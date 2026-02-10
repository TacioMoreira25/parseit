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

func (r *CVRepository) AddBlock(cvID string, block models.CVBlock) (*models.CVBlock, error) {
	if block.ID == "" {
		block.ID = uuid.New().String()
	}
	if block.CreatedAt.IsZero() {
		block.CreatedAt = time.Now()
	}
	block.UpdatedAt = time.Now()
	block.CVID = cvID

	// Ensure content is valid JSON
	if len(block.Content) == 0 {
		block.Content = json.RawMessage("{}")
	}

	query := `INSERT INTO cv_blocks (id, cv_id, type, position, content, created_at, updated_at) 
			  VALUES (:id, :cv_id, :type, :position, :content, :created_at, :updated_at)`

	_, err := r.DB.NamedExec(query, block)
	if err != nil {
		return nil, fmt.Errorf("failed to add block: %w", err)
	}

	return &block, nil
}

func (r *CVRepository) GetCV(cvID string) (*models.CV, error) {
	var cv models.CV
	// Busca o CV
	if err := r.DB.Get(&cv, "SELECT * FROM cvs WHERE id = $1", cvID); err != nil {
		return nil, err
	}

	// Busca os Blocos ordenados por position ASC
	var blocks []models.CVBlock
	err := r.DB.Select(&blocks, "SELECT * FROM cv_blocks WHERE cv_id = $1 ORDER BY position ASC", cvID)
	if err != nil {
		return nil, err
	}

	cv.Blocks = blocks
	return &cv, nil
}

func (r *CVRepository) GetCVs() ([]models.CV, error) {
	var cvs []models.CV
	
	// Ordenamos pelo mais recente (updated_at DESC)
	query := `SELECT id, user_id, title, created_at, updated_at FROM cvs ORDER BY updated_at DESC`
	
	err := r.DB.Select(&cvs, query)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch cvs: %w", err)
	}

	// Garante que retorna um array vazio [] em vez de null se não houver registros
	if cvs == nil {
		cvs = []models.CV{}
	}

	return cvs, nil
}

func (r *CVRepository) UpdateBlockPositions(cvID string, blockIDs []string) error {
	tx, err := r.DB.Beginx()
	if err != nil {
		return err
	}
	defer tx.Rollback()

	query := `UPDATE cv_blocks SET position = $1, updated_at = $2 WHERE id = $3 AND cv_id = $4`

	for i, blockID := range blockIDs {
		// i serve como a nova posição (0-based)
		// blockID é o ID do bloco que deve estar na posição i
		if _, err := tx.Exec(query, i, time.Now(), blockID, cvID); err != nil {
			return fmt.Errorf("erro atualizando ordem bloco %s: %w", blockID, err)
		}
	}

	return tx.Commit()
}

// UpdateBlock atualiza o conteúdo JSON de um bloco específico
func (r *CVRepository) UpdateBlock(cvID, blockID string, content interface{}) error {
	contentBytes, err := json.Marshal(content)
	if err != nil {
		return fmt.Errorf("failed to marshal content: %w", err)
	}

	query := `UPDATE cv_blocks SET content = $1, updated_at = $2 WHERE id = $3 AND cv_id = $4`
	
	result, err := r.DB.Exec(query, contentBytes, time.Now(), blockID, cvID)
	if err != nil {
		return fmt.Errorf("failed to update block: %w", err)
	}

	rows, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if rows == 0 {
		return fmt.Errorf("block not found or access denied")
	}

	return nil
}

// DeleteBlock remove um bloco do banco
func (r *CVRepository) DeleteBlock(cvID, blockID string) error {
	query := `DELETE FROM cv_blocks WHERE id = $1 AND cv_id = $2`
	
	result, err := r.DB.Exec(query, blockID, cvID)
	if err != nil {
		return fmt.Errorf("failed to delete block: %w", err)
	}

	rows, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if rows == 0 {
		return fmt.Errorf("block not found")
	}

	return nil
}
