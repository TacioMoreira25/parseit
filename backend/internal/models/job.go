package models

import "gorm.io/gorm"

type Job struct {
	gorm.Model
	Title       string `json:"title"`
	Description string `json:"description"`
	Link        string `json:"link"`
	Status      string `json:"status" gorm:"default:'applied'"`
}