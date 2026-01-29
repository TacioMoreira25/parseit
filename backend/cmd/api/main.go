package main

import (
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"github.com/tacio/parseit-backend/internal/database"
	"github.com/tacio/parseit-backend/internal/routes"
)

func main() {
	// 1. Carrega variáveis
	godotenv.Load("../.env") 

	// 2. Inicia Banco
	db := database.InitDB()

	// 3. Inicia Gin
	r := gin.Default()

	// 4. Configura Rotas
	routes.SetupRoutes(r, db)

	// 5. Roda
	r.Run(":8080")
}