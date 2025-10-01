package routes

import (
	"fittracker/internal/handlers"
	"fittracker/internal/middleware"
	"fittracker/internal/services"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(
	router *gin.Engine,
	authHandler *handlers.AuthHandler,
	userHandler *handlers.UserHandler,
	postHandler *handlers.PostHandler,
	workoutHandler *handlers.WorkoutHandler,
	authService *services.AuthService,
) {
	// API版本组
	v1 := router.Group("/api/v1")
	{
		// 公开路由
		public := v1.Group("/")
		{
			// 用户认证
			public.POST("/auth/register", userHandler.Register)
			public.POST("/auth/login", userHandler.Login)
			public.POST("/auth/refresh", authHandler.RefreshToken)
			public.POST("/auth/verify", authHandler.VerifyToken)

			// 公开的动态和用户信息
			public.GET("/posts", postHandler.GetPosts)
			public.GET("/posts/:id", postHandler.GetPost)
			public.GET("/posts/:id/comments", postHandler.GetComments)
			public.GET("/users/:id", userHandler.GetUserByID)
			public.GET("/users/:id/followers", userHandler.GetFollowers)
			public.GET("/users/:id/following", userHandler.GetFollowing)

			// 公开的训练计划
			public.GET("/workout-plans", workoutHandler.GetWorkoutPlans)
			public.GET("/workout-plans/:id", workoutHandler.GetWorkoutPlan)
		}

		// 需要认证的路由
		protected := v1.Group("/")
		protected.Use(middleware.Auth(authService))
		{
			// 用户管理
			protected.GET("/profile", userHandler.GetProfile)
			protected.PUT("/profile", userHandler.UpdateProfile)
			protected.POST("/users/:id/follow", userHandler.FollowUser)
			protected.DELETE("/users/:id/follow", userHandler.UnfollowUser)
			protected.POST("/auth/logout", authHandler.Logout)

			// 动态管理
			protected.POST("/posts", postHandler.CreatePost)
			protected.PUT("/posts/:id", postHandler.UpdatePost)
			protected.DELETE("/posts/:id", postHandler.DeletePost)
			protected.POST("/posts/:id/like", postHandler.LikePost)
			protected.DELETE("/posts/:id/like", postHandler.UnlikePost)
			protected.POST("/posts/:id/comments", postHandler.CreateComment)
			protected.DELETE("/comments/:id", postHandler.DeleteComment)

			// 训练管理
			protected.POST("/workout-plans", workoutHandler.CreateWorkoutPlan)
			protected.POST("/workout-plans/ai-generate", workoutHandler.GenerateAIWorkoutPlan)
			protected.POST("/workout-sessions", workoutHandler.CreateWorkoutSession)
			protected.GET("/workout-sessions", workoutHandler.GetWorkoutSessions)
			protected.POST("/check-ins", workoutHandler.CreateCheckIn)
			protected.GET("/check-ins", workoutHandler.GetCheckIns)
			protected.GET("/workout-stats", workoutHandler.GetWorkoutStats)
		}
	}

	// 健康检查
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status":    "healthy",
			"service":   "FitTracker API",
			"timestamp": "2024-01-01T00:00:00Z",
		})
	})

	// 根路径
	router.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "FitTracker API",
			"version": "1.0.0",
			"status":  "running",
		})
	})
}
