package models

import (
	"time"
)

// Post 社区动态模型
type Post struct {
	ID           string       `json:"id" gorm:"primaryKey"`
	UserID       string       `json:"user_id" gorm:"type:uuid;not null"`
	Content      string       `json:"content" gorm:"not null"`
	Type         string       `json:"type"` // text, image, video, workout, checkin
	Images       []string     `json:"images" gorm:"type:jsonb"`
	VideoURL     string       `json:"video_url"`
	Tags         []string     `json:"tags" gorm:"type:jsonb"`
	Location     string       `json:"location"`
	WorkoutData  *WorkoutData `json:"workout_data" gorm:"type:jsonb"`
	LikeCount    int          `json:"like_count"`
	CommentCount int          `json:"comment_count"`
	ShareCount   int          `json:"share_count"`
	IsLiked      bool         `json:"is_liked" gorm:"-"`
	IsFeatured   bool         `json:"is_featured" gorm:"column:is_featured"` // 是否精选
	IsPinned     bool         `json:"is_pinned" gorm:"column:is_pinned"`     // 是否置顶
	CreatedAt    time.Time    `json:"created_at"`
	UpdatedAt    time.Time    `json:"updated_at"`

	// 关联数据
	User     User       `json:"user" gorm:"foreignKey:UserID"`
	Comments []Comment  `json:"comments" gorm:"foreignKey:PostID"`
	Likes    []PostLike `json:"likes" gorm:"foreignKey:PostID"`
}

// TableName 指定表名
func (Post) TableName() string {
	return "posts"
}

// Comment 评论模型
type Comment struct {
	ID        string    `json:"id" gorm:"primaryKey"`
	PostID    string    `json:"post_id" gorm:"not null"`
	UserID    string    `json:"user_id" gorm:"type:uuid;not null"`
	Content   string    `json:"content" gorm:"not null"`
	ParentID  string    `json:"parent_id"` // 回复的评论ID
	LikeCount int       `json:"like_count"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	// 关联数据
	User    User      `json:"user" gorm:"foreignKey:UserID"`
	Replies []Comment `json:"replies" gorm:"foreignKey:ParentID"`
}

// PostLike 点赞模型
type PostLike struct {
	ID        string    `json:"id" gorm:"primaryKey"`
	PostID    string    `json:"post_id" gorm:"not null"`
	UserID    string    `json:"user_id" gorm:"type:uuid;not null"`
	CreatedAt time.Time `json:"created_at"`
}

// Follow 关注关系模型
type Follow struct {
	ID          string    `json:"id" gorm:"primaryKey"`
	FollowerID  string    `json:"follower_id" gorm:"type:uuid;not null"`
	FollowingID string    `json:"following_id" gorm:"type:uuid;not null"`
	CreatedAt   time.Time `json:"created_at"`
}

// Topic 话题模型
type Topic struct {
	ID             string    `json:"id" gorm:"primaryKey"`
	Name           string    `json:"name" gorm:"uniqueIndex;not null"`
	Description    string    `json:"description"`
	ImageURL       string    `json:"image_url"`
	PostCount      int       `json:"post_count"`
	FollowersCount int       `json:"followers_count"`
	IsActive       bool      `json:"is_active"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}

// PostTopic 动态话题关联模型
type PostTopic struct {
	ID      string `json:"id" gorm:"primaryKey"`
	PostID  string `json:"post_id" gorm:"not null"`
	TopicID string `json:"topic_id" gorm:"not null"`
}

// Report 举报模型
type Report struct {
	ID          string    `json:"id" gorm:"primaryKey"`
	ReporterID  string    `json:"reporter_id" gorm:"not null"`
	PostID      string    `json:"post_id"`
	CommentID   string    `json:"comment_id"`
	UserID      string    `json:"user_id"` // 被举报用户
	Reason      string    `json:"reason" gorm:"not null"`
	Description string    `json:"description"`
	Status      string    `json:"status" gorm:"default:'pending'"` // pending, processed, rejected
	ProcessedAt time.Time `json:"processed_at"`
	ProcessedBy string    `json:"processed_by"`
	CreatedAt   time.Time `json:"created_at"`
}

// CreatePostRequest 创建动态请求
type CreatePostRequest struct {
	Content     string       `json:"content" binding:"required"`
	Type        string       `json:"type" binding:"required"`
	Images      []string     `json:"images"`
	VideoURL    string       `json:"video_url"`
	Tags        []string     `json:"tags"`
	Location    string       `json:"location"`
	WorkoutData *WorkoutData `json:"workout_data"`
}

// UpdatePostRequest 更新动态请求
type UpdatePostRequest struct {
	Content     string       `json:"content"`
	Images      []string     `json:"images"`
	VideoURL    string       `json:"video_url"`
	Tags        []string     `json:"tags"`
	Location    string       `json:"location"`
	WorkoutData *WorkoutData `json:"workout_data"`
}

// CreateCommentRequest 创建评论请求
type CreateCommentRequest struct {
	Content  string `json:"content" binding:"required"`
	ParentID string `json:"parent_id"`
}

// CreateTopicRequest 创建话题请求
type CreateTopicRequest struct {
	Name        string `json:"name" binding:"required"`
	Description string `json:"description"`
	ImageURL    string `json:"image_url"`
}

// CreateReportRequest 创建举报请求
type CreateReportRequest struct {
	PostID      string `json:"post_id"`
	CommentID   string `json:"comment_id"`
	UserID      string `json:"user_id"`
	Reason      string `json:"reason" binding:"required"`
	Description string `json:"description"`
}

// PostResponse 动态响应
type PostResponse struct {
	ID           string       `json:"id"`
	UserID       string       `json:"user_id"`
	Content      string       `json:"content"`
	Type         string       `json:"type"`
	Images       []string     `json:"images"`
	VideoURL     string       `json:"video_url"`
	Tags         []string     `json:"tags"`
	Location     string       `json:"location"`
	WorkoutData  *WorkoutData `json:"workout_data"`
	LikeCount    int          `json:"like_count"`
	CommentCount int          `json:"comment_count"`
	ShareCount   int          `json:"share_count"`
	IsLiked      bool         `json:"is_liked"`
	IsFeatured   bool         `json:"is_featured"`
	IsPinned     bool         `json:"is_pinned"`
	CreatedAt    time.Time    `json:"created_at"`
	UpdatedAt    time.Time    `json:"updated_at"`
	User         User         `json:"user"`
	Comments     []Comment    `json:"comments"`
}

// CommentResponse 评论响应
type CommentResponse struct {
	ID        string            `json:"id"`
	PostID    string            `json:"post_id"`
	UserID    string            `json:"user_id"`
	Content   string            `json:"content"`
	ParentID  string            `json:"parent_id"`
	LikeCount int               `json:"like_count"`
	CreatedAt time.Time         `json:"created_at"`
	UpdatedAt time.Time         `json:"updated_at"`
	User      User              `json:"user"`
	Replies   []CommentResponse `json:"replies"`
}

// TopicResponse 话题响应
type TopicResponse struct {
	ID             string    `json:"id"`
	Name           string    `json:"name"`
	Description    string    `json:"description"`
	ImageURL       string    `json:"image_url"`
	PostCount      int       `json:"post_count"`
	FollowersCount int       `json:"followers_count"`
	IsActive       bool      `json:"is_active"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}
