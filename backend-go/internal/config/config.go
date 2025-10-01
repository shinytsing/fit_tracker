package config

import (
	"os"
	"strconv"
)

type Config struct {
	Environment string
	Database    DatabaseConfig
	Redis       RedisConfig
	JWT         JWTConfig
	AI          AIConfig
	Server      ServerConfig
}

type DatabaseConfig struct {
	Host     string
	Port     string
	User     string
	Password string
	DBName   string
	SSLMode  string
}

type RedisConfig struct {
	Host     string
	Port     string
	Password string
	DB       int
}

type JWTConfig struct {
	SecretKey string
	ExpiresIn int // hours
}

type AIConfig struct {
	TencentSecretID  string
	TencentSecretKey string
	DeepSeekAPIKey   string
	GroqAPIKey       string
}

type ServerConfig struct {
	Port string
	Host string
}

func Load() *Config {
	return &Config{
		Environment: getEnv("ENVIRONMENT", "development"),
		Database: DatabaseConfig{
			Host:     getEnv("DB_HOST", "localhost"),
			Port:     getEnv("DB_PORT", "5432"),
			User:     getEnv("DB_USER", "fittracker"),
			Password: getEnv("DB_PASSWORD", "fittracker123"),
			DBName:   getEnv("DB_NAME", "fittracker"),
			SSLMode:  getEnv("DB_SSLMODE", "disable"),
		},
		Redis: RedisConfig{
			Host:     getEnv("REDIS_HOST", "localhost"),
			Port:     getEnv("REDIS_PORT", "6379"),
			Password: getEnv("REDIS_PASSWORD", ""),
			DB:       getEnvAsInt("REDIS_DB", 0),
		},
		JWT: JWTConfig{
			SecretKey: getEnv("JWT_SECRET", "fittracker-secret-key-2024"),
			ExpiresIn: getEnvAsInt("JWT_EXPIRES_IN", 24),
		},
		AI: AIConfig{
			TencentSecretID:  getEnv("TENCENT_SECRET_ID", ""),
			TencentSecretKey: getEnv("TENCENT_SECRET_KEY", ""),
			DeepSeekAPIKey:   getEnv("DEEPSEEK_API_KEY", ""),
			GroqAPIKey:       getEnv("GROQ_API_KEY", ""),
		},
		Server: ServerConfig{
			Port: getEnv("PORT", "8080"),
			Host: getEnv("HOST", "0.0.0.0"),
		},
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func getEnvAsInt(key string, defaultValue int) int {
	if value := os.Getenv(key); value != "" {
		if intValue, err := strconv.Atoi(value); err == nil {
			return intValue
		}
	}
	return defaultValue
}
