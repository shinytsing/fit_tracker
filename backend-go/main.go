package main

import (
	"log"
	"net/http"
	"os"
	"os/exec"
	"os/signal"
	"syscall"
	"time"

	"gymates/internal/config"
	"gymates/internal/database"
	"gymates/internal/middleware"
	"gymates/internal/routes"
	"gymates/internal/services"

	"github.com/gin-gonic/gin"
	"github.com/go-redis/redis/v8"
	"github.com/joho/godotenv"
	"gorm.io/gorm"
)

// Gymates API 服务器主入口
// 技术栈: Gin + GORM + PostgreSQL + Redis
func main() {
	// 加载环境变量
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found")
	}

	// 初始化配置
	cfg := config.Load()

	// 初始化数据库
	db, err := database.Initialize(cfg)
	if err != nil {
		log.Fatal("Failed to initialize database:", err)
	}

	// 初始化Redis客户端
	redisClient := redis.NewClient(&redis.Options{
		Addr:     cfg.Redis.Host + ":" + cfg.Redis.Port,
		Password: cfg.Redis.Password,
		DB:       cfg.Redis.DB,
	})

	// 初始化所有服务
	services := initializeServices(cfg, db, redisClient)

	// 设置Gin模式
	if cfg.Environment == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	// 创建路由
	router := gin.Default()

	// 全局中间件
	setupGlobalMiddleware(router, redisClient)

	// 设置API路由
	setupAPIRoutes(router, services)

	// 健康检查
	router.GET("/health", healthCheck)

	// 设置优雅关闭
	setupGracefulShutdown()

	// 启动服务器
	startServer(router, cfg.Server.Port)
}

// runTests 运行API测试
func runTests() {
	log.Println("🧪 开始运行 API 测试...")

	// 等待服务器完全启动
	time.Sleep(3 * time.Second)

	// 检查服务器是否可用
	if !isServerReady() {
		log.Println("❌ 服务器未就绪，跳过测试")
		return
	}

	// 运行测试
	cmd := exec.Command("go", "test", "./tests", "-v")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		log.Printf("❌ 测试执行失败: %v", err)
	} else {
		log.Println("✅ 所有测试完成")
	}
}

// isServerReady 检查服务器是否就绪
func isServerReady() bool {
	client := &http.Client{Timeout: 5 * time.Second}
	resp, err := client.Get("http://localhost:8080/health")
	if err != nil {
		return false
	}
	defer resp.Body.Close()
	return resp.StatusCode == http.StatusOK
}

// setupGracefulShutdown 设置优雅关闭
func setupGracefulShutdown() {
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)

	go func() {
		<-c
		log.Println("🛑 收到关闭信号，正在优雅关闭...")
		os.Exit(0)
	}()
}

// initializeServices 初始化所有服务
func initializeServices(cfg *config.Config, db *gorm.DB, redisClient *redis.Client) *services.Services {
	return services.NewServices(cfg, db, redisClient)
}

// setupGlobalMiddleware 设置全局中间件
func setupGlobalMiddleware(router *gin.Engine, redisClient *redis.Client) {
	// 请求ID
	router.Use(middleware.RequestID())

	// 安全头
	router.Use(middleware.SecurityHeaders())

	// CORS 跨域支持
	router.Use(middleware.CORS())

	// 请求日志
	router.Use(middleware.Logger())

	// 异常恢复
	router.Use(middleware.Recovery())

	// JSON验证
	router.Use(middleware.ValidateJSON())

	// 请求限流 (每分钟100次请求)
	router.Use(middleware.RateLimit(redisClient, 100, time.Minute))

	// 请求超时 (30秒)
	router.Use(middleware.Timeout(30 * time.Second))
}

// setupAPIRoutes 设置API路由
func setupAPIRoutes(router *gin.Engine, services *services.Services) {
	// API v1 路由组
	v1 := router.Group("/api/v1")

	// 初始化路由处理器
	routeHandler := routes.NewRouteHandler(services)

	// 设置各模块路由
	routeHandler.SetupUserRoutes(v1)      // /api/v1/users/...
	routeHandler.SetupTrainingRoutes(v1)  // /api/v1/training/...
	routeHandler.SetupCommunityRoutes(v1) // /api/v1/posts/...
	routeHandler.SetupGymRoutes(v1)       // /api/v1/gyms/...
	routeHandler.SetupRestRoutes(v1)      // /api/v1/rest/...
	routeHandler.SetupMessageRoutes(v1)   // /api/v1/messages/...
	routeHandler.SetupTeamRoutes(v1)      // /api/v1/teams/...
}

// healthCheck 健康检查端点
func healthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status":    "ok",
		"service":   "gymates-api",
		"version":   "v1.0.0",
		"timestamp": time.Now().Unix(),
	})
}

// startServer 启动服务器
func startServer(router *gin.Engine, port string) {
	if port == "" {
		port = "8080"
	}

	log.Printf("🚀 Gymates API Server starting on port %s", port)
	log.Printf("📚 API Documentation: http://localhost:%s/api/v1/docs", port)
	log.Printf("🔍 Health Check: http://localhost:%s/health", port)

	// 异步启动测试
	go func() {
		time.Sleep(2 * time.Second)
		runTests()
	}()

	if err := router.Run(":" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}
