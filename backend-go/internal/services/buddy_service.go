package services

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"time"

	"gymates/internal/models"
	"gymates/pkg/logger"

	"gorm.io/gorm"
)

// BuddyService 搭子服务
type BuddyService struct {
	db *gorm.DB
}

// NewBuddyService 创建搭子服务实例
func NewBuddyService(db *gorm.DB) *BuddyService {
	return &BuddyService{db: db}
}

// GetBuddyRecommendations 获取搭子推荐列表
func (s *BuddyService) GetBuddyRecommendations(userID string, skip, limit int) ([]models.BuddyRecommendationResponse, error) {
	var users []models.User
	var recommendations []models.BuddyRecommendationResponse

	// 查询用户信息
	if err := s.db.First(&models.User{}, "id = ?", userID).Error; err != nil {
		return nil, fmt.Errorf("用户不存在: %v", err)
	}

	// 获取推荐用户（这里使用模拟数据，实际应该基于算法推荐）
	if err := s.db.Where("id != ?", userID).
		Offset(skip).Limit(limit).Find(&users).Error; err != nil {
		return nil, fmt.Errorf("获取推荐用户失败: %v", err)
	}

	// 生成推荐数据
	for _, user := range users {
		recommendation := models.BuddyRecommendationResponse{
			User:       user,
			MatchScore: rand.Intn(100) + 1, // 1-100的匹配分数
			MatchReasons: []string{
				"相似的训练目标",
				"相同的训练时间",
				"相近的健身水平",
			},
			WorkoutPreferences: &models.WorkoutPreferences{
				Time:     "晚上7-9点",
				Location: "健身房",
				Type:     "力量训练",
			},
		}
		recommendations = append(recommendations, recommendation)
	}

	return recommendations, nil
}

// RequestBuddy 发送搭子申请
func (s *BuddyService) RequestBuddy(requesterID string, requestData models.BuddyRequestCreate) (*models.BuddyRequestResponse, error) {
	// 检查是否已经存在申请
	var existingRequest models.BuddyRequest
	if err := s.db.Where("requester_id = ? AND receiver_id = ?", requesterID, requestData.ReceiverID).
		First(&existingRequest).Error; err == nil {
		return nil, fmt.Errorf("已经发送过申请")
	}

	// 检查是否已经是搭子
	var existingRelationship models.BuddyRelationship
	if err := s.db.Where("(user_id = ? AND buddy_id = ?) OR (user_id = ? AND buddy_id = ?)",
		requesterID, requestData.ReceiverID, requestData.ReceiverID, requesterID).
		First(&existingRelationship).Error; err == nil {
		return nil, fmt.Errorf("已经是搭子关系")
	}

	// 创建申请
	preferencesJSON, _ := json.Marshal(requestData.WorkoutPreferences)
	request := models.BuddyRequest{
		RequesterID:        requesterID,
		ReceiverID:         requestData.ReceiverID,
		Message:            requestData.Message,
		Status:             "pending",
		WorkoutPreferences: string(preferencesJSON),
		CreatedAt:          time.Now(),
		UpdatedAt:          time.Now(),
	}

	if err := s.db.Create(&request).Error; err != nil {
		return nil, fmt.Errorf("创建申请失败: %v", err)
	}

	// 获取申请者和接收者信息
	var requester, receiver models.User
	s.db.First(&requester, "id = ?", requesterID)
	s.db.First(&receiver, "id = ?", requestData.ReceiverID)

	var preferences *models.WorkoutPreferences
	if requestData.WorkoutPreferences != nil {
		preferences = requestData.WorkoutPreferences
	}

	response := &models.BuddyRequestResponse{
		ID:                 request.ID,
		RequesterID:        request.RequesterID,
		ReceiverID:         request.ReceiverID,
		Message:            request.Message,
		Status:             request.Status,
		WorkoutPreferences: preferences,
		CreatedAt:          request.CreatedAt,
		UpdatedAt:          request.UpdatedAt,
		Requester:          &requester,
		Receiver:           &receiver,
	}

	return response, nil
}

// GetBuddyRequests 获取搭子申请列表
func (s *BuddyService) GetBuddyRequests(userID string, requestType string, skip, limit int) ([]models.BuddyRequestResponse, error) {
	var requests []models.BuddyRequest
	var responses []models.BuddyRequestResponse

	query := s.db.Preload("Requester").Preload("Receiver")

	if requestType == "received" {
		query = query.Where("receiver_id = ?", userID)
	} else if requestType == "sent" {
		query = query.Where("requester_id = ?", userID)
	}

	if err := query.Offset(skip).Limit(limit).Find(&requests).Error; err != nil {
		return nil, fmt.Errorf("获取申请列表失败: %v", err)
	}

	for _, request := range requests {
		var preferences *models.WorkoutPreferences
		if request.WorkoutPreferences != "" {
			json.Unmarshal([]byte(request.WorkoutPreferences), &preferences)
		}

		response := models.BuddyRequestResponse{
			ID:                 request.ID,
			RequesterID:        request.RequesterID,
			ReceiverID:         request.ReceiverID,
			Message:            request.Message,
			Status:             request.Status,
			WorkoutPreferences: preferences,
			CreatedAt:          request.CreatedAt,
			UpdatedAt:          request.UpdatedAt,
			Requester:          &request.Requester,
			Receiver:           &request.Receiver,
		}
		responses = append(responses, response)
	}

	return responses, nil
}

// AcceptBuddyRequest 接受搭子申请
func (s *BuddyService) AcceptBuddyRequest(requestID uint, userID string, message string) (*models.BuddyRequestResponse, error) {
	var request models.BuddyRequest
	if err := s.db.Preload("Requester").Preload("Receiver").
		First(&request, "id = ? AND receiver_id = ?", requestID, userID).Error; err != nil {
		return nil, fmt.Errorf("申请不存在或无权限: %v", err)
	}

	if request.Status != "pending" {
		return nil, fmt.Errorf("申请状态不正确")
	}

	// 开始事务
	tx := s.db.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// 更新申请状态
	request.Status = "accepted"
	request.UpdatedAt = time.Now()
	if err := tx.Save(&request).Error; err != nil {
		tx.Rollback()
		return nil, fmt.Errorf("更新申请状态失败: %v", err)
	}

	// 创建搭子关系
	relationship1 := models.BuddyRelationship{
		UserID:        request.RequesterID,
		BuddyID:       request.ReceiverID,
		EstablishedAt: time.Now(),
		Status:        "active",
		CreatedAt:     time.Now(),
		UpdatedAt:     time.Now(),
	}

	relationship2 := models.BuddyRelationship{
		UserID:        request.ReceiverID,
		BuddyID:       request.RequesterID,
		EstablishedAt: time.Now(),
		Status:        "active",
		CreatedAt:     time.Now(),
		UpdatedAt:     time.Now(),
	}

	if err := tx.Create(&relationship1).Error; err != nil {
		tx.Rollback()
		return nil, fmt.Errorf("创建搭子关系失败: %v", err)
	}

	if err := tx.Create(&relationship2).Error; err != nil {
		tx.Rollback()
		return nil, fmt.Errorf("创建搭子关系失败: %v", err)
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		return nil, fmt.Errorf("提交事务失败: %v", err)
	}

	var preferences *models.WorkoutPreferences
	if request.WorkoutPreferences != "" {
		json.Unmarshal([]byte(request.WorkoutPreferences), &preferences)
	}

	response := &models.BuddyRequestResponse{
		ID:                 request.ID,
		RequesterID:        request.RequesterID,
		ReceiverID:         request.ReceiverID,
		Message:            request.Message,
		Status:             request.Status,
		WorkoutPreferences: preferences,
		CreatedAt:          request.CreatedAt,
		UpdatedAt:          request.UpdatedAt,
		Requester:          &request.Requester,
		Receiver:           &request.Receiver,
	}

	return response, nil
}

// RejectBuddyRequest 拒绝搭子申请
func (s *BuddyService) RejectBuddyRequest(requestID uint, userID string, reason string) (*models.BuddyRequestResponse, error) {
	var request models.BuddyRequest
	if err := s.db.Preload("Requester").Preload("Receiver").
		First(&request, "id = ? AND receiver_id = ?", requestID, userID).Error; err != nil {
		return nil, fmt.Errorf("申请不存在或无权限: %v", err)
	}

	if request.Status != "pending" {
		return nil, fmt.Errorf("申请状态不正确")
	}

	request.Status = "rejected"
	request.UpdatedAt = time.Now()
	if err := s.db.Save(&request).Error; err != nil {
		return nil, fmt.Errorf("更新申请状态失败: %v", err)
	}

	var preferences *models.WorkoutPreferences
	if request.WorkoutPreferences != "" {
		json.Unmarshal([]byte(request.WorkoutPreferences), &preferences)
	}

	response := &models.BuddyRequestResponse{
		ID:                 request.ID,
		RequesterID:        request.RequesterID,
		ReceiverID:         request.ReceiverID,
		Message:            request.Message,
		Status:             request.Status,
		WorkoutPreferences: preferences,
		CreatedAt:          request.CreatedAt,
		UpdatedAt:          request.UpdatedAt,
		Requester:          &request.Requester,
		Receiver:           &request.Receiver,
	}

	return response, nil
}

// GetMyBuddies 获取我的搭子列表
func (s *BuddyService) GetMyBuddies(userID string, skip, limit int) ([]models.BuddyResponse, error) {
	var relationships []models.BuddyRelationship
	var responses []models.BuddyResponse

	if err := s.db.Preload("Buddy").
		Where("user_id = ? AND status = ?", userID, "active").
		Offset(skip).Limit(limit).Find(&relationships).Error; err != nil {
		return nil, fmt.Errorf("获取搭子列表失败: %v", err)
	}

	for _, rel := range relationships {
		response := models.BuddyResponse{
			ID:            rel.ID,
			UserID:        rel.UserID,
			BuddyID:       rel.BuddyID,
			EstablishedAt: rel.EstablishedAt,
			Status:        rel.Status,
			Buddy:         &rel.Buddy,
		}
		responses = append(responses, response)
	}

	return responses, nil
}

// DeleteBuddy 删除搭子关系
func (s *BuddyService) DeleteBuddy(userID string, buddyID string) error {
	// 开始事务
	tx := s.db.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// 删除双向关系
	if err := tx.Where("user_id = ? AND buddy_id = ?", userID, buddyID).Delete(&models.BuddyRelationship{}).Error; err != nil {
		tx.Rollback()
		return fmt.Errorf("删除搭子关系失败: %v", err)
	}

	if err := tx.Where("user_id = ? AND buddy_id = ?", buddyID, userID).Delete(&models.BuddyRelationship{}).Error; err != nil {
		tx.Rollback()
		return fmt.Errorf("删除搭子关系失败: %v", err)
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		return fmt.Errorf("提交事务失败: %v", err)
	}

	logger.Info.Printf("搭子关系删除成功: user_id=%s, buddy_id=%s", userID, buddyID)

	return nil
}
