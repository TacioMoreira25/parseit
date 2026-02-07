package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
	"github.com/tacio/parseit-backend/internal/models"
	"github.com/tacio/parseit-backend/internal/queue"
	"gorm.io/gorm"
	"strings"
)

// JobHandler segura a conexão do banco para usar nas rotas
type JobHandler struct {
	DB *gorm.DB
	Redis *redis.Client
}

// CreateJob recebe o JSON e salva
func (h *JobHandler) CreateJob(c *gin.Context) {
	var job models.Job
	
	if err := c.ShouldBindJSON(&job); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	result := h.DB.Create(&job)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": result.Error.Error()})
		return
	}

	msg := map[string]interface{}{
		"id": job.ID,
		"description": job.Description,
	}

	msgBytes, _ := json.Marshal(msg)

	err := h.Redis.Publish(queue.Ctx, "job_created", msgBytes).Err()
	if err != nil {
		c.JSON(http.StatusCreated, gin.H{"job": job, "warning": "Falha ao enviar para análise"})		
		return
	}	

	c.JSON(http.StatusCreated, job)
}

// ListJobs busca tudo
func (h *JobHandler) ListJobs(c *gin.Context) {
	var jobs []models.Job
	h.DB.Find(&jobs)
	c.JSON(http.StatusOK, jobs)
}

func (h *JobHandler) GetJobCards(c *gin.Context) {
	id := c.Param("id")
	var job models.Job

	// Busca a vaga pelo ID
	if result := h.DB.First(&job, id); result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Vaga não encontrada"})
		return
	}

	// Se não tiver tags, retorna lista vazia
	if job.Tags == "" {
		c.JSON(http.StatusOK, gin.H{"cards": []string{}})
		return
	}

	// Quebra a string "go,rust,docker" em um array ["go", "rust", "docker"]
	cards := strings.Split(job.Tags, ",")

	c.JSON(http.StatusOK, gin.H{
		"job_title": job.Title,
		"cards":     cards,
	})
}

// DeleteJob remove um job do banco de dados.
func (h *JobHandler) DeleteJob(c *gin.Context) {
	id := c.Param("id")

	// Se o GORM não encontrar o registro para deletar, ele retorna um erro.
	result := h.DB.Unscoped().Delete(&models.Job{}, id)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": result.Error.Error()})
		return
	}

	// O GORM informa quantos registros foram afetados. Se for 0, o ID não foi encontrado.
	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Vaga não encontrada para exclusão"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Vaga excluída com sucesso"})
}

// UpdateJobStatus atualiza o status de uma vaga.
func (h *JobHandler) UpdateJobStatus(c *gin.Context) {
	id := c.Param("id")

	// Define uma struct local para fazer o bind apenas do campo de status.
	var statusUpdate struct {
		Status string `json:"status"`
	}

	// Faz o bind do JSON do corpo da requisição para a struct.
	if err := c.ShouldBindJSON(&statusUpdate); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "JSON inválido: " + err.Error()})
		return
	}

	// Valida se o status fornecido é um dos valores permitidos.
	status := statusUpdate.Status
	allowedStatuses := map[string]bool{
		"applied":   true,
		"interview": true,
		"offer":     true,
		"rejected":  true,
	}

	if !allowedStatuses[status] {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Status inválido. Use 'applied', 'interview', 'offer' ou 'rejected'"})
		return
	}

	// Busca o job para garantir que ele existe antes de atualizar.
	var job models.Job
	if result := h.DB.First(&job, id); result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Vaga não encontrada"})
		return
	}

	// Atualiza apenas o campo 'status' do job encontrado.
	result := h.DB.Model(&job).Update("status", status)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Falha ao atualizar o status: " + result.Error.Error()})
		return
	}

	c.JSON(http.StatusOK, job)
}

func (h *JobHandler) UpdateJob(c *gin.Context) {
	id := c.Param("id")

	// Encontra a vaga existente
	var job models.Job
	if result := h.DB.First(&job, id); result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Vaga não encontrada"})
		return
	}

	// Define uma struct para o payload de atualização
	var updatePayload struct {
		Title       *string `json:"title"`
		Description *string `json:"description"`
		Link        *string `json:"link"`
	}

	// Faz o bind do JSON, ignorando campos não enviados
	if err := c.ShouldBindJSON(&updatePayload); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "JSON inválido: " + err.Error()})
		return
	}

	// Atualiza o modelo do GORM com os novos valores, se eles não forem nulos
	updates := make(map[string]interface{})
	if updatePayload.Title != nil {
		updates["title"] = *updatePayload.Title
	}
	if updatePayload.Description != nil {
		updates["description"] = *updatePayload.Description
	}
	if updatePayload.Link != nil {
		updates["link"] = *updatePayload.Link
	}

	// Se nada foi enviado, não faz nada
	if len(updates) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Nenhum campo para atualizar foi fornecido"})
		return
	}

	// Aplica as atualizações no banco de dados
	if result := h.DB.Model(&job).Updates(updates); result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Falha ao atualizar a vaga: " + result.Error.Error()})
		return
	}

	c.JSON(http.StatusOK, job)
}