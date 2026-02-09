package models

import (
	"encoding/json"
	"time"
)

// CV representa o currículo (Resume)
type CV struct {
	ID        string    `json:"id" db:"id" gorm:"primaryKey"`
	UserID    string    `json:"user_id" db:"user_id"`
	Title     string    `json:"title" db:"title"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
	Blocks    []CVBlock `json:"blocks,omitempty" db:"-" gorm:"foreignKey:CVID"` // Populado manualmente
}

// CVBlock representa um bloco de conteúdo no CV
type CVBlock struct {
	ID        string          `json:"id" db:"id" gorm:"primaryKey"`
	CVID      string          `json:"cv_id" db:"cv_id" gorm:"index"`
	Type      string          `json:"type" db:"type"` // HEADER, TEXT, EXPERIENCE, SPACER
	Position  int             `json:"position" db:"position"`
	Content   json.RawMessage `json:"content" db:"content" gorm:"type:jsonb"` // JSONB
	CreatedAt time.Time       `json:"created_at" db:"created_at"`
	UpdatedAt time.Time       `json:"updated_at" db:"updated_at"`
}

// Helpers para tipagem do Content
type HeaderBlockData struct {
	FullName string `json:"full_name"`
	Email    string `json:"email"`
	Phone    string `json:"phone"`
	Address  string `json:"address"`
	Link     string `json:"link"`
}

type TextBlockData struct {
	Text string `json:"text"`
}

type ExperienceBlockData struct {
	Company     string `json:"company"`
	Role        string `json:"role"`
	DateRange   string `json:"date_range"`
	Description string `json:"description"`
}
