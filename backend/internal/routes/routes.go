package routes

import (
	"github.com/gin-gonic/gin"
	"github.com/tacio/parseit-backend/internal/handlers"
	"gorm.io/gorm"
)

func SetupRoutes(r *gin.Engine, db *gorm.DB) {
	// Iniciamos o Handler injetando o banco
	jobHandler := &handlers.JobHandler{DB: db}

	// Grupo de rotas
	api := r.Group("/api/v1")
	{
		api.POST("/jobs", jobHandler.CreateJob)
		api.GET("/jobs", jobHandler.ListJobs)
	}
}