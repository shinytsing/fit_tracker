package config

import (
	"os"
	"strconv"
)

// Config 应用配置
type Config struct {
	Environment string
	Port        string
	LogLevel    string

	// 数据库配置
	DatabaseURL string

	// Redis配置
	RedisURL string

	// JWT配置
	JWTSecret     string
	JWTExpiration int

	// AI服务配置
	DeepSeekAPIKey   string
	TencentSecretID  string
	TencentSecretKey string
	AIMLAPIKey       string

	// 文件上传配置
	UploadPath  string
	MaxFileSize int64
}

// Load 加载配置
func Load() *Config {
	return &Config{
		Environment: getEnv("ENVIRONMENT", "development"),
		Port:        getEnv("PORT", "8080"),
		LogLevel:    getEnv("LOG_LEVEL", "info"),

		DatabaseURL: getEnv("DATABASE_URL", "postgres://user:password@localhost:5432/fittracker?sslmode=disable"),
		RedisURL:    getEnv("REDIS_URL", "redis://localhost:6379/0"),

		JWTSecret:     getEnv("JWT_SECRET", "your-secret-key"),
		JWTExpiration: getEnvAsInt("JWT_EXPIRATION", 24*7), // 7天

		DeepSeekAPIKey:   getEnv("DEEPSEEK_API_KEY", ""),
		TencentSecretID:  getEnv("TENCENT_SECRET_ID", ""),
		TencentSecretKey: getEnv("TENCENT_SECRET_KEY", ""),
		AIMLAPIKey:       getEnv("AIMLAPI_API_KEY", ""),

		UploadPath:  getEnv("UPLOAD_PATH", "./uploads"),
		MaxFileSize: getEnvAsInt64("MAX_FILE_SIZE", 10*1024*1024), // 10MB
	}
}

// getEnv 获取环境变量，如果不存在则返回默认值
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

// getEnvAsInt 获取环境变量并转换为int
func getEnvAsInt(key string, defaultValue int) int {
	if value := os.Getenv(key); value != "" {
		if intValue, err := strconv.Atoi(value); err == nil {
			return intValue
		}
	}
	return defaultValue
}

// getEnvAsInt64 获取环境变量并转换为int64
func getEnvAsInt64(key string, defaultValue int64) int64 {
	if value := os.Getenv(key); value != "" {
		if intValue, err := strconv.ParseInt(value, 10, 64); err == nil {
			return intValue
		}
	}
	return defaultValue
}
