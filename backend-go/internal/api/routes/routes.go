package routes

import (
	"fittracker/internal/api/handlers"
	"fittracker/internal/api/middleware"

	"github.com/gin-gonic/gin"
)

// SetupRoutes 设置所有路由
func SetupRoutes(r *gin.Engine, h *handlers.Handlers) {
	// 根路径测试
	r.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{"message": "FitTracker API is running"})
	})

	// API版本组
	v1 := r.Group("/api/v1")

	// 健康检查端点（无需认证）
	v1.GET("/health", h.HealthCheck)

	// 认证相关路由
	auth := v1.Group("/auth")
	{
		auth.POST("/register", h.Register)
		auth.POST("/login", h.Login)
		auth.POST("/logout", h.Logout)
		auth.POST("/refresh", h.RefreshToken)
	}

	// 需要认证的路由
	authenticated := v1.Group("")
	authenticated.Use(middleware.Auth())
	{
		// 用户资料
		profile := authenticated.Group("/profile")
		{
			profile.GET("", h.GetProfile)
			profile.PUT("", h.UpdateProfile)
			profile.POST("/avatar", h.UploadAvatar)
			profile.GET("/stats", h.GetUserStats)
		}

		// 用户管理 (兼容旧路径)
		users := authenticated.Group("/users")
		{
			users.GET("/profile", h.GetProfile)
			users.PUT("/profile", h.UpdateProfile)
			users.POST("/profile/avatar", h.UploadAvatar)
			users.GET("/profile/stats", h.GetUserStats)
		}

		// 训练计划
		plans := authenticated.Group("/plans")
		{
			plans.GET("", h.GetTrainingPlans)
			plans.GET("/exercises", h.GetExercises)
		}

		// 运动记录
		workouts := authenticated.Group("/workouts")
		{
			workouts.GET("", h.GetWorkouts)
			workouts.POST("", h.CreateWorkout)
			workouts.GET("/:id", h.GetWorkout)
			workouts.PUT("/:id", h.UpdateWorkout)
			workouts.DELETE("/:id", h.DeleteWorkout)
			workouts.GET("/plans", h.GetTrainingPlans)
			workouts.GET("/exercises", h.GetExercises)
		}

		// BMI计算器
		bmi := authenticated.Group("/bmi")
		{
			bmi.POST("/calculate", h.CalculateBMI)
			bmi.POST("/calc", h.CalculateBMI) // 兼容旧路径
			bmi.GET("/records", h.GetBMIRecords)
			bmi.POST("/records", h.CreateBMIRecord)
		}

		// 营养管理
		nutrition := authenticated.Group("/nutrition")
		{
			nutrition.GET("/daily", h.GetDailyIntake)
			nutrition.POST("/records", h.CreateNutritionRecord)
			nutrition.GET("/records", h.GetNutritionRecords)
			nutrition.POST("/calculate", h.CalculateNutrition)
			nutrition.GET("/search", h.SearchFoods)
			nutrition.GET("/foods", h.SearchFoods) // 兼容旧路径
		}

		// 社区功能
		community := authenticated.Group("/community")
		{
			// 动态相关
			community.GET("/feed", h.GetFeed)                     // 推荐流
			community.GET("/posts", h.GetPosts)                   // 获取动态列表
			community.POST("/posts", h.CreatePost)                // 发布动态
			community.GET("/posts/:id", h.GetPost)                // 获取动态详情
			community.POST("/posts/:id/like", h.LikePost)         // 点赞/取消点赞
			community.DELETE("/posts/:id/like", h.UnlikePost)     // 取消点赞（兼容）
			community.POST("/posts/:id/favorite", h.FavoritePost) // 收藏/取消收藏
			community.POST("/posts/:id/comment", h.CreateComment) // 创建评论
			community.GET("/posts/:id/comments", h.GetComments)   // 获取评论列表

			// 话题相关
			community.GET("/topics/hot", h.GetHotTopics)          // 获取热门话题
			community.GET("/topics/:name/posts", h.GetTopicPosts) // 获取话题相关动态

			// 用户相关
			community.POST("/follow/:id", h.FollowUser)     // 关注/取消关注用户
			community.DELETE("/follow/:id", h.UnfollowUser) // 取消关注（兼容）
			community.GET("/users/:id", h.GetUserProfile)   // 获取用户主页

			// 搜索功能
			community.GET("/search", h.SearchPosts) // 搜索功能

			// 挑战赛相关
			community.GET("/challenges", h.GetChallenges)                           // 获取挑战赛列表
			community.GET("/challenges/:id", h.GetChallenge)                        // 获取挑战赛详情
			community.POST("/challenges", h.CreateChallenge)                        // 创建挑战赛
			community.POST("/challenges/:id/join", h.JoinChallenge)                 // 参与挑战赛
			community.DELETE("/challenges/:id/leave", h.LeaveChallenge)             // 退出挑战赛
			community.POST("/challenges/:id/checkin", h.CheckinChallenge)           // 挑战赛打卡
			community.GET("/challenges/:id/leaderboard", h.GetChallengeLeaderboard) // 排行榜
			community.GET("/challenges/:id/checkins", h.GetChallengeCheckins)       // 打卡记录
			community.GET("/user/challenges", h.GetUserChallenges)                  // 用户参与的挑战赛
		}

		// 签到功能
		checkins := authenticated.Group("/checkins")
		{
			checkins.GET("", h.GetCheckins)
			checkins.POST("", h.CreateCheckin)
			checkins.GET("/calendar", h.GetCheckinCalendar)
			checkins.GET("/streak", h.GetCheckinStreak)
			checkins.GET("/achievements", h.GetAchievements)
		}
	}
}
