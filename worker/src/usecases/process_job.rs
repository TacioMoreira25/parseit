use std::sync::Arc;
use std::error::Error;
use crate::domain::entities::Job;
use crate::domain::ports::{JobRepository, VocabularyRepository, NLPService, AIService};

pub struct ProcessJobUseCase {
    job_repo: Arc<dyn JobRepository>,
    vocab_repo: Arc<dyn VocabularyRepository>,
    nlp_service: Arc<dyn NLPService>,
    ai_service: Arc<dyn AIService>,
}

impl ProcessJobUseCase {
    pub fn new(
        job_repo: Arc<dyn JobRepository>,
        vocab_repo: Arc<dyn VocabularyRepository>,
        nlp_service: Arc<dyn NLPService>,
        ai_service: Arc<dyn AIService>,
    ) -> Self {
        Self {
            job_repo,
            vocab_repo,
            nlp_service,
            ai_service,
        }
    }

    pub async fn execute(&self, job: Job) -> Result<Vec<String>, Box<dyn Error>> {
        // 1. Extract Keywords
        let keywords = self.nlp_service.extract_keywords(&job.description);
        
        if keywords.is_empty() {
             return Ok(vec![]);
        }

        // 2. Process Vocabulary
        for term in &keywords {
            let term_lower = term.to_lowercase();
            
            // A. Check Cache/DB
            match self.vocab_repo.exists(&term_lower).await {
                Ok(true) => {
                    println!("⏭️ '{}' já existe no vocabulário.", term_lower);
                    continue; // Already exists
                },
                Err(e) => {
                    eprintln!("Erro ao verificar existência de '{}': {}", term_lower, e);
                }
                Ok(false) => {}
            }

            // B. Fetch from AI
            println!("🔍 Buscando definição para '{}'...", term_lower);
            match self.ai_service.fetch_definition(&term_lower).await {
                Ok(vocab_data) => {
                     // C. Save to DB
                     if let Err(e) = self.vocab_repo.save(&vocab_data).await {
                         eprintln!("❌ Erro ao salvar '{}': {}", term_lower, e);
                     } else {
                         println!("✅ '{}' salvo com sucesso!", term_lower);
                     }
                },
                Err(e) => {
                    eprintln!("⚠️ Falha ao buscar '{}' na IA: {}", term_lower, e);
                }
            }
        }

        // 3. Update Job
        self.job_repo.update_tags(job.id, &keywords).await?;
        
        Ok(keywords)
    }
}
