package services

import (
	"errors"
	"fmt"
	"time"

	"fittracker/internal/models"

	"github.com/go-redis/redis/v8"
	"gorm.io/gorm"
)

type WorkoutService struct {
	db    *gorm.DB
	redis *redis.Client
}

func NewWorkoutService(db *gorm.DB, redis *redis.Client) *WorkoutService {
	return &WorkoutService{
		db:    db,
		redis: redis,
	}
}

// CreateWorkoutPlan 创建训练计划
func (s *WorkoutService) CreateWorkoutPlan(plan *models.TrainingPlan) error {
	if err := s.db.Create(plan).Error; err != nil {
		return fmt.Errorf("failed to create workout plan: %w", err)
	}

	// 预加载用户信息
	if err := s.db.Preload("User").First(plan, plan.ID).Error; err != nil {
		return fmt.Errorf("failed to load workout plan with user: %w", err)
	}

	return nil
}

// GetWorkoutPlans 获取训练计划列表
func (s *WorkoutService) GetWorkoutPlans(userID uint, isPublic bool, page, limit int) ([]models.TrainingPlan, int64, error) {
	var plans []models.TrainingPlan
	var total int64

	offset := (page - 1) * limit
	query := s.db.Model(&models.TrainingPlan{})

	if isPublic {
		query = query.Where("is_public = ?", true)
	} else {
		query = query.Where("user_id = ?", userID)
	}

	// 获取总数
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, fmt.Errorf("failed to count workout plans: %w", err)
	}

	// 获取计划列表
	if err := query.Preload("User").
		Preload("Sessions").
		Order("created_at DESC").
		Offset(offset).
		Limit(limit).
		Find(&plans).Error; err != nil {
		return nil, 0, fmt.Errorf("failed to get workout plans: %w", err)
	}

	return plans, total, nil
}

// GetWorkoutPlanByID 根据ID获取训练计划
func (s *WorkoutService) GetWorkoutPlanByID(id uint) (*models.TrainingPlan, error) {
	var plan models.TrainingPlan

	if err := s.db.Preload("User").
		Preload("Sessions").
		Preload("Sessions.Exercises").
		First(&plan, id).Error; err != nil {
		return nil, fmt.Errorf("workout plan not found: %w", err)
	}

	return &plan, nil
}

// CreateWorkoutSession 创建训练会话
func (s *WorkoutService) CreateWorkoutSession(session *models.WorkoutSession, exercises []ExerciseRequest) error {
	// 开始事务
	tx := s.db.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// 创建训练会话
	if err := tx.Create(session).Error; err != nil {
		tx.Rollback()
		return fmt.Errorf("failed to create workout session: %w", err)
	}

	// 创建训练动作
	for _, exerciseReq := range exercises {
		exercise := &models.WorkoutExercise{
			SessionID: session.ID,
			Name:      exerciseReq.Name,
			Category:  exerciseReq.Category,
			Sets:      exerciseReq.Sets,
			Reps:      exerciseReq.Reps,
			Weight:    exerciseReq.Weight,
			Duration:  exerciseReq.Duration,
			RestTime:  exerciseReq.RestTime,
			Notes:     exerciseReq.Notes,
		}

		if err := tx.Create(exercise).Error; err != nil {
			tx.Rollback()
			return fmt.Errorf("failed to create workout exercise: %w", err)
		}
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		return fmt.Errorf("failed to commit transaction: %w", err)
	}

	// 预加载关联数据
	if err := s.db.Preload("User").
		Preload("Plan").
		Preload("Exercises").
		First(session, session.ID).Error; err != nil {
		return fmt.Errorf("failed to load workout session with relations: %w", err)
	}

	return nil
}

// GetWorkoutSessions 获取训练会话列表
func (s *WorkoutService) GetWorkoutSessions(userID uint, planID *uint, page, limit int) ([]models.WorkoutSession, int64, error) {
	var sessions []models.WorkoutSession
	var total int64

	offset := (page - 1) * limit
	query := s.db.Model(&models.WorkoutSession{}).Where("user_id = ?", userID)

	if planID != nil {
		query = query.Where("plan_id = ?", *planID)
	}

	// 获取总数
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, fmt.Errorf("failed to count workout sessions: %w", err)
	}

	// 获取会话列表
	if err := query.Preload("User").
		Preload("Plan").
		Preload("Exercises").
		Order("date DESC").
		Offset(offset).
		Limit(limit).
		Find(&sessions).Error; err != nil {
		return nil, 0, fmt.Errorf("failed to get workout sessions: %w", err)
	}

	return sessions, total, nil
}

// CreateCheckIn 创建打卡记录
func (s *WorkoutService) CreateCheckIn(checkIn *models.CheckIn) error {
	// 检查当天是否已经打卡
	var existingCheckIn models.CheckIn
	if err := s.db.Where("user_id = ? AND DATE(date) = DATE(?)", checkIn.UserID, checkIn.Date).First(&existingCheckIn).Error; err == nil {
		return errors.New("already checked in today")
	}

	if err := s.db.Create(checkIn).Error; err != nil {
		return fmt.Errorf("failed to create check-in: %w", err)
	}

	// 预加载用户信息
	if err := s.db.Preload("User").First(checkIn, checkIn.ID).Error; err != nil {
		return fmt.Errorf("failed to load check-in with user: %w", err)
	}

	return nil
}

// GetCheckIns 获取打卡记录列表
func (s *WorkoutService) GetCheckIns(userID uint, year, month string, page, limit int) ([]models.CheckIn, int64, error) {
	var checkIns []models.CheckIn
	var total int64

	offset := (page - 1) * limit
	query := s.db.Model(&models.CheckIn{}).Where("user_id = ?", userID)

	// 根据年份和月份过滤
	if year != "" {
		query = query.Where("EXTRACT(YEAR FROM date) = ?", year)
	}
	if month != "" {
		query = query.Where("EXTRACT(MONTH FROM date) = ?", month)
	}

	// 获取总数
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, fmt.Errorf("failed to count check-ins: %w", err)
	}

	// 获取打卡记录列表
	if err := query.Preload("User").
		Order("date DESC").
		Offset(offset).
		Limit(limit).
		Find(&checkIns).Error; err != nil {
		return nil, 0, fmt.Errorf("failed to get check-ins: %w", err)
	}

	return checkIns, total, nil
}

// GetWorkoutStats 获取训练统计
func (s *WorkoutService) GetWorkoutStats(userID uint, period string) (map[string]interface{}, error) {
	stats := make(map[string]interface{})

	var startDate time.Time
	now := time.Now()

	switch period {
	case "week":
		startDate = now.AddDate(0, 0, -7)
	case "month":
		startDate = now.AddDate(0, -1, 0)
	case "year":
		startDate = now.AddDate(-1, 0, 0)
	default:
		startDate = now.AddDate(0, -1, 0) // 默认一个月
	}

	// 总训练次数
	var totalSessions int64
	if err := s.db.Model(&models.WorkoutSession{}).
		Where("user_id = ? AND date >= ?", userID, startDate).
		Count(&totalSessions).Error; err != nil {
		return nil, fmt.Errorf("failed to count total sessions: %w", err)
	}

	// 总训练时长（分钟）
	var totalDuration int
	if err := s.db.Model(&models.WorkoutSession{}).
		Where("user_id = ? AND date >= ?", userID, startDate).
		Select("COALESCE(SUM(duration), 0)").
		Scan(&totalDuration).Error; err != nil {
		return nil, fmt.Errorf("failed to calculate total duration: %w", err)
	}

	// 总消耗卡路里
	var totalCalories int
	if err := s.db.Model(&models.WorkoutSession{}).
		Where("user_id = ? AND date >= ?", userID, startDate).
		Select("COALESCE(SUM(calories), 0)").
		Scan(&totalCalories).Error; err != nil {
		return nil, fmt.Errorf("failed to calculate total calories: %w", err)
	}

	// 打卡天数
	var checkInDays int64
	if err := s.db.Model(&models.CheckIn{}).
		Where("user_id = ? AND date >= ?", userID, startDate).
		Count(&checkInDays).Error; err != nil {
		return nil, fmt.Errorf("failed to count check-in days: %w", err)
	}

	// 平均训练时长
	var avgDuration float64
	if totalSessions > 0 {
		avgDuration = float64(totalDuration) / float64(totalSessions)
	}

	stats["total_sessions"] = totalSessions
	stats["total_duration"] = totalDuration
	stats["total_calories"] = totalCalories
	stats["check_in_days"] = checkInDays
	stats["avg_duration"] = avgDuration
	stats["period"] = period
	stats["start_date"] = startDate
	stats["end_date"] = now

	return stats, nil
}

// ExerciseRequest 训练动作请求结构
type ExerciseRequest struct {
	Name     string  `json:"name"`
	Category string  `json:"category"`
	Sets     int     `json:"sets"`
	Reps     int     `json:"reps"`
	Weight   float64 `json:"weight"`
	Duration int     `json:"duration"`
	Distance float64 `json:"distance"`
	RestTime int     `json:"rest_time"`
	Notes    string  `json:"notes"`
}
