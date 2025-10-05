package services

import (
	"fmt"
	"time"

	"gymates/internal/models"

	"gorm.io/gorm"
)

type MessageService struct {
	db *gorm.DB
}

func NewMessageService(db *gorm.DB) *MessageService {
	return &MessageService{
		db: db,
	}
}

// GetChats 获取聊天列表
func (s *MessageService) GetChats(userID string) ([]models.Chat, error) {
	var chats []models.Chat
	// 使用PostgreSQL的JSON操作符来查找包含用户ID的聊天
	if err := s.db.Where("participants @> ? OR created_by = ?", fmt.Sprintf(`["%s"]`, userID), userID).Find(&chats).Error; err != nil {
		return nil, fmt.Errorf("获取聊天列表失败: %w", err)
	}
	return chats, nil
}

// CreateChat 创建聊天
func (s *MessageService) CreateChat(userID uint, req *models.CreateChatRequest) (*models.Chat, error) {
	chat := &models.Chat{
		ID:              fmt.Sprintf("%d_%d", userID, req.UserID),
		User1ID:         fmt.Sprintf("%d", userID),
		User2ID:         fmt.Sprintf("%d", req.UserID),
		LastMessage:     "",
		LastMessageTime: time.Now(),
		UnreadCount:     0,
		CreatedAt:       time.Now(),
		UpdatedAt:       time.Now(),
	}

	if err := s.db.Create(chat).Error; err != nil {
		return nil, fmt.Errorf("创建聊天失败: %w", err)
	}

	return chat, nil
}

// SendMessage 发送消息
func (s *MessageService) SendMessage(chatID, userID uint, req *models.SendMessageRequest) (*models.Message, error) {
	message := &models.Message{
		ID:        fmt.Sprintf("%d_%d_%d", chatID, userID, time.Now().Unix()),
		ChatID:    fmt.Sprintf("%d", chatID),
		SenderID:  fmt.Sprintf("%d", userID),
		Type:      req.Type,
		Content:   req.Content,
		IsRead:    false,
		CreatedAt: time.Now(),
	}

	if err := s.db.Create(message).Error; err != nil {
		return nil, fmt.Errorf("发送消息失败: %w", err)
	}

	return message, nil
}

// GetNotifications 获取通知列表
func (s *MessageService) GetNotifications(userID string) ([]models.Notification, error) {
	var notifications []models.Notification
	if err := s.db.Where("user_id = ?", userID).Order("created_at DESC").Find(&notifications).Error; err != nil {
		return nil, fmt.Errorf("获取通知列表失败: %w", err)
	}
	return notifications, nil
}
