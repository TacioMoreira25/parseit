package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/tacio/parseit-backend/internal/models"
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
	var req models.CVBlock

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	block, err := h.Repo.AddBlock(cvID, req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, block)
}

// GetCVs handles GET /api/v1/cvs
func (h *CVHandler) GetCVs(c *gin.Context) {
	cvs, err := h.Repo.GetCVs()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch cvs"})
		return
	}

	c.JSON(http.StatusOK, cvs)
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

// ReorderBlocks - POST /api/v1/cvs/:id/reorder
func (h *CVHandler) ReorderBlocks(c *gin.Context) {
	cvID := c.Param("id")
	var req struct {
		BlockIDs []string `json:"block_ids"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := h.Repo.UpdateBlockPositions(cvID, req.BlockIDs); err != nil {
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

// UpdateBlock handles PATCH /api/v1/cvs/:id/blocks/:blockId
func (h *CVHandler) UpdateBlock(c *gin.Context) {
	cvID := c.Param("id")
	blockID := c.Param("blockId")

	// Estrutura para receber apenas o campo "content" do JSON
	var payload struct {
		Content interface{} `json:"content"`
	}

	if err := c.ShouldBindJSON(&payload); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid payload"})
		return
	}

	if err := h.Repo.UpdateBlock(cvID, blockID, payload.Content); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "block updated"})
}

// DeleteBlock handles DELETE /api/v1/cvs/:id/blocks/:blockId
func (h *CVHandler) DeleteBlock(c *gin.Context) {
	cvID := c.Param("id")
	blockID := c.Param("blockId")

	if err := h.Repo.DeleteBlock(cvID, blockID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "block deleted"})
}