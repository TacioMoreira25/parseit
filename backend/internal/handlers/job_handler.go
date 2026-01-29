package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/tacio/parseit-backend/internal/models"
	"gorm.io/gorm"
)

// JobHandler segura a conexão do banco para usar nas rotas
type JobHandler struct {
	DB *gorm.DB
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

	c.JSON(http.StatusCreated, job)
}

// ListJobs busca tudo
func (h *JobHandler) ListJobs(c *gin.Context) {
	var jobs []models.Job
	h.DB.Find(&jobs)
	c.JSON(http.StatusOK, jobs)
}