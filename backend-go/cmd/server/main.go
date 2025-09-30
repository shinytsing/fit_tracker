package main

import (
	"log"
	"os"

	"fittracker/backend/internal/api/handlers"
	"fittracker/backend/internal/api/middleware"
	"fittracker/backend/internal/api/routes"
	"fittracker/backend/internal/config"
	"fittracker/backend/internal/infrastructure/cache"
	"fittracker/backend/internal/infrastructure/database"
	"fittracker/backend/pkg/logger"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	// 加载环境变量
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found")
	}

	// 初始化配置
	cfg := config.Load()

	// 初始化日志
	logger.Init(cfg.LogLevel)

	// 初始化数据库
	db, err := database.Init(cfg.DatabaseURL)
	if err != nil {
		logger.Fatal.Fatalf("Failed to initialize database: %v", err)
	}

	// 初始化Redis
	redisClient, err := database.InitRedis(cfg.RedisURL)
	if err != nil {
		logger.Fatal.Fatalf("Failed to initialize Redis: %v", err)
	}

	// 初始化缓存服务
	cacheService, err := cache.NewRedisClient(cfg)
	if err != nil {
		logger.Fatal.Fatalf("Failed to initialize cache service: %v", err)
	}
	defer cacheService.Close()

	// 设置Gin模式
	if cfg.Environment == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	// 创建Gin引擎
	r := gin.New()

	// 添加中间件
	r.Use(middleware.Logger())
	r.Use(middleware.Recovery())
	r.Use(middleware.CORS())

	// 初始化处理器
	handlers := handlers.New(db, redisClient, cache.NewCacheService(cacheService), cfg)

	// 设置路由
	routes.SetupRoutes(r, handlers)

	// 启动服务器
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	logger.Info.Printf("Starting FitTracker server on port %s", port)
	if err := r.Run(":" + port); err != nil {
		logger.Fatal.Fatalf("Failed to start server: %v", err)
	}
}
