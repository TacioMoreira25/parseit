package routes

import (
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
	"github.com/tacio/parseit-backend/internal/handlers"
	"gorm.io/gorm"
	"time"
)

func SetupRoutes(r *gin.Engine, db *gorm.DB, rdb *redis.Client) {
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))
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

		// Vocabulary routes
		api.POST("/vocabulary/lookup", vocabularyHandler.LookupTerms)
	}
}