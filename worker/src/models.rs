use serde::Deserialize;

#[derive(Deserialize, Debug)]
pub struct JobEvent {
    pub id: u32,
    pub description: String,
}