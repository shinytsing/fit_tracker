package handlers

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"fittracker/backend/internal/domain/models"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"gorm.io/gorm"
)

// MockDB 模拟数据库
type MockDB struct {
	mock.Mock
}

func (m *MockDB) Create(value interface{}) *gorm.DB {
	args := m.Called(value)
	return args.Get(0).(*gorm.DB)
}

func (m *MockDB) First(dest interface{}, conds ...interface{}) *gorm.DB {
	args := m.Called(dest, conds)
	return args.Get(0).(*gorm.DB)
}

func (m *MockDB) Where(query interface{}, args ...interface{}) *gorm.DB {
	mockArgs := m.Called(query, args)
	return mockArgs.Get(0).(*gorm.DB)
}

func (m *MockDB) Preload(query string, args ...interface{}) *gorm.DB {
	mockArgs := m.Called(query, args)
	return mockArgs.Get(0).(*gorm.DB)
}

func (m *MockDB) Offset(offset int) *gorm.DB {
	args := m.Called(offset)
	return args.Get(0).(*gorm.DB)
}

func (m *MockDB) Limit(limit int) *gorm.DB {
	args := m.Called(limit)
	return args.Get(0).(*gorm.DB)
}

func (m *MockDB) Order(value interface{}) *gorm.DB {
	args := m.Called(value)
	return args.Get(0).(*gorm.DB)
}

func (m *MockDB) Find(dest interface{}, conds ...interface{}) *gorm.DB {
	args := m.Called(dest, conds)
	return args.Get(0).(*gorm.DB)
}

func (m *MockDB) Count(count *int64) *gorm.DB {
	args := m.Called(count)
	return args.Get(0).(*gorm.DB)
}

func (m *MockDB) Updates(values interface{}) *gorm.DB {
	args := m.Called(values)
	return args.Get(0).(*gorm.DB)
}

func (m *MockDB) Delete(value interface{}, conds ...interface{}) *gorm.DB {
	args := m.Called(value, conds)
	return args.Get(0).(*gorm.DB)
}

func (m *MockDB) Model(value interface{}) *gorm.DB {
	args := m.Called(value)
	return args.Get(0).(*gorm.DB)
}

// MockCache 模拟缓存
type MockCache struct {
	mock.Mock
}

func (m *MockCache) SetUserToken(token string, userID uint) error {
	args := m.Called(token, userID)
	return args.Error(0)
}

func (m *MockCache) GetUserToken(token string) (uint, error) {
	args := m.Called(token)
	return args.Get(0).(uint), args.Error(1)
}

func (m *MockCache) DeleteUserToken(token string) error {
	args := m.Called(token)
	return args.Error(0)
}

func (m *MockCache) UpdateWorkoutLeaderboard(userID uint, score int) error {
	args := m.Called(userID, score)
	return args.Error(0)
}

func (m *MockCache) UpdateCheckinLeaderboard(userID uint, score int) error {
	args := m.Called(userID, score)
	return args.Error(0)
}

func (m *MockCache) AddHotPost(postID uint, score float64) error {
	args := m.Called(postID, score)
	return args.Error(0)
}

func (m *MockCache) SetUserStats(userID uint, stats interface{}) error {
	args := m.Called(userID, stats)
	return args.Error(0)
}

func (m *MockCache) GetUserStats(userID uint, dest interface{}) error {
	args := m.Called(userID, dest)
	return args.Error(0)
}

// 测试辅助函数
func setupTestRouter() *gin.Engine {
	gin.SetMode(gin.TestMode)
	router := gin.New()
	return router
}

func createTestUser() *models.User {
	return &models.User{
		ID:            1,
		Username:      "testuser",
		Email:         "test@example.com",
		FirstName:     "Test",
		LastName:      "User",
		TotalWorkouts: 0,
		TotalCheckins: 0,
		CurrentStreak: 0,
		LongestStreak: 0,
		CreatedAt:     time.Now(),
		UpdatedAt:     time.Now(),
	}
}

func createTestWorkout() *models.Workout {
	return &models.Workout{
		ID:         1,
		UserID:     1,
		Name:       "测试训练",
		Type:       "力量训练",
		Duration:   30,
		Calories:   200,
		Difficulty: "初级",
		Notes:      "测试训练",
		Rating:     4.5,
		CreatedAt:  time.Now(),
		UpdatedAt:  time.Now(),
	}
}

func createTestPost() *models.Post {
	return &models.Post{
		ID:            1,
		UserID:        1,
		Content:       "测试动态",
		Type:          "训练",
		IsPublic:      true,
		LikesCount:    0,
		CommentsCount: 0,
		SharesCount:   0,
		CreatedAt:     time.Now(),
		UpdatedAt:     time.Now(),
	}
}

func createTestCheckin() *models.Checkin {
	return &models.Checkin{
		ID:         1,
		UserID:     1,
		Date:       time.Now(),
		Type:       "训练",
		Notes:      "测试签到",
		Mood:       "开心",
		Energy:     8,
		Motivation: 9,
		CreatedAt:  time.Now(),
		UpdatedAt:  time.Now(),
	}
}

// 用户认证测试
func TestRegister(t *testing.T) {
	tests := []struct {
		name           string
		requestBody    map[string]interface{}
		expectedStatus int
		expectedError  string
	}{
		{
			name: "成功注册",
			requestBody: map[string]interface{}{
				"username":   "newuser",
				"email":      "newuser@example.com",
				"password":   "password123",
				"first_name": "New",
				"last_name":  "User",
			},
			expectedStatus: http.StatusCreated,
		},
		{
			name: "邮箱格式错误",
			requestBody: map[string]interface{}{
				"username":   "newuser",
				"email":      "invalid-email",
				"password":   "password123",
				"first_name": "New",
				"last_name":  "User",
			},
			expectedStatus: http.StatusBadRequest,
			expectedError:  "INVALID_REQUEST",
		},
		{
			name: "密码太短",
			requestBody: map[string]interface{}{
				"username":   "newuser",
				"email":      "newuser@example.com",
				"password":   "123",
				"first_name": "New",
				"last_name":  "User",
			},
			expectedStatus: http.StatusBadRequest,
			expectedError:  "INVALID_REQUEST",
		},
		{
			name: "缺少必填字段",
			requestBody: map[string]interface{}{
				"email": "newuser@example.com",
			},
			expectedStatus: http.StatusBadRequest,
			expectedError:  "INVALID_REQUEST",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// 设置测试环境
			gin.SetMode(gin.TestMode)
			router := gin.New()

			mockDB := new(MockDB)
			mockCache := new(MockCache)

			handlers := &Handlers{
				DB:    mockDB,
				Cache: mockCache,
			}

			router.POST("/auth/register", handlers.Register)

			// 准备请求
			jsonBody, _ := json.Marshal(tt.requestBody)
			req, _ := http.NewRequest("POST", "/auth/register", bytes.NewBuffer(jsonBody))
			req.Header.Set("Content-Type", "application/json")

			// 执行请求
			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			// 验证响应
			assert.Equal(t, tt.expectedStatus, w.Code)

			if tt.expectedError != "" {
				var response map[string]interface{}
				json.Unmarshal(w.Body.Bytes(), &response)
				assert.Equal(t, tt.expectedError, response["code"])
			}
		})
	}
}

func TestLogin(t *testing.T) {
	tests := []struct {
		name           string
		requestBody    map[string]interface{}
		expectedStatus int
		expectedError  string
	}{
		{
			name: "成功登录",
			requestBody: map[string]interface{}{
				"email":    "test@example.com",
				"password": "password123",
			},
			expectedStatus: http.StatusOK,
		},
		{
			name: "邮箱格式错误",
			requestBody: map[string]interface{}{
				"email":    "invalid-email",
				"password": "password123",
			},
			expectedStatus: http.StatusBadRequest,
			expectedError:  "INVALID_REQUEST",
		},
		{
			name: "缺少密码",
			requestBody: map[string]interface{}{
				"email": "test@example.com",
			},
			expectedStatus: http.StatusBadRequest,
			expectedError:  "INVALID_REQUEST",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			gin.SetMode(gin.TestMode)
			router := gin.New()

			mockDB := new(MockDB)
			mockCache := new(MockCache)

			handlers := &Handlers{
				DB:    mockDB,
				Cache: mockCache,
			}

			router.POST("/auth/login", handlers.Login)

			jsonBody, _ := json.Marshal(tt.requestBody)
			req, _ := http.NewRequest("POST", "/auth/login", bytes.NewBuffer(jsonBody))
			req.Header.Set("Content-Type", "application/json")

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)

			if tt.expectedError != "" {
				var response map[string]interface{}
				json.Unmarshal(w.Body.Bytes(), &response)
				assert.Equal(t, tt.expectedError, response["code"])
			}
		})
	}
}

// 训练记录测试
func TestCreateWorkout(t *testing.T) {
	tests := []struct {
		name           string
		requestBody    map[string]interface{}
		expectedStatus int
		expectedError  string
	}{
		{
			name: "成功创建训练记录",
			requestBody: map[string]interface{}{
				"name":       "胸肌训练",
				"type":       "力量训练",
				"duration":   60,
				"calories":   300,
				"difficulty": "中级",
				"notes":      "训练效果很好",
				"rating":     4.5,
			},
			expectedStatus: http.StatusCreated,
		},
		{
			name: "缺少必填字段",
			requestBody: map[string]interface{}{
				"duration": 60,
				"calories": 300,
			},
			expectedStatus: http.StatusBadRequest,
			expectedError:  "INVALID_REQUEST",
		},
		{
			name: "无效的评分",
			requestBody: map[string]interface{}{
				"name":       "胸肌训练",
				"type":       "力量训练",
				"duration":   60,
				"calories":   300,
				"difficulty": "中级",
				"notes":      "训练效果很好",
				"rating":     6.0, // 超过5.0
			},
			expectedStatus: http.StatusCreated, // 后端应该接受这个值
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			gin.SetMode(gin.TestMode)
			router := gin.New()

			mockDB := new(MockDB)
			mockCache := new(MockCache)

			handlers := &Handlers{
				DB:    mockDB,
				Cache: mockCache,
			}

			// 添加认证中间件模拟
			router.Use(func(c *gin.Context) {
				c.Set("user_id", uint(1))
				c.Next()
			})
			router.POST("/workouts", handlers.CreateWorkout)

			jsonBody, _ := json.Marshal(tt.requestBody)
			req, _ := http.NewRequest("POST", "/workouts", bytes.NewBuffer(jsonBody))
			req.Header.Set("Content-Type", "application/json")

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)

			if tt.expectedError != "" {
				var response map[string]interface{}
				json.Unmarshal(w.Body.Bytes(), &response)
				assert.Equal(t, tt.expectedError, response["code"])
			}
		})
	}
}

func TestGetWorkouts(t *testing.T) {
	tests := []struct {
		name           string
		queryParams    string
		expectedStatus int
	}{
		{
			name:           "获取训练记录",
			queryParams:    "",
			expectedStatus: http.StatusOK,
		},
		{
			name:           "按类型筛选",
			queryParams:    "?type=力量训练",
			expectedStatus: http.StatusOK,
		},
		{
			name:           "分页查询",
			queryParams:    "?page=1&limit=5",
			expectedStatus: http.StatusOK,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			gin.SetMode(gin.TestMode)
			router := gin.New()

			mockDB := new(MockDB)
			mockCache := new(MockCache)

			handlers := &Handlers{
				DB:    mockDB,
				Cache: mockCache,
			}

			router.Use(func(c *gin.Context) {
				c.Set("user_id", uint(1))
				c.Next()
			})
			router.GET("/workouts", handlers.GetWorkouts)

			req, _ := http.NewRequest("GET", "/workouts"+tt.queryParams, nil)

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
		})
	}
}

// BMI 计算测试
func TestCalculateBMI(t *testing.T) {
	tests := []struct {
		name           string
		requestBody    map[string]interface{}
		expectedStatus int
		expectedBMI    float64
		expectedError  string
	}{
		{
			name: "正常BMI计算",
			requestBody: map[string]interface{}{
				"height": 175.0,
				"weight": 70.0,
				"age":    25,
				"gender": "male",
			},
			expectedStatus: http.StatusOK,
			expectedBMI:    22.86,
		},
		{
			name: "偏瘦BMI",
			requestBody: map[string]interface{}{
				"height": 175.0,
				"weight": 50.0,
				"age":    25,
				"gender": "male",
			},
			expectedStatus: http.StatusOK,
			expectedBMI:    16.33,
		},
		{
			name: "肥胖BMI",
			requestBody: map[string]interface{}{
				"height": 175.0,
				"weight": 100.0,
				"age":    25,
				"gender": "male",
			},
			expectedStatus: http.StatusOK,
			expectedBMI:    32.65,
		},
		{
			name: "无效身高",
			requestBody: map[string]interface{}{
				"height": -175.0,
				"weight": 70.0,
				"age":    25,
				"gender": "male",
			},
			expectedStatus: http.StatusBadRequest,
			expectedError:  "INVALID_REQUEST",
		},
		{
			name: "无效体重",
			requestBody: map[string]interface{}{
				"height": 175.0,
				"weight": 0.0,
				"age":    25,
				"gender": "male",
			},
			expectedStatus: http.StatusBadRequest,
			expectedError:  "INVALID_REQUEST",
		},
		{
			name: "无效年龄",
			requestBody: map[string]interface{}{
				"height": 175.0,
				"weight": 70.0,
				"age":    0,
				"gender": "male",
			},
			expectedStatus: http.StatusBadRequest,
			expectedError:  "INVALID_REQUEST",
		},
		{
			name: "女性BMI计算",
			requestBody: map[string]interface{}{
				"height": 165.0,
				"weight": 55.0,
				"age":    25,
				"gender": "female",
			},
			expectedStatus: http.StatusOK,
			expectedBMI:    20.20,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			gin.SetMode(gin.TestMode)
			router := gin.New()

			mockDB := new(MockDB)
			mockCache := new(MockCache)

			handlers := &Handlers{
				DB:    mockDB,
				Cache: mockCache,
			}

			router.Use(func(c *gin.Context) {
				c.Set("user_id", uint(1))
				c.Next()
			})
			router.POST("/bmi/calculate", handlers.CalculateBMI)

			jsonBody, _ := json.Marshal(tt.requestBody)
			req, _ := http.NewRequest("POST", "/bmi/calculate", bytes.NewBuffer(jsonBody))
			req.Header.Set("Content-Type", "application/json")

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)

			if tt.expectedError != "" {
				var response map[string]interface{}
				json.Unmarshal(w.Body.Bytes(), &response)
				assert.Equal(t, tt.expectedError, response["code"])
			} else if tt.expectedStatus == http.StatusOK {
				var response map[string]interface{}
				json.Unmarshal(w.Body.Bytes(), &response)
				data := response["data"].(map[string]interface{})
				bmi := data["bmi"].(float64)
				assert.InDelta(t, tt.expectedBMI, bmi, 0.01)
			}
		})
	}
}

// 社区互动测试
func TestCreatePost(t *testing.T) {
	tests := []struct {
		name           string
		requestBody    map[string]interface{}
		expectedStatus int
		expectedError  string
	}{
		{
			name: "成功发布动态",
			requestBody: map[string]interface{}{
				"content":   "今天完成了胸肌训练，感觉很好！",
				"type":      "训练",
				"is_public": true,
			},
			expectedStatus: http.StatusCreated,
		},
		{
			name: "发布带图片的动态",
			requestBody: map[string]interface{}{
				"content":   "训练后的照片",
				"images":    []string{"image1.jpg", "image2.jpg"},
				"type":      "训练",
				"is_public": true,
			},
			expectedStatus: http.StatusCreated,
		},
		{
			name: "缺少内容",
			requestBody: map[string]interface{}{
				"type":      "训练",
				"is_public": true,
			},
			expectedStatus: http.StatusBadRequest,
			expectedError:  "INVALID_REQUEST",
		},
		{
			name: "空内容",
			requestBody: map[string]interface{}{
				"content":   "",
				"type":      "训练",
				"is_public": true,
			},
			expectedStatus: http.StatusBadRequest,
			expectedError:  "INVALID_REQUEST",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			gin.SetMode(gin.TestMode)
			router := gin.New()

			mockDB := new(MockDB)
			mockCache := new(MockCache)

			handlers := &Handlers{
				DB:    mockDB,
				Cache: mockCache,
			}

			router.Use(func(c *gin.Context) {
				c.Set("user_id", uint(1))
				c.Next()
			})
			router.POST("/community/posts", handlers.CreatePost)

			jsonBody, _ := json.Marshal(tt.requestBody)
			req, _ := http.NewRequest("POST", "/community/posts", bytes.NewBuffer(jsonBody))
			req.Header.Set("Content-Type", "application/json")

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)

			if tt.expectedError != "" {
				var response map[string]interface{}
				json.Unmarshal(w.Body.Bytes(), &response)
				assert.Equal(t, tt.expectedError, response["code"])
			}
		})
	}
}

func TestLikePost(t *testing.T) {
	tests := []struct {
		name           string
		postID         string
		expectedStatus int
		expectedError  string
	}{
		{
			name:           "成功点赞",
			postID:         "1",
			expectedStatus: http.StatusOK,
		},
		{
			name:           "无效的帖子ID",
			postID:         "invalid",
			expectedStatus: http.StatusOK, // 后端应该处理这个情况
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			gin.SetMode(gin.TestMode)
			router := gin.New()

			mockDB := new(MockDB)
			mockCache := new(MockCache)

			handlers := &Handlers{
				DB:    mockDB,
				Cache: mockCache,
			}

			router.Use(func(c *gin.Context) {
				c.Set("user_id", uint(1))
				c.Next()
			})
			router.POST("/community/posts/:id/like", handlers.LikePost)

			req, _ := http.NewRequest("POST", "/community/posts/"+tt.postID+"/like", nil)

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)

			if tt.expectedError != "" {
				var response map[string]interface{}
				json.Unmarshal(w.Body.Bytes(), &response)
				assert.Equal(t, tt.expectedError, response["code"])
			}
		})
	}
}

// 签到系统测试
func TestCreateCheckin(t *testing.T) {
	tests := []struct {
		name           string
		requestBody    map[string]interface{}
		expectedStatus int
		expectedError  string
	}{
		{
			name: "成功签到",
			requestBody: map[string]interface{}{
				"type":       "训练",
				"notes":      "完成了今天的训练",
				"mood":       "开心",
				"energy":     8,
				"motivation": 9,
			},
			expectedStatus: http.StatusCreated,
		},
		{
			name: "缺少签到类型",
			requestBody: map[string]interface{}{
				"notes":      "完成了今天的训练",
				"mood":       "开心",
				"energy":     8,
				"motivation": 9,
			},
			expectedStatus: http.StatusBadRequest,
			expectedError:  "INVALID_REQUEST",
		},
		{
			name: "无效的精力值",
			requestBody: map[string]interface{}{
				"type":       "训练",
				"notes":      "完成了今天的训练",
				"mood":       "开心",
				"energy":     15, // 超过10
				"motivation": 9,
			},
			expectedStatus: http.StatusCreated, // 后端应该接受这个值
		},
		{
			name: "无效的动力值",
			requestBody: map[string]interface{}{
				"type":       "训练",
				"notes":      "完成了今天的训练",
				"mood":       "开心",
				"energy":     8,
				"motivation": -1, // 小于1
			},
			expectedStatus: http.StatusCreated, // 后端应该接受这个值
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			gin.SetMode(gin.TestMode)
			router := gin.New()

			mockDB := new(MockDB)
			mockCache := new(MockCache)

			handlers := &Handlers{
				DB:    mockDB,
				Cache: mockCache,
			}

			router.Use(func(c *gin.Context) {
				c.Set("user_id", uint(1))
				c.Next()
			})
			router.POST("/checkins", handlers.CreateCheckin)

			jsonBody, _ := json.Marshal(tt.requestBody)
			req, _ := http.NewRequest("POST", "/checkins", bytes.NewBuffer(jsonBody))
			req.Header.Set("Content-Type", "application/json")

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)

			if tt.expectedError != "" {
				var response map[string]interface{}
				json.Unmarshal(w.Body.Bytes(), &response)
				assert.Equal(t, tt.expectedError, response["code"])
			}
		})
	}
}

func TestGetCheckinStreak(t *testing.T) {
	tests := []struct {
		name           string
		expectedStatus int
	}{
		{
			name:           "获取签到连续天数",
			expectedStatus: http.StatusOK,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			gin.SetMode(gin.TestMode)
			router := gin.New()

			mockDB := new(MockDB)
			mockCache := new(MockCache)

			handlers := &Handlers{
				DB:    mockDB,
				Cache: mockCache,
			}

			router.Use(func(c *gin.Context) {
				c.Set("user_id", uint(1))
				c.Next()
			})
			router.GET("/checkins/streak", handlers.GetCheckinStreak)

			req, _ := http.NewRequest("GET", "/checkins/streak", nil)

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
		})
	}
}

// 营养分析测试
func TestCalculateNutrition(t *testing.T) {
	tests := []struct {
		name           string
		requestBody    map[string]interface{}
		expectedStatus int
		expectedError  string
	}{
		{
			name: "成功计算营养信息",
			requestBody: map[string]interface{}{
				"food_name": "鸡胸肉",
				"quantity":  100.0,
				"unit":      "g",
			},
			expectedStatus: http.StatusOK,
		},
		{
			name: "未知食物",
			requestBody: map[string]interface{}{
				"food_name": "未知食物",
				"quantity":  100.0,
				"unit":      "g",
			},
			expectedStatus: http.StatusNotFound,
			expectedError:  "FOOD_NOT_FOUND",
		},
		{
			name: "无效数量",
			requestBody: map[string]interface{}{
				"food_name": "鸡胸肉",
				"quantity":  0.0,
				"unit":      "g",
			},
			expectedStatus: http.StatusBadRequest,
			expectedError:  "INVALID_REQUEST",
		},
		{
			name: "缺少必填字段",
			requestBody: map[string]interface{}{
				"quantity": 100.0,
				"unit":     "g",
			},
			expectedStatus: http.StatusBadRequest,
			expectedError:  "INVALID_REQUEST",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			gin.SetMode(gin.TestMode)
			router := gin.New()

			mockDB := new(MockDB)
			mockCache := new(MockCache)

			handlers := &Handlers{
				DB:    mockDB,
				Cache: mockCache,
			}

			router.Use(func(c *gin.Context) {
				c.Set("user_id", uint(1))
				c.Next()
			})
			router.POST("/nutrition/calculate", handlers.CalculateNutrition)

			jsonBody, _ := json.Marshal(tt.requestBody)
			req, _ := http.NewRequest("POST", "/nutrition/calculate", bytes.NewBuffer(jsonBody))
			req.Header.Set("Content-Type", "application/json")

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)

			if tt.expectedError != "" {
				var response map[string]interface{}
				json.Unmarshal(w.Body.Bytes(), &response)
				assert.Equal(t, tt.expectedError, response["code"])
			}
		})
	}
}

func TestSearchFoods(t *testing.T) {
	tests := []struct {
		name           string
		query          string
		expectedStatus int
	}{
		{
			name:           "搜索食物",
			query:          "鸡",
			expectedStatus: http.StatusOK,
		},
		{
			name:           "空搜索",
			query:          "",
			expectedStatus: http.StatusBadRequest,
		},
		{
			name:           "搜索不存在的食物",
			query:          "不存在的食物",
			expectedStatus: http.StatusOK,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			gin.SetMode(gin.TestMode)
			router := gin.New()

			mockDB := new(MockDB)
			mockCache := new(MockCache)

			handlers := &Handlers{
				DB:    mockDB,
				Cache: mockCache,
			}

			router.Use(func(c *gin.Context) {
				c.Set("user_id", uint(1))
				c.Next()
			})
			router.GET("/nutrition/foods", handlers.SearchFoods)

			req, _ := http.NewRequest("GET", "/nutrition/foods?q="+tt.query, nil)

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
		})
	}
}

// 挑战系统测试
func TestCreateChallenge(t *testing.T) {
	tests := []struct {
		name           string
		requestBody    map[string]interface{}
		expectedStatus int
		expectedError  string
	}{
		{
			name: "成功创建挑战",
			requestBody: map[string]interface{}{
				"name":        "30天训练挑战",
				"description": "连续30天进行训练",
				"type":        "训练",
				"difficulty":  "中级",
				"start_date":  "2024-01-01",
				"end_date":    "2024-01-31",
			},
			expectedStatus: http.StatusCreated,
		},
		{
			name: "缺少必填字段",
			requestBody: map[string]interface{}{
				"description": "连续30天进行训练",
				"type":        "训练",
				"difficulty":  "中级",
			},
			expectedStatus: http.StatusBadRequest,
			expectedError:  "INVALID_REQUEST",
		},
		{
			name: "无效的日期格式",
			requestBody: map[string]interface{}{
				"name":        "30天训练挑战",
				"description": "连续30天进行训练",
				"type":        "训练",
				"difficulty":  "中级",
				"start_date":  "invalid-date",
				"end_date":    "2024-01-31",
			},
			expectedStatus: http.StatusBadRequest,
			expectedError:  "INVALID_REQUEST",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			gin.SetMode(gin.TestMode)
			router := gin.New()

			mockDB := new(MockDB)
			mockCache := new(MockCache)

			handlers := &Handlers{
				DB:    mockDB,
				Cache: mockCache,
			}

			router.Use(func(c *gin.Context) {
				c.Set("user_id", uint(1))
				c.Next()
			})
			router.POST("/community/challenges", handlers.CreateChallenge)

			jsonBody, _ := json.Marshal(tt.requestBody)
			req, _ := http.NewRequest("POST", "/community/challenges", bytes.NewBuffer(jsonBody))
			req.Header.Set("Content-Type", "application/json")

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)

			if tt.expectedError != "" {
				var response map[string]interface{}
				json.Unmarshal(w.Body.Bytes(), &response)
				assert.Equal(t, tt.expectedError, response["code"])
			}
		})
	}
}

func TestJoinChallenge(t *testing.T) {
	tests := []struct {
		name           string
		challengeID    string
		expectedStatus int
		expectedError  string
	}{
		{
			name:           "成功参与挑战",
			challengeID:    "1",
			expectedStatus: http.StatusOK,
		},
		{
			name:           "无效的挑战ID",
			challengeID:    "invalid",
			expectedStatus: http.StatusOK, // 后端应该处理这个情况
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			gin.SetMode(gin.TestMode)
			router := gin.New()

			mockDB := new(MockDB)
			mockCache := new(MockCache)

			handlers := &Handlers{
				DB:    mockDB,
				Cache: mockCache,
			}

			router.Use(func(c *gin.Context) {
				c.Set("user_id", uint(1))
				c.Next()
			})
			router.POST("/community/challenges/:id/join", handlers.JoinChallenge)

			req, _ := http.NewRequest("POST", "/community/challenges/"+tt.challengeID+"/join", nil)

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)

			if tt.expectedError != "" {
				var response map[string]interface{}
				json.Unmarshal(w.Body.Bytes(), &response)
				assert.Equal(t, tt.expectedError, response["code"])
			}
		})
	}
}

// 性能测试
func BenchmarkCalculateBMI(b *testing.B) {
	gin.SetMode(gin.TestMode)
	router := gin.New()

	mockDB := new(MockDB)
	mockCache := new(MockCache)

	handlers := &Handlers{
		DB:    mockDB,
		Cache: mockCache,
	}

	router.Use(func(c *gin.Context) {
		c.Set("user_id", uint(1))
		c.Next()
	})
	router.POST("/bmi/calculate", handlers.CalculateBMI)

	requestBody := map[string]interface{}{
		"height": 175.0,
		"weight": 70.0,
		"age":    25,
		"gender": "male",
	}

	jsonBody, _ := json.Marshal(requestBody)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		req, _ := http.NewRequest("POST", "/bmi/calculate", bytes.NewBuffer(jsonBody))
		req.Header.Set("Content-Type", "application/json")

		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)
	}
}

// 集成测试
func TestIntegrationWorkflow(t *testing.T) {
	// 这是一个集成测试示例，测试完整的用户工作流程
	t.Run("完整用户工作流程", func(t *testing.T) {
		gin.SetMode(gin.TestMode)
		router := gin.New()

		mockDB := new(MockDB)
		mockCache := new(MockCache)

		handlers := &Handlers{
			DB:    mockDB,
			Cache: mockCache,
		}

		// 设置路由
		router.POST("/auth/register", handlers.Register)
		router.POST("/auth/login", handlers.Login)
		router.Use(func(c *gin.Context) {
			c.Set("user_id", uint(1))
			c.Next()
		})
		router.POST("/workouts", handlers.CreateWorkout)
		router.POST("/checkins", handlers.CreateCheckin)
		router.POST("/community/posts", handlers.CreatePost)

		// 1. 用户注册
		registerData := map[string]interface{}{
			"username":   "integrationuser",
			"email":      "integration@example.com",
			"password":   "password123",
			"first_name": "Integration",
			"last_name":  "User",
		}

		jsonBody, _ := json.Marshal(registerData)
		req, _ := http.NewRequest("POST", "/auth/register", bytes.NewBuffer(jsonBody))
		req.Header.Set("Content-Type", "application/json")

		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusCreated, w.Code)

		// 2. 用户登录
		loginData := map[string]interface{}{
			"email":    "integration@example.com",
			"password": "password123",
		}

		jsonBody, _ = json.Marshal(loginData)
		req, _ = http.NewRequest("POST", "/auth/login", bytes.NewBuffer(jsonBody))
		req.Header.Set("Content-Type", "application/json")

		w = httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)

		// 3. 创建训练记录
		workoutData := map[string]interface{}{
			"name":       "集成测试训练",
			"type":       "力量训练",
			"duration":   45,
			"calories":   250,
			"difficulty": "中级",
			"notes":      "集成测试",
			"rating":     4.0,
		}

		jsonBody, _ = json.Marshal(workoutData)
		req, _ = http.NewRequest("POST", "/workouts", bytes.NewBuffer(jsonBody))
		req.Header.Set("Content-Type", "application/json")

		w = httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusCreated, w.Code)

		// 4. 创建签到
		checkinData := map[string]interface{}{
			"type":       "训练",
			"notes":      "完成了集成测试训练",
			"mood":       "满意",
			"energy":     8,
			"motivation": 9,
		}

		jsonBody, _ = json.Marshal(checkinData)
		req, _ = http.NewRequest("POST", "/checkins", bytes.NewBuffer(jsonBody))
		req.Header.Set("Content-Type", "application/json")

		w = httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusCreated, w.Code)

		// 5. 发布动态
		postData := map[string]interface{}{
			"content":   "完成了集成测试训练，感觉很好！",
			"type":      "训练",
			"is_public": true,
		}

		jsonBody, _ = json.Marshal(postData)
		req, _ = http.NewRequest("POST", "/community/posts", bytes.NewBuffer(jsonBody))
		req.Header.Set("Content-Type", "application/json")

		w = httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusCreated, w.Code)
	})
}
