package routes

import (
	"fittracker/backend/internal/api/handlers"
	"fittracker/backend/internal/api/middleware"

	"github.com/gin-gonic/gin"
)

// SetupRoutes 设置所有路由
func SetupRoutes(r *gin.Engine, h *handlers.Handlers) {
	// API版本组
	v1 := r.Group("/api/v1")

	// 健康检查
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
	authenticated := v1.Group("/")
	authenticated.Use(middleware.Auth()) // 添加认证中间件
	{
		// 用户相关
		users := authenticated.Group("/users")
		{
			users.GET("/profile", h.GetProfile)
			users.PUT("/profile", h.UpdateProfile)
			users.POST("/avatar", h.UploadAvatar)
			users.GET("/stats", h.GetUserStats)
		}

		// 健身中心
		workouts := authenticated.Group("/workouts")
		{
			workouts.GET("", h.GetWorkouts)
			workouts.POST("", h.CreateWorkout)
			workouts.GET("/:id", h.GetWorkout)
			workouts.PUT("/:id", h.UpdateWorkout)
			workouts.DELETE("/:id", h.DeleteWorkout)

			// 训练计划
			workouts.GET("/plans", h.GetTrainingPlans)
			workouts.POST("/plans", h.CreateTrainingPlan)
			workouts.GET("/plans/:id", h.GetTrainingPlan)
			workouts.PUT("/plans/:id", h.UpdateTrainingPlan)
			workouts.DELETE("/plans/:id", h.DeleteTrainingPlan)

			// 运动动作
			workouts.GET("/exercises", h.GetExercises)
			workouts.POST("/exercises", h.CreateExercise)
			workouts.GET("/exercises/:id", h.GetExercise)
		}

		// BMI计算器
		bmi := authenticated.Group("/bmi")
		{
			bmi.POST("/calculate", h.CalculateBMI)
			bmi.GET("/records", h.GetBMIRecords)
			bmi.POST("/records", h.CreateBMIRecord)
			bmi.PUT("/records/:id", h.UpdateBMIRecord)
			bmi.DELETE("/records/:id", h.DeleteBMIRecord)

			// 其他身体指标计算
			bmi.POST("/body-fat", h.CalculateBodyFat)
			bmi.POST("/heart-rate", h.CalculateHeartRate)
			bmi.POST("/one-rm", h.CalculateOneRM)
			bmi.POST("/pace", h.CalculatePace)
		}

		// 营养计算器
		nutrition := authenticated.Group("/nutrition")
		{
			nutrition.POST("/calculate", h.CalculateNutrition)
			nutrition.GET("/foods", h.SearchFoods)
			nutrition.POST("/foods", h.CreateFood)
			nutrition.GET("/daily-intake", h.GetDailyIntake)
			nutrition.POST("/daily-intake", h.UpdateDailyIntake)

			// 营养记录
			nutrition.GET("/records", h.GetNutritionRecords)
			nutrition.POST("/records", h.CreateNutritionRecord)
			nutrition.PUT("/records/:id", h.UpdateNutritionRecord)
			nutrition.DELETE("/records/:id", h.DeleteNutritionRecord)
		}

		// 签到日历
		checkins := authenticated.Group("/checkins")
		{
			checkins.GET("", h.GetCheckins)
			checkins.POST("", h.CreateCheckin)
			checkins.GET("/calendar", h.GetCheckinCalendar)
			checkins.GET("/streak", h.GetCheckinStreak)
			checkins.GET("/achievements", h.GetAchievements)
		}

		// 社区互动
		community := authenticated.Group("/community")
		{
			// 动态
			community.GET("/posts", h.GetPosts)
			community.POST("/posts", h.CreatePost)
			community.GET("/posts/:id", h.GetPost)
			community.PUT("/posts/:id", h.UpdatePost)
			community.DELETE("/posts/:id", h.DeletePost)

			// 点赞和评论
			community.POST("/posts/:id/like", h.LikePost)
			community.DELETE("/posts/:id/like", h.UnlikePost)
			community.POST("/posts/:id/comments", h.CreateComment)
			community.GET("/posts/:id/comments", h.GetComments)
			community.DELETE("/comments/:id", h.DeleteComment)

			// 关注
			community.POST("/follow/:user_id", h.FollowUser)
			community.DELETE("/follow/:user_id", h.UnfollowUser)
			community.GET("/followers", h.GetFollowers)
			community.GET("/following", h.GetFollowing)

			// 挑战
			community.GET("/challenges", h.GetChallenges)
			community.POST("/challenges", h.CreateChallenge)
			community.GET("/challenges/:id", h.GetChallenge)
			community.POST("/challenges/:id/join", h.JoinChallenge)
			community.GET("/challenges/:id/leaderboard", h.GetChallengeLeaderboard)
		}

		// AI服务
		ai := authenticated.Group("/ai")
		{
			// AI教练
			ai.POST("/coach/workout-plan", h.GenerateWorkoutPlan)
			ai.POST("/coach/exercise-guidance", h.GetExerciseGuidance)
			ai.POST("/coach/progress-analysis", h.AnalyzeWorkoutProgress)
			ai.POST("/coach/chat", h.ChatWithCoach)

			// AI营养师
			ai.POST("/nutritionist/meal-plan", h.GenerateMealPlan)
			ai.POST("/nutritionist/nutrition-analysis", h.AnalyzeNutrition)
			ai.POST("/nutritionist/dietary-advice", h.GetDietaryAdvice)
			ai.POST("/nutritionist/macros", h.CalculateMacros)
			ai.POST("/nutritionist/chat", h.ChatWithNutritionist)
		}
	}
}
