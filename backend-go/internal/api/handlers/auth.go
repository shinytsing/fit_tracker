package handlers

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"net/http"
	"time"

	"fittracker/backend/internal/api/middleware"
	"fittracker/backend/internal/domain/models"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

// RegisterRequest 注册请求
type RegisterRequest struct {
	Username  string `json:"username" binding:"required,min=3,max=20"`
	Email     string `json:"email" binding:"required,email"`
	Password  string `json:"password" binding:"required,min=6"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
}

// LoginRequest 登录请求
type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

// AuthResponse 认证响应
type AuthResponse struct {
	Token     string       `json:"token"`
	User      *models.User `json:"user"`
	ExpiresAt time.Time    `json:"expires_at"`
}

// Register 用户注册
func (h *Handlers) Register(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "请求参数错误",
			"code":    "INVALID_REQUEST",
			"details": err.Error(),
		})
		return
	}

	// 检查用户名是否已存在
	var existingUser models.User
	if err := h.DB.Where("username = ? OR email = ?", req.Username, req.Email).First(&existingUser).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{
			"error": "用户名或邮箱已存在",
			"code":  "USER_EXISTS",
		})
		return
	}

	// 加密密码
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "密码加密失败",
			"code":  "PASSWORD_ENCRYPTION_ERROR",
		})
		return
	}

	// 创建用户
	user := &models.User{
		Username:     req.Username,
		Email:        req.Email,
		PasswordHash: string(hashedPassword),
		FirstName:    req.FirstName,
		LastName:     req.LastName,
	}

	if err := h.DB.Create(user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "用户创建失败",
			"code":  "USER_CREATION_ERROR",
		})
		return
	}

	// 生成Token
	token, err := middleware.GenerateToken(user.ID, user.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Token生成失败",
			"code":  "TOKEN_GENERATION_ERROR",
		})
		return
	}

	// 存储Token到Redis
	if h.Cache != nil {
		h.Cache.SetUserToken(token, user.ID)
	}

	// 清除密码哈希
	user.PasswordHash = ""

	c.JSON(http.StatusCreated, gin.H{
		"message": "注册成功",
		"data": AuthResponse{
			Token:     token,
			User:      user,
			ExpiresAt: time.Now().Add(24 * time.Hour),
		},
	})
}

// Login 用户登录
func (h *Handlers) Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "请求参数错误",
			"code":    "INVALID_REQUEST",
			"details": err.Error(),
		})
		return
	}

	// 查找用户
	var user models.User
	if err := h.DB.Where("email = ?", req.Email).First(&user).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusUnauthorized, gin.H{
				"error": "邮箱或密码错误",
				"code":  "INVALID_CREDENTIALS",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "数据库查询失败",
			"code":  "DATABASE_ERROR",
		})
		return
	}

	// 验证密码
	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "邮箱或密码错误",
			"code":  "INVALID_CREDENTIALS",
		})
		return
	}

	// 生成Token
	token, err := middleware.GenerateToken(user.ID, user.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Token生成失败",
			"code":  "TOKEN_GENERATION_ERROR",
		})
		return
	}

	// 存储Token到Redis
	if h.Cache != nil {
		h.Cache.SetUserToken(token, user.ID)
	}

	// 清除密码哈希
	user.PasswordHash = ""

	c.JSON(http.StatusOK, gin.H{
		"message": "登录成功",
		"data": AuthResponse{
			Token:     token,
			User:      &user,
			ExpiresAt: time.Now().Add(24 * time.Hour),
		},
	})
}

// Logout 用户登出
func (h *Handlers) Logout(c *gin.Context) {
	// 获取Token
	authHeader := c.GetHeader("Authorization")
	if authHeader == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "缺少认证令牌",
			"code":  "MISSING_TOKEN",
		})
		return
	}

	tokenString := authHeader[7:] // 移除"Bearer "前缀

	// 从Redis中删除Token
	if h.Cache != nil {
		h.Cache.DeleteUserToken(tokenString)
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "登出成功",
	})
}

// RefreshToken 刷新Token
func (h *Handlers) RefreshToken(c *gin.Context) {
	// 获取当前用户ID
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "未认证用户",
			"code":  "UNAUTHENTICATED",
		})
		return
	}

	// 查找用户
	var user models.User
	if err := h.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "用户不存在",
			"code":  "USER_NOT_FOUND",
		})
		return
	}

	// 生成新Token
	token, err := middleware.GenerateToken(user.ID, user.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Token生成失败",
			"code":  "TOKEN_GENERATION_ERROR",
		})
		return
	}

	// 存储新Token到Redis
	if h.Cache != nil {
		h.Cache.SetUserToken(token, user.ID)
	}

	// 清除密码哈希
	user.PasswordHash = ""

	c.JSON(http.StatusOK, gin.H{
		"message": "Token刷新成功",
		"data": AuthResponse{
			Token:     token,
			User:      &user,
			ExpiresAt: time.Now().Add(24 * time.Hour),
		},
	})
}

// GetProfile 获取用户资料
func (h *Handlers) GetProfile(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "未认证用户",
			"code":  "UNAUTHENTICATED",
		})
		return
	}

	var user models.User
	if err := h.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "用户不存在",
			"code":  "USER_NOT_FOUND",
		})
		return
	}

	// 清除密码哈希
	user.PasswordHash = ""

	c.JSON(http.StatusOK, gin.H{
		"data": user,
	})
}

// UpdateProfile 更新用户资料
func (h *Handlers) UpdateProfile(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "未认证用户",
			"code":  "UNAUTHENTICATED",
		})
		return
	}

	var req struct {
		FirstName string `json:"first_name"`
		LastName  string `json:"last_name"`
		Bio       string `json:"bio"`
		Avatar    string `json:"avatar"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "请求参数错误",
			"code":    "INVALID_REQUEST",
			"details": err.Error(),
		})
		return
	}

	var user models.User
	if err := h.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "用户不存在",
			"code":  "USER_NOT_FOUND",
		})
		return
	}

	// 更新用户信息
	updates := make(map[string]interface{})
	if req.FirstName != "" {
		updates["first_name"] = req.FirstName
	}
	if req.LastName != "" {
		updates["last_name"] = req.LastName
	}
	if req.Bio != "" {
		updates["bio"] = req.Bio
	}
	if req.Avatar != "" {
		updates["avatar"] = req.Avatar
	}

	if err := h.DB.Model(&user).Updates(updates).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "更新用户资料失败",
			"code":  "UPDATE_ERROR",
		})
		return
	}

	// 清除密码哈希
	user.PasswordHash = ""

	c.JSON(http.StatusOK, gin.H{
		"message": "用户资料更新成功",
		"data":    user,
	})
}

// UploadAvatar 上传头像
func (h *Handlers) UploadAvatar(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "未认证用户",
			"code":  "UNAUTHENTICATED",
		})
		return
	}

	// 获取上传的文件
	file, err := c.FormFile("avatar")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "文件上传失败",
			"code":    "FILE_UPLOAD_ERROR",
			"details": err.Error(),
		})
		return
	}

	// 生成唯一文件名
	randomBytes := make([]byte, 16)
	rand.Read(randomBytes)
	filename := fmt.Sprintf("avatar_%d_%s_%s", userID, hex.EncodeToString(randomBytes), file.Filename)

	// 保存文件
	uploadPath := fmt.Sprintf("./uploads/avatars/%s", filename)
	if err := c.SaveUploadedFile(file, uploadPath); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "文件保存失败",
			"code":  "FILE_SAVE_ERROR",
		})
		return
	}

	// 更新用户头像URL
	avatarURL := fmt.Sprintf("/uploads/avatars/%s", filename)
	if err := h.DB.Model(&models.User{}).Where("id = ?", userID).Update("avatar", avatarURL).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "头像更新失败",
			"code":  "AVATAR_UPDATE_ERROR",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "头像上传成功",
		"data": gin.H{
			"avatar_url": avatarURL,
		},
	})
}

// GetUserStats 获取用户统计信息
func (h *Handlers) GetUserStats(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "未认证用户",
			"code":  "UNAUTHENTICATED",
		})
		return
	}

	// 尝试从缓存获取
	var stats models.UserStats
	if h.Cache != nil {
		if err := h.Cache.GetUserStats(userID.(uint), &stats); err == nil {
			c.JSON(http.StatusOK, gin.H{
				"data": stats,
			})
			return
		}
	}

	// 从数据库计算统计信息
	var totalWorkouts int64
	var totalCheckins int64
	var totalCalories int64
	var avgRating float64

	h.DB.Model(&models.Workout{}).Where("user_id = ?", userID).Count(&totalWorkouts)
	h.DB.Model(&models.Checkin{}).Where("user_id = ?", userID).Count(&totalCheckins)
	h.DB.Model(&models.Workout{}).Where("user_id = ?", userID).Select("COALESCE(SUM(calories), 0)").Scan(&totalCalories)
	h.DB.Model(&models.Workout{}).Where("user_id = ?", userID).Select("COALESCE(AVG(rating), 0)").Scan(&avgRating)

	var followersCount int64
	var followingCount int64
	h.DB.Model(&models.Follow{}).Where("following_id = ?", userID).Count(&followersCount)
	h.DB.Model(&models.Follow{}).Where("follower_id = ?", userID).Count(&followingCount)

	stats = models.UserStats{
		UserID:         userID.(uint),
		TotalWorkouts:  int(totalWorkouts),
		TotalCheckins:  int(totalCheckins),
		TotalCalories:  int(totalCalories),
		AverageRating:  avgRating,
		FollowersCount: int(followersCount),
		FollowingCount: int(followingCount),
	}

	// 存储到缓存
	if h.Cache != nil {
		h.Cache.SetUserStats(userID.(uint), stats)
	}

	c.JSON(http.StatusOK, gin.H{
		"data": stats,
	})
}
