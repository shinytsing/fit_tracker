package database

import (
	"context"
	"fmt"
	"log"
	"time"

	"gymates/internal/config"

	"github.com/go-redis/redis/v8"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func Initialize(cfg *config.Config) (*gorm.DB, error) {
	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		cfg.Database.Host,
		cfg.Database.Port,
		cfg.Database.User,
		cfg.Database.Password,
		cfg.Database.DBName,
		cfg.Database.SSLMode,
	)

	var logLevel logger.LogLevel
	if cfg.Environment == "production" {
		logLevel = logger.Silent
	} else {
		logLevel = logger.Info
	}

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logLevel),
	})
	if err != nil {
		return nil, fmt.Errorf("failed to connect to database: %w", err)
	}

	// 配置连接池
	sqlDB, err := db.DB()
	if err != nil {
		return nil, fmt.Errorf("failed to get underlying sql.DB: %w", err)
	}

	sqlDB.SetMaxIdleConns(10)
	sqlDB.SetMaxOpenConns(100)
	sqlDB.SetConnMaxLifetime(time.Hour)

	// 手动创建posts表结构
	if err := createPostsTable(db); err != nil {
		return nil, fmt.Errorf("failed to create posts table: %w", err)
	}

	log.Println("Database connected successfully")

	// 测试数据库连接和表是否存在
	var count int64
	if err := db.Table("posts").Count(&count).Error; err != nil {
		log.Printf("Error checking posts table: %v", err)
	} else {
		log.Printf("Posts table exists, count: %d", count)
	}

	return db, nil
}

func InitializeRedis(cfg *config.Config) (*redis.Client, error) {
	rdb := redis.NewClient(&redis.Options{
		Addr:     fmt.Sprintf("%s:%s", cfg.Redis.Host, cfg.Redis.Port),
		Password: cfg.Redis.Password,
		DB:       cfg.Redis.DB,
	})

	// 测试连接
	ctx := context.Background()
	_, err := rdb.Ping(ctx).Result()
	if err != nil {
		return nil, fmt.Errorf("failed to connect to Redis: %w", err)
	}

	log.Println("Redis connected successfully")
	return rdb, nil
}

func createPostsTable(db *gorm.DB) error {
	// 检查posts表是否存在
	var exists bool
	err := db.Raw("SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'posts')").Scan(&exists).Error
	if err != nil {
		return fmt.Errorf("failed to check if posts table exists: %w", err)
	}

	if !exists {
		// 创建posts表
		sql := `
			CREATE TABLE posts (
				id VARCHAR(255) PRIMARY KEY,
				user_id UUID NOT NULL,
				content TEXT NOT NULL,
				type VARCHAR(50),
				images JSONB,
				video_url VARCHAR(500),
				tags JSONB,
				location VARCHAR(255),
				workout_data JSONB,
				like_count INTEGER DEFAULT 0,
				comment_count INTEGER DEFAULT 0,
				share_count INTEGER DEFAULT 0,
				is_featured BOOLEAN DEFAULT FALSE,
				is_pinned BOOLEAN DEFAULT FALSE,
				created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
				updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
			)
		`

		if err := db.Exec(sql).Error; err != nil {
			return fmt.Errorf("failed to create posts table: %w", err)
		}

		log.Println("Posts table created successfully")
	} else {
		// 检查is_pinned和is_featured字段是否存在
		var columnExists bool

		// 检查is_pinned字段
		err = db.Raw("SELECT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'posts' AND column_name = 'is_pinned')").Scan(&columnExists).Error
		if err != nil {
			return fmt.Errorf("failed to check is_pinned column: %w", err)
		}

		if !columnExists {
			if err := db.Exec("ALTER TABLE posts ADD COLUMN is_pinned BOOLEAN DEFAULT FALSE").Error; err != nil {
				return fmt.Errorf("failed to add is_pinned column: %w", err)
			}
			log.Println("Added is_pinned column to posts table")
		}

		// 检查is_featured字段
		err = db.Raw("SELECT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'posts' AND column_name = 'is_featured')").Scan(&columnExists).Error
		if err != nil {
			return fmt.Errorf("failed to check is_featured column: %w", err)
		}

		if !columnExists {
			if err := db.Exec("ALTER TABLE posts ADD COLUMN is_featured BOOLEAN DEFAULT FALSE").Error; err != nil {
				return fmt.Errorf("failed to add is_featured column: %w", err)
			}
			log.Println("Added is_featured column to posts table")
		}
	}

	return nil
}
