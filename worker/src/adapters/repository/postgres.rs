use async_trait::async_trait;
use sqlx::PgPool;
use sqlx::Row;
use std::error::Error;

use crate::domain::entities::Vocabulary;
use crate::domain::ports::{JobRepository, VocabularyRepository};

pub struct PostgresRepository {
    pool: PgPool,
}

impl PostgresRepository {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }
}

#[async_trait]
impl JobRepository for PostgresRepository {
    async fn update_tags(&self, job_id: i64, tags: &[String]) -> Result<(), Box<dyn Error>> {
        let tags_string = tags.join(",");
        
        sqlx::query("UPDATE jobs SET tags = $1 WHERE id = $2")
            .bind(&tags_string)
            .bind(job_id)
            .execute(&self.pool)
            .await?;
            
        Ok(())
    }
}

#[async_trait]
impl VocabularyRepository for PostgresRepository {
    async fn exists(&self, term: &str) -> Result<bool, Box<dyn Error>> {
        let row = sqlx::query("SELECT exists(SELECT 1 FROM vocabulary WHERE term = $1)")
            .bind(term)
            .fetch_one(&self.pool)
            .await?;

        let exists: bool = row.try_get(0)?;
        Ok(exists)
    }

    async fn save(&self, vocab: &Vocabulary) -> Result<(), Box<dyn Error>> {
        sqlx::query!(
            r#"
            INSERT INTO vocabulary 
            (term, definition_en, translation_pt, phonetic_ipa, grammatical_category, example_sentence_en, example_sentence_pt)
            VALUES ($1, $2, $3, $4, $5, $6, $7)
            ON CONFLICT (term) DO NOTHING
            "#,
            vocab.term,
            vocab.definition_en,
            vocab.translation_pt,
            vocab.phonetic_ipa,
            vocab.grammatical_category,
            vocab.example_sentence_en,
            vocab.example_sentence_pt
        )
        .execute(&self.pool)
        .await?;

        Ok(())
    }
}
