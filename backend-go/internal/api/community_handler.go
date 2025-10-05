package api

import (
	"net/http"
	"strconv"

	"gymates/internal/models"
	"gymates/internal/services"

	"github.com/gin-gonic/gin"
)

// CommunityHandler 社区相关API处理器
type CommunityHandler struct {
	communityService *services.CommunityService
}

// NewCommunityHandler 创建社区API处理器
func NewCommunityHandler(communityService *services.CommunityService) *CommunityHandler {
	return &CommunityHandler{
		communityService: communityService,
	}
}

// GetCommunityPosts 获取社区动态
func (h *CommunityHandler) GetCommunityPosts(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	skip, _ := strconv.Atoi(c.DefaultQuery("skip", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	category := c.DefaultQuery("category", "")

	posts, err := h.communityService.GetPosts(userID, skip, limit, category)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取社区动态成功",
		"data":    posts,
	})
}

// CreateCommunityPost 创建社区动态
func (h *CommunityHandler) CreateCommunityPost(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	var req models.CreatePostRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	post, err := h.communityService.CreatePost(userID, req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"code":    201,
		"message": "创建社区动态成功",
		"data":    post,
	})
}

// GetCommunityPost 获取社区动态详情
func (h *CommunityHandler) GetCommunityPost(c *gin.Context) {
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

	post, err := h.communityService.GetPost(postID, userID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取社区动态详情成功",
		"data":    post,
	})
}

// UpdateCommunityPost 更新社区动态
func (h *CommunityHandler) UpdateCommunityPost(c *gin.Context) {
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

	var req models.UpdatePostRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	post, err := h.communityService.UpdatePost(userID, postID, req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "更新社区动态成功",
		"data":    post,
	})
}

// DeleteCommunityPost 删除社区动态
func (h *CommunityHandler) DeleteCommunityPost(c *gin.Context) {
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

	err := h.communityService.DeletePost(userID, postID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "删除社区动态成功",
	})
}

// LikeCommunityPost 点赞社区动态
func (h *CommunityHandler) LikeCommunityPost(c *gin.Context) {
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

	err := h.communityService.LikePost(userID, postID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "点赞成功",
	})
}

// UnlikeCommunityPost 取消点赞社区动态
func (h *CommunityHandler) UnlikeCommunityPost(c *gin.Context) {
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

	err := h.communityService.UnlikePost(userID, postID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "取消点赞成功",
	})
}

// CommentCommunityPost 评论社区动态
func (h *CommunityHandler) CommentCommunityPost(c *gin.Context) {
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

	var req models.CreateCommentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	comment, err := h.communityService.CreateComment(userID, postID, req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"code":    201,
		"message": "评论成功",
		"data":    comment,
	})
}

// GetCommunityComments 获取社区动态评论
func (h *CommunityHandler) GetCommunityComments(c *gin.Context) {
	postID := c.Param("id")
	if postID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "动态ID不能为空"})
		return
	}

	skip, _ := strconv.Atoi(c.DefaultQuery("skip", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	comments, err := h.communityService.GetComments(postID, skip, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取评论成功",
		"data":    comments,
	})
}

// GetTrendingPosts 获取热门动态
func (h *CommunityHandler) GetTrendingPosts(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	skip, _ := strconv.Atoi(c.DefaultQuery("skip", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	posts, err := h.communityService.GetTrendingPosts(userID, skip, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取热门动态成功",
		"data":    posts,
	})
}

// GetRecommendedCoaches 获取推荐教练
func (h *CommunityHandler) GetRecommendedCoaches(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	skip, _ := strconv.Atoi(c.DefaultQuery("skip", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	coaches, err := h.communityService.GetRecommendedCoaches(userID, skip, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取推荐教练成功",
		"data":    coaches,
	})
}
