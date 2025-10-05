package api

import (
	"net/http"
	"strconv"

	"gymates/internal/models"
	"gymates/internal/services"

	"github.com/gin-gonic/gin"
)

// BuddyHandler 搭子相关API处理器
type BuddyHandler struct {
	buddyService *services.BuddyService
}

// NewBuddyHandler 创建搭子API处理器
func NewBuddyHandler(buddyService *services.BuddyService) *BuddyHandler {
	return &BuddyHandler{
		buddyService: buddyService,
	}
}

// GetBuddyRecommendations 获取搭子推荐
func (h *BuddyHandler) GetBuddyRecommendations(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	skip, _ := strconv.Atoi(c.DefaultQuery("skip", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	recommendations, err := h.buddyService.GetBuddyRecommendations(userID, skip, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取搭子推荐成功",
		"data":    recommendations,
	})
}

// RequestBuddy 申请搭子
func (h *BuddyHandler) RequestBuddy(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	var req models.BuddyRequestCreate
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	request, err := h.buddyService.RequestBuddy(userID, req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"code":    201,
		"message": "申请搭子成功",
		"data":    request,
	})
}

// GetBuddyRequests 获取搭子申请
func (h *BuddyHandler) GetBuddyRequests(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	requestType := c.DefaultQuery("type", "received")
	skip, _ := strconv.Atoi(c.DefaultQuery("skip", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	requests, err := h.buddyService.GetBuddyRequests(userID, requestType, skip, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取搭子申请成功",
		"data":    requests,
	})
}

// AcceptBuddyRequest 接受搭子申请
func (h *BuddyHandler) AcceptBuddyRequest(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	requestIDStr := c.Param("id")
	requestID, err := strconv.ParseUint(requestIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "申请ID不能为空"})
		return
	}

	var req struct {
		Message string `json:"message"`
	}
	c.ShouldBindJSON(&req)

	response, err := h.buddyService.AcceptBuddyRequest(uint(requestID), userID, req.Message)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "接受搭子申请成功",
		"data":    response,
	})
}

// RejectBuddyRequest 拒绝搭子申请
func (h *BuddyHandler) RejectBuddyRequest(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	requestIDStr := c.Param("id")
	requestID, err := strconv.ParseUint(requestIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "申请ID不能为空"})
		return
	}

	var req struct {
		Reason string `json:"reason"`
	}
	c.ShouldBindJSON(&req)

	response, err := h.buddyService.RejectBuddyRequest(uint(requestID), userID, req.Reason)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "拒绝搭子申请成功",
		"data":    response,
	})
}

// GetMyBuddies 获取我的搭子
func (h *BuddyHandler) GetMyBuddies(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	skip, _ := strconv.Atoi(c.DefaultQuery("skip", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	buddies, err := h.buddyService.GetMyBuddies(userID, skip, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取我的搭子成功",
		"data":    buddies,
	})
}

// DeleteBuddy 删除搭子
func (h *BuddyHandler) DeleteBuddy(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	buddyID := c.Param("id")
	if buddyID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "搭子ID不能为空"})
		return
	}

	err := h.buddyService.DeleteBuddy(userID, buddyID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "删除搭子成功",
	})
}
