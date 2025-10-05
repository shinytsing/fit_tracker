package database

import (
	"context"
	"fmt"
	"strings"
	"time"

	"gymates/internal/models"

	"github.com/go-redis/redis/v8"
	"gorm.io/driver/postgres"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

// Init 初始化数据库连接
func Init(databaseURL string) (*gorm.DB, error) {
	var db *gorm.DB
	var err error

	// 验证数据库URL格式
	if databaseURL == "" {
		return nil, fmt.Errorf("database URL cannot be empty")
	}

	// 设置重试机制
	maxRetries := 5
	retryDelay := 2 * time.Second

	for i := 0; i < maxRetries; i++ {
		fmt.Printf("Attempting database connection (attempt %d/%d)...\n", i+1, maxRetries)

		if strings.HasPrefix(databaseURL, "sqlite://") {
			// SQLite数据库
			dbPath := strings.TrimPrefix(databaseURL, "sqlite://")
			if dbPath == "" {
				return nil, fmt.Errorf("SQLite database path cannot be empty")
			}
			db, err = gorm.Open(sqlite.Open(dbPath), &gorm.Config{
				Logger: logger.Default.LogMode(logger.Info),
			})
		} else {
			// PostgreSQL数据库
			// 验证PostgreSQL URL格式
			if !strings.HasPrefix(databaseURL, "postgres://") && !strings.HasPrefix(databaseURL, "postgresql://") {
				return nil, fmt.Errorf("invalid PostgreSQL URL format")
			}

			db, err = gorm.Open(postgres.Open(databaseURL), &gorm.Config{
				Logger: logger.Default.LogMode(logger.Info),
				// 添加连接配置
				DisableForeignKeyConstraintWhenMigrating: true,
			})
		}

		if err == nil {
			// 测试连接
			if err = testConnection(db); err == nil {
				fmt.Printf("Database connection successful on attempt %d\n", i+1)
				break
			}
		}

		if i < maxRetries-1 {
			fmt.Printf("Database connection attempt %d failed: %v, retrying in %v...\n", i+1, err, retryDelay)
			time.Sleep(retryDelay)
			retryDelay *= 2 // 指数退避
		}
	}

	if err != nil {
		return nil, fmt.Errorf("failed to connect to database after %d attempts: %w", maxRetries, err)
	}

	// 获取底层sql.DB对象进行连接池配置
	sqlDB, err := db.DB()
	if err != nil {
		return nil, fmt.Errorf("failed to get sql.DB: %w", err)
	}

	// 设置连接池参数
	sqlDB.SetMaxIdleConns(10)
	sqlDB.SetMaxOpenConns(100)
	sqlDB.SetConnMaxLifetime(time.Hour)
	sqlDB.SetConnMaxIdleTime(30 * time.Minute)

	// 自动迁移数据库表
	if err := autoMigrate(db); err != nil {
		fmt.Printf("Warning: failed to migrate database: %v\n", err)
		// 不返回错误，允许应用继续运行
	}

	fmt.Println("Database connection established successfully")
	return db, nil
}

// testConnection 测试数据库连接
func testConnection(db *gorm.DB) error {
	sqlDB, err := db.DB()
	if err != nil {
		return fmt.Errorf("failed to get sql.DB: %w", err)
	}

	// 设置超时
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// 测试连接
	if err := sqlDB.PingContext(ctx); err != nil {
		return fmt.Errorf("failed to ping database: %w", err)
	}

	// 测试简单查询
	var result int
	if err := db.WithContext(ctx).Raw("SELECT 1").Scan(&result).Error; err != nil {
		return fmt.Errorf("failed to execute test query: %w", err)
	}

	return nil
}

// InitRedis 初始化Redis连接
func InitRedis(redisURL string) (*redis.Client, error) {
	opt, err := redis.ParseURL(redisURL)
	if err != nil {
		return nil, fmt.Errorf("failed to parse Redis URL: %w", err)
	}

	client := redis.NewClient(opt)

	// 测试连接
	ctx := context.Background()
	if err := client.Ping(ctx).Err(); err != nil {
		return nil, fmt.Errorf("failed to connect to Redis: %w", err)
	}

	return client, nil
}

// autoMigrate 自动迁移数据库表
func autoMigrate(db *gorm.DB) error {
	// 先迁移基本模型
	err := db.AutoMigrate(
		&models.User{},
		&models.Workout{},
		&models.Checkin{},
		&models.HealthRecord{},
	)
	if err != nil {
		return err
	}

	// 再迁移其他模型
	return db.AutoMigrate(
		&models.TrainingPlan{},
		&models.Exercise{},
		&models.Post{},
		&models.Like{},
		&models.Comment{},
		&models.Follow{},
		&models.Challenge{},
		&models.ChallengeParticipant{},
		&models.NutritionRecord{},
	)
}
