package main

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"fittracker/internal/api"
	"fittracker/internal/config"
	"fittracker/internal/models"
	"fittracker/internal/services"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"gorm.io/gorm"
)

func TestFitTrackerAPI(t *testing.T) {
	// 设置测试环境
	gin.SetMode(gin.TestMode)

	// 初始化测试数据库
	db := setupTestDB(t)
	defer cleanupTestDB(t, db)

	// 初始化服务
	userService := services.NewUserService(db)
	trainingService := services.NewTrainingService(db)
	communityService := services.NewCommunityService(db)
	messageService := services.NewMessageService(db)
	aiService := services.NewAIService(&config.AIConfig{})

	// 初始化处理器
	handlers := api.NewHandlers(
		userService,
		trainingService,
		communityService,
		messageService,
		aiService,
	)

	// 创建测试路由
	router := setupTestRouter(handlers)

	t.Run("用户注册登录测试", func(t *testing.T) {
		testUserRegistration(t, router)
		testUserLogin(t, router)
	})

	t.Run("训练功能测试", func(t *testing.T) {
		testCreateTrainingPlan(t, router)
		testGetTodayPlan(t, router)
		testGenerateAIPlan(t, router)
		testCompleteExercise(t, router)
	})

	t.Run("社区功能测试", func(t *testing.T) {
		testCreatePost(t, router)
		testLikePost(t, router)
		testFollowUser(t, router)
		testGetFollowingPosts(t, router)
	})

	t.Run("消息功能测试", func(t *testing.T) {
		testCreateChat(t, router)
		testSendMessage(t, router)
		testGetNotifications(t, router)
	})

	t.Run("AI功能测试", func(t *testing.T) {
		testAIChat(t, router)
		testGenerateTrainingPlan(t, router)
	})
}

func testUserRegistration(t *testing.T, router *gin.Engine) {
	registerReq := models.RegisterRequest{
		Username: "testuser",
		Email:    "test@example.com",
		Password: "password123",
		Nickname: "测试用户",
	}

	reqBody, _ := json.Marshal(registerReq)
	req := httptest.NewRequest("POST", "/api/v1/users/register", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusCreated, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.Equal(t, "注册成功", response["message"])
}

func testUserLogin(t *testing.T, router *gin.Engine) {
	loginReq := models.LoginRequest{
		Username: "testuser",
		Password: "password123",
	}

	reqBody, _ := json.Marshal(loginReq)
	req := httptest.NewRequest("POST", "/api/v1/users/login", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.Equal(t, "登录成功", response["message"])
	assert.NotEmpty(t, response["token"])
}

func testCreateTrainingPlan(t *testing.T, router *gin.Engine) {
	token := getAuthToken(t, router)

	planReq := models.CreatePlanRequest{
		Name:        "测试训练计划",
		Description: "这是一个测试训练计划",
		Date:        "2024-01-01",
		Exercises: []models.CreateExerciseRequest{
			{
				Name:         "深蹲",
				Description:  "全身力量训练",
				Category:     "腿",
				Difficulty:   "中级",
				MuscleGroups: []string{"股四头肌", "臀大肌"},
				Equipment:    []string{"自重"},
				Sets: []models.CreateSetRequest{
					{Reps: 15, Weight: 0, RestTime: 60, Order: 1},
					{Reps: 12, Weight: 0, RestTime: 60, Order: 2},
				},
				Order: 1,
			},
		},
	}

	reqBody, _ := json.Marshal(planReq)
	req := httptest.NewRequest("POST", "/api/v1/training/plans", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+token)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusCreated, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.Equal(t, "训练计划创建成功", response["message"])
}

func testGetTodayPlan(t *testing.T, router *gin.Engine) {
	token := getAuthToken(t, router)

	req := httptest.NewRequest("GET", "/api/v1/training/plans/today", nil)
	req.Header.Set("Authorization", "Bearer "+token)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.NotNil(t, response["plan"])
}

func testGenerateAIPlan(t *testing.T, router *gin.Engine) {
	token := getAuthToken(t, router)

	aiReq := models.GenerateAIPlanRequest{
		Goal:       "减脂",
		Duration:   45,
		Difficulty: "中级",
		Equipment:  []string{"自重", "哑铃"},
		FocusAreas: []string{"全身"},
	}

	reqBody, _ := json.Marshal(aiReq)
	req := httptest.NewRequest("POST", "/api/v1/training/plans/ai-generate", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+token)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.Equal(t, "AI训练计划生成成功", response["message"])
}

func testCompleteExercise(t *testing.T, router *gin.Engine) {
	token := getAuthToken(t, router)

	completeReq := models.CompleteExerciseRequest{
		SetIndex: 0,
	}

	reqBody, _ := json.Marshal(completeReq)
	req := httptest.NewRequest("POST", "/api/v1/training/exercises/test_exercise/complete", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+token)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.Equal(t, "动作完成记录成功", response["message"])
}

func testCreatePost(t *testing.T, router *gin.Engine) {
	token := getAuthToken(t, router)

	postReq := models.CreatePostRequest{
		Content: "今天完成了训练！",
		Type:    "text",
		Tags:    []string{"健身", "训练", "打卡"},
	}

	reqBody, _ := json.Marshal(postReq)
	req := httptest.NewRequest("POST", "/api/v1/community/posts", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+token)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusCreated, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.Equal(t, "帖子发布成功", response["message"])
}

func testLikePost(t *testing.T, router *gin.Engine) {
	token := getAuthToken(t, router)

	req := httptest.NewRequest("POST", "/api/v1/community/posts/test_post/like", nil)
	req.Header.Set("Authorization", "Bearer "+token)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.Equal(t, "操作成功", response["message"])
}

func testFollowUser(t *testing.T, router *gin.Engine) {
	token := getAuthToken(t, router)

	req := httptest.NewRequest("POST", "/api/v1/community/users/test_user/follow", nil)
	req.Header.Set("Authorization", "Bearer "+token)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.Equal(t, "关注成功", response["message"])
}

func testGetFollowingPosts(t *testing.T, router *gin.Engine) {
	token := getAuthToken(t, router)

	req := httptest.NewRequest("GET", "/api/v1/community/posts/following", nil)
	req.Header.Set("Authorization", "Bearer "+token)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.NotNil(t, response["posts"])
}

func testCreateChat(t *testing.T, router *gin.Engine) {
	token := getAuthToken(t, router)

	chatReq := models.CreateChatRequest{
		UserID: "test_user_2",
	}

	reqBody, _ := json.Marshal(chatReq)
	req := httptest.NewRequest("POST", "/api/v1/messages/chats", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+token)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusCreated, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.Equal(t, "聊天创建成功", response["message"])
}

func testSendMessage(t *testing.T, router *gin.Engine) {
	token := getAuthToken(t, router)

	messageReq := models.SendMessageRequest{
		Content: "你好！",
		Type:    "text",
	}

	reqBody, _ := json.Marshal(messageReq)
	req := httptest.NewRequest("POST", "/api/v1/messages/chats/test_chat/messages", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+token)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusCreated, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.NotNil(t, response["message"])
}

func testGetNotifications(t *testing.T, router *gin.Engine) {
	token := getAuthToken(t, router)

	req := httptest.NewRequest("GET", "/api/v1/messages/notifications", nil)
	req.Header.Set("Authorization", "Bearer "+token)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.NotNil(t, response["notifications"])
}

func testAIChat(t *testing.T, router *gin.Engine) {
	token := getAuthToken(t, router)

	chatReq := models.AIChatRequest{
		Message: "帮我制定一个减脂训练计划",
		Context: "训练",
	}

	reqBody, _ := json.Marshal(chatReq)
	req := httptest.NewRequest("POST", "/api/v1/ai/chat", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+token)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.NotNil(t, response["message"])
}

func testGenerateTrainingPlan(t *testing.T, router *gin.Engine) {
	token := getAuthToken(t, router)

	planReq := models.GenerateTrainingPlanRequest{
		Goal:       "增肌",
		Duration:   60,
		Difficulty: "高级",
		Equipment:  []string{"杠铃", "哑铃", "器械"},
		FocusAreas: []string{"胸", "背", "腿"},
	}

	reqBody, _ := json.Marshal(planReq)
	req := httptest.NewRequest("POST", "/api/v1/ai/training-plan", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+token)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.Equal(t, "AI训练计划生成成功", response["message"])
}

// 辅助函数
func getAuthToken(t *testing.T, router *gin.Engine) string {
	loginReq := models.LoginRequest{
		Username: "testuser",
		Password: "password123",
	}

	reqBody, _ := json.Marshal(loginReq)
	req := httptest.NewRequest("POST", "/api/v1/users/login", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	var response map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &response)

	return response["token"].(string)
}

func setupTestDB(t *testing.T) *gorm.DB {
	// 这里应该设置测试数据库
	// 为了简化，这里返回nil，实际测试中需要真实的数据库连接
	return nil
}

func cleanupTestDB(t *testing.T, db *gorm.DB) {
	// 清理测试数据
}

func setupTestRouter(handlers *api.Handlers) *gin.Engine {
	router := gin.New()

	// 设置测试路由
	v1 := router.Group("/api/v1")
	{
		// 用户相关
		users := v1.Group("/users")
		{
			users.POST("/register", handlers.Register)
			users.POST("/login", handlers.Login)
		}

		// 训练相关
		training := v1.Group("/training")
		{
			training.GET("/plans/today", handlers.GetTodayPlan)
			training.POST("/plans", handlers.CreatePlan)
			training.POST("/plans/ai-generate", handlers.GenerateAIPlan)
			training.POST("/exercises/:id/complete", handlers.CompleteExercise)
		}

		// 社区相关
		community := v1.Group("/community")
		{
			community.GET("/posts/following", handlers.GetFollowingPosts)
			community.POST("/posts", handlers.CreatePost)
			community.POST("/posts/:id/like", handlers.LikePost)
			community.POST("/users/:id/follow", handlers.FollowUser)
		}

		// 消息相关
		messages := v1.Group("/messages")
		{
			messages.POST("/chats", handlers.CreateChat)
			messages.POST("/chats/:id/messages", handlers.SendMessage)
			messages.GET("/notifications", handlers.GetNotifications)
		}

		// AI相关
		ai := v1.Group("/ai")
		{
			ai.POST("/chat", handlers.AIChat)
			ai.POST("/training-plan", handlers.GenerateTrainingPlan)
		}
	}

	return router
}
