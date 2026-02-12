package models

import "gorm.io/gorm"

type Job struct {
	gorm.Model
	Title       string `json:"title"`
	Company     string `json:"company"`     // Novo
	Description string `json:"description"`
	Link        string `json:"link"`
	Status      string `json:"status" gorm:"default:'applied'"`
	Tags        string `json:"tags"`
	// Novos Campos
	JobType  string `json:"job_type" gorm:"default:'Integral'"` 
	Location string `json:"location" gorm:"default:'Remoto'"`  
	Salary   string `json:"salary"`                             
}