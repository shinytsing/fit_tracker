package handlers

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"net/http"
	"time"

	"gymates/internal/api/middleware"
	"gymates/internal/models"

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
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// ThirdPartyLoginRequest 第三方登录请求
type ThirdPartyLoginRequest struct {
	Provider      string                 `json:"provider" binding:"required"` // apple, wechat, sms, one_click
	UserID        string                 `json:"userId,omitempty"`            // 第三方用户ID
	Email         string                 `json:"email,omitempty"`             // 邮箱
	PhoneNumber   string                 `json:"phoneNumber,omitempty"`       // 手机号
	FullName      string                 `json:"fullName,omitempty"`          // 全名
	IdentityToken string                 `json:"identityToken,omitempty"`     // 身份令牌
	AuthCode      string                 `json:"authCode,omitempty"`          // 授权码
	DeviceInfo    map[string]interface{} `json:"deviceInfo,omitempty"`        // 设备信息
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
		Nickname:     req.Username,
	}

	if err := h.DB.Create(user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "用户创建失败",
			"code":  "USER_CREATION_ERROR",
		})
		return
	}

	// 生成Token
	token, err := middleware.GenerateToken(fmt.Sprintf("%d", user.UID), user.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Token生成失败",
			"code":  "TOKEN_GENERATION_ERROR",
		})
		return
	}

	// 存储Token到Redis
	if h.Cache != nil {
		h.Cache.SetUserToken(token, user.UID)
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

	// 查找用户 - 支持用户名、邮箱或手机号登录
	var user models.User
	if err := h.DB.Where("username = ? OR email = ? OR phone = ?", req.Username, req.Username, req.Username).First(&user).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusUnauthorized, gin.H{
				"error": "用户名或密码错误",
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
			"error": "用户名或密码错误",
			"code":  "INVALID_CREDENTIALS",
		})
		return
	}

	// 生成Token
	token, err := middleware.GenerateToken(fmt.Sprintf("%d", user.UID), user.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Token生成失败",
			"code":  "TOKEN_GENERATION_ERROR",
		})
		return
	}

	// 存储Token到Redis
	if h.Cache != nil {
		h.Cache.SetUserToken(token, user.UID)
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

// ThirdPartyLogin 第三方登录
func (h *Handlers) ThirdPartyLogin(c *gin.Context) {
	var req ThirdPartyLoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "请求参数错误",
			"code":  "INVALID_REQUEST",
		})
		return
	}

	// 根据不同的第三方登录方式处理
	switch req.Provider {
	case "apple":
		h.handleAppleLogin(c, req)
	case "wechat":
		h.handleWeChatLogin(c, req)
	case "sms":
		h.handleSMSLogin(c, req)
	case "one_click":
		h.handleOneClickLogin(c, req)
	default:
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "不支持的登录方式",
			"code":  "UNSUPPORTED_PROVIDER",
		})
	}
}

// handleAppleLogin 处理苹果登录
func (h *Handlers) handleAppleLogin(c *gin.Context, req ThirdPartyLoginRequest) {
	// 验证苹果身份令牌（这里简化处理，实际项目中需要验证JWT）
	if req.IdentityToken == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "苹果身份令牌无效",
			"code":  "INVALID_APPLE_TOKEN",
		})
		return
	}

	// 查找或创建用户
	var user models.User
	var err error

	if req.UserID != "" {
		// 通过苹果用户ID查找用户
		err = h.DB.Where("apple_id = ?", req.UserID).First(&user).Error
	} else if req.Email != "" {
		// 通过邮箱查找用户
		err = h.DB.Where("email = ?", req.Email).First(&user).Error
	}

	if err != nil {
		if err == gorm.ErrRecordNotFound {
			// 用户不存在，创建新用户
			user = models.User{
				Username:  req.Email, // 使用邮箱作为用户名
				Email:     req.Email,
				Nickname:  req.FullName,
				AppleID:   req.UserID,
				IsActive:  true,
				CreatedAt: time.Now(),
				UpdatedAt: time.Now(),
			}

			if err := h.DB.Create(&user).Error; err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{
					"error": "创建用户失败",
					"code":  "USER_CREATION_FAILED",
				})
				return
			}
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "查询用户失败",
				"code":  "USER_QUERY_FAILED",
			})
			return
		}
	}

	// 更新苹果ID（如果还没有）
	if user.AppleID == "" && req.UserID != "" {
		user.AppleID = req.UserID
		h.DB.Save(&user)
	}

	// 生成JWT token
	token, err := middleware.GenerateToken(fmt.Sprintf("%d", user.UID), user.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "生成token失败",
			"code":  "TOKEN_GENERATION_FAILED",
		})
		return
	}

	// 缓存token
	if h.Cache != nil {
		h.Cache.SetUserToken(token, user.UID)
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

// handleWeChatLogin 处理微信登录
func (h *Handlers) handleWeChatLogin(c *gin.Context, req ThirdPartyLoginRequest) {
	// 验证微信授权码（这里简化处理，实际项目中需要调用微信API验证）
	if req.AuthCode == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "微信授权码无效",
			"code":  "INVALID_WECHAT_CODE",
		})
		return
	}

	// 查找或创建用户
	var user models.User
	var err error

	// 通过微信授权码查找用户（这里简化处理）
	err = h.DB.Where("wechat_openid = ?", req.AuthCode).First(&user).Error

	if err != nil {
		if err == gorm.ErrRecordNotFound {
			// 用户不存在，创建新用户
			user = models.User{
				Username:     fmt.Sprintf("wechat_%s", req.AuthCode[:8]), // 生成用户名
				Nickname:     "微信用户",
				WeChatOpenID: req.AuthCode,
				IsActive:     true,
				CreatedAt:    time.Now(),
				UpdatedAt:    time.Now(),
			}

			if err := h.DB.Create(&user).Error; err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{
					"error": "创建用户失败",
					"code":  "USER_CREATION_FAILED",
				})
				return
			}
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "查询用户失败",
				"code":  "USER_QUERY_FAILED",
			})
			return
		}
	}

	// 生成JWT token
	token, err := middleware.GenerateToken(fmt.Sprintf("%d", user.UID), user.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "生成token失败",
			"code":  "TOKEN_GENERATION_FAILED",
		})
		return
	}

	// 缓存token
	if h.Cache != nil {
		h.Cache.SetUserToken(token, user.UID)
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

// handleSMSLogin 处理短信验证码登录
func (h *Handlers) handleSMSLogin(c *gin.Context, req ThirdPartyLoginRequest) {
	// 验证手机号
	if req.PhoneNumber == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "手机号不能为空",
			"code":  "PHONE_NUMBER_REQUIRED",
		})
		return
	}

	// 查找或创建用户
	var user models.User
	var err error

	err = h.DB.Where("phone = ?", req.PhoneNumber).First(&user).Error

	if err != nil {
		if err == gorm.ErrRecordNotFound {
			// 用户不存在，创建新用户
			user = models.User{
				Username:  req.PhoneNumber, // 使用手机号作为用户名
				Phone:     req.PhoneNumber,
				Nickname:  fmt.Sprintf("用户%s", req.PhoneNumber[len(req.PhoneNumber)-4:]),
				IsActive:  true,
				CreatedAt: time.Now(),
				UpdatedAt: time.Now(),
			}

			if err := h.DB.Create(&user).Error; err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{
					"error": "创建用户失败",
					"code":  "USER_CREATION_FAILED",
				})
				return
			}
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "查询用户失败",
				"code":  "USER_QUERY_FAILED",
			})
			return
		}
	}

	// 生成JWT token
	token, err := middleware.GenerateToken(fmt.Sprintf("%d", user.UID), user.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "生成token失败",
			"code":  "TOKEN_GENERATION_FAILED",
		})
		return
	}

	// 缓存token
	if h.Cache != nil {
		h.Cache.SetUserToken(token, user.UID)
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

// handleOneClickLogin 处理一键登录
func (h *Handlers) handleOneClickLogin(c *gin.Context, req ThirdPartyLoginRequest) {
	// 验证手机号
	if req.PhoneNumber == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "手机号不能为空",
			"code":  "PHONE_NUMBER_REQUIRED",
		})
		return
	}

	// 查找或创建用户
	var user models.User
	var err error

	err = h.DB.Where("phone = ?", req.PhoneNumber).First(&user).Error

	if err != nil {
		if err == gorm.ErrRecordNotFound {
			// 用户不存在，创建新用户
			user = models.User{
				Username:  req.PhoneNumber, // 使用手机号作为用户名
				Phone:     req.PhoneNumber,
				Nickname:  fmt.Sprintf("用户%s", req.PhoneNumber[len(req.PhoneNumber)-4:]),
				IsActive:  true,
				CreatedAt: time.Now(),
				UpdatedAt: time.Now(),
			}

			if err := h.DB.Create(&user).Error; err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{
					"error": "创建用户失败",
					"code":  "USER_CREATION_FAILED",
				})
				return
			}
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "查询用户失败",
				"code":  "USER_QUERY_FAILED",
			})
			return
		}
	}

	// 生成JWT token
	token, err := middleware.GenerateToken(fmt.Sprintf("%d", user.UID), user.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "生成token失败",
			"code":  "TOKEN_GENERATION_FAILED",
		})
		return
	}

	// 缓存token
	if h.Cache != nil {
		h.Cache.SetUserToken(token, user.UID)
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
	token, err := middleware.GenerateToken(fmt.Sprintf("%d", user.UID), user.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Token生成失败",
			"code":  "TOKEN_GENERATION_ERROR",
		})
		return
	}

	// 存储新Token到Redis
	if h.Cache != nil {
		h.Cache.SetUserToken(token, user.UID)
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
		UserID:         uint64(userID.(uint)),
		TotalWorkouts:  int(totalWorkouts),
		TotalCheckins:  int(totalCheckins),
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
