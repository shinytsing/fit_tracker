package routes

import (
	"github.com/gin-gonic/gin"
)

// SetupUserRoutes 设置用户相关路由
func (h *RouteHandler) SetupUserRoutes(rg *gin.RouterGroup) {
	users := rg.Group("/users")
	{
		// 公开路由
		users.POST("/register", h.Register)
		users.POST("/login", h.Login)
		users.POST("/search", h.SearchUsers)

		// 需要认证的路由
		authenticated := users.Group("")
		authenticated.Use(h.authMiddleware())
		{
			authenticated.GET("/profile", h.GetProfile)
			authenticated.PUT("/profile", h.UpdateProfile)
			authenticated.POST("/upload-avatar", h.UploadAvatar)
			authenticated.GET("/settings", h.GetSettings)
			authenticated.PUT("/settings", h.UpdateSettings)
			authenticated.POST("/change-password", h.ChangePassword)
			authenticated.GET("/stats", h.GetUserStats)
			authenticated.GET("/achievements", h.GetUserAchievements)
			authenticated.POST("/follow", h.FollowUser)
			authenticated.DELETE("/follow/:id", h.UnfollowUser)

			// 新增的用户资料相关路由
			authenticated.GET("/profile/detailed", h.GetUserProfile)
			authenticated.PUT("/profile/detailed", h.UpdateUserProfile)
			authenticated.POST("/profile/avatar", h.UploadUserAvatar)
			authenticated.GET("/profile/settings", h.GetUserSettings)
			authenticated.PUT("/profile/settings", h.UpdateUserSettings)
			authenticated.POST("/profile/password", h.ChangeUserPassword)
			authenticated.GET("/profile/stats", h.GetUserStats)
			authenticated.GET("/profile/achievements", h.GetUserAchievements)
			authenticated.POST("/profile/follow", h.FollowUser)
			authenticated.DELETE("/profile/follow/:id", h.UnfollowUser)
		}
	}
}

// SetupTrainingRoutes 设置训练相关路由
func (h *RouteHandler) SetupTrainingRoutes(rg *gin.RouterGroup) {
	training := rg.Group("/training")
	training.Use(h.authMiddleware())
	{
		// 训练计划管理
		training.GET("/today-plan", h.GetTodayPlan)
		training.GET("/plans", h.GetHistoryPlans)
		training.POST("/plans", h.CreatePlan)
		training.PUT("/plans/:id", h.UpdatePlan)
		training.DELETE("/plans/:id", h.DeletePlan)

		// AI训练计划生成
		training.POST("/ai-plan", h.GenerateAIPlan)

		// 训练记录管理
		training.POST("/start", h.StartWorkout)
		training.POST("/end", h.EndWorkout)
		training.POST("/complete-exercise", h.CompleteExercise)
		training.POST("/feedback", h.SubmitFeedback)
		training.GET("/history", h.GetWorkoutHistory)
		training.GET("/stats", h.GetTrainingStats)
	}
}

// SetupCommunityRoutes 设置社区相关路由
func (h *RouteHandler) SetupCommunityRoutes(rg *gin.RouterGroup) {
	community := rg.Group("/community")
	community.Use(h.authMiddleware())
	{
		community.GET("/posts", h.GetCommunityPosts)
		community.POST("/posts", h.CreateCommunityPost)
		community.GET("/posts/:id", h.GetCommunityPost)
		community.PUT("/posts/:id", h.UpdateCommunityPost)
		community.DELETE("/posts/:id", h.DeleteCommunityPost)
		community.POST("/posts/:id/like", h.LikeCommunityPost)
		community.DELETE("/posts/:id/like", h.UnlikeCommunityPost)
		community.POST("/posts/:id/comment", h.CommentCommunityPost)
		community.GET("/posts/:id/comments", h.GetCommunityComments)
		community.GET("/trending", h.GetTrendingPosts)
		community.GET("/coaches", h.GetRecommendedCoaches)
	}
}

// SetupGymRoutes 设置健身房相关路由
func (h *RouteHandler) SetupGymRoutes(rg *gin.RouterGroup) {
	gyms := rg.Group("/gyms")
	gyms.Use(h.authMiddleware())
	{
		gyms.GET("", h.GetGyms)
		gyms.POST("", h.CreateGym)
		gyms.GET("/:id", h.GetGym)
		gyms.PUT("/:id", h.UpdateGym)
		gyms.DELETE("/:id", h.DeleteGym)
		gyms.POST("/:id/join", h.JoinGym)
		gyms.POST("/:id/accept", h.AcceptJoinRequest)
		gyms.POST("/:id/reject", h.RejectJoinRequest)
		gyms.GET("/:id/buddies", h.GetGymBuddies)
		gyms.POST("/:id/discounts", h.CreateGymDiscount)
		gyms.POST("/:id/reviews", h.CreateGymReview)
		gyms.GET("/nearby", h.GetNearbyGyms)
	}
}

// SetupRestRoutes 设置休息相关路由
func (h *RouteHandler) SetupRestRoutes(rg *gin.RouterGroup) {
	rest := rg.Group("/rest")
	rest.Use(h.authMiddleware())
	{
		rest.POST("/start", h.StartRest)
		rest.POST("/end", h.EndRest)
		rest.GET("/sessions", h.GetRestSessions)
		rest.GET("/feed", h.GetRestFeed)
		rest.POST("/posts", h.CreateRestPost)
		rest.POST("/posts/:id/like", h.LikeRestPost)
		rest.POST("/posts/:id/comment", h.CommentRestPost)
	}
}

// SetupMessageRoutes 设置消息相关路由
func (h *RouteHandler) SetupMessageRoutes(rg *gin.RouterGroup) {
	messages := rg.Group("/messages")
	messages.Use(h.authMiddleware())
	{
		messages.GET("/chats", h.GetChats)
		messages.POST("/chats", h.CreateChat)
		messages.GET("/chats/:id", h.GetChat)
		messages.GET("/chats/:id/messages", h.GetMessages)
		messages.POST("/chats/:id/messages", h.SendMessage)
		messages.PUT("/messages/:id/read", h.MarkMessageAsRead)
		messages.GET("/notifications", h.GetNotifications)
		messages.POST("/notifications", h.CreateNotification)
		messages.PUT("/notifications/:id/read", h.MarkNotificationAsRead)
		messages.GET("/unread-count", h.GetUnreadCount)
	}
}

// SetupTeamRoutes 设置搭子团队相关路由
func (h *RouteHandler) SetupTeamRoutes(rg *gin.RouterGroup) {
	teams := rg.Group("/teams")
	teams.Use(h.authMiddleware())
	{
		teams.GET("", h.GetTeams)
		teams.POST("", h.CreateTeam)
		teams.GET("/:id", h.GetTeamByID)
		teams.POST("/:id/join", h.JoinTeam)
	}
}

// SetupBuddyRoutes 设置搭子相关路由
func (h *RouteHandler) SetupBuddyRoutes(rg *gin.RouterGroup) {
	buddies := rg.Group("/buddies")
	buddies.Use(h.authMiddleware())
	{
		buddies.GET("/recommendations", h.GetBuddyRecommendations)
		buddies.POST("/request", h.RequestBuddy)
		buddies.GET("/requests", h.GetBuddyRequests)
		buddies.PUT("/requests/:request_id/accept", h.AcceptBuddyRequest)
		buddies.PUT("/requests/:request_id/reject", h.RejectBuddyRequest)
		buddies.GET("", h.GetMyBuddies)
		buddies.DELETE("/:buddy_id", h.DeleteBuddy)
	}
}
