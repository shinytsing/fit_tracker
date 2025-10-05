package main

import (
	"log"

	"gymates/internal/config"
	"gymates/internal/database"
	"gymates/internal/models"

	"github.com/joho/godotenv"
	"gorm.io/gorm"
)

func main() {
	// 加载环境变量
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found")
	}

	// 初始化配置
	cfg := config.Load()

	// 初始化数据库
	db, err := database.Initialize(cfg)
	if err != nil {
		log.Fatal("Failed to initialize database:", err)
	}

	log.Println("Starting database migration...")

	// 删除所有现有表
	log.Println("Dropping existing tables...")
	if err := dropAllTables(db); err != nil {
		log.Fatal("Failed to drop tables:", err)
	}

	// 重新创建所有表
	log.Println("Creating new tables...")
	if err := createAllTables(db); err != nil {
		log.Fatal("Failed to create tables:", err)
	}

	log.Println("Database migration completed successfully!")
}

func dropAllTables(db *gorm.DB) error {
	// 按依赖关系顺序删除表
	tables := []interface{}{
		&models.ChallengeCheckin{},
		&models.ChallengeParticipant{},
		&models.Challenge{},
		&models.PostView{},
		&models.Share{},
		&models.Favorite{},
		&models.PostTopic{},
		&models.Topic{},
		&models.Comment{},
		&models.Like{},
		&models.Post{},
		&models.Follow{},
		&models.Message{},
		&models.Chat{},
		&models.Notification{},
		&models.AIRequest{},
		&models.AIModel{},
		&models.MediaFile{},
		&models.Checkin{},
		&models.HealthRecord{},
		&models.Workout{},
		&models.Exercise{},
		&models.ExerciseSet{},
		&models.TrainingExercise{},
		&models.TrainingPlan{},
		&models.User{},
	}

	for _, table := range tables {
		if err := db.Migrator().DropTable(table); err != nil {
			log.Printf("Warning: Failed to drop table %T: %v", table, err)
		}
	}

	return nil
}

func createAllTables(db *gorm.DB) error {
	// 按依赖关系顺序创建表
	tables := []interface{}{
		&models.User{},
		&models.TrainingPlan{},
		&models.TrainingExercise{},
		&models.ExerciseSet{},
		&models.Exercise{},
		&models.Workout{},
		&models.Checkin{},
		&models.HealthRecord{},
		&models.MediaFile{},
		&models.AIModel{},
		&models.AIRequest{},
		&models.Notification{},
		&models.Chat{},
		&models.Message{},
		&models.Follow{},
		&models.Post{},
		&models.Like{},
		&models.Comment{},
		&models.Topic{},
		&models.PostTopic{},
		&models.Favorite{},
		&models.Share{},
		&models.PostView{},
		&models.Challenge{},
		&models.ChallengeParticipant{},
		&models.ChallengeCheckin{},
	}

	if err := db.AutoMigrate(tables...); err != nil {
		return err
	}

	return nil
}
