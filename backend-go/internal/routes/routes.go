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
		users.POST("/third-party-login", h.ThirdPartyLogin)

		// 需要认证的路由
		authenticated := users.Group("")
		authenticated.Use(h.authMiddleware())
		{
			authenticated.GET("/profile", h.GetProfile)
			authenticated.PUT("/profile", h.UpdateProfile)
			authenticated.POST("/upload-avatar", h.UploadAvatar)
			authenticated.GET("/buddies", h.GetBuddies)
			authenticated.POST("/buddies", h.AddBuddy)
			authenticated.DELETE("/buddies/:id", h.RemoveBuddy)
		}
	}
}

// SetupTrainingRoutes 设置训练相关路由
func (h *RouteHandler) SetupTrainingRoutes(rg *gin.RouterGroup) {
	training := rg.Group("/training")
	training.Use(h.authMiddleware())
	{
		training.GET("/today", h.GetTodayPlan)
		training.POST("/ai-generate", h.GenerateAIPlan)
		training.GET("/plans", h.GetTrainingPlans)
		training.POST("/plans", h.CreateTrainingPlan)
		training.GET("/plans/:id", h.GetTrainingPlan)
		training.PUT("/plans/:id", h.UpdateTrainingPlan)
		training.DELETE("/plans/:id", h.DeleteTrainingPlan)
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
		community.POST("/posts/:id/comment", h.CommentCommunityPost)
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
		messages.PUT("/notifications/:id/read", h.MarkNotificationAsRead)
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
