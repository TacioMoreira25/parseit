package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/tacio/parseit-backend/internal/database"
	"gorm.io/gorm"
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

	if err := c.ShouldBindJSON(&requestBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	if len(requestBody.Terms) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Terms list cannot be empty"})
		return
	}

	vocabularies, err := database.GetVocabularyByTerms(h.DB, requestBody.Terms)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve vocabulary from database"})
		return
	}

	c.JSON(http.StatusOK, vocabularies)
}
