package services

import (
	"gymates/internal/config"

	"github.com/go-redis/redis/v8"
	"gorm.io/gorm"
)

// Services 服务容器
type Services struct {
	UserService        *UserService
	AuthService        *AuthService
	AIService          *AIService
	TrainingService    *TrainingService
	MessageService     *MessageService
	BuddyService       *BuddyService
	CommunityService   *CommunityService
	UserProfileService *UserProfileService
}

// NewServices 创建服务容器
func NewServices(cfg *config.Config, db *gorm.DB, redisClient *redis.Client) *Services {
	userService := NewUserService(db, redisClient)
	authService := NewAuthService(cfg, userService)
	aiService := NewAIService(cfg)
	trainingService := NewTrainingService(db, aiService, userService)
	messageService := NewMessageService(db)
	buddyService := NewBuddyService(db)
	communityService := NewCommunityService(db)
	userProfileService := NewUserProfileService(db)

	return &Services{
		UserService:        userService,
		AuthService:        authService,
		AIService:          aiService,
		TrainingService:    trainingService,
		MessageService:     messageService,
		BuddyService:       buddyService,
		CommunityService:   communityService,
		UserProfileService: userProfileService,
	}
}
