package models

// Vocabulary represents the structure for a technical term in the database.
type Vocabulary struct {
	Term                string `json:"term" gorm:"primaryKey"`
	DefinitionEN        string `json:"definition_en" gorm:"not null"`
	TranslationPT       string `json:"translation_pt" gorm:"not null"`
	PhoneticIPA         string `json:"phonetic_ipa"`
	GrammaticalCategory string `json:"grammatical_category" gorm:"not null"`
	ExampleSentenceEN   string `json:"example_sentence_en"`
	ExampleSentencePT   string `json:"example_sentence_pt"`
}
