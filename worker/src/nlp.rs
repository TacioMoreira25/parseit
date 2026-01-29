use regex::Regex;
use std::collections::HashSet;

const STOP_WORDS: &[&str] = &[
    "a", "an", "the", "and", "or", "but", "is", "are", "was", "were",
    "of", "in", "on", "at", "to", "for", "with", "by", "from", "about",
    "we", "you", "your", "our", "be", "have", "has", "looking", "seeking",
    "experience", "knowledge", "skills", "plus", "years", "working", "requirements",
    "solid", "strong", "proficiency", "understanding", "familiarity", "huge", "must", "use"
];

pub fn extract_keywords(text: &str) -> Vec<String> {
    let text_lower = text.to_lowercase();
    let re = Regex::new(r"\b[a-zA-Z0-9#+.]+\b").unwrap();
    let mut unique_words = HashSet::new();

    for cap in re.captures_iter(&text_lower) {
        if let Some(word_match) = cap.get(0) {
            let word = word_match.as_str();
            // Filtra stop words e palavras muito curtas
            if !STOP_WORDS.contains(&word) && word.len() > 1 {
                unique_words.insert(word.to_string());
            }
        }
    }

    let mut result: Vec<String> = unique_words.into_iter().collect();
    result.sort();
    result
}