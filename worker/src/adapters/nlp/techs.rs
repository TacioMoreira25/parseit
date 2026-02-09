use std::collections::HashSet;

pub fn get_allowed_tags() -> HashSet<&'static str> {
    let mut techs = HashSet::new();

    // --- LINGUAGENS DE PROGRAMAÇÃO ---
    techs.insert("rust");
    techs.insert("go");
    techs.insert("golang");
    techs.insert("python");
    techs.insert("javascript");
    techs.insert("typescript");
    techs.insert("java");
    techs.insert("c#");
    techs.insert("c++");
    techs.insert("c");
    techs.insert("php");
    techs.insert("ruby");
    techs.insert("swift");
    techs.insert("kotlin");
    techs.insert("dart");
    techs.insert("elixir");
    techs.insert("scala");
    techs.insert("haskell");
    techs.insert("lua");
    techs.insert("sql");

    // --- FRONTEND & WEB ---
    techs.insert("react");
    techs.insert("react.js");
    techs.insert("vue");
    techs.insert("vue.js");
    techs.insert("angular");
    techs.insert("svelte");
    techs.insert("next.js");
    techs.insert("nuxt");
    techs.insert("html");
    techs.insert("css");
    techs.insert("sass");
    techs.insert("tailwind");
    techs.insert("bootstrap");
    techs.insert("redux");
    techs.insert("webpack");
    techs.insert("vite");

    // --- BACKEND & FRAMEWORKS ---
    techs.insert("node.js");
    techs.insert("nodejs");
    techs.insert("nest.js");
    techs.insert("nestjs");
    techs.insert("express");
    techs.insert("django");
    techs.insert("flask");
    techs.insert("fastapi");
    techs.insert("spring");
    techs.insert("spring boot");
    techs.insert(".net");
    techs.insert("asp.net");
    techs.insert("laravel");
    techs.insert("symfony");
    techs.insert("rails"); // Ruby on Rails
    techs.insert("gin");   // Go
    techs.insert("fiber"); // Go
    techs.insert("actix"); // Rust
    techs.insert("tokio"); // Rust
    techs.insert("axum");  // Rust

    // --- MOBILE ---
    techs.insert("flutter");
    techs.insert("react native");
    techs.insert("ionic");
    techs.insert("android");
    techs.insert("ios");
    techs.insert("xamarin");

    // --- BANCO DE DADOS (Data) ---
    techs.insert("postgresql");
    techs.insert("postgres");
    techs.insert("mysql");
    techs.insert("mariadb");
    techs.insert("sqlite");
    techs.insert("sql server");
    techs.insert("mongodb");
    techs.insert("mongo");
    techs.insert("redis");
    techs.insert("cassandra");
    techs.insert("elasticsearch");
    techs.insert("dynamodb");
    techs.insert("firebase");
    techs.insert("supabase");
    techs.insert("neo4j");

    // --- DEVOPS, INFRA & CLOUD ---
    techs.insert("docker");
    techs.insert("kubernetes");
    techs.insert("k8s");
    techs.insert("aws");
    techs.insert("amazon web services");
    techs.insert("azure");
    techs.insert("gcp");
    techs.insert("google cloud");
    techs.insert("terraform");
    techs.insert("ansible");
    techs.insert("jenkins");
    techs.insert("github actions");
    techs.insert("gitlab ci");
    techs.insert("circleci");
    techs.insert("linux");
    techs.insert("bash");
    techs.insert("nginx");
    techs.insert("apache");
    techs.insert("helm");
    techs.insert("prometheus");
    techs.insert("grafana");

    // --- MENSAGERIA & ARQUITETURA ---
    techs.insert("kafka");
    techs.insert("rabbitmq");
    techs.insert("sqs");
    techs.insert("sns");
    techs.insert("grpc");
    techs.insert("graphql");
    techs.insert("rest");
    techs.insert("soap");
    techs.insert("websocket");
    techs.insert("microservices");
    techs.insert("serverless");
    techs.insert("event-driven");

    // --- FERRAMENTAS & TESTES ---
    techs.insert("git");
    techs.insert("github");
    techs.insert("gitlab");
    techs.insert("jira");
    techs.insert("confluence");
    techs.insert("postman");
    techs.insert("jest");
    techs.insert("cypress");
    techs.insert("selenium");
    techs.insert("junit");
    techs.insert("pytest");

    techs.insert("ai");
    techs.insert("artificial intelligence");
    techs.insert("ml");
    techs.insert("machine learning");
    techs.insert("aws lambda");

    // CLOUD SERVICES (AWS/AZURE/GCP) ---
    techs.insert("lambda");
    techs.insert("ec2");
    techs.insert("s3");
    techs.insert("ecs");
    techs.insert("eks");
    techs.insert("fargate");
    techs.insert("cloudfront");
    techs.insert("blob storage"); 
    techs.insert("app service");
    techs.insert("bigquery");
    
    // FERRAMENTAS & DESIGN ---
    techs.insert("figma");
    techs.insert("adobe xd");
    techs.insert("sketch");
    techs.insert("photoshop");
    techs.insert("blender");
    techs.insert("unity");
    techs.insert("unreal");
    techs.insert("godot");

    //  METODOLOGIAS & CONCEITOS ---
    techs.insert("scrum");
    techs.insert("kanban");
    techs.insert("agile");
    techs.insert("tdd"); // Test Driven Development
    techs.insert("bdd");
    techs.insert("ddd"); // Domain Driven Design
    techs.insert("solid");
    techs.insert("oop");
    techs.insert("design patterns");
    techs.insert("ci"); // Continuous Integration
    techs.insert("cd"); // Continuous Delivery
    techs.insert("devops");
    techs.insert("finops");
    techs.insert("gitops");

    // SISTEMAS OPERACIONAIS & SHELL ---
    techs.insert("windows"); 
    techs.insert("ubuntu");
    techs.insert("debian");
    techs.insert("centos");
    techs.insert("fedora");
    techs.insert("arch");
    techs.insert("kali");
    techs.insert("powershell");
    techs.insert("zsh");
    techs.insert("vim");
    techs.insert("nvim");
    techs.insert("emacs");

    techs
}
