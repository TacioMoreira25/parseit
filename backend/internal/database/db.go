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
		db.AutoMigrate(&models.Job{}, &models.Vocabulary{})
	
		log.Println("Banco conectado e migrado com sucesso!")
		return db
	}
	
	// GetVocabularyByTerms retrieves a list of vocabulary entries by their terms.
	func GetVocabularyByTerms(db *gorm.DB, terms []string) ([]models.Vocabulary, error) {
		var vocabulary []models.Vocabulary
		if err := db.Where("term IN ?", terms).Find(&vocabulary).Error; err != nil {
			return nil, err
		}
		return vocabulary, nil
	}
	