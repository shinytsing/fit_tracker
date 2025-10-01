package handlers

import (
	"fittracker/internal/config"
	"fittracker/internal/domain/services"
	"fittracker/internal/infrastructure/cache"
	"net/http"

	"github.com/gin-gonic/gin"
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

// HealthCheck 健康检查端点
func (h *Handlers) HealthCheck(c *gin.Context) {
	// 检查数据库连接
	sqlDB, err := h.DB.DB()
	if err != nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{
			"status": "unhealthy",
			"error":  "database connection failed",
		})
		return
	}

	if err := sqlDB.Ping(); err != nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{
			"status": "unhealthy",
			"error":  "database ping failed",
		})
		return
	}

	// 检查 Redis 连接
	if err := h.Redis.Ping(c.Request.Context()).Err(); err != nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{
			"status": "unhealthy",
			"error":  "redis connection failed",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  "healthy",
		"message": "FitTracker API is running",
	})
}
