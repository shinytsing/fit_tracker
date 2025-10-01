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

// CommunityHandler 社区相关处理器
type CommunityHandler struct {
	communityService *services.CommunityService
	notificationService *services.NotificationService
}

// NewCommunityHandler 创建社区处理器
func NewCommunityHandler(communityService *services.CommunityService, notificationService *services.NotificationService) *CommunityHandler {
	return &CommunityHandler{
		communityService: communityService,
		notificationService: notificationService,
	}
}

// GetFollowingPosts 获取关注流动态
// GET /api/v1/community/posts/following
func (h *CommunityHandler) GetFollowingPosts(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 获取查询参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	lastPostID := c.Query("last_post_id")

	posts, hasMore, err := h.communityService.GetFollowingPosts(userID, page, limit, lastPostID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"posts":    posts,
			"has_more": hasMore,
			"page":     page,
			"limit":    limit,
		},
	})
}

// GetRecommendPosts 获取推荐流动态
// GET /api/v1/community/posts/recommend
func (h *CommunityHandler) GetRecommendPosts(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 获取查询参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	lastPostID := c.Query("last_post_id")

	posts, hasMore, err := h.communityService.GetRecommendPosts(userID, page, limit, lastPostID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"posts":    posts,
			"has_more": hasMore,
			"page":     page,
			"limit":    limit,
		},
	})
}

// CreatePost 发布动态
// POST /api/v1/community/posts
func (h *CommunityHandler) CreatePost(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		Content     string                    `json:"content" binding:"required"`
		Media       []domain.MediaItem        `json:"media"`
		Topics      []string                  `json:"topics"`
		Location    string                    `json:"location"`
		WorkoutData *domain.WorkoutData       `json:"workout_data"`
		CheckInData *domain.CheckInData       `json:"check_in_data"`
		IsAnonymous bool                      `json:"is_anonymous"`
		Visibility  string                    `json:"visibility"` // public, friends, private
		Tags        []string                  `json:"tags"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 验证内容
	if req.Content == "" && len(req.Media) == 0 && req.WorkoutData == nil && req.CheckInData == nil {
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
		IsAnonymous: req.IsAnonymous,
		Visibility:  req.Visibility,
		Tags:        req.Tags,
		Status:      domain.PostStatusPublished,
	}

	createdPost, err := h.communityService.CreatePost(post)
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

// GetPost 获取动态详情
// GET /api/v1/community/posts/:id
func (h *CommunityHandler) GetPost(c *gin.Context) {
	postID := c.Param("id")
	userID := c.GetString("user_id")

	post, err := h.communityService.GetPostByID(postID, userID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "动态不存在"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    post,
	})
}

// UpdatePost 更新动态
// PUT /api/v1/community/posts/:id
func (h *CommunityHandler) UpdatePost(c *gin.Context) {
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
		Visibility  string                    `json:"visibility"`
		Tags        []string                  `json:"tags"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 检查动态所有权
	post, err := h.communityService.GetPostByID(postID, userID)
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
	post.Visibility = req.Visibility
	post.Tags = req.Tags

	updatedPost, err := h.communityService.UpdatePost(post)
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
// DELETE /api/v1/community/posts/:id
func (h *CommunityHandler) DeletePost(c *gin.Context) {
	userID := c.GetString("user_id")
	postID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 检查动态所有权
	post, err := h.communityService.GetPostByID(postID, userID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "动态不存在"})
		return
	}

	if post.UserID != userID {
		c.JSON(http.StatusForbidden, gin.H{"error": "无权限删除此动态"})
		return
	}

	err = h.communityService.DeletePost(postID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "动态删除成功",
	})
}

// LikePost 点赞/取消点赞动态
// POST /api/v1/community/posts/:id/like
func (h *CommunityHandler) LikePost(c *gin.Context) {
	userID := c.GetString("user_id")
	postID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	isLiked, err := h.communityService.ToggleLike(userID, postID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 异步处理通知
	go h.notificationService.NotifyPostLiked(userID, postID, isLiked)

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"is_liked": isLiked,
		},
	})
}

// CreateComment 创建评论
// POST /api/v1/community/posts/:id/comments
func (h *CommunityHandler) CreateComment(c *gin.Context) {
	userID := c.GetString("user_id")
	postID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		Content    string `json:"content" binding:"required"`
		ParentID   string `json:"parent_id"` // 回复评论的ID
		ReplyToID  string `json:"reply_to_id"` // 回复的用户ID
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	comment := &domain.Comment{
		PostID:    postID,
		UserID:    userID,
		Content:   req.Content,
		ParentID:  req.ParentID,
		ReplyToID: req.ReplyToID,
		Status:    domain.CommentStatusPublished,
	}

	createdComment, err := h.communityService.CreateComment(comment)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 异步处理通知
	go h.notificationService.NotifyCommentCreated(createdComment)

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"data":    createdComment,
	})
}

// GetComments 获取评论列表
// GET /api/v1/community/posts/:id/comments
func (h *CommunityHandler) GetComments(c *gin.Context) {
	postID := c.Param("id")
	userID := c.GetString("user_id")

	// 获取查询参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	sortBy := c.DefaultQuery("sort_by", "created_at") // created_at, like_count

	comments, total, err := h.communityService.GetComments(postID, userID, page, limit, sortBy)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"comments":   comments,
			"total":      total,
			"page":       page,
			"limit":      limit,
			"total_page": (total + limit - 1) / limit,
		},
	})
}

// DeleteComment 删除评论
// DELETE /api/v1/community/comments/:id
func (h *CommunityHandler) DeleteComment(c *gin.Context) {
	userID := c.GetString("user_id")
	commentID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	// 检查评论所有权
	comment, err := h.communityService.GetCommentByID(commentID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "评论不存在"})
		return
	}

	if comment.UserID != userID {
		c.JSON(http.StatusForbidden, gin.H{"error": "无权限删除此评论"})
		return
	}

	err = h.communityService.DeleteComment(commentID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "评论删除成功",
	})
}

// SharePost 分享动态
// POST /api/v1/community/posts/:id/share
func (h *CommunityHandler) SharePost(c *gin.Context) {
	userID := c.GetString("user_id")
	postID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		Platform string `json:"platform"` // wechat, weibo, qq, copy_link
		Message  string `json:"message"`  // 分享时的附加消息
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	shareRecord, err := h.communityService.RecordShare(userID, postID, req.Platform, req.Message)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    shareRecord,
	})
}

// FollowUser 关注/取消关注用户
// POST /api/v1/community/users/:id/follow
func (h *CommunityHandler) FollowUser(c *gin.Context) {
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

	isFollowing, err := h.communityService.ToggleFollow(userID, targetUserID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 异步处理通知
	go h.notificationService.NotifyFollowAction(userID, targetUserID, isFollowing)

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"is_following": isFollowing,
		},
	})
}

// GetUserProfile 获取用户主页
// GET /api/v1/community/users/:id
func (h *CommunityHandler) GetUserProfile(c *gin.Context) {
	userID := c.GetString("user_id")
	targetUserID := c.Param("id")

	profile, err := h.communityService.GetUserProfile(targetUserID, userID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "用户不存在"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    profile,
	})
}

// GetUserPosts 获取用户动态列表
// GET /api/v1/community/users/:id/posts
func (h *CommunityHandler) GetUserPosts(c *gin.Context) {
	targetUserID := c.Param("id")
	userID := c.GetString("user_id")

	// 获取查询参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	posts, total, err := h.communityService.GetUserPosts(targetUserID, userID, page, limit)
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

// GetHotTopics 获取热门话题
// GET /api/v1/community/topics/hot
func (h *CommunityHandler) GetHotTopics(c *gin.Context) {
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	topics, err := h.communityService.GetHotTopics(limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    topics,
	})
}

// GetTopicPosts 获取话题相关动态
// GET /api/v1/community/topics/:name/posts
func (h *CommunityHandler) GetTopicPosts(c *gin.Context) {
	topicName := c.Param("name")
	userID := c.GetString("user_id")

	// 获取查询参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	posts, total, err := h.communityService.GetTopicPosts(topicName, userID, page, limit)
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

// SearchPosts 搜索动态
// GET /api/v1/community/search
func (h *CommunityHandler) SearchPosts(c *gin.Context) {
	userID := c.GetString("user_id")
	query := c.Query("q")
	if query == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "搜索关键词不能为空"})
		return
	}

	// 获取查询参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	searchType := c.DefaultQuery("type", "all") // all, posts, users, topics

	results, total, err := h.communityService.Search(query, userID, searchType, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"results":    results,
			"total":      total,
			"page":       page,
			"limit":      limit,
			"total_page": (total + limit - 1) / limit,
			"query":      query,
			"type":       searchType,
		},
	})
}

// GetChallenges 获取挑战列表
// GET /api/v1/community/challenges
func (h *CommunityHandler) GetChallenges(c *gin.Context) {
	userID := c.GetString("user_id")

	// 获取查询参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	category := c.Query("category")
	status := c.DefaultQuery("status", "active") // active, completed, upcoming

	challenges, total, err := h.communityService.GetChallenges(userID, category, status, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"challenges": challenges,
			"total":      total,
			"page":       page,
			"limit":      limit,
			"total_page": (total + limit - 1) / limit,
		},
	})
}

// GetChallenge 获取挑战详情
// GET /api/v1/community/challenges/:id
func (h *CommunityHandler) GetChallenge(c *gin.Context) {
	challengeID := c.Param("id")
	userID := c.GetString("user_id")

	challenge, err := h.communityService.GetChallengeByID(challengeID, userID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "挑战不存在"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    challenge,
	})
}

// JoinChallenge 参加挑战
// POST /api/v1/community/challenges/:id/join
func (h *CommunityHandler) JoinChallenge(c *gin.Context) {
	userID := c.GetString("user_id")
	challengeID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	err := h.communityService.JoinChallenge(userID, challengeID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "挑战参加成功",
	})
}

// ReportPost 举报动态
// POST /api/v1/community/posts/:id/report
func (h *CommunityHandler) ReportPost(c *gin.Context) {
	userID := c.GetString("user_id")
	postID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	var req struct {
		Reason      string `json:"reason" binding:"required"`
		Description string `json:"description"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := h.communityService.ReportPost(userID, postID, req.Reason, req.Description)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "举报提交成功",
	})
}

// BlockUser 屏蔽用户
// POST /api/v1/community/users/:id/block
func (h *CommunityHandler) BlockUser(c *gin.Context) {
	userID := c.GetString("user_id")
	targetUserID := c.Param("id")

	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权访问"})
		return
	}

	if userID == targetUserID {
		c.JSON(http.StatusBadRequest, gin.H{"error": "不能屏蔽自己"})
		return
	}

	err := h.communityService.BlockUser(userID, targetUserID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "用户屏蔽成功",
	})
}
