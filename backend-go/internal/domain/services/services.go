package services

import (
	"fittracker/internal/config"
	"fittracker/internal/domain/models"
	"fittracker/internal/domain/repositories"

	"gorm.io/gorm"
)

// UserService 用户服务
type UserService struct {
	userRepo repositories.UserRepository
}

// NewUserService 创建用户服务
func NewUserService(db *gorm.DB) *UserService {
	return &UserService{
		userRepo: repositories.NewUserRepository(db),
	}
}

// CreateUser 创建用户
func (s *UserService) CreateUser(user *models.User) error {
	return s.userRepo.Create(user)
}

// GetUserByID 根据ID获取用户
func (s *UserService) GetUserByID(id uint) (*models.User, error) {
	return s.userRepo.GetByID(id)
}

// GetUserByEmail 根据邮箱获取用户
func (s *UserService) GetUserByEmail(email string) (*models.User, error) {
	return s.userRepo.GetByEmail(email)
}

// GetUserByUsername 根据用户名获取用户
func (s *UserService) GetUserByUsername(username string) (*models.User, error) {
	return s.userRepo.GetByUsername(username)
}

// UpdateUser 更新用户
func (s *UserService) UpdateUser(user *models.User) error {
	return s.userRepo.Update(user)
}

// DeleteUser 删除用户
func (s *UserService) DeleteUser(id uint) error {
	return s.userRepo.Delete(id)
}

// GetUserStats 获取用户统计信息
func (s *UserService) GetUserStats(userID uint) (*models.UserStats, error) {
	return s.userRepo.GetStats(userID)
}

// WorkoutService 训练服务
type WorkoutService struct {
	workoutRepo  repositories.WorkoutRepository
	planRepo     repositories.TrainingPlanRepository
	exerciseRepo repositories.ExerciseRepository
}

// NewWorkoutService 创建训练服务
func NewWorkoutService(db *gorm.DB) *WorkoutService {
	return &WorkoutService{
		workoutRepo:  repositories.NewWorkoutRepository(db),
		planRepo:     repositories.NewTrainingPlanRepository(db),
		exerciseRepo: repositories.NewExerciseRepository(db),
	}
}

// CreateWorkout 创建训练记录
func (s *WorkoutService) CreateWorkout(workout *models.Workout) error {
	return s.workoutRepo.Create(workout)
}

// GetWorkouts 获取训练记录列表
func (s *WorkoutService) GetWorkouts(userID uint, limit, offset int) ([]*models.Workout, error) {
	return s.workoutRepo.GetByUserID(userID, limit, offset)
}

// GetWorkout 获取单个训练记录
func (s *WorkoutService) GetWorkout(id uint) (*models.Workout, error) {
	return s.workoutRepo.GetByID(id)
}

// UpdateWorkout 更新训练记录
func (s *WorkoutService) UpdateWorkout(workout *models.Workout) error {
	return s.workoutRepo.Update(workout)
}

// DeleteWorkout 删除训练记录
func (s *WorkoutService) DeleteWorkout(id uint) error {
	return s.workoutRepo.Delete(id)
}

// CreateTrainingPlan 创建训练计划
func (s *WorkoutService) CreateTrainingPlan(plan *models.TrainingPlan) error {
	return s.planRepo.Create(plan)
}

// GetTrainingPlans 获取训练计划列表
func (s *WorkoutService) GetTrainingPlans(limit, offset int) ([]*models.TrainingPlan, error) {
	return s.planRepo.GetAll(limit, offset)
}

// GetTrainingPlan 获取单个训练计划
func (s *WorkoutService) GetTrainingPlan(id uint) (*models.TrainingPlan, error) {
	return s.planRepo.GetByID(id)
}

// UpdateTrainingPlan 更新训练计划
func (s *WorkoutService) UpdateTrainingPlan(plan *models.TrainingPlan) error {
	return s.planRepo.Update(plan)
}

// DeleteTrainingPlan 删除训练计划
func (s *WorkoutService) DeleteTrainingPlan(id uint) error {
	return s.planRepo.Delete(id)
}

// GetExercises 获取运动动作列表
func (s *WorkoutService) GetExercises(category string, limit, offset int) ([]*models.Exercise, error) {
	return s.exerciseRepo.GetByCategory(category, limit, offset)
}

// CreateExercise 创建运动动作
func (s *WorkoutService) CreateExercise(exercise *models.Exercise) error {
	return s.exerciseRepo.Create(exercise)
}

// GetExercise 获取单个运动动作
func (s *WorkoutService) GetExercise(id uint) (*models.Exercise, error) {
	return s.exerciseRepo.GetByID(id)
}

// BMIService BMI服务
type BMIService struct {
	healthRepo repositories.HealthRecordRepository
}

// NewBMIService 创建BMI服务
func NewBMIService(db *gorm.DB) *BMIService {
	return &BMIService{
		healthRepo: repositories.NewHealthRecordRepository(db),
	}
}

// CalculateBMI 计算BMI
func (s *BMIService) CalculateBMI(height, weight float64) float64 {
	return weight / (height * height / 10000)
}

// CreateHealthRecord 创建健康记录
func (s *BMIService) CreateHealthRecord(record *models.HealthRecord) error {
	return s.healthRepo.Create(record)
}

// GetHealthRecords 获取健康记录列表
func (s *BMIService) GetHealthRecords(userID uint, recordType string, limit, offset int) ([]*models.HealthRecord, error) {
	return s.healthRepo.GetByUserIDAndType(userID, recordType, limit, offset)
}

// UpdateHealthRecord 更新健康记录
func (s *BMIService) UpdateHealthRecord(record *models.HealthRecord) error {
	return s.healthRepo.Update(record)
}

// DeleteHealthRecord 删除健康记录
func (s *BMIService) DeleteHealthRecord(id uint) error {
	return s.healthRepo.Delete(id)
}

// NutritionService 营养服务
type NutritionService struct {
	nutritionRepo repositories.NutritionRecordRepository
}

// NewNutritionService 创建营养服务
func NewNutritionService(db *gorm.DB) *NutritionService {
	return &NutritionService{
		nutritionRepo: repositories.NewNutritionRecordRepository(db),
	}
}

// CalculateNutrition 计算营养信息
func (s *NutritionService) CalculateNutrition(foodName string, quantity float64) (*models.NutritionInfo, error) {
	// 这里应该调用食物数据库API或本地数据库
	// 简化实现，返回模拟数据
	return &models.NutritionInfo{
		FoodName: foodName,
		Quantity: quantity,
		Calories: quantity * 2.5, // 模拟计算
		Protein:  quantity * 0.1,
		Carbs:    quantity * 0.3,
		Fat:      quantity * 0.05,
		Fiber:    quantity * 0.02,
		Sugar:    quantity * 0.1,
		Sodium:   quantity * 0.01,
	}, nil
}

// CheckinService 签到服务
type CheckinService struct {
	checkinRepo repositories.CheckinRepository
}

// NewCheckinService 创建签到服务
func NewCheckinService(db *gorm.DB) *CheckinService {
	return &CheckinService{
		checkinRepo: repositories.NewCheckinRepository(db),
	}
}

// CreateCheckin 创建签到记录
func (s *CheckinService) CreateCheckin(checkin *models.Checkin) error {
	return s.checkinRepo.Create(checkin)
}

// GetCheckins 获取签到记录列表
func (s *CheckinService) GetCheckins(userID uint, limit, offset int) ([]*models.Checkin, error) {
	return s.checkinRepo.GetByUserID(userID, limit, offset)
}

// GetCheckinStreak 获取连续签到天数
func (s *CheckinService) GetCheckinStreak(userID uint) (int, error) {
	return s.checkinRepo.GetStreak(userID)
}

// CommunityService 社区服务
type CommunityService struct {
	postRepo      repositories.PostRepository
	likeRepo      repositories.LikeRepository
	commentRepo   repositories.CommentRepository
	followRepo    repositories.FollowRepository
	challengeRepo repositories.ChallengeRepository
}

// NewCommunityService 创建社区服务
func NewCommunityService(db *gorm.DB) *CommunityService {
	return &CommunityService{
		postRepo:      repositories.NewPostRepository(db),
		likeRepo:      repositories.NewLikeRepository(db),
		commentRepo:   repositories.NewCommentRepository(db),
		followRepo:    repositories.NewFollowRepository(db),
		challengeRepo: repositories.NewChallengeRepository(db),
	}
}

// CreatePost 创建动态
func (s *CommunityService) CreatePost(post *models.Post) error {
	return s.postRepo.Create(post)
}

// GetPosts 获取动态列表
func (s *CommunityService) GetPosts(userID uint, limit, offset int) ([]*models.Post, error) {
	return s.postRepo.GetFeed(userID, limit, offset)
}

// LikePost 点赞动态
func (s *CommunityService) LikePost(userID, postID uint) error {
	return s.likeRepo.Create(&models.Like{
		UserID: userID,
		PostID: postID,
	})
}

// UnlikePost 取消点赞
func (s *CommunityService) UnlikePost(userID, postID uint) error {
	return s.likeRepo.DeleteByUserAndPost(userID, postID)
}

// CreateComment 创建评论
func (s *CommunityService) CreateComment(comment *models.Comment) error {
	return s.commentRepo.Create(comment)
}

// FollowUser 关注用户
func (s *CommunityService) FollowUser(followerID, followingID uint) error {
	return s.followRepo.Create(&models.Follow{
		FollowerID:  followerID,
		FollowingID: followingID,
	})
}

// UnfollowUser 取消关注
func (s *CommunityService) UnfollowUser(followerID, followingID uint) error {
	return s.followRepo.DeleteByFollowerAndFollowing(followerID, followingID)
}

// AICoachService AI教练服务
type AICoachService struct {
	config *config.Config
}

// NewAICoachService 创建AI教练服务
func NewAICoachService(cfg *config.Config) *AICoachService {
	return &AICoachService{
		config: cfg,
	}
}

// GenerateWorkoutPlan 生成训练计划
func (s *AICoachService) GenerateWorkoutPlan(userProfile map[string]interface{}) (*models.AIWorkoutPlan, error) {
	// 这里应该调用LLM API
	// 简化实现，返回模拟数据
	return &models.AIWorkoutPlan{
		Name:        "AI个性化训练计划",
		Description: "根据您的需求生成的个性化训练计划",
		Duration:    8,
		Exercises:   []models.AIExercise{},
		Tips:        []string{"保持规律训练", "注意动作标准"},
	}, nil
}

// AINutritionService AI营养师服务
type AINutritionService struct {
	config *config.Config
}

// NewAINutritionService 创建AI营养师服务
func NewAINutritionService(cfg *config.Config) *AINutritionService {
	return &AINutritionService{
		config: cfg,
	}
}

// GenerateMealPlan 生成饮食计划
func (s *AINutritionService) GenerateMealPlan(userProfile map[string]interface{}) (*models.AIMealPlan, error) {
	// 这里应该调用LLM API
	// 简化实现，返回模拟数据
	return &models.AIMealPlan{
		Name:        "AI个性化饮食计划",
		Description: "根据您的需求生成的个性化饮食计划",
		Duration:    7,
		Meals:       []models.AIMeal{},
		Tips:        []string{"保持均衡饮食", "多喝水"},
	}, nil
}
