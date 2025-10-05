package models

import (
	"time"
)

// BuddyRequest 搭子申请模型
type BuddyRequest struct {
	ID                 uint      `json:"id" gorm:"primaryKey,autoIncrement"`
	RequesterID        string    `json:"requester_id" gorm:"not null"`
	ReceiverID         string    `json:"receiver_id" gorm:"not null"`
	Message            string    `json:"message" gorm:"type:text"`
	Status             string    `json:"status" gorm:"default:'pending'"` // pending, accepted, rejected
	WorkoutPreferences string    `json:"workout_preferences" gorm:"type:json"`
	CreatedAt          time.Time `json:"created_at"`
	UpdatedAt          time.Time `json:"updated_at"`

	// 关联关系
	Requester User `json:"requester" gorm:"foreignKey:RequesterID"`
	Receiver  User `json:"receiver" gorm:"foreignKey:ReceiverID"`
}

// BuddyRelationship 搭子关系模型
type BuddyRelationship struct {
	ID            uint      `json:"id" gorm:"primaryKey,autoIncrement"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
	UserID        string    `json:"user_id" gorm:"not null"`
	BuddyID       string    `json:"buddy_id" gorm:"not null"`
	EstablishedAt time.Time `json:"established_at"`
	Status        string    `json:"status" gorm:"default:'active'"` // active, blocked

	// 关联关系
	User  User `json:"user" gorm:"foreignKey:UserID"`
	Buddy User `json:"buddy" gorm:"foreignKey:BuddyID"`
}

// WorkoutPreferences 训练偏好
type WorkoutPreferences struct {
	Time     string `json:"time"`     // 训练时间偏好
	Location string `json:"location"` // 训练地点偏好
	Type     string `json:"type"`     // 训练类型偏好
}

// BuddyRequestCreate 创建搭子申请请求
type BuddyRequestCreate struct {
	ReceiverID         string              `json:"receiver_id" binding:"required"`
	Message            string              `json:"message"`
	WorkoutPreferences *WorkoutPreferences `json:"workout_preferences"`
}

// BuddyRequestResponse 搭子申请响应
type BuddyRequestResponse struct {
	ID                 uint                `json:"id"`
	RequesterID        string              `json:"requester_id"`
	ReceiverID         string              `json:"receiver_id"`
	Message            string              `json:"message"`
	Status             string              `json:"status"`
	WorkoutPreferences *WorkoutPreferences `json:"workout_preferences"`
	CreatedAt          time.Time           `json:"created_at"`
	UpdatedAt          time.Time           `json:"updated_at"`
	Requester          *User               `json:"requester"`
	Receiver           *User               `json:"receiver"`
}

// BuddyRecommendationResponse 搭子推荐响应
type BuddyRecommendationResponse struct {
	User               User                `json:"user"`
	MatchScore         int                 `json:"match_score"`
	MatchReasons       []string            `json:"match_reasons"`
	WorkoutPreferences *WorkoutPreferences `json:"workout_preferences"`
}

// BuddyResponse 搭子关系响应
type BuddyResponse struct {
	ID            uint      `json:"id"`
	UserID        string    `json:"user_id"`
	BuddyID       string    `json:"buddy_id"`
	EstablishedAt time.Time `json:"established_at"`
	Status        string    `json:"status"`
	User          *User     `json:"user"`
	Buddy         *User     `json:"buddy"`
}

// BuddyUpdateRequest 更新搭子关系请求
type BuddyUpdateRequest struct {
	Status  string `json:"status"` // accepted, rejected, blocked
	Message string `json:"message"`
}
