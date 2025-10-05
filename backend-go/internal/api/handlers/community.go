package handlers

import (
	"math"
	"net/http"
	"strconv"
	"strings"
	"time"

	"gymates/internal/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// PostRequest 动态发布请求
type PostRequest struct {
	Content  string   `json:"content" binding:"required"`
	Images   []string `json:"images"`
	Type     string   `json:"type"`
	IsPublic bool     `json:"is_public"`
}

// CommentRequest 评论请求
type CommentRequest struct {
	Content string `json:"content" binding:"required"`
}

// ChallengeRequest 挑战创建请求
type ChallengeRequest struct {
	Name        string    `json:"name" binding:"required"`
	Description string    `json:"description"`
	Type        string    `json:"type" binding:"required"`
	Difficulty  string    `json:"difficulty" binding:"required"`
	StartDate   time.Time `json:"start_date" binding:"required"`
	EndDate     time.Time `json:"end_date" binding:"required"`
}

// GetPosts 获取社区动态
func (h *Handlers) GetPosts(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	postType := c.Query("type")

	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 10
	}

	offset := (page - 1) * limit

	var posts []models.Post
	query := h.DB.Where("is_public = ?", true).Preload("User").Preload("Likes").Preload("Comments")

	if postType != "" {
		query = query.Where("type = ?", postType)
	}

	var total int64
	query.Model(&models.Post{}).Count(&total)

	if err := query.Offset(offset).Limit(limit).Order("created_at DESC").Find(&posts).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取动态失败",
			"code":  "DATABASE_ERROR",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": posts,
		"pagination": gin.H{
			"page":  page,
			"limit": limit,
			"total": total,
			"pages": int(math.Ceil(float64(total) / float64(limit))),
		},
	})
}

// CreatePost 发布动态
func (h *Handlers) CreatePost(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var req PostRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "请求参数错误",
			"code":    "INVALID_REQUEST",
			"details": err.Error(),
		})
		return
	}

	// 处理图片数组
	var imagesStr string
	if len(req.Images) > 0 {
		imagesStr = strings.Join(req.Images, ",")
	}

	post := &models.Post{
		UserID:   userID.(uint),
		Content:  req.Content,
		Images:   imagesStr,
		Type:     req.Type,
		IsPublic: req.IsPublic,
	}

	if err := h.DB.Create(post).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "发布动态失败",
			"code":  "CREATION_ERROR",
		})
		return
	}

	// 更新热门动态
	if h.Cache != nil && req.IsPublic {
		h.Cache.AddHotPost(post.ID, float64(time.Now().Unix()))
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "动态发布成功",
		"data":    post,
	})
}

// GetPost 获取单个动态
func (h *Handlers) GetPost(c *gin.Context) {
	postID := c.Param("id")

	var post models.Post
	if err := h.DB.Where("id = ?", postID).Preload("User").Preload("Likes").Preload("Comments").First(&post).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{
				"error": "动态不存在",
				"code":  "POST_NOT_FOUND",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取动态失败",
			"code":  "DATABASE_ERROR",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": post,
	})
}

// LikePost 点赞动态
func (h *Handlers) LikePost(c *gin.Context) {
	userID, _ := c.Get("user_id")
	postID := c.Param("id")

	// 检查是否已经点赞
	var existingLike models.Like
	if err := h.DB.Where("user_id = ? AND post_id = ?", userID, postID).First(&existingLike).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{
			"error": "已经点赞过了",
			"code":  "ALREADY_LIKED",
		})
		return
	}

	// 创建点赞记录
	postIDUint, err := strconv.ParseUint(postID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid post ID"})
		return
	}
	like := &models.Like{
		UserID: userID.(uint),
		PostID: uint(postIDUint),
	}

	if err := h.DB.Create(like).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "点赞失败",
			"code":  "CREATION_ERROR",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "点赞成功",
	})
}

// UnlikePost 取消点赞
func (h *Handlers) UnlikePost(c *gin.Context) {
	userID, _ := c.Get("user_id")
	postID := c.Param("id")

	if err := h.DB.Where("user_id = ? AND post_id = ?", userID, postID).Delete(&models.Like{}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "取消点赞失败",
			"code":  "DELETE_ERROR",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "取消点赞成功",
	})
}

// CreateComment 创建评论
func (h *Handlers) CreateComment(c *gin.Context) {
	userID, _ := c.Get("user_id")
	postID := c.Param("id")

	var req CommentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "请求参数错误",
			"code":    "INVALID_REQUEST",
			"details": err.Error(),
		})
		return
	}

	postIDUint, err := strconv.ParseUint(postID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid post ID"})
		return
	}
	comment := &models.Comment{
		UserID:  userID.(uint),
		PostID:  uint(postIDUint),
		Content: req.Content,
	}

	if err := h.DB.Create(comment).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "评论失败",
			"code":  "CREATION_ERROR",
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "评论成功",
		"data":    comment,
	})
}

// GetComments 获取评论列表
func (h *Handlers) GetComments(c *gin.Context) {
	postID := c.Param("id")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 20
	}

	offset := (page - 1) * limit

	var comments []models.Comment
	query := h.DB.Where("post_id = ?", postID).Preload("User")

	var total int64
	query.Model(&models.Comment{}).Count(&total)

	if err := query.Offset(offset).Limit(limit).Order("created_at ASC").Find(&comments).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取评论失败",
			"code":  "DATABASE_ERROR",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": comments,
		"pagination": gin.H{
			"page":  page,
			"limit": limit,
			"total": total,
			"pages": int(math.Ceil(float64(total) / float64(limit))),
		},
	})
}

// FollowUser 关注用户
func (h *Handlers) FollowUser(c *gin.Context) {
	userID, _ := c.Get("user_id")
	followingID := c.Param("user_id")

	// 不能关注自己
	if userID == followingID {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "不能关注自己",
			"code":  "CANNOT_FOLLOW_SELF",
		})
		return
	}

	// 检查是否已经关注
	var existingFollow models.Follow
	if err := h.DB.Where("follower_id = ? AND following_id = ?", userID, followingID).First(&existingFollow).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{
			"error": "已经关注过了",
			"code":  "ALREADY_FOLLOWING",
		})
		return
	}

	// 创建关注记录
	followingIDUint, err := strconv.ParseUint(followingID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid following ID"})
		return
	}
	follow := &models.Follow{
		FollowerID:  userID.(uint),
		FollowingID: uint(followingIDUint),
	}

	if err := h.DB.Create(follow).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "关注失败",
			"code":  "CREATION_ERROR",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "关注成功",
	})
}

// UnfollowUser 取消关注
func (h *Handlers) UnfollowUser(c *gin.Context) {
	userID, _ := c.Get("user_id")
	followingID := c.Param("user_id")

	if err := h.DB.Where("follower_id = ? AND following_id = ?", userID, followingID).Delete(&models.Follow{}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "取消关注失败",
			"code":  "DELETE_ERROR",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "取消关注成功",
	})
}

// GetChallenges 获取挑战列表
func (h *Handlers) GetChallenges(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	difficulty := c.Query("difficulty")
	challengeType := c.Query("type")

	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 10
	}

	offset := (page - 1) * limit

	var challenges []models.Challenge
	query := h.DB.Where("is_active = ?", true)

	if difficulty != "" {
		query = query.Where("difficulty = ?", difficulty)
	}
	if challengeType != "" {
		query = query.Where("type = ?", challengeType)
	}

	var total int64
	query.Model(&models.Challenge{}).Count(&total)

	if err := query.Offset(offset).Limit(limit).Order("created_at DESC").Find(&challenges).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取挑战失败",
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

// CreateChallenge 创建挑战
func (h *Handlers) CreateChallenge(c *gin.Context) {
	var req ChallengeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "请求参数错误",
			"code":    "INVALID_REQUEST",
			"details": err.Error(),
		})
		return
	}

	challenge := &models.Challenge{
		Name:        req.Name,
		Description: req.Description,
		Type:        req.Type,
		Difficulty:  req.Difficulty,
		StartDate:   req.StartDate,
		EndDate:     req.EndDate,
		IsActive:    true,
	}

	if err := h.DB.Create(challenge).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "创建挑战失败",
			"code":  "CREATION_ERROR",
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "挑战创建成功",
		"data":    challenge,
	})
}

// JoinChallenge 参与挑战
func (h *Handlers) JoinChallenge(c *gin.Context) {
	userID, _ := c.Get("user_id")
	challengeID := c.Param("id")

	// 检查挑战是否存在
	var challenge models.Challenge
	if err := h.DB.Where("id = ? AND is_active = ?", challengeID, true).First(&challenge).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{
				"error": "挑战不存在",
				"code":  "CHALLENGE_NOT_FOUND",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取挑战失败",
			"code":  "DATABASE_ERROR",
		})
		return
	}

	// 检查是否已经参与
	var existingParticipant models.ChallengeParticipant
	if err := h.DB.Where("user_id = ? AND challenge_id = ?", userID, challengeID).First(&existingParticipant).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{
			"error": "已经参与过这个挑战",
			"code":  "ALREADY_PARTICIPATING",
		})
		return
	}

	// 创建参与记录
	challengeIDUint, err := strconv.ParseUint(challengeID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid challenge ID"})
		return
	}
	participant := &models.ChallengeParticipant{
		UserID:      userID.(uint),
		ChallengeID: uint(challengeIDUint),
		Progress:    0,
	}

	if err := h.DB.Create(participant).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "参与挑战失败",
			"code":  "CREATION_ERROR",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "成功参与挑战",
	})
}

// GetChallengeLeaderboard 获取挑战排行榜
func (h *Handlers) GetChallengeLeaderboard(c *gin.Context) {
	challengeID := c.Param("id")
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	if limit < 1 || limit > 100 {
		limit = 10
	}

	var participants []models.ChallengeParticipant
	if err := h.DB.Where("challenge_id = ?", challengeID).Preload("User").Order("progress DESC").Limit(limit).Find(&participants).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取排行榜失败",
			"code":  "DATABASE_ERROR",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": participants,
	})
}
