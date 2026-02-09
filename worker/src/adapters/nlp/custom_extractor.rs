use regex::Regex;
use std::collections::HashSet;
use crate::domain::ports::NLPService;
use crate::adapters::nlp::techs;

pub struct CustomNLPService;

impl CustomNLPService {
    pub fn new() -> Self {
        Self {}
    }
}

impl NLPService for CustomNLPService {
    fn extract_keywords(&self, text: &str) -> Vec<String> {
        let allowed_techs = techs::get_allowed_tags();
        
        let re = Regex::new(r"(?i)[a-zA-Z0-9\+#\.\-]+").unwrap();

        let mut keywords = HashSet::new();

        for cap in re.captures_iter(text) {
            let raw_word = cap[0].to_lowercase();
            
            if allowed_techs.contains(raw_word.as_str()) {
                keywords.insert(raw_word);
                continue;
            }

            let clean_word = raw_word.trim_end_matches(|c| c == '.' || c == ',' || c == ')' || c == ':' || c == ';');
            
            if allowed_techs.contains(clean_word) {
                keywords.insert(clean_word.to_string());
            }
        }

        let mut result: Vec<String> = keywords.into_iter().collect();
        result.sort();
        result
    }
}
