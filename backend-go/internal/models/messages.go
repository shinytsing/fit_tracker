package models

import (
	"time"
)

// Chat 聊天模型
type Chat struct {
	ID              string    `json:"id" gorm:"primaryKey"`
	User1ID         string    `json:"user1_id" gorm:"not null"`
	User2ID         string    `json:"user2_id" gorm:"not null"`
	LastMessage     string    `json:"last_message"`
	LastMessageTime time.Time `json:"last_message_time"`
	UnreadCount     int       `json:"unread_count"`
	IsOnline        bool      `json:"is_online" gorm:"-"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`

	// 关联数据
	User1 User `json:"user1" gorm:"foreignKey:User1ID"`
	User2 User `json:"user2" gorm:"foreignKey:User2ID"`
}

// Message 消息模型
type Message struct {
	ID        string    `json:"id" gorm:"primaryKey"`
	ChatID    string    `json:"chat_id" gorm:"not null"`
	SenderID  string    `json:"sender_id" gorm:"not null"`
	Content   string    `json:"content" gorm:"not null"`
	Type      string    `json:"type"` // text, image, video, audio, file
	IsRead    bool      `json:"is_read"`
	CreatedAt time.Time `json:"created_at"`

	// 关联数据
	Sender User `json:"sender" gorm:"foreignKey:SenderID"`
}

// Notification 通知模型
type Notification struct {
	ID        string    `json:"id" gorm:"primaryKey"`
	UserID    string    `json:"user_id" gorm:"not null"`
	Type      string    `json:"type"` // like, comment, follow, workout, achievement, system, buddy_request
	Title     string    `json:"title" gorm:"not null"`
	Content   string    `json:"content" gorm:"not null"`
	ImageURL  string    `json:"image_url"`
	ActionURL string    `json:"action_url"`
	IsRead    bool      `json:"is_read"`
	ExtraData string    `json:"extra_data" gorm:"serializer:json"`
	CreatedAt time.Time `json:"created_at"`

	// 关联数据
	User User `json:"user" gorm:"foreignKey:UserID"`
}

// CreateChatRequest 创建聊天请求
type CreateChatRequest struct {
	UserID string `json:"user_id" binding:"required"`
}

// SendMessageRequest 发送消息请求
type SendMessageRequest struct {
	Content string `json:"content" binding:"required"`
	Type    string `json:"type"` // text, image, video, audio, file
}

// CreateNotificationRequest 创建通知请求
type CreateNotificationRequest struct {
	UserID    string `json:"user_id" binding:"required"`
	Type      string `json:"type" binding:"required"`
	Title     string `json:"title" binding:"required"`
	Content   string `json:"content" binding:"required"`
	ImageURL  string `json:"image_url"`
	ActionURL string `json:"action_url"`
	ExtraData string `json:"extra_data"`
}

// ChatResponse 聊天响应
type ChatResponse struct {
	ID              string    `json:"id"`
	User1ID         string    `json:"user1_id"`
	User2ID         string    `json:"user2_id"`
	LastMessage     string    `json:"last_message"`
	LastMessageTime time.Time `json:"last_message_time"`
	UnreadCount     int       `json:"unread_count"`
	IsOnline        bool      `json:"is_online"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
	User1           User      `json:"user1"`
	User2           User      `json:"user2"`
}

// MessageResponse 消息响应
type MessageResponse struct {
	ID        string    `json:"id"`
	ChatID    string    `json:"chat_id"`
	SenderID  string    `json:"sender_id"`
	Content   string    `json:"content"`
	Type      string    `json:"type"`
	IsRead    bool      `json:"is_read"`
	CreatedAt time.Time `json:"created_at"`
	Sender    User      `json:"sender"`
}

// NotificationResponse 通知响应
type NotificationResponse struct {
	ID        string    `json:"id"`
	UserID    string    `json:"user_id"`
	Type      string    `json:"type"`
	Title     string    `json:"title"`
	Content   string    `json:"content"`
	ImageURL  string    `json:"image_url"`
	ActionURL string    `json:"action_url"`
	IsRead    bool      `json:"is_read"`
	ExtraData string    `json:"extra_data"`
	CreatedAt time.Time `json:"created_at"`
	User      User      `json:"user"`
}

// MarkAsReadRequest 标记已读请求
type MarkAsReadRequest struct {
	MessageIDs []string `json:"message_ids"`
}

// GetMessagesRequest 获取消息请求
type GetMessagesRequest struct {
	Skip  int `json:"skip"`
	Limit int `json:"limit"`
}
