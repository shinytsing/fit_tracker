package handlers

import (
	"encoding/json"
	"net/http"
	"strconv"
	"time"

	"fittracker/internal/domain"
	"fittracker/internal/services"
	"github.com/gin-gonic/gin"
)

// TrainingHandler 训练相关处理器
type TrainingHandler struct {
	trainingService *services.TrainingService
	aiService       *services.AIService
}

// NewTrainingHandler 创建训练处理器
func NewTrainingHandler(trainingService *services.TrainingService, aiService *services.AIService) *TrainingHandler {
	return &TrainingHandler{
		trainingService: trainingService,
		aiService:       aiService,
	}
}

// GetTodayPlan 获取今日训练计划
// GET /api/v1/training/plans/today
func (h *TrainingHandler) GetTodayPlan(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	plan, err := h.trainingService.GetTodayPlan(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    plan,
	})
}

// GetHistoryPlans 获取训练历史
// GET /api/v1/training/plans/history
func (h *TrainingHandler) GetHistoryPlans(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 获取查询参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	startDate := c.Query("start_date")
	endDate := c.Query("end_date")

	plans, total, err := h.trainingService.GetHistoryPlans(userID, page, limit, startDate, endDate)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"plans":      plans,
			"total":      total,
			"page":       page,
			"limit":      limit,
			"total_page": (total + limit - 1) / limit,
		},
	})
}

// CreatePlan 创建训练计划
// POST /api/v1/training/plans
func (h *TrainingHandler) CreatePlan(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		Name        string                    `json:"name" binding:"required"`
		Description string                    `json:"description"`
		Date        time.Time                 `json:"date"`
		Exercises   []domain.TrainingExercise `json:"exercises" binding:"required"`
		Duration    int                       `json:"duration"`
		Calories    int                       `json:"calories"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	plan := &domain.TrainingPlan{
		UserID:      userID,
		Name:        req.Name,
		Description: req.Description,
		Date:        req.Date,
		Exercises:   req.Exercises,
		Duration:    req.Duration,
		Calories:    req.Calories,
		Status:      domain.TrainingStatusPending,
	}

	createdPlan, err := h.trainingService.CreatePlan(plan)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"data":    createdPlan,
	})
}

// UpdatePlan 更新训练计划
// PUT /api/v1/training/plans/:id
func (h *TrainingHandler) UpdatePlan(c *gin.Context) {
	userID := c.GetString("user_id")
	planID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		Name        string                    `json:"name"`
		Description string                    `json:"description"`
		Exercises   []domain.TrainingExercise `json:"exercises"`
		Duration    int                       `json:"duration"`
		Calories    int                       `json:"calories"`
		Status      string                    `json:"status"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 检查计划所有权
	plan, err := h.trainingService.GetPlanByID(planID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "训练计划不存在"})
		return
	}

	if plan.UserID != userID {
		c.JSON(http.StatusForbidden, gin.H{"error": "无权限修改此计划"})
		return
	}

	// 更新计划
	plan.Name = req.Name
	plan.Description = req.Description
	plan.Exercises = req.Exercises
	plan.Duration = req.Duration
	plan.Calories = req.Calories
	if req.Status != "" {
		plan.Status = domain.TrainingStatus(req.Status)
	}

	updatedPlan, err := h.trainingService.UpdatePlan(plan)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    updatedPlan,
	})
}

// DeletePlan 删除训练计划
// DELETE /api/v1/training/plans/:id
func (h *TrainingHandler) DeletePlan(c *gin.Context) {
	userID := c.GetString("user_id")
	planID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 检查计划所有权
	plan, err := h.trainingService.GetPlanByID(planID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "训练计划不存在"})
		return
	}

	if plan.UserID != userID {
		c.JSON(http.StatusForbidden, gin.H{"error": "无权限删除此计划"})
		return
	}

	err = h.trainingService.DeletePlan(planID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "训练计划删除成功",
	})
}

// GenerateAIPlan AI生成训练计划
// POST /api/v1/training/plans/ai-generate
func (h *TrainingHandler) GenerateAIPlan(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		Goal           string   `json:"goal" binding:"required"`           // 训练目标：增肌、减脂、塑形等
		Duration       int      `json:"duration" binding:"required"`        // 训练时长（分钟）
		Difficulty     string   `json:"difficulty" binding:"required"`      // 训练难度：初级、中级、高级
		MuscleGroups   []string `json:"muscle_groups" binding:"required"`   // 目标肌肉群
		IncludeCardio  bool     `json:"include_cardio"`                     // 是否包含有氧运动
		Equipment      []string `json:"equipment"`                          // 可用器械
		Preferences    map[string]interface{} `json:"preferences"`          // 其他偏好设置
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 获取用户身体数据
	userProfile, err := h.trainingService.GetUserProfile(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取用户资料失败"})
		return
	}

	// 获取用户训练历史
	trainingHistory, err := h.trainingService.GetUserTrainingHistory(userID, 30) // 最近30天
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取训练历史失败"})
		return
	}

	// 构建AI请求参数
	aiRequest := &domain.AITrainingPlanRequest{
		UserProfile:     userProfile,
		TrainingHistory: trainingHistory,
		Goal:            req.Goal,
		Duration:        req.Duration,
		Difficulty:      req.Difficulty,
		MuscleGroups:    req.MuscleGroups,
		IncludeCardio:   req.IncludeCardio,
		Equipment:       req.Equipment,
		Preferences:     req.Preferences,
	}

	// 调用AI服务生成训练计划
	aiPlan, err := h.aiService.GenerateTrainingPlan(aiRequest)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "AI生成训练计划失败: " + err.Error()})
		return
	}

	// 保存生成的计划到数据库
	plan := &domain.TrainingPlan{
		UserID:            userID,
		Name:              aiPlan.Name,
		Description:       aiPlan.Description,
		Date:              time.Now(),
		Exercises:         aiPlan.Exercises,
		Duration:          aiPlan.Duration,
		Calories:          aiPlan.Calories,
		Status:            domain.TrainingStatusPending,
		AIGenerated:       true,
		AIGeneratedReason: aiPlan.Reason,
	}

	createdPlan, err := h.trainingService.CreatePlan(plan)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "保存AI训练计划失败"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"data":    createdPlan,
		"ai_info": gin.H{
			"generated_reason": aiPlan.Reason,
			"confidence":       aiPlan.Confidence,
			"suggestions":      aiPlan.Suggestions,
		},
	})
}

// CompleteExercise 完成动作组
// POST /api/v1/training/exercises/:id/complete
func (h *TrainingHandler) CompleteExercise(c *gin.Context) {
	userID := c.GetString("user_id")
	exerciseID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		SetIndex int `json:"set_index" binding:"required"`
		PlanID   string `json:"plan_id" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := h.trainingService.CompleteExercise(userID, req.PlanID, exerciseID, req.SetIndex)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "动作组完成记录成功",
	})
}

// CompleteWorkout 完成训练
// POST /api/v1/training/workouts/complete
func (h *TrainingHandler) CompleteWorkout(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		PlanID     string `json:"plan_id" binding:"required"`
		ActualDuration int `json:"actual_duration"` // 实际训练时长
		ActualCalories int `json:"actual_calories"` // 实际消耗卡路里
		Notes      string `json:"notes"`             // 训练备注
		Rating     int    `json:"rating"`            // 训练评分 1-5
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 完成训练
	err := h.trainingService.CompleteWorkout(userID, req.PlanID, req.ActualDuration, req.ActualCalories, req.Notes, req.Rating)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 更新用户积分和成就
	go h.trainingService.UpdateUserAchievements(userID, req.PlanID)

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "训练完成！",
		"data": gin.H{
			"points_earned": 50, // 完成训练获得积分
			"achievements":  []string{"训练新手", "坚持一周"}, // 解锁的成就
		},
	})
}

// GetTrainingStats 获取训练统计
// GET /api/v1/training/stats
func (h *TrainingHandler) GetTrainingStats(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 获取查询参数
	period := c.DefaultQuery("period", "week") // week, month, year
	startDate := c.Query("start_date")
	endDate := c.Query("end_date")

	stats, err := h.trainingService.GetTrainingStats(userID, period, startDate, endDate)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    stats,
	})
}

// GetAvailableExercises 获取可用动作库
// GET /api/v1/training/exercises
func (h *TrainingHandler) GetAvailableExercises(c *gin.Context) {
	category := c.Query("category")
	difficulty := c.Query("difficulty")
	equipment := c.Query("equipment")
	search := c.Query("search")

	exercises, err := h.trainingService.GetAvailableExercises(category, difficulty, equipment, search)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    exercises,
	})
}

// CreateCheckIn 创建打卡记录
// POST /api/v1/training/check-ins
func (h *TrainingHandler) CreateCheckIn(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		Date        time.Time `json:"date"`
		Type        string    `json:"type" binding:"required"` // 训练、日常
		Description string    `json:"description"`
		Images      []string  `json:"images"` // 打卡图片
		Location    string    `json:"location"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	checkIn := &domain.CheckIn{
		UserID:      userID,
		Date:        req.Date,
		Type:        req.Type,
		Description: req.Description,
		Images:      req.Images,
		Location:    req.Location,
	}

	createdCheckIn, err := h.trainingService.CreateCheckIn(checkIn)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 更新用户连续打卡天数
	go h.trainingService.UpdateCheckInStreak(userID)

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"data":    createdCheckIn,
		"message": "打卡成功！",
	})
}

// GetCheckIns 获取打卡记录
// GET /api/v1/training/check-ins
func (h *TrainingHandler) GetCheckIns(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 获取查询参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "30"))
	startDate := c.Query("start_date")
	endDate := c.Query("end_date")
	checkInType := c.Query("type")

	checkIns, total, err := h.trainingService.GetCheckIns(userID, page, limit, startDate, endDate, checkInType)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"check_ins":   checkIns,
			"total":       total,
			"page":        page,
			"limit":       limit,
			"total_page":  (total + limit - 1) / limit,
		},
	})
}

// GetUserAchievements 获取用户成就
// GET /api/v1/training/achievements
func (h *TrainingHandler) GetUserAchievements(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	achievements, err := h.trainingService.GetUserAchievements(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    achievements,
	})
}

// ClaimAchievementReward 领取成就奖励
// POST /api/v1/training/achievements/:id/claim
func (h *TrainingHandler) ClaimAchievementReward(c *gin.Context) {
	userID := c.GetString("user_id")
	achievementID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	reward, err := h.trainingService.ClaimAchievementReward(userID, achievementID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    reward,
		"message": "奖励领取成功！",
	})
}
