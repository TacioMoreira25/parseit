package models

import (
	"encoding/json"
	"time"
)

// CV representa o currículo (Resume)
type CV struct {
	ID        string    `json:"id" db:"id"`
	UserID    string    `json:"user_id" db:"user_id"`
	Title     string    `json:"title" db:"title"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
	Blocks    []CVBlock `json:"blocks,omitempty" db:"-"` // Populado manualmente
}

// CVBlock representa um bloco de conteúdo no CV
type CVBlock struct {
	ID        string          `json:"id" db:"id"`
	CVID      string          `json:"cv_id" db:"cv_id"`
	Type      string          `json:"type" db:"type"` // HEADER, TEXT, EXPERIENCE, SPACER
	Position  int             `json:"position" db:"position"`
	Content   json.RawMessage `json:"content" db:"content"` // JSONB
	CreatedAt time.Time       `json:"created_at" db:"created_at"`
	UpdatedAt time.Time       `json:"updated_at" db:"updated_at"`
}

// HeaderBlockData define o conteúdo para blocos do tipo HEADER
type HeaderBlockData struct {
	FullName string `json:"full_name"`
	Email    string `json:"email"`
	Phone    string `json:"phone"`
	Address  string `json:"address"`
	Link     string `json:"link"`
}

// TextBlockData define o conteúdo para blocos do tipo TEXT
type TextBlockData struct {
	Text string `json:"text"`
}

// ExperienceBlockData define o conteúdo para blocos do tipo EXPERIENCE
type ExperienceBlockData struct {
	Company     string `json:"company"`
	Role        string `json:"role"`
	DateRange   string `json:"date_range"`
	Description string `json:"description"`
}
