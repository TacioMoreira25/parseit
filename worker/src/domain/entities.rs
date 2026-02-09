use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct Job {
    pub id: i64,
    pub description: String,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Vocabulary {
    pub term: String,
    pub definition_en: String,
    pub translation_pt: String,
    pub phonetic_ipa: String,
    pub grammatical_category: String,
    pub example_sentence_en: String,
    pub example_sentence_pt: String,
}
