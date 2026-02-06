mod config;
mod models;
mod nlp;
mod techs;

use dotenv::dotenv;
use futures_util::StreamExt;
use redis::AsyncCommands;
use sqlx::postgres::PgPoolOptions; 
use models::JobEvent;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    dotenv().ok();
    println!("🦀 Worker Rust Iniciando...");

    // 1. Configurações
    let redis_url = config::get_redis_url();
    let db_url = config::get_database_url();

    // 2. Conecta no Banco de Dados (Postgres)
    // O Pool gerencia várias conexões para ser super rápido
    println!("Conectando ao Postgres...");
    let db_pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(&db_url)
        .await?;
    println!("Postgres conectado!");

    // 3. Conecta no Redis
    let client = redis::Client::open(redis_url)?;
    let conn = client.get_async_connection().await?;
    let mut pubsub = conn.into_pubsub();
    pubsub.subscribe("job_created").await?;
    
    println!("Redis conectado! Aguardando vagas...");

    let mut on_message = pubsub.into_on_message();

    // 4. Loop Principal
    while let Some(msg) = on_message.next().await {
        if let Ok(payload) = msg.get_payload::<String>() {
            // Se falhar o JSON, ignora e continua
            if let Ok(job) = serde_json::from_str::<JobEvent>(&payload) {
                println!("\nVaga Recebida ID: {}", job.id);
                
                // A. Processamento (CPU Bound)
                let keywords = nlp::extract_keywords(&job.description);
                
                if keywords.is_empty() {
                    println!("Nenhuma tag encontrada.");
                    continue;
                }

                // Transforma o vetor ["go", "rust"] em string "go,rust"
                let tags_string = keywords.join(",");
                println!("Tags geradas: {}", tags_string);

                // B. Persistência (IO Bound) - Salva no Banco
                // Atenção: O GORM cria a tabela como 'jobs' e 'id' geralmente é bigint (i64)
                let result = sqlx::query("UPDATE jobs SET tags = $1 WHERE id = $2")
                    .bind(&tags_string)
                    .bind(job.id as i64) // Cast seguro para garantir compatibilidade
                    .execute(&db_pool)
                    .await;

                match result {
                    Ok(_) => println!("Tags salvas no banco com sucesso!"),
                    Err(e) => eprintln!("Erro ao salvar no banco: {}", e),
                }
            }
        }
    }

    Ok(())
}