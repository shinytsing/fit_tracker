package handlers

import (
	"net/http"
	"strconv"

	"gymates/internal/models"
	"gymates/pkg/logger"

	"github.com/gin-gonic/gin"
)

// GetBuddyRecommendations 获取搭子推荐列表
func (h *Handlers) GetBuddyRecommendations(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	// 获取查询参数
	skip, _ := strconv.Atoi(c.DefaultQuery("skip", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	if limit > 50 {
		limit = 50
	}

	// 获取推荐
	recommendations, err := h.services.BuddyService.GetBuddyRecommendations(userID, skip, limit)
	if err != nil {
		logger.Error("获取搭子推荐失败", map[string]interface{}{
			"user_id": userID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取推荐失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取推荐成功",
		"data":    recommendations,
	})
}

// RequestBuddy 发送搭子申请
func (h *Handlers) RequestBuddy(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	var requestData models.BuddyRequestCreate
	if err := c.ShouldBindJSON(&requestData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "请求参数错误"})
		return
	}

	// 发送申请
	response, err := h.services.BuddyService.RequestBuddy(userID, requestData)
	if err != nil {
		logger.Error("发送搭子申请失败", map[string]interface{}{
			"user_id":     userID,
			"receiver_id": requestData.ReceiverID,
			"error":       err.Error(),
		})
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	logger.Info("搭子申请发送成功", map[string]interface{}{
		"requester_id": userID,
		"receiver_id":  requestData.ReceiverID,
	})

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "申请发送成功",
		"data":    response,
	})
}

// GetBuddyRequests 获取搭子申请列表
func (h *Handlers) GetBuddyRequests(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	// 获取查询参数
	requestType := c.DefaultQuery("type", "received") // received, sent
	skip, _ := strconv.Atoi(c.DefaultQuery("skip", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	if limit > 50 {
		limit = 50
	}

	// 获取申请列表
	requests, err := h.services.BuddyService.GetBuddyRequests(userID, requestType, skip, limit)
	if err != nil {
		logger.Error("获取搭子申请列表失败", map[string]interface{}{
			"user_id": userID,
			"type":    requestType,
			"error":   err.Error(),
		})
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取申请列表失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取申请列表成功",
		"data":    requests,
	})
}

// AcceptBuddyRequest 接受搭子申请
func (h *Handlers) AcceptBuddyRequest(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	requestIDStr := c.Param("request_id")
	requestID, err := strconv.ParseUint(requestIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "请求ID格式错误"})
		return
	}

	var requestData struct {
		Message string `json:"message"`
	}
	c.ShouldBindJSON(&requestData)

	// 接受申请
	response, err := h.services.BuddyService.AcceptBuddyRequest(uint(requestID), userID, requestData.Message)
	if err != nil {
		logger.Error("接受搭子申请失败", map[string]interface{}{
			"user_id":    userID,
			"request_id": requestID,
			"error":      err.Error(),
		})
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	logger.Info("搭子申请接受成功", map[string]interface{}{
		"user_id":    userID,
		"request_id": requestID,
	})

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "申请接受成功",
		"data":    response,
	})
}

// RejectBuddyRequest 拒绝搭子申请
func (h *Handlers) RejectBuddyRequest(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	requestIDStr := c.Param("request_id")
	requestID, err := strconv.ParseUint(requestIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "请求ID格式错误"})
		return
	}

	var requestData struct {
		Reason string `json:"reason"`
	}
	c.ShouldBindJSON(&requestData)

	// 拒绝申请
	response, err := h.services.BuddyService.RejectBuddyRequest(uint(requestID), userID, requestData.Reason)
	if err != nil {
		logger.Error("拒绝搭子申请失败", map[string]interface{}{
			"user_id":    userID,
			"request_id": requestID,
			"error":      err.Error(),
		})
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	logger.Info("搭子申请拒绝成功", map[string]interface{}{
		"user_id":    userID,
		"request_id": requestID,
	})

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "申请拒绝成功",
		"data":    response,
	})
}

// GetMyBuddies 获取我的搭子列表
func (h *Handlers) GetMyBuddies(c *gin.Context) {
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

	// 获取搭子列表
	buddies, err := h.services.BuddyService.GetMyBuddies(userID, skip, limit)
	if err != nil {
		logger.Error("获取搭子列表失败", map[string]interface{}{
			"user_id": userID,
			"error":   err.Error(),
		})
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取搭子列表失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "获取搭子列表成功",
		"data":    buddies,
	})
}

// DeleteBuddy 删除搭子关系
func (h *Handlers) DeleteBuddy(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	buddyID := c.Param("buddy_id")
	if buddyID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "搭子ID不能为空"})
		return
	}

	// 删除搭子关系
	err := h.services.BuddyService.DeleteBuddy(userID, buddyID)
	if err != nil {
		logger.Error("删除搭子关系失败", map[string]interface{}{
			"user_id":  userID,
			"buddy_id": buddyID,
			"error":    err.Error(),
		})
		c.JSON(http.StatusInternalServerError, gin.H{"error": "删除搭子关系失败"})
		return
	}

	logger.Info("搭子关系删除成功", map[string]interface{}{
		"user_id":  userID,
		"buddy_id": buddyID,
	})

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "搭子关系删除成功",
	})
}
