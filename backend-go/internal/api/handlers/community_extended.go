package handlers

import (
	"encoding/json"
	"fmt"
	"math"
	"net/http"
	"strconv"
	"time"

	"fittracker/internal/domain/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// CommunityRequest 社区相关请求结构体
type CommunityRequest struct {
	Content     string   `json:"content" binding:"required"`
	Images      []string `json:"images"`
	VideoURL    string   `json:"video_url"`
	Type        string   `json:"type"`
	Tags        []string `json:"tags"`
	Location    string   `json:"location"`
	WorkoutData string   `json:"workout_data"`
	IsPublic    bool     `json:"is_public"`
}

// CommentRequest 评论请求
type CommentRequest struct {
	Content       string `json:"content" binding:"required"`
	ParentID      *uint  `json:"parent_id"`
	ReplyToUserID *uint  `json:"reply_to_user_id"`
}

// TopicRequest 话题请求
type TopicRequest struct {
	Name        string `json:"name" binding:"required"`
	Description string `json:"description"`
	Icon        string `json:"icon"`
	Color       string `json:"color"`
}

// ChallengeRequest 挑战创建请求
type ChallengeRequest struct {
	Name            string    `json:"name" binding:"required"`
	Description     string    `json:"description"`
	Type            string    `json:"type" binding:"required"`
	Difficulty      string    `json:"difficulty" binding:"required"`
	StartDate       time.Time `json:"start_date" binding:"required"`
	EndDate         time.Time `json:"end_date" binding:"required"`
	CoverImage      string    `json:"cover_image"`
	Rules           string    `json:"rules"`
	Rewards         string    `json:"rewards"`
	Tags            []string  `json:"tags"`
	MaxParticipants *int      `json:"max_participants"`
	EntryFee        float64   `json:"entry_fee"`
}

// ChallengeCheckinRequest 挑战打卡请求
type ChallengeCheckinRequest struct {
	Content  string   `json:"content"`
	Images   []string `json:"images"`
	Calories int      `json:"calories"`
	Duration int      `json:"duration"`
	Notes    string   `json:"notes"`
}

// GetFeed 获取推荐流
func (h *Handlers) GetFeed(c *gin.Context) {
	userID, _ := c.Get("user_id")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	sortBy := c.DefaultQuery("sort", "hot") // hot, latest, following

	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 50 {
		limit = 10
	}

	offset := (page - 1) * limit

	var posts []models.Post
	query := h.DB.Where("is_public = ?", true).Preload("User").Preload("Topics")

	// 根据排序方式调整查询
	switch sortBy {
	case "following":
		// 关注用户的动态优先
		var followingIDs []uint
		h.DB.Model(&models.Follow{}).Where("follower_id = ?", userID).Pluck("following_id", &followingIDs)
		if len(followingIDs) > 0 {
			query = query.Where("user_id IN ? OR user_id = ?", followingIDs, userID)
		}
		query = query.Order("created_at DESC")
	case "hot":
		// 热度排序（点赞+评论+浏览+精选加权）
		query = query.Order("(likes_count + comments_count * 2 + view_count * 0.1 + CASE WHEN is_featured THEN 50 ELSE 0 END) DESC, created_at DESC")
	default:
		query = query.Order("created_at DESC")
	}

	var total int64
	query.Model(&models.Post{}).Count(&total)

	if err := query.Offset(offset).Limit(limit).Find(&posts).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取推荐流失败",
			"code":  "DATABASE_ERROR",
		})
		return
	}

	// 记录浏览
	go h.recordPostViews(posts, userID, c.ClientIP(), c.GetHeader("User-Agent"))

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

	var req CommunityRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "请求参数错误",
			"code":  "INVALID_REQUEST",
		})
		return
	}

	// 处理图片数组
	imagesJSON, _ := json.Marshal(req.Images)
	tagsJSON, _ := json.Marshal(req.Tags)

	post := &models.Post{
		UserID:      userID.(uint),
		Content:     req.Content,
		Images:      string(imagesJSON),
		VideoURL:    req.VideoURL,
		Type:        req.Type,
		Tags:        string(tagsJSON),
		Location:    req.Location,
		WorkoutData: req.WorkoutData,
		IsPublic:    req.IsPublic,
	}

	if err := h.DB.Create(post).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "发布动态失败",
			"code":  "CREATION_ERROR",
		})
		return
	}

	// 处理话题关联
	if len(req.Tags) > 0 {
		h.processPostTopics(post.ID, req.Tags)
	}

	// 预加载关联数据，确保用户信息正确加载
	if err := h.DB.Preload("User").Preload("Topics").First(post, post.ID).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取动态详情失败",
			"code":  "DATABASE_ERROR",
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "发布成功",
		"data":    post,
	})
}

// GetPost 获取单个动态详情
func (h *Handlers) GetPost(c *gin.Context) {
	postID := c.Param("id")
	userID, _ := c.Get("user_id")

	var post models.Post
	if err := h.DB.Preload("User").Preload("Topics").Preload("Comments", func(db *gorm.DB) *gorm.DB {
		return db.Preload("User").Preload("Replies").Order("created_at ASC")
	}).First(&post, postID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "动态不存在",
			"code":  "POST_NOT_FOUND",
		})
		return
	}

	// 记录浏览
	go h.recordPostView(post.ID, userID, c.ClientIP(), c.GetHeader("User-Agent"))

	c.JSON(http.StatusOK, gin.H{
		"data": post,
	})
}

// LikePost 点赞/取消点赞动态
func (h *Handlers) LikePost(c *gin.Context) {
	userID, _ := c.Get("user_id")
	postID := c.Param("id")

	// 检查是否已经点赞
	var existingLike models.Like
	if err := h.DB.Where("user_id = ? AND post_id = ?", userID, postID).First(&existingLike).Error; err == nil {
		// 取消点赞
		if err := h.DB.Delete(&existingLike).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "取消点赞失败",
				"code":  "DELETE_ERROR",
			})
			return
		}

		// 更新动态点赞数
		h.DB.Model(&models.Post{}).Where("id = ?", postID).Update("likes_count", gorm.Expr("likes_count - 1"))

		c.JSON(http.StatusOK, gin.H{
			"message": "取消点赞成功",
			"liked":   false,
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

	// 更新动态点赞数
	h.DB.Model(&models.Post{}).Where("id = ?", postID).Update("likes_count", gorm.Expr("likes_count + 1"))

	// 发送通知
	go h.sendNotification(uint(postIDUint), userID.(uint), "like", "有人点赞了你的动态")

	c.JSON(http.StatusOK, gin.H{
		"message": "点赞成功",
		"liked":   true,
	})
}

// CreateComment 创建评论
func (h *Handlers) CreateComment(c *gin.Context) {
	userID, _ := c.Get("user_id")
	postID := c.Param("id")

	var req CommentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "请求参数错误",
			"code":  "INVALID_REQUEST",
		})
		return
	}

	postIDUint, err := strconv.ParseUint(postID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid post ID"})
		return
	}

	comment := &models.Comment{
		UserID:        userID.(uint),
		PostID:        uint(postIDUint),
		Content:       req.Content,
		ParentID:      req.ParentID,
		ReplyToUserID: req.ReplyToUserID,
	}

	if err := h.DB.Create(comment).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "评论失败",
			"code":  "CREATION_ERROR",
		})
		return
	}

	// 更新动态评论数
	h.DB.Model(&models.Post{}).Where("id = ?", postID).Update("comments_count", gorm.Expr("comments_count + 1"))

	// 预加载关联数据
	h.DB.Preload("User").Preload("ReplyToUser").First(comment, comment.ID)

	// 发送通知
	go h.sendNotification(uint(postIDUint), userID.(uint), "comment", "有人评论了你的动态")

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
	if limit < 1 || limit > 50 {
		limit = 20
	}

	offset := (page - 1) * limit

	var comments []models.Comment
	query := h.DB.Where("post_id = ? AND parent_id IS NULL", postID).
		Preload("User").Preload("Replies", func(db *gorm.DB) *gorm.DB {
		return db.Preload("User").Preload("ReplyToUser").Order("created_at ASC")
	}).Order("created_at DESC")

	var total int64
	query.Model(&models.Comment{}).Count(&total)

	if err := query.Offset(offset).Limit(limit).Find(&comments).Error; err != nil {
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

// FavoritePost 收藏/取消收藏动态
func (h *Handlers) FavoritePost(c *gin.Context) {
	userID, _ := c.Get("user_id")
	postID := c.Param("id")

	// 检查是否已经收藏
	var existingFavorite models.Favorite
	if err := h.DB.Where("user_id = ? AND post_id = ?", userID, postID).First(&existingFavorite).Error; err == nil {
		// 取消收藏
		if err := h.DB.Delete(&existingFavorite).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "取消收藏失败",
				"code":  "DELETE_ERROR",
			})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"message":   "取消收藏成功",
			"favorited": false,
		})
		return
	}

	// 创建收藏记录
	postIDUint, err := strconv.ParseUint(postID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid post ID"})
		return
	}

	favorite := &models.Favorite{
		UserID: userID.(uint),
		PostID: uint(postIDUint),
	}

	if err := h.DB.Create(favorite).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "收藏失败",
			"code":  "CREATION_ERROR",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":   "收藏成功",
		"favorited": true,
	})
}

// GetHotTopics 获取热门话题
func (h *Handlers) GetHotTopics(c *gin.Context) {
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	if limit < 1 || limit > 50 {
		limit = 10
	}

	var topics []models.Topic
	if err := h.DB.Where("is_hot = ? OR posts_count > 0", true).
		Order("posts_count DESC, followers_count DESC").
		Limit(limit).Find(&topics).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取热门话题失败",
			"code":  "DATABASE_ERROR",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": topics,
	})
}

// GetTopicPosts 获取话题相关动态
func (h *Handlers) GetTopicPosts(c *gin.Context) {
	topicName := c.Param("name")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 50 {
		limit = 10
	}

	offset := (page - 1) * limit

	var posts []models.Post
	query := h.DB.Joins("JOIN post_topics ON posts.id = post_topics.post_id").
		Joins("JOIN topics ON post_topics.topic_id = topics.id").
		Where("topics.name = ? AND posts.is_public = ?", topicName, true).
		Preload("User").Preload("Topics").
		Order("posts.created_at DESC")

	var total int64
	query.Model(&models.Post{}).Count(&total)

	if err := query.Offset(offset).Limit(limit).Find(&posts).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取话题动态失败",
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

// SearchPosts 搜索动态
func (h *Handlers) SearchPosts(c *gin.Context) {
	query := c.Query("q")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	searchType := c.DefaultQuery("type", "post") // post, user, topic

	if query == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "搜索关键词不能为空",
			"code":  "INVALID_REQUEST",
		})
		return
	}

	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 50 {
		limit = 10
	}

	offset := (page - 1) * limit
	userID, _ := c.Get("user_id")

	// 记录搜索日志
	go h.recordSearchLog(userID, query, searchType, c.ClientIP())

	var results interface{}
	var total int64

	switch searchType {
	case "post":
		var posts []models.Post
		dbQuery := h.DB.Where("is_public = ? AND (content ILIKE ? OR tags ILIKE ?)", true, "%"+query+"%", "%"+query+"%").
			Preload("User").Preload("Topics").
			Order("created_at DESC")

		dbQuery.Model(&models.Post{}).Count(&total)
		if err := dbQuery.Offset(offset).Limit(limit).Find(&posts).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "搜索动态失败",
				"code":  "DATABASE_ERROR",
			})
			return
		}
		results = posts

	case "user":
		var users []models.User
		dbQuery := h.DB.Where("username ILIKE ? OR bio ILIKE ?", "%"+query+"%", "%"+query+"%").
			Order("followers_count DESC")

		dbQuery.Model(&models.User{}).Count(&total)
		if err := dbQuery.Offset(offset).Limit(limit).Find(&users).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "搜索用户失败",
				"code":  "DATABASE_ERROR",
			})
			return
		}
		results = users

	case "topic":
		var topics []models.Topic
		dbQuery := h.DB.Where("name ILIKE ? OR description ILIKE ?", "%"+query+"%", "%"+query+"%").
			Order("posts_count DESC")

		dbQuery.Model(&models.Topic{}).Count(&total)
		if err := dbQuery.Offset(offset).Limit(limit).Find(&topics).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "搜索话题失败",
				"code":  "DATABASE_ERROR",
			})
			return
		}
		results = topics
	}

	c.JSON(http.StatusOK, gin.H{
		"data": results,
		"pagination": gin.H{
			"page":  page,
			"limit": limit,
			"total": total,
			"pages": int(math.Ceil(float64(total) / float64(limit))),
		},
	})
}

// FollowUser 关注/取消关注用户
func (h *Handlers) FollowUser(c *gin.Context) {
	userID, _ := c.Get("user_id")
	targetUserID := c.Param("id")

	// 不能关注自己
	if fmt.Sprintf("%d", userID.(uint)) == targetUserID {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "不能关注自己",
			"code":  "INVALID_REQUEST",
		})
		return
	}

	targetUserIDUint, err := strconv.ParseUint(targetUserID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	// 检查是否已经关注
	var existingFollow models.Follow
	if err := h.DB.Where("follower_id = ? AND following_id = ?", userID, targetUserIDUint).First(&existingFollow).Error; err == nil {
		// 取消关注
		if err := h.DB.Delete(&existingFollow).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "取消关注失败",
				"code":  "DELETE_ERROR",
			})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"message":   "取消关注成功",
			"following": false,
		})
		return
	}

	// 创建关注记录
	follow := &models.Follow{
		FollowerID:  userID.(uint),
		FollowingID: uint(targetUserIDUint),
	}

	if err := h.DB.Create(follow).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "关注失败",
			"code":  "CREATION_ERROR",
		})
		return
	}

	// 发送通知
	go h.sendNotification(0, userID.(uint), "follow", "有人关注了你")

	c.JSON(http.StatusOK, gin.H{
		"message":   "关注成功",
		"following": true,
	})
}

// GetUserProfile 获取用户主页
func (h *Handlers) GetUserProfile(c *gin.Context) {
	userID := c.Param("id")
	currentUserID, _ := c.Get("user_id")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 50 {
		limit = 10
	}

	offset := (page - 1) * limit

	// 获取用户信息
	var user models.User
	if err := h.DB.Preload("UserTags").First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "用户不存在",
			"code":  "USER_NOT_FOUND",
		})
		return
	}

	// 获取用户动态
	var posts []models.Post
	query := h.DB.Where("user_id = ? AND is_public = ?", userID, true).
		Preload("User").Preload("Topics").
		Order("created_at DESC")

	var total int64
	query.Model(&models.Post{}).Count(&total)

	if err := query.Offset(offset).Limit(limit).Find(&posts).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取用户动态失败",
			"code":  "DATABASE_ERROR",
		})
		return
	}

	// 检查是否已关注
	var isFollowing bool
	if currentUserID != nil {
		var follow models.Follow
		if err := h.DB.Where("follower_id = ? AND following_id = ?", currentUserID, userID).First(&follow).Error; err == nil {
			isFollowing = true
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"user":         user,
		"posts":        posts,
		"is_following": isFollowing,
		"pagination": gin.H{
			"page":  page,
			"limit": limit,
			"total": total,
			"pages": int(math.Ceil(float64(total) / float64(limit))),
		},
	})
}

// 辅助方法

// processPostTopics 处理动态话题关联
func (h *Handlers) processPostTopics(postID uint, tags []string) {
	for _, tagName := range tags {
		// 查找或创建话题
		var topic models.Topic
		if err := h.DB.Where("name = ?", tagName).First(&topic).Error; err != nil {
			// 创建新话题
			topic = models.Topic{
				Name:        tagName,
				Description: fmt.Sprintf("关于 %s 的讨论", tagName),
				Icon:        "tag",
				Color:       "#FF6B35",
			}
			h.DB.Create(&topic)
		}

		// 创建关联
		postTopic := &models.PostTopic{
			PostID:  postID,
			TopicID: topic.ID,
		}
		h.DB.Create(postTopic)
	}
}

// recordPostView 记录动态浏览
func (h *Handlers) recordPostView(postID uint, userID interface{}, ipAddress, userAgent string) {
	view := &models.PostView{
		PostID:    postID,
		IPAddress: ipAddress,
		UserAgent: userAgent,
	}

	if userID != nil {
		view.UserID = &userID.(uint)
	}

	h.DB.Create(view)

	// 更新动态浏览次数
	h.DB.Model(&models.Post{}).Where("id = ?", postID).Update("view_count", gorm.Expr("view_count + 1"))
}

// recordPostViews 批量记录动态浏览
func (h *Handlers) recordPostViews(posts []models.Post, userID interface{}, ipAddress, userAgent string) {
	for _, post := range posts {
		h.recordPostView(post.ID, userID, ipAddress, userAgent)
	}
}

// sendNotification 发送通知
func (h *Handlers) sendNotification(postID, userID uint, notificationType, content string) {
	// 获取动态作者
	var post models.Post
	if err := h.DB.Preload("User").First(&post, postID).Error; err != nil {
		return
	}

	// 不给自己发通知
	if post.UserID == userID {
		return
	}

	notification := &models.Notification{
		UserID:        post.UserID,
		Type:          notificationType,
		Title:         content,
		Content:       content,
		RelatedUserID: &userID,
		RelatedPostID: &postID,
		IsRead:        false,
	}

	h.DB.Create(notification)
}

// recordSearchLog 记录搜索日志
func (h *Handlers) recordSearchLog(userID interface{}, query, searchType, ipAddress string) {
	searchLog := &models.SearchLog{
		Query:      query,
		SearchType: searchType,
		IPAddress:  ipAddress,
	}

	if userID != nil {
		searchLog.UserID = &userID.(uint)
	}

	h.DB.Create(searchLog)
}
