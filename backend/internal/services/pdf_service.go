package services

import (
	"encoding/json"
	"fmt"

	"github.com/johnfercher/maroto/pkg/consts"
	"github.com/johnfercher/maroto/pkg/pdf"
	"github.com/johnfercher/maroto/pkg/props"
	"github.com/tacio/parseit-backend/internal/models"
)

type PDFService struct{}

func NewPDFService() *PDFService {
	return &PDFService{}
}

func (s *PDFService) GeneratePDF(blocks []models.CVBlock) ([]byte, error) {
	m := pdf.NewMaroto(consts.Portrait, consts.A4)
	m.SetPageMargins(20, 10, 20)

	for _, block := range blocks {
		switch block.Type {
		case "HEADER":
			var data models.HeaderBlockData
			if err := json.Unmarshal(block.Content, &data); err == nil {
				renderHeader(m, data)
			}
		case "TEXT":
			var data models.TextBlockData
			if err := json.Unmarshal(block.Content, &data); err == nil {
				renderText(m, data)
			}
		case "EXPERIENCE":
			var data models.ExperienceBlockData
			if err := json.Unmarshal(block.Content, &data); err == nil {
				renderExperience(m, data)
			}
		case "SPACER":
			m.Line(5)
		}
	}

	buffer, err := m.Output()
	if err != nil {
		return nil, err
	}
	return buffer.Bytes(), nil
}

// Funções auxiliares de renderização
func renderHeader(m pdf.Maroto, data models.HeaderBlockData) {
	m.Row(20, func() {
		m.Col(12, func() {
			m.Text(data.FullName, props.Text{
				Size:  18,
				Style: consts.Bold,
				Align: consts.Center,
			})
		})
	})
	m.Row(10, func() {
		m.Col(12, func() {
			contact := fmt.Sprintf("%s | %s | %s", data.Email, data.Phone, data.Link)
			m.Text(contact, props.Text{Size: 10, Align: consts.Center})
		})
	})
	m.Row(10, func() {
		m.Col(12, func() {
			m.Text(data.Address, props.Text{Size: 10, Align: consts.Center})
		})
	})
}

func renderText(m pdf.Maroto, data models.TextBlockData) {
	// Cria uma linha básica. Para textos grandes reais, considerar calcular altura
	m.Row(10, func() {
		m.Col(12, func() {
			m.Text(data.Text, props.Text{
				Size:        11,
				Align:       consts.Left,
				Extrapolate: false,
			})
		})
	})
}

func renderExperience(m pdf.Maroto, data models.ExperienceBlockData) {
	m.Row(10, func() {
		m.Col(8, func() {
			m.Text(data.Role, props.Text{Style: consts.Bold, Size: 12})
		})
		m.Col(4, func() {
			m.Text(data.DateRange, props.Text{Align: consts.Right, Size: 10})
		})
	})
	m.Row(8, func() {
		m.Col(12, func() {
			m.Text(data.Company, props.Text{Style: consts.Italic, Size: 11})
		})
	})
	m.Row(10, func() {
		m.Col(12, func() {
			m.Text(data.Description, props.Text{Size: 10})
		})
	})
}
