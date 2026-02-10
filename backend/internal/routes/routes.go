package routes

import (
	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
	"github.com/tacio/parseit-backend/internal/database"
	"github.com/tacio/parseit-backend/internal/handlers"
	"github.com/tacio/parseit-backend/internal/middleware"
	"github.com/tacio/parseit-backend/internal/repository"
	"github.com/tacio/parseit-backend/internal/services"
	"gorm.io/gorm"
)

func SetupRoutes(r *gin.Engine, db *gorm.DB, rdb *redis.Client) {
	r.Use(middleware.CORSMiddleware())

	// Inicializa conexão SQLX para o CVRepository
	sqlxDB := database.GetSQLXDB(db)
	cvRepo := repository.NewCVRepository(sqlxDB)
	pdfService := services.NewPDFService()

	// Iniciamos os Handlers injetando o banco
	jobHandler := &handlers.JobHandler{DB: db, Redis: rdb}
	vocabularyHandler := &handlers.VocabularyHandler{DB: db}
	cvHandler := handlers.NewCVHandler(cvRepo, pdfService)

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

		// CV routes
        api.POST("/cvs", cvHandler.CreateCV)
        api.GET("/cvs", cvHandler.GetCVs)
        api.GET("/cvs/:id", cvHandler.GetCV)
        
        api.POST("/cvs/:id/blocks", cvHandler.AddBlock)
        
        api.PATCH("/cvs/:id/blocks/:blockId", cvHandler.UpdateBlock)
        api.DELETE("/cvs/:id/blocks/:blockId", cvHandler.DeleteBlock)
        // ---------------------------

        api.POST("/cvs/:id/reorder", cvHandler.ReorderBlocks)
        api.GET("/cvs/:id/pdf", cvHandler.GeneratePDF)
	}
}
