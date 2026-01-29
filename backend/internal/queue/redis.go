package queue

import (
	"context"
	"crypto/tls"
	"log"
	"net"
	"os"

	"github.com/redis/go-redis/v9"
)

var Ctx = context.Background()

func InitRedis() *redis.Client {
	host := os.Getenv("REDIS_HOST")
	password := os.Getenv("REDIS_PASSWORD")

	if host == "" || password == "" {
		log.Fatal("Erro: REDIS_HOST ou REDIS_PASSWORD não definidos no .env")
	}

	// O Upstash precisa do nome do servidor (ServerName) para aceitar conexão segura
	serverName, _, _ := net.SplitHostPort(host)
	if serverName == "" {
		serverName = host // fallback
	}

	opt := &redis.Options{
		Addr:     host,
		Password: password,
		DB:       0, // Banco padrão
		TLSConfig: &tls.Config{
			MinVersion: tls.VersionTLS12,
			ServerName: serverName,
		},
	}

	client := redis.NewClient(opt)

	_, err := client.Ping(Ctx).Result()
	if err != nil {
		log.Fatal("Erro: Falha ao conectar no Redis:", err)
	}

	log.Println("Redis conectado com sucesso!")
	return client
}