package models

import "time"

// UserStats 用户统计信息
type UserStats struct {
	UserID         uint    `json:"user_id"`
	TotalWorkouts  int     `json:"total_workouts"`
	TotalCheckins  int     `json:"total_checkins"`
	CurrentStreak  int     `json:"current_streak"`
	LongestStreak  int     `json:"longest_streak"`
	TotalCalories  int     `json:"total_calories"`
	AverageRating  float64 `json:"average_rating"`
	FollowersCount int     `json:"followers_count"`
	FollowingCount int     `json:"following_count"`
}

// NutritionInfo 营养信息
type NutritionInfo struct {
	FoodName string  `json:"food_name"`
	Quantity float64 `json:"quantity"`
	Calories float64 `json:"calories"`
	Protein  float64 `json:"protein"`
	Carbs    float64 `json:"carbs"`
	Fat      float64 `json:"fat"`
	Fiber    float64 `json:"fiber"`
	Sugar    float64 `json:"sugar"`
	Sodium   float64 `json:"sodium"`
}

// AIWorkoutPlan AI生成的训练计划
type AIWorkoutPlan struct {
	Name        string       `json:"name"`
	Description string       `json:"description"`
	Duration    int          `json:"duration"` // 周数
	Exercises   []AIExercise `json:"exercises"`
	Tips        []string     `json:"tips"`
	GeneratedAt time.Time    `json:"generated_at"`
	AIProvider  string       `json:"ai_provider"`
}

// AIExercise AI训练计划中的动作
type AIExercise struct {
	Name         string `json:"name"`
	Category     string `json:"category"`
	MuscleGroups string `json:"muscle_groups"`
	Equipment    string `json:"equipment"`
	Difficulty   string `json:"difficulty"`
	Instructions string `json:"instructions"`
	Sets         int    `json:"sets"`
	Reps         int    `json:"reps"`
	Duration     int    `json:"duration"`  // 秒
	RestTime     int    `json:"rest_time"` // 秒
	Order        int    `json:"order"`
}

// AIMealPlan AI生成的饮食计划
type AIMealPlan struct {
	Name        string    `json:"name"`
	Description string    `json:"description"`
	Duration    int       `json:"duration"` // 天数
	Meals       []AIMeal  `json:"meals"`
	Tips        []string  `json:"tips"`
	GeneratedAt time.Time `json:"generated_at"`
	AIProvider  string    `json:"ai_provider"`
}

// AIMeal AI饮食计划中的餐食
type AIMeal struct {
	Name         string        `json:"name"`
	Type         string        `json:"type"` // breakfast, lunch, dinner, snack
	Time         string        `json:"time"`
	Foods        []AIFood      `json:"foods"`
	Nutrition    NutritionInfo `json:"nutrition"`
	Instructions string        `json:"instructions"`
}

// AIFood AI饮食计划中的食物
type AIFood struct {
	Name     string  `json:"name"`
	Quantity float64 `json:"quantity"`
	Unit     string  `json:"unit"`
	Calories float64 `json:"calories"`
	Protein  float64 `json:"protein"`
	Carbs    float64 `json:"carbs"`
	Fat      float64 `json:"fat"`
}

// AIResponse AI服务响应
type AIResponse struct {
	Success   bool        `json:"success"`
	Content   string      `json:"content"`
	Provider  string      `json:"provider"`
	Model     string      `json:"model"`
	Timestamp time.Time   `json:"timestamp"`
	Error     string      `json:"error,omitempty"`
	Data      interface{} `json:"data,omitempty"`
}
