package services

import (
	"context"
	"errors"
	"fmt"
	"time"

	"gymates/internal/models"

	"github.com/go-redis/redis/v8"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type UserService struct {
	db    *gorm.DB
	redis *redis.Client
}

func NewUserService(db *gorm.DB, redis *redis.Client) *UserService {
	return &UserService{
		db:    db,
		redis: redis,
	}
}

// Register 用户注册
func (s *UserService) Register(req *models.RegisterRequest) (*models.User, error) {
	// 检查用户名是否已存在
	var existingUser models.User
	if err := s.db.Where("username = ? OR email = ?", req.Username, req.Email).First(&existingUser).Error; err == nil {
		return nil, errors.New("用户名或邮箱已存在")
	}

	// 加密密码
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, fmt.Errorf("密码加密失败: %w", err)
	}

	// 创建用户对象
	user := &models.User{
		ID:        fmt.Sprintf("user_%d", time.Now().Unix()),
		Username:  req.Username,
		Email:     req.Email,
		Password:  string(hashedPassword),
		Nickname:  req.Nickname,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	// 使用 GORM 创建用户
	if err := s.db.Create(user).Error; err != nil {
		return nil, fmt.Errorf("创建用户失败: %w", err)
	}

	return user, nil
}

// Login 用户登录
func (s *UserService) Login(req *models.LoginRequest) (*models.User, error) {
	var user models.User
	// 支持用户名、邮箱、手机号登录
	if err := s.db.Where("username = ? OR email = ? OR phone = ?", req.Username, req.Username, req.Username).First(&user).Error; err != nil {
		return nil, errors.New("用户名或密码错误")
	}

	// 验证密码
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		return nil, errors.New("用户名或密码错误")
	}

	return &user, nil
}

// GetByID 根据ID获取用户
func (s *UserService) GetByID(userID uint) (*models.User, error) {
	var user models.User
	if err := s.db.First(&user, userID).Error; err != nil {
		return nil, fmt.Errorf("用户不存在: %w", err)
	}
	return &user, nil
}

// UpdateProfile 更新用户资料
func (s *UserService) UpdateProfile(userID uint, req *models.UpdateProfileRequest) error {
	updates := map[string]interface{}{
		"nickname": req.Nickname,
		"bio":      req.Bio,
		"gender":   req.Gender,
	}

	if req.Birthday != "" {
		if birthday, err := time.Parse("2006-01-02", req.Birthday); err == nil {
			updates["birthday"] = birthday
		}
	}

	return s.db.Model(&models.User{}).Where("id = ?", userID).Updates(updates).Error
}

// UploadAvatar 上传头像
func (s *UserService) UploadAvatar(userID uint, avatarURL string) error {
	return s.db.Model(&models.User{}).Where("id = ?", userID).Update("avatar", avatarURL).Error
}

// AuthenticateUser 用户认证
func (s *UserService) AuthenticateUser(login, password string) (*models.User, error) {
	var user models.User

	// 先尝试从缓存获取
	if cachedUser := s.getCachedUser(login); cachedUser != nil {
		if err := bcrypt.CompareHashAndPassword([]byte(cachedUser.Password), []byte(password)); err == nil {
			return cachedUser, nil
		}
	}

	// 从数据库查询
	if err := s.db.Where("username = ? OR email = ?", login, login).First(&user).Error; err != nil {
		return nil, errors.New("invalid credentials")
	}

	// 验证密码
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(password)); err != nil {
		return nil, errors.New("invalid credentials")
	}

	// 缓存用户信息
	s.cacheUser(&user)

	return &user, nil
}

// GetUserByID 根据ID获取用户
func (s *UserService) GetUserByID(id uint) (*models.User, error) {
	var user models.User

	// 先尝试从缓存获取
	if cachedUser := s.getCachedUserByID(id); cachedUser != nil {
		return cachedUser, nil
	}

	// 从数据库查询
	if err := s.db.Preload("Posts").Preload("WorkoutPlans").First(&user, id).Error; err != nil {
		return nil, fmt.Errorf("user not found: %w", err)
	}

	// 缓存用户信息
	s.cacheUser(&user)

	return &user, nil
}

// UpdateUser 更新用户信息
func (s *UserService) UpdateUser(id uint, updates interface{}) (*models.User, error) {
	var user models.User
	if err := s.db.First(&user, id).Error; err != nil {
		return nil, fmt.Errorf("user not found: %w", err)
	}

	if err := s.db.Model(&user).Updates(updates).Error; err != nil {
		return nil, fmt.Errorf("failed to update user: %w", err)
	}

	// 更新缓存
	s.cacheUser(&user)

	return &user, nil
}

// FollowUser 关注用户
func (s *UserService) FollowUser(userID, followingID uint) error {
	// 检查是否已经关注
	var follow models.Follow
	if err := s.db.Where("user_id = ? AND following_id = ?", userID, followingID).First(&follow).Error; err == nil {
		return errors.New("already following this user")
	}

	// 创建关注关系
	follow = models.Follow{
		ID:          fmt.Sprintf("follow_%d_%d", userID, followingID),
		FollowerID:  fmt.Sprintf("%d", userID),
		FollowingID: fmt.Sprintf("%d", followingID),
	}

	if err := s.db.Create(&follow).Error; err != nil {
		return fmt.Errorf("failed to follow user: %w", err)
	}

	// 更新缓存
	s.invalidateUserCache(userID)
	s.invalidateUserCache(followingID)

	return nil
}

// UnfollowUser 取消关注用户
func (s *UserService) UnfollowUser(userID, followingID uint) error {
	if err := s.db.Where("user_id = ? AND following_id = ?", userID, followingID).Delete(&models.Follow{}).Error; err != nil {
		return fmt.Errorf("failed to unfollow user: %w", err)
	}

	// 更新缓存
	s.invalidateUserCache(userID)
	s.invalidateUserCache(followingID)

	return nil
}

// GetFollowers 获取关注者列表
func (s *UserService) GetFollowers(userID uint, page, limit int) ([]models.User, int64, error) {
	var followers []models.User
	var total int64

	offset := (page - 1) * limit

	// 获取总数
	if err := s.db.Model(&models.Follow{}).Where("following_id = ?", userID).Count(&total).Error; err != nil {
		return nil, 0, fmt.Errorf("failed to count followers: %w", err)
	}

	// 获取关注者列表
	if err := s.db.Table("users").
		Joins("JOIN follows ON users.uid = follows.user_id").
		Where("follows.following_id = ?", userID).
		Offset(offset).
		Limit(limit).
		Find(&followers).Error; err != nil {
		return nil, 0, fmt.Errorf("failed to get followers: %w", err)
	}

	return followers, total, nil
}

// GetFollowing 获取关注列表
func (s *UserService) GetFollowing(userID uint, page, limit int) ([]models.User, int64, error) {
	var following []models.User
	var total int64

	offset := (page - 1) * limit

	// 获取总数
	if err := s.db.Model(&models.Follow{}).Where("user_id = ?", userID).Count(&total).Error; err != nil {
		return nil, 0, fmt.Errorf("failed to count following: %w", err)
	}

	// 获取关注列表
	if err := s.db.Table("users").
		Joins("JOIN follows ON users.uid = follows.following_id").
		Where("follows.user_id = ?", userID).
		Offset(offset).
		Limit(limit).
		Find(&following).Error; err != nil {
		return nil, 0, fmt.Errorf("failed to get following: %w", err)
	}

	return following, total, nil
}

// 缓存相关方法
func (s *UserService) cacheUser(user *models.User) {
	ctx := context.Background()
	key := fmt.Sprintf("user:%d", user.ID)
	keyByUsername := fmt.Sprintf("user:username:%s", user.Username)
	keyByEmail := fmt.Sprintf("user:email:%s", user.Email)

	// 缓存用户信息（不包含密码）
	userData := map[string]interface{}{
		"id":          user.ID,
		"username":    user.Username,
		"email":       user.Email,
		"nickname":    user.Nickname,
		"avatar":      user.Avatar,
		"bio":         user.Bio,
		"gender":      user.Gender,
		"is_verified": user.IsVerified,
		"created_at":  user.CreatedAt,
		"updated_at":  user.UpdatedAt,
	}

	s.redis.HMSet(ctx, key, userData)
	s.redis.HMSet(ctx, keyByUsername, userData)
	s.redis.HMSet(ctx, keyByEmail, userData)
	s.redis.Expire(ctx, key, time.Hour)
	s.redis.Expire(ctx, keyByUsername, time.Hour)
	s.redis.Expire(ctx, keyByEmail, time.Hour)
}

func (s *UserService) getCachedUser(login string) *models.User {
	ctx := context.Background()
	keyByUsername := fmt.Sprintf("user:username:%s", login)
	keyByEmail := fmt.Sprintf("user:email:%s", login)

	// 尝试通过用户名获取
	if userData := s.redis.HGetAll(ctx, keyByUsername).Val(); len(userData) > 0 {
		return s.mapToUser(userData)
	}

	// 尝试通过邮箱获取
	if userData := s.redis.HGetAll(ctx, keyByEmail).Val(); len(userData) > 0 {
		return s.mapToUser(userData)
	}

	return nil
}

func (s *UserService) getCachedUserByID(id uint) *models.User {
	ctx := context.Background()
	key := fmt.Sprintf("user:%d", id)

	if userData := s.redis.HGetAll(ctx, key).Val(); len(userData) > 0 {
		return s.mapToUser(userData)
	}

	return nil
}

func (s *UserService) invalidateUserCache(userID uint) {
	ctx := context.Background()
	keys := []string{
		fmt.Sprintf("user:%d", userID),
	}

	// 获取用户信息以删除用户名和邮箱的缓存
	var user models.User
	if err := s.db.First(&user, userID).Error; err == nil {
		keys = append(keys, fmt.Sprintf("user:username:%s", user.Username))
		keys = append(keys, fmt.Sprintf("user:email:%s", user.Email))
	}

	s.redis.Del(ctx, keys...)
}

func (s *UserService) mapToUser(data map[string]string) *models.User {
	// 这里需要将map转换为User结构体
	// 为了简化，这里返回nil，实际实现中需要完整的转换逻辑
	return nil
}
