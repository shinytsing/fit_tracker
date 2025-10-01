package services

import (
	"testing"
	"time"

	"fittracker/internal/domain/models"

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

// MockGormDB 模拟GORM数据库
type MockGormDB struct {
	mock.Mock
}

func (m *MockGormDB) Create(value interface{}) *gorm.DB {
	args := m.Called(value)
	return args.Get(0).(*gorm.DB)
}

func (m *MockGormDB) First(dest interface{}, conds ...interface{}) *gorm.DB {
	args := m.Called(dest, conds)
	return args.Get(0).(*gorm.DB)
}

func (m *MockGormDB) Where(query interface{}, args ...interface{}) *gorm.DB {
	mockArgs := m.Called(query, args)
	return mockArgs.Get(0).(*gorm.DB)
}

func (m *MockGormDB) Preload(query string, args ...interface{}) *gorm.DB {
	mockArgs := m.Called(query, args)
	return mockArgs.Get(0).(*gorm.DB)
}

func (m *MockGormDB) Offset(offset int) *gorm.DB {
	args := m.Called(offset)
	return args.Get(0).(*gorm.DB)
}

func (m *MockGormDB) Limit(limit int) *gorm.DB {
	args := m.Called(limit)
	return args.Get(0).(*gorm.DB)
}

func (m *MockGormDB) Order(value interface{}) *gorm.DB {
	args := m.Called(value)
	return args.Get(0).(*gorm.DB)
}

func (m *MockGormDB) Find(dest interface{}, conds ...interface{}) *gorm.DB {
	args := m.Called(dest, conds)
	return args.Get(0).(*gorm.DB)
}

func (m *MockGormDB) Count(count *int64) *gorm.DB {
	args := m.Called(count)
	return args.Get(0).(*gorm.DB)
}

func (m *MockGormDB) Updates(values interface{}) *gorm.DB {
	args := m.Called(values)
	return args.Get(0).(*gorm.DB)
}

func (m *MockGormDB) Delete(value interface{}, conds ...interface{}) *gorm.DB {
	args := m.Called(value, conds)
	return args.Get(0).(*gorm.DB)
}

func (m *MockGormDB) Model(value interface{}) *gorm.DB {
	args := m.Called(value)
	return args.Get(0).(*gorm.DB)
}

// 测试辅助函数
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

func createTestChallenge() *models.Challenge {
	return &models.Challenge{
		ID:          1,
		Name:        "30天训练挑战",
		Description: "连续30天进行训练",
		Type:        "训练",
		Difficulty:  "中级",
		StartDate:   time.Now(),
		EndDate:     time.Now().AddDate(0, 0, 30),
		IsActive:    true,
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}
}

// UserService 测试
func TestUserService_CreateUser(t *testing.T) {
	tests := []struct {
		name    string
		user    *models.User
		wantErr bool
	}{
		{
			name:    "成功创建用户",
			user:    createTestUser(),
			wantErr: false,
		},
		{
			name:    "创建空用户",
			user:    &models.User{},
			wantErr: false, // 数据库层面可能允许空用户
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockDB := new(MockGormDB)
			service := NewUserService(mockDB)

			// 设置mock期望
			mockDB.On("Create", tt.user).Return(&gorm.DB{})

			err := service.CreateUser(tt.user)

			if tt.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}

			mockDB.AssertExpectations(t)
		})
	}
}

func TestUserService_GetUserByID(t *testing.T) {
	tests := []struct {
		name    string
		userID  uint
		wantErr bool
	}{
		{
			name:    "成功获取用户",
			userID:  1,
			wantErr: false,
		},
		{
			name:    "获取不存在的用户",
			userID:  999,
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockDB := new(MockGormDB)
			service := NewUserService(mockDB)

			// 设置mock期望
			mockDB.On("First", mock.Anything, mock.Anything).Return(&gorm.DB{})

			user, err := service.GetUserByID(tt.userID)

			if tt.wantErr {
				assert.Error(t, err)
				assert.Nil(t, user)
			} else {
				assert.NoError(t, err)
				assert.NotNil(t, user)
			}

			mockDB.AssertExpectations(t)
		})
	}
}

func TestUserService_GetUserByEmail(t *testing.T) {
	tests := []struct {
		name    string
		email   string
		wantErr bool
	}{
		{
			name:    "成功获取用户",
			email:   "test@example.com",
			wantErr: false,
		},
		{
			name:    "获取不存在的用户",
			email:   "nonexistent@example.com",
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockDB := new(MockGormDB)
			service := NewUserService(mockDB)

			// 设置mock期望
			mockDB.On("First", mock.Anything, mock.Anything).Return(&gorm.DB{})

			user, err := service.GetUserByEmail(tt.email)

			if tt.wantErr {
				assert.Error(t, err)
				assert.Nil(t, user)
			} else {
				assert.NoError(t, err)
				assert.NotNil(t, user)
			}

			mockDB.AssertExpectations(t)
		})
	}
}

func TestUserService_UpdateUser(t *testing.T) {
	tests := []struct {
		name    string
		user    *models.User
		wantErr bool
	}{
		{
			name:    "成功更新用户",
			user:    createTestUser(),
			wantErr: false,
		},
		{
			name:    "更新空用户",
			user:    &models.User{},
			wantErr: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockDB := new(MockGormDB)
			service := NewUserService(mockDB)

			// 设置mock期望
			mockDB.On("Updates", tt.user).Return(&gorm.DB{})

			err := service.UpdateUser(tt.user)

			if tt.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}

			mockDB.AssertExpectations(t)
		})
	}
}

func TestUserService_DeleteUser(t *testing.T) {
	tests := []struct {
		name    string
		userID  uint
		wantErr bool
	}{
		{
			name:    "成功删除用户",
			userID:  1,
			wantErr: false,
		},
		{
			name:    "删除不存在的用户",
			userID:  999,
			wantErr: false, // 删除操作通常不会报错
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockDB := new(MockGormDB)
			service := NewUserService(mockDB)

			// 设置mock期望
			mockDB.On("Delete", mock.Anything, mock.Anything).Return(&gorm.DB{})

			err := service.DeleteUser(tt.userID)

			if tt.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}

			mockDB.AssertExpectations(t)
		})
	}
}

// WorkoutService 测试
func TestWorkoutService_CreateWorkout(t *testing.T) {
	tests := []struct {
		name    string
		workout *models.Workout
		wantErr bool
	}{
		{
			name:    "成功创建训练记录",
			workout: createTestWorkout(),
			wantErr: false,
		},
		{
			name:    "创建空训练记录",
			workout: &models.Workout{},
			wantErr: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockDB := new(MockGormDB)
			service := NewWorkoutService(mockDB)

			// 设置mock期望
			mockDB.On("Create", tt.workout).Return(&gorm.DB{})

			err := service.CreateWorkout(tt.workout)

			if tt.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}

			mockDB.AssertExpectations(t)
		})
	}
}

func TestWorkoutService_GetWorkoutsByUserID(t *testing.T) {
	tests := []struct {
		name    string
		userID  uint
		wantErr bool
	}{
		{
			name:    "成功获取用户训练记录",
			userID:  1,
			wantErr: false,
		},
		{
			name:    "获取不存在用户的训练记录",
			userID:  999,
			wantErr: false, // 应该返回空列表而不是错误
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockDB := new(MockGormDB)
			service := NewWorkoutService(mockDB)

			// 设置mock期望
			mockDB.On("Where", mock.Anything, mock.Anything).Return(mockDB)
			mockDB.On("Preload", mock.Anything, mock.Anything).Return(mockDB)
			mockDB.On("Order", mock.Anything).Return(mockDB)
			mockDB.On("Find", mock.Anything).Return(&gorm.DB{})

			workouts, err := service.GetWorkoutsByUserID(tt.userID)

			if tt.wantErr {
				assert.Error(t, err)
				assert.Nil(t, workouts)
			} else {
				assert.NoError(t, err)
				assert.NotNil(t, workouts)
			}

			mockDB.AssertExpectations(t)
		})
	}
}

func TestWorkoutService_GetWorkoutByID(t *testing.T) {
	tests := []struct {
		name      string
		workoutID uint
		wantErr   bool
	}{
		{
			name:      "成功获取训练记录",
			workoutID: 1,
			wantErr:   false,
		},
		{
			name:      "获取不存在的训练记录",
			workoutID: 999,
			wantErr:   true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockDB := new(MockGormDB)
			service := NewWorkoutService(mockDB)

			// 设置mock期望
			mockDB.On("First", mock.Anything, mock.Anything).Return(&gorm.DB{})

			workout, err := service.GetWorkoutByID(tt.workoutID)

			if tt.wantErr {
				assert.Error(t, err)
				assert.Nil(t, workout)
			} else {
				assert.NoError(t, err)
				assert.NotNil(t, workout)
			}

			mockDB.AssertExpectations(t)
		})
	}
}

func TestWorkoutService_UpdateWorkout(t *testing.T) {
	tests := []struct {
		name    string
		workout *models.Workout
		wantErr bool
	}{
		{
			name:    "成功更新训练记录",
			workout: createTestWorkout(),
			wantErr: false,
		},
		{
			name:    "更新空训练记录",
			workout: &models.Workout{},
			wantErr: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockDB := new(MockGormDB)
			service := NewWorkoutService(mockDB)

			// 设置mock期望
			mockDB.On("Updates", tt.workout).Return(&gorm.DB{})

			err := service.UpdateWorkout(tt.workout)

			if tt.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}

			mockDB.AssertExpectations(t)
		})
	}
}

func TestWorkoutService_DeleteWorkout(t *testing.T) {
	tests := []struct {
		name      string
		workoutID uint
		wantErr   bool
	}{
		{
			name:      "成功删除训练记录",
			workoutID: 1,
			wantErr:   false,
		},
		{
			name:      "删除不存在的训练记录",
			workoutID: 999,
			wantErr:   false, // 删除操作通常不会报错
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockDB := new(MockGormDB)
			service := NewWorkoutService(mockDB)

			// 设置mock期望
			mockDB.On("Delete", mock.Anything, mock.Anything).Return(&gorm.DB{})

			err := service.DeleteWorkout(tt.workoutID)

			if tt.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}

			mockDB.AssertExpectations(t)
		})
	}
}

// BMIService 测试
func TestBMIService_CalculateBMI(t *testing.T) {
	tests := []struct {
		name             string
		height           float64
		weight           float64
		age              int
		gender           string
		expectedBMI      float64
		expectedCategory string
	}{
		{
			name:             "正常BMI",
			height:           175.0,
			weight:           70.0,
			age:              25,
			gender:           "male",
			expectedBMI:      22.86,
			expectedCategory: "正常",
		},
		{
			name:             "偏瘦BMI",
			height:           175.0,
			weight:           50.0,
			age:              25,
			gender:           "male",
			expectedBMI:      16.33,
			expectedCategory: "偏瘦",
		},
		{
			name:             "肥胖BMI",
			height:           175.0,
			weight:           100.0,
			age:              25,
			gender:           "male",
			expectedBMI:      32.65,
			expectedCategory: "肥胖",
		},
		{
			name:             "女性BMI",
			height:           165.0,
			weight:           55.0,
			age:              25,
			gender:           "female",
			expectedBMI:      20.20,
			expectedCategory: "正常",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockDB := new(MockGormDB)
			service := NewBMIService(mockDB)

			bmi, category := service.CalculateBMI(tt.height, tt.weight, tt.age, tt.gender)

			assert.InDelta(t, tt.expectedBMI, bmi, 0.01)
			assert.Equal(t, tt.expectedCategory, category)
		})
	}
}

func TestBMIService_CreateHealthRecord(t *testing.T) {
	tests := []struct {
		name    string
		record  *models.HealthRecord
		wantErr bool
	}{
		{
			name: "成功创建健康记录",
			record: &models.HealthRecord{
				UserID: 1,
				Type:   "bmi",
				Value:  22.86,
				Notes:  "测试记录",
			},
			wantErr: false,
		},
		{
			name:    "创建空健康记录",
			record:  &models.HealthRecord{},
			wantErr: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockDB := new(MockGormDB)
			service := NewBMIService(mockDB)

			// 设置mock期望
			mockDB.On("Create", tt.record).Return(&gorm.DB{})

			err := service.CreateHealthRecord(tt.record)

			if tt.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}

			mockDB.AssertExpectations(t)
		})
	}
}

// CommunityService 测试
func TestCommunityService_CreatePost(t *testing.T) {
	tests := []struct {
		name    string
		post    *models.Post
		wantErr bool
	}{
		{
			name:    "成功创建动态",
			post:    createTestPost(),
			wantErr: false,
		},
		{
			name:    "创建空动态",
			post:    &models.Post{},
			wantErr: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockDB := new(MockGormDB)
			service := NewCommunityService(mockDB)

			// 设置mock期望
			mockDB.On("Create", tt.post).Return(&gorm.DB{})

			err := service.CreatePost(tt.post)

			if tt.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}

			mockDB.AssertExpectations(t)
		})
	}
}

func TestCommunityService_GetPosts(t *testing.T) {
	tests := []struct {
		name    string
		wantErr bool
	}{
		{
			name:    "成功获取动态列表",
			wantErr: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockDB := new(MockGormDB)
			service := NewCommunityService(mockDB)

			// 设置mock期望
			mockDB.On("Where", mock.Anything, mock.Anything).Return(mockDB)
			mockDB.On("Preload", mock.Anything, mock.Anything).Return(mockDB)
			mockDB.On("Order", mock.Anything).Return(mockDB)
			mockDB.On("Find", mock.Anything).Return(&gorm.DB{})

			posts, err := service.GetPosts()

			if tt.wantErr {
				assert.Error(t, err)
				assert.Nil(t, posts)
			} else {
				assert.NoError(t, err)
				assert.NotNil(t, posts)
			}

			mockDB.AssertExpectations(t)
		})
	}
}

func TestCommunityService_LikePost(t *testing.T) {
	tests := []struct {
		name    string
		userID  uint
		postID  uint
		wantErr bool
	}{
		{
			name:    "成功点赞",
			userID:  1,
			postID:  1,
			wantErr: false,
		},
		{
			name:    "重复点赞",
			userID:  1,
			postID:  1,
			wantErr: false, // 应该处理重复点赞
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockDB := new(MockGormDB)
			service := NewCommunityService(mockDB)

			// 设置mock期望
			mockDB.On("First", mock.Anything, mock.Anything).Return(&gorm.DB{})
			mockDB.On("Create", mock.Anything).Return(&gorm.DB{})

			err := service.LikePost(tt.userID, tt.postID)

			if tt.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}

			mockDB.AssertExpectations(t)
		})
	}
}

func TestCommunityService_CreateComment(t *testing.T) {
	tests := []struct {
		name    string
		comment *models.Comment
		wantErr bool
	}{
		{
			name: "成功创建评论",
			comment: &models.Comment{
				UserID:  1,
				PostID:  1,
				Content: "测试评论",
			},
			wantErr: false,
		},
		{
			name:    "创建空评论",
			comment: &models.Comment{},
			wantErr: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockDB := new(MockGormDB)
			service := NewCommunityService(mockDB)

			// 设置mock期望
			mockDB.On("Create", tt.comment).Return(&gorm.DB{})

			err := service.CreateComment(tt.comment)

			if tt.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}

			mockDB.AssertExpectations(t)
		})
	}
}

// CheckinService 测试
func TestCheckinService_CreateCheckin(t *testing.T) {
	tests := []struct {
		name    string
		checkin *models.Checkin
		wantErr bool
	}{
		{
			name:    "成功创建签到",
			checkin: createTestCheckin(),
			wantErr: false,
		},
		{
			name:    "创建空签到",
			checkin: &models.Checkin{},
			wantErr: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockDB := new(MockGormDB)
			service := NewCheckinService(mockDB)

			// 设置mock期望
			mockDB.On("Create", tt.checkin).Return(&gorm.DB{})

			err := service.CreateCheckin(tt.checkin)

			if tt.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}

			mockDB.AssertExpectations(t)
		})
	}
}

func TestCheckinService_GetCheckinsByUserID(t *testing.T) {
	tests := []struct {
		name    string
		userID  uint
		wantErr bool
	}{
		{
			name:    "成功获取用户签到记录",
			userID:  1,
			wantErr: false,
		},
		{
			name:    "获取不存在用户的签到记录",
			userID:  999,
			wantErr: false, // 应该返回空列表而不是错误
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockDB := new(MockGormDB)
			service := NewCheckinService(mockDB)

			// 设置mock期望
			mockDB.On("Where", mock.Anything, mock.Anything).Return(mockDB)
			mockDB.On("Order", mock.Anything).Return(mockDB)
			mockDB.On("Find", mock.Anything).Return(&gorm.DB{})

			checkins, err := service.GetCheckinsByUserID(tt.userID)

			if tt.wantErr {
				assert.Error(t, err)
				assert.Nil(t, checkins)
			} else {
				assert.NoError(t, err)
				assert.NotNil(t, checkins)
			}

			mockDB.AssertExpectations(t)
		})
	}
}

func TestCheckinService_GetCheckinStreak(t *testing.T) {
	tests := []struct {
		name    string
		userID  uint
		wantErr bool
	}{
		{
			name:    "成功获取签到连续天数",
			userID:  1,
			wantErr: false,
		},
		{
			name:    "获取不存在用户的签到连续天数",
			userID:  999,
			wantErr: false, // 应该返回0而不是错误
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockDB := new(MockGormDB)
			service := NewCheckinService(mockDB)

			// 设置mock期望
			mockDB.On("Where", mock.Anything, mock.Anything).Return(mockDB)
			mockDB.On("Order", mock.Anything).Return(mockDB)
			mockDB.On("Find", mock.Anything).Return(&gorm.DB{})

			streak, err := service.GetCheckinStreak(tt.userID)

			if tt.wantErr {
				assert.Error(t, err)
				assert.Equal(t, 0, streak)
			} else {
				assert.NoError(t, err)
				assert.GreaterOrEqual(t, streak, 0)
			}

			mockDB.AssertExpectations(t)
		})
	}
}

// NutritionService 测试
func TestNutritionService_CreateNutritionRecord(t *testing.T) {
	tests := []struct {
		name    string
		record  *models.NutritionRecord
		wantErr bool
	}{
		{
			name: "成功创建营养记录",
			record: &models.NutritionRecord{
				UserID:   1,
				FoodName: "鸡胸肉",
				Quantity: 100.0,
				Calories: 165.0,
				Protein:  31.0,
				Carbs:    0.0,
				Fat:      3.6,
			},
			wantErr: false,
		},
		{
			name:    "创建空营养记录",
			record:  &models.NutritionRecord{},
			wantErr: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockDB := new(MockGormDB)
			service := NewNutritionService(mockDB)

			// 设置mock期望
			mockDB.On("Create", tt.record).Return(&gorm.DB{})

			err := service.CreateNutritionRecord(tt.record)

			if tt.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}

			mockDB.AssertExpectations(t)
		})
	}
}

func TestNutritionService_GetNutritionRecordsByUserID(t *testing.T) {
	tests := []struct {
		name    string
		userID  uint
		wantErr bool
	}{
		{
			name:    "成功获取用户营养记录",
			userID:  1,
			wantErr: false,
		},
		{
			name:    "获取不存在用户的营养记录",
			userID:  999,
			wantErr: false, // 应该返回空列表而不是错误
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockDB := new(MockGormDB)
			service := NewNutritionService(mockDB)

			// 设置mock期望
			mockDB.On("Where", mock.Anything, mock.Anything).Return(mockDB)
			mockDB.On("Order", mock.Anything).Return(mockDB)
			mockDB.On("Find", mock.Anything).Return(&gorm.DB{})

			records, err := service.GetNutritionRecordsByUserID(tt.userID)

			if tt.wantErr {
				assert.Error(t, err)
				assert.Nil(t, records)
			} else {
				assert.NoError(t, err)
				assert.NotNil(t, records)
			}

			mockDB.AssertExpectations(t)
		})
	}
}

// 性能测试
func BenchmarkUserService_CreateUser(b *testing.B) {
	mockDB := new(MockGormDB)
	service := NewUserService(mockDB)

	user := createTestUser()

	// 设置mock期望
	mockDB.On("Create", mock.Anything).Return(&gorm.DB{})

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		service.CreateUser(user)
	}
}

func BenchmarkBMIService_CalculateBMI(b *testing.B) {
	mockDB := new(MockGormDB)
	service := NewBMIService(mockDB)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		service.CalculateBMI(175.0, 70.0, 25, "male")
	}
}

// 集成测试
func TestServiceIntegration(t *testing.T) {
	t.Run("用户服务集成测试", func(t *testing.T) {
		mockDB := new(MockGormDB)
		userService := NewUserService(mockDB)
		workoutService := NewWorkoutService(mockDB)

		// 创建用户
		user := createTestUser()
		mockDB.On("Create", user).Return(&gorm.DB{})

		err := userService.CreateUser(user)
		assert.NoError(t, err)

		// 创建训练记录
		workout := createTestWorkout()
		mockDB.On("Create", workout).Return(&gorm.DB{})

		err = workoutService.CreateWorkout(workout)
		assert.NoError(t, err)

		mockDB.AssertExpectations(t)
	})

	t.Run("社区服务集成测试", func(t *testing.T) {
		mockDB := new(MockGormDB)
		communityService := NewCommunityService(mockDB)

		// 创建动态
		post := createTestPost()
		mockDB.On("Create", post).Return(&gorm.DB{})

		err := communityService.CreatePost(post)
		assert.NoError(t, err)

		// 点赞动态
		mockDB.On("First", mock.Anything, mock.Anything).Return(&gorm.DB{})
		mockDB.On("Create", mock.Anything).Return(&gorm.DB{})

		err = communityService.LikePost(1, 1)
		assert.NoError(t, err)

		mockDB.AssertExpectations(t)
	})
}
