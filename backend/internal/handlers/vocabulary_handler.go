package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/tacio/parseit-backend/internal/database"
	"gorm.io/gorm"
	"strings"
)

// VocabularyHandler holds the database connection.
type VocabularyHandler struct {
	DB *gorm.DB
}

// lookupRequest defines the structure for the JSON request body.
type lookupRequest struct {
	Terms []string `json:"terms"`
}

// LookupTerms handles the POST request to fetch vocabulary details.
func (h *VocabularyHandler) LookupTerms(c *gin.Context) {
    var requestBody lookupRequest

    // 1. Tenta ler o JSON
    if err := c.ShouldBindJSON(&requestBody); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid JSON format"})
        return
    }

    // 2. FILTRO INTELIGENTE (A Novidade)
    var validTerms []string
    for _, term := range requestBody.Terms {
        // Remove espaços antes e depois (ex: "  rust  " vira "rust")
        cleanTerm := strings.TrimSpace(term)
        
        // Só adiciona se não for vazio
        if cleanTerm != "" {
            validTerms = append(validTerms, strings.ToLower(cleanTerm))
        }
    }

    // 3. Bloqueio: Se depois da limpeza não sobrou nada...
    if len(validTerms) == 0 {
        c.JSON(http.StatusBadRequest, gin.H{
            "error": "Nenhum termo válido encontrado. Envie pelo menos uma palavra (não vazia).",
        })
        return
    }

    // 4. Agora sim, busca no banco só o que presta
    vocabulary, err := database.GetVocabularyByTerms(h.DB, validTerms)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve vocabulary"})
        return
    }

    c.JSON(http.StatusOK, vocabulary)
}