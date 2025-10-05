package integration

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"

	"fittracker/internal/handlers"
	"fittracker/internal/models"
	"fittracker/internal/services"
)

// 测试数据库设置
func setupTestDB(t *testing.T) *gorm.DB {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	require.NoError(t, err)

	// 自动迁移
	err = db.AutoMigrate(
		&models.User{},
		&models.Gym{},
		&models.GymJoinRequest{},
		&models.GymBuddyGroup{},
		&models.GymBuddyMember{},
		&models.Post{},
	)
	require.NoError(t, err)

	return db
}

// 创建测试用户
func createTestUser(t *testing.T, db *gorm.DB) *models.User {
	user := &models.User{
		ID:       "test-user-1",
		Username: "testuser",
		Email:    "test@example.com",
		Nickname: "测试用户",
	}

	err := db.Create(user).Error
	require.NoError(t, err)

	return user
}

// 创建测试健身房
func createTestGym(t *testing.T, db *gorm.DB) *models.Gym {
	gym := &models.Gym{
		Name:        "测试健身房",
		Address:     "测试地址",
		Description: "测试描述",
		IsActive:    true,
	}

	err := db.Create(gym).Error
	require.NoError(t, err)

	return gym
}

// 测试创建健身房
func TestCreateGym(t *testing.T) {
	db := setupTestDB(t)
	router := setupTestRouter(t, db)

	// 创建测试数据
	user := createTestUser(t, db)

	// 准备请求
	createGymReq := map[string]interface{}{
		"name":        "新健身房",
		"address":     "北京市朝阳区",
		"description": "现代化健身房",
		"lat":         39.9042,
		"lng":         116.4074,
	}

	reqBody, _ := json.Marshal(createGymReq)
	req, _ := http.NewRequest("POST", "/api/v1/gyms", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer test-token")

	// 执行请求
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	// 验证响应
	assert.Equal(t, http.StatusCreated, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	require.NoError(t, err)

	assert.Equal(t, "新健身房", response["name"])
	assert.Equal(t, "北京市朝阳区", response["address"])

	// 验证数据库
	var gym models.Gym
	err = db.Where("name = ?", "新健身房").First(&gym).Error
	require.NoError(t, err)
	assert.Equal(t, "新健身房", gym.Name)
}

// 测试获取健身房列表
func TestGetGyms(t *testing.T) {
	db := setupTestDB(t)
	router := setupTestRouter(t, db)

	// 创建测试数据
	createTestUser(t, db)
	gym1 := createTestGym(t, db)
	gym2 := createTestGym(t, db)
	gym2.Name = "第二个健身房"
	db.Save(gym2)

	// 准备请求
	req, _ := http.NewRequest("GET", "/api/v1/gyms", nil)
	req.Header.Set("Authorization", "Bearer test-token")

	// 执行请求
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	// 验证响应
	assert.Equal(t, http.StatusOK, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	require.NoError(t, err)

	gyms := response["gyms"].([]interface{})
	assert.Len(t, gyms, 2)
}

// 测试加入健身房
func TestJoinGym(t *testing.T) {
	db := setupTestDB(t)
	router := setupTestRouter(t, db)

	// 创建测试数据
	user := createTestUser(t, db)
	gym := createTestGym(t, db)

	// 准备请求
	joinReq := map[string]interface{}{
		"goal":             "增肌",
		"time_slot":        time.Now().Add(24 * time.Hour).Format(time.RFC3339),
		"duration_minutes": 60,
		"experience_level": "beginner",
		"message":          "希望找到健身搭子",
	}

	reqBody, _ := json.Marshal(joinReq)
	req, _ := http.NewRequest("POST", fmt.Sprintf("/api/v1/gyms/%d/join", gym.ID), bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer test-token")

	// 执行请求
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	// 验证响应
	assert.Equal(t, http.StatusCreated, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	require.NoError(t, err)

	assert.Equal(t, "pending", response["status"])
	assert.Equal(t, "增肌", response["goal"])

	// 验证数据库
	var joinRequest models.GymJoinRequest
	err = db.Where("gym_id = ? AND user_id = ?", gym.ID, user.ID).First(&joinRequest).Error
	require.NoError(t, err)
	assert.Equal(t, "pending", joinRequest.Status)
	assert.Equal(t, "增肌", joinRequest.Goal)
}

// 测试获取健身房详情
func TestGetGymDetail(t *testing.T) {
	db := setupTestDB(t)
	router := setupTestRouter(t, db)

	// 创建测试数据
	user := createTestUser(t, db)
	gym := createTestGym(t, db)

	// 创建加入申请
	joinRequest := &models.GymJoinRequest{
		GymID:           gym.ID,
		UserID:          user.ID,
		Status:          "accepted",
		Goal:            "减脂",
		DurationMinutes: 90,
	}
	db.Create(joinRequest)

	// 准备请求
	req, _ := http.NewRequest("GET", fmt.Sprintf("/api/v1/gyms/%d", gym.ID), nil)
	req.Header.Set("Authorization", "Bearer test-token")

	// 执行请求
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	// 验证响应
	assert.Equal(t, http.StatusOK, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	require.NoError(t, err)

	gymData := response["gym"].(map[string]interface{})
	assert.Equal(t, "测试健身房", gymData["name"])

	// 验证统计信息
	assert.Equal(t, float64(1), response["current_buddies_count"])
}

// 测试发布动态
func TestCreatePost(t *testing.T) {
	db := setupTestDB(t)
	router := setupTestRouter(t, db)

	// 创建测试数据
	user := createTestUser(t, db)

	// 准备请求
	createPostReq := map[string]interface{}{
		"content": "今天完成了30分钟的跑步训练！",
		"type":    "workout",
		"tags":    []string{"健身", "跑步"},
	}

	reqBody, _ := json.Marshal(createPostReq)
	req, _ := http.NewRequest("POST", "/api/v1/posts", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer test-token")

	// 执行请求
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	// 验证响应
	assert.Equal(t, http.StatusCreated, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	require.NoError(t, err)

	assert.Equal(t, "今天完成了30分钟的跑步训练！", response["content"])
	assert.Equal(t, "workout", response["type"])

	// 验证数据库
	var post models.Post
	err = db.Where("user_id = ?", user.ID).First(&post).Error
	require.NoError(t, err)
	assert.Equal(t, "今天完成了30分钟的跑步训练！", post.Content)
	assert.Equal(t, "workout", post.Type)
}

// 设置测试路由器
func setupTestRouter(t *testing.T, db *gorm.DB) *gin.Engine {
	gin.SetMode(gin.TestMode)

	// 创建服务
	gymService := services.NewGymService(db)
	postService := services.NewPostService(db)

	// 创建处理器
	gymHandler := handlers.NewGymHandler(gymService)
	postHandler := handlers.NewPostHandler(postService)

	// 创建路由器
	router := gin.New()

	// 添加中间件
	router.Use(func(c *gin.Context) {
		// 模拟认证中间件
		c.Set("user_id", "test-user-1")
		c.Next()
	})

	// 注册路由
	api := router.Group("/api/v1")
	{
		gyms := api.Group("/gyms")
		{
			gyms.POST("", gymHandler.CreateGym)
			gyms.GET("", gymHandler.GetGyms)
			gyms.GET("/:id", gymHandler.GetGymDetail)
			gyms.POST("/:id/join", gymHandler.JoinGym)
		}

		posts := api.Group("/posts")
		{
			posts.POST("", postHandler.CreatePost)
			posts.GET("", postHandler.GetPosts)
		}
	}

	return router
}

// 测试用户注册和登录
func TestUserAuth(t *testing.T) {
	db := setupTestDB(t)
	router := setupTestRouter(t, db)

	// 测试注册
	registerReq := map[string]interface{}{
		"username": "newuser",
		"email":    "newuser@example.com",
		"password": "password123",
		"nickname": "新用户",
	}

	reqBody, _ := json.Marshal(registerReq)
	req, _ := http.NewRequest("POST", "/api/v1/auth/register", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusCreated, w.Code)

	// 测试登录
	loginReq := map[string]interface{}{
		"username": "newuser",
		"password": "password123",
	}

	reqBody, _ = json.Marshal(loginReq)
	req, _ = http.NewRequest("POST", "/api/v1/auth/login", bytes.NewBuffer(reqBody))
	req.Header.Set("Content-Type", "application/json")

	w = httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	require.NoError(t, err)

	assert.NotEmpty(t, response["token"])
	assert.NotEmpty(t, response["user"])
}
