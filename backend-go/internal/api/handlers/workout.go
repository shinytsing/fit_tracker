package handlers

import (
	"math"
	"net/http"
	"strconv"

	"fittracker/internal/domain/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// WorkoutRequest 训练记录请求
type WorkoutRequest struct {
	PlanID     *uint                    `json:"plan_id"`
	Name       string                   `json:"name" binding:"required"`
	Type       string                   `json:"type" binding:"required"`
	Duration   int                      `json:"duration"`
	Calories   int                      `json:"calories"`
	Difficulty string                   `json:"difficulty"`
	Notes      string                   `json:"notes"`
	Rating     float64                  `json:"rating"`
	Exercises  []WorkoutExerciseRequest `json:"exercises"`
}

// WorkoutExerciseRequest 训练动作请求
type WorkoutExerciseRequest struct {
	ExerciseID uint    `json:"exercise_id" binding:"required"`
	Sets       int     `json:"sets"`
	Reps       int     `json:"reps"`
	Duration   int     `json:"duration"`
	Weight     float64 `json:"weight"`
	RestTime   int     `json:"rest_time"`
	Order      int     `json:"order"`
}

// GetWorkouts 获取训练记录
func (h *Handlers) GetWorkouts(c *gin.Context) {
	userID, _ := c.Get("user_id")

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	workoutType := c.Query("type")

	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 10
	}

	offset := (page - 1) * limit

	var workouts []models.Workout
	query := h.DB.Where("user_id = ?", userID).Preload("Plan").Preload("Exercises")

	if workoutType != "" {
		query = query.Where("type = ?", workoutType)
	}

	var total int64
	query.Model(&models.Workout{}).Count(&total)

	if err := query.Offset(offset).Limit(limit).Order("created_at DESC").Find(&workouts).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取训练记录失败",
			"code":  "DATABASE_ERROR",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": workouts,
		"pagination": gin.H{
			"page":  page,
			"limit": limit,
			"total": total,
			"pages": int(math.Ceil(float64(total) / float64(limit))),
		},
	})
}

// CreateWorkout 创建训练记录
func (h *Handlers) CreateWorkout(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var req WorkoutRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "请求参数错误",
			"code":    "INVALID_REQUEST",
			"details": err.Error(),
		})
		return
	}

	workout := &models.Workout{
		UserID:     userID.(uint),
		PlanID:     req.PlanID,
		Name:       req.Name,
		Type:       req.Type,
		Duration:   req.Duration,
		Calories:   req.Calories,
		Difficulty: req.Difficulty,
		Notes:      req.Notes,
		Rating:     req.Rating,
	}

	if err := h.DB.Create(workout).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "创建训练记录失败",
			"code":  "CREATION_ERROR",
		})
		return
	}

	// 添加训练动作
	if len(req.Exercises) > 0 {
		for _, ex := range req.Exercises {
			h.DB.Exec("INSERT INTO workout_exercises (workout_id, exercise_id, sets, reps, duration, weight, rest_time, order_index) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
				workout.ID, ex.ExerciseID, ex.Sets, ex.Reps, ex.Duration, ex.Weight, ex.RestTime, ex.Order)
		}
	}

	// 更新排行榜
	if h.Cache != nil {
		h.Cache.UpdateWorkoutLeaderboard(userID.(uint), req.Calories)
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "训练记录创建成功",
		"data":    workout,
	})
}

// GetWorkout 获取单个训练记录
func (h *Handlers) GetWorkout(c *gin.Context) {
	userID, _ := c.Get("user_id")
	workoutID := c.Param("id")

	var workout models.Workout
	if err := h.DB.Where("id = ? AND user_id = ?", workoutID, userID).Preload("Plan").Preload("Exercises").First(&workout).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{
				"error": "训练记录不存在",
				"code":  "WORKOUT_NOT_FOUND",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取训练记录失败",
			"code":  "DATABASE_ERROR",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": workout,
	})
}

// UpdateWorkout 更新训练记录
func (h *Handlers) UpdateWorkout(c *gin.Context) {
	userID, _ := c.Get("user_id")
	workoutID := c.Param("id")

	var req WorkoutRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "请求参数错误",
			"code":    "INVALID_REQUEST",
			"details": err.Error(),
		})
		return
	}

	var workout models.Workout
	if err := h.DB.Where("id = ? AND user_id = ?", workoutID, userID).First(&workout).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{
				"error": "训练记录不存在",
				"code":  "WORKOUT_NOT_FOUND",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取训练记录失败",
			"code":  "DATABASE_ERROR",
		})
		return
	}

	// 更新训练记录
	updates := map[string]interface{}{
		"name":       req.Name,
		"type":       req.Type,
		"duration":   req.Duration,
		"calories":   req.Calories,
		"difficulty": req.Difficulty,
		"notes":      req.Notes,
		"rating":     req.Rating,
	}

	if req.PlanID != nil {
		updates["plan_id"] = req.PlanID
	}

	if err := h.DB.Model(&workout).Updates(updates).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "更新训练记录失败",
			"code":  "UPDATE_ERROR",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "训练记录更新成功",
		"data":    workout,
	})
}

// DeleteWorkout 删除训练记录
func (h *Handlers) DeleteWorkout(c *gin.Context) {
	userID, _ := c.Get("user_id")
	workoutID := c.Param("id")

	if err := h.DB.Where("id = ? AND user_id = ?", workoutID, userID).Delete(&models.Workout{}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "删除训练记录失败",
			"code":  "DELETE_ERROR",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "训练记录删除成功",
	})
}

// GetTrainingPlans 获取训练计划
func (h *Handlers) GetTrainingPlans(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	difficulty := c.Query("difficulty")
	planType := c.Query("type")

	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 10
	}

	offset := (page - 1) * limit

	var plans []models.TrainingPlan
	query := h.DB.Where("is_public = ?", true)

	if difficulty != "" {
		query = query.Where("difficulty = ?", difficulty)
	}
	if planType != "" {
		query = query.Where("type = ?", planType)
	}

	var total int64
	query.Model(&models.TrainingPlan{}).Count(&total)

	if err := query.Offset(offset).Limit(limit).Order("created_at DESC").Find(&plans).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取训练计划失败",
			"code":  "DATABASE_ERROR",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": plans,
		"pagination": gin.H{
			"page":  page,
			"limit": limit,
			"total": total,
			"pages": int(math.Ceil(float64(total) / float64(limit))),
		},
	})
}

// GetExercises 获取运动动作
func (h *Handlers) GetExercises(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	category := c.Query("category")
	difficulty := c.Query("difficulty")

	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 20
	}

	offset := (page - 1) * limit

	var exercises []models.Exercise
	query := h.DB

	if category != "" {
		query = query.Where("category = ?", category)
	}
	if difficulty != "" {
		query = query.Where("difficulty = ?", difficulty)
	}

	var total int64
	query.Model(&models.Exercise{}).Count(&total)

	if err := query.Offset(offset).Limit(limit).Order("name ASC").Find(&exercises).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取运动动作失败",
			"code":  "DATABASE_ERROR",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": exercises,
		"pagination": gin.H{
			"page":  page,
			"limit": limit,
			"total": total,
			"pages": int(math.Ceil(float64(total) / float64(limit))),
		},
	})
}
