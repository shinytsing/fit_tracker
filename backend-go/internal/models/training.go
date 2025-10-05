package models

import "time"

// 训练相关的响应和请求模型（扩展）

// TrainingPlanResponse 训练计划响应
type TrainingPlanResponse struct {
	ID            string                     `json:"id"`
	UserID        string                     `json:"user_id"`
	Name          string                     `json:"name"`
	Description   string                     `json:"description"`
	Date          time.Time                  `json:"date"`
	Exercises     []TrainingExerciseResponse `json:"exercises"`
	Duration      int                        `json:"duration"`
	Calories      int                        `json:"calories"`
	Status        string                     `json:"status"`
	IsAIGenerated bool                       `json:"is_ai_generated"`
	AIReason      string                     `json:"ai_reason"`
	CreatedAt     time.Time                  `json:"created_at"`
	UpdatedAt     time.Time                  `json:"updated_at"`
	User          User                       `json:"user"`
}

// TrainingExerciseResponse 训练动作响应
type TrainingExerciseResponse struct {
	ID           string                `json:"id"`
	PlanID       string                `json:"plan_id"`
	Name         string                `json:"name"`
	Description  string                `json:"description"`
	Category     string                `json:"category"`
	Difficulty   string                `json:"difficulty"`
	MuscleGroups []string              `json:"muscle_groups"`
	Equipment    []string              `json:"equipment"`
	Sets         []ExerciseSetResponse `json:"sets"`
	VideoURL     string                `json:"video_url"`
	ImageURL     string                `json:"image_url"`
	Instructions string                `json:"instructions"`
	Order        int                   `json:"order"`
	CreatedAt    time.Time             `json:"created_at"`
	UpdatedAt    time.Time             `json:"updated_at"`
}

// ExerciseSetResponse 动作组数响应
type ExerciseSetResponse struct {
	ID         string    `json:"id"`
	ExerciseID string    `json:"exercise_id"`
	Reps       int       `json:"reps"`
	Weight     float64   `json:"weight"`
	Duration   int       `json:"duration"`
	Distance   float64   `json:"distance"`
	RestTime   int       `json:"rest_time"`
	Completed  bool      `json:"completed"`
	Order      int       `json:"order"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

// TrainingStats 训练统计
type TrainingStats struct {
	TotalWorkouts    int     `json:"total_workouts"`
	TotalDuration    int     `json:"total_duration"` // 分钟
	TotalCalories    int     `json:"total_calories"`
	AverageDuration  float64 `json:"average_duration"`
	AverageCalories  float64 `json:"average_calories"`
	StreakDays       int     `json:"streak_days"`
	LongestStreak    int     `json:"longest_streak"`
	FavoriteExercise string  `json:"favorite_exercise"`
	LastWorkoutDate  string  `json:"last_workout_date"`
	WeeklyWorkouts   int     `json:"weekly_workouts"`
	MonthlyWorkouts  int     `json:"monthly_workouts"`
}

// WorkoutHistory 训练历史
type WorkoutHistory struct {
	ID            string    `json:"id"`
	UserID        string    `json:"user_id"`
	PlanName      string    `json:"plan_name"`
	Duration      int       `json:"duration"`
	Calories      int       `json:"calories"`
	ExerciseCount int       `json:"exercise_count"`
	CompletedAt   time.Time `json:"completed_at"`
	Status        string    `json:"status"`
}

// AI训练计划生成请求（扩展）
type AITrainingPlanRequest struct {
	Goal        string   `json:"goal" binding:"required"`
	Duration    int      `json:"duration" binding:"required"`
	Difficulty  string   `json:"difficulty" binding:"required"`
	Equipment   []string `json:"equipment"`
	FocusAreas  []string `json:"focus_areas"`
	UserLevel   string   `json:"user_level"`
	Injuries    []string `json:"injuries"`
	Preferences []string `json:"preferences"`
}

// AI训练计划生成响应
type AITrainingPlanResponse struct {
	Plan        TrainingPlan `json:"plan"`
	Explanation string       `json:"explanation"`
	Tips        []string     `json:"tips"`
	Warnings    []string     `json:"warnings"`
}

// 训练计划搜索请求
type SearchTrainingPlansRequest struct {
	Query    string `json:"query"`
	Category string `json:"category"`
	Level    string `json:"level"`
	Limit    int    `json:"limit"`
	Offset   int    `json:"offset"`
}

// 训练计划搜索响应
type SearchTrainingPlansResponse struct {
	Plans  []TrainingPlan `json:"plans"`
	Total  int            `json:"total"`
	Limit  int            `json:"limit"`
	Offset int            `json:"offset"`
}

// 训练计划分享请求
type ShareTrainingPlanRequest struct {
	PlanID    string `json:"plan_id" binding:"required"`
	IsPublic  bool   `json:"is_public"`
	AllowCopy bool   `json:"allow_copy"`
	Message   string `json:"message"`
}

// 训练计划分享响应
type ShareTrainingPlanResponse struct {
	ShareID   string `json:"share_id"`
	ShareURL  string `json:"share_url"`
	ExpiresAt string `json:"expires_at"`
	IsPublic  bool   `json:"is_public"`
	AllowCopy bool   `json:"allow_copy"`
}

// 训练计划复制请求
type CopyTrainingPlanRequest struct {
	ShareID string `json:"share_id" binding:"required"`
	NewName string `json:"new_name"`
}

// 训练计划复制响应
type CopyTrainingPlanResponse struct {
	PlanID   string `json:"plan_id"`
	PlanName string `json:"plan_name"`
	Message  string `json:"message"`
}

// 训练计划评价请求
type RateTrainingPlanRequest struct {
	PlanID string `json:"plan_id" binding:"required"`
	Rating int    `json:"rating" binding:"required,min=1,max=5"`
	Review string `json:"review"`
}

// 训练计划评价响应
type RateTrainingPlanResponse struct {
	RatingID string `json:"rating_id"`
	Message  string `json:"message"`
}

// 训练计划评价
type TrainingPlanRating struct {
	ID        string    `json:"id" gorm:"primaryKey"`
	PlanID    string    `json:"plan_id" gorm:"not null"`
	UserID    string    `json:"user_id" gorm:"not null"`
	Rating    int       `json:"rating" gorm:"not null"`
	Review    string    `json:"review"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	// 关联数据
	Plan TrainingPlan `json:"plan" gorm:"foreignKey:PlanID"`
	User User         `json:"user" gorm:"foreignKey:UserID"`
}

// 训练计划收藏
type TrainingPlanFavorite struct {
	ID        string    `json:"id" gorm:"primaryKey"`
	PlanID    string    `json:"plan_id" gorm:"not null"`
	UserID    string    `json:"user_id" gorm:"not null"`
	CreatedAt time.Time `json:"created_at"`

	// 关联数据
	Plan TrainingPlan `json:"plan" gorm:"foreignKey:PlanID"`
	User User         `json:"user" gorm:"foreignKey:UserID"`
}

// 训练计划收藏请求
type FavoriteTrainingPlanRequest struct {
	PlanID string `json:"plan_id" binding:"required"`
}

// 训练计划收藏响应
type FavoriteTrainingPlanResponse struct {
	Message string `json:"message"`
}

// 训练计划标签
type TrainingPlanTag struct {
	ID        string    `json:"id" gorm:"primaryKey"`
	Name      string    `json:"name" gorm:"uniqueIndex;not null"`
	Color     string    `json:"color"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// 训练计划标签关联
type TrainingPlanTagRelation struct {
	ID        string    `json:"id" gorm:"primaryKey"`
	PlanID    string    `json:"plan_id" gorm:"not null"`
	TagID     string    `json:"tag_id" gorm:"not null"`
	CreatedAt time.Time `json:"created_at"`

	// 关联数据
	Plan TrainingPlan    `json:"plan" gorm:"foreignKey:PlanID"`
	Tag  TrainingPlanTag `json:"tag" gorm:"foreignKey:TagID"`
}

// 训练计划标签请求
type AddTrainingPlanTagRequest struct {
	PlanID string `json:"plan_id" binding:"required"`
	TagID  string `json:"tag_id" binding:"required"`
}

// 训练计划标签响应
type AddTrainingPlanTagResponse struct {
	Message string `json:"message"`
}

// 训练计划模板
type TrainingPlanTemplate struct {
	ID          string             `json:"id" gorm:"primaryKey"`
	Name        string             `json:"name" gorm:"not null"`
	Description string             `json:"description"`
	Category    string             `json:"category"`
	Difficulty  string             `json:"difficulty"`
	Duration    int                `json:"duration"`
	Calories    int                `json:"calories"`
	Exercises   []TrainingExercise `json:"exercises" gorm:"foreignKey:TemplateID"`
	IsPublic    bool               `json:"is_public"`
	CreatorID   string             `json:"creator_id"`
	UseCount    int                `json:"use_count"`
	Rating      float64            `json:"rating"`
	CreatedAt   time.Time          `json:"created_at"`
	UpdatedAt   time.Time          `json:"updated_at"`

	// 关联数据
	Creator User `json:"creator" gorm:"foreignKey:CreatorID"`
}

// 训练计划模板请求
type CreateTrainingPlanTemplateRequest struct {
	Name        string                  `json:"name" binding:"required"`
	Description string                  `json:"description"`
	Category    string                  `json:"category"`
	Difficulty  string                  `json:"difficulty"`
	Exercises   []CreateExerciseRequest `json:"exercises" binding:"required"`
	IsPublic    bool                    `json:"is_public"`
}

// 训练计划模板响应
type CreateTrainingPlanTemplateResponse struct {
	TemplateID string `json:"template_id"`
	Message    string `json:"message"`
}

// 从模板创建训练计划请求
type CreatePlanFromTemplateRequest struct {
	TemplateID string `json:"template_id" binding:"required"`
	Date       string `json:"date" binding:"required"`
	Name       string `json:"name"`
}

// 从模板创建训练计划响应
type CreatePlanFromTemplateResponse struct {
	PlanID  string `json:"plan_id"`
	Message string `json:"message"`
}
