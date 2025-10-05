package handlers

import (
	"net/http"
	"strconv"
	"time"

	"gymates/internal/models"

	"github.com/gin-gonic/gin"
)

// CheckinRequest 签到请求
type CheckinRequest struct {
	Type       string `json:"type" binding:"required"`
	Notes      string `json:"notes"`
	Mood       string `json:"mood"`
	Energy     int    `json:"energy"`
	Motivation int    `json:"motivation"`
}

// GetCheckins 获取签到记录
func (h *Handlers) GetCheckins(c *gin.Context) {
	userID, _ := c.Get("user_id")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "30"))

	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 30
	}

	offset := (page - 1) * limit

	var checkins []models.Checkin
	if err := h.DB.Where("user_id = ?", userID).Preload("User").Offset(offset).Limit(limit).Order("date DESC").Find(&checkins).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取签到记录失败",
			"code":  "DATABASE_ERROR",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": checkins,
	})
}

// CreateCheckin 创建签到记录
func (h *Handlers) CreateCheckin(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var req CheckinRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "请求参数错误",
			"code":    "INVALID_REQUEST",
			"details": err.Error(),
		})
		return
	}

	// 检查今天是否已经签到
	today := time.Now().Format("2006-01-02")
	var existingCheckin models.Checkin
	if err := h.DB.Where("user_id = ? AND DATE(date) = ?", userID, today).First(&existingCheckin).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{
			"error": "今天已经签到过了",
			"code":  "ALREADY_CHECKED_IN",
		})
		return
	}

	checkin := &models.Checkin{
		UserID:     userID.(uint),
		Date:       time.Now(),
		Type:       req.Type,
		Notes:      req.Notes,
		Mood:       req.Mood,
		Energy:     int64(req.Energy),
		Motivation: int64(req.Motivation),
	}

	if err := h.DB.Create(checkin).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "签到失败",
			"code":  "CREATION_ERROR",
		})
		return
	}

	// 预加载用户信息，确保返回完整的签到记录
	if err := h.DB.Preload("User").First(checkin, checkin.ID).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取签到详情失败",
			"code":  "DATABASE_ERROR",
		})
		return
	}

	// 更新用户签到统计
	h.updateUserCheckinStats(userID.(uint))

	// 更新签到排行榜
	if h.Cache != nil {
		h.Cache.UpdateCheckinLeaderboard(userID.(uint), 1)
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "签到成功",
		"data":    checkin,
	})
}

// GetCheckinCalendar 获取签到日历
func (h *Handlers) GetCheckinCalendar(c *gin.Context) {
	userID, _ := c.Get("user_id")
	year, _ := strconv.Atoi(c.DefaultQuery("year", strconv.Itoa(time.Now().Year())))
	month, _ := strconv.Atoi(c.DefaultQuery("month", strconv.Itoa(int(time.Now().Month()))))

	// 获取该月的签到记录
	var checkins []models.Checkin
	startDate := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.Local)
	endDate := startDate.AddDate(0, 1, -1)

	if err := h.DB.Where("user_id = ? AND date BETWEEN ? AND ?", userID, startDate, endDate).Find(&checkins).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取签到日历失败",
			"code":  "DATABASE_ERROR",
		})
		return
	}

	// 构建日历数据
	calendar := make(map[string]bool)
	for _, checkin := range checkins {
		dateStr := checkin.Date.Format("2006-01-02")
		calendar[dateStr] = true
	}

	c.JSON(http.StatusOK, gin.H{
		"data": calendar,
	})
}

// GetCheckinStreak 获取签到连续天数
func (h *Handlers) GetCheckinStreak(c *gin.Context) {
	userID, _ := c.Get("user_id")

	// 获取最近的签到记录
	var checkins []models.Checkin
	if err := h.DB.Where("user_id = ?", userID).Order("date DESC").Limit(30).Find(&checkins).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取签到记录失败",
			"code":  "DATABASE_ERROR",
		})
		return
	}

	currentStreak := 0
	longestStreak := 0
	tempStreak := 0

	today := time.Now()
	expectedDate := today

	for _, checkin := range checkins {
		checkinDate := checkin.Date.Truncate(24 * time.Hour)
		expectedDate = expectedDate.Truncate(24 * time.Hour)

		if checkinDate.Equal(expectedDate) {
			tempStreak++
			if tempStreak > longestStreak {
				longestStreak = tempStreak
			}
			if currentStreak == 0 {
				currentStreak = tempStreak
			}
			expectedDate = expectedDate.AddDate(0, 0, -1)
		} else if checkinDate.Before(expectedDate) {
			// 有间隔，重置连续天数
			if tempStreak > longestStreak {
				longestStreak = tempStreak
			}
			tempStreak = 0
			expectedDate = checkinDate.AddDate(0, 0, -1)
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"data": gin.H{
			"current_streak": currentStreak,
			"longest_streak": longestStreak,
			"total_checkins": len(checkins),
		},
	})
}

// GetAchievements 获取成就
func (h *Handlers) GetAchievements(c *gin.Context) {
	userID, _ := c.Get("user_id")

	// 获取用户统计
	var user models.User
	if err := h.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "用户不存在",
			"code":  "USER_NOT_FOUND",
		})
		return
	}

	achievements := []gin.H{
		{
			"id":          "first_checkin",
			"name":        "首次签到",
			"description": "完成第一次签到",
			"icon":        "🎯",
			"unlocked":    user.TotalCheckins > 0,
		},
		{
			"id":          "week_streak",
			"name":        "一周坚持",
			"description": "连续签到7天",
			"icon":        "🔥",
			"unlocked":    user.CurrentStreak >= 7,
		},
		{
			"id":          "month_streak",
			"name":        "月度坚持",
			"description": "连续签到30天",
			"icon":        "💪",
			"unlocked":    user.CurrentStreak >= 30,
		},
		{
			"id":          "hundred_checkins",
			"name":        "百日坚持",
			"description": "累计签到100次",
			"icon":        "🏆",
			"unlocked":    user.TotalCheckins >= 100,
		},
		{
			"id":          "first_workout",
			"name":        "健身新手",
			"description": "完成第一次训练",
			"icon":        "💪",
			"unlocked":    user.TotalWorkouts > 0,
		},
		{
			"id":          "workout_master",
			"name":        "训练大师",
			"description": "完成100次训练",
			"icon":        "🥇",
			"unlocked":    user.TotalWorkouts >= 100,
		},
	}

	c.JSON(http.StatusOK, gin.H{
		"data": achievements,
	})
}

// updateUserCheckinStats 更新用户签到统计
func (h *Handlers) updateUserCheckinStats(userID uint) {
	// 计算连续签到天数
	var checkins []models.Checkin
	h.DB.Where("user_id = ?", userID).Order("date DESC").Limit(30).Find(&checkins)

	currentStreak := 0
	longestStreak := 0
	tempStreak := 0

	today := time.Now()
	expectedDate := today

	for _, checkin := range checkins {
		checkinDate := checkin.Date.Truncate(24 * time.Hour)
		expectedDate = expectedDate.Truncate(24 * time.Hour)

		if checkinDate.Equal(expectedDate) {
			tempStreak++
			if tempStreak > longestStreak {
				longestStreak = tempStreak
			}
			if currentStreak == 0 {
				currentStreak = tempStreak
			}
			expectedDate = expectedDate.AddDate(0, 0, -1)
		} else if checkinDate.Before(expectedDate) {
			if tempStreak > longestStreak {
				longestStreak = tempStreak
			}
			tempStreak = 0
			expectedDate = checkinDate.AddDate(0, 0, -1)
		}
	}

	// 更新用户统计
	h.DB.Model(&models.User{}).Where("id = ?", userID).Updates(map[string]interface{}{
		"current_streak": currentStreak,
		"longest_streak": longestStreak,
	})
}
