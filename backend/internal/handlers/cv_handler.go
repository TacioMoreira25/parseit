package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/tacio/parseit-backend/internal/repository"
	"github.com/tacio/parseit-backend/internal/services"
)

type CVHandler struct {
	Repo       *repository.CVRepository
	PDFService *services.PDFService
}

func NewCVHandler(repo *repository.CVRepository, pdfService *services.PDFService) *CVHandler {
	return &CVHandler{Repo: repo, PDFService: pdfService}
}

// CreateCV - POST /api/v1/cvs
func (h *CVHandler) CreateCV(c *gin.Context) {
	var req struct {
		UserID string `json:"user_id"`
		Title  string `json:"title"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	cv, err := h.Repo.CreateCV(req.UserID, req.Title)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, cv)
}

// AddBlock - POST /api/v1/cvs/:id/blocks
func (h *CVHandler) AddBlock(c *gin.Context) {
	cvID := c.Param("id")
	var req struct {
		Type     string      `json:"type"`
		Position int         `json:"position"`
		Content  interface{} `json:"content"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	block, err := h.Repo.AddBlock(cvID, req.Type, req.Content, req.Position)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, block)
}

// GetCV - GET /api/v1/cvs/:id
func (h *CVHandler) GetCV(c *gin.Context) {
	cvID := c.Param("id")

	cv, err := h.Repo.GetCV(cvID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "CV not found"})
		return
	}

	c.JSON(http.StatusOK, cv)
}

// UpdateOrder - PUT /api/v1/cvs/:id/order
func (h *CVHandler) UpdateOrder(c *gin.Context) {
	cvID := c.Param("id")
	var req struct {
		BlockIDs []string `json:"block_ids"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := h.Repo.UpdateBlockOrder(cvID, req.BlockIDs); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.Status(http.StatusOK)
}

// GeneratePDF - GET /api/v1/cvs/:id/pdf
func (h *CVHandler) GeneratePDF(c *gin.Context) {
	cvID := c.Param("id")

	cv, err := h.Repo.GetCV(cvID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "CV not found"})
		return
	}

	pdfBytes, err := h.PDFService.GeneratePDF(cv.Blocks)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate PDF"})
		return
	}

	// Configura headers para download
	c.Header("Content-Disposition", "attachment; filename=cv.pdf")
	c.Data(http.StatusOK, "application/pdf", pdfBytes)
}
