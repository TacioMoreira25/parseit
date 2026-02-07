use serde::Deserialize;
use sqlx::FromRow;

#[derive(Deserialize, Debug)]
pub struct JobEvent {
    pub id: u32,
    pub description: String,
}

#[derive(FromRow, Debug, Clone)]
pub struct Vocabulary {
    pub term: String,
    pub definition_en: String,
    pub translation_pt: String,
    pub phonetic_ipa: String,
    pub grammatical_category: String,
    pub example_sentence_en: String,
    pub example_sentence_pt: String,
}