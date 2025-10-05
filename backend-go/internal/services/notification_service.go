package services

import (
	"gymates/internal/models"
	"gorm.io/gorm"
)

// NotificationService 通知服务
type NotificationService struct {
	db *gorm.DB
}

// NewNotificationService 创建通知服务
func NewNotificationService(db *gorm.DB) *NotificationService {
	return &NotificationService{
		db: db,
	}
}

// NotifyPostCreated 通知动态创建
func (s *NotificationService) NotifyPostCreated(post interface{}) {
	// 实现通知逻辑
	// 这里可以发送推送通知、站内信等
}

// NotifyPostLiked 通知动态被点赞
func (s *NotificationService) NotifyPostLiked(postID, likerID string) {
	// 实现点赞通知逻辑
	// 这里可以发送推送通知、站内信等
}

// NotifyCommentCreated 通知评论创建
func (s *NotificationService) NotifyCommentCreated(comment interface{}) {
	// 实现评论通知逻辑
	// 这里可以发送推送通知、站内信等
}

// NotifyFollowAction 通知关注操作
func (s *NotificationService) NotifyFollowAction(followerID, targetUserID string, isFollow bool) {
	// 实现关注通知逻辑
	// 这里可以发送推送通知、站内信等
}

// NotifyNewMessage 通知新消息
func (s *NotificationService) NotifyNewMessage(message interface{}) {
	// 实现新消息通知逻辑
	// 这里可以发送推送通知、站内信等
}

// NotifyGroupCreated 通知群组创建
func (s *NotificationService) NotifyGroupCreated(group interface{}) {
	// 实现群组创建通知逻辑
	// 这里可以发送推送通知、站内信等
}

// CreateNotification 创建通知
func (s *NotificationService) CreateNotification(notification *models.Notification) error {
	return s.db.Create(notification).Error
}

// GetNotifications 获取用户通知
func (s *NotificationService) GetNotifications(userID uint, page, limit int) ([]*models.Notification, int64, error) {
	var notifications []*models.Notification
	var total int64

	offset := (page - 1) * limit

	err := s.db.Model(&models.Notification{}).Where("user_id = ?", userID).Count(&total).Error
	if err != nil {
		return nil, 0, err
	}

	err = s.db.Where("user_id = ?", userID).
		Order("created_at DESC").
		Offset(offset).
		Limit(limit).
		Find(&notifications).Error

	return notifications, total, err
}

// MarkAsRead 标记通知为已读
func (s *NotificationService) MarkAsRead(notificationID uint) error {
	return s.db.Model(&models.Notification{}).Where("id = ?", notificationID).Update("is_read", true).Error
}

// MarkAllAsRead 标记所有通知为已读
func (s *NotificationService) MarkAllAsRead(userID uint) error {
	return s.db.Model(&models.Notification{}).Where("user_id = ?", userID).Update("is_read", true).Error
}
