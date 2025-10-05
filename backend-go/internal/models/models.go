package models

import (
	"time"
)

// 用户相关模型
type User struct {
	ID             string    `json:"id" gorm:"primaryKey"`
	Username       string    `json:"username" gorm:"uniqueIndex;not null"`
	Email          string    `json:"email" gorm:"uniqueIndex;not null"`
	Password       string    `json:"-" gorm:"not null"`
	Nickname       string    `json:"nickname"`
	Avatar         string    `json:"avatar"`
	Bio            string    `json:"bio"`
	Gender         string    `json:"gender"`
	Birthday       time.Time `json:"birthday"`
	Height         float64   `json:"height"` // cm
	Weight         float64   `json:"weight"` // kg
	BMI            float64   `json:"bmi"`
	Level          int       `json:"level"`  // 用户等级
	Points         int       `json:"points"` // 积分
	FollowerCount  int       `json:"follower_count"`
	FollowingCount int       `json:"following_count"`
	PostCount      int       `json:"post_count"`
	IsVerified     bool      `json:"is_verified"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}

type RegisterRequest struct {
	Username string `json:"username" binding:"required,min=3,max=20"`
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=6"`
	Nickname string `json:"nickname" binding:"required"`
}

type LoginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

type UpdateProfileRequest struct {
	Nickname string  `json:"nickname"`
	Bio      string  `json:"bio"`
	Gender   string  `json:"gender"`
	Birthday string  `json:"birthday"`
	Height   float64 `json:"height"`
	Weight   float64 `json:"weight"`
}

// 训练相关模型
type TrainingPlan struct {
	ID            string             `json:"id" gorm:"primaryKey"`
	UserID        string             `json:"user_id" gorm:"not null"`
	Name          string             `json:"name" gorm:"not null"`
	Description   string             `json:"description"`
	Date          time.Time          `json:"date" gorm:"not null"`
	Exercises     []TrainingExercise `json:"exercises" gorm:"foreignKey:PlanID"`
	Duration      int                `json:"duration"` // 分钟
	Calories      int                `json:"calories"`
	Status        string             `json:"status"` // pending, in_progress, completed, skipped
	IsAIGenerated bool               `json:"is_ai_generated"`
	AIReason      string             `json:"ai_reason"`
	CreatedAt     time.Time          `json:"created_at"`
	UpdatedAt     time.Time          `json:"updated_at"`
}

func (TrainingPlan) TableName() string {
	return "training_plans"
}

type TrainingExercise struct {
	ID           string        `json:"id" gorm:"primaryKey"`
	PlanID       string        `json:"plan_id" gorm:"not null"`
	Name         string        `json:"name" gorm:"not null"`
	Description  string        `json:"description"`
	Category     string        `json:"category"`   // 胸、背、腿、肩、臂等
	Difficulty   string        `json:"difficulty"` // 初级、中级、高级
	MuscleGroups []string      `json:"muscle_groups" gorm:"serializer:json"`
	Equipment    []string      `json:"equipment" gorm:"serializer:json"`
	Sets         []ExerciseSet `json:"sets" gorm:"foreignKey:ExerciseID"`
	VideoURL     string        `json:"video_url"`
	ImageURL     string        `json:"image_url"`
	Instructions string        `json:"instructions"`
	Order        int           `json:"order"`
	CreatedAt    time.Time     `json:"created_at"`
	UpdatedAt    time.Time     `json:"updated_at"`
}

type ExerciseSet struct {
	ID         string    `json:"id" gorm:"primaryKey"`
	ExerciseID string    `json:"exercise_id" gorm:"not null"`
	Reps       int       `json:"reps"`
	Weight     float64   `json:"weight"`    // kg
	Duration   int       `json:"duration"`  // 秒，用于有氧运动
	Distance   float64   `json:"distance"`  // 公里，用于跑步等
	RestTime   int       `json:"rest_time"` // 秒
	Completed  bool      `json:"completed"`
	Order      int       `json:"order"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

type CreatePlanRequest struct {
	Name        string                  `json:"name" binding:"required"`
	Description string                  `json:"description"`
	Date        string                  `json:"date" binding:"required"`
	Exercises   []CreateExerciseRequest `json:"exercises" binding:"required"`
}

type CreateExerciseRequest struct {
	Name         string             `json:"name" binding:"required"`
	Description  string             `json:"description"`
	Category     string             `json:"category"`
	Difficulty   string             `json:"difficulty"`
	MuscleGroups []string           `json:"muscle_groups"`
	Equipment    []string           `json:"equipment"`
	Sets         []CreateSetRequest `json:"sets" binding:"required"`
	VideoURL     string             `json:"video_url"`
	ImageURL     string             `json:"image_url"`
	Instructions string             `json:"instructions"`
	Order        int                `json:"order"`
}

type CreateSetRequest struct {
	Reps     int     `json:"reps" binding:"required"`
	Weight   float64 `json:"weight"`
	Duration int     `json:"duration"`
	Distance float64 `json:"distance"`
	RestTime int     `json:"rest_time"`
	Order    int     `json:"order"`
}

type UpdatePlanRequest struct {
	Name        string                  `json:"name"`
	Description string                  `json:"description"`
	Exercises   []CreateExerciseRequest `json:"exercises"`
}

type GenerateAIPlanRequest struct {
	Goal       string   `json:"goal"`        // 减脂、增肌、塑形等
	Duration   int      `json:"duration"`    // 训练时长（分钟）
	Difficulty string   `json:"difficulty"`  // 初级、中级、高级
	Equipment  []string `json:"equipment"`   // 可用器械
	FocusAreas []string `json:"focus_areas"` // 重点训练部位
}

type CompleteExerciseRequest struct {
	ExerciseID string               `json:"exercise_id" binding:"required"`
	Sets       []CompleteSetRequest `json:"sets" binding:"required"`
}

type CompleteSetRequest struct {
	SetID     string  `json:"set_id" binding:"required"`
	Reps      int     `json:"reps"`
	Weight    float64 `json:"weight"`
	Duration  int     `json:"duration"`
	Distance  float64 `json:"distance"`
	Completed bool    `json:"completed"`
}

type CompleteWorkoutRequest struct {
	PlanID   string `json:"plan_id" binding:"required"`
	Duration int    `json:"duration"`
	Calories int    `json:"calories"`
	Notes    string `json:"notes"`
}

// WorkoutData 训练数据模型
type WorkoutData struct {
	ExerciseName string   `json:"exercise_name"`
	Duration     int      `json:"duration"`
	Calories     int      `json:"calories"`
	Exercises    []string `json:"exercises"`
}

// AI相关模型
type GenerateTrainingPlanRequest struct {
	Goal       string   `json:"goal" binding:"required"`
	Duration   int      `json:"duration" binding:"required"`
	Difficulty string   `json:"difficulty" binding:"required"`
	Equipment  []string `json:"equipment"`
	FocusAreas []string `json:"focus_areas"`
}

type GenerateNutritionPlanRequest struct {
	Goal        string   `json:"goal" binding:"required"`
	DietType    string   `json:"diet_type"`
	Allergies   []string `json:"allergies"`
	Preferences []string `json:"preferences"`
	MealsPerDay int      `json:"meals_per_day"`
}

type AIChatRequest struct {
	Message string `json:"message" binding:"required"`
	Context string `json:"context"`
}

// 签到相关模型
type CheckIn struct {
	ID         string    `json:"id" gorm:"primaryKey"`
	UserID     string    `json:"user_id" gorm:"not null"`
	Date       time.Time `json:"date" gorm:"not null"`
	Type       string    `json:"type"` // 训练、饮食、休息等
	Notes      string    `json:"notes"`
	Mood       string    `json:"mood"`       // 心情状态
	Energy     int       `json:"energy"`     // 能量等级 1-10
	Motivation int       `json:"motivation"` // 动力等级 1-10
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`

	// 关联数据
	User User `json:"user" gorm:"foreignKey:UserID"`
}

type CreateCheckInRequest struct {
	Type       string `json:"type" binding:"required"`
	Notes      string `json:"notes"`
	Mood       string `json:"mood"`
	Energy     int    `json:"energy"`
	Motivation int    `json:"motivation"`
}

// 成就相关模型
type Achievement struct {
	ID          string    `json:"id" gorm:"primaryKey"`
	Name        string    `json:"name" gorm:"not null"`
	Description string    `json:"description"`
	Icon        string    `json:"icon"`
	Points      int       `json:"points"`
	Category    string    `json:"category"`  // 训练、社交、坚持等
	Condition   string    `json:"condition"` // 达成条件
	IsActive    bool      `json:"is_active"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

type UserAchievement struct {
	ID            string    `json:"id" gorm:"primaryKey"`
	UserID        string    `json:"user_id" gorm:"not null"`
	AchievementID string    `json:"achievement_id" gorm:"not null"`
	EarnedAt      time.Time `json:"earned_at"`
	CreatedAt     time.Time `json:"created_at"`

	// 关联数据
	User        User        `json:"user" gorm:"foreignKey:UserID"`
	Achievement Achievement `json:"achievement" gorm:"foreignKey:AchievementID"`
}

// 训练记录相关模型
type WorkoutRecord struct {
	ID        string    `json:"id" gorm:"primaryKey"`
	UserID    string    `json:"user_id" gorm:"not null"`
	PlanID    string    `json:"plan_id"`
	StartTime time.Time `json:"start_time"`
	EndTime   time.Time `json:"end_time"`
	Duration  int       `json:"duration"` // 分钟
	Calories  int       `json:"calories"`
	Notes     string    `json:"notes"`
	Status    string    `json:"status"` // in_progress, completed, paused
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	// 关联数据
	User User         `json:"user" gorm:"foreignKey:UserID"`
	Plan TrainingPlan `json:"plan" gorm:"foreignKey:PlanID"`
}

type StartWorkoutRequest struct {
	PlanID string `json:"plan_id"`
	Notes  string `json:"notes"`
}

type EndWorkoutRequest struct {
	RecordID string `json:"record_id" binding:"required"`
	Notes    string `json:"notes"`
	Calories int    `json:"calories"`
}

type WorkoutRecordResponse struct {
	ID        string       `json:"id"`
	UserID    string       `json:"user_id"`
	PlanID    string       `json:"plan_id"`
	StartTime time.Time    `json:"start_time"`
	EndTime   time.Time    `json:"end_time"`
	Duration  int          `json:"duration"`
	Calories  int          `json:"calories"`
	Notes     string       `json:"notes"`
	Status    string       `json:"status"`
	CreatedAt time.Time    `json:"created_at"`
	UpdatedAt time.Time    `json:"updated_at"`
	User      User         `json:"user"`
	Plan      TrainingPlan `json:"plan"`
}

// 统计相关模型
type WeeklyStat struct {
	Week     string `json:"week"`
	Workouts int    `json:"workouts"`
	Duration int    `json:"duration"`
	Calories int    `json:"calories"`
}

// 统计相关模型
type UserStats struct {
	ID                 string    `json:"id" gorm:"primaryKey"`
	UserID             string    `json:"user_id" gorm:"not null"`
	TotalWorkouts      int       `json:"total_workouts"`
	TotalDuration      int       `json:"total_duration"` // 分钟
	TotalCalories      int       `json:"total_calories"`
	CurrentStreak      int       `json:"current_streak"`
	LongestStreak      int       `json:"longest_streak"`
	FavoriteExercise   string    `json:"favorite_exercise"`
	WorkoutDays        int       `json:"workout_days"`
	RestDays           int       `json:"rest_days"`
	AverageWorkoutTime int       `json:"average_workout_time"`
	LastWorkoutAt      time.Time `json:"last_workout_at"`
	CreatedAt          time.Time `json:"created_at"`
	UpdatedAt          time.Time `json:"updated_at"`

	// 关联数据
	User User `json:"user" gorm:"foreignKey:UserID"`
}

// 用户响应模型
type UserResponse struct {
	ID             string    `json:"id"`
	Username       string    `json:"username"`
	Email          string    `json:"email"`
	Nickname       string    `json:"nickname"`
	Avatar         string    `json:"avatar"`
	Bio            string    `json:"bio"`
	Gender         string    `json:"gender"`
	Birthday       time.Time `json:"birthday"`
	Height         float64   `json:"height"`
	Weight         float64   `json:"weight"`
	BMI            float64   `json:"bmi"`
	Level          int       `json:"level"`
	Points         int       `json:"points"`
	FollowerCount  int       `json:"follower_count"`
	FollowingCount int       `json:"following_count"`
	PostCount      int       `json:"post_count"`
	IsVerified     bool      `json:"is_verified"`
	IsActive       bool      `json:"is_active"`
	LastLoginAt    time.Time `json:"last_login_at"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}

// 训练反馈相关模型
type ExerciseFeedback struct {
	ID         string    `json:"id" gorm:"primaryKey"`
	UserID     string    `json:"user_id" gorm:"not null"`
	ExerciseID string    `json:"exercise_id" gorm:"not null"`
	RecordID   string    `json:"record_id"`
	Rating     int       `json:"rating"`     // 1-5
	Difficulty string    `json:"difficulty"` // too_easy, easy, medium, hard, too_hard
	PainLevel  int       `json:"pain_level"` // 1-10
	Comments   string    `json:"comments"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`

	// 关联数据
	User     User             `json:"user" gorm:"foreignKey:UserID"`
	Exercise TrainingExercise `json:"exercise" gorm:"foreignKey:ExerciseID"`
	Record   WorkoutRecord    `json:"record" gorm:"foreignKey:RecordID"`
}

type SubmitFeedbackRequest struct {
	ExerciseID string `json:"exercise_id" binding:"required"`
	RecordID   string `json:"record_id"`
	Rating     int    `json:"rating" binding:"required,min=1,max=5"`
	Difficulty string `json:"difficulty" binding:"required"`
	PainLevel  int    `json:"pain_level" binding:"min=1,max=10"`
	Comments   string `json:"comments"`
}

type ExerciseFeedbackResponse struct {
	ID         string           `json:"id"`
	UserID     string           `json:"user_id"`
	ExerciseID string           `json:"exercise_id"`
	RecordID   string           `json:"record_id"`
	Rating     int              `json:"rating"`
	Difficulty string           `json:"difficulty"`
	PainLevel  int              `json:"pain_level"`
	Comments   string           `json:"comments"`
	CreatedAt  time.Time        `json:"created_at"`
	UpdatedAt  time.Time        `json:"updated_at"`
	User       User             `json:"user"`
	Exercise   TrainingExercise `json:"exercise"`
}

// 训练统计响应
type TrainingStatsResponse struct {
	TotalWorkouts    int     `json:"total_workouts"`
	TotalDuration    int     `json:"total_duration"`
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

// 用户设置相关模型
type UpdateSettingsRequest struct {
	PrivacyLevel      string `json:"privacy_level"`
	NotificationEmail bool   `json:"notification_email"`
	NotificationPush  bool   `json:"notification_push"`
	NotificationSMS   bool   `json:"notification_sms"`
	Language          string `json:"language"`
	Timezone          string `json:"timezone"`
	Theme             string `json:"theme"`
}

type UserStatsResponse struct {
	ID                 string `json:"id"`
	UserID             string `json:"user_id"`
	TotalWorkouts      int    `json:"total_workouts"`
	TotalDuration      int    `json:"total_duration"`
	TotalCalories      int    `json:"total_calories"`
	CurrentStreak      int    `json:"current_streak"`
	LongestStreak      int    `json:"longest_streak"`
	FavoriteExercise   string `json:"favorite_exercise"`
	WorkoutDays        int    `json:"workout_days"`
	RestDays           int    `json:"rest_days"`
	AverageWorkoutTime int    `json:"average_workout_time"`
	LastWorkoutAt      string `json:"last_workout_at"`
	CreatedAt          string `json:"created_at"`
	UpdatedAt          string `json:"updated_at"`
	Period             string `json:"period"`
}

type UserAchievementResponse struct {
	ID            string    `json:"id"`
	UserID        string    `json:"user_id"`
	AchievementID string    `json:"achievement_id"`
	Title         string    `json:"title"`
	Description   string    `json:"description"`
	IconURL       string    `json:"icon_url"`
	Points        int       `json:"points"`
	UnlockedAt    time.Time `json:"unlocked_at"`
	CreatedAt     time.Time `json:"created_at"`
}

type SearchUsersRequest struct {
	Query  string `json:"query"`
	Limit  int    `json:"limit"`
	Offset int    `json:"offset"`
}

type FollowUserRequest struct {
	UserID string `json:"user_id" binding:"required"`
}

type UserSettingsResponse struct {
	ID                string `json:"id"`
	UserID            string `json:"user_id"`
	PrivacyLevel      string `json:"privacy_level"`
	NotificationEmail bool   `json:"notification_email"`
	NotificationPush  bool   `json:"notification_push"`
	NotificationSMS   bool   `json:"notification_sms"`
	Language          string `json:"language"`
	Timezone          string `json:"timezone"`
	Theme             string `json:"theme"`
	CreatedAt         string `json:"created_at"`
	UpdatedAt         string `json:"updated_at"`
}

// 训练会话相关模型
type WorkoutSession struct {
	ID        string    `json:"id" gorm:"primaryKey"`
	UserID    string    `json:"user_id" gorm:"not null"`
	PlanID    string    `json:"plan_id"`
	StartTime time.Time `json:"start_time"`
	EndTime   time.Time `json:"end_time"`
	Duration  int       `json:"duration"` // 分钟
	Calories  int       `json:"calories"`
	Notes     string    `json:"notes"`
	Status    string    `json:"status"` // in_progress, completed, paused
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	// 关联数据
	User User         `json:"user" gorm:"foreignKey:UserID"`
	Plan TrainingPlan `json:"plan" gorm:"foreignKey:PlanID"`
}
