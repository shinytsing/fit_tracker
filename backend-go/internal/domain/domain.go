package domain

// 重新导出 models 包中的类型
import "gymates/internal/domain/models"

// 重新导出所有类型
type MediaItem = models.MediaItem
type WorkoutData = models.WorkoutData
type ExerciseData = models.ExerciseData
type CheckInData = models.CheckInData
type Post = models.Post
type PostStatus = models.PostStatus
type Challenge = models.Challenge
type ChallengeParticipant = models.ChallengeParticipant
type ChallengeCheckin = models.ChallengeCheckin

// 常量重新导出
const (
	PostStatusDraft     = models.PostStatusDraft
	PostStatusPublished = models.PostStatusPublished
	PostStatusDeleted   = models.PostStatusDeleted
)
