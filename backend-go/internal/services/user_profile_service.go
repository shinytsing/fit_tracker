package services

import (
	"fmt"
	"time"

	"gymates/internal/models"
	"gymates/pkg/logger"

	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

// UserProfileService 用户资料服务
type UserProfileService struct {
	db *gorm.DB
}

// NewUserProfileService 创建用户资料服务实例
func NewUserProfileService(db *gorm.DB) *UserProfileService {
	return &UserProfileService{db: db}
}

// Register 用户注册
func (s *UserProfileService) Register(requestData models.RegisterRequest) (*models.UserResponse, error) {
	// 检查用户名是否已存在
	var existingUser models.UserProfile
	if err := s.db.Where("username = ? OR email = ?", requestData.Username, requestData.Email).First(&existingUser).Error; err == nil {
		return nil, fmt.Errorf("用户名或邮箱已存在")
	}

	// 加密密码
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(requestData.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, fmt.Errorf("密码加密失败: %v", err)
	}

	// 创建用户
	user := models.UserProfile{
		ID:             uuid.New().String(),
		Username:       requestData.Username,
		Email:          requestData.Email,
		Password:       string(hashedPassword),
		Nickname:       requestData.Nickname,
		Avatar:         "",
		Bio:            "",
		Gender:         "",
		Birthday:       time.Time{},
		Height:         0,
		Weight:         0,
		BMI:            0,
		Level:          1,
		Points:         0,
		FollowerCount:  0,
		FollowingCount: 0,
		PostCount:      0,
		IsVerified:     false,
		IsActive:       true,
		LastLoginAt:    time.Now(),
		CreatedAt:      time.Now(),
		UpdatedAt:      time.Now(),
	}

	if err := s.db.Create(&user).Error; err != nil {
		return nil, fmt.Errorf("创建用户失败: %v", err)
	}

	// 创建默认设置
	settings := models.UserSettings{
		ID:                uuid.New().String(),
		UserID:            user.ID,
		PrivacyLevel:      "public",
		NotificationEmail: true,
		NotificationPush:  true,
		NotificationSMS:   false,
		Language:          "zh-CN",
		Timezone:          "Asia/Shanghai",
		Theme:             "auto",
		CreatedAt:         time.Now(),
		UpdatedAt:         time.Now(),
	}

	if err := s.db.Create(&settings).Error; err != nil {
		logger.Error.Printf("创建用户默认设置失败", map[string]interface{}{
			"user_id": user.ID,
			"error":   err.Error(),
		})
	}

	// 创建用户统计
	stats := models.UserStats{
		ID:                 uuid.New().String(),
		UserID:             user.ID,
		TotalWorkouts:      0,
		TotalDuration:      0,
		TotalCalories:      0,
		CurrentStreak:      0,
		LongestStreak:      0,
		FavoriteExercise:   "",
		WorkoutDays:        0,
		RestDays:           0,
		AverageWorkoutTime: 0,
		LastWorkoutAt:      time.Time{},
		CreatedAt:          time.Now(),
		UpdatedAt:          time.Now(),
	}

	if err := s.db.Create(&stats).Error; err != nil {
		logger.Error.Printf("创建用户统计失败", map[string]interface{}{
			"user_id": user.ID,
			"error":   err.Error(),
		})
	}

	response := &models.UserResponse{
		ID:             user.ID,
		Username:       user.Username,
		Email:          user.Email,
		Nickname:       user.Nickname,
		Avatar:         user.Avatar,
		Bio:            user.Bio,
		Gender:         user.Gender,
		Birthday:       user.Birthday,
		Height:         user.Height,
		Weight:         user.Weight,
		BMI:            user.BMI,
		Level:          user.Level,
		Points:         user.Points,
		FollowerCount:  user.FollowerCount,
		FollowingCount: user.FollowingCount,
		PostCount:      user.PostCount,
		IsVerified:     user.IsVerified,
		IsActive:       user.IsActive,
		LastLoginAt:    user.LastLoginAt,
		CreatedAt:      user.CreatedAt,
		UpdatedAt:      user.UpdatedAt,
	}

	return response, nil
}

// Login 用户登录
func (s *UserProfileService) Login(requestData models.LoginRequest) (*models.UserResponse, error) {
	var user models.UserProfile
	if err := s.db.Where("username = ? OR email = ?", requestData.Username, requestData.Username).First(&user).Error; err != nil {
		return nil, fmt.Errorf("用户不存在")
	}

	// 验证密码
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(requestData.Password)); err != nil {
		return nil, fmt.Errorf("密码错误")
	}

	if !user.IsActive {
		return nil, fmt.Errorf("账户已被禁用")
	}

	// 更新最后登录时间
	user.LastLoginAt = time.Now()
	s.db.Save(&user)

	response := &models.UserResponse{
		ID:             user.ID,
		Username:       user.Username,
		Email:          user.Email,
		Nickname:       user.Nickname,
		Avatar:         user.Avatar,
		Bio:            user.Bio,
		Gender:         user.Gender,
		Birthday:       user.Birthday,
		Height:         user.Height,
		Weight:         user.Weight,
		BMI:            user.BMI,
		Level:          user.Level,
		Points:         user.Points,
		FollowerCount:  user.FollowerCount,
		FollowingCount: user.FollowingCount,
		PostCount:      user.PostCount,
		IsVerified:     user.IsVerified,
		IsActive:       user.IsActive,
		LastLoginAt:    user.LastLoginAt,
		CreatedAt:      user.CreatedAt,
		UpdatedAt:      user.UpdatedAt,
	}

	return response, nil
}

// GetProfile 获取用户资料
func (s *UserProfileService) GetProfile(userID string) (*models.UserResponse, error) {
	var user models.UserProfile
	if err := s.db.First(&user, "id = ?", userID).Error; err != nil {
		return nil, fmt.Errorf("用户不存在: %v", err)
	}

	response := &models.UserResponse{
		ID:             user.ID,
		Username:       user.Username,
		Email:          user.Email,
		Nickname:       user.Nickname,
		Avatar:         user.Avatar,
		Bio:            user.Bio,
		Gender:         user.Gender,
		Birthday:       user.Birthday,
		Height:         user.Height,
		Weight:         user.Weight,
		BMI:            user.BMI,
		Level:          user.Level,
		Points:         user.Points,
		FollowerCount:  user.FollowerCount,
		FollowingCount: user.FollowingCount,
		PostCount:      user.PostCount,
		IsVerified:     user.IsVerified,
		IsActive:       user.IsActive,
		LastLoginAt:    user.LastLoginAt,
		CreatedAt:      user.CreatedAt,
		UpdatedAt:      user.UpdatedAt,
	}

	return response, nil
}

// UpdateProfile 更新用户资料
func (s *UserProfileService) UpdateProfile(userID string, requestData models.UpdateProfileRequest) (*models.UserResponse, error) {
	var user models.UserProfile
	if err := s.db.First(&user, "id = ?", userID).Error; err != nil {
		return nil, fmt.Errorf("用户不存在: %v", err)
	}

	// 更新字段
	if requestData.Nickname != "" {
		user.Nickname = requestData.Nickname
	}
	if requestData.Bio != "" {
		user.Bio = requestData.Bio
	}
	if requestData.Gender != "" {
		user.Gender = requestData.Gender
	}
	if requestData.Birthday != "" {
		if birthday, err := time.Parse("2006-01-02", requestData.Birthday); err == nil {
			user.Birthday = birthday
		}
	}
	if requestData.Height > 0 {
		user.Height = requestData.Height
	}
	if requestData.Weight > 0 {
		user.Weight = requestData.Weight
		// 计算BMI
		if user.Height > 0 {
			user.BMI = user.Weight / ((user.Height / 100) * (user.Height / 100))
		}
	}

	user.UpdatedAt = time.Now()

	if err := s.db.Save(&user).Error; err != nil {
		return nil, fmt.Errorf("更新用户资料失败: %v", err)
	}

	response := &models.UserResponse{
		ID:             user.ID,
		Username:       user.Username,
		Email:          user.Email,
		Nickname:       user.Nickname,
		Avatar:         user.Avatar,
		Bio:            user.Bio,
		Gender:         user.Gender,
		Birthday:       user.Birthday,
		Height:         user.Height,
		Weight:         user.Weight,
		BMI:            user.BMI,
		Level:          user.Level,
		Points:         user.Points,
		FollowerCount:  user.FollowerCount,
		FollowingCount: user.FollowingCount,
		PostCount:      user.PostCount,
		IsVerified:     user.IsVerified,
		IsActive:       user.IsActive,
		LastLoginAt:    user.LastLoginAt,
		CreatedAt:      user.CreatedAt,
		UpdatedAt:      user.UpdatedAt,
	}

	return response, nil
}

// GetSettings 获取用户设置
func (s *UserProfileService) GetSettings(userID string) (*models.UserSettingsResponse, error) {
	var settings models.UserSettings
	if err := s.db.Where("user_id = ?", userID).First(&settings).Error; err != nil {
		return nil, fmt.Errorf("用户设置不存在: %v", err)
	}

	response := &models.UserSettingsResponse{
		ID:                settings.ID,
		UserID:            settings.UserID,
		PrivacyLevel:      settings.PrivacyLevel,
		NotificationEmail: settings.NotificationEmail,
		NotificationPush:  settings.NotificationPush,
		NotificationSMS:   settings.NotificationSMS,
		Language:          settings.Language,
		Timezone:          settings.Timezone,
		Theme:             settings.Theme,
		CreatedAt:         settings.CreatedAt.Format("2006-01-02 15:04:05"),
		UpdatedAt:         settings.UpdatedAt.Format("2006-01-02 15:04:05"),
	}

	return response, nil
}

// UpdateSettings 更新用户设置
func (s *UserProfileService) UpdateSettings(userID string, requestData models.UpdateSettingsRequest) (*models.UserSettingsResponse, error) {
	var settings models.UserSettings
	if err := s.db.Where("user_id = ?", userID).First(&settings).Error; err != nil {
		return nil, fmt.Errorf("用户设置不存在: %v", err)
	}

	// 更新字段
	if requestData.PrivacyLevel != "" {
		settings.PrivacyLevel = requestData.PrivacyLevel
	}
	settings.NotificationEmail = requestData.NotificationEmail
	settings.NotificationPush = requestData.NotificationPush
	settings.NotificationSMS = requestData.NotificationSMS
	if requestData.Language != "" {
		settings.Language = requestData.Language
	}
	if requestData.Timezone != "" {
		settings.Timezone = requestData.Timezone
	}
	if requestData.Theme != "" {
		settings.Theme = requestData.Theme
	}

	settings.UpdatedAt = time.Now()

	if err := s.db.Save(&settings).Error; err != nil {
		return nil, fmt.Errorf("更新用户设置失败: %v", err)
	}

	response := &models.UserSettingsResponse{
		ID:                settings.ID,
		UserID:            settings.UserID,
		PrivacyLevel:      settings.PrivacyLevel,
		NotificationEmail: settings.NotificationEmail,
		NotificationPush:  settings.NotificationPush,
		NotificationSMS:   settings.NotificationSMS,
		Language:          settings.Language,
		Timezone:          settings.Timezone,
		Theme:             settings.Theme,
		CreatedAt:         settings.CreatedAt.Format("2006-01-02 15:04:05"),
		UpdatedAt:         settings.UpdatedAt.Format("2006-01-02 15:04:05"),
	}

	return response, nil
}

// ChangePassword 修改密码
func (s *UserProfileService) ChangePassword(userID string, requestData models.ChangePasswordRequest) error {
	var user models.UserProfile
	if err := s.db.First(&user, "id = ?", userID).Error; err != nil {
		return fmt.Errorf("用户不存在: %v", err)
	}

	// 验证旧密码
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(requestData.OldPassword)); err != nil {
		return fmt.Errorf("旧密码错误")
	}

	// 加密新密码
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(requestData.NewPassword), bcrypt.DefaultCost)
	if err != nil {
		return fmt.Errorf("密码加密失败: %v", err)
	}

	user.Password = string(hashedPassword)
	user.UpdatedAt = time.Now()

	if err := s.db.Save(&user).Error; err != nil {
		return fmt.Errorf("修改密码失败: %v", err)
	}

	return nil
}

// GetUserStats 获取用户统计
func (s *UserProfileService) GetUserStats(userID string) (*models.UserStatsResponse, error) {
	var stats models.UserStats
	if err := s.db.Where("user_id = ?", userID).First(&stats).Error; err != nil {
		return nil, fmt.Errorf("用户统计不存在: %v", err)
	}

	response := &models.UserStatsResponse{
		ID:                 stats.ID,
		UserID:             stats.UserID,
		TotalWorkouts:      stats.TotalWorkouts,
		TotalDuration:      stats.TotalDuration,
		TotalCalories:      stats.TotalCalories,
		CurrentStreak:      stats.CurrentStreak,
		LongestStreak:      stats.LongestStreak,
		FavoriteExercise:   stats.FavoriteExercise,
		WorkoutDays:        stats.WorkoutDays,
		RestDays:           stats.RestDays,
		AverageWorkoutTime: stats.AverageWorkoutTime,
		LastWorkoutAt:      stats.LastWorkoutAt.Format("2006-01-02 15:04:05"),
		CreatedAt:          stats.CreatedAt.Format("2006-01-02 15:04:05"),
		UpdatedAt:          stats.UpdatedAt.Format("2006-01-02 15:04:05"),
	}

	return response, nil
}

// GetUserAchievements 获取用户成就
func (s *UserProfileService) GetUserAchievements(userID string, skip, limit int) ([]models.UserAchievementResponse, error) {
	var achievements []models.UserAchievement
	var responses []models.UserAchievementResponse

	if err := s.db.Where("user_id = ?", userID).
		Order("unlocked_at DESC").
		Offset(skip).Limit(limit).Find(&achievements).Error; err != nil {
		return nil, fmt.Errorf("获取用户成就失败: %v", err)
	}

	for _, achievement := range achievements {
		response := models.UserAchievementResponse{
			ID:            achievement.ID,
			UserID:        achievement.UserID,
			AchievementID: achievement.AchievementID,
			Title:         achievement.Achievement.Name,
			Description:   achievement.Achievement.Description,
			IconURL:       achievement.Achievement.Icon,
			Points:        achievement.Achievement.Points,
			UnlockedAt:    achievement.EarnedAt,
			CreatedAt:     achievement.CreatedAt,
		}
		responses = append(responses, response)
	}

	return responses, nil
}

// SearchUsers 搜索用户
func (s *UserProfileService) SearchUsers(requestData models.SearchUsersRequest) ([]models.UserResponse, error) {
	var users []models.UserProfile
	var responses []models.UserResponse

	query := s.db.Where("is_active = ?", true)

	// 搜索条件
	if requestData.Query != "" {
		query = query.Where("username LIKE ? OR nickname LIKE ? OR bio LIKE ?",
			"%"+requestData.Query+"%", "%"+requestData.Query+"%", "%"+requestData.Query+"%")
	}

	if err := query.Order("follower_count DESC").
		Offset(requestData.Offset).Limit(requestData.Limit).Find(&users).Error; err != nil {
		return nil, fmt.Errorf("搜索用户失败: %v", err)
	}

	for _, user := range users {
		response := models.UserResponse{
			ID:             user.ID,
			Username:       user.Username,
			Email:          user.Email,
			Nickname:       user.Nickname,
			Avatar:         user.Avatar,
			Bio:            user.Bio,
			Gender:         user.Gender,
			Birthday:       user.Birthday,
			Height:         user.Height,
			Weight:         user.Weight,
			BMI:            user.BMI,
			Level:          user.Level,
			Points:         user.Points,
			FollowerCount:  user.FollowerCount,
			FollowingCount: user.FollowingCount,
			PostCount:      user.PostCount,
			IsVerified:     user.IsVerified,
			IsActive:       user.IsActive,
			LastLoginAt:    user.LastLoginAt,
			CreatedAt:      user.CreatedAt,
			UpdatedAt:      user.UpdatedAt,
		}
		responses = append(responses, response)
	}

	return responses, nil
}

// FollowUser 关注用户
func (s *UserProfileService) FollowUser(followerID string, requestData models.FollowUserRequest) error {
	// 检查是否已经关注
	var existingFollow models.Follow
	if err := s.db.Where("follower_id = ? AND following_id = ?", followerID, requestData.UserID).First(&existingFollow).Error; err == nil {
		return fmt.Errorf("已经关注过该用户")
	}

	// 不能关注自己
	if followerID == requestData.UserID {
		return fmt.Errorf("不能关注自己")
	}

	// 开始事务
	tx := s.db.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// 创建关注关系
	follow := models.Follow{
		ID:          uuid.New().String(),
		FollowerID:  followerID,
		FollowingID: requestData.UserID,
		CreatedAt:   time.Now(),
	}

	if err := tx.Create(&follow).Error; err != nil {
		tx.Rollback()
		return fmt.Errorf("创建关注关系失败: %v", err)
	}

	// 更新关注者和被关注者的计数
	if err := tx.Model(&models.UserProfile{}).Where("id = ?", followerID).UpdateColumn("following_count", gorm.Expr("following_count + 1")).Error; err != nil {
		tx.Rollback()
		return fmt.Errorf("更新关注者计数失败: %v", err)
	}

	if err := tx.Model(&models.UserProfile{}).Where("id = ?", requestData.UserID).UpdateColumn("follower_count", gorm.Expr("follower_count + 1")).Error; err != nil {
		tx.Rollback()
		return fmt.Errorf("更新被关注者计数失败: %v", err)
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		return fmt.Errorf("提交事务失败: %v", err)
	}

	return nil
}

// UnfollowUser 取消关注用户
func (s *UserProfileService) UnfollowUser(followerID string, followingID string) error {
	// 检查是否已经关注
	var existingFollow models.Follow
	if err := s.db.Where("follower_id = ? AND following_id = ?", followerID, followingID).First(&existingFollow).Error; err != nil {
		return fmt.Errorf("还没有关注该用户")
	}

	// 开始事务
	tx := s.db.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// 删除关注关系
	if err := tx.Delete(&existingFollow).Error; err != nil {
		tx.Rollback()
		return fmt.Errorf("删除关注关系失败: %v", err)
	}

	// 更新关注者和被关注者的计数
	if err := tx.Model(&models.UserProfile{}).Where("id = ?", followerID).UpdateColumn("following_count", gorm.Expr("following_count - 1")).Error; err != nil {
		tx.Rollback()
		return fmt.Errorf("更新关注者计数失败: %v", err)
	}

	if err := tx.Model(&models.UserProfile{}).Where("id = ?", followingID).UpdateColumn("follower_count", gorm.Expr("follower_count - 1")).Error; err != nil {
		tx.Rollback()
		return fmt.Errorf("更新被关注者计数失败: %v", err)
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		return fmt.Errorf("提交事务失败: %v", err)
	}

	return nil
}
