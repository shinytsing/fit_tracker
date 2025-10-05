package api

import (
	"net/http"
	"strconv"

	"gymates/internal/models"
	"gymates/internal/services"

	"github.com/gin-gonic/gin"
)

// TrainingHandler 训练相关API处理器
type TrainingHandler struct {
	trainingService *services.TrainingService
	aiService       *services.AIService
}

// NewTrainingHandler 创建训练API处理器
func NewTrainingHandler(
	trainingService *services.TrainingService,
	aiService *services.AIService,
) *TrainingHandler {
	return &TrainingHandler{
		trainingService: trainingService,
		aiService:       aiService,
	}
}

// GetTodayPlan 获取今日训练计划
func (h *TrainingHandler) GetTodayPlan(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	plan, err := h.trainingService.GetTodayPlan(strconv.FormatUint(userIDUint, 10))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取今日训练计划成功",
		"data":    plan,
	})
}

// GetHistoryPlans 获取历史训练计划
func (h *TrainingHandler) GetHistoryPlans(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	skip, _ := strconv.Atoi(c.DefaultQuery("skip", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	plans, err := h.trainingService.GetHistoryPlans(userID, skip, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取历史训练计划成功",
		"data":    plans,
	})
}

// CreatePlan 创建训练计划
func (h *TrainingHandler) CreatePlan(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	var req models.CreatePlanRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	plan, err := h.trainingService.CreatePlan(userID, req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"code":    201,
		"message": "创建训练计划成功",
		"data":    plan,
	})
}

// UpdatePlan 更新训练计划
func (h *TrainingHandler) UpdatePlan(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	planID := c.Param("id")
	if planID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "计划ID不能为空"})
		return
	}

	var req models.UpdatePlanRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	planIDUint, err := strconv.ParseUint(planID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的计划ID"})
		return
	}

	plan, err := h.trainingService.UpdatePlan(userID, uint(planIDUint), req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "更新训练计划成功",
		"data":    plan,
	})
}

// DeletePlan 删除训练计划
func (h *TrainingHandler) DeletePlan(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	planID := c.Param("id")
	if planID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "计划ID不能为空"})
		return
	}

	planIDUint, err := strconv.ParseUint(planID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的计划ID"})
		return
	}

	err = h.trainingService.DeletePlan(userID, uint(planIDUint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "删除训练计划成功",
	})
}

// GenerateAIPlan 生成AI训练计划
func (h *TrainingHandler) GenerateAIPlan(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	var req models.GenerateTrainingPlanRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	plan, err := h.trainingService.GenerateAIPlan(strconv.FormatUint(userIDUint, 10), models.GenerateAIPlanRequest{
		Goal:       req.Goal,
		Duration:   req.Duration,
		Difficulty: req.Difficulty,
		Equipment:  req.Equipment,
		FocusAreas: req.FocusAreas,
	})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "生成AI训练计划成功",
		"data":    plan,
	})
}

// StartWorkout 开始训练
func (h *TrainingHandler) StartWorkout(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	var req models.StartWorkoutRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	record, err := h.trainingService.StartWorkout(userID, req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "开始训练成功",
		"data":    record,
	})
}

// EndWorkout 结束训练
func (h *TrainingHandler) EndWorkout(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	var req models.EndWorkoutRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	record, err := h.trainingService.EndWorkout(userID, req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "结束训练成功",
		"data":    record,
	})
}

// CompleteExercise 完成动作
func (h *TrainingHandler) CompleteExercise(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	var req models.CompleteExerciseRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := h.trainingService.CompleteExercise(userID, req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "完成动作成功",
	})
}

// SubmitFeedback 提交动作反馈
func (h *TrainingHandler) SubmitFeedback(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	var req models.SubmitFeedbackRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	feedback, err := h.trainingService.SubmitFeedback(userID, req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "提交反馈成功",
		"data":    feedback,
	})
}

// GetTrainingStats 获取训练统计
func (h *TrainingHandler) GetTrainingStats(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	stats, err := h.trainingService.GetTrainingStats(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取训练统计成功",
		"data":    stats,
	})
}
