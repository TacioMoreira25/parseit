package database

import (
	"log"
	"os"

	"github.com/tacio/parseit-backend/internal/models"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

// InitDB conecta e roda as migrações
func InitDB() *gorm.DB {
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		log.Fatal("Erro: DATABASE_URL não encontrada")
	}

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("Erro: Falha ao conectar no banco:", err)
	}

	// Migração Automática (Cria tabelas baseadas nos Models)
	// Adicione novos models aqui quando criar
	db.AutoMigrate(&models.Job{})
	
	log.Println("Banco conectado e migrado com sucesso!")
	return db
}