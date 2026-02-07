//! worker/src/dictionary.rs

use crate::models::Vocabulary;
use sqlx::PgPool;

/// Processes a list of tags, checks if they exist in the vocabulary,
/// fetches a definition for new terms, and inserts them into the database.
pub async fn process_tags(pool: &PgPool, tags: &[String]) -> Result<(), sqlx::Error> {
    for tag in tags {
        // DEBUG: Trocado para a versão sem macro para evitar o erro de compilação
        let exists: Option<bool> = sqlx::query_scalar(
            "SELECT EXISTS(SELECT 1 FROM vocabulary WHERE term = $1)",
        )
        .bind(tag)
        .fetch_one(pool)
        .await?;

        let term_exists = exists.unwrap_or(false);

        if !term_exists {
            println!("Termo novo encontrado: '{}'. Adicionando ao vocabulário.", tag);
            let new_vocab_entry = fetch_definition(tag);
            insert_vocabulary(pool, &new_vocab_entry).await?;
        }
    }
    Ok(())
}

/// Inserts a new vocabulary entry into the database.
async fn insert_vocabulary(pool: &PgPool, vocab: &Vocabulary) -> Result<(), sqlx::Error> {
    // DEBUG: Trocado para a versão sem macro para evitar o erro de compilação
    sqlx::query(
        r#"
        INSERT INTO vocabulary (term, definition_en, translation_pt, phonetic_ipa, grammatical_category, example_sentence_en, example_sentence_pt)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        "#,
    )
    .bind(&vocab.term)
    .bind(&vocab.definition_en)
    .bind(&vocab.translation_pt)
    .bind(&vocab.phonetic_ipa)
    .bind(&vocab.grammatical_category)
    .bind(&vocab.example_sentence_en)
    .bind(&vocab.example_sentence_pt)
    .execute(pool)
    .await?;
    println!("Termo '{}' inserido com sucesso no banco de dados.", vocab.term);
    Ok(())
}

/// "Smart Mock" to fetch vocabulary definitions.
/// Simulates an AI/API call to get linguistic details for a given term.
fn fetch_definition(term: &str) -> Vocabulary {
    match term.to_lowercase().as_str() {
        "rust" => Vocabulary {
            term: "Rust".to_string(),
            definition_en: "A multi-paradigm, high-level, general-purpose programming language designed for performance and safety, especially safe concurrency.".to_string(),
            translation_pt: "Uma linguagem de programação de múltiplos paradigmas, projetada para performance e segurança, especialmente concorrência segura.".to_string(),
            phonetic_ipa: "/rʌst/".to_string(),
            grammatical_category: "Noun".to_string(),
            example_sentence_en: "Rust's ownership system guarantees memory safety without needing a garbage collector.".to_string(),
            example_sentence_pt: "O sistema de ownership do Rust garante segurança de memória sem precisar de um coletor de lixo.".to_string(),
        },
        "docker" => Vocabulary {
            term: "Docker".to_string(),
            definition_en: "A set of platform-as-a-service products that use OS-level virtualization to deliver software in packages called containers.".to_string(),
            translation_pt: "Um conjunto de produtos de plataforma como serviço que usa virtualização de nível de sistema operacional para entregar software em pacotes chamados contêineres.".to_string(),
            phonetic_ipa: "/ˈdɒkər/".to_string(),
            grammatical_category: "Noun".to_string(),
            example_sentence_en: "We use Docker to deploy our microservices.".to_string(),
            example_sentence_pt: "Nós usamos Docker para implantar nossos microsserviços.".to_string(),
        },
        // Generic fallback for any other term
        _ => Vocabulary {
            term: term.to_string(),
            definition_en: "Placeholder definition: A technical term used in software development.".to_string(),
            translation_pt: "Definição placeholder: Um termo técnico usado em desenvolvimento de software.".to_string(),
            phonetic_ipa: "/pleɪsˌhoʊldər/".to_string(),
            grammatical_category: "Noun".to_string(),
            example_sentence_en: "This is a placeholder example sentence for the term.".to_string(),
            example_sentence_pt: "Esta é uma frase de exemplo placeholder para o termo.".to_string(),
        },
    }
}
