package handlers

import (
	"net/http"
	"strconv"
	"time"

	"gymates/internal/models"
	"gymates/internal/services"

	"github.com/gin-gonic/gin"
)

// ProfileHandler 个人中心相关处理器
type ProfileHandler struct {
	profileService     *services.ProfileService
	achievementService *services.AchievementService
	statsService       *services.StatsService
	settingsService    *services.SettingsService
}

// NewProfileHandler 创建个人中心处理器
func NewProfileHandler(profileService *services.ProfileService, achievementService *services.AchievementService, statsService *services.StatsService, settingsService *services.SettingsService) *ProfileHandler {
	return &ProfileHandler{
		profileService:     profileService,
		achievementService: achievementService,
		statsService:       statsService,
		settingsService:    settingsService,
	}
}

// GetProfile 获取个人资料
// GET /api/v1/profile
func (h *ProfileHandler) GetProfile(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 转换 userID 为 uint
	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	profile, err := h.profileService.GetProfile(uint(userIDUint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    profile,
	})
}

// UpdateProfile 更新个人资料
// PUT /api/v1/profile
func (h *ProfileHandler) UpdateProfile(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		Nickname    string `json:"nickname"`
		Bio         string `json:"bio"`
		Avatar      string `json:"avatar"`
		Gender      string `json:"gender"`
		Birthday    string `json:"birthday"`
		Height      int    `json:"height"`
		Weight      int    `json:"weight"`
		Location    string `json:"location"`
		Phone       string `json:"phone"`
		Email       string `json:"email"`
		IsPublic    bool   `json:"is_public"`
		AllowFollow bool   `json:"allow_follow"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 转换 userID 为 uint
	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	updates := map[string]interface{}{
		"nickname":     req.Nickname,
		"bio":          req.Bio,
		"avatar":       req.Avatar,
		"gender":       req.Gender,
		"birthday":     req.Birthday,
		"height":       req.Height,
		"weight":       req.Weight,
		"location":     req.Location,
		"phone":        req.Phone,
		"email":        req.Email,
		"is_public":    req.IsPublic,
		"allow_follow": req.AllowFollow,
		"updated_at":   time.Now(),
	}

	err = h.profileService.UpdateProfile(uint(userIDUint), updates)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "个人资料更新成功",
	})
}

// GetUserStats 获取用户统计
// GET /api/v1/profile/stats
func (h *ProfileHandler) GetUserStats(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 转换 userID 为 uint
	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	stats, err := h.statsService.GetUserStats(uint(userIDUint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    stats,
	})
}

// GetChartData 获取图表数据
// GET /api/v1/profile/charts
func (h *ProfileHandler) GetChartData(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 获取查询参数
	chartType := c.Query("type")             // bmi_trend, training_duration, calories_burned, workout_frequency, exercise_distribution
	period := c.DefaultQuery("period", "30") // 天数
	startDate := c.Query("start_date")
	endDate := c.Query("end_date")

	chartData, err := h.statsService.GetChartData(userID, chartType, period, startDate, endDate)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    chartData,
	})
}

// GetAchievements 获取成就列表
// GET /api/v1/profile/achievements
func (h *ProfileHandler) GetAchievements(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 转换 userID 为 uint
	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	achievements, err := h.achievementService.GetUserAchievements(uint(userIDUint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"achievements": achievements,
		},
	})
}

// ClaimAchievementReward 领取成就奖励
// POST /api/v1/profile/achievements/:id/claim
func (h *ProfileHandler) ClaimAchievementReward(c *gin.Context) {
	userID := c.GetString("user_id")
	achievementID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	err := h.achievementService.ClaimReward(userID, achievementID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "奖励领取成功",
	})
}

// GetTrainingPlans 获取训练计划
// GET /api/v1/profile/training-plans
func (h *ProfileHandler) GetTrainingPlans(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 转换 userID 为 uint
	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	plans, err := h.profileService.GetTrainingPlans(uint(userIDUint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"plans": plans,
		},
	})
}

// CreateTrainingPlan 创建训练计划
// POST /api/v1/profile/training-plans
func (h *ProfileHandler) CreateTrainingPlan(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		Name        string                    `json:"name" binding:"required"`
		Description string                    `json:"description"`
		Type        string                    `json:"type" binding:"required"` // ai, custom, template
		TemplateID  string                    `json:"template_id"`
		Duration    int                       `json:"duration"`   // 计划持续天数
		Frequency   int                       `json:"frequency"`  // 每周训练次数
		Difficulty  string                    `json:"difficulty"` // beginner, intermediate, advanced
		Goals       []string                  `json:"goals"`
		Exercises   []string               `json:"exercises"`
		Extra       map[string]interface{}    `json:"extra"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 转换 userID 为 uint
	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	plan := &models.TrainingPlan{
		UserID:        uint(userIDUint),
		Name:          req.Name,
		Description:   req.Description,
		Date:          time.Now(),
		Duration:      req.Duration,
		Status:        "draft",
		IsAIGenerated: false,
		CreatedAt:     time.Now(),
		UpdatedAt:     time.Now(),
	}

	createdPlan, err := h.profileService.CreateTrainingPlan(plan)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"data":    createdPlan,
		"message": "训练计划创建成功",
	})
}

// UpdateTrainingPlan 更新训练计划
// PUT /api/v1/profile/training-plans/:id
func (h *ProfileHandler) UpdateTrainingPlan(c *gin.Context) {
	userID := c.GetString("user_id")
	planID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		Name        string                    `json:"name"`
		Description string                    `json:"description"`
		Duration    int                       `json:"duration"`
		Frequency   int                       `json:"frequency"`
		Difficulty  string                    `json:"difficulty"`
		Goals       []string                  `json:"goals"`
		Exercises   []string               `json:"exercises"`
		Status      string                    `json:"status"`
		Extra       map[string]interface{}    `json:"extra"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	updates := map[string]interface{}{
		"name":        req.Name,
		"description": req.Description,
		"duration":    req.Duration,
		"frequency":   req.Frequency,
		"difficulty":  req.Difficulty,
		"goals":       req.Goals,
		"exercises":   req.Exercises,
		"status":      req.Status,
		"extra":       req.Extra,
		"updated_at":  time.Now(),
	}

	updatedPlan, err := h.profileService.UpdateTrainingPlan(planID, updates)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    updatedPlan,
		"message": "训练计划更新成功",
	})
}

// DeleteTrainingPlan 删除训练计划
// DELETE /api/v1/profile/training-plans/:id
func (h *ProfileHandler) DeleteTrainingPlan(c *gin.Context) {
	userID := c.GetString("user_id")
	planID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	err := h.profileService.DeleteTrainingPlan(planID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "训练计划删除成功",
	})
}

// GetNutritionPlan 获取营养计划
// GET /api/v1/profile/nutrition-plan
func (h *ProfileHandler) GetNutritionPlan(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 转换 userID 为 uint
	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	plan, err := h.profileService.GetNutritionPlan(uint(userIDUint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    plan,
	})
}

// UpdateNutritionPlan 更新营养计划
// PUT /api/v1/profile/nutrition-plan
func (h *ProfileHandler) UpdateNutritionPlan(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		Name           string                 `json:"name"`
		Description    string                 `json:"description"`
		TargetCalories int                    `json:"target_calories"`
		TargetProtein  int                    `json:"target_protein"`
		TargetCarbs    int                    `json:"target_carbs"`
		TargetFat      int                    `json:"target_fat"`
		MealPlans      []map[string]interface{} `json:"meal_plans"`
		Restrictions   []string               `json:"restrictions"`
		Preferences    []string               `json:"preferences"`
		Extra          map[string]interface{} `json:"extra"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 转换 userID 为 uint
	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	updates := map[string]interface{}{
		"name":            req.Name,
		"description":     req.Description,
		"target_calories": req.TargetCalories,
		"target_protein":  req.TargetProtein,
		"target_carbs":    req.TargetCarbs,
		"target_fat":      req.TargetFat,
		"meal_plans":     req.MealPlans,
		"restrictions":    req.Restrictions,
		"preferences":     req.Preferences,
		"extra":           req.Extra,
	}

	updatedPlan, err := h.profileService.UpdateNutritionPlan(uint(userIDUint), updates)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    updatedPlan,
		"message": "营养计划更新成功",
	})
}

// GetSettings 获取用户设置
// GET /api/v1/profile/settings
func (h *ProfileHandler) GetSettings(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 转换 userID 为 uint
	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	settings, err := h.settingsService.GetUserSettings(uint(userIDUint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    settings,
	})
}

// UpdateSetting 更新设置
// PUT /api/v1/profile/settings/:key
func (h *ProfileHandler) UpdateSetting(c *gin.Context) {
	userID := c.GetString("user_id")
	settingKey := c.Param("key")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		Value interface{} `json:"value"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 转换 userID 为 uint
	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	err = h.settingsService.UpdateSetting(uint(userIDUint), settingKey, req.Value.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "设置更新成功",
	})
}

// GetActivityHistory 获取活动历史
// GET /api/v1/profile/activity
func (h *ProfileHandler) GetActivityHistory(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 转换 userID 为 uint
	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	activities, err := h.profileService.GetActivityHistory(uint(userIDUint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"activities": activities,
		},
	})
}

// GetFollowers 获取粉丝列表
// GET /api/v1/profile/followers
func (h *ProfileHandler) GetFollowers(c *gin.Context) {
	userID := c.GetString("user_id")
	targetUserID := c.DefaultQuery("user_id", userID)

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 转换 targetUserID 为 uint
	targetUserIDUint, err := strconv.ParseUint(targetUserID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	followers, err := h.profileService.GetFollowers(uint(targetUserIDUint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"followers": followers,
		},
	})
}

// GetFollowing 获取关注列表
// GET /api/v1/profile/following
func (h *ProfileHandler) GetFollowing(c *gin.Context) {
	userID := c.GetString("user_id")
	targetUserID := c.DefaultQuery("user_id", userID)

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 转换 targetUserID 为 uint
	targetUserIDUint, err := strconv.ParseUint(targetUserID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	following, err := h.profileService.GetFollowing(uint(targetUserIDUint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"following": following,
		},
	})
}

// FollowUser 关注用户
// POST /api/v1/profile/follow/:id
func (h *ProfileHandler) FollowUser(c *gin.Context) {
	userID := c.GetString("user_id")
	targetUserID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	if userID == targetUserID {
		c.JSON(http.StatusBadRequest, gin.H{"error": "不能关注自己"})
		return
	}

	// 转换 userID 和 targetUserID 为 uint
	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}
	targetUserIDUint, err := strconv.ParseUint(targetUserID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的目标用户ID"})
		return
	}

	err = h.profileService.FollowUser(uint(userIDUint), uint(targetUserIDUint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "关注成功",
	})
}

// UnfollowUser 取消关注用户
// DELETE /api/v1/profile/follow/:id
func (h *ProfileHandler) UnfollowUser(c *gin.Context) {
	userID := c.GetString("user_id")
	targetUserID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 转换 userID 和 targetUserID 为 uint
	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}
	targetUserIDUint, err := strconv.ParseUint(targetUserID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的目标用户ID"})
		return
	}

	err = h.profileService.UnfollowUser(uint(userIDUint), uint(targetUserIDUint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "取消关注成功",
	})
}

// UploadAvatar 上传头像
// POST /api/v1/profile/avatar
func (h *ProfileHandler) UploadAvatar(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 获取上传的文件
	file, _, err := c.Request.FormFile("avatar")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "文件上传失败"})
		return
	}
	defer file.Close()

	// 转换 userID 为 uint
	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	// 模拟头像URL
	avatarURL := "https://example.com/avatar.jpg"
	err = h.profileService.UploadAvatar(uint(userIDUint), avatarURL)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"avatar_url": avatarURL,
		},
		"message": "头像上传成功",
	})
}

// DeleteAccount 删除账户
// DELETE /api/v1/profile/account
func (h *ProfileHandler) DeleteAccount(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		Password string `json:"password" binding:"required"`
		Reason   string `json:"reason"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 转换 userID 为 uint
	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	err = h.profileService.DeleteAccount(uint(userIDUint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "账户删除成功",
	})
}
