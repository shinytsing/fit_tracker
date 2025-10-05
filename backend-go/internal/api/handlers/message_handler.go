package handlers

import (
	"mime/multipart"
	"net/http"
	"strconv"
	"time"

	"gymates/internal/models"
	"gymates/internal/services"

	"github.com/gin-gonic/gin"
)

// MessageHandler 消息相关处理器
type MessageHandler struct {
	messageService      *services.MessageService
	notificationService *services.NotificationService
	websocketService    *services.WebSocketService
}

// NewMessageHandler 创建消息处理器
func NewMessageHandler(messageService *services.MessageService, notificationService *services.NotificationService, websocketService *services.WebSocketService) *MessageHandler {
	return &MessageHandler{
		messageService:      messageService,
		notificationService: notificationService,
		websocketService:    websocketService,
	}
}

// GetChats 获取聊天列表
// GET /api/v1/messages/chats
func (h *MessageHandler) GetChats(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 获取查询参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	chats, total, err := h.messageService.GetChats(userID, page, limit)
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
			"total_page": (int(total) + limit - 1) / limit,
		},
	})
}

// GetChatMessages 获取聊天消息
// GET /api/v1/messages/chats/:id/messages
func (h *MessageHandler) GetChatMessages(c *gin.Context) {
	userID := c.GetString("user_id")
	chatID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 获取查询参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "50"))
	lastMessageID := c.Query("last_message_id")

	messages, hasMore, err := h.messageService.GetChatMessages(chatID, userID, page, limit, lastMessageID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 标记消息为已读
	go h.messageService.MarkMessagesAsRead(chatID, userID)

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

// SendMessage 发送消息
// POST /api/v1/messages/chats/:id/messages
func (h *MessageHandler) SendMessage(c *gin.Context) {
	userID := c.GetString("user_id")
	chatID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		Type            string                 `json:"type" binding:"required"` // text, image, video, voice, file, location, contact
		Content         string                 `json:"content"`
		MediaURL        string                 `json:"media_url"`
		ThumbnailURL    string                 `json:"thumbnail_url"`
		Duration        int                    `json:"duration"` // 语音/视频时长
		FileName        string                 `json:"file_name"`
		FileSize        int64                  `json:"file_size"`
		LocationName    string                 `json:"location_name"`
		LocationAddress string                 `json:"location_address"`
		Latitude        float64                `json:"latitude"`
		Longitude       float64                `json:"longitude"`
		ContactName     string                 `json:"contact_name"`
		ContactPhone    string                 `json:"contact_phone"`
		ContactAvatar   string                 `json:"contact_avatar"`
		ReplyToID       string                 `json:"reply_to_id"` // 回复的消息ID
		Extra           map[string]interface{} `json:"extra"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 转换 string 到 uint
	chatIDUint, err := strconv.ParseUint(chatID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的聊天ID"})
		return
	}
	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	message := &models.Message{
		ChatID:   uint(chatIDUint),
		SenderID: uint(userIDUint),
		Type:     models.MessageType(req.Type),
		Content:  req.Content,
		MediaURL: req.MediaURL,
		Status:   models.MessageStatusSending,
	}

	sentMessage, err := h.messageService.SendMessage(message)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 通过WebSocket实时推送消息
	go h.websocketService.BroadcastToChat(chatID, sentMessage)

	// 异步处理通知
	go h.notificationService.NotifyNewMessage(sentMessage)

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"data":    sentMessage,
	})
}

// UpdateMessageStatus 更新消息状态
// PUT /api/v1/messages/messages/:id/status
func (h *MessageHandler) UpdateMessageStatus(c *gin.Context) {
	userID := c.GetString("user_id")
	messageID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		Status string `json:"status" binding:"required"` // sent, delivered, read, failed
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := h.messageService.UpdateMessageStatus(messageID, userID, models.MessageStatus(req.Status))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "消息状态更新成功",
	})
}

// DeleteMessage 删除消息
// DELETE /api/v1/messages/messages/:id
func (h *MessageHandler) DeleteMessage(c *gin.Context) {
	userID := c.GetString("user_id")
	messageID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	err := h.messageService.DeleteMessage(messageID, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "消息删除成功",
	})
}

// MarkMessagesAsRead 标记消息为已读
// POST /api/v1/messages/chats/:id/read
func (h *MessageHandler) MarkMessagesAsRead(c *gin.Context) {
	userID := c.GetString("user_id")
	chatID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	err := h.messageService.MarkMessagesAsRead(chatID, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "消息已标记为已读",
	})
}

// GetNotifications 获取通知列表
// GET /api/v1/messages/notifications
func (h *MessageHandler) GetNotifications(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 获取查询参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	unreadOnly := c.DefaultQuery("unread_only", "false") == "true"

	notifications, total, err := h.messageService.GetNotifications(userID, page, limit, unreadOnly)
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
			"total_page":    (int(total) + limit - 1) / limit,
		},
	})
}

// MarkNotificationAsRead 标记通知为已读
// PUT /api/v1/messages/notifications/:id/read
func (h *MessageHandler) MarkNotificationAsRead(c *gin.Context) {
	userID := c.GetString("user_id")
	notificationID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	err := h.messageService.MarkNotificationAsRead(notificationID, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "通知已标记为已读",
	})
}

// MarkAllNotificationsAsRead 标记所有通知为已读
// POST /api/v1/messages/notifications/read-all
func (h *MessageHandler) MarkAllNotificationsAsRead(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	err := h.messageService.MarkAllNotificationsAsRead(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "所有通知已标记为已读",
	})
}

// GetGroups 获取群聊列表
// GET /api/v1/messages/groups
func (h *MessageHandler) GetGroups(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 获取查询参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	groups, total, err := h.messageService.GetGroups(userID, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"groups":     groups,
			"total":      total,
			"page":       page,
			"limit":      limit,
			"total_page": (int(total) + limit - 1) / limit,
		},
	})
}

// CreateGroup 创建群聊
// POST /api/v1/messages/groups
func (h *MessageHandler) CreateGroup(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		Name        string   `json:"name" binding:"required"`
		Description string   `json:"description"`
		Avatar      string   `json:"avatar"`
		MemberIDs   []string `json:"member_ids" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 转换 userID 为 uint
	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	group := &models.Group{
		Name:        req.Name,
		Description: req.Description,
		Avatar:      req.Avatar,
		CreatedBy:   uint(userIDUint),
		Members:     append(req.MemberIDs, userID), // 包含创建者
		Status:      "active",
	}

	createdGroup, err := h.messageService.CreateGroup(group)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 异步处理通知
	go h.notificationService.NotifyGroupCreated(createdGroup)

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"data":    createdGroup,
	})
}

// JoinGroup 加入群聊
// POST /api/v1/messages/groups/:id/join
func (h *MessageHandler) JoinGroup(c *gin.Context) {
	userID := c.GetString("user_id")
	groupID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	err := h.messageService.JoinGroup(groupID, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "成功加入群聊",
	})
}

// LeaveGroup 退出群聊
// POST /api/v1/messages/groups/:id/leave
func (h *MessageHandler) LeaveGroup(c *gin.Context) {
	userID := c.GetString("user_id")
	groupID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	err := h.messageService.LeaveGroup(groupID, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "已退出群聊",
	})
}

// UploadMedia 上传媒体文件
// POST /api/v1/messages/media/upload
func (h *MessageHandler) UploadMedia(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 获取上传的文件
	file, header, err := c.Request.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "文件上传失败"})
		return
	}
	defer file.Close()

	// 获取文件类型
	fileType := c.PostForm("type") // image, video, audio, file
	if fileType == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "文件类型不能为空"})
		return
	}

	// 上传文件
	mediaItem, err := h.messageService.UploadMedia(userID, file, header, fileType)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    mediaItem,
	})
}

// UploadVideo 上传视频文件
// POST /api/v1/messages/video/upload
func (h *MessageHandler) UploadVideo(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 获取上传的视频文件
	file, header, err := c.Request.FormFile("video")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "视频文件上传失败"})
		return
	}
	defer file.Close()

	// 获取缩略图文件（可选）
	var thumbnailFile *multipart.FileHeader
	if thumbnail, err := c.FormFile("thumbnail"); err == nil {
		thumbnailFile = thumbnail
	}

	// 获取视频时长
	duration := 0
	if durationStr := c.PostForm("duration"); durationStr != "" {
		if d, err := strconv.Atoi(durationStr); err == nil {
			duration = d
		}
	}

	// 上传视频
	videoItem, err := h.messageService.UploadVideo(userID, file, header, thumbnailFile, duration)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    videoItem,
	})
}

// GetMessageStats 获取消息统计
// GET /api/v1/messages/stats
func (h *MessageHandler) GetMessageStats(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	stats, err := h.messageService.GetMessageStats(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    stats,
	})
}

// SearchMessages 搜索消息
// GET /api/v1/messages/search
func (h *MessageHandler) SearchMessages(c *gin.Context) {
	userID := c.GetString("user_id")
	query := c.Query("q")
	if query == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "搜索关键词不能为空"})
		return
	}

	// 获取查询参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	chatID := c.Query("chat_id") // 可选：指定聊天

	messages, total, err := h.messageService.SearchMessages(userID, query, chatID, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"messages":   messages,
			"total":      total,
			"page":       page,
			"limit":      limit,
			"total_page": (int(total) + limit - 1) / limit,
			"query":      query,
		},
	})
}

// ==================== 视频通话API ====================

// StartVideoCall 发起视频通话
// POST /api/v1/messages/video-call/start
func (h *MessageHandler) StartVideoCall(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		CalleeID string `json:"callee_id" binding:"required"` // 被邀请用户ID
		ChatID   string `json:"chat_id" binding:"required"`   // 聊天ID
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 创建视频通话会话
	session, err := h.messageService.CreateVideoCallSession(userID, req.CalleeID, req.ChatID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 通过WebSocket发送视频通话邀请
	go func() {
		wsMsg := map[string]interface{}{
			"type":      "video_call_invite",
			"user_id":   userID,
			"chat_id":   req.ChatID,
			"timestamp": time.Now().Unix(),
			"data": map[string]interface{}{
				"session_id": session.ID,
				"room_id":    session.RoomID,
				"caller_id":  userID,
				"callee_id":  req.CalleeID,
			},
		}
		h.websocketService.SendToUser(req.CalleeID, wsMsg)
	}()

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"data":    session,
	})
}

// AcceptVideoCall 接受视频通话
// POST /api/v1/messages/video-call/:id/accept
func (h *MessageHandler) AcceptVideoCall(c *gin.Context) {
	userID := c.GetString("user_id")
	sessionID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 接受视频通话
	session, err := h.messageService.AcceptVideoCall(sessionID, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 通过WebSocket发送接受消息
	go func() {
		wsMsg := map[string]interface{}{
			"type":      "video_call_accept",
			"user_id":   userID,
			"timestamp": time.Now().Unix(),
			"data": map[string]interface{}{
				"session_id": session.ID,
				"room_id":    session.RoomID,
				"caller_id":  session.CallerID,
				"callee_id":  userID,
			},
		}
		h.websocketService.SendToUser(string(rune(session.CallerID)), wsMsg)
	}()

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    session,
	})
}

// RejectVideoCall 拒绝视频通话
// POST /api/v1/messages/video-call/:id/reject
func (h *MessageHandler) RejectVideoCall(c *gin.Context) {
	userID := c.GetString("user_id")
	sessionID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 拒绝视频通话
	session, err := h.messageService.RejectVideoCall(sessionID, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 通过WebSocket发送拒绝消息
	go func() {
		wsMsg := map[string]interface{}{
			"type":      "video_call_reject",
			"user_id":   userID,
			"timestamp": time.Now().Unix(),
			"data": map[string]interface{}{
				"session_id": session.ID,
				"caller_id":  session.CallerID,
				"callee_id":  userID,
			},
		}
		h.websocketService.SendToUser(string(rune(session.CallerID)), wsMsg)
	}()

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    session,
	})
}

// EndVideoCall 结束视频通话
// POST /api/v1/messages/video-call/:id/end
func (h *MessageHandler) EndVideoCall(c *gin.Context) {
	userID := c.GetString("user_id")
	sessionID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 结束视频通话
	session, err := h.messageService.EndVideoCall(sessionID, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 通过WebSocket发送结束消息
	go func() {
		otherUserID := string(rune(session.CallerID))
		if session.CallerID == parseUserID(userID) {
			otherUserID = string(rune(session.CalleeID))
		}

		wsMsg := map[string]interface{}{
			"type":      "video_call_end",
			"user_id":   userID,
			"timestamp": time.Now().Unix(),
			"data": map[string]interface{}{
				"session_id":    session.ID,
				"other_user_id": otherUserID,
				"duration":      session.Duration,
			},
		}
		h.websocketService.SendToUser(otherUserID, wsMsg)
	}()

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    session,
	})
}

// GetVideoCallHistory 获取视频通话历史
// GET /api/v1/messages/video-call/history
func (h *MessageHandler) GetVideoCallHistory(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 获取查询参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	sessions, total, err := h.messageService.GetVideoCallHistory(userID, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"sessions":   sessions,
			"total":      total,
			"page":       page,
			"limit":      limit,
			"total_page": (int(total) + limit - 1) / limit,
		},
	})
}

// ==================== 视频消息API ====================

// SendVideoMessage 发送视频消息
// POST /api/v1/messages/video-message/send
func (h *MessageHandler) SendVideoMessage(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		ChatID       string `json:"chat_id" binding:"required"`
		VideoURL     string `json:"video_url" binding:"required"`
		ThumbnailURL string `json:"thumbnail_url"`
		Duration     int    `json:"duration" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 发送视频消息
	message, err := h.messageService.SendVideoMessage(req.ChatID, userID, req.VideoURL, req.ThumbnailURL, req.Duration)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 通过WebSocket实时推送消息
	go h.websocketService.BroadcastToChat(req.ChatID, message)

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"data":    message,
	})
}

// GetVideoMessages 获取视频消息列表
// GET /api/v1/messages/video-messages
func (h *MessageHandler) GetVideoMessages(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 获取查询参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	messages, total, err := h.messageService.GetVideoMessages(userID, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"messages":   messages,
			"total":      total,
			"page":       page,
			"limit":      limit,
			"total_page": (int(total) + limit - 1) / limit,
		},
	})
}

// UpdateVideoMessageStatus 更新视频消息状态
// PUT /api/v1/messages/video-messages/:id/status
func (h *MessageHandler) UpdateVideoMessageStatus(c *gin.Context) {
	userID := c.GetString("user_id")
	messageID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		Status string `json:"status" binding:"required"` // sent, delivered, read, failed
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := h.messageService.UpdateVideoMessageStatus(messageID, userID, models.MessageStatus(req.Status))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "视频消息状态更新成功",
	})
}
