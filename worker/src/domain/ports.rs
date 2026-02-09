use async_trait::async_trait;
use crate::domain::entities::{Job, Vocabulary};
use std::error::Error;

#[async_trait]
pub trait JobRepository: Send + Sync {
    async fn update_tags(&self, job_id: i64, tags:  &[String]) -> Result<(), Box<dyn Error>>;
}

#[async_trait]
pub trait VocabularyRepository: Send + Sync {
    async fn exists(&self, term: &str) -> Result<bool, Box<dyn Error>>;
    async fn save(&self, vocab: &Vocabulary) -> Result<(), Box<dyn Error>>;
}

#[async_trait]
pub trait NLPService: Send + Sync {
    fn extract_keywords(&self, text: &str) -> Vec<String>;
}

#[async_trait]
pub trait AIService: Send + Sync {
    async fn fetch_definition(&self, term: &str) -> Result<Vocabulary, Box<dyn Error>>;
}
