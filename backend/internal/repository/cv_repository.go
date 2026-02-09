package repository

import (
	"encoding/json"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
	"github.com/tacio/parseit-backend/internal/models"
)

type CVRepository struct {
	DB *sqlx.DB
}

func NewCVRepository(db *sqlx.DB) *CVRepository {
	return &CVRepository{DB: db}
}

func (r *CVRepository) CreateCV(userID, title string) (*models.CV, error) {
	cv := &models.CV{
		ID:        uuid.New().String(),
		UserID:    userID,
		Title:     title,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	query := `INSERT INTO cvs (id, user_id, title, created_at, updated_at) 
			  VALUES (:id, :user_id, :title, :created_at, :updated_at)`

	_, err := r.DB.NamedExec(query, cv)
	if err != nil {
		return nil, fmt.Errorf("failed to create cv: %w", err)
	}

	return cv, nil
}

func (r *CVRepository) AddBlock(cvID, blockType string, content interface{}, position int) (*models.CVBlock, error) {
	contentBytes, err := json.Marshal(content)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal content: %w", err)
	}

	block := &models.CVBlock{
		ID:        uuid.New().String(),
		CVID:      cvID,
		Type:      blockType,
		Position:  position,
		Content:   json.RawMessage(contentBytes),
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	query := `INSERT INTO cv_blocks (id, cv_id, type, position, content, created_at, updated_at) 
			  VALUES (:id, :cv_id, :type, :position, :content, :created_at, :updated_at)`

	_, err = r.DB.NamedExec(query, block)
	if err != nil {
		return nil, fmt.Errorf("failed to add block: %w", err)
	}

	return block, nil
}

func (r *CVRepository) GetCV(cvID string) (*models.CV, error) {
	var cv models.CV
	// Busca o CV
	if err := r.DB.Get(&cv, "SELECT * FROM cvs WHERE id = $1", cvID); err != nil {
		return nil, err
	}

	// Busca os Blocos ordenados
	var blocks []models.CVBlock
	err := r.DB.Select(&blocks, "SELECT * FROM cv_blocks WHERE cv_id = $1 ORDER BY position ASC", cvID)
	if err != nil {
		return nil, err
	}

	cv.Blocks = blocks
	return &cv, nil
}

func (r *CVRepository) UpdateBlockOrder(cvID string, blockIDs []string) error {
	tx, err := r.DB.Beginx()
	if err != nil {
		return err
	}
	defer tx.Rollback()

	query := `UPDATE cv_blocks SET position = $1, updated_at = $2 WHERE id = $3 AND cv_id = $4`

	for i, blockID := range blockIDs {
		// i serve como a nova posição (0-based)
		if _, err := tx.Exec(query, i, time.Now(), blockID, cvID); err != nil {
			return fmt.Errorf("erro atualizando ordem bloco %s: %w", blockID, err)
		}
	}

	return tx.Commit()
}
