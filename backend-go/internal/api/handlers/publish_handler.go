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

// PublishHandler 发布相关处理器
type PublishHandler struct {
	publishService *services.PublishService
	communityService *services.CommunityService
	notificationService *services.NotificationService
}

// NewPublishHandler 创建发布处理器
func NewPublishHandler(publishService *services.PublishService, communityService *services.CommunityService, notificationService *services.NotificationService) *PublishHandler {
	return &PublishHandler{
		publishService: publishService,
		communityService: communityService,
		notificationService: notificationService,
	}
}

// GetPublishStats 获取发布统计
// GET /api/v1/publish/stats
func (h *PublishHandler) GetPublishStats(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 获取查询参数
	date := c.DefaultQuery("date", time.Now().Format("2006-01-02"))

	stats, err := h.publishService.GetPublishStats(userID, date)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    stats,
	})
}

// GetRecentPosts 获取最近发布
// GET /api/v1/publish/recent
func (h *PublishHandler) GetRecentPosts(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 获取查询参数
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	posts, err := h.publishService.GetRecentPosts(userID, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    posts,
	})
}

// GetPublishHistory 获取发布历史
// GET /api/v1/publish/history
func (h *PublishHandler) GetPublishHistory(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 获取查询参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	postType := c.Query("type") // text, image, video, workout, checkin, nutrition

	posts, total, err := h.publishService.GetPublishHistory(userID, postType, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"posts":      posts,
			"total":      total,
			"page":       page,
			"limit":      limit,
			"total_page": (total + limit - 1) / limit,
		},
	})
}

// GetFavoritePosts 获取收藏的动态
// GET /api/v1/publish/favorites
func (h *PublishHandler) GetFavoritePosts(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 获取查询参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	posts, total, err := h.publishService.GetFavoritePosts(userID, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"posts":      posts,
			"total":      total,
			"page":       page,
			"limit":      limit,
			"total_page": (total + limit - 1) / limit,
		},
	})
}

// CreatePost 创建动态
// POST /api/v1/publish/posts
func (h *PublishHandler) CreatePost(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		Type        string                    `json:"type" binding:"required"` // text, image, video, workout, checkin, nutrition
		Content     string                    `json:"content"`
		Media       []domain.MediaItem        `json:"media"`
		Topics      []string                  `json:"topics"`
		Location    string                    `json:"location"`
		WorkoutData *domain.WorkoutData       `json:"workout_data"`
		CheckInData *domain.CheckInData       `json:"check_in_data"`
		NutritionData *domain.NutritionData   `json:"nutrition_data"`
		IsAnonymous bool                      `json:"is_anonymous"`
		Visibility  string                    `json:"visibility"`
		Tags        []string                  `json:"tags"`
		ScheduledAt *time.Time                `json:"scheduled_at"` // 定时发布
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 验证内容
	if req.Content == "" && len(req.Media) == 0 && req.WorkoutData == nil && req.CheckInData == nil && req.NutritionData == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "内容不能为空"})
		return
	}

	post := &domain.Post{
		UserID:      userID,
		Content:     req.Content,
		Media:       req.Media,
		Topics:      req.Topics,
		Location:    req.Location,
		WorkoutData: req.WorkoutData,
		CheckInData: req.CheckInData,
		NutritionData: req.NutritionData,
		IsAnonymous: req.IsAnonymous,
		Visibility:  req.Visibility,
		Tags:        req.Tags,
		Status:      domain.PostStatusPublished,
	}

	// 如果是定时发布
	if req.ScheduledAt != nil {
		post.Status = domain.PostStatusScheduled
		post.ScheduledAt = req.ScheduledAt
	}

	createdPost, err := h.publishService.CreatePost(post)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 异步处理通知
	go h.notificationService.NotifyPostCreated(createdPost)

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"data":    createdPost,
	})
}

// UpdatePost 更新动态
// PUT /api/v1/publish/posts/:id
func (h *PublishHandler) UpdatePost(c *gin.Context) {
	userID := c.GetString("user_id")
	postID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		Content     string                    `json:"content"`
		Media       []domain.MediaItem        `json:"media"`
		Topics      []string                  `json:"topics"`
		Location    string                    `json:"location"`
		WorkoutData *domain.WorkoutData       `json:"workout_data"`
		CheckInData *domain.CheckInData       `json:"check_in_data"`
		NutritionData *domain.NutritionData   `json:"nutrition_data"`
		Visibility  string                    `json:"visibility"`
		Tags        []string                  `json:"tags"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 检查动态所有权
	post, err := h.publishService.GetPostByID(postID, userID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "动态不存在"})
		return
	}

	if post.UserID != userID {
		c.JSON(http.StatusForbidden, gin.H{"error": "无权限修改此动态"})
		return
	}

	// 更新动态
	post.Content = req.Content
	post.Media = req.Media
	post.Topics = req.Topics
	post.Location = req.Location
	post.WorkoutData = req.WorkoutData
	post.CheckInData = req.CheckInData
	post.NutritionData = req.NutritionData
	post.Visibility = req.Visibility
	post.Tags = req.Tags

	updatedPost, err := h.publishService.UpdatePost(post)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    updatedPost,
	})
}

// DeletePost 删除动态
// DELETE /api/v1/publish/posts/:id
func (h *PublishHandler) DeletePost(c *gin.Context) {
	userID := c.GetString("user_id")
	postID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 检查动态所有权
	post, err := h.publishService.GetPostByID(postID, userID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "动态不存在"})
		return
	}

	if post.UserID != userID {
		c.JSON(http.StatusForbidden, gin.H{"error": "无权限删除此动态"})
		return
	}

	err = h.publishService.DeletePost(postID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "动态删除成功",
	})
}

// RepostContent 转发内容
// POST /api/v1/publish/repost
func (h *PublishHandler) RepostContent(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		OriginalPostID string `json:"original_post_id" binding:"required"`
		Content        string `json:"content"`
		Visibility     string `json:"visibility"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	repost, err := h.publishService.RepostContent(userID, req.OriginalPostID, req.Content, req.Visibility)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 异步处理通知
	go h.notificationService.NotifyRepost(repost)

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"data":    repost,
	})
}

// ToggleFavorite 切换收藏状态
// POST /api/v1/publish/posts/:id/favorite
func (h *PublishHandler) ToggleFavorite(c *gin.Context) {
	userID := c.GetString("user_id")
	postID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	isFavorited, err := h.publishService.ToggleFavorite(userID, postID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"is_favorited": isFavorited,
		},
	})
}

// GetRecommendedTopics 获取推荐话题
// GET /api/v1/publish/topics/recommended
func (h *PublishHandler) GetRecommendedTopics(c *gin.Context) {
	userID := c.GetString("user_id")
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	topics, err := h.publishService.GetRecommendedTopics(userID, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    topics,
	})
}

// GetRecommendedChallenges 获取推荐挑战
// GET /api/v1/publish/challenges/recommended
func (h *PublishHandler) GetRecommendedChallenges(c *gin.Context) {
	userID := c.GetString("user_id")
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "5"))

	challenges, err := h.publishService.GetRecommendedChallenges(userID, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    challenges,
	})
}

// UploadMedia 上传媒体文件
// POST /api/v1/publish/media/upload
func (h *PublishHandler) UploadMedia(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 获取上传的文件
	file, header, err := c.Request.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "文件上传失败"})
		return
	}
	defer file.Close()

	// 获取文件类型
	fileType := c.PostForm("type") // image, video, audio
	if fileType == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "文件类型不能为空"})
		return
	}

	// 上传文件
	mediaItem, err := h.publishService.UploadMedia(userID, file, header, fileType)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    mediaItem,
	})
}

// GetScheduledPosts 获取定时发布
// GET /api/v1/publish/scheduled
func (h *PublishHandler) GetScheduledPosts(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 获取查询参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	posts, total, err := h.publishService.GetScheduledPosts(userID, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"posts":      posts,
			"total":      total,
			"page":       page,
			"limit":      limit,
			"total_page": (total + limit - 1) / limit,
		},
	})
}

// CancelScheduledPost 取消定时发布
// DELETE /api/v1/publish/scheduled/:id
func (h *PublishHandler) CancelScheduledPost(c *gin.Context) {
	userID := c.GetString("user_id")
	postID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	err := h.publishService.CancelScheduledPost(userID, postID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "定时发布已取消",
	})
}

// GetPublishAnalytics 获取发布分析
// GET /api/v1/publish/analytics
func (h *PublishHandler) GetPublishAnalytics(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 获取查询参数
	period := c.DefaultQuery("period", "week") // week, month, year
	startDate := c.Query("start_date")
	endDate := c.Query("end_date")

	analytics, err := h.publishService.GetPublishAnalytics(userID, period, startDate, endDate)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    analytics,
	})
}
