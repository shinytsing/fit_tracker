package models

import (
	"time"

	"gorm.io/gorm"
)

// User 用户模型
type User struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	Username     string `json:"username" gorm:"uniqueIndex;not null"`
	Email        string `json:"email" gorm:"uniqueIndex;not null"`
	PasswordHash string `json:"-" gorm:"not null"`
	FirstName    string `json:"first_name"`
	LastName     string `json:"last_name"`
	Avatar       string `json:"avatar"`
	Bio          string `json:"bio"`

	// 用户统计
	TotalWorkouts int `json:"total_workouts" gorm:"default:0"`
	TotalCheckins int `json:"total_checkins" gorm:"default:0"`
	CurrentStreak int `json:"current_streak" gorm:"default:0"`
	LongestStreak int `json:"longest_streak" gorm:"default:0"`

	// 关联关系
	Workouts      []Workout      `json:"workouts" gorm:"foreignKey:UserID"`
	Checkins      []Checkin      `json:"checkins" gorm:"foreignKey:UserID"`
	HealthRecords []HealthRecord `json:"health_records" gorm:"foreignKey:UserID"`
	Posts         []Post         `json:"posts" gorm:"foreignKey:UserID"`
	Followers     []Follow       `json:"followers" gorm:"foreignKey:FollowingID"`
	Following     []Follow       `json:"following" gorm:"foreignKey:FollowerID"`
}

// Workout 训练记录模型
type Workout struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	UserID     uint    `json:"user_id" gorm:"not null"`
	PlanID     *uint   `json:"plan_id"`
	Name       string  `json:"name" gorm:"not null"`
	Type       string  `json:"type" gorm:"not null"` // 训练类型
	Duration   int     `json:"duration"`             // 时长(分钟)
	Calories   int     `json:"calories"`             // 消耗卡路里
	Difficulty string  `json:"difficulty"`           // 难度等级
	Notes      string  `json:"notes"`                // 备注
	Rating     float64 `json:"rating"`               // 评分

	// 关联关系
	User      User          `json:"user" gorm:"foreignKey:UserID"`
	Plan      *TrainingPlan `json:"plan" gorm:"foreignKey:PlanID"`
	Exercises []Exercise    `json:"exercises" gorm:"many2many:workout_exercises;"`
}

// TrainingPlan 训练计划模型
type TrainingPlan struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	Name        string `json:"name" gorm:"not null"`
	Description string `json:"description"`
	Type        string `json:"type" gorm:"not null"`       // 计划类型
	Difficulty  string `json:"difficulty" gorm:"not null"` // 难度等级
	Duration    int    `json:"duration"`                   // 计划周期(周)
	IsPublic    bool   `json:"is_public" gorm:"default:false"`
	IsAI        bool   `json:"is_ai" gorm:"default:false"` // 是否AI生成

	// 关联关系
	Workouts []Workout `json:"workouts" gorm:"foreignKey:PlanID"`
}

// Exercise 运动动作模型
type Exercise struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	Name         string `json:"name" gorm:"not null"`
	Description  string `json:"description"`
	Category     string `json:"category"`      // 动作分类
	MuscleGroups string `json:"muscle_groups"` // 目标肌群
	Equipment    string `json:"equipment"`     // 所需器械
	Difficulty   string `json:"difficulty"`    // 难度等级
	Instructions string `json:"instructions"`  // 动作说明
	VideoURL     string `json:"video_url"`     // 视频链接
	ImageURL     string `json:"image_url"`     // 图片链接

	// 关联关系
	Workouts []Workout `json:"workouts" gorm:"many2many:workout_exercises;"`
}

// Checkin 签到记录模型
type Checkin struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	UserID     uint      `json:"user_id" gorm:"not null"`
	Date       time.Time `json:"date" gorm:"not null"`
	Type       string    `json:"type" gorm:"not null"` // 签到类型
	Notes      string    `json:"notes"`
	Mood       string    `json:"mood"`       // 心情
	Energy     int       `json:"energy"`     // 精力等级 1-10
	Motivation int       `json:"motivation"` // 动力等级 1-10

	// 关联关系
	User User `json:"user" gorm:"foreignKey:UserID"`
}

// HealthRecord 健康记录模型
type HealthRecord struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	UserID uint      `json:"user_id" gorm:"not null"`
	Date   time.Time `json:"date" gorm:"not null"`
	Type   string    `json:"type" gorm:"not null"` // 记录类型: bmi, weight, height, etc.
	Value  float64   `json:"value" gorm:"not null"`
	Unit   string    `json:"unit"` // 单位
	Notes  string    `json:"notes"`

	// 关联关系
	User User `json:"user" gorm:"foreignKey:UserID"`
}

// Post 社区动态模型
type Post struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	UserID   uint   `json:"user_id" gorm:"not null"`
	Content  string `json:"content" gorm:"not null"`
	Images   string `json:"images"` // JSON数组存储图片URL
	Type     string `json:"type"`   // 动态类型
	IsPublic bool   `json:"is_public" gorm:"default:true"`

	// 统计信息
	LikesCount    int `json:"likes_count" gorm:"default:0"`
	CommentsCount int `json:"comments_count" gorm:"default:0"`
	SharesCount   int `json:"shares_count" gorm:"default:0"`

	// 关联关系
	User     User      `json:"user" gorm:"foreignKey:UserID"`
	Likes    []Like    `json:"likes" gorm:"foreignKey:PostID"`
	Comments []Comment `json:"comments" gorm:"foreignKey:PostID"`
}

// Like 点赞模型
type Like struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	UserID uint `json:"user_id" gorm:"not null"`
	PostID uint `json:"post_id" gorm:"not null"`

	// 关联关系
	User User `json:"user" gorm:"foreignKey:UserID"`
	Post Post `json:"post" gorm:"foreignKey:PostID"`
}

// Comment 评论模型
type Comment struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	UserID  uint   `json:"user_id" gorm:"not null"`
	PostID  uint   `json:"post_id" gorm:"not null"`
	Content string `json:"content" gorm:"not null"`

	// 关联关系
	User User `json:"user" gorm:"foreignKey:UserID"`
	Post Post `json:"post" gorm:"foreignKey:PostID"`
}

// Follow 关注关系模型
type Follow struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	FollowerID  uint `json:"follower_id" gorm:"not null"`
	FollowingID uint `json:"following_id" gorm:"not null"`

	// 关联关系
	Follower  User `json:"follower" gorm:"foreignKey:FollowerID"`
	Following User `json:"following" gorm:"foreignKey:FollowingID"`
}

// Challenge 挑战模型
type Challenge struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	Name        string    `json:"name" gorm:"not null"`
	Description string    `json:"description"`
	Type        string    `json:"type" gorm:"not null"`       // 挑战类型
	Difficulty  string    `json:"difficulty" gorm:"not null"` // 难度等级
	StartDate   time.Time `json:"start_date" gorm:"not null"`
	EndDate     time.Time `json:"end_date" gorm:"not null"`
	IsActive    bool      `json:"is_active" gorm:"default:true"`

	// 统计信息
	ParticipantsCount int `json:"participants_count" gorm:"default:0"`

	// 关联关系
	Participants []ChallengeParticipant `json:"participants" gorm:"foreignKey:ChallengeID"`
}

// ChallengeParticipant 挑战参与者模型
type ChallengeParticipant struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	UserID      uint `json:"user_id" gorm:"not null"`
	ChallengeID uint `json:"challenge_id" gorm:"not null"`
	Progress    int  `json:"progress" gorm:"default:0"` // 进度百分比

	// 关联关系
	User      User      `json:"user" gorm:"foreignKey:UserID"`
	Challenge Challenge `json:"challenge" gorm:"foreignKey:ChallengeID"`
}

// NutritionRecord 营养记录模型
type NutritionRecord struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	UserID   uint      `json:"user_id" gorm:"not null"`
	Date     time.Time `json:"date" gorm:"not null"`
	MealType string    `json:"meal_type" gorm:"not null"` // breakfast, lunch, dinner, snack
	FoodName string    `json:"food_name" gorm:"not null"`
	Quantity float64   `json:"quantity" gorm:"not null"`
	Unit     string    `json:"unit"` // g, ml, cup, etc.
	Calories float64   `json:"calories"`
	Protein  float64   `json:"protein"`
	Carbs    float64   `json:"carbs"`
	Fat      float64   `json:"fat"`
	Fiber    float64   `json:"fiber"`
	Sugar    float64   `json:"sugar"`
	Sodium   float64   `json:"sodium"`
	Notes    string    `json:"notes"`

	// 关联关系
	User User `json:"user" gorm:"foreignKey:UserID"`
}
