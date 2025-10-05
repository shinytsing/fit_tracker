package handlers

import (
	"net/http"
	"strconv"

	"gymates/internal/models"
	"gymates/pkg/logger"

	"github.com/gin-gonic/gin"
)

// GetCommunityPosts 获取社区动态列表
func (h *Handlers) GetCommunityPosts(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	// 获取查询参数
	skip, _ := strconv.Atoi(c.DefaultQuery("skip", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	postType := c.DefaultQuery("type", "all")

	if limit > 50 {
		limit = 50
	}

	// 获取动态列表
	posts, err := h.services.CommunityService.GetPosts(userID, skip, limit, postType)
	if err != nil {
		logger.Error("获取社区动态列表失败", map[string]interface{}{
			"user_id": userID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取动态列表失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取动态列表成功",
		"data":    posts,
	})
}

// CreateCommunityPost 创建社区动态
func (h *Handlers) CreateCommunityPost(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	var requestData models.CreatePostRequest
	if err := c.ShouldBindJSON(&requestData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "请求参数错误"})
		return
	}

	// 创建动态
	response, err := h.services.CommunityService.CreatePost(userID, requestData)
	if err != nil {
		logger.Error("创建社区动态失败", map[string]interface{}{
			"user_id": userID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	logger.Info("社区动态创建成功", map[string]interface{}{
		"user_id": userID,
		"post_id": response.ID,
	})

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "动态创建成功",
		"data":    response,
	})
}

// GetCommunityPost 获取社区动态详情
func (h *Handlers) GetCommunityPost(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	postID := c.Param("id")
	if postID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "动态ID不能为空"})
		return
	}

	// 获取动态详情
	response, err := h.services.CommunityService.GetPost(postID, userID)
	if err != nil {
		logger.Error("获取社区动态详情失败", map[string]interface{}{
			"user_id": userID,
			"post_id": postID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取动态详情成功",
		"data":    response,
	})
}

// UpdateCommunityPost 更新社区动态
func (h *Handlers) UpdateCommunityPost(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	postID := c.Param("id")
	if postID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "动态ID不能为空"})
		return
	}

	var requestData models.UpdatePostRequest
	if err := c.ShouldBindJSON(&requestData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "请求参数错误"})
		return
	}

	// 更新动态
	response, err := h.services.CommunityService.UpdatePost(postID, userID, requestData)
	if err != nil {
		logger.Error("更新社区动态失败", map[string]interface{}{
			"user_id": userID,
			"post_id": postID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	logger.Info("社区动态更新成功", map[string]interface{}{
		"user_id": userID,
		"post_id": postID,
	})

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "动态更新成功",
		"data":    response,
	})
}

// DeleteCommunityPost 删除社区动态
func (h *Handlers) DeleteCommunityPost(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	postID := c.Param("id")
	if postID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "动态ID不能为空"})
		return
	}

	// 删除动态
	err := h.services.CommunityService.DeletePost(postID, userID)
	if err != nil {
		logger.Error("删除社区动态失败", map[string]interface{}{
			"user_id": userID,
			"post_id": postID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	logger.Info("社区动态删除成功", map[string]interface{}{
		"user_id": userID,
		"post_id": postID,
	})

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "动态删除成功",
	})
}

// LikeCommunityPost 点赞社区动态
func (h *Handlers) LikeCommunityPost(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	postID := c.Param("id")
	if postID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "动态ID不能为空"})
		return
	}

	// 点赞动态
	err := h.services.CommunityService.LikePost(postID, userID)
	if err != nil {
		logger.Error("点赞社区动态失败", map[string]interface{}{
			"user_id": userID,
			"post_id": postID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	logger.Info("社区动态点赞成功", map[string]interface{}{
		"user_id": userID,
		"post_id": postID,
	})

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "点赞成功",
	})
}

// UnlikeCommunityPost 取消点赞社区动态
func (h *Handlers) UnlikeCommunityPost(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	postID := c.Param("id")
	if postID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "动态ID不能为空"})
		return
	}

	// 取消点赞动态
	err := h.services.CommunityService.UnlikePost(postID, userID)
	if err != nil {
		logger.Error("取消点赞社区动态失败", map[string]interface{}{
			"user_id": userID,
			"post_id": postID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	logger.Info("社区动态取消点赞成功", map[string]interface{}{
		"user_id": userID,
		"post_id": postID,
	})

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "取消点赞成功",
	})
}

// CommentCommunityPost 评论社区动态
func (h *Handlers) CommentCommunityPost(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	postID := c.Param("id")
	if postID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "动态ID不能为空"})
		return
	}

	var requestData models.CreateCommentRequest
	if err := c.ShouldBindJSON(&requestData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "请求参数错误"})
		return
	}

	// 创建评论
	response, err := h.services.CommunityService.CreateComment(postID, userID, requestData)
	if err != nil {
		logger.Error("评论社区动态失败", map[string]interface{}{
			"user_id": userID,
			"post_id": postID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	logger.Info("社区动态评论成功", map[string]interface{}{
		"user_id":    userID,
		"post_id":    postID,
		"comment_id": response.ID,
	})

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "评论成功",
		"data":    response,
	})
}

// GetCommunityComments 获取动态评论列表
func (h *Handlers) GetCommunityComments(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	postID := c.Param("id")
	if postID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "动态ID不能为空"})
		return
	}

	// 获取查询参数
	skip, _ := strconv.Atoi(c.DefaultQuery("skip", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	if limit > 50 {
		limit = 50
	}

	// 获取评论列表
	comments, err := h.services.CommunityService.GetComments(postID, skip, limit)
	if err != nil {
		logger.Error("获取动态评论列表失败", map[string]interface{}{
			"user_id": userID,
			"post_id": postID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取评论列表失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取评论列表成功",
		"data":    comments,
	})
}

// GetTrendingPosts 获取热门动态
func (h *Handlers) GetTrendingPosts(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	// 获取查询参数
	skip, _ := strconv.Atoi(c.DefaultQuery("skip", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	if limit > 50 {
		limit = 50
	}

	// 获取热门动态
	posts, err := h.services.CommunityService.GetTrendingPosts(userID, skip, limit)
	if err != nil {
		logger.Error("获取热门动态失败", map[string]interface{}{
			"user_id": userID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取热门动态失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取热门动态成功",
		"data":    posts,
	})
}

// GetRecommendedCoaches 获取推荐教练
func (h *Handlers) GetRecommendedCoaches(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	// 获取查询参数
	skip, _ := strconv.Atoi(c.DefaultQuery("skip", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	if limit > 20 {
		limit = 20
	}

	// 获取推荐教练
	coaches, err := h.services.CommunityService.GetRecommendedCoaches(userID, skip, limit)
	if err != nil {
		logger.Error("获取推荐教练失败", map[string]interface{}{
			"user_id": userID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取推荐教练失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取推荐教练成功",
		"data":    coaches,
	})
}
