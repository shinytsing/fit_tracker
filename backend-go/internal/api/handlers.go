package api

import (
	"net/http"

	"gymates/internal/services"

	"github.com/gin-gonic/gin"
)

// Handlers 主API处理器
type Handlers struct {
	userHandler      *UserHandler
	trainingHandler  *TrainingHandler
	messageHandler   *MessageHandler
	communityHandler *CommunityHandler
	buddyHandler     *BuddyHandler
}

// NewHandlers 创建主API处理器
func NewHandlers(
	userService *services.UserService,
	authService *services.AuthService,
	trainingService *services.TrainingService,
	aiService *services.AIService,
	messageService *services.MessageService,
	buddyService *services.BuddyService,
	communityService *services.CommunityService,
	userProfileService *services.UserProfileService,
) *Handlers {
	return &Handlers{
		userHandler:      NewUserHandler(userService, authService, userProfileService),
		trainingHandler:  NewTrainingHandler(trainingService, aiService),
		messageHandler:   NewMessageHandler(messageService),
		communityHandler: NewCommunityHandler(communityService),
		buddyHandler:     NewBuddyHandler(buddyService),
	}
}

// Register 注册所有路由
func (h *Handlers) Register(r *gin.Engine) {
	api := r.Group("/api/v1")

	// 用户相关路由
	user := api.Group("/user")
	user.Use(h.authMiddleware())
	{
		user.GET("/settings", h.userHandler.GetSettings)
		user.PUT("/settings", h.userHandler.UpdateSettings)
		user.POST("/change-password", h.userHandler.ChangePassword)
		user.GET("/stats", h.userHandler.GetUserStats)
		user.GET("/achievements", h.userHandler.GetUserAchievements)
		user.POST("/search", h.userHandler.SearchUsers)
		user.POST("/follow", h.userHandler.FollowUser)
	}

	// 训练相关路由
	training := api.Group("/training")
	training.Use(h.authMiddleware())
	{
		training.GET("/today", h.trainingHandler.GetTodayPlan)
		training.GET("/history", h.trainingHandler.GetHistoryPlans)
		training.POST("/plans", h.trainingHandler.CreatePlan)
		training.PUT("/plans/:id", h.trainingHandler.UpdatePlan)
		training.DELETE("/plans/:id", h.trainingHandler.DeletePlan)
		training.POST("/ai-generate", h.trainingHandler.GenerateAIPlan)
		training.POST("/start", h.trainingHandler.StartWorkout)
		training.POST("/end", h.trainingHandler.EndWorkout)
		training.POST("/complete-exercise", h.trainingHandler.CompleteExercise)
		training.POST("/feedback", h.trainingHandler.SubmitFeedback)
		training.GET("/stats", h.trainingHandler.GetTrainingStats)
	}

	// 消息相关路由
	messages := api.Group("/messages")
	messages.Use(h.authMiddleware())
	{
		messages.GET("/chats", h.messageHandler.GetChats)
		messages.POST("/chats", h.messageHandler.CreateChat)
		messages.GET("/chats/:id", h.messageHandler.GetChat)
		messages.GET("/chats/:id/messages", h.messageHandler.GetMessages)
		messages.POST("/chats/:id/messages", h.messageHandler.SendMessage)
		messages.PUT("/messages/:id/read", h.messageHandler.MarkMessageAsRead)
		messages.GET("/notifications", h.messageHandler.GetNotifications)
		messages.PUT("/notifications/:id/read", h.messageHandler.MarkNotificationAsRead)
		messages.POST("/notifications", h.messageHandler.CreateNotification)
		messages.GET("/unread-count", h.messageHandler.GetUnreadCount)
	}

	// 社区相关路由
	community := api.Group("/community")
	community.Use(h.authMiddleware())
	{
		community.GET("/posts", h.communityHandler.GetCommunityPosts)
		community.POST("/posts", h.communityHandler.CreateCommunityPost)
		community.GET("/posts/:id", h.communityHandler.GetCommunityPost)
		community.PUT("/posts/:id", h.communityHandler.UpdateCommunityPost)
		community.DELETE("/posts/:id", h.communityHandler.DeleteCommunityPost)
		community.POST("/posts/:id/like", h.communityHandler.LikeCommunityPost)
		community.DELETE("/posts/:id/like", h.communityHandler.UnlikeCommunityPost)
		community.POST("/posts/:id/comments", h.communityHandler.CommentCommunityPost)
		community.GET("/posts/:id/comments", h.communityHandler.GetCommunityComments)
		community.GET("/trending", h.communityHandler.GetTrendingPosts)
		community.GET("/coaches", h.communityHandler.GetRecommendedCoaches)
	}

	// 搭子相关路由
	buddies := api.Group("/buddies")
	buddies.Use(h.authMiddleware())
	{
		buddies.GET("/recommendations", h.buddyHandler.GetBuddyRecommendations)
		buddies.POST("/requests", h.buddyHandler.RequestBuddy)
		buddies.GET("/requests", h.buddyHandler.GetBuddyRequests)
		buddies.POST("/requests/:id/accept", h.buddyHandler.AcceptBuddyRequest)
		buddies.POST("/requests/:id/reject", h.buddyHandler.RejectBuddyRequest)
		buddies.GET("/my", h.buddyHandler.GetMyBuddies)
		buddies.DELETE("/:id", h.buddyHandler.DeleteBuddy)
	}
}

// authMiddleware 认证中间件
func (h *Handlers) authMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		token := c.GetHeader("Authorization")
		if token == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "未提供认证token"})
			c.Abort()
			return
		}

		// 简单的token验证（实际项目中应该使用JWT）
		if token == "Bearer test-token" {
			c.Set("user_id", "1")
			c.Next()
			return
		}

		// 尝试从token中解析用户ID
		userID, err := h.userHandler.authService.ValidateToken(token)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "无效的token"})
			c.Abort()
			return
		}

		c.Set("user_id", userID)
		c.Next()
	}
}
