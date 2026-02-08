package models

type Vocabulary struct {
	Term                string `json:"term"`
	DefinitionEn        string `json:"definition_en"`
	TranslationPt       string `json:"translation_pt"`
	PhoneticIPA         string `json:"phonetic_ipa"`
	GrammaticalCategory string `json:"grammatical_category"`
	ExampleSentenceEn   string `json:"example_sentence_en"`
	ExampleSentencePt   string `json:"example_sentence_pt"`
}

func (Vocabulary) TableName() string {
    return "vocabulary"
}