package handlers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

// CreateUserProfile 创建用户个人资料
func (h *Handlers) CreateUserProfile(c *gin.Context) {
	userID := c.GetUint("user_id")
	if userID == 0 {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "用户未登录",
			"code":  "UNAUTHORIZED",
		})
		return
	}

	var req struct {
		Height        float64 `json:"height" binding:"required,min=100,max=250"`
		Weight        float64 `json:"weight" binding:"required,min=30,max=300"`
		ExerciseYears int     `json:"exercise_years" binding:"required,min=0,max=50"`
		FitnessGoal   string  `json:"fitness_goal" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "请求参数错误",
			"code":    "INVALID_REQUEST",
			"details": err.Error(),
		})
		return
	}

	// 构建请求对象
	createReq := struct {
		Height        float64
		Weight        float64
		ExerciseYears int
		FitnessGoal   string
	}{
		Height:        req.Height,
		Weight:        req.Weight,
		ExerciseYears: req.ExerciseYears,
		FitnessGoal:   req.FitnessGoal,
	}

	profile, err := h.UserProfileService.CreateProfile(&createReq, userID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
			"code":  "PROFILE_CREATION_FAILED",
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "个人资料创建成功",
		"data":    profile,
	})
}

// GetUserProfile 获取用户个人资料
func (h *Handlers) GetUserProfile(c *gin.Context) {
	userID := c.GetUint("user_id")
	if userID == 0 {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "用户未登录",
			"code":  "UNAUTHORIZED",
		})
		return
	}

	profile, err := h.UserProfileService.GetProfile(userID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": err.Error(),
			"code":  "PROFILE_NOT_FOUND",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "获取个人资料成功",
		"data":    profile,
	})
}

// GetUserProfileByID 根据用户ID获取个人资料（管理员接口）
func (h *Handlers) GetUserProfileByID(c *gin.Context) {
	userIDStr := c.Param("user_id")
	userID, err := strconv.ParseUint(userIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "无效的用户ID",
			"code":  "INVALID_USER_ID",
		})
		return
	}

	profile, err := h.UserProfileService.GetProfile(uint(userID))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": err.Error(),
			"code":  "PROFILE_NOT_FOUND",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "获取个人资料成功",
		"data":    profile,
	})
}

// UpdateUserProfile 更新用户个人资料
func (h *Handlers) UpdateUserProfile(c *gin.Context) {
	userID := c.GetUint("user_id")
	if userID == 0 {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "用户未登录",
			"code":  "UNAUTHORIZED",
		})
		return
	}

	var req struct {
		Height        *float64 `json:"height,omitempty"`
		Weight        *float64 `json:"weight,omitempty"`
		ExerciseYears *int     `json:"exercise_years,omitempty"`
		FitnessGoal   *string  `json:"fitness_goal,omitempty"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "请求参数错误",
			"code":    "INVALID_REQUEST",
			"details": err.Error(),
		})
		return
	}

	// 构建请求对象
	updateReq := struct {
		Height        *float64
		Weight        *float64
		ExerciseYears *int
		FitnessGoal   *string
	}{
		Height:        req.Height,
		Weight:        req.Weight,
		ExerciseYears: req.ExerciseYears,
		FitnessGoal:   req.FitnessGoal,
	}

	profile, err := h.UserProfileService.UpdateProfile(&updateReq, userID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
			"code":  "PROFILE_UPDATE_FAILED",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "个人资料更新成功",
		"data":    profile,
	})
}

// DeleteUserProfile 删除用户个人资料
func (h *Handlers) DeleteUserProfile(c *gin.Context) {
	userID := c.GetUint("user_id")
	if userID == 0 {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "用户未登录",
			"code":  "UNAUTHORIZED",
		})
		return
	}

	err := h.UserProfileService.DeleteProfile(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": err.Error(),
			"code":  "PROFILE_DELETE_FAILED",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "个人资料删除成功",
	})
}

// CheckUserProfileExists 检查用户个人资料是否存在
func (h *Handlers) CheckUserProfileExists(c *gin.Context) {
	userID := c.GetUint("user_id")
	if userID == 0 {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "用户未登录",
			"code":  "UNAUTHORIZED",
		})
		return
	}

	exists, err := h.UserProfileService.CheckProfileExists(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": err.Error(),
			"code":  "PROFILE_CHECK_FAILED",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "检查完成",
		"data": gin.H{
			"exists": exists,
		},
	})
}
