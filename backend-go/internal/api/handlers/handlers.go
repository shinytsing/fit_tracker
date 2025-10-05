package handlers

import (
	"gymates/internal/config"
	"gymates/internal/infrastructure/cache"
	"gymates/internal/models"
	"gymates/internal/services"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/go-redis/redis/v8"
	"gorm.io/gorm"
)

// Handlers 处理器集合
type Handlers struct {
	DB     *gorm.DB
	Redis  *redis.Client
	Cache  *cache.CacheService
	Config *config.Config

	// 服务层
	UserService        *services.UserService
	UserProfileService *services.UserProfileService
	WorkoutService     *services.WorkoutService
	CommunityService   *services.CommunityService
	MessageService     *services.MessageService
	WebSocketService   *services.WebSocketService
	RestService        *services.RestService
}

// New 创建新的处理器集合
func New(db *gorm.DB, redis *redis.Client, cacheService *cache.CacheService, cfg *config.Config) *Handlers {
	// 初始化服务层
	userService := services.NewUserService(db, redis)
	userProfileService := services.NewUserProfileService(db)
	workoutService := services.NewWorkoutService(db, redis)
	communityService := services.NewCommunityService(db)
	messageService := services.NewMessageService(db)
	webSocketService := services.NewWebSocketService()
	restService := services.NewRestService(db)

	return &Handlers{
		DB:                 db,
		Redis:              redis,
		Cache:              cacheService,
		Config:             cfg,
		UserService:        userService,
		UserProfileService: userProfileService,
		WorkoutService:     workoutService,
		CommunityService:   communityService,
		MessageService:     messageService,
		WebSocketService:   webSocketService,
		RestService:        restService,
	}
}

// HealthCheck 健康检查端点
func (h *Handlers) HealthCheck(c *gin.Context) {
	// 检查数据库连接
	sqlDB, err := h.DB.DB()
	if err != nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{
			"status": "unhealthy",
			"error":  "database connection failed",
		})
		return
	}

	if err := sqlDB.Ping(); err != nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{
			"status": "unhealthy",
			"error":  "database ping failed",
		})
		return
	}

	// 检查 Redis 连接
	if err := h.Redis.Ping(c.Request.Context()).Err(); err != nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{
			"status": "unhealthy",
			"error":  "redis connection failed",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  "healthy",
		"message": "FitTracker API is running",
	})
}

// GetChats 获取聊天列表
func (h *Handlers) GetChats(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	chats, total, err := h.MessageService.GetChats(userID, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"chats":      chats,
			"total":      total,
			"page":       page,
			"limit":      limit,
			"total_page": (total + int64(limit) - 1) / int64(limit),
		},
	})
}

// GetChatMessages 获取聊天消息
func (h *Handlers) GetChatMessages(c *gin.Context) {
	userID := c.GetString("user_id")
	chatID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "50"))
	lastMessageID := c.Query("last_message_id")

	messages, hasMore, err := h.MessageService.GetChatMessages(chatID, userID, page, limit, lastMessageID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 标记消息为已读
	go h.MessageService.MarkMessagesAsRead(chatID, userID)

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"messages": messages,
			"has_more": hasMore,
			"page":     page,
			"limit":    limit,
		},
	})
}

// CreateChat 创建聊天
func (h *Handlers) CreateChat(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		ParticipantIDs []string `json:"participant_ids" binding:"required"`
		Name           string   `json:"name"`
		Type           string   `json:"type"` // private, group
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 添加当前用户到参与者列表
	participants := append(req.ParticipantIDs, userID)

	chat := &models.Chat{
		Name:         req.Name,
		Type:         models.ChatType(req.Type),
		Participants: participants,
		CreatedBy:    parseUserID(userID), // 将userID转换为uint
		Status:       models.ChatStatusActive,
	}

	createdChat, err := h.MessageService.CreateChat(chat)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"data":    createdChat,
	})
}

// SendMessage 发送消息
func (h *Handlers) SendMessage(c *gin.Context) {
	userID := c.GetString("user_id")
	chatID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		Type     string `json:"type" binding:"required"` // text, image, video, voice, file
		Content  string `json:"content"`
		MediaURL string `json:"media_url"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	message := &models.Message{
		ChatID:   parseChatID(chatID), // 将chatID转换为uint
		SenderID: parseUserID(userID), // 将userID转换为uint
		Type:     models.MessageType(req.Type),
		Content:  req.Content,
		MediaURL: req.MediaURL,
		Status:   models.MessageStatusSent,
	}

	sentMessage, err := h.MessageService.SendMessage(message)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 通过WebSocket实时推送消息
	go func() {
		// 创建WebSocket消息
		wsMsg := map[string]interface{}{
			"type":      "message",
			"chat_id":   chatID,
			"user_id":   userID,
			"content":   sentMessage.Content,
			"data":      sentMessage,
			"timestamp": sentMessage.CreatedAt.Unix(),
		}
		h.WebSocketService.BroadcastToChat(chatID, wsMsg)
	}()

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"data":    sentMessage,
	})
}

// GetNotifications 获取通知
func (h *Handlers) GetNotifications(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	unreadOnly := c.DefaultQuery("unread_only", "false") == "true"

	notifications, total, err := h.MessageService.GetNotifications(userID, page, limit, unreadOnly)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"notifications": notifications,
			"total":         total,
			"page":          page,
			"limit":         limit,
			"total_page":    (total + int64(limit) - 1) / int64(limit),
		},
	})
}

// MarkNotificationRead 标记通知为已读
func (h *Handlers) MarkNotificationRead(c *gin.Context) {
	userID := c.GetString("user_id")
	notificationID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	err := h.MessageService.MarkNotificationAsRead(notificationID, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "通知已标记为已读",
	})
}

// ClearNotifications 清除通知
func (h *Handlers) ClearNotifications(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	err := h.MessageService.MarkAllNotificationsAsRead(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "所有通知已标记为已读",
	})
}

// GetSystemMessages 获取系统消息
func (h *Handlers) GetSystemMessages(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 暂时返回空列表
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"messages": []interface{}{},
			"total":    0,
		},
	})
}

// HandleWebSocket WebSocket处理器
func (h *Handlers) HandleWebSocket(c *gin.Context) {
	h.WebSocketService.HandleWebSocket(c)
}

// parseUserID 将字符串用户ID转换为uint
func parseUserID(userID string) uint {
	if id, err := strconv.ParseUint(userID, 10, 32); err == nil {
		return uint(id)
	}
	return 0
}

// parseChatID 将字符串聊天ID转换为uint
func parseChatID(chatID string) uint {
	if id, err := strconv.ParseUint(chatID, 10, 32); err == nil {
		return uint(id)
	}
	return 0
}
