package handlers

import (
	"fittracker/backend/internal/config"
	"fittracker/backend/internal/domain/services"
	"fittracker/backend/internal/infrastructure/cache"

	"github.com/go-redis/redis/v8"
	"gorm.io/gorm"
)

// Handlers 处理器集合
type Handlers struct {
	DB     *gorm.DB
	Redis  *redis.Client
	Cache  *cache.CacheService
	Config *config.Config

	// 服务层
	UserService        *services.UserService
	WorkoutService     *services.WorkoutService
	BMIService         *services.BMIService
	NutritionService   *services.NutritionService
	CheckinService     *services.CheckinService
	CommunityService   *services.CommunityService
	AICoachService     *services.AICoachService
	AINutritionService *services.AINutritionService
}

// New 创建新的处理器集合
func New(db *gorm.DB, redis *redis.Client, cacheService *cache.CacheService, cfg *config.Config) *Handlers {
	// 初始化服务层
	userService := services.NewUserService(db)
	workoutService := services.NewWorkoutService(db)
	bmiService := services.NewBMIService(db)
	nutritionService := services.NewNutritionService(db)
	checkinService := services.NewCheckinService(db)
	communityService := services.NewCommunityService(db)
	aiCoachService := services.NewAICoachService(cfg)
	aiNutritionService := services.NewAINutritionService(cfg)

	return &Handlers{
		DB:                 db,
		Redis:              redis,
		Cache:              cacheService,
		Config:             cfg,
		UserService:        userService,
		WorkoutService:     workoutService,
		BMIService:         bmiService,
		NutritionService:   nutritionService,
		CheckinService:     checkinService,
		CommunityService:   communityService,
		AICoachService:     aiCoachService,
		AINutritionService: aiNutritionService,
	}
}
