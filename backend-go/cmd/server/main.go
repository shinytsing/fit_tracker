package main

import (
	"log"
	"net/http"
	"os"

	"fittracker/internal/api"
	"fittracker/internal/config"
	"fittracker/internal/database"
	"fittracker/internal/middleware"
	"fittracker/internal/services"

	"github.com/gin-gonic/gin"
	"github.com/go-redis/redis/v8"
	"github.com/joho/godotenv"
)

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

	// 初始化服务
	userService := services.NewUserService(db, redisClient)
	communityService := services.NewCommunityService(db)
	aiService := services.NewAIService(cfg)
	trainingService := services.NewTrainingService(db, aiService, userService)

	// 初始化API处理器
	handlers := api.NewHandlers(
		userService,
		trainingService,
		communityService,
		aiService,
	)

	// 设置Gin模式
	if cfg.Environment == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	// 创建路由
	router := gin.Default()

	// 中间件
	router.Use(middleware.CORS())
	router.Use(middleware.Logger())
	router.Use(middleware.Recovery())

	// API路由组
	v1 := router.Group("/api/v1")
	{
		// 用户相关
		users := v1.Group("/users")
		{
			users.POST("/register", handlers.Register)
			users.POST("/login", handlers.Login)
		users.GET("/profile", handlers.GetProfile)
		users.PUT("/profile", handlers.UpdateProfile)
		users.POST("/avatar", handlers.UploadAvatar)
		}

		// Profile 相关路由
		profile := v1.Group("/profile")
		{
			profile.GET("/activities", handlers.GetProfileActivities)
			profile.GET("/current-plan", handlers.GetCurrentPlan)
			profile.GET("/plan-history", handlers.GetPlanHistory)
			profile.GET("/nutrition-plan", handlers.GetNutritionPlan)
			profile.PUT("/nutrition-plan", handlers.UpdateNutritionPlan)
			profile.GET("/settings", handlers.GetProfileSettings)
			profile.PUT("/settings/:key", handlers.UpdateProfileSetting)
		}

		// 文件上传相关
		upload := v1.Group("/upload")
		{
			upload.POST("/avatar", handlers.UploadAvatar)
		}

		// 训练相关
		training := v1.Group("/training")
		{
			training.GET("/plans/today", handlers.GetTodayPlan)
			training.GET("/plans/history", handlers.GetHistoryPlans)
			training.POST("/plans", handlers.CreatePlan)
			training.PUT("/plans/:id", handlers.UpdatePlan)
			training.DELETE("/plans/:id", handlers.DeletePlan)
			training.POST("/plans/ai-generate", handlers.GenerateAIPlan)
			training.POST("/exercises/:id/complete", handlers.CompleteExercise)
			training.POST("/workouts/complete", handlers.CompleteWorkout)
			training.POST("/workouts/start", handlers.StartWorkout)
			training.GET("/stats", handlers.GetTrainingStats)
			training.GET("/achievements", handlers.GetAchievements)
			training.POST("/achievements/:id/claim", handlers.ClaimAchievement)
			training.GET("/checkins", handlers.GetCheckIns)
			training.POST("/checkins", handlers.CreateCheckIn)
		}

		// 社区相关
		community := v1.Group("/community")
		{
			community.GET("/posts/following", handlers.GetFollowingPosts)
			community.GET("/posts/recommend", handlers.GetRecommendPosts)
			community.POST("/posts", handlers.CreatePost)
			community.GET("/posts/:id", handlers.GetPost)
			community.PUT("/posts/:id", handlers.UpdatePost)
			community.DELETE("/posts/:id", handlers.DeletePost)
			community.POST("/posts/:id/like", handlers.LikePost)
			community.POST("/posts/:id/comment", handlers.CommentPost)
			community.POST("/posts/:id/share", handlers.SharePost)
			community.GET("/topics/trending", handlers.GetTrendingTopics)
			community.POST("/users/:id/follow", handlers.FollowUser)
			community.DELETE("/users/:id/follow", handlers.UnfollowUser)
		}

		// 消息相关
		messages := v1.Group("/messages")
		{
			messages.GET("/chats", handlers.GetChats)
			messages.GET("/chats/:id", handlers.GetChatMessages)
			messages.POST("/chats", handlers.CreateChat)
			messages.POST("/chats/:id/messages", handlers.SendMessage)
			messages.GET("/notifications", handlers.GetNotifications)
			messages.PUT("/notifications/:id/read", handlers.MarkNotificationRead)
			messages.DELETE("/notifications", handlers.ClearNotifications)
			messages.GET("/system", handlers.GetSystemMessages)
		}

		// WebSocket连接暂时禁用
		// router.GET("/ws", handlers.HandleWebSocket)

		// AI相关
		ai := v1.Group("/ai")
		{
			ai.POST("/training-plan", handlers.GenerateTrainingPlan)
			ai.POST("/nutrition-plan", handlers.GenerateNutritionPlan)
			ai.POST("/chat", handlers.AIChat)
		}
	}

	// 健康检查
	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":  "ok",
			"service": "fittracker-api",
		})
	})

	// 启动服务器
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s", port)
	if err := router.Run(":" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}
