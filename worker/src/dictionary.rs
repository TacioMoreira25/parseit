use reqwest::Client;
use serde::{Deserialize, Serialize};
use serde_json::json;
use sqlx::PgPool;
use std::env;
use std::error::Error;
use sqlx::Row;

// --- ESTRUTURAS DE DADOS ---

// 1. A Struct LIMPA (que vai pro Banco)
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct VocabularyData {
    pub term: String,
    pub definition_en: String,
    pub translation_pt: String,
    pub phonetic_ipa: String,
    pub grammatical_category: String,
    pub example_sentence_en: String,
    pub example_sentence_pt: String,
}

// 2. A Struct SUJA (que aceita null da IA)
#[derive(Deserialize, Debug)]
struct RawVocabularyData {
    term: Option<String>,
    definition_en: Option<String>,
    translation_pt: Option<String>,
    phonetic_ipa: Option<String>,
    grammatical_category: Option<String>,
    example_sentence_en: Option<String>,
    example_sentence_pt: Option<String>,
}

// Estruturas da Groq
#[derive(Deserialize, Debug)]
struct GroqResponse {
    choices: Vec<Choice>,
}
#[derive(Deserialize, Debug)]
struct Choice {
    message: Message,
}
#[derive(Deserialize, Debug)]
struct Message {
    content: String,
}

// --- FUNÇÃO PRINCIPAL (QUE O MAIN.RS CHAMA) ---

pub async fn process_tags(pool: &PgPool, tags: &[String]) -> Result<(), Box<dyn Error>> {
    // Pega a chave aqui dentro para não precisar passar do main toda hora
    let api_key = env::var("GROQ_API_KEY").unwrap_or_default();

    if api_key.is_empty() {
        eprintln!("⚠️ GROQ_API_KEY não encontrada no .env. Pulando enriquecimento.");
        return Ok(());
    }

    for tag in tags {
        let term = tag.to_lowercase();

        // 1. Verifica se já existe no banco (Cache)
        if word_exists(pool, &term).await? {
            println!("⏭️ '{}' já existe no vocabulário. Pulando.", term);
            continue;
        }

        println!("🔍 Buscando definição para '{}'...", term);

        // 2. Chama a IA
        match fetch_definition_from_ai(&term, &api_key).await {
            Ok(data) => {
                // 3. Salva no Banco
                if let Err(e) = save_word(pool, &data).await {
                    eprintln!("❌ Erro ao salvar '{}': {}", term, e);
                } else {
                    println!("✅ '{}' salvo com sucesso!", term);
                }
            },
            Err(e) => {
                eprintln!("⚠️ Falha ao buscar '{}' na IA: {}", term, e);
                // Não retorna erro aqui para não parar o loop das outras tags
            }
        }
    }

    Ok(())
}

// --- FUNÇÕES AUXILIARES ---

async fn word_exists(pool: &PgPool, term: &str) -> Result<bool, sqlx::Error> {
    // Usamos a função query() comum em vez da macro query!()
    // Isso evita o erro de "prepared statement" do Neon/PgBouncer
    let row = sqlx::query("SELECT exists(SELECT 1 FROM vocabulary WHERE term = $1)")
        .bind(term)
        .fetch_one(pool)
        .await?;

    // Pegamos o valor booleano da primeira coluna (índice 0)
    let exists: bool = row.try_get(0)?;
    Ok(exists)
}

async fn save_word(pool: &PgPool, data: &VocabularyData) -> Result<(), sqlx::Error> {
    sqlx::query!(
        r#"
        INSERT INTO vocabulary 
        (term, definition_en, translation_pt, phonetic_ipa, grammatical_category, example_sentence_en, example_sentence_pt)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        ON CONFLICT (term) DO NOTHING
        "#,
        data.term,
        data.definition_en,
        data.translation_pt,
        data.phonetic_ipa,
        data.grammatical_category,
        data.example_sentence_en,
        data.example_sentence_pt
    )
    .execute(pool)
    .await?;

    Ok(())
}

// --- INTEGRAÇÃO COM A IA ---

pub async fn fetch_definition_from_ai(term: &str, api_key: &str) -> Result<VocabularyData, Box<dyn Error>> {
    let client = Client::new();
    let url = "https://api.groq.com/openai/v1/chat/completions";

    let prompt_text = format!(
        "You are a Dictionary API. Define '{}'. \
        Return a valid JSON object with keys: \
        term, definition_en, translation_pt, phonetic_ipa, grammatical_category, example_sentence_en, example_sentence_pt. \
        If any field is unknown, return an empty string, NOT null.",
        term
    );

    let request_body = json!({
        "model": "llama-3.3-70b-versatile",
        "messages": [{
            "role": "user",
            "content": prompt_text
        }],
        "response_format": { "type": "json_object" }
    });

    let resp = client.post(url)
        .header("Authorization", format!("Bearer {}", api_key))
        .json(&request_body)
        .send()
        .await?;

    if !resp.status().is_success() {
        let error_text = resp.text().await?;
        return Err(format!("Erro Groq: {}", error_text).into());
    }

    let groq_data: GroqResponse = resp.json().await?;

    if let Some(choice) = groq_data.choices.first() {
        // Tenta deserializar para a struct "Raw" (que aceita null)
        let raw_data: RawVocabularyData = serde_json::from_str(&choice.message.content)?;

        // Sanitização: Converte null para String vazia
        let clean_data = VocabularyData {
            term: raw_data.term.unwrap_or(term.to_string()),
            definition_en: raw_data.definition_en.unwrap_or("Definition unavailable".to_string()),
            translation_pt: raw_data.translation_pt.unwrap_or("Tradução indisponível".to_string()),
            phonetic_ipa: raw_data.phonetic_ipa.unwrap_or("".to_string()),
            grammatical_category: raw_data.grammatical_category.unwrap_or("Noun".to_string()),
            example_sentence_en: raw_data.example_sentence_en.unwrap_or("".to_string()),
            example_sentence_pt: raw_data.example_sentence_pt.unwrap_or("".to_string()),
        };

        return Ok(clean_data);
    }

    Err("Groq não retornou conteúdo".into())
}