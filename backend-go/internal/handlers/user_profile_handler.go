package handlers

import (
	"net/http"
	"strconv"
	"time"

	"gymates/internal/models"
	"gymates/pkg/logger"

	"github.com/gin-gonic/gin"
)

// Register 用户注册
func (h *Handlers) Register(c *gin.Context) {
	var requestData models.RegisterRequest
	if err := c.ShouldBindJSON(&requestData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "请求参数错误"})
		return
	}

	// 注册用户
	response, err := h.services.UserProfileService.Register(requestData)
	if err != nil {
		logger.Error("用户注册失败", map[string]interface{}{
			"username": requestData.Username,
			"error":    err.Error(),
		})
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	logger.Info("用户注册成功", map[string]interface{}{
		"user_id":  response.ID,
		"username": response.Username,
	})

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "注册成功",
		"data":    response,
	})
}

// Login 用户登录
func (h *Handlers) Login(c *gin.Context) {
	var requestData models.LoginRequest
	if err := c.ShouldBindJSON(&requestData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "请求参数错误"})
		return
	}

	// 用户登录
	response, err := h.services.UserProfileService.Login(requestData)
	if err != nil {
		logger.Error("用户登录失败", map[string]interface{}{
			"username": requestData.Username,
			"error":    err.Error(),
		})
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	logger.Info("用户登录成功", map[string]interface{}{
		"user_id":  response.ID,
		"username": response.Username,
	})

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "登录成功",
		"data":    response,
	})
}

// GetProfile 获取用户资料
func (h *Handlers) GetProfile(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	// 获取用户资料
	response, err := h.services.UserProfileService.GetProfile(userID)
	if err != nil {
		logger.Error("获取用户资料失败", map[string]interface{}{
			"user_id": userID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取用户资料成功",
		"data":    response,
	})
}

// UpdateProfile 更新用户资料
func (h *Handlers) UpdateProfile(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	var requestData models.UpdateProfileRequest
	if err := c.ShouldBindJSON(&requestData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "请求参数错误"})
		return
	}

	// 更新用户资料
	response, err := h.services.UserProfileService.UpdateProfile(userID, requestData)
	if err != nil {
		logger.Error("更新用户资料失败", map[string]interface{}{
			"user_id": userID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	logger.Info("用户资料更新成功", map[string]interface{}{
		"user_id": userID,
	})

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "更新用户资料成功",
		"data":    response,
	})
}

// GetSettings 获取用户设置
func (h *Handlers) GetSettings(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	// 获取用户设置
	response, err := h.services.UserProfileService.GetSettings(userID)
	if err != nil {
		logger.Error("获取用户设置失败", map[string]interface{}{
			"user_id": userID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取用户设置成功",
		"data":    response,
	})
}

// UpdateSettings 更新用户设置
func (h *Handlers) UpdateSettings(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	var requestData models.UpdateSettingsRequest
	if err := c.ShouldBindJSON(&requestData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "请求参数错误"})
		return
	}

	// 更新用户设置
	response, err := h.services.UserProfileService.UpdateSettings(userID, requestData)
	if err != nil {
		logger.Error("更新用户设置失败", map[string]interface{}{
			"user_id": userID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	logger.Info("用户设置更新成功", map[string]interface{}{
		"user_id": userID,
	})

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "更新用户设置成功",
		"data":    response,
	})
}

// ChangePassword 修改密码
func (h *Handlers) ChangePassword(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	var requestData models.ChangePasswordRequest
	if err := c.ShouldBindJSON(&requestData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "请求参数错误"})
		return
	}

	// 修改密码
	err := h.services.UserProfileService.ChangePassword(userID, requestData)
	if err != nil {
		logger.Error("修改密码失败", map[string]interface{}{
			"user_id": userID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	logger.Info("密码修改成功", map[string]interface{}{
		"user_id": userID,
	})

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "密码修改成功",
	})
}

// GetUserStats 获取用户统计
func (h *Handlers) GetUserStats(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	// 获取用户统计
	response, err := h.services.UserProfileService.GetUserStats(userID)
	if err != nil {
		logger.Error("获取用户统计失败", map[string]interface{}{
			"user_id": userID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取用户统计成功",
		"data":    response,
	})
}

// GetUserAchievements 获取用户成就
func (h *Handlers) GetUserAchievements(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	// 获取查询参数
	skip, _ := strconv.Atoi(c.DefaultQuery("skip", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	if limit > 50 {
		limit = 50
	}

	// 获取用户成就
	achievements, err := h.services.UserProfileService.GetUserAchievements(userID, skip, limit)
	if err != nil {
		logger.Error("获取用户成就失败", map[string]interface{}{
			"user_id": userID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取用户成就失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取用户成就成功",
		"data":    achievements,
	})
}

// SearchUsers 搜索用户
func (h *Handlers) SearchUsers(c *gin.Context) {
	var requestData models.SearchUsersRequest
	if err := c.ShouldBindJSON(&requestData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "请求参数错误"})
		return
	}

	// 设置默认值
	if requestData.Limit == 0 {
		requestData.Limit = 20
	}
	if requestData.Limit > 50 {
		requestData.Limit = 50
	}

	// 搜索用户
	users, err := h.services.UserProfileService.SearchUsers(requestData)
	if err != nil {
		logger.Error("搜索用户失败", map[string]interface{}{
			"query": requestData.Query,
			"error": err.Error(),
		})
		c.JSON(http.StatusInternalServerError, gin.H{"error": "搜索用户失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "搜索用户成功",
		"data":    users,
	})
}

// FollowUser 关注用户
func (h *Handlers) FollowUser(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	var requestData models.FollowUserRequest
	if err := c.ShouldBindJSON(&requestData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "请求参数错误"})
		return
	}

	// 关注用户
	err := h.services.UserProfileService.FollowUser(userID, requestData)
	if err != nil {
		logger.Error("关注用户失败", map[string]interface{}{
			"user_id":      userID,
			"following_id": requestData.UserID,
			"error":        err.Error(),
		})
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	logger.Info("关注用户成功", map[string]interface{}{
		"user_id":      userID,
		"following_id": requestData.UserID,
	})

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "关注用户成功",
	})
}

// UnfollowUser 取消关注用户
func (h *Handlers) UnfollowUser(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	followingID := c.Param("id")
	if followingID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "用户ID不能为空"})
		return
	}

	// 取消关注用户
	err := h.services.UserProfileService.UnfollowUser(userID, followingID)
	if err != nil {
		logger.Error("取消关注用户失败", map[string]interface{}{
			"user_id":      userID,
			"following_id": followingID,
			"error":        err.Error(),
		})
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	logger.Info("取消关注用户成功", map[string]interface{}{
		"user_id":      userID,
		"following_id": followingID,
	})

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "取消关注用户成功",
	})
}

// UploadAvatar 上传头像
func (h *Handlers) UploadAvatar(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	var requestData models.UploadAvatarRequest
	if err := c.ShouldBindJSON(&requestData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "请求参数错误"})
		return
	}

	// 这里应该实现头像上传逻辑，保存图片并返回URL
	// 暂时返回模拟数据
	avatarURL := "https://example.com/avatars/" + userID + ".jpg"

	// 更新用户头像
	var user models.UserProfile
	if err := h.services.UserProfileService.db.First(&user, "id = ?", userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "用户不存在"})
		return
	}

	user.Avatar = avatarURL
	user.UpdatedAt = time.Now()

	if err := h.services.UserProfileService.db.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "更新头像失败"})
		return
	}

	logger.Info("头像上传成功", map[string]interface{}{
		"user_id":    userID,
		"avatar_url": avatarURL,
	})

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "头像上传成功",
		"data": gin.H{
			"avatar_url": avatarURL,
		},
	})
}
