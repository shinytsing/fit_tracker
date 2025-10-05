package services

import (
	"errors"
	"fmt"
	"time"

	"gymates/internal/models"
	"gymates/pkg/logger"

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
func (s *TrainingService) GetTodayPlan(userID string) (*models.TrainingPlanResponse, error) {
	today := time.Now().Format("2006-01-02")

	var plan models.TrainingPlan
	err := s.db.Where("user_id = ? AND DATE(date) = ?", userID, today).
		Preload("Exercises.Sets").
		First(&plan).Error

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			// 如果没有今日计划，生成默认计划
			return s.generateDefaultPlan(userID)
		}
		logger.Error.Printf("获取今日训练计划失败: user_id=%v, error=%v", userID, err.Error())
		return nil, err
	}

	return s.convertToPlanResponse(plan), nil
}

// GetHistoryPlans 获取历史训练计划
func (s *TrainingService) GetHistoryPlans(userID string, skip, limit int) ([]models.TrainingPlanResponse, error) {
	var plans []models.TrainingPlan
	err := s.db.Where("user_id = ?", userID).
		Preload("Exercises.Sets").
		Order("date DESC").
		Limit(limit).
		Offset(skip).
		Find(&plans).Error

	if err != nil {
		logger.Error.Printf("获取历史训练计划失败: user_id=%v, error=%v", userID, err.Error())
		return nil, err
	}

	var responses []models.TrainingPlanResponse
	for _, plan := range plans {
		responses = append(responses, *s.convertToPlanResponse(plan))
	}

	return responses, nil
}

// CreatePlan 创建训练计划
func (s *TrainingService) CreatePlan(userID string, req models.CreatePlanRequest) (*models.TrainingPlanResponse, error) {
	// 解析日期
	date, err := time.Parse("2006-01-02", req.Date)
	if err != nil {
		return nil, errors.New("日期格式错误")
	}

	// 创建训练计划
	plan := models.TrainingPlan{
		UserID:        userID,
		Name:          req.Name,
		Description:   req.Description,
		Date:          date,
		Status:        "pending",
		IsAIGenerated: false,
		CreatedAt:     time.Now(),
		UpdatedAt:     time.Now(),
	}

	// 开始事务
	tx := s.db.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// 保存训练计划
	if err := tx.Create(&plan).Error; err != nil {
		tx.Rollback()
		logger.Error.Printf("创建训练计划失败: user_id=%v, error=%v", userID, err.Error())
		return nil, err
	}

	// 创建动作
	for _, exerciseReq := range req.Exercises {
		exercise := models.TrainingExercise{
			PlanID:       plan.ID,
			Name:         exerciseReq.Name,
			Description:  exerciseReq.Description,
			Category:     exerciseReq.Category,
			Difficulty:   exerciseReq.Difficulty,
			MuscleGroups: exerciseReq.MuscleGroups,
			Equipment:    exerciseReq.Equipment,
			VideoURL:     exerciseReq.VideoURL,
			ImageURL:     exerciseReq.ImageURL,
			Instructions: exerciseReq.Instructions,
			Order:        exerciseReq.Order,
			CreatedAt:    time.Now(),
			UpdatedAt:    time.Now(),
		}

		if err := tx.Create(&exercise).Error; err != nil {
			tx.Rollback()
			logger.Error.Printf("创建训练动作失败: plan_id=%v, error=%v", plan.ID, err.Error())
			return nil, err
		}

		// 创建组数
		for _, setReq := range exerciseReq.Sets {
			set := models.ExerciseSet{
				ExerciseID: exercise.ID,
				Reps:       setReq.Reps,
				Weight:     setReq.Weight,
				Duration:   setReq.Duration,
				Distance:   setReq.Distance,
				RestTime:   setReq.RestTime,
				Order:      setReq.Order,
				CreatedAt:  time.Now(),
				UpdatedAt:  time.Now(),
			}

			if err := tx.Create(&set).Error; err != nil {
				tx.Rollback()
				logger.Error.Printf("创建动作组数失败: exercise_id=%v, error=%v", exercise.ID, err.Error())
				return nil, err
			}
		}
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		logger.Error.Printf("提交训练计划事务失败: error=%v", err.Error())
		return nil, err
	}

	// 重新加载完整数据
	s.db.Preload("Exercises.Sets").First(&plan, plan.ID)
	return s.convertToPlanResponse(plan), nil
}

// UpdatePlan 更新训练计划
func (s *TrainingService) UpdatePlan(userID string, planID uint, req models.UpdatePlanRequest) (*models.TrainingPlanResponse, error) {
	var plan models.TrainingPlan
	err := s.db.Where("id = ? AND user_id = ?", planID, userID).First(&plan).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("训练计划不存在或无权操作")
		}
		logger.Error.Printf("查询训练计划失败", map[string]interface{}{"plan_id": planID, "user_id": userID, "error": err.Error()})
		return nil, err
	}

	// 更新基本信息
	if req.Name != "" {
		plan.Name = req.Name
	}
	if req.Description != "" {
		plan.Description = req.Description
	}
	plan.UpdatedAt = time.Now()

	if err := s.db.Save(&plan).Error; err != nil {
		logger.Error.Printf("更新训练计划失败: plan_id=%v, error=%v", planID, err.Error())
		return nil, err
	}

	// 重新加载完整数据
	s.db.Preload("Exercises.Sets").First(&plan, plan.ID)
	return s.convertToPlanResponse(plan), nil
}

// DeletePlan 删除训练计划
func (s *TrainingService) DeletePlan(userID string, planID uint) error {
	var plan models.TrainingPlan
	err := s.db.Where("id = ? AND user_id = ?", planID, userID).First(&plan).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("训练计划不存在或无权操作")
		}
		logger.Error.Printf("查询训练计划失败", map[string]interface{}{"plan_id": planID, "user_id": userID, "error": err.Error()})
		return err
	}

	// 删除训练计划（级联删除相关数据）
	if err := s.db.Delete(&plan).Error; err != nil {
		logger.Error.Printf("删除训练计划失败: plan_id=%v, error=%v", planID, err.Error())
		return err
	}

	return nil
}

// GenerateAIPlan 生成AI训练计划
func (s *TrainingService) GenerateAIPlan(userID string, req models.GenerateAIPlanRequest) (*models.TrainingPlanResponse, error) {
	// 获取用户资料
	// profile, err := s.userService.GetProfile(userID)
	// if err != nil {
	// 	return nil, errors.New("请先完善个人资料")
	// }

	// 构建AI请求
	aiReq := &models.GenerateTrainingPlanRequest{
		Goal:       req.Goal,
		Duration:   req.Duration,
		Difficulty: req.Difficulty,
		Equipment:  req.Equipment,
		FocusAreas: req.FocusAreas,
	}

	// 调用AI服务生成计划
	aiPlan, err := s.aiService.GenerateTrainingPlan(aiReq)
	if err != nil {
		logger.Error.Printf("AI生成训练计划失败: user_id=%v, error=%v", userID, err.Error())
		return nil, errors.New("AI训练计划生成失败")
	}

	// 转换为数据库模型并保存
	plan := models.TrainingPlan{
		UserID:        userID,
		Name:          aiPlan.Name,
		Description:   aiPlan.Description,
		Date:          time.Now(),
		Duration:      aiPlan.Duration,
		Calories:      aiPlan.Calories,
		Status:        "pending",
		IsAIGenerated: true,
		AIReason:      fmt.Sprintf("基于目标：%s，难度：%s，时长：%d分钟", req.Goal, req.Difficulty, req.Duration),
		CreatedAt:     time.Now(),
		UpdatedAt:     time.Now(),
	}

	// 保存AI生成的计划
	if err := s.db.Create(&plan).Error; err != nil {
		logger.Error.Printf("保存AI训练计划失败: user_id=%v, error=%v", userID, err.Error())
		return nil, err
	}

	// 重新加载完整数据
	s.db.Preload("Exercises.Sets").First(&plan, plan.ID)
	return s.convertToPlanResponse(plan), nil
}

// StartWorkout 开始训练
func (s *TrainingService) StartWorkout(userID string, req models.StartWorkoutRequest) (*models.WorkoutRecordResponse, error) {
	record := models.WorkoutRecord{
		UserID:    userID,
		PlanID:    req.PlanID,
		StartTime: time.Now(),
		Status:    "in_progress",
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	if err := s.db.Create(&record).Error; err != nil {
		logger.Error.Printf("开始训练失败: user_id=%v, error=%v", userID, err.Error())
		return nil, err
	}

	return s.convertToRecordResponse(record), nil
}

// EndWorkout 结束训练
func (s *TrainingService) EndWorkout(userID string, req models.EndWorkoutRequest) (*models.WorkoutRecordResponse, error) {
	var record models.WorkoutRecord
	err := s.db.Where("id = ? AND user_id = ?", req.RecordID, userID).First(&record).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("训练记录不存在或无权操作")
		}
		logger.Error.Printf("查询训练记录失败: record_id=%v, user_id=%v, error=%v", req.RecordID, userID, err.Error())
		return nil, err
	}

	record.EndTime = time.Now()
	record.Duration = int(record.EndTime.Sub(record.StartTime).Minutes())
	record.Calories = req.Calories
	record.Notes = req.Notes
	record.Status = "completed"
	record.UpdatedAt = time.Now()

	if err := s.db.Save(&record).Error; err != nil {
		logger.Error.Printf("结束训练失败: record_id=%v, error=%v", req.RecordID, err.Error())
		return nil, err
	}

	return s.convertToRecordResponse(record), nil
}

// CompleteExercise 完成动作
func (s *TrainingService) CompleteExercise(userID string, req models.CompleteExerciseRequest) error {
	// 验证动作是否存在
	var exercise models.TrainingExercise
	err := s.db.First(&exercise, req.ExerciseID).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("动作不存在")
		}
		logger.Error.Printf("查询动作失败: exercise_id=%v, error=%v", req.ExerciseID, err.Error())
		return err
	}

	// 更新组数完成状态
	for _, setReq := range req.Sets {
		var set models.ExerciseSet
		err := s.db.Where("id = ? AND exercise_id = ?", setReq.SetID, req.ExerciseID).First(&set).Error
		if err != nil {
			logger.Error.Printf("查询组数失败: set_id=%v, error=%v", setReq.SetID, err.Error())
			continue
		}

		set.Reps = setReq.Reps
		set.Weight = setReq.Weight
		set.Duration = setReq.Duration
		set.Distance = setReq.Distance
		set.Completed = setReq.Completed
		set.UpdatedAt = time.Now()

		if err := s.db.Save(&set).Error; err != nil {
			logger.Error.Printf("更新组数失败: set_id=%v, error=%v", setReq.SetID, err.Error())
			return err
		}
	}

	return nil
}

// SubmitFeedback 提交动作反馈
func (s *TrainingService) SubmitFeedback(userID string, req models.SubmitFeedbackRequest) (*models.ExerciseFeedbackResponse, error) {
	feedback := models.ExerciseFeedback{
		UserID:     userID,
		ExerciseID: req.ExerciseID,
		RecordID:   req.RecordID,
		Rating:     req.Rating,
		Difficulty: req.Difficulty,
		PainLevel:  req.PainLevel,
		Comments:   req.Comments,
		CreatedAt:  time.Now(),
		UpdatedAt:  time.Now(),
	}

	if err := s.db.Create(&feedback).Error; err != nil {
		logger.Error.Printf("提交反馈失败: user_id=%v, exercise_id=%v, error=%v", userID, req.ExerciseID, err.Error())
		return nil, err
	}

	return s.convertToFeedbackResponse(feedback), nil
}

// GetWorkoutHistory 获取训练历史
func (s *TrainingService) GetWorkoutHistory(userID string, skip, limit int) ([]models.WorkoutRecordResponse, error) {
	var records []models.WorkoutRecord
	err := s.db.Where("user_id = ?", userID).
		Preload("Plan").
		Order("start_time DESC").
		Limit(limit).
		Offset(skip).
		Find(&records).Error

	if err != nil {
		logger.Error.Printf("获取训练历史失败: user_id=%v, error=%v", userID, err.Error())
		return nil, err
	}

	var responses []models.WorkoutRecordResponse
	for _, record := range records {
		responses = append(responses, *s.convertToRecordResponse(record))
	}

	return responses, nil
}

// GetTrainingStats 获取训练统计
func (s *TrainingService) GetTrainingStats(userID string) (*models.TrainingStatsResponse, error) {
	var stats models.TrainingStatsResponse

	// 基础统计
	var totalWorkouts int64
	var totalDuration int64
	var totalCalories int64

	s.db.Model(&models.WorkoutRecord{}).
		Where("user_id = ?", userID).
		Select("COUNT(*), COALESCE(SUM(duration), 0), COALESCE(SUM(calories_burned), 0)").
		Row().Scan(&totalWorkouts, &totalDuration, &totalCalories)

	stats.TotalWorkouts = int(totalWorkouts)
	stats.TotalDuration = int(totalDuration)
	stats.TotalCalories = int(totalCalories)

	if totalWorkouts > 0 {
		stats.AverageDuration = float64(totalDuration) / float64(totalWorkouts)
		stats.AverageCalories = float64(totalCalories) / float64(totalWorkouts)
	}

	// 连续训练天数
	stats.StreakDays = s.calculateCurrentStreak(userID)
	stats.LongestStreak = s.calculateLongestStreak(userID)

	// 最喜欢的训练部位
	stats.FavoriteExercise = s.getFavoriteCategory(userID)

	// 周统计
	// stats.WeeklyStats = s.getWeeklyStats(userID)

	return &stats, nil
}

// 辅助方法

// generateDefaultPlan 生成默认训练计划
func (s *TrainingService) generateDefaultPlan(userID string) (*models.TrainingPlanResponse, error) {
	plan := models.TrainingPlan{
		UserID:        userID,
		Name:          "今日训练计划",
		Description:   "适合初学者的基础训练计划",
		Date:          time.Now(),
		Duration:      30,
		Status:        "pending",
		IsAIGenerated: false,
		CreatedAt:     time.Now(),
		UpdatedAt:     time.Now(),
		Exercises: []models.TrainingExercise{
			{
				Name:         "俯卧撑",
				Description:  "经典的上肢力量训练动作",
				Category:     "胸肌",
				Difficulty:   "初级",
				MuscleGroups: []string{"胸肌", "三头肌", "肩部"},
				Equipment:    []string{"无器械"},
				Instructions: "保持身体挺直，核心收紧",
				Order:        1,
				Sets: []models.ExerciseSet{
					{Reps: 10, RestTime: 60, Order: 1},
					{Reps: 10, RestTime: 60, Order: 2},
					{Reps: 8, RestTime: 60, Order: 3},
				},
			},
			{
				Name:         "深蹲",
				Description:  "经典的下肢力量训练动作",
				Category:     "腿部",
				Difficulty:   "初级",
				MuscleGroups: []string{"股四头肌", "臀肌"},
				Equipment:    []string{"无器械"},
				Instructions: "保持背部挺直，膝盖不超过脚尖",
				Order:        2,
				Sets: []models.ExerciseSet{
					{Reps: 15, RestTime: 60, Order: 1},
					{Reps: 15, RestTime: 60, Order: 2},
					{Reps: 12, RestTime: 60, Order: 3},
				},
			},
		},
	}

	return s.convertToPlanResponse(plan), nil
}

// convertToPlanResponse 转换为计划响应
func (s *TrainingService) convertToPlanResponse(plan models.TrainingPlan) *models.TrainingPlanResponse {
	var exercises []models.TrainingExerciseResponse
	for _, exercise := range plan.Exercises {
		var sets []models.ExerciseSetResponse
		for _, set := range exercise.Sets {
			sets = append(sets, models.ExerciseSetResponse{
				ID:         set.ID,
				ExerciseID: set.ExerciseID,
				Reps:       set.Reps,
				Weight:     set.Weight,
				Duration:   set.Duration,
				Distance:   set.Distance,
				RestTime:   set.RestTime,
				Completed:  set.Completed,
				Order:      set.Order,
				CreatedAt:  set.CreatedAt,
				UpdatedAt:  set.UpdatedAt,
			})
		}

		exercises = append(exercises, models.TrainingExerciseResponse{
			ID:           exercise.ID,
			PlanID:       exercise.PlanID,
			Name:         exercise.Name,
			Description:  exercise.Description,
			Category:     exercise.Category,
			Difficulty:   exercise.Difficulty,
			MuscleGroups: exercise.MuscleGroups,
			Equipment:    exercise.Equipment,
			Sets:         sets,
			VideoURL:     exercise.VideoURL,
			ImageURL:     exercise.ImageURL,
			Instructions: exercise.Instructions,
			Order:        exercise.Order,
			CreatedAt:    exercise.CreatedAt,
			UpdatedAt:    exercise.UpdatedAt,
		})
	}

	return &models.TrainingPlanResponse{
		ID:            plan.ID,
		UserID:        plan.UserID,
		Name:          plan.Name,
		Description:   plan.Description,
		Date:          plan.Date,
		Exercises:     exercises,
		Duration:      plan.Duration,
		Calories:      plan.Calories,
		Status:        plan.Status,
		IsAIGenerated: plan.IsAIGenerated,
		AIReason:      plan.AIReason,
		CreatedAt:     plan.CreatedAt,
		UpdatedAt:     plan.UpdatedAt,
	}
}

// convertToRecordResponse 转换为记录响应
func (s *TrainingService) convertToRecordResponse(record models.WorkoutRecord) *models.WorkoutRecordResponse {
	return &models.WorkoutRecordResponse{
		ID:        record.ID,
		UserID:    record.UserID,
		PlanID:    record.PlanID,
		StartTime: record.StartTime,
		EndTime:   record.EndTime,
		Duration:  record.Duration,
		Calories:  record.Calories,
		Notes:     record.Notes,
		Status:    record.Status,
		CreatedAt: record.CreatedAt,
		UpdatedAt: record.UpdatedAt,
		User:      record.User,
		Plan:      record.Plan,
	}
}

// convertToFeedbackResponse 转换为反馈响应
func (s *TrainingService) convertToFeedbackResponse(feedback models.ExerciseFeedback) *models.ExerciseFeedbackResponse {
	return &models.ExerciseFeedbackResponse{
		ID:         feedback.ID,
		UserID:     feedback.UserID,
		ExerciseID: feedback.ExerciseID,
		RecordID:   feedback.RecordID,
		Rating:     feedback.Rating,
		Difficulty: feedback.Difficulty,
		PainLevel:  feedback.PainLevel,
		Comments:   feedback.Comments,
		CreatedAt:  feedback.CreatedAt,
		UpdatedAt:  feedback.UpdatedAt,
		User:       feedback.User,
		Exercise:   feedback.Exercise,
	}
}

// calculateCurrentStreak 计算当前连续训练天数
func (s *TrainingService) calculateCurrentStreak(userID string) int {
	// 简化实现，实际应该根据训练记录计算
	return 0
}

// calculateLongestStreak 计算最长连续训练天数
func (s *TrainingService) calculateLongestStreak(userID string) int {
	// 简化实现，实际应该根据训练记录计算
	return 0
}

// getFavoriteCategory 获取最喜欢的训练部位
func (s *TrainingService) getFavoriteCategory(userID string) string {
	// 简化实现，实际应该根据训练记录统计
	return "全身"
}

// getWeeklyStats 获取周统计
func (s *TrainingService) getWeeklyStats(userID string) []models.WeeklyStat {
	// 简化实现，实际应该根据训练记录计算
	return []models.WeeklyStat{}
}
