package integration

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"

	"fittracker/backend/internal/api/handlers"
	"fittracker/backend/internal/api/routes"
	"fittracker/backend/internal/config"
	"fittracker/backend/internal/domain/models"
	"fittracker/backend/internal/infrastructure/cache"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/suite"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

// IntegrationTestSuite 集成测试套件
type IntegrationTestSuite struct {
	suite.Suite
	router *gin.Engine
	db     *gorm.DB
	cache  *cache.CacheService
	token  string
	userID uint
}

// SetupSuite 设置测试套件
func (suite *IntegrationTestSuite) SetupSuite() {
	// 设置测试模式
	gin.SetMode(gin.TestMode)

	// 初始化内存数据库
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	suite.Require().NoError(err)
	suite.db = db

	// 自动迁移数据库
	err = db.AutoMigrate(
		&models.User{},
		&models.TrainingPlan{},
		&models.Exercise{},
		&models.Workout{},
		&models.Checkin{},
		&models.HealthRecord{},
		&models.Post{},
		&models.Like{},
		&models.Comment{},
		&models.Follow{},
		&models.Challenge{},
		&models.ChallengeParticipant{},
		&models.NutritionRecord{},
	)
	suite.Require().NoError(err)

	// 初始化缓存服务（使用内存缓存）
	suite.cache = cache.NewCacheService(nil) // 在测试中不使用Redis

	// 初始化配置
	cfg := &config.Config{
		JWTSecret:     "test-secret",
		JWTExpiration: 24,
	}

	// 初始化处理器
	handlers := handlers.New(suite.db, nil, suite.cache, cfg)

	// 设置路由
	suite.router = gin.New()
	routes.SetupRoutes(suite.router, handlers)
}

// TearDownSuite 清理测试套件
func (suite *IntegrationTestSuite) TearDownSuite() {
	// 清理数据库
	suite.db.Exec("DROP TABLE IF EXISTS users")
	suite.db.Exec("DROP TABLE IF EXISTS training_plans")
	suite.db.Exec("DROP TABLE IF EXISTS exercises")
	suite.db.Exec("DROP TABLE IF EXISTS workouts")
	suite.db.Exec("DROP TABLE IF EXISTS checkins")
	suite.db.Exec("DROP TABLE IF EXISTS health_records")
	suite.db.Exec("DROP TABLE IF EXISTS posts")
	suite.db.Exec("DROP TABLE IF EXISTS likes")
	suite.db.Exec("DROP TABLE IF EXISTS comments")
	suite.db.Exec("DROP TABLE IF EXISTS follows")
	suite.db.Exec("DROP TABLE IF EXISTS challenges")
	suite.db.Exec("DROP TABLE IF EXISTS challenge_participants")
	suite.db.Exec("DROP TABLE IF EXISTS nutrition_records")
}

// SetupTest 设置每个测试
func (suite *IntegrationTestSuite) SetupTest() {
	// 清理数据库
	suite.db.Exec("DELETE FROM users")
	suite.db.Exec("DELETE FROM workouts")
	suite.db.Exec("DELETE FROM checkins")
	suite.db.Exec("DELETE FROM posts")
	suite.db.Exec("DELETE FROM likes")
	suite.db.Exec("DELETE FROM comments")
	suite.db.Exec("DELETE FROM challenges")
	suite.db.Exec("DELETE FROM nutrition_records")

	// 重置token
	suite.token = ""
	suite.userID = 0
}

// TestUserRegistration 测试用户注册
func (suite *IntegrationTestSuite) TestUserRegistration() {
	registerData := map[string]interface{}{
		"username":   "testuser",
		"email":      "test@example.com",
		"password":   "password123",
		"first_name": "Test",
		"last_name":  "User",
	}

	jsonData, _ := json.Marshal(registerData)
	req, _ := http.NewRequest("POST", "/api/v1/auth/register", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	suite.router.ServeHTTP(w, req)

	suite.Equal(http.StatusCreated, w.Code)

	// 验证用户已创建
	var user models.User
	err := suite.db.Where("email = ?", "test@example.com").First(&user).Error
	suite.NoError(err)
	suite.Equal("testuser", user.Username)
	suite.Equal("test@example.com", user.Email)
}

// TestUserLogin 测试用户登录
func (suite *IntegrationTestSuite) TestUserLogin() {
	// 先注册用户
	suite.registerTestUser()

	loginData := map[string]interface{}{
		"email":    "test@example.com",
		"password": "password123",
	}

	jsonData, _ := json.Marshal(loginData)
	req, _ := http.NewRequest("POST", "/api/v1/auth/login", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	suite.router.ServeHTTP(w, req)

	suite.Equal(http.StatusOK, w.Code)

	// 解析响应获取token
	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	suite.NoError(err)

	token, exists := response["token"]
	suite.True(exists)
	suite.NotEmpty(token)

	suite.token = token.(string)
}

// TestCreateWorkout 测试创建训练记录
func (suite *IntegrationTestSuite) TestCreateWorkout() {
	// 先登录获取token
	suite.loginTestUser()

	workoutData := map[string]interface{}{
		"name":       "胸肌训练",
		"type":       "力量训练",
		"duration":   60,
		"calories":   300,
		"difficulty": "中级",
		"notes":      "训练效果很好",
		"rating":     4.5,
	}

	jsonData, _ := json.Marshal(workoutData)
	req, _ := http.NewRequest("POST", "/api/v1/workouts", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+suite.token)

	w := httptest.NewRecorder()
	suite.router.ServeHTTP(w, req)

	suite.Equal(http.StatusCreated, w.Code)

	// 验证训练记录已创建
	var workout models.Workout
	err := suite.db.Where("user_id = ?", suite.userID).First(&workout).Error
	suite.NoError(err)
	suite.Equal("胸肌训练", workout.Name)
	suite.Equal("力量训练", workout.Type)
	suite.Equal(60, workout.Duration)
	suite.Equal(300, workout.Calories)
}

// TestGetWorkouts 测试获取训练记录
func (suite *IntegrationTestSuite) TestGetWorkouts() {
	// 先登录并创建训练记录
	suite.loginTestUser()
	suite.createTestWorkout()

	req, _ := http.NewRequest("GET", "/api/v1/workouts", nil)
	req.Header.Set("Authorization", "Bearer "+suite.token)

	w := httptest.NewRecorder()
	suite.router.ServeHTTP(w, req)

	suite.Equal(http.StatusOK, w.Code)

	// 验证响应包含训练记录
	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	suite.NoError(err)

	data, exists := response["data"]
	suite.True(exists)

	workouts := data.([]interface{})
	suite.Len(workouts, 1)
}

// TestCalculateBMI 测试BMI计算
func (suite *IntegrationTestSuite) TestCalculateBMI() {
	// 先登录
	suite.loginTestUser()

	bmiData := map[string]interface{}{
		"height": 175.0,
		"weight": 70.0,
		"age":    25,
		"gender": "male",
	}

	jsonData, _ := json.Marshal(bmiData)
	req, _ := http.NewRequest("POST", "/api/v1/bmi/calculate", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+suite.token)

	w := httptest.NewRecorder()
	suite.router.ServeHTTP(w, req)

	suite.Equal(http.StatusOK, w.Code)

	// 验证BMI计算结果
	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	suite.NoError(err)

	data, exists := response["data"]
	suite.True(exists)

	bmiResult := data.(map[string]interface{})
	bmi, exists := bmiResult["bmi"]
	suite.True(exists)
	suite.InDelta(22.86, bmi, 0.01)
}

// TestCreatePost 测试发布动态
func (suite *IntegrationTestSuite) TestCreatePost() {
	// 先登录
	suite.loginTestUser()

	postData := map[string]interface{}{
		"content":   "今天完成了胸肌训练，感觉很好！",
		"type":      "训练",
		"is_public": true,
	}

	jsonData, _ := json.Marshal(postData)
	req, _ := http.NewRequest("POST", "/api/v1/community/posts", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+suite.token)

	w := httptest.NewRecorder()
	suite.router.ServeHTTP(w, req)

	suite.Equal(http.StatusCreated, w.Code)

	// 验证动态已创建
	var post models.Post
	err := suite.db.Where("user_id = ?", suite.userID).First(&post).Error
	suite.NoError(err)
	suite.Equal("今天完成了胸肌训练，感觉很好！", post.Content)
	suite.Equal("训练", post.Type)
	suite.True(post.IsPublic)
}

// TestLikePost 测试点赞动态
func (suite *IntegrationTestSuite) TestLikePost() {
	// 先登录并创建动态
	suite.loginTestUser()
	suite.createTestPost()

	req, _ := http.NewRequest("POST", "/api/v1/community/posts/1/like", nil)
	req.Header.Set("Authorization", "Bearer "+suite.token)

	w := httptest.NewRecorder()
	suite.router.ServeHTTP(w, req)

	suite.Equal(http.StatusOK, w.Code)

	// 验证点赞记录已创建
	var like models.Like
	err := suite.db.Where("user_id = ? AND post_id = ?", suite.userID, 1).First(&like).Error
	suite.NoError(err)
	suite.Equal(suite.userID, like.UserID)
	suite.Equal(uint(1), like.PostID)
}

// TestCreateCheckin 测试创建签到
func (suite *IntegrationTestSuite) TestCreateCheckin() {
	// 先登录
	suite.loginTestUser()

	checkinData := map[string]interface{}{
		"type":       "训练",
		"notes":      "完成了今天的训练",
		"mood":       "开心",
		"energy":     8,
		"motivation": 9,
	}

	jsonData, _ := json.Marshal(checkinData)
	req, _ := http.NewRequest("POST", "/api/v1/checkins", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+suite.token)

	w := httptest.NewRecorder()
	suite.router.ServeHTTP(w, req)

	suite.Equal(http.StatusCreated, w.Code)

	// 验证签到记录已创建
	var checkin models.Checkin
	err := suite.db.Where("user_id = ?", suite.userID).First(&checkin).Error
	suite.NoError(err)
	suite.Equal("训练", checkin.Type)
	suite.Equal("完成了今天的训练", checkin.Notes)
	suite.Equal("开心", checkin.Mood)
	suite.Equal(8, checkin.Energy)
	suite.Equal(9, checkin.Motivation)
}

// TestGetCheckinStreak 测试获取签到连续天数
func (suite *IntegrationTestSuite) TestGetCheckinStreak() {
	// 先登录并创建签到
	suite.loginTestUser()
	suite.createTestCheckin()

	req, _ := http.NewRequest("GET", "/api/v1/checkins/streak", nil)
	req.Header.Set("Authorization", "Bearer "+suite.token)

	w := httptest.NewRecorder()
	suite.router.ServeHTTP(w, req)

	suite.Equal(http.StatusOK, w.Code)

	// 验证签到连续天数
	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	suite.NoError(err)

	data, exists := response["data"]
	suite.True(exists)

	streak := data.(map[string]interface{})
	currentStreak, exists := streak["current_streak"]
	suite.True(exists)
	suite.GreaterOrEqual(currentStreak, 0)
}

// TestCreateChallenge 测试创建挑战
func (suite *IntegrationTestSuite) TestCreateChallenge() {
	// 先登录
	suite.loginTestUser()

	challengeData := map[string]interface{}{
		"name":        "30天训练挑战",
		"description": "连续30天进行训练",
		"type":        "训练",
		"difficulty":  "中级",
		"start_date":  "2024-01-01",
		"end_date":    "2024-01-31",
	}

	jsonData, _ := json.Marshal(challengeData)
	req, _ := http.NewRequest("POST", "/api/v1/community/challenges", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+suite.token)

	w := httptest.NewRecorder()
	suite.router.ServeHTTP(w, req)

	suite.Equal(http.StatusCreated, w.Code)

	// 验证挑战已创建
	var challenge models.Challenge
	err := suite.db.Where("name = ?", "30天训练挑战").First(&challenge).Error
	suite.NoError(err)
	suite.Equal("30天训练挑战", challenge.Name)
	suite.Equal("连续30天进行训练", challenge.Description)
	suite.Equal("训练", challenge.Type)
	suite.Equal("中级", challenge.Difficulty)
}

// TestJoinChallenge 测试参与挑战
func (suite *IntegrationTestSuite) TestJoinChallenge() {
	// 先登录并创建挑战
	suite.loginTestUser()
	suite.createTestChallenge()

	req, _ := http.NewRequest("POST", "/api/v1/community/challenges/1/join", nil)
	req.Header.Set("Authorization", "Bearer "+suite.token)

	w := httptest.NewRecorder()
	suite.router.ServeHTTP(w, req)

	suite.Equal(http.StatusOK, w.Code)

	// 验证参与记录已创建
	var participant models.ChallengeParticipant
	err := suite.db.Where("user_id = ? AND challenge_id = ?", suite.userID, 1).First(&participant).Error
	suite.NoError(err)
	suite.Equal(suite.userID, participant.UserID)
	suite.Equal(uint(1), participant.ChallengeID)
	suite.Equal(0, participant.Progress)
}

// TestCalculateNutrition 测试营养计算
func (suite *IntegrationTestSuite) TestCalculateNutrition() {
	// 先登录
	suite.loginTestUser()

	nutritionData := map[string]interface{}{
		"food_name": "鸡胸肉",
		"quantity":  100.0,
		"unit":      "g",
	}

	jsonData, _ := json.Marshal(nutritionData)
	req, _ := http.NewRequest("POST", "/api/v1/nutrition/calculate", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+suite.token)

	w := httptest.NewRecorder()
	suite.router.ServeHTTP(w, req)

	suite.Equal(http.StatusOK, w.Code)

	// 验证营养计算结果
	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	suite.NoError(err)

	data, exists := response["data"]
	suite.True(exists)

	nutrition := data.(map[string]interface{})
	foodName, exists := nutrition["food_name"]
	suite.True(exists)
	suite.Equal("鸡胸肉", foodName)
}

// TestCompleteWorkflow 测试完整工作流程
func (suite *IntegrationTestSuite) TestCompleteWorkflow() {
	// 1. 用户注册
	suite.registerTestUser()

	// 2. 用户登录
	suite.loginTestUser()

	// 3. 创建训练记录
	suite.createTestWorkout()

	// 4. 计算BMI
	suite.calculateTestBMI()

	// 5. 发布动态
	suite.createTestPost()

	// 6. 点赞动态
	suite.likeTestPost()

	// 7. 创建签到
	suite.createTestCheckin()

	// 8. 创建挑战
	suite.createTestChallenge()

	// 9. 参与挑战
	suite.joinTestChallenge()

	// 10. 计算营养
	suite.calculateTestNutrition()

	// 验证所有数据都已创建
	var userCount int64
	suite.db.Model(&models.User{}).Count(&userCount)
	suite.Equal(int64(1), userCount)

	var workoutCount int64
	suite.db.Model(&models.Workout{}).Count(&workoutCount)
	suite.Equal(int64(1), workoutCount)

	var postCount int64
	suite.db.Model(&models.Post{}).Count(&postCount)
	suite.Equal(int64(1), postCount)

	var checkinCount int64
	suite.db.Model(&models.Checkin{}).Count(&checkinCount)
	suite.Equal(int64(1), checkinCount)

	var challengeCount int64
	suite.db.Model(&models.Challenge{}).Count(&challengeCount)
	suite.Equal(int64(1), challengeCount)
}

// 辅助方法
func (suite *IntegrationTestSuite) registerTestUser() {
	registerData := map[string]interface{}{
		"username":   "testuser",
		"email":      "test@example.com",
		"password":   "password123",
		"first_name": "Test",
		"last_name":  "User",
	}

	jsonData, _ := json.Marshal(registerData)
	req, _ := http.NewRequest("POST", "/api/v1/auth/register", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	suite.router.ServeHTTP(w, req)

	suite.Equal(http.StatusCreated, w.Code)
}

func (suite *IntegrationTestSuite) loginTestUser() {
	loginData := map[string]interface{}{
		"email":    "test@example.com",
		"password": "password123",
	}

	jsonData, _ := json.Marshal(loginData)
	req, _ := http.NewRequest("POST", "/api/v1/auth/login", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	suite.router.ServeHTTP(w, req)

	suite.Equal(http.StatusOK, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	suite.NoError(err)

	token, exists := response["token"]
	suite.True(exists)
	suite.token = token.(string)

	// 获取用户ID
	var user models.User
	err = suite.db.Where("email = ?", "test@example.com").First(&user).Error
	suite.NoError(err)
	suite.userID = user.ID
}

func (suite *IntegrationTestSuite) createTestWorkout() {
	workoutData := map[string]interface{}{
		"name":       "测试训练",
		"type":       "力量训练",
		"duration":   30,
		"calories":   200,
		"difficulty": "初级",
		"notes":      "测试训练",
		"rating":     4.5,
	}

	jsonData, _ := json.Marshal(workoutData)
	req, _ := http.NewRequest("POST", "/api/v1/workouts", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+suite.token)

	w := httptest.NewRecorder()
	suite.router.ServeHTTP(w, req)

	suite.Equal(http.StatusCreated, w.Code)
}

func (suite *IntegrationTestSuite) calculateTestBMI() {
	bmiData := map[string]interface{}{
		"height": 175.0,
		"weight": 70.0,
		"age":    25,
		"gender": "male",
	}

	jsonData, _ := json.Marshal(bmiData)
	req, _ := http.NewRequest("POST", "/api/v1/bmi/calculate", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+suite.token)

	w := httptest.NewRecorder()
	suite.router.ServeHTTP(w, req)

	suite.Equal(http.StatusOK, w.Code)
}

func (suite *IntegrationTestSuite) createTestPost() {
	postData := map[string]interface{}{
		"content":   "测试动态",
		"type":      "训练",
		"is_public": true,
	}

	jsonData, _ := json.Marshal(postData)
	req, _ := http.NewRequest("POST", "/api/v1/community/posts", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+suite.token)

	w := httptest.NewRecorder()
	suite.router.ServeHTTP(w, req)

	suite.Equal(http.StatusCreated, w.Code)
}

func (suite *IntegrationTestSuite) likeTestPost() {
	req, _ := http.NewRequest("POST", "/api/v1/community/posts/1/like", nil)
	req.Header.Set("Authorization", "Bearer "+suite.token)

	w := httptest.NewRecorder()
	suite.router.ServeHTTP(w, req)

	suite.Equal(http.StatusOK, w.Code)
}

func (suite *IntegrationTestSuite) createTestCheckin() {
	checkinData := map[string]interface{}{
		"type":       "训练",
		"notes":      "测试签到",
		"mood":       "开心",
		"energy":     8,
		"motivation": 9,
	}

	jsonData, _ := json.Marshal(checkinData)
	req, _ := http.NewRequest("POST", "/api/v1/checkins", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+suite.token)

	w := httptest.NewRecorder()
	suite.router.ServeHTTP(w, req)

	suite.Equal(http.StatusCreated, w.Code)
}

func (suite *IntegrationTestSuite) createTestChallenge() {
	challengeData := map[string]interface{}{
		"name":        "测试挑战",
		"description": "测试挑战描述",
		"type":        "训练",
		"difficulty":  "初级",
		"start_date":  "2024-01-01",
		"end_date":    "2024-01-31",
	}

	jsonData, _ := json.Marshal(challengeData)
	req, _ := http.NewRequest("POST", "/api/v1/community/challenges", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+suite.token)

	w := httptest.NewRecorder()
	suite.router.ServeHTTP(w, req)

	suite.Equal(http.StatusCreated, w.Code)
}

func (suite *IntegrationTestSuite) joinTestChallenge() {
	req, _ := http.NewRequest("POST", "/api/v1/community/challenges/1/join", nil)
	req.Header.Set("Authorization", "Bearer "+suite.token)

	w := httptest.NewRecorder()
	suite.router.ServeHTTP(w, req)

	suite.Equal(http.StatusOK, w.Code)
}

func (suite *IntegrationTestSuite) calculateTestNutrition() {
	nutritionData := map[string]interface{}{
		"food_name": "鸡胸肉",
		"quantity":  100.0,
		"unit":      "g",
	}

	jsonData, _ := json.Marshal(nutritionData)
	req, _ := http.NewRequest("POST", "/api/v1/nutrition/calculate", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+suite.token)

	w := httptest.NewRecorder()
	suite.router.ServeHTTP(w, req)

	suite.Equal(http.StatusOK, w.Code)
}

// 运行集成测试套件
func TestIntegrationTestSuite(t *testing.T) {
	suite.Run(t, new(IntegrationTestSuite))
}

// 性能测试
func BenchmarkIntegrationWorkflow(b *testing.B) {
	// 设置测试环境
	gin.SetMode(gin.TestMode)

	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	if err != nil {
		b.Fatal(err)
	}

	err = db.AutoMigrate(&models.User{}, &models.Workout{}, &models.Post{}, &models.Checkin{})
	if err != nil {
		b.Fatal(err)
	}

	cache := cache.NewCacheService(nil)
	cfg := &config.Config{
		JWTSecret:     "test-secret",
		JWTExpiration: 24,
	}

	handlers := handlers.New(db, nil, cache, cfg)
	router := gin.New()
	routes.SetupRoutes(router, handlers)

	b.ResetTimer()

	for i := 0; i < b.N; i++ {
		// 注册用户
		registerData := map[string]interface{}{
			"username":   fmt.Sprintf("user%d", i),
			"email":      fmt.Sprintf("user%d@example.com", i),
			"password":   "password123",
			"first_name": "Test",
			"last_name":  "User",
		}

		jsonData, _ := json.Marshal(registerData)
		req, _ := http.NewRequest("POST", "/api/v1/auth/register", bytes.NewBuffer(jsonData))
		req.Header.Set("Content-Type", "application/json")

		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		if w.Code != http.StatusCreated {
			b.Fatal("Registration failed")
		}

		// 登录用户
		loginData := map[string]interface{}{
			"email":    fmt.Sprintf("user%d@example.com", i),
			"password": "password123",
		}

		jsonData, _ = json.Marshal(loginData)
		req, _ = http.NewRequest("POST", "/api/v1/auth/login", bytes.NewBuffer(jsonData))
		req.Header.Set("Content-Type", "application/json")

		w = httptest.NewRecorder()
		router.ServeHTTP(w, req)

		if w.Code != http.StatusOK {
			b.Fatal("Login failed")
		}

		var response map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &response)
		token := response["token"].(string)

		// 创建训练记录
		workoutData := map[string]interface{}{
			"name":       "测试训练",
			"type":       "力量训练",
			"duration":   30,
			"calories":   200,
			"difficulty": "初级",
			"notes":      "测试训练",
			"rating":     4.5,
		}

		jsonData, _ = json.Marshal(workoutData)
		req, _ = http.NewRequest("POST", "/api/v1/workouts", bytes.NewBuffer(jsonData))
		req.Header.Set("Content-Type", "application/json")
		req.Header.Set("Authorization", "Bearer "+token)

		w = httptest.NewRecorder()
		router.ServeHTTP(w, req)

		if w.Code != http.StatusCreated {
			b.Fatal("Workout creation failed")
		}
	}
}
