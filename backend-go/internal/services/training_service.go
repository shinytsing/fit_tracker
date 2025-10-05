package services

import (
	"fmt"
	"time"

	"gymates/internal/models"

	"gorm.io/gorm"
)

// TrainingService 训练服务
type TrainingService struct {
	db          *gorm.DB
	aiService   *AIService
	userService *UserService
}

// NewTrainingService 创建训练服务
func NewTrainingService(db *gorm.DB, aiService *AIService, userService *UserService) *TrainingService {
	return &TrainingService{
		db:          db,
		aiService:   aiService,
		userService: userService,
	}
}

// GetTodayPlan 获取今日训练计划
func (s *TrainingService) GetTodayPlan(userID uint) (*models.TrainingPlan, error) {
	today := time.Now().Format("2006-01-02")

	var plan models.TrainingPlan
	err := s.db.Where("user_id = ? AND created_at >= ?", userID, today).
		Preload("Exercises").
		First(&plan).Error

	if err != nil {
		// 如果没有今日计划，返回默认计划
		plan = models.TrainingPlan{
			ID:          "1",
			UserID:      fmt.Sprintf("%d", userID),
			Name:        "今日训练计划",
			Description: "适合初学者的基础训练计划",
			Duration:    30,
			CreatedAt:   time.Now(),
			UpdatedAt:   time.Now(),
			Exercises: []models.TrainingExercise{
				{
					ID:           "1",
					PlanID:       "1",
					Name:         "俯卧撑",
					Description:  "经典的上肢力量训练动作",
					Category:     "胸肌",
					Difficulty:   "初级",
					MuscleGroups: []string{"胸肌", "三头肌", "肩部"},
					Equipment:    []string{"无器械"},
					Instructions: "保持身体挺直，核心收紧",
					Order:        1,
				},
				{
					ID:           "2",
					PlanID:       "1",
					Name:         "深蹲",
					Description:  "经典的下肢力量训练动作",
					Category:     "腿部",
					Difficulty:   "初级",
					MuscleGroups: []string{"股四头肌", "臀肌"},
					Equipment:    []string{"无器械"},
					Instructions: "保持背部挺直，膝盖不超过脚尖",
					Order:        2,
				},
			},
		}
	}

	return &plan, nil
}

// GetHistoryPlans 获取历史训练计划
func (s *TrainingService) GetHistoryPlans(userID string, page, limit int) ([]*models.TrainingPlan, bool, error) {
	offset := (page - 1) * limit

	var plans []*models.TrainingPlan
	err := s.db.Where("user_id = ?", userID).
		Preload("Exercises").
		Order("created_at DESC").
		Offset(offset).
		Limit(limit + 1).
		Find(&plans).Error

	if err != nil {
		return nil, false, err
	}

	hasMore := len(plans) > limit
	if hasMore {
		plans = plans[:limit]
	}

	return plans, hasMore, nil
}

// CreatePlan 创建训练计划
func (s *TrainingService) CreatePlan(plan *models.TrainingPlan) (*models.TrainingPlan, error) {
	plan.CreatedAt = time.Now()
	plan.UpdatedAt = time.Now()

	if err := s.db.Create(plan).Error; err != nil {
		return nil, err
	}

	// 预加载关联数据
	if err := s.db.Preload("Exercises").First(plan, "id = ?", plan.ID).Error; err != nil {
		return nil, err
	}

	return plan, nil
}

// UpdatePlan 更新训练计划
func (s *TrainingService) UpdatePlan(planID string, plan *models.TrainingPlan) error {
	plan.UpdatedAt = time.Now()
	return s.db.Model(&models.TrainingPlan{}).Where("id = ?", planID).Updates(plan).Error
}

// DeletePlan 删除训练计划
func (s *TrainingService) DeletePlan(planID string) error {
	return s.db.Delete(&models.TrainingPlan{}, planID).Error
}

// GenerateAIPlan 生成AI训练计划
func (s *TrainingService) GenerateAIPlan(userID uint, req *models.GenerateTrainingPlanRequest) (*models.TrainingPlan, error) {
	// 调用AI服务生成训练计划
	aiPlan, err := s.aiService.GenerateTrainingPlan(req)
	if err != nil {
		return nil, fmt.Errorf("AI生成训练计划失败: %v", err)
	}

	// 设置用户ID
	aiPlan.UserID = fmt.Sprintf("%d", userID)

	// 保存到数据库
	return s.CreatePlan(aiPlan)
}

// CompleteExercise 完成动作
func (s *TrainingService) CompleteExercise(exerciseID string, userID string) error {
	// 这里应该记录动作完成情况
	return nil
}

// CompleteWorkout 完成训练
func (s *TrainingService) CompleteWorkout(planID string, userID string) error {
	// 这里应该记录训练完成情况
	return nil
}

// GetExercises 获取动作库
func (s *TrainingService) GetExercises(category string, difficulty string) ([]*models.TrainingExercise, error) {
	var exercises []*models.TrainingExercise
	query := s.db.Model(&models.TrainingExercise{})

	if category != "" {
		query = query.Where("category = ?", category)
	}
	if difficulty != "" {
		query = query.Where("difficulty = ?", difficulty)
	}

	err := query.Find(&exercises).Error
	return exercises, err
}

// GetUserProfile 获取用户资料
func (s *TrainingService) GetUserProfile(userID string) (*models.User, error) {
	var user models.User
	err := s.db.First(&user, userID).Error
	return &user, err
}

// GetUserTrainingHistory 获取用户训练历史
func (s *TrainingService) GetUserTrainingHistory(userID string, days int) ([]*models.TrainingPlan, error) {
	since := time.Now().AddDate(0, 0, -days)

	var plans []*models.TrainingPlan
	err := s.db.Where("user_id = ? AND created_at >= ?", userID, since).
		Preload("Exercises").
		Order("created_at DESC").
		Find(&plans).Error

	return plans, err
}
