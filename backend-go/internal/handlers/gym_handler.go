package handlers

import (
	"net/http"
	"strconv"

	"gymates/internal/models"
	"gymates/internal/services"

	"github.com/gin-gonic/gin"
)

// GymHandler 健身房处理器
type GymHandler struct {
	gymService *services.GymService
}

// NewGymHandler 创建健身房处理器
func NewGymHandler(gymService *services.GymService) *GymHandler {
	return &GymHandler{gymService: gymService}
}

// CreateGym 创建健身房
func (h *GymHandler) CreateGym(c *gin.Context) {
	var req models.CreateGymRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "请求参数错误",
			"details": err.Error(),
		})
		return
	}

	// 获取用户ID
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "未授权访问",
		})
		return
	}

	gym, err := h.gymService.CreateGym(&req, userID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "创建健身房失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "健身房创建成功",
		"data":    gym,
	})
}

// GetGyms 获取健身房列表
func (h *GymHandler) GetGyms(c *gin.Context) {
	// 解析查询参数
	latStr := c.Query("lat")
	lngStr := c.Query("lng")
	radiusStr := c.Query("radius")
	pageStr := c.Query("page")
	pageSizeStr := c.Query("page_size")
	search := c.Query("search")

	// 设置默认值
	lat := 0.0
	lng := 0.0
	radius := 0.0
	page := 1
	pageSize := 20

	// 解析参数
	if latStr != "" {
		if parsedLat, err := strconv.ParseFloat(latStr, 64); err == nil {
			lat = parsedLat
		}
	}
	if lngStr != "" {
		if parsedLng, err := strconv.ParseFloat(lngStr, 64); err == nil {
			lng = parsedLng
		}
	}
	if radiusStr != "" {
		if parsedRadius, err := strconv.ParseFloat(radiusStr, 64); err == nil {
			radius = parsedRadius
		}
	}
	if pageStr != "" {
		if parsedPage, err := strconv.Atoi(pageStr); err == nil && parsedPage > 0 {
			page = parsedPage
		}
	}
	if pageSizeStr != "" {
		if parsedPageSize, err := strconv.Atoi(pageSizeStr); err == nil && parsedPageSize > 0 && parsedPageSize <= 100 {
			pageSize = parsedPageSize
		}
	}

	result, err := h.gymService.GetGyms(lat, lng, radius, page, pageSize, search)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "获取健身房列表失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "获取健身房列表成功",
		"data":    result,
	})
}

// GetGymByID 根据ID获取健身房详情
func (h *GymHandler) GetGymByID(c *gin.Context) {
	gymIDStr := c.Param("id")
	gymID, err := strconv.ParseUint(gymIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "无效的健身房ID",
		})
		return
	}

	// 获取用户ID（可选）
	var userID *uint
	if userIDValue, exists := c.Get("user_id"); exists {
		userIDValue := userIDValue.(uint)
		userID = &userIDValue
	}

	result, err := h.gymService.GetGymByID(uint(gymID), userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "获取健身房详情失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "获取健身房详情成功",
		"data":    result,
	})
}

// JoinGym 申请加入健身房
func (h *GymHandler) JoinGym(c *gin.Context) {
	gymIDStr := c.Param("id")
	gymID, err := strconv.ParseUint(gymIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "无效的健身房ID",
		})
		return
	}

	var req models.GymJoinRequestRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "请求参数错误",
			"details": err.Error(),
		})
		return
	}

	// 获取用户ID
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "未授权访问",
		})
		return
	}

	joinRequest, err := h.gymService.JoinGym(uint(gymID), userID.(uint), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "申请加入健身房失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "申请加入健身房成功",
		"data":    joinRequest,
	})
}

// AcceptJoinRequest 接受加入申请
func (h *GymHandler) AcceptJoinRequest(c *gin.Context) {
	gymIDStr := c.Param("id")
	gymID, err := strconv.ParseUint(gymIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "无效的健身房ID",
		})
		return
	}

	var req models.AcceptJoinRequestRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "请求参数错误",
			"details": err.Error(),
		})
		return
	}

	// 获取用户ID
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "未授权访问",
		})
		return
	}

	err = h.gymService.AcceptJoinRequest(uint(gymID), userID.(uint), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "接受申请失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "接受申请成功",
	})
}

// RejectJoinRequest 拒绝加入申请
func (h *GymHandler) RejectJoinRequest(c *gin.Context) {
	gymIDStr := c.Param("id")
	gymID, err := strconv.ParseUint(gymIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "无效的健身房ID",
		})
		return
	}

	requestIDStr := c.Param("request_id")
	requestID, err := strconv.ParseUint(requestIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "无效的申请ID",
		})
		return
	}

	// 获取用户ID
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "未授权访问",
		})
		return
	}

	err = h.gymService.RejectJoinRequest(uint(gymID), userID.(uint), uint(requestID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "拒绝申请失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "拒绝申请成功",
	})
}

// CancelJoinRequest 取消加入申请
func (h *GymHandler) CancelJoinRequest(c *gin.Context) {
	gymIDStr := c.Param("id")
	gymID, err := strconv.ParseUint(gymIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "无效的健身房ID",
		})
		return
	}

	// 获取用户ID
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "未授权访问",
		})
		return
	}

	err = h.gymService.CancelJoinRequest(uint(gymID), userID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "取消申请失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "取消申请成功",
	})
}

// GetGymBuddies 获取健身房搭子列表
func (h *GymHandler) GetGymBuddies(c *gin.Context) {
	gymIDStr := c.Param("id")
	gymID, err := strconv.ParseUint(gymIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "无效的健身房ID",
		})
		return
	}

	buddies, err := h.gymService.GetGymBuddies(uint(gymID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "获取搭子列表失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "获取搭子列表成功",
		"data":    buddies,
	})
}

// CreateGymDiscount 创建折扣策略
func (h *GymHandler) CreateGymDiscount(c *gin.Context) {
	gymIDStr := c.Param("id")
	gymID, err := strconv.ParseUint(gymIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "无效的健身房ID",
		})
		return
	}

	var req models.CreateGymDiscountRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "请求参数错误",
			"details": err.Error(),
		})
		return
	}

	// 获取用户ID
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "未授权访问",
		})
		return
	}

	discount, err := h.gymService.CreateGymDiscount(uint(gymID), userID.(uint), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "创建折扣策略失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "创建折扣策略成功",
		"data":    discount,
	})
}

// CreateGymReview 创建健身房评价
func (h *GymHandler) CreateGymReview(c *gin.Context) {
	gymIDStr := c.Param("id")
	gymID, err := strconv.ParseUint(gymIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "无效的健身房ID",
		})
		return
	}

	var req models.CreateGymReviewRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "请求参数错误",
			"details": err.Error(),
		})
		return
	}

	// 获取用户ID
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "未授权访问",
		})
		return
	}

	review, err := h.gymService.CreateGymReview(uint(gymID), userID.(uint), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "创建评价失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "创建评价成功",
		"data":    review,
	})
}

// UpdateGym 更新健身房信息
func (h *GymHandler) UpdateGym(c *gin.Context) {
	gymIDStr := c.Param("id")
	gymID, err := strconv.ParseUint(gymIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "无效的健身房ID",
		})
		return
	}

	var req models.UpdateGymRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "请求参数错误",
			"details": err.Error(),
		})
		return
	}

	// 获取用户ID
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "未授权访问",
		})
		return
	}

	gym, err := h.gymService.UpdateGym(uint(gymID), userID.(uint), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "更新健身房失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "更新健身房成功",
		"data":    gym,
	})
}

// DeleteGym 删除健身房
func (h *GymHandler) DeleteGym(c *gin.Context) {
	gymIDStr := c.Param("id")
	gymID, err := strconv.ParseUint(gymIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "无效的健身房ID",
		})
		return
	}

	// 获取用户ID
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "未授权访问",
		})
		return
	}

	err = h.gymService.DeleteGym(uint(gymID), userID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "删除健身房失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "删除健身房成功",
	})
}

// GetNearbyGyms 获取附近的健身房
func (h *GymHandler) GetNearbyGyms(c *gin.Context) {
	latStr := c.Query("lat")
	lngStr := c.Query("lng")
	radiusStr := c.Query("radius")
	limitStr := c.Query("limit")

	// 设置默认值
	lat := 0.0
	lng := 0.0
	radius := 10.0 // 默认10公里
	limit := 20

	// 解析参数
	if latStr != "" {
		if parsedLat, err := strconv.ParseFloat(latStr, 64); err == nil {
			lat = parsedLat
		}
	}
	if lngStr != "" {
		if parsedLng, err := strconv.ParseFloat(lngStr, 64); err == nil {
			lng = parsedLng
		}
	}
	if radiusStr != "" {
		if parsedRadius, err := strconv.ParseFloat(radiusStr, 64); err == nil {
			radius = parsedRadius
		}
	}
	if limitStr != "" {
		if parsedLimit, err := strconv.Atoi(limitStr); err == nil && parsedLimit > 0 && parsedLimit <= 100 {
			limit = parsedLimit
		}
	}

	gyms, err := h.gymService.GetNearbyGyms(lat, lng, radius, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "获取附近健身房失败",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "获取附近健身房成功",
		"data":    gyms,
	})
}
