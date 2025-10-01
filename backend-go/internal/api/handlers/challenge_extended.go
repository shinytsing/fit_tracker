package handlers

import (
	"encoding/json"
	"math"
	"net/http"
	"strconv"
	"time"

	"fittracker/internal/domain/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// GetChallenges 获取挑战赛列表
func (h *Handlers) GetChallenges(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	difficulty := c.Query("difficulty")
	challengeType := c.Query("type")
	status := c.DefaultQuery("status", "active") // active, upcoming, ended

	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 50 {
		limit = 10
	}

	offset := (page - 1) * limit

	var challenges []models.Challenge
	query := h.DB.Where("is_active = ?", true)

	// 根据状态筛选
	now := time.Now()
	switch status {
	case "active":
		query = query.Where("start_date <= ? AND end_date >= ?", now, now)
	case "upcoming":
		query = query.Where("start_date > ?", now)
	case "ended":
		query = query.Where("end_date < ?", now)
	}

	// 根据难度筛选
	if difficulty != "" {
		query = query.Where("difficulty = ?", difficulty)
	}

	// 根据类型筛选
	if challengeType != "" {
		query = query.Where("type = ?", challengeType)
	}

	query = query.Order("is_featured DESC, participants_count DESC, created_at DESC")

	var total int64
	query.Model(&models.Challenge{}).Count(&total)

	if err := query.Offset(offset).Limit(limit).Find(&challenges).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取挑战赛失败",
			"code":  "DATABASE_ERROR",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": challenges,
		"pagination": gin.H{
			"page":  page,
			"limit": limit,
			"total": total,
			"pages": int(math.Ceil(float64(total) / float64(limit))),
		},
	})
}

// GetChallenge 获取挑战赛详情
func (h *Handlers) GetChallenge(c *gin.Context) {
	challengeID := c.Param("id")
	userID, _ := c.Get("user_id")

	var challenge models.Challenge
	if err := h.DB.Preload("Participants", func(db *gorm.DB) *gorm.DB {
		return db.Preload("User").Order("rank ASC").Limit(10)
	}).First(&challenge, challengeID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "挑战赛不存在",
			"code":  "CHALLENGE_NOT_FOUND",
		})
		return
	}

	// 检查用户是否已参与
	var isParticipating bool
	var participant *models.ChallengeParticipant
	if userID != nil {
		var p models.ChallengeParticipant
		if err := h.DB.Where("user_id = ? AND challenge_id = ?", userID, challengeID).First(&p).Error; err == nil {
			isParticipating = true
			participant = &p
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"challenge":        challenge,
		"is_participating": isParticipating,
		"participant":      participant,
	})
}

// JoinChallenge 参与挑战赛
func (h *Handlers) JoinChallenge(c *gin.Context) {
	userID, _ := c.Get("user_id")
	challengeID := c.Param("id")

	challengeIDUint, err := strconv.ParseUint(challengeID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid challenge ID"})
		return
	}

	// 检查挑战赛是否存在且可参与
	var challenge models.Challenge
	if err := h.DB.First(&challenge, challengeIDUint).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "挑战赛不存在",
			"code":  "CHALLENGE_NOT_FOUND",
		})
		return
	}

	// 检查挑战赛是否已开始
	now := time.Now()
	if challenge.StartDate.After(now) {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "挑战赛尚未开始",
			"code":  "CHALLENGE_NOT_STARTED",
		})
		return
	}

	// 检查挑战赛是否已结束
	if challenge.EndDate.Before(now) {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "挑战赛已结束",
			"code":  "CHALLENGE_ENDED",
		})
		return
	}

	// 检查是否已经参与
	var existingParticipant models.ChallengeParticipant
	if err := h.DB.Where("user_id = ? AND challenge_id = ?", userID, challengeIDUint).First(&existingParticipant).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{
			"error": "已经参与此挑战赛",
			"code":  "ALREADY_PARTICIPATING",
		})
		return
	}

	// 检查参与人数限制
	if challenge.MaxParticipants != nil {
		var participantCount int64
		h.DB.Model(&models.ChallengeParticipant{}).Where("challenge_id = ?", challengeIDUint).Count(&participantCount)
		if participantCount >= int64(*challenge.MaxParticipants) {
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "挑战赛参与人数已满",
				"code":  "CHALLENGE_FULL",
			})
			return
		}
	}

	// 创建参与记录
	participant := &models.ChallengeParticipant{
		UserID:      userID.(uint),
		ChallengeID: uint(challengeIDUint),
		JoinedAt:    now,
		Status:      "active",
		Progress:    0,
	}

	if err := h.DB.Create(participant).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "参与挑战赛失败",
			"code":  "CREATION_ERROR",
		})
		return
	}

	// 更新挑战赛参与人数
	h.DB.Model(&challenge).Update("participants_count", gorm.Expr("participants_count + 1"))

	// 预加载用户信息
	h.DB.Preload("User").First(participant, participant.ID)

	c.JSON(http.StatusCreated, gin.H{
		"message": "参与挑战赛成功",
		"data":    participant,
	})
}

// LeaveChallenge 退出挑战赛
func (h *Handlers) LeaveChallenge(c *gin.Context) {
	userID, _ := c.Get("user_id")
	challengeID := c.Param("id")

	// 查找参与记录
	var participant models.ChallengeParticipant
	if err := h.DB.Where("user_id = ? AND challenge_id = ?", userID, challengeID).First(&participant).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "未参与此挑战赛",
			"code":  "NOT_PARTICIPATING",
		})
		return
	}

	// 软删除参与记录
	if err := h.DB.Delete(&participant).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "退出挑战赛失败",
			"code":  "DELETE_ERROR",
		})
		return
	}

	// 更新挑战赛参与人数
	h.DB.Model(&models.Challenge{}).Where("id = ?", challengeID).Update("participants_count", gorm.Expr("participants_count - 1"))

	c.JSON(http.StatusOK, gin.H{
		"message": "退出挑战赛成功",
	})
}

// CheckinChallenge 挑战赛打卡
func (h *Handlers) CheckinChallenge(c *gin.Context) {
	userID, _ := c.Get("user_id")
	challengeID := c.Param("id")

	var req ChallengeCheckinRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "请求参数错误",
			"code":  "INVALID_REQUEST",
		})
		return
	}

	challengeIDUint, err := strconv.ParseUint(challengeID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid challenge ID"})
		return
	}

	// 检查是否参与挑战赛
	var participant models.ChallengeParticipant
	if err := h.DB.Where("user_id = ? AND challenge_id = ? AND status = ?", userID, challengeIDUint, "active").First(&participant).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "未参与此挑战赛或挑战赛已结束",
			"code":  "NOT_PARTICIPATING",
		})
		return
	}

	// 检查今天是否已经打卡
	today := time.Now().Truncate(24 * time.Hour)
	var existingCheckin models.ChallengeCheckin
	if err := h.DB.Where("user_id = ? AND challenge_id = ? AND checkin_date = ?", userID, challengeIDUint, today).First(&existingCheckin).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{
			"error": "今天已经打卡过了",
			"code":  "ALREADY_CHECKED_IN",
		})
		return
	}

	// 处理图片数组
	imagesJSON, _ := json.Marshal(req.Images)

	// 创建打卡记录
	checkin := &models.ChallengeCheckin{
		UserID:        userID.(uint),
		ChallengeID:   uint(challengeIDUint),
		ParticipantID: participant.ID,
		CheckinDate:   today,
		Content:       req.Content,
		Images:        string(imagesJSON),
		Calories:      req.Calories,
		Duration:      req.Duration,
		Notes:         req.Notes,
	}

	if err := h.DB.Create(checkin).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "打卡失败",
			"code":  "CREATION_ERROR",
		})
		return
	}

	// 更新参与者统计
	h.DB.Model(&participant).Updates(map[string]interface{}{
		"checkin_count":   gorm.Expr("checkin_count + 1"),
		"total_calories":  gorm.Expr("total_calories + ?", req.Calories),
		"last_checkin_at": now,
	})

	// 计算进度
	var challenge models.Challenge
	h.DB.First(&challenge, challengeIDUint)
	duration := challenge.EndDate.Sub(challenge.StartDate)
	days := int(duration.Hours() / 24)
	progress := int(float64(participant.CheckinCount+1) / float64(days) * 100)
	if progress > 100 {
		progress = 100
	}

	h.DB.Model(&participant).Update("progress", progress)

	// 更新排行榜
	h.updateChallengeLeaderboard(uint(challengeIDUint))

	// 预加载关联数据
	h.DB.Preload("User").First(checkin, checkin.ID)

	c.JSON(http.StatusCreated, gin.H{
		"message": "打卡成功",
		"data":    checkin,
	})
}

// GetChallengeLeaderboard 获取挑战赛排行榜
func (h *Handlers) GetChallengeLeaderboard(c *gin.Context) {
	challengeID := c.Param("id")
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	if limit < 1 || limit > 100 {
		limit = 20
	}

	var participants []models.ChallengeParticipant
	if err := h.DB.Where("challenge_id = ? AND status = ?", challengeID, "active").
		Preload("User").
		Order("checkin_count DESC, total_calories DESC, joined_at ASC").
		Limit(limit).Find(&participants).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取排行榜失败",
			"code":  "DATABASE_ERROR",
		})
		return
	}

	// 更新排名
	for i, participant := range participants {
		h.DB.Model(&participant).Update("rank", i+1)
		participants[i].Rank = &[]int{i + 1}[0]
	}

	c.JSON(http.StatusOK, gin.H{
		"data": participants,
	})
}

// GetUserChallenges 获取用户参与的挑战赛
func (h *Handlers) GetUserChallenges(c *gin.Context) {
	userID, _ := c.Get("user_id")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	status := c.DefaultQuery("status", "active") // active, completed, dropped

	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 50 {
		limit = 10
	}

	offset := (page - 1) * limit

	var participants []models.ChallengeParticipant
	query := h.DB.Where("user_id = ?", userID).Preload("Challenge")

	// 根据状态筛选
	if status != "" {
		query = query.Where("status = ?", status)
	}

	query = query.Order("joined_at DESC")

	var total int64
	query.Model(&models.ChallengeParticipant{}).Count(&total)

	if err := query.Offset(offset).Limit(limit).Find(&participants).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取用户挑战赛失败",
			"code":  "DATABASE_ERROR",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": participants,
		"pagination": gin.H{
			"page":  page,
			"limit": limit,
			"total": total,
			"pages": int(math.Ceil(float64(total) / float64(limit))),
		},
	})
}

// GetChallengeCheckins 获取挑战赛打卡记录
func (h *Handlers) GetChallengeCheckins(c *gin.Context) {
	challengeID := c.Param("id")
	userID, _ := c.Get("user_id")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 50 {
		limit = 20
	}

	offset := (page - 1) * limit

	var checkins []models.ChallengeCheckin
	query := h.DB.Where("challenge_id = ?", challengeID).Preload("User").Preload("Participant")

	// 如果指定了用户ID，只显示该用户的打卡记录
	if userID != nil {
		query = query.Where("user_id = ?", userID)
	}

	query = query.Order("checkin_date DESC")

	var total int64
	query.Model(&models.ChallengeCheckin{}).Count(&total)

	if err := query.Offset(offset).Limit(limit).Find(&checkins).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取打卡记录失败",
			"code":  "DATABASE_ERROR",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": checkins,
		"pagination": gin.H{
			"page":  page,
			"limit": limit,
			"total": total,
			"pages": int(math.Ceil(float64(total) / float64(limit))),
		},
	})
}

// CreateChallenge 创建挑战赛（管理员功能）
func (h *Handlers) CreateChallenge(c *gin.Context) {
	var req ChallengeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "请求参数错误",
			"code":  "INVALID_REQUEST",
		})
		return
	}

	// 验证日期
	if req.EndDate.Before(req.StartDate) {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "结束日期不能早于开始日期",
			"code":  "INVALID_DATE",
		})
		return
	}

	// 处理标签数组
	tagsJSON, _ := json.Marshal(req.Tags)

	challenge := &models.Challenge{
		Name:            req.Name,
		Description:     req.Description,
		Type:            req.Type,
		Difficulty:      req.Difficulty,
		StartDate:       req.StartDate,
		EndDate:         req.EndDate,
		CoverImage:      req.CoverImage,
		Rules:           req.Rules,
		Rewards:         req.Rewards,
		Tags:            string(tagsJSON),
		MaxParticipants: req.MaxParticipants,
		EntryFee:        req.EntryFee,
		IsActive:        true,
	}

	if err := h.DB.Create(challenge).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "创建挑战赛失败",
			"code":  "CREATION_ERROR",
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "创建挑战赛成功",
		"data":    challenge,
	})
}

// 辅助方法

// updateChallengeLeaderboard 更新挑战赛排行榜
func (h *Handlers) updateChallengeLeaderboard(challengeID uint) {
	var participants []models.ChallengeParticipant
	h.DB.Where("challenge_id = ? AND status = ?", challengeID, "active").
		Order("checkin_count DESC, total_calories DESC, joined_at ASC").
		Find(&participants)

	for i, participant := range participants {
		h.DB.Model(&participant).Update("rank", i+1)
	}
}
