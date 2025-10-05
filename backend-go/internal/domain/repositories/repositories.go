package repositories

import (
	"gymates/internal/models"
)

// UserRepository 用户仓储接口
type UserRepository interface {
	Create(user *models.User) error
	GetByID(id uint) (*models.User, error)
	GetByEmail(email string) (*models.User, error)
	GetByUsername(username string) (*models.User, error)
	Update(user *models.User) error
	Delete(id uint) error
	GetStats(userID uint) (*models.UserStats, error)
}

// WorkoutRepository 训练记录仓储接口
type WorkoutRepository interface {
	Create(workout *models.Workout) error
	GetByID(id uint) (*models.Workout, error)
	GetByUserID(userID uint, limit, offset int) ([]*models.Workout, error)
	Update(workout *models.Workout) error
	Delete(id uint) error
}

// TrainingPlanRepository 训练计划仓储接口
type TrainingPlanRepository interface {
	Create(plan *models.TrainingPlan) error
	GetByID(id uint) (*models.TrainingPlan, error)
	GetAll(limit, offset int) ([]*models.TrainingPlan, error)
	Update(plan *models.TrainingPlan) error
	Delete(id uint) error
}

// ExerciseRepository 运动动作仓储接口
type ExerciseRepository interface {
	Create(exercise *models.Exercise) error
	GetByID(id uint) (*models.Exercise, error)
	GetByCategory(category string, limit, offset int) ([]*models.Exercise, error)
	Update(exercise *models.Exercise) error
	Delete(id uint) error
}

// HealthRecordRepository 健康记录仓储接口
type HealthRecordRepository interface {
	Create(record *models.HealthRecord) error
	GetByID(id uint) (*models.HealthRecord, error)
	GetByUserIDAndType(userID uint, recordType string, limit, offset int) ([]*models.HealthRecord, error)
	Update(record *models.HealthRecord) error
	Delete(id uint) error
}

// NutritionRecordRepository 营养记录仓储接口
type NutritionRecordRepository interface {
	Create(record *models.NutritionRecord) error
	GetByID(id uint) (*models.NutritionRecord, error)
	GetByUserID(userID uint, limit, offset int) ([]*models.NutritionRecord, error)
	Update(record *models.NutritionRecord) error
	Delete(id uint) error
}

// CheckinRepository 签到记录仓储接口
type CheckinRepository interface {
	Create(checkin *models.Checkin) error
	GetByID(id uint) (*models.Checkin, error)
	GetByUserID(userID uint, limit, offset int) ([]*models.Checkin, error)
	GetStreak(userID uint) (int, error)
	Update(checkin *models.Checkin) error
	Delete(id uint) error
}

// PostRepository 动态仓储接口
type PostRepository interface {
	Create(post *models.Post) error
	GetByID(id uint) (*models.Post, error)
	GetFeed(userID uint, limit, offset int) ([]*models.Post, error)
	Update(post *models.Post) error
	Delete(id uint) error
}

// LikeRepository 点赞仓储接口
type LikeRepository interface {
	Create(like *models.Like) error
	GetByUserAndPost(userID, postID uint) (*models.Like, error)
	DeleteByUserAndPost(userID, postID uint) error
	GetByPostID(postID uint) ([]*models.Like, error)
}

// CommentRepository 评论仓储接口
type CommentRepository interface {
	Create(comment *models.Comment) error
	GetByID(id uint) (*models.Comment, error)
	GetByPostID(postID uint, limit, offset int) ([]*models.Comment, error)
	Update(comment *models.Comment) error
	Delete(id uint) error
}

// FollowRepository 关注关系仓储接口
type FollowRepository interface {
	Create(follow *models.Follow) error
	GetByFollowerAndFollowing(followerID, followingID uint) (*models.Follow, error)
	DeleteByFollowerAndFollowing(followerID, followingID uint) error
	GetFollowers(userID uint, limit, offset int) ([]*models.User, error)
	GetFollowing(userID uint, limit, offset int) ([]*models.User, error)
}

// ChallengeRepository 挑战仓储接口
type ChallengeRepository interface {
	Create(challenge *models.Challenge) error
	GetByID(id uint) (*models.Challenge, error)
	GetAll(limit, offset int) ([]*models.Challenge, error)
	Update(challenge *models.Challenge) error
	Delete(id uint) error
	JoinChallenge(userID, challengeID uint) error
	GetLeaderboard(challengeID uint) ([]*models.ChallengeParticipant, error)
}
