use std::env;

pub fn get_redis_url() -> String {
    let host = env::var("REDIS_HOST").expect("Erro: REDIS_HOST não definido no .env");
    let password = env::var("REDIS_PASSWORD").expect("Erro: REDIS_PASSWORD não definido no .env");
    format!("rediss://:{}@{}", password, host)
}

pub fn get_database_url() -> String {
    env::var("DATABASE_URL").expect("Erro: DATABASE_URL não definido no .env")
}

pub fn get_groq_api_key() -> String {
    env::var("GROQ_API_KEY").expect("Erro: GROQ_API_KEY não definido no .env")
}