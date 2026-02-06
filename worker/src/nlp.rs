use regex::Regex;
use std::collections::HashSet;
use crate::techs;

pub fn extract_keywords(text: &str) -> Vec<String> {
    let allowed_techs = techs::get_allowed_tags();
    
    // Regex "guloso": Pega C#, .NET, Node.js, etc.
    let re = Regex::new(r"(?i)[a-zA-Z0-9\+#\.\-]+").unwrap();

    let mut keywords = HashSet::new();

    for cap in re.captures_iter(text) {
        let raw_word = cap[0].to_lowercase();
        
        // 1. Tenta a palavra exata (ex: ".net" ou "c#")
        if allowed_techs.contains(raw_word.as_str()) {
            keywords.insert(raw_word);
            continue;
        }

        // 2. CORREÇÃO AQUI: Use 'trim_end_matches' em vez de 'trim_matches'
        // Isso remove ponto final ("node.js.") mas mantém ponto inicial (".net")
        let clean_word = raw_word.trim_end_matches(|c| c == '.' || c == ',' || c == ')' || c == ':' || c == ';');
        
        if allowed_techs.contains(clean_word) {
            keywords.insert(clean_word.to_string());
        }
    }

    let mut result: Vec<String> = keywords.into_iter().collect();
    result.sort();
    result
}