package services

import (
	"fmt"
	"time"

	"gymates/internal/models"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// MessageService 消息服务
type MessageService struct {
	db *gorm.DB
}

// NewMessageService 创建消息服务实例
func NewMessageService(db *gorm.DB) *MessageService {
	return &MessageService{db: db}
}

// GetChats 获取聊天列表
func (s *MessageService) GetChats(userID string, skip, limit int) ([]models.ChatResponse, error) {
	var chats []models.Chat
	var responses []models.ChatResponse

	// 查询用户参与的聊天
	query := s.db.Preload("User1").Preload("User2").
		Where("user1_id = ? OR user2_id = ?", userID, userID).
		Order("last_message_time DESC")

	if err := query.Offset(skip).Limit(limit).Find(&chats).Error; err != nil {
		return nil, fmt.Errorf("获取聊天列表失败: %v", err)
	}

	for _, chat := range chats {
		// 确定对方用户
		// var otherUser models.User
		// if chat.User1ID == userID {
		// 	otherUser = chat.User2
		// } else {
		// 	otherUser = chat.User1
		// }

		// 模拟在线状态（实际应该基于WebSocket连接状态）
		isOnline := time.Since(chat.LastMessageTime) < 5*time.Minute

		response := models.ChatResponse{
			ID:              chat.ID,
			User1ID:         chat.User1ID,
			User2ID:         chat.User2ID,
			LastMessage:     chat.LastMessage,
			LastMessageTime: chat.LastMessageTime,
			UnreadCount:     chat.UnreadCount,
			IsOnline:        isOnline,
			CreatedAt:       chat.CreatedAt,
			UpdatedAt:       chat.UpdatedAt,
			User1:           chat.User1,
			User2:           chat.User2,
		}
		responses = append(responses, response)
	}

	return responses, nil
}

// CreateChat 创建聊天
func (s *MessageService) CreateChat(userID string, requestData models.CreateChatRequest) (*models.ChatResponse, error) {
	// 检查是否已经存在聊天
	var existingChat models.Chat
	if err := s.db.Where("(user1_id = ? AND user2_id = ?) OR (user1_id = ? AND user2_id = ?)",
		userID, requestData.UserID, requestData.UserID, userID).First(&existingChat).Error; err == nil {
		// 聊天已存在，返回现有聊天
		var user1, user2 models.User
		s.db.First(&user1, "id = ?", existingChat.User1ID)
		s.db.First(&user2, "id = ?", existingChat.User2ID)

		response := &models.ChatResponse{
			ID:              existingChat.ID,
			User1ID:         existingChat.User1ID,
			User2ID:         existingChat.User2ID,
			LastMessage:     existingChat.LastMessage,
			LastMessageTime: existingChat.LastMessageTime,
			UnreadCount:     existingChat.UnreadCount,
			IsOnline:        false,
			CreatedAt:       existingChat.CreatedAt,
			UpdatedAt:       existingChat.UpdatedAt,
			User1:           user1,
			User2:           user2,
		}
		return response, nil
	}

	// 创建新聊天
	chat := models.Chat{
		ID:              uuid.New().String(),
		User1ID:         userID,
		User2ID:         requestData.UserID,
		LastMessage:     "",
		LastMessageTime: time.Now(),
		UnreadCount:     0,
		CreatedAt:       time.Now(),
		UpdatedAt:       time.Now(),
	}

	if err := s.db.Create(&chat).Error; err != nil {
		return nil, fmt.Errorf("创建聊天失败: %v", err)
	}

	// 获取用户信息
	var user1, user2 models.User
	s.db.First(&user1, "id = ?", chat.User1ID)
	s.db.First(&user2, "id = ?", chat.User2ID)

	response := &models.ChatResponse{
		ID:              chat.ID,
		User1ID:         chat.User1ID,
		User2ID:         chat.User2ID,
		LastMessage:     chat.LastMessage,
		LastMessageTime: chat.LastMessageTime,
		UnreadCount:     chat.UnreadCount,
		IsOnline:        false,
		CreatedAt:       chat.CreatedAt,
		UpdatedAt:       chat.UpdatedAt,
		User1:           user1,
		User2:           user2,
	}

	return response, nil
}

// GetChat 获取聊天详情
func (s *MessageService) GetChat(chatID string, userID string) (*models.ChatResponse, error) {
	var chat models.Chat
	if err := s.db.Preload("User1").Preload("User2").
		Where("id = ? AND (user1_id = ? OR user2_id = ?)", chatID, userID, userID).
		First(&chat).Error; err != nil {
		return nil, fmt.Errorf("聊天不存在或无权限: %v", err)
	}

	// 模拟在线状态
	isOnline := time.Since(chat.LastMessageTime) < 5*time.Minute

	response := &models.ChatResponse{
		ID:              chat.ID,
		User1ID:         chat.User1ID,
		User2ID:         chat.User2ID,
		LastMessage:     chat.LastMessage,
		LastMessageTime: chat.LastMessageTime,
		UnreadCount:     chat.UnreadCount,
		IsOnline:        isOnline,
		CreatedAt:       chat.CreatedAt,
		UpdatedAt:       chat.UpdatedAt,
		User1:           chat.User1,
		User2:           chat.User2,
	}

	return response, nil
}

// GetMessages 获取消息列表
func (s *MessageService) GetMessages(chatID string, userID string, skip, limit int) ([]models.MessageResponse, error) {
	// 验证用户是否有权限访问该聊天
	var chat models.Chat
	if err := s.db.Where("id = ? AND (user1_id = ? OR user2_id = ?)", chatID, userID, userID).First(&chat).Error; err != nil {
		return nil, fmt.Errorf("聊天不存在或无权限: %v", err)
	}

	var messages []models.Message
	var responses []models.MessageResponse

	if err := s.db.Preload("Sender").
		Where("chat_id = ?", chatID).
		Order("created_at DESC").
		Offset(skip).Limit(limit).Find(&messages).Error; err != nil {
		return nil, fmt.Errorf("获取消息列表失败: %v", err)
	}

	for _, message := range messages {
		response := models.MessageResponse{
			ID:        message.ID,
			ChatID:    message.ChatID,
			SenderID:  message.SenderID,
			Content:   message.Content,
			Type:      message.Type,
			IsRead:    message.IsRead,
			CreatedAt: message.CreatedAt,
			Sender:    message.Sender,
		}
		responses = append(responses, response)
	}

	return responses, nil
}

// SendMessage 发送消息
func (s *MessageService) SendMessage(chatID string, senderID string, requestData models.SendMessageRequest) (*models.MessageResponse, error) {
	// 验证用户是否有权限发送消息到该聊天
	var chat models.Chat
	if err := s.db.Where("id = ? AND (user1_id = ? OR user2_id = ?)", chatID, senderID, senderID).First(&chat).Error; err != nil {
		return nil, fmt.Errorf("聊天不存在或无权限: %v", err)
	}

	// 开始事务
	tx := s.db.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// 创建消息
	message := models.Message{
		ID:        uuid.New().String(),
		ChatID:    chatID,
		SenderID:  senderID,
		Content:   requestData.Content,
		Type:      requestData.Type,
		IsRead:    false,
		CreatedAt: time.Now(),
	}

	if err := tx.Create(&message).Error; err != nil {
		tx.Rollback()
		return nil, fmt.Errorf("创建消息失败: %v", err)
	}

	// 更新聊天最后消息信息
	chat.LastMessage = requestData.Content
	chat.LastMessageTime = time.Now()

	// 更新未读计数（对方用户的未读数+1）
	if chat.User1ID == senderID {
		chat.UnreadCount = chat.UnreadCount + 1
	} else {
		chat.UnreadCount = chat.UnreadCount + 1
	}

	chat.UpdatedAt = time.Now()

	if err := tx.Save(&chat).Error; err != nil {
		tx.Rollback()
		return nil, fmt.Errorf("更新聊天信息失败: %v", err)
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		return nil, fmt.Errorf("提交事务失败: %v", err)
	}

	// 获取发送者信息
	var sender models.User
	s.db.First(&sender, "id = ?", senderID)

	response := &models.MessageResponse{
		ID:        message.ID,
		ChatID:    message.ChatID,
		SenderID:  message.SenderID,
		Content:   message.Content,
		Type:      message.Type,
		IsRead:    message.IsRead,
		CreatedAt: message.CreatedAt,
		Sender:    sender,
	}

	return response, nil
}

// MarkMessageAsRead 标记消息为已读
func (s *MessageService) MarkMessageAsRead(messageID string, userID string) error {
	var message models.Message
	if err := s.db.First(&message, "id = ?", messageID).Error; err != nil {
		return fmt.Errorf("消息不存在: %v", err)
	}

	// 验证用户是否有权限标记该消息
	var chat models.Chat
	if err := s.db.Where("id = ? AND (user1_id = ? OR user2_id = ?)", message.ChatID, userID, userID).First(&chat).Error; err != nil {
		return fmt.Errorf("无权限操作该消息: %v", err)
	}

	// 标记消息为已读
	message.IsRead = true
	if err := s.db.Save(&message).Error; err != nil {
		return fmt.Errorf("标记消息已读失败: %v", err)
	}

	// 更新聊天的未读计数
	if chat.UnreadCount > 0 {
		chat.UnreadCount = chat.UnreadCount - 1
		s.db.Save(&chat)
	}

	return nil
}

// GetNotifications 获取通知列表
func (s *MessageService) GetNotifications(userID string, skip, limit int) ([]models.NotificationResponse, error) {
	var notifications []models.Notification
	var responses []models.NotificationResponse

	if err := s.db.Preload("User").
		Where("user_id = ?", userID).
		Order("created_at DESC").
		Offset(skip).Limit(limit).Find(&notifications).Error; err != nil {
		return nil, fmt.Errorf("获取通知列表失败: %v", err)
	}

	for _, notification := range notifications {
		response := models.NotificationResponse{
			ID:        notification.ID,
			UserID:    notification.UserID,
			Type:      notification.Type,
			Title:     notification.Title,
			Content:   notification.Content,
			ImageURL:  notification.ImageURL,
			ActionURL: notification.ActionURL,
			IsRead:    notification.IsRead,
			ExtraData: notification.ExtraData,
			CreatedAt: notification.CreatedAt,
			User:      notification.User,
		}
		responses = append(responses, response)
	}

	return responses, nil
}

// CreateNotification 创建通知
func (s *MessageService) CreateNotification(requestData models.CreateNotificationRequest) (*models.NotificationResponse, error) {
	notification := models.Notification{
		ID:        uuid.New().String(),
		UserID:    requestData.UserID,
		Type:      requestData.Type,
		Title:     requestData.Title,
		Content:   requestData.Content,
		ImageURL:  requestData.ImageURL,
		ActionURL: requestData.ActionURL,
		IsRead:    false,
		ExtraData: requestData.ExtraData,
		CreatedAt: time.Now(),
	}

	if err := s.db.Create(&notification).Error; err != nil {
		return nil, fmt.Errorf("创建通知失败: %v", err)
	}

	// 获取用户信息
	var user models.User
	s.db.First(&user, "id = ?", notification.UserID)

	response := &models.NotificationResponse{
		ID:        notification.ID,
		UserID:    notification.UserID,
		Type:      notification.Type,
		Title:     notification.Title,
		Content:   notification.Content,
		ImageURL:  notification.ImageURL,
		ActionURL: notification.ActionURL,
		IsRead:    notification.IsRead,
		ExtraData: notification.ExtraData,
		CreatedAt: notification.CreatedAt,
		User:      user,
	}

	return response, nil
}

// MarkNotificationAsRead 标记通知为已读
func (s *MessageService) MarkNotificationAsRead(notificationID string, userID string) error {
	var notification models.Notification
	if err := s.db.Where("id = ? AND user_id = ?", notificationID, userID).First(&notification).Error; err != nil {
		return fmt.Errorf("通知不存在或无权限: %v", err)
	}

	notification.IsRead = true
	if err := s.db.Save(&notification).Error; err != nil {
		return fmt.Errorf("标记通知已读失败: %v", err)
	}

	return nil
}

// GetUnreadCount 获取未读消息和通知数量
func (s *MessageService) GetUnreadCount(userID string) (map[string]int, error) {
	var chatUnreadCount int64
	var notificationUnreadCount int64

	// 统计未读聊天消息
	if err := s.db.Model(&models.Chat{}).Where("(user1_id = ? OR user2_id = ?) AND unread_count > 0", userID, userID).Count(&chatUnreadCount).Error; err != nil {
		return nil, fmt.Errorf("获取未读聊天数量失败: %v", err)
	}

	// 统计未读通知
	if err := s.db.Model(&models.Notification{}).Where("user_id = ? AND is_read = ?", userID, false).Count(&notificationUnreadCount).Error; err != nil {
		return nil, fmt.Errorf("获取未读通知数量失败: %v", err)
	}

	return map[string]int{
		"chat_unread_count":         int(chatUnreadCount),
		"notification_unread_count": int(notificationUnreadCount),
		"total_unread_count":        int(chatUnreadCount + notificationUnreadCount),
	}, nil
}
