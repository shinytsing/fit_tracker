package models

import (
	"time"

	"gorm.io/gorm"
)

// User 用户模型
type User struct {
	ID        string         `json:"id" gorm:"primaryKey"`
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

	// 社区相关字段
	FitnessTags    string `json:"fitness_tags"`    // JSON数组存储健身偏好标签
	FitnessGoal    string `json:"fitness_goal"`    // 健身目标
	Location       string `json:"location"`        // 位置信息
	IsVerified     bool   `json:"is_verified"`     // 是否认证用户
	FollowersCount int    `json:"followers_count"` // 粉丝数
	FollowingCount int    `json:"following_count"` // 关注数

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
	UserTags      []UserTag      `json:"user_tags" gorm:"foreignKey:UserID"`
	Notifications []Notification `json:"notifications" gorm:"foreignKey:UserID"`
}

// Workout 训练记录模型
type Workout struct {
	ID        string         `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	UserID     string  `json:"user_id" gorm:"not null"`
	PlanID     *string `json:"plan_id"`
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
	ID        string         `json:"id" gorm:"primaryKey"`
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
	ID        string         `json:"id" gorm:"primaryKey"`
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
	ID        string         `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	UserID     string    `json:"user_id" gorm:"not null"`
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
	ID        string         `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	UserID string    `json:"user_id" gorm:"not null"`
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
	ID        string         `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	UserID   string `json:"user_id" gorm:"not null"`
	Content  string `json:"content" gorm:"not null"`
	Images   string `json:"images"`    // JSON数组存储图片URL
	VideoURL string `json:"video_url"` // 视频链接
	Type     string `json:"type"`      // 动态类型
	IsPublic bool   `json:"is_public" gorm:"default:true"`

	// 社区扩展字段
	Tags        string `json:"tags"`         // JSON数组存储话题标签
	Location    string `json:"location"`     // 发布位置
	WorkoutData string `json:"workout_data"` // JSON存储关联的训练数据
	IsFeatured  bool   `json:"is_featured"`  // 是否精选
	ViewCount   int    `json:"view_count"`   // 浏览次数
	ShareCount  int    `json:"share_count"`  // 分享次数

	// 统计信息
	LikesCount    int `json:"likes_count" gorm:"default:0"`
	CommentsCount int `json:"comments_count" gorm:"default:0"`
	SharesCount   int `json:"shares_count" gorm:"default:0"`

	// 关联关系
	User      User       `json:"user" gorm:"foreignKey:UserID"`
	Likes     []Like     `json:"likes" gorm:"foreignKey:PostID"`
	Comments  []Comment  `json:"comments" gorm:"foreignKey:PostID"`
	Topics    []Topic    `json:"topics" gorm:"many2many:post_topics;"`
	Favorites []Favorite `json:"favorites" gorm:"foreignKey:PostID"`
	Shares    []Share    `json:"shares" gorm:"foreignKey:PostID"`
	Views     []PostView `json:"views" gorm:"foreignKey:PostID"`
}

// Like 点赞模型
type Like struct {
	ID        string         `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	UserID string `json:"user_id" gorm:"not null"`
	PostID string `json:"post_id" gorm:"not null"`

	// 关联关系
	User User `json:"user" gorm:"foreignKey:UserID"`
	Post Post `json:"post" gorm:"foreignKey:PostID"`
}

// Comment 评论模型
type Comment struct {
	ID        string         `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	UserID  string `json:"user_id" gorm:"not null"`
	PostID  string `json:"post_id" gorm:"not null"`
	Content string `json:"content" gorm:"not null"`

	// 多级回复支持
	ParentID      *string `json:"parent_id"`        // 父评论ID
	ReplyToUserID *string `json:"reply_to_user_id"` // 回复的用户ID
	LikesCount    int     `json:"likes_count"`      // 点赞数
	RepliesCount  int     `json:"replies_count"`    // 回复数

	// 关联关系
	User        User      `json:"user" gorm:"foreignKey:UserID"`
	Post        Post      `json:"post" gorm:"foreignKey:PostID"`
	Parent      *Comment  `json:"parent" gorm:"foreignKey:ParentID"`
	Replies     []Comment `json:"replies" gorm:"foreignKey:ParentID"`
	ReplyToUser *User     `json:"reply_to_user" gorm:"foreignKey:ReplyToUserID"`
}

// Follow 关注关系模型
type Follow struct {
	ID        string         `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	FollowerID  string `json:"follower_id" gorm:"not null"`
	FollowingID string `json:"following_id" gorm:"not null"`

	// 关联关系
	Follower  User `json:"follower" gorm:"foreignKey:FollowerID"`
	Following User `json:"following" gorm:"foreignKey:FollowingID"`
}

// Challenge 挑战模型
type Challenge struct {
	ID        string         `json:"id" gorm:"primaryKey"`
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
	ID        string         `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	UserID      string `json:"user_id" gorm:"not null"`
	ChallengeID string `json:"challenge_id" gorm:"not null"`
	Progress    int    `json:"progress" gorm:"default:0"` // 进度百分比

	// 关联关系
	User      User      `json:"user" gorm:"foreignKey:UserID"`
	Challenge Challenge `json:"challenge" gorm:"foreignKey:ChallengeID"`
}

// NutritionRecord 营养记录模型
type NutritionRecord struct {
	ID        string         `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	UserID   string    `json:"user_id" gorm:"not null"`
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

// Topic 话题模型
type Topic struct {
	ID        string         `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	Name           string `json:"name" gorm:"uniqueIndex;not null"`
	Description    string `json:"description"`
	Icon           string `json:"icon"`
	Color          string `json:"color"`
	PostsCount     int    `json:"posts_count" gorm:"default:0"`
	FollowersCount int    `json:"followers_count" gorm:"default:0"`
	IsHot          bool   `json:"is_hot" gorm:"default:false"`
	IsOfficial     bool   `json:"is_official" gorm:"default:false"`

	// 关联关系
	Posts []Post `json:"posts" gorm:"many2many:post_topics;"`
}

// PostTopic 动态-话题关联模型
type PostTopic struct {
	ID        string    `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time `json:"created_at"`

	PostID  string `json:"post_id" gorm:"not null"`
	TopicID string `json:"topic_id" gorm:"not null"`

	// 关联关系
	Post  Post  `json:"post" gorm:"foreignKey:PostID"`
	Topic Topic `json:"topic" gorm:"foreignKey:TopicID"`
}

// Favorite 收藏模型
type Favorite struct {
	ID        string         `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	UserID string `json:"user_id" gorm:"not null"`
	PostID string `json:"post_id" gorm:"not null"`

	// 关联关系
	User User `json:"user" gorm:"foreignKey:UserID"`
	Post Post `json:"post" gorm:"foreignKey:PostID"`
}

// Share 分享模型
type Share struct {
	ID        string    `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time `json:"created_at"`

	UserID        string `json:"user_id" gorm:"not null"`
	PostID        string `json:"post_id" gorm:"not null"`
	ShareType     string `json:"share_type" gorm:"default:'community'"` // 分享类型
	SharePlatform string `json:"share_platform"`                        // 分享平台

	// 关联关系
	User User `json:"user" gorm:"foreignKey:UserID"`
	Post Post `json:"post" gorm:"foreignKey:PostID"`
}

// UserTag 用户标签模型
type UserTag struct {
	ID        string    `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time `json:"created_at"`

	UserID  string `json:"user_id" gorm:"not null"`
	TagName string `json:"tag_name" gorm:"not null"`
	TagType string `json:"tag_type" gorm:"not null"` // 标签类型

	// 关联关系
	User User `json:"user" gorm:"foreignKey:UserID"`
}

// Challenge 挑战模型扩展
type Challenge struct {
	ID        string         `json:"id" gorm:"primaryKey"`
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

	// 挑战扩展字段
	CoverImage      string  `json:"cover_image"`      // 挑战封面图
	Rules           string  `json:"rules"`            // 挑战规则
	Rewards         string  `json:"rewards"`          // 奖励说明
	Tags            string  `json:"tags"`             // JSON数组存储标签
	IsFeatured      bool    `json:"is_featured"`      // 是否精选
	MaxParticipants *int    `json:"max_participants"` // 最大参与人数
	EntryFee        float64 `json:"entry_fee"`        // 参与费用

	// 统计信息
	ParticipantsCount int `json:"participants_count" gorm:"default:0"`

	// 关联关系
	Participants []ChallengeParticipant `json:"participants" gorm:"foreignKey:ChallengeID"`
	Checkins     []ChallengeCheckin     `json:"checkins" gorm:"foreignKey:ChallengeID"`
}

// ChallengeParticipant 挑战参与者模型扩展
type ChallengeParticipant struct {
	ID        string         `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	UserID      string `json:"user_id" gorm:"not null"`
	ChallengeID string `json:"challenge_id" gorm:"not null"`
	Progress    int    `json:"progress" gorm:"default:0"` // 进度百分比

	// 挑战扩展字段
	JoinedAt      time.Time  `json:"joined_at"`
	LastCheckinAt *time.Time `json:"last_checkin_at"`
	CheckinCount  int        `json:"checkin_count" gorm:"default:0"`
	TotalCalories int        `json:"total_calories" gorm:"default:0"`
	Status        string     `json:"status" gorm:"default:'active'"` // 状态
	Rank          *int       `json:"rank"`                           // 排名

	// 关联关系
	User      User               `json:"user" gorm:"foreignKey:UserID"`
	Challenge Challenge          `json:"challenge" gorm:"foreignKey:ChallengeID"`
	Checkins  []ChallengeCheckin `json:"checkins" gorm:"foreignKey:ParticipantID"`
}

// ChallengeCheckin 挑战打卡记录模型
type ChallengeCheckin struct {
	ID        string         `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	UserID        string    `json:"user_id" gorm:"not null"`
	ChallengeID   string    `json:"challenge_id" gorm:"not null"`
	ParticipantID string    `json:"participant_id" gorm:"not null"`
	CheckinDate   time.Time `json:"checkin_date" gorm:"not null"`
	Content       string    `json:"content"`
	Images        string    `json:"images"` // JSON数组存储图片
	Calories      int       `json:"calories" gorm:"default:0"`
	Duration      int       `json:"duration" gorm:"default:0"` // 运动时长（分钟）
	Notes         string    `json:"notes"`

	// 关联关系
	User        User                 `json:"user" gorm:"foreignKey:UserID"`
	Challenge   Challenge            `json:"challenge" gorm:"foreignKey:ChallengeID"`
	Participant ChallengeParticipant `json:"participant" gorm:"foreignKey:ParticipantID"`
}

// Notification 通知模型
type Notification struct {
	ID        string         `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	UserID             string  `json:"user_id" gorm:"not null"`
	Type               string  `json:"type" gorm:"not null"` // 通知类型
	Title              string  `json:"title" gorm:"not null"`
	Content            string  `json:"content"`
	Data               string  `json:"data"` // JSON存储额外数据
	IsRead             bool    `json:"is_read" gorm:"default:false"`
	RelatedUserID      *string `json:"related_user_id"`
	RelatedPostID      *string `json:"related_post_id"`
	RelatedChallengeID *string `json:"related_challenge_id"`

	// 关联关系
	User             User       `json:"user" gorm:"foreignKey:UserID"`
	RelatedUser      *User      `json:"related_user" gorm:"foreignKey:RelatedUserID"`
	RelatedPost      *Post      `json:"related_post" gorm:"foreignKey:RelatedPostID"`
	RelatedChallenge *Challenge `json:"related_challenge" gorm:"foreignKey:RelatedChallengeID"`
}

// PostView 动态浏览记录模型
type PostView struct {
	ID        string    `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time `json:"created_at"`

	UserID    *string `json:"user_id"` // 可为空，支持匿名浏览
	PostID    string  `json:"post_id" gorm:"not null"`
	IPAddress string  `json:"ip_address"`
	UserAgent string  `json:"user_agent"`

	// 关联关系
	User *User `json:"user" gorm:"foreignKey:UserID"`
	Post Post  `json:"post" gorm:"foreignKey:PostID"`
}

// SearchLog 搜索记录模型
type SearchLog struct {
	ID        string    `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time `json:"created_at"`

	UserID       *string `json:"user_id"`
	Query        string  `json:"query" gorm:"not null"`
	SearchType   string  `json:"search_type" gorm:"not null"` // 搜索类型
	ResultsCount int     `json:"results_count" gorm:"default:0"`
	IPAddress    string  `json:"ip_address"`

	// 关联关系
	User *User `json:"user" gorm:"foreignKey:UserID"`
}
