mod domain;
mod usecases;
mod adapters;

use dotenv::dotenv;
use futures_util::StreamExt;
use sqlx::postgres::PgPoolOptions;
use std::sync::Arc;

use adapters::config;
use adapters::groq::client::GroqClient;
use adapters::nlp::custom_extractor::CustomNLPService;
use adapters::repository::postgres::PostgresRepository;
use usecases::process_job::ProcessJobUseCase;
use domain::entities::Job;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    dotenv().ok();
    println!("🦀 Worker Rust Iniciando (Clean Architecture)...");

    // 1. Configurações
    let redis_url = config::get_redis_url();
    let db_url = config::get_database_url();
    let groq_api_key = config::get_groq_api_key();

    // 2. Conecta no Banco de Dados (Postgres)
    println!("Conectando ao Postgres...");
    let db_pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(&db_url)
        .await?;
    println!("Postgres conectado!");

    // 3. Inicializa Adapters e Usecases
    let repo = Arc::new(PostgresRepository::new(db_pool.clone()));
    let nlp_service = Arc::new(CustomNLPService::new());
    let ai_service = Arc::new(GroqClient::new(groq_api_key));

    // Castings explícitos para Traits (necessário para injeção de dependência)
    let job_repo: Arc<dyn domain::ports::JobRepository> = repo.clone();
    let vocab_repo: Arc<dyn domain::ports::VocabularyRepository> = repo.clone();
    let nlp: Arc<dyn domain::ports::NLPService> = nlp_service;
    let ai: Arc<dyn domain::ports::AIService> = ai_service;

    let process_job_usecase = ProcessJobUseCase::new(
        job_repo,
        vocab_repo,
        nlp,
        ai,
    );

    // 4. Conecta no Redis
    let client = redis::Client::open(redis_url.clone())?;
    let conn = client.get_async_connection().await?;
    let mut pubsub = conn.into_pubsub();
    pubsub.subscribe("job_created").await?;

    // Conexão separada para publicar respostas
    let publisher_client = redis::Client::open(redis_url)?;
    let mut publisher_conn = publisher_client.get_async_connection().await?;

    println!("Redis conectado! Aguardando vagas...");

    let mut on_message = pubsub.into_on_message();

    // 5. Loop Principal
    while let Some(msg) = on_message.next().await {
        if let Ok(payload) = msg.get_payload::<String>() {
            // Tenta deserializar para nossa entidade de domínio
            if let Ok(job) = serde_json::from_str::<Job>(&payload) {
                println!("\nVaga Recebida ID: {}", job.id);

                // Executa o Caso de Uso
                match process_job_usecase.execute(job.clone()).await {
                    Ok(keywords) => {
                        let tags_string = keywords.join(",");
                        println!("Processamento concluído. Tags: {}", tags_string);

                        // Notifica Backend
                        let completion_msg = serde_json::json!({
                            "id": job.id,
                            "status": "completed",
                            "tags": tags_string
                        });
                        
                        let _: redis::RedisResult<()> = redis::cmd("PUBLISH")
                            .arg("job_completed")
                            .arg(completion_msg.to_string())
                            .query_async(&mut publisher_conn)
                            .await;
                    },
                    Err(e) => {
                        eprintln!("Erro ao processar vaga {}: {}", job.id, e);
                    }
                }
            } else {
                 eprintln!("Falha ao deserializar Job: {}", payload);
            }
        }
    }

    Ok(())
}
