use regex::Regex;
use std::collections::HashSet;

// Lista básica de "Stop Words"
const STOP_WORDS: &[&str] = &[
    "a", "an", "the", "and", "or", "but", "is", "are", "was", "were",
    "of", "in", "on", "at", "to", "for", "with", "by", "from", "about",
    "we", "you", "your", "our", "be", "have", "has", "looking", "seeking",
    "experience", "knowledge", "skills", "plus", "years", "working",
];

fn main() {
    // 1. Simulação: Um texto sujo que viria da descrição da vaga
    let raw_text = "We are looking for a Senior Go Developer with experience in Docker, Kubernetes and Microservices. Rust is a plus!";
    
    println!("Texto Original:\n'{}'\n", raw_text);

    // 2. Processa
    let keywords = extract_keywords(raw_text);

    // 3. Mostra o resultado
    println!("Keywords Extraídas (Rust):");
    println!("{:?}", keywords);
}

fn extract_keywords(text: &str) -> Vec<String> {
    // Passo A: Converte para minúsculas
    let text_lower = text.to_lowercase();

    // Passo B: Regex para pegar apenas palavras (remove pontuação .,!?)
    let re = Regex::new(r"\b[a-zA-Z0-9#+.]+\b").unwrap();

    // Passo C: HashSet para garantir que não teremos palavras repetidas
    let mut unique_words = HashSet::new();

    for cap in re.captures_iter(&text_lower) {
        if let Some(word_match) = cap.get(0) {
            let word = word_match.as_str();

            // Passo D: Filtra se NÃO é uma stop word
            if !STOP_WORDS.contains(&word) {
                unique_words.insert(word.to_string());
            }
        }
    }

    // Retorna como um vetor (Array dinâmico) ordenado
    let mut result: Vec<String> = unique_words.into_iter().collect();
    result.sort();
    result
}