package routes

import (
	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
	"github.com/tacio/parseit-backend/internal/handlers"
	"github.com/tacio/parseit-backend/internal/middleware"
	"gorm.io/gorm"
)

func SetupRoutes(r *gin.Engine, db *gorm.DB, rdb *redis.Client) {
	r.Use(middleware.CORSMiddleware())

	// Iniciamos os Handlers injetando o banco
	jobHandler := &handlers.JobHandler{DB: db, Redis: rdb}
	vocabularyHandler := &handlers.VocabularyHandler{DB: db}

	// Grupo de rotas
	api := r.Group("/api/v1")
	{
		// Job routes
		api.POST("/jobs", jobHandler.CreateJob)
		api.GET("/jobs", jobHandler.ListJobs)
		api.GET("/jobs/:id/cards", jobHandler.GetJobCards)
		api.DELETE("/jobs/:id", jobHandler.DeleteJob)
		api.PATCH("/jobs/:id", jobHandler.UpdateJob)
		api.PATCH("/jobs/:id/status", jobHandler.UpdateJobStatus)

		// Vocabulary routes
		api.POST("/vocabulary/lookup", vocabularyHandler.LookupTerms)
	}
}
