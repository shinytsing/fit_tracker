package api

import (
	"net/http"
	"strconv"

	"gymates/internal/models"
	"gymates/internal/services"

	"github.com/gin-gonic/gin"
)

type Handlers struct {
	userService     *services.UserService
	authService     *services.AuthService
	trainingService *services.TrainingService
	aiService       *services.AIService
	messageService  *services.MessageService
	teamService     *services.TeamService
}

func NewHandlers(
	userService *services.UserService,
	authService *services.AuthService,
	trainingService *services.TrainingService,
	aiService *services.AIService,
	messageService *services.MessageService,
	teamService *services.TeamService,
) *Handlers {
	return &Handlers{
		userService:     userService,
		authService:     authService,
		trainingService: trainingService,
		aiService:       aiService,
		messageService:  messageService,
		teamService:     teamService,
	}
}

// 用户相关API
func (h *Handlers) Register(c *gin.Context) {
	var req models.RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	user, err := h.userService.Register(&req)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userIDUint, err := strconv.ParseUint(user.ID, 10, 32)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "无效的用户ID"})
		return
	}

	token, err := h.authService.GenerateToken(uint(userIDUint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "生成token失败"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "注册成功",
		"token":   token,
		"user":    user,
	})
}

func (h *Handlers) Login(c *gin.Context) {
	var req models.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	user, err := h.userService.Login(&req)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	userIDUint, err := strconv.ParseUint(user.ID, 10, 32)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "无效的用户ID"})
		return
	}

	token, err := h.authService.GenerateToken(uint(userIDUint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "生成token失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "登录成功",
		"token":   token,
		"user":    user,
	})
}

func (h *Handlers) GetProfile(c *gin.Context) {
	userID := c.GetString("user_id")

	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	user, err := h.userService.GetByID(uint(userIDUint))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "用户不存在"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"user": user})
}

func (h *Handlers) UpdateProfile(c *gin.Context) {
	userID := c.GetString("user_id")

	var req models.UpdateProfileRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	err = h.userService.UpdateProfile(uint(userIDUint), &req)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "更新成功",
	})
}

// 训练相关API
func (h *Handlers) GetTodayPlan(c *gin.Context) {
	userID := c.GetString("user_id")

	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	plan, err := h.trainingService.GetTodayPlan(uint(userIDUint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"plan": plan})
}

func (h *Handlers) GenerateAIPlan(c *gin.Context) {
	userID := c.GetString("user_id")

	var req models.GenerateTrainingPlanRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	plan, err := h.trainingService.GenerateAIPlan(uint(userIDUint), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"plan": plan})
}

// 消息相关API
func (h *Handlers) GetChats(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	chats, err := h.messageService.GetChats(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"chats": chats,
	})
}

func (h *Handlers) CreateChat(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	var req models.CreateChatRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	chat, err := h.messageService.CreateChat(uint(userIDUint), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"chat": chat,
	})
}

func (h *Handlers) SendMessage(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	chatIDStr := c.Param("id")
	chatID, err := strconv.ParseUint(chatIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的聊天ID"})
		return
	}

	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	var req models.SendMessageRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	message, err := h.messageService.SendMessage(uint(chatID), uint(userIDUint), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": message,
	})
}

func (h *Handlers) GetNotifications(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	notifications, err := h.messageService.GetNotifications(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"notifications": notifications,
	})
}

// 团队相关API
func (h *Handlers) CreateTeam(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	var req models.CreateTeamRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	team, err := h.teamService.CreateTeam(uint(userIDUint), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"team": team,
	})
}

func (h *Handlers) GetTeams(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	teams, hasMore, err := h.teamService.GetTeams(page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"teams":    teams,
		"has_more": hasMore,
		"page":     page,
		"limit":    limit,
	})
}

func (h *Handlers) GetTeamByID(c *gin.Context) {
	teamIDStr := c.Param("id")
	teamID, err := strconv.ParseUint(teamIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的团队ID"})
		return
	}

	team, err := h.teamService.GetTeamByID(uint(teamID))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"team": team,
	})
}

func (h *Handlers) JoinTeam(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	teamIDStr := c.Param("id")
	teamID, err := strconv.ParseUint(teamIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的团队ID"})
		return
	}

	userIDUint, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	var req models.JoinTeamRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err = h.teamService.JoinTeam(uint(teamID), uint(userIDUint), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "成功加入团队",
	})
}

// 占位符方法 - 暂时返回简单响应
func (h *Handlers) UploadAvatar(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "头像上传功能开发中"})
}

func (h *Handlers) GetHistoryPlans(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"plans": []interface{}{}})
}

func (h *Handlers) CreatePlan(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "创建训练计划功能开发中"})
}

func (h *Handlers) UpdatePlan(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "更新训练计划功能开发中"})
}

func (h *Handlers) DeletePlan(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "删除训练计划功能开发中"})
}

func (h *Handlers) GetChat(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"chat": nil})
}

func (h *Handlers) GetMessages(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"messages": []interface{}{}})
}

func (h *Handlers) MarkMessageAsRead(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "标记已读功能开发中"})
}

func (h *Handlers) MarkNotificationAsRead(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "标记通知已读功能开发中"})
}
