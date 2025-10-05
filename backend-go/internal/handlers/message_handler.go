package handlers

import (
	"net/http"
	"strconv"

	"gymates/internal/models"
	"gymates/pkg/logger"

	"github.com/gin-gonic/gin"
)

// GetChats 获取聊天列表
func (h *Handlers) GetChats(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	// 获取查询参数
	skip, _ := strconv.Atoi(c.DefaultQuery("skip", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	if limit > 50 {
		limit = 50
	}

	// 获取聊天列表
	chats, err := h.services.MessageService.GetChats(userID, skip, limit)
	if err != nil {
		logger.Error("获取聊天列表失败", map[string]interface{}{
			"user_id": userID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取聊天列表失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取聊天列表成功",
		"data":    chats,
	})
}

// CreateChat 创建聊天
func (h *Handlers) CreateChat(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	var requestData models.CreateChatRequest
	if err := c.ShouldBindJSON(&requestData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "请求参数错误"})
		return
	}

	// 创建聊天
	response, err := h.services.MessageService.CreateChat(userID, requestData)
	if err != nil {
		logger.Error("创建聊天失败", map[string]interface{}{
			"user_id": userID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	logger.Info("聊天创建成功", map[string]interface{}{
		"user_id": userID,
		"chat_id": response.ID,
	})

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "聊天创建成功",
		"data":    response,
	})
}

// GetChat 获取聊天详情
func (h *Handlers) GetChat(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	chatID := c.Param("id")
	if chatID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "聊天ID不能为空"})
		return
	}

	// 获取聊天详情
	response, err := h.services.MessageService.GetChat(chatID, userID)
	if err != nil {
		logger.Error("获取聊天详情失败", map[string]interface{}{
			"user_id": userID,
			"chat_id": chatID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取聊天详情成功",
		"data":    response,
	})
}

// GetMessages 获取消息列表
func (h *Handlers) GetMessages(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	chatID := c.Param("id")
	if chatID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "聊天ID不能为空"})
		return
	}

	// 获取查询参数
	skip, _ := strconv.Atoi(c.DefaultQuery("skip", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "50"))

	if limit > 100 {
		limit = 100
	}

	// 获取消息列表
	messages, err := h.services.MessageService.GetMessages(chatID, userID, skip, limit)
	if err != nil {
		logger.Error("获取消息列表失败", map[string]interface{}{
			"user_id": userID,
			"chat_id": chatID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取消息列表失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取消息列表成功",
		"data":    messages,
	})
}

// SendMessage 发送消息
func (h *Handlers) SendMessage(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	chatID := c.Param("id")
	if chatID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "聊天ID不能为空"})
		return
	}

	var requestData models.SendMessageRequest
	if err := c.ShouldBindJSON(&requestData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "请求参数错误"})
		return
	}

	// 发送消息
	response, err := h.services.MessageService.SendMessage(chatID, userID, requestData)
	if err != nil {
		logger.Error("发送消息失败", map[string]interface{}{
			"user_id": userID,
			"chat_id": chatID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	logger.Info("消息发送成功", map[string]interface{}{
		"user_id":    userID,
		"chat_id":    chatID,
		"message_id": response.ID,
	})

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "消息发送成功",
		"data":    response,
	})
}

// MarkMessageAsRead 标记消息为已读
func (h *Handlers) MarkMessageAsRead(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	messageID := c.Param("id")
	if messageID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "消息ID不能为空"})
		return
	}

	// 标记消息为已读
	err := h.services.MessageService.MarkMessageAsRead(messageID, userID)
	if err != nil {
		logger.Error("标记消息已读失败", map[string]interface{}{
			"user_id":    userID,
			"message_id": messageID,
			"error":      err.Error(),
		})
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	logger.Info("消息标记已读成功", map[string]interface{}{
		"user_id":    userID,
		"message_id": messageID,
	})

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "消息标记已读成功",
	})
}

// GetNotifications 获取通知列表
func (h *Handlers) GetNotifications(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	// 获取查询参数
	skip, _ := strconv.Atoi(c.DefaultQuery("skip", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	if limit > 50 {
		limit = 50
	}

	// 获取通知列表
	notifications, err := h.services.MessageService.GetNotifications(userID, skip, limit)
	if err != nil {
		logger.Error("获取通知列表失败", map[string]interface{}{
			"user_id": userID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取通知列表失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取通知列表成功",
		"data":    notifications,
	})
}

// CreateNotification 创建通知
func (h *Handlers) CreateNotification(c *gin.Context) {
	var requestData models.CreateNotificationRequest
	if err := c.ShouldBindJSON(&requestData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "请求参数错误"})
		return
	}

	// 创建通知
	response, err := h.services.MessageService.CreateNotification(requestData)
	if err != nil {
		logger.Error("创建通知失败", map[string]interface{}{
			"user_id": requestData.UserID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	logger.Info("通知创建成功", map[string]interface{}{
		"user_id":         requestData.UserID,
		"notification_id": response.ID,
	})

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "通知创建成功",
		"data":    response,
	})
}

// MarkNotificationAsRead 标记通知为已读
func (h *Handlers) MarkNotificationAsRead(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	notificationID := c.Param("id")
	if notificationID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "通知ID不能为空"})
		return
	}

	// 标记通知为已读
	err := h.services.MessageService.MarkNotificationAsRead(notificationID, userID)
	if err != nil {
		logger.Error("标记通知已读失败", map[string]interface{}{
			"user_id":         userID,
			"notification_id": notificationID,
			"error":           err.Error(),
		})
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	logger.Info("通知标记已读成功", map[string]interface{}{
		"user_id":         userID,
		"notification_id": notificationID,
	})

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "通知标记已读成功",
	})
}

// GetUnreadCount 获取未读数量
func (h *Handlers) GetUnreadCount(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	// 获取未读数量
	counts, err := h.services.MessageService.GetUnreadCount(userID)
	if err != nil {
		logger.Error("获取未读数量失败", map[string]interface{}{
			"user_id": userID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取未读数量失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取未读数量成功",
		"data":    counts,
	})
}
