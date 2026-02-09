use async_trait::async_trait;
use reqwest::Client;
use serde::{Deserialize, Serialize};
use serde_json::json;
use std::error::Error;

use crate::domain::entities::Vocabulary;
use crate::domain::ports::AIService;

// Structs de suporte para a API da Groq
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

// Struct "Suja" para deserializar reposta da IA (permite nulls)
#[derive(Deserialize, Debug)]
struct RawVocabularyData {
    definition_en: Option<String>,
    translation_pt: Option<String>,
    grammatical_category: Option<String>,
    example_sentence_en: Option<String>,
    example_sentence_pt: Option<String>,
}

pub struct GroqClient {
    api_key: String,
    client: Client,
}

impl GroqClient {
    pub fn new(api_key: String) -> Self {
        Self {
            api_key,
            client: Client::new(),
        }
    }
}

#[async_trait]
impl AIService for GroqClient {
    async fn fetch_definition(&self, term: &str) -> Result<Vocabulary, Box<dyn Error>> {
        let url = "https://api.groq.com/openai/v1/chat/completions";

        let prompt_text = format!(
            r#"
            Role: You are a specialized technical dictionary for Software Engineers.
            Task: Define the term "{term}".
    
            CONTEXT: 
            Strictly consider this term in the context of Software Development, DevOps, or Computer Science. 
            Ignore general English meanings (e.g., if the term is "Rust", define the language, not the metal oxidation).
    
            INSTRUCTIONS:
            1. definition_en: A concise, technical definition in English (max 25 words).
            2. translation_pt: The direct translation of the term or a short explanation in Portuguese.
            3. example_sentence_en: A REALISTIC technical sentence showing how a developer would use this term in a work environment (e.g., inside a commit message, a log, or an architectural discussion). Do NOT use generic sentences like "I like [term]".
            4. example_sentence_pt: The Portuguese translation of the example sentence.
            5. grammatical_category: Choose strictly one: "Noun", "Verb", "Adjective", or "Phrase".
    
            OUTPUT FORMAT:
            Return ONLY a valid JSON object. Do not wrap in markdown code blocks.
            Keys: term, definition_en, translation_pt, example_sentence_en, example_sentence_pt, grammatical_category.
            "#,
            term = term
        );

        let request_body = json!({
            "model": "llama-3.3-70b-versatile",
            "messages": [
                {
                    "role": "system", 
                    "content": "You are a JSON-only API. Always return valid JSON."
                },
                {
                    "role": "user",
                    "content": prompt_text
                }
            ],
            "response_format": { "type": "json_object" },
            "temperature": 0.3
        });

        let resp = self.client.post(url)
            .header("Authorization", format!("Bearer {}", self.api_key))
            .json(&request_body)
            .send()
            .await?;

        if !resp.status().is_success() {
            let error_text = resp.text().await?;
            return Err(format!("Erro Groq: {}", error_text).into());
        }

        let groq_data: GroqResponse = resp.json().await?;

        if let Some(choice) = groq_data.choices.first() {
            let raw_data: RawVocabularyData = serde_json::from_str(&choice.message.content)?;

            let clean_data = Vocabulary {
                term: term.to_string(),
                definition_en: raw_data.definition_en.unwrap_or("Definition unavailable".to_string()),
                translation_pt: raw_data.translation_pt.unwrap_or("Tradução indisponível".to_string()),
                phonetic_ipa: "".to_string(), 
                grammatical_category: raw_data.grammatical_category.unwrap_or("Noun".to_string()),
                example_sentence_en: raw_data.example_sentence_en.unwrap_or("".to_string()),
                example_sentence_pt: raw_data.example_sentence_pt.unwrap_or("".to_string()),
            };

            return Ok(clean_data);
        }

        Err("Groq não retornou conteúdo".into())
    }
}
