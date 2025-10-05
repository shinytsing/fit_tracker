package routes

import (
	"net/http"

	"gymates/internal/api"
	"gymates/internal/services"

	"github.com/gin-gonic/gin"
)

type RouteHandler struct {
	services *services.Services
}

func NewRouteHandler(services *services.Services) *RouteHandler {
	return &RouteHandler{
		services: services,
	}
}

// 用户相关路由
func (h *RouteHandler) Register(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.Register(c)
}

func (h *RouteHandler) Login(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.Login(c)
}

func (h *RouteHandler) GetProfile(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.GetProfile(c)
}

func (h *RouteHandler) UpdateProfile(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.UpdateProfile(c)
}

func (h *RouteHandler) UploadAvatar(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.UploadAvatar(c)
}

// 训练相关路由
func (h *RouteHandler) GetTodayPlan(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.GetTodayPlan(c)
}

func (h *RouteHandler) GetHistoryPlans(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.GetHistoryPlans(c)
}

func (h *RouteHandler) CreatePlan(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.CreatePlan(c)
}

func (h *RouteHandler) UpdatePlan(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.UpdatePlan(c)
}

func (h *RouteHandler) DeletePlan(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.DeletePlan(c)
}

func (h *RouteHandler) GenerateAIPlan(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.GenerateAIPlan(c)
}

// 消息相关路由
func (h *RouteHandler) GetChats(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.GetChats(c)
}

func (h *RouteHandler) CreateChat(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.CreateChat(c)
}

func (h *RouteHandler) GetChat(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.GetChat(c)
}

func (h *RouteHandler) GetMessages(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.GetMessages(c)
}

func (h *RouteHandler) SendMessage(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.SendMessage(c)
}

func (h *RouteHandler) MarkMessageAsRead(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.MarkMessageAsRead(c)
}

func (h *RouteHandler) GetNotifications(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.GetNotifications(c)
}

func (h *RouteHandler) MarkNotificationAsRead(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.MarkNotificationAsRead(c)
}

// 团队相关路由
func (h *RouteHandler) CreateTeam(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.CreateTeam(c)
}

func (h *RouteHandler) GetTeams(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.GetTeams(c)
}

func (h *RouteHandler) GetTeamByID(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.GetTeamByID(c)
}

func (h *RouteHandler) JoinTeam(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.JoinTeam(c)
}

// 中间件
func (h *RouteHandler) authMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		token := c.GetHeader("Authorization")
		if token == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "未提供认证token"})
			c.Abort()
			return
		}

		// 简单的token验证（实际项目中应该使用JWT）
		if token == "Bearer test-token" {
			c.Set("user_id", "1")
			c.Next()
			return
		}

		// 尝试从token中解析用户ID
		userID, err := h.services.AuthService.ValidateToken(token)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "无效的token"})
			c.Abort()
			return
		}

		c.Set("user_id", userID)
		c.Next()
	}
}

// 添加缺失的方法
func (h *RouteHandler) ThirdPartyLogin(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "第三方登录功能开发中"})
}

func (h *RouteHandler) GetBuddies(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "获取搭子列表功能开发中"})
}

func (h *RouteHandler) AddBuddy(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "添加搭子功能开发中"})
}

func (h *RouteHandler) RemoveBuddy(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "移除搭子功能开发中"})
}

func (h *RouteHandler) GetTrainingPlans(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.GetHistoryPlans(c)
}

func (h *RouteHandler) CreateTrainingPlan(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.CreatePlan(c)
}

func (h *RouteHandler) GetTrainingPlan(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "获取训练计划详情功能开发中"})
}

func (h *RouteHandler) UpdateTrainingPlan(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.UpdatePlan(c)
}

func (h *RouteHandler) DeleteTrainingPlan(c *gin.Context) {
	apiHandlers := api.NewHandlers(
		h.services.UserService,
		h.services.AuthService,
		h.services.TrainingService,
		h.services.AIService,
		h.services.MessageService,
		h.services.TeamService,
	)
	apiHandlers.DeletePlan(c)
}

// 社区相关方法
func (h *RouteHandler) GetCommunityPosts(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "获取社区动态列表功能开发中"})
}

func (h *RouteHandler) CreateCommunityPost(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "创建社区动态功能开发中"})
}

func (h *RouteHandler) GetCommunityPost(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "获取社区动态详情功能开发中"})
}

func (h *RouteHandler) UpdateCommunityPost(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "更新社区动态功能开发中"})
}

func (h *RouteHandler) DeleteCommunityPost(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "删除社区动态功能开发中"})
}

func (h *RouteHandler) LikeCommunityPost(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "点赞社区动态功能开发中"})
}

func (h *RouteHandler) CommentCommunityPost(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "评论社区动态功能开发中"})
}

// 健身房相关方法
func (h *RouteHandler) GetGyms(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "获取健身房列表功能开发中"})
}

func (h *RouteHandler) CreateGym(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "创建健身房功能开发中"})
}

func (h *RouteHandler) GetGym(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "获取健身房详情功能开发中"})
}

func (h *RouteHandler) UpdateGym(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "更新健身房功能开发中"})
}

func (h *RouteHandler) DeleteGym(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "删除健身房功能开发中"})
}

func (h *RouteHandler) JoinGym(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "加入健身房功能开发中"})
}

func (h *RouteHandler) AcceptJoinRequest(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "接受加入申请功能开发中"})
}

func (h *RouteHandler) RejectJoinRequest(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "拒绝加入申请功能开发中"})
}

func (h *RouteHandler) GetGymBuddies(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "获取健身房搭子功能开发中"})
}

func (h *RouteHandler) CreateGymDiscount(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "创建健身房折扣功能开发中"})
}

func (h *RouteHandler) CreateGymReview(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "创建健身房评价功能开发中"})
}

func (h *RouteHandler) GetNearbyGyms(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "获取附近健身房功能开发中"})
}

// 休息相关方法
func (h *RouteHandler) StartRest(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "开始休息功能开发中"})
}

func (h *RouteHandler) EndRest(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "结束休息功能开发中"})
}

func (h *RouteHandler) GetRestSessions(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "获取休息会话功能开发中"})
}

func (h *RouteHandler) GetRestFeed(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "获取休息动态流功能开发中"})
}

func (h *RouteHandler) CreateRestPost(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "创建休息动态功能开发中"})
}

func (h *RouteHandler) LikeRestPost(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "点赞休息动态功能开发中"})
}

func (h *RouteHandler) CommentRestPost(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "评论休息动态功能开发中"})
}
