package models

import (
	"time"
)

// UserProfile 用户详细信息模型（扩展）
type UserProfile struct {
	ID             string    `json:"id" gorm:"primaryKey"`
	Username       string    `json:"username" gorm:"uniqueIndex;not null"`
	Email          string    `json:"email" gorm:"uniqueIndex;not null"`
	Password       string    `json:"-" gorm:"not null"`
	Nickname       string    `json:"nickname"`
	Avatar         string    `json:"avatar"`
	Bio            string    `json:"bio"`
	Gender         string    `json:"gender"`
	Birthday       time.Time `json:"birthday"`
	Height         float64   `json:"height"` // cm
	Weight         float64   `json:"weight"` // kg
	BMI            float64   `json:"bmi"`
	Level          int       `json:"level"`  // 用户等级
	Points         int       `json:"points"` // 积分
	FollowerCount  int       `json:"follower_count"`
	FollowingCount int       `json:"following_count"`
	PostCount      int       `json:"post_count"`
	IsVerified     bool      `json:"is_verified"`
	IsActive       bool      `json:"is_active"`
	LastLoginAt    time.Time `json:"last_login_at"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}

// UserSettings 用户设置模型
type UserSettings struct {
	ID                string    `json:"id" gorm:"primaryKey"`
	UserID            string    `json:"user_id" gorm:"not null"`
	PrivacyLevel      string    `json:"privacy_level"` // public, friends, private
	NotificationEmail bool      `json:"notification_email"`
	NotificationPush  bool      `json:"notification_push"`
	NotificationSMS   bool      `json:"notification_sms"`
	Language          string    `json:"language"`
	Timezone          string    `json:"timezone"`
	Theme             string    `json:"theme"` // light, dark, auto
	CreatedAt         time.Time `json:"created_at"`
	UpdatedAt         time.Time `json:"updated_at"`

	// 关联数据
	User User `json:"user" gorm:"foreignKey:UserID"`
}

// UserProfileResponse 用户资料响应
type UserProfileResponse struct {
	ID             string    `json:"id"`
	Username       string    `json:"username"`
	Email          string    `json:"email"`
	Nickname       string    `json:"nickname"`
	Avatar         string    `json:"avatar"`
	Bio            string    `json:"bio"`
	Gender         string    `json:"gender"`
	Birthday       time.Time `json:"birthday"`
	Height         float64   `json:"height"`
	Weight         float64   `json:"weight"`
	BMI            float64   `json:"bmi"`
	Level          int       `json:"level"`
	Points         int       `json:"points"`
	FollowerCount  int       `json:"follower_count"`
	FollowingCount int       `json:"following_count"`
	PostCount      int       `json:"post_count"`
	IsVerified     bool      `json:"is_verified"`
	IsActive       bool      `json:"is_active"`
	LastLoginAt    time.Time `json:"last_login_at"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}

// UpdateUserProfileRequest 更新用户资料请求
type UpdateUserProfileRequest struct {
	Nickname string  `json:"nickname"`
	Bio      string  `json:"bio"`
	Gender   string  `json:"gender"`
	Birthday string  `json:"birthday"`
	Height   float64 `json:"height"`
	Weight   float64 `json:"weight"`
	Avatar   string  `json:"avatar"`
}

// ChangePasswordRequest 修改密码请求
type ChangePasswordRequest struct {
	OldPassword string `json:"old_password" binding:"required"`
	NewPassword string `json:"new_password" binding:"required,min=6"`
}

// ChangePasswordResponse 修改密码响应
type ChangePasswordResponse struct {
	Message string `json:"message"`
}

// UpdateUserSettingsRequest 更新用户设置请求
type UpdateUserSettingsRequest struct {
	PrivacyLevel      string `json:"privacy_level"`
	NotificationEmail bool   `json:"notification_email"`
	NotificationPush  bool   `json:"notification_push"`
	NotificationSMS   bool   `json:"notification_sms"`
	Language          string `json:"language"`
	Timezone          string `json:"timezone"`
	Theme             string `json:"theme"`
}

// UpdateUserSettingsResponse 更新用户设置响应
type UpdateUserSettingsResponse struct {
	Message string `json:"message"`
}

// UserProfileSearchRequest 用户搜索请求
type UserProfileSearchRequest struct {
	Query  string `json:"query"`
	Limit  int    `json:"limit"`
	Offset int    `json:"offset"`
}

// UserProfileSearchResponse 用户搜索响应
type UserProfileSearchResponse struct {
	Users  []UserProfileResponse `json:"users"`
	Total  int                   `json:"total"`
	Limit  int                   `json:"limit"`
	Offset int                   `json:"offset"`
}

// UserProfileStatsRequest 用户统计请求
type UserProfileStatsRequest struct {
	UserID string `json:"user_id" binding:"required"`
	Period string `json:"period"` // week, month, year, all
}

// UserProfileStatsResponse 用户统计响应
type UserProfileStatsResponse struct {
	UserID             string `json:"user_id"`
	TotalWorkouts      int    `json:"total_workouts"`
	TotalDuration      int    `json:"total_duration"`
	TotalCalories      int    `json:"total_calories"`
	CurrentStreak      int    `json:"current_streak"`
	LongestStreak      int    `json:"longest_streak"`
	FavoriteExercise   string `json:"favorite_exercise"`
	WorkoutDays        int    `json:"workout_days"`
	RestDays           int    `json:"rest_days"`
	AverageWorkoutTime int    `json:"average_workout_time"`
	LastWorkoutAt      string `json:"last_workout_at"`
	Period             string `json:"period"`
}

// UserProfileActivityRequest 用户活动请求
type UserProfileActivityRequest struct {
	UserID string `json:"user_id" binding:"required"`
	Limit  int    `json:"limit"`
	Offset int    `json:"offset"`
}

// UserProfileActivityResponse 用户活动响应
type UserProfileActivityResponse struct {
	Activities []UserActivity `json:"activities"`
	Total      int            `json:"total"`
	Limit      int            `json:"limit"`
	Offset     int            `json:"offset"`
}

// UserActivity 用户活动模型
type UserActivity struct {
	ID        string    `json:"id" gorm:"primaryKey"`
	UserID    string    `json:"user_id" gorm:"not null"`
	Type      string    `json:"type"` // workout, achievement, social, system
	Title     string    `json:"title"`
	Content   string    `json:"content"`
	ImageURL  string    `json:"image_url"`
	ActionURL string    `json:"action_url"`
	CreatedAt time.Time `json:"created_at"`

	// 关联数据
	User User `json:"user" gorm:"foreignKey:UserID"`
}

// UserProfileFollowRequest 关注用户请求
type UserProfileFollowRequest struct {
	UserID string `json:"user_id" binding:"required"`
}

// UserProfileFollowResponse 关注用户响应
type UserProfileFollowResponse struct {
	Message string `json:"message"`
}

// UserProfileUnfollowRequest 取消关注用户请求
type UserProfileUnfollowRequest struct {
	UserID string `json:"user_id" binding:"required"`
}

// UserProfileUnfollowResponse 取消关注用户响应
type UserProfileUnfollowResponse struct {
	Message string `json:"message"`
}

// UserProfileFollowersRequest 获取关注者请求
type UserProfileFollowersRequest struct {
	UserID string `json:"user_id" binding:"required"`
	Limit  int    `json:"limit"`
	Offset int    `json:"offset"`
}

// UserProfileFollowersResponse 获取关注者响应
type UserProfileFollowersResponse struct {
	Followers []UserProfileResponse `json:"followers"`
	Total     int                   `json:"total"`
	Limit     int                   `json:"limit"`
	Offset    int                   `json:"offset"`
}

// UserProfileFollowingRequest 获取关注列表请求
type UserProfileFollowingRequest struct {
	UserID string `json:"user_id" binding:"required"`
	Limit  int    `json:"limit"`
	Offset int    `json:"offset"`
}

// UserProfileFollowingResponse 获取关注列表响应
type UserProfileFollowingResponse struct {
	Following []UserProfileResponse `json:"following"`
	Total     int                   `json:"total"`
	Limit     int                   `json:"limit"`
	Offset    int                   `json:"offset"`
}

// UserProfileBlockRequest 屏蔽用户请求
type UserProfileBlockRequest struct {
	UserID string `json:"user_id" binding:"required"`
}

// UserProfileBlockResponse 屏蔽用户响应
type UserProfileBlockResponse struct {
	Message string `json:"message"`
}

// UserProfileUnblockRequest 取消屏蔽用户请求
type UserProfileUnblockRequest struct {
	UserID string `json:"user_id" binding:"required"`
}

// UserProfileUnblockResponse 取消屏蔽用户响应
type UserProfileUnblockResponse struct {
	Message string `json:"message"`
}

// UserProfileReportRequest 举报用户请求
type UserProfileReportRequest struct {
	UserID      string `json:"user_id" binding:"required"`
	Reason      string `json:"reason" binding:"required"`
	Description string `json:"description"`
}

// UserProfileReportResponse 举报用户响应
type UserProfileReportResponse struct {
	Message string `json:"message"`
}

// UserProfileDeleteRequest 删除用户请求
type UserProfileDeleteRequest struct {
	Password string `json:"password" binding:"required"`
}

// UserProfileDeleteResponse 删除用户响应
type UserProfileDeleteResponse struct {
	Message string `json:"message"`
}
