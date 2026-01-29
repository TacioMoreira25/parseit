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