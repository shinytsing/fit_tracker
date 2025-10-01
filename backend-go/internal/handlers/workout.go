package handlers

import (
	"net/http"
	"strconv"
	"time"

	"fittracker/internal/models"
	"fittracker/internal/services"

	"github.com/gin-gonic/gin"
)

type WorkoutHandler struct {
	workoutService *services.WorkoutService
	aiService      *services.AIService
	authService    *services.AuthService
}

func NewWorkoutHandler(workoutService *services.WorkoutService, aiService *services.AIService, authService *services.AuthService) *WorkoutHandler {
	return &WorkoutHandler{
		workoutService: workoutService,
		aiService:      aiService,
		authService:    authService,
	}
}

// CreateWorkoutPlan 创建训练计划
func (h *WorkoutHandler) CreateWorkoutPlan(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var req struct {
		Title       string `json:"title" binding:"required"`
		Description string `json:"description"`
		PlanType    string `json:"plan_type"` // AI生成、教练制定、自定义
		Difficulty  string `json:"difficulty"`
		Duration    int    `json:"duration"`
		IsPublic    bool   `json:"is_public"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	plan := &models.WorkoutPlan{
		UserID:      userID.(uint),
		Title:       req.Title,
		Description: req.Description,
		PlanType:    req.PlanType,
		Difficulty:  req.Difficulty,
		Duration:    req.Duration,
		IsPublic:    req.IsPublic,
	}

	if err := h.workoutService.CreateWorkoutPlan(plan); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Workout plan created successfully",
		"plan":    plan,
	})
}

// GenerateAIWorkoutPlan 生成AI训练计划
func (h *WorkoutHandler) GenerateAIWorkoutPlan(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var req struct {
		Goal        string `json:"goal" binding:"required"`
		Duration    int    `json:"duration" binding:"required"`
		Difficulty  string `json:"difficulty" binding:"required"`
		Experience  string `json:"experience"`
		Equipment   string `json:"equipment"`
		TimePerDay  int    `json:"time_per_day"`
		Preferences string `json:"preferences"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 调用AI服务生成训练计划
	plan, err := h.aiService.GenerateWorkoutPlan(userID.(uint), req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate workout plan"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "AI workout plan generated successfully",
		"plan":    plan,
	})
}

// GetWorkoutPlans 获取训练计划列表
func (h *WorkoutHandler) GetWorkoutPlans(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	isPublic := c.Query("is_public") == "true"

	plans, total, err := h.workoutService.GetWorkoutPlans(userID.(uint), isPublic, page, limit)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"plans": plans,
		"total": total,
		"page":  page,
		"limit": limit,
	})
}

// GetWorkoutPlan 获取单个训练计划
func (h *WorkoutHandler) GetWorkoutPlan(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid plan ID"})
		return
	}

	plan, err := h.workoutService.GetWorkoutPlanByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Workout plan not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"plan": plan})
}

// CreateWorkoutSession 创建训练会话
func (h *WorkoutHandler) CreateWorkoutSession(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var req struct {
		PlanID    *uint             `json:"plan_id"`
		Title     string            `json:"title" binding:"required"`
		Date      time.Time         `json:"date" binding:"required"`
		Duration  int               `json:"duration"`
		Calories  int               `json:"calories"`
		Notes     string            `json:"notes"`
		Exercises []ExerciseRequest `json:"exercises"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	session := &models.WorkoutSession{
		UserID:   userID.(uint),
		PlanID:   req.PlanID,
		Title:    req.Title,
		Date:     req.Date,
		Duration: req.Duration,
		Calories: req.Calories,
		Notes:    req.Notes,
	}

	if err := h.workoutService.CreateWorkoutSession(session, req.Exercises); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Workout session created successfully",
		"session": session,
	})
}

type ExerciseRequest struct {
	Name     string  `json:"name" binding:"required"`
	Category string  `json:"category"`
	Sets     int     `json:"sets"`
	Reps     int     `json:"reps"`
	Weight   float64 `json:"weight"`
	Duration int     `json:"duration"`
	Distance float64 `json:"distance"`
	RestTime int     `json:"rest_time"`
	Notes    string  `json:"notes"`
}

// GetWorkoutSessions 获取训练会话列表
func (h *WorkoutHandler) GetWorkoutSessions(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	planIDStr := c.Query("plan_id")

	var planID *uint
	if planIDStr != "" {
		if id, err := strconv.ParseUint(planIDStr, 10, 32); err == nil {
			pid := uint(id)
			planID = &pid
		}
	}

	sessions, total, err := h.workoutService.GetWorkoutSessions(userID.(uint), planID, page, limit)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"sessions": sessions,
		"total":    total,
		"page":     page,
		"limit":    limit,
	})
}

// CreateCheckIn 创建打卡记录
func (h *WorkoutHandler) CreateCheckIn(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var req struct {
		Date        time.Time `json:"date" binding:"required"`
		WorkoutType string    `json:"workout_type"`
		Duration    int       `json:"duration"`
		Calories    int       `json:"calories"`
		Mood        string    `json:"mood"`
		Notes       string    `json:"notes"`
		Images      string    `json:"images"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	checkIn := &models.CheckIn{
		UserID:      userID.(uint),
		Date:        req.Date,
		WorkoutType: req.WorkoutType,
		Duration:    req.Duration,
		Calories:    req.Calories,
		Mood:        req.Mood,
		Notes:       req.Notes,
		Images:      req.Images,
	}

	if err := h.workoutService.CreateCheckIn(checkIn); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message":  "Check-in created successfully",
		"check_in": checkIn,
	})
}

// GetCheckIns 获取打卡记录列表
func (h *WorkoutHandler) GetCheckIns(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	year := c.Query("year")
	month := c.Query("month")

	checkIns, total, err := h.workoutService.GetCheckIns(userID.(uint), year, month, page, limit)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"check_ins": checkIns,
		"total":     total,
		"page":      page,
		"limit":     limit,
	})
}

// GetWorkoutStats 获取训练统计
func (h *WorkoutHandler) GetWorkoutStats(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	period := c.DefaultQuery("period", "month") // week, month, year

	stats, err := h.workoutService.GetWorkoutStats(userID.(uint), period)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"stats": stats})
}
