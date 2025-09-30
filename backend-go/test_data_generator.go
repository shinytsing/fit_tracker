package main

import (
	"fmt"
	"log"
	"time"

	"fittracker/backend/internal/domain/models"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func main() {
	// 连接测试数据库
	db, err := gorm.Open(postgres.Open("postgres://fittracker:fittracker123@postgres-test:5432/fittracker_test?sslmode=disable"), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// 自动迁移数据库
	err = db.AutoMigrate(
		&models.User{},
		&models.TrainingPlan{},
		&models.Exercise{},
		&models.Workout{},
		&models.Checkin{},
		&models.HealthRecord{},
		&models.Post{},
		&models.Like{},
		&models.Comment{},
		&models.Follow{},
		&models.Challenge{},
		&models.ChallengeParticipant{},
		&models.NutritionRecord{},
	)
	if err != nil {
		log.Fatal("Failed to migrate database:", err)
	}

	// 生成测试数据
	fmt.Println("Generating test data...")

	// 生成用户
	users := generateUsers(db)
	fmt.Printf("Generated %d users\n", len(users))

	// 生成训练计划
	trainingPlans := generateTrainingPlans(db)
	fmt.Printf("Generated %d training plans\n", len(trainingPlans))

	// 生成运动动作
	exercises := generateExercises(db)
	fmt.Printf("Generated %d exercises\n", len(exercises))

	// 生成训练记录
	workouts := generateWorkouts(db, users)
	fmt.Printf("Generated %d workouts\n", len(workouts))

	// 生成签到记录
	checkins := generateCheckins(db, users)
	fmt.Printf("Generated %d checkins\n", len(checkins))

	// 生成健康记录
	healthRecords := generateHealthRecords(db, users)
	fmt.Printf("Generated %d health records\n", len(healthRecords))

	// 生成社区动态
	posts := generatePosts(db, users)
	fmt.Printf("Generated %d posts\n", len(posts))

	// 生成点赞记录
	likes := generateLikes(db, users, posts)
	fmt.Printf("Generated %d likes\n", len(likes))

	// 生成评论
	comments := generateComments(db, users, posts)
	fmt.Printf("Generated %d comments\n", len(comments))

	// 生成关注关系
	follows := generateFollows(db, users)
	fmt.Printf("Generated %d follows\n", len(follows))

	// 生成挑战
	challenges := generateChallenges(db, users)
	fmt.Printf("Generated %d challenges\n", len(challenges))

	// 生成挑战参与记录
	challengeParticipants := generateChallengeParticipants(db, users, challenges)
	fmt.Printf("Generated %d challenge participants\n", len(challengeParticipants))

	// 生成营养记录
	nutritionRecords := generateNutritionRecords(db, users)
	fmt.Printf("Generated %d nutrition records\n", len(nutritionRecords))

	fmt.Println("Test data generation completed!")
}

func generateUsers(db *gorm.DB) []models.User {
	users := []models.User{
		{
			Username:      "testuser1",
			Email:         "test1@example.com",
			PasswordHash:  "$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi", // password
			FirstName:     "Test",
			LastName:      "User1",
			Bio:           "热爱健身的测试用户",
			TotalWorkouts: 10,
			TotalCheckins: 15,
			CurrentStreak: 5,
			LongestStreak: 10,
		},
		{
			Username:      "testuser2",
			Email:         "test2@example.com",
			PasswordHash:  "$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi", // password
			FirstName:     "Test",
			LastName:      "User2",
			Bio:           "健身新手",
			TotalWorkouts: 5,
			TotalCheckins: 8,
			CurrentStreak: 3,
			LongestStreak: 5,
		},
		{
			Username:      "testuser3",
			Email:         "test3@example.com",
			PasswordHash:  "$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi", // password
			FirstName:     "Test",
			LastName:      "User3",
			Bio:           "健身达人",
			TotalWorkouts: 50,
			TotalCheckins: 60,
			CurrentStreak: 20,
			LongestStreak: 30,
		},
	}

	for i := range users {
		if err := db.Create(&users[i]).Error; err != nil {
			log.Printf("Failed to create user %d: %v", i+1, err)
		}
	}

	return users
}

func generateTrainingPlans(db *gorm.DB) []models.TrainingPlan {
	plans := []models.TrainingPlan{
		{
			Name:        "初级力量训练计划",
			Description: "适合初学者的力量训练计划",
			Type:        "力量训练",
			Difficulty:  "初级",
			Duration:    30,
			IsPublic:    true,
		},
		{
			Name:        "中级有氧训练计划",
			Description: "适合中级用户的有氧训练计划",
			Type:        "有氧训练",
			Difficulty:  "中级",
			Duration:    45,
			IsPublic:    true,
		},
		{
			Name:        "高级综合训练计划",
			Description: "适合高级用户的综合训练计划",
			Type:        "综合训练",
			Difficulty:  "高级",
			Duration:    60,
			IsPublic:    true,
		},
	}

	for i := range plans {
		if err := db.Create(&plans[i]).Error; err != nil {
			log.Printf("Failed to create training plan %d: %v", i+1, err)
		}
	}

	return plans
}

func generateExercises(db *gorm.DB) []models.Exercise {
	exercises := []models.Exercise{
		{
			Name:        "俯卧撑",
			Description: "经典的上肢力量训练动作",
			Category:    "上肢",
			MuscleGroup: "胸肌、三头肌",
			Difficulty:  "初级",
			Equipment:   "无器械",
		},
		{
			Name:        "深蹲",
			Description: "经典的下肢力量训练动作",
			Category:    "下肢",
			MuscleGroup: "股四头肌、臀肌",
			Difficulty:  "初级",
			Equipment:   "无器械",
		},
		{
			Name:        "引体向上",
			Description: "经典的上肢力量训练动作",
			Category:    "上肢",
			MuscleGroup: "背肌、二头肌",
			Difficulty:  "中级",
			Equipment:   "单杠",
		},
		{
			Name:        "硬拉",
			Description: "经典的下肢力量训练动作",
			Category:    "下肢",
			MuscleGroup: "臀肌、背肌",
			Difficulty:  "高级",
			Equipment:   "杠铃",
		},
		{
			Name:        "跑步",
			Description: "经典的有氧运动",
			Category:    "有氧",
			MuscleGroup: "全身",
			Difficulty:  "初级",
			Equipment:   "无器械",
		},
	}

	for i := range exercises {
		if err := db.Create(&exercises[i]).Error; err != nil {
			log.Printf("Failed to create exercise %d: %v", i+1, err)
		}
	}

	return exercises
}

func generateWorkouts(db *gorm.DB, users []models.User) []models.Workout {
	workouts := []models.Workout{
		{
			UserID:     users[0].ID,
			Name:       "胸肌训练",
			Type:       "力量训练",
			Duration:   60,
			Calories:   300,
			Difficulty: "中级",
			Notes:      "训练效果很好",
			Rating:     4.5,
		},
		{
			UserID:     users[1].ID,
			Name:       "有氧训练",
			Type:       "有氧训练",
			Duration:   30,
			Calories:   200,
			Difficulty: "初级",
			Notes:      "感觉很累但很爽",
			Rating:     4.0,
		},
		{
			UserID:     users[2].ID,
			Name:       "综合训练",
			Type:       "综合训练",
			Duration:   90,
			Calories:   500,
			Difficulty: "高级",
			Notes:      "挑战性很强",
			Rating:     5.0,
		},
	}

	for i := range workouts {
		if err := db.Create(&workouts[i]).Error; err != nil {
			log.Printf("Failed to create workout %d: %v", i+1, err)
		}
	}

	return workouts
}

func generateCheckins(db *gorm.DB, users []models.User) []models.Checkin {
	checkins := []models.Checkin{
		{
			UserID:     users[0].ID,
			Date:       time.Now().AddDate(0, 0, -1),
			Type:       "训练",
			Notes:      "完成了胸肌训练",
			Mood:       "开心",
			Energy:     8,
			Motivation: 9,
		},
		{
			UserID:     users[1].ID,
			Date:       time.Now().AddDate(0, 0, -2),
			Type:       "有氧",
			Notes:      "完成了有氧训练",
			Mood:       "满意",
			Energy:     7,
			Motivation: 8,
		},
		{
			UserID:     users[2].ID,
			Date:       time.Now().AddDate(0, 0, -3),
			Type:       "综合",
			Notes:      "完成了综合训练",
			Mood:       "兴奋",
			Energy:     9,
			Motivation: 10,
		},
	}

	for i := range checkins {
		if err := db.Create(&checkins[i]).Error; err != nil {
			log.Printf("Failed to create checkin %d: %v", i+1, err)
		}
	}

	return checkins
}

func generateHealthRecords(db *gorm.DB, users []models.User) []models.HealthRecord {
	records := []models.HealthRecord{
		{
			UserID: users[0].ID,
			Type:   "bmi",
			Value:  22.5,
			Notes:  "BMI正常",
		},
		{
			UserID: users[1].ID,
			Type:   "bmi",
			Value:  20.8,
			Notes:  "BMI正常",
		},
		{
			UserID: users[2].ID,
			Type:   "bmi",
			Value:  24.2,
			Notes:  "BMI正常",
		},
	}

	for i := range records {
		if err := db.Create(&records[i]).Error; err != nil {
			log.Printf("Failed to create health record %d: %v", i+1, err)
		}
	}

	return records
}

func generatePosts(db *gorm.DB, users []models.User) []models.Post {
	posts := []models.Post{
		{
			UserID:        users[0].ID,
			Content:       "今天完成了胸肌训练，感觉很好！",
			Type:          "训练",
			IsPublic:      true,
			LikesCount:    5,
			CommentsCount: 2,
			SharesCount:   1,
		},
		{
			UserID:        users[1].ID,
			Content:       "有氧训练让我感觉很有活力",
			Type:          "训练",
			IsPublic:      true,
			LikesCount:    3,
			CommentsCount: 1,
			SharesCount:   0,
		},
		{
			UserID:        users[2].ID,
			Content:       "综合训练挑战性很强，但很有成就感",
			Type:          "训练",
			IsPublic:      true,
			LikesCount:    8,
			CommentsCount: 4,
			SharesCount:   2,
		},
	}

	for i := range posts {
		if err := db.Create(&posts[i]).Error; err != nil {
			log.Printf("Failed to create post %d: %v", i+1, err)
		}
	}

	return posts
}

func generateLikes(db *gorm.DB, users []models.User, posts []models.Post) []models.Like {
	likes := []models.Like{
		{
			UserID: users[1].ID,
			PostID: posts[0].ID,
		},
		{
			UserID: users[2].ID,
			PostID: posts[0].ID,
		},
		{
			UserID: users[0].ID,
			PostID: posts[1].ID,
		},
		{
			UserID: users[2].ID,
			PostID: posts[1].ID,
		},
		{
			UserID: users[0].ID,
			PostID: posts[2].ID,
		},
		{
			UserID: users[1].ID,
			PostID: posts[2].ID,
		},
	}

	for i := range likes {
		if err := db.Create(&likes[i]).Error; err != nil {
			log.Printf("Failed to create like %d: %v", i+1, err)
		}
	}

	return likes
}

func generateComments(db *gorm.DB, users []models.User, posts []models.Post) []models.Comment {
	comments := []models.Comment{
		{
			UserID:  users[1].ID,
			PostID:  posts[0].ID,
			Content: "加油！",
		},
		{
			UserID:  users[2].ID,
			PostID:  posts[0].ID,
			Content: "很棒！",
		},
		{
			UserID:  users[0].ID,
			PostID:  posts[1].ID,
			Content: "继续努力！",
		},
		{
			UserID:  users[0].ID,
			PostID:  posts[2].ID,
			Content: "太厉害了！",
		},
		{
			UserID:  users[1].ID,
			PostID:  posts[2].ID,
			Content: "向你学习！",
		},
	}

	for i := range comments {
		if err := db.Create(&comments[i]).Error; err != nil {
			log.Printf("Failed to create comment %d: %v", i+1, err)
		}
	}

	return comments
}

func generateFollows(db *gorm.DB, users []models.User) []models.Follow {
	follows := []models.Follow{
		{
			FollowerID:  users[0].ID,
			FollowingID: users[1].ID,
		},
		{
			FollowerID:  users[0].ID,
			FollowingID: users[2].ID,
		},
		{
			FollowerID:  users[1].ID,
			FollowingID: users[2].ID,
		},
	}

	for i := range follows {
		if err := db.Create(&follows[i]).Error; err != nil {
			log.Printf("Failed to create follow %d: %v", i+1, err)
		}
	}

	return follows
}

func generateChallenges(db *gorm.DB, users []models.User) []models.Challenge {
	challenges := []models.Challenge{
		{
			Name:        "30天训练挑战",
			Description: "连续30天进行训练",
			Type:        "训练",
			Difficulty:  "中级",
			StartDate:   time.Now().AddDate(0, 0, -10),
			EndDate:     time.Now().AddDate(0, 0, 20),
			IsActive:    true,
		},
		{
			Name:        "100天有氧挑战",
			Description: "连续100天进行有氧运动",
			Type:        "有氧",
			Difficulty:  "高级",
			StartDate:   time.Now().AddDate(0, 0, -20),
			EndDate:     time.Now().AddDate(0, 0, 80),
			IsActive:    true,
		},
	}

	for i := range challenges {
		if err := db.Create(&challenges[i]).Error; err != nil {
			log.Printf("Failed to create challenge %d: %v", i+1, err)
		}
	}

	return challenges
}

func generateChallengeParticipants(db *gorm.DB, users []models.User, challenges []models.Challenge) []models.ChallengeParticipant {
	participants := []models.ChallengeParticipant{
		{
			UserID:      users[0].ID,
			ChallengeID: challenges[0].ID,
			Progress:    10,
		},
		{
			UserID:      users[1].ID,
			ChallengeID: challenges[0].ID,
			Progress:    8,
		},
		{
			UserID:      users[2].ID,
			ChallengeID: challenges[1].ID,
			Progress:    20,
		},
	}

	for i := range participants {
		if err := db.Create(&participants[i]).Error; err != nil {
			log.Printf("Failed to create challenge participant %d: %v", i+1, err)
		}
	}

	return participants
}

func generateNutritionRecords(db *gorm.DB, users []models.User) []models.NutritionRecord {
	records := []models.NutritionRecord{
		{
			UserID:   users[0].ID,
			FoodName: "鸡胸肉",
			Quantity: 100.0,
			Calories: 165.0,
			Protein:  31.0,
			Carbs:    0.0,
			Fat:      3.6,
			Fiber:    0.0,
			Sugar:    0.0,
			Sodium:   74.0,
			MealType: "午餐",
			Notes:    "高蛋白食物",
		},
		{
			UserID:   users[1].ID,
			FoodName: "米饭",
			Quantity: 150.0,
			Calories: 195.0,
			Protein:  4.0,
			Carbs:    45.0,
			Fat:      0.5,
			Fiber:    0.5,
			Sugar:    0.0,
			Sodium:   1.0,
			MealType: "晚餐",
			Notes:    "主食",
		},
		{
			UserID:   users[2].ID,
			FoodName: "鸡蛋",
			Quantity: 2.0,
			Calories: 140.0,
			Protein:  12.0,
			Carbs:    1.0,
			Fat:      10.0,
			Fiber:    0.0,
			Sugar:    1.0,
			Sodium:   140.0,
			MealType: "早餐",
			Notes:    "营养丰富",
		},
	}

	for i := range records {
		if err := db.Create(&records[i]).Error; err != nil {
			log.Printf("Failed to create nutrition record %d: %v", i+1, err)
		}
	}

	return records
}
