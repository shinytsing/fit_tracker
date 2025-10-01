package handlers

import (
	"math"
	"net/http"
	"strconv"
	"time"

	"fittracker/internal/domain/models"

	"github.com/gin-gonic/gin"
)

// NutritionRequest 营养分析请求
type NutritionRequest struct {
	FoodName string  `json:"food_name" binding:"required"`
	Quantity float64 `json:"quantity" binding:"required,gt=0"`
	Unit     string  `json:"unit" binding:"required"`
}

// NutritionRecordRequest 营养记录请求
type NutritionRecordRequest struct {
	Date     string  `json:"date" binding:"required"`
	MealType string  `json:"meal_type" binding:"required"`
	FoodName string  `json:"food_name" binding:"required"`
	Quantity float64 `json:"quantity" binding:"required,gt=0"`
	Unit     string  `json:"unit" binding:"required"`
	Notes    string  `json:"notes"`
}

// DailyIntakeResponse 每日摄入响应
type DailyIntakeResponse struct {
	Date     string        `json:"date"`
	Calories float64       `json:"calories"`
	Protein  float64       `json:"protein"`
	Carbs    float64       `json:"carbs"`
	Fat      float64       `json:"fat"`
	Fiber    float64       `json:"fiber"`
	Sugar    float64       `json:"sugar"`
	Sodium   float64       `json:"sodium"`
	Meals    []MealSummary `json:"meals"`
}

// MealSummary 餐食摘要
type MealSummary struct {
	MealType string  `json:"meal_type"`
	Calories float64 `json:"calories"`
	Protein  float64 `json:"protein"`
	Carbs    float64 `json:"carbs"`
	Fat      float64 `json:"fat"`
	Count    int     `json:"count"`
}

// CalculateNutrition 计算营养信息
func (h *Handlers) CalculateNutrition(c *gin.Context) {
	var req NutritionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "请求参数错误",
			"code":    "INVALID_REQUEST",
			"details": err.Error(),
		})
		return
	}

	// 简化的营养数据库（实际应用中应该使用专业的营养数据库）
	nutritionData := getNutritionData(req.FoodName)
	if nutritionData == nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "未找到该食物的营养信息",
			"code":  "FOOD_NOT_FOUND",
		})
		return
	}

	// 根据数量计算营养值
	multiplier := req.Quantity / 100.0 // 假设营养数据是每100g的值

	response := gin.H{
		"food_name": req.FoodName,
		"quantity":  req.Quantity,
		"unit":      req.Unit,
		"nutrition": gin.H{
			"calories": math.Round(nutritionData["calories"].(float64)*multiplier*100) / 100,
			"protein":  math.Round(nutritionData["protein"].(float64)*multiplier*100) / 100,
			"carbs":    math.Round(nutritionData["carbs"].(float64)*multiplier*100) / 100,
			"fat":      math.Round(nutritionData["fat"].(float64)*multiplier*100) / 100,
			"fiber":    math.Round(nutritionData["fiber"].(float64)*multiplier*100) / 100,
			"sugar":    math.Round(nutritionData["sugar"].(float64)*multiplier*100) / 100,
			"sodium":   math.Round(nutritionData["sodium"].(float64)*multiplier*100) / 100,
		},
	}

	c.JSON(http.StatusOK, gin.H{
		"data": response,
	})
}

// SearchFoods 搜索食物
func (h *Handlers) SearchFoods(c *gin.Context) {
	query := c.Query("q")
	if query == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "搜索关键词不能为空",
			"code":  "INVALID_REQUEST",
		})
		return
	}

	// 简化的食物搜索（实际应用中应该使用专业的营养数据库）
	foods := searchFoods(query)

	c.JSON(http.StatusOK, gin.H{
		"data": foods,
	})
}

// GetDailyIntake 获取每日摄入
func (h *Handlers) GetDailyIntake(c *gin.Context) {
	userID, _ := c.Get("user_id")
	dateStr := c.DefaultQuery("date", time.Now().Format("2006-01-02"))

	_, err := time.Parse("2006-01-02", dateStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "日期格式错误",
			"code":  "INVALID_DATE",
		})
		return
	}

	var records []models.NutritionRecord
	if err := h.DB.Where("user_id = ? AND DATE(date) = ?", userID, dateStr).Find(&records).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取营养记录失败",
			"code":  "DATABASE_ERROR",
		})
		return
	}

	// 计算每日总摄入
	var totalCalories, totalProtein, totalCarbs, totalFat, totalFiber, totalSugar, totalSodium float64
	mealSummary := make(map[string]*MealSummary)

	for _, record := range records {
		totalCalories += record.Calories
		totalProtein += record.Protein
		totalCarbs += record.Carbs
		totalFat += record.Fat
		totalFiber += record.Fiber
		totalSugar += record.Sugar
		totalSodium += record.Sodium

		// 按餐食类型分组
		if mealSummary[record.MealType] == nil {
			mealSummary[record.MealType] = &MealSummary{
				MealType: record.MealType,
			}
		}
		mealSummary[record.MealType].Calories += record.Calories
		mealSummary[record.MealType].Protein += record.Protein
		mealSummary[record.MealType].Carbs += record.Carbs
		mealSummary[record.MealType].Fat += record.Fat
		mealSummary[record.MealType].Count++
	}

	// 转换为切片
	var meals []MealSummary
	for _, meal := range mealSummary {
		meals = append(meals, *meal)
	}

	response := DailyIntakeResponse{
		Date:     dateStr,
		Calories: math.Round(totalCalories*100) / 100,
		Protein:  math.Round(totalProtein*100) / 100,
		Carbs:    math.Round(totalCarbs*100) / 100,
		Fat:      math.Round(totalFat*100) / 100,
		Fiber:    math.Round(totalFiber*100) / 100,
		Sugar:    math.Round(totalSugar*100) / 100,
		Sodium:   math.Round(totalSodium*100) / 100,
		Meals:    meals,
	}

	c.JSON(http.StatusOK, gin.H{
		"data": response,
	})
}

// CreateNutritionRecord 创建营养记录
func (h *Handlers) CreateNutritionRecord(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var req NutritionRecordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "请求参数错误",
			"code":    "INVALID_REQUEST",
			"details": err.Error(),
		})
		return
	}

	date, err := time.Parse("2006-01-02", req.Date)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "日期格式错误",
			"code":  "INVALID_DATE",
		})
		return
	}

	// 获取营养信息
	nutritionData := getNutritionData(req.FoodName)
	if nutritionData == nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "未找到该食物的营养信息",
			"code":  "FOOD_NOT_FOUND",
		})
		return
	}

	// 计算营养值
	multiplier := req.Quantity / 100.0

	record := &models.NutritionRecord{
		UserID:   userID.(uint),
		Date:     date,
		MealType: req.MealType,
		FoodName: req.FoodName,
		Quantity: req.Quantity,
		Unit:     req.Unit,
		Calories: nutritionData["calories"].(float64) * multiplier,
		Protein:  nutritionData["protein"].(float64) * multiplier,
		Carbs:    nutritionData["carbs"].(float64) * multiplier,
		Fat:      nutritionData["fat"].(float64) * multiplier,
		Fiber:    nutritionData["fiber"].(float64) * multiplier,
		Sugar:    nutritionData["sugar"].(float64) * multiplier,
		Sodium:   nutritionData["sodium"].(float64) * multiplier,
		Notes:    req.Notes,
	}

	if err := h.DB.Create(record).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "创建营养记录失败",
			"code":  "CREATION_ERROR",
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "营养记录创建成功",
		"data":    record,
	})
}

// GetNutritionRecords 获取营养记录
func (h *Handlers) GetNutritionRecords(c *gin.Context) {
	userID, _ := c.Get("user_id")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	date := c.Query("date")

	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 20
	}

	offset := (page - 1) * limit

	var records []models.NutritionRecord
	query := h.DB.Where("user_id = ?", userID)

	if date != "" {
		query = query.Where("DATE(date) = ?", date)
	}

	var total int64
	query.Model(&models.NutritionRecord{}).Count(&total)

	if err := query.Offset(offset).Limit(limit).Order("date DESC").Find(&records).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取营养记录失败",
			"code":  "DATABASE_ERROR",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": records,
		"pagination": gin.H{
			"page":  page,
			"limit": limit,
			"total": total,
			"pages": int(math.Ceil(float64(total) / float64(limit))),
		},
	})
}

// getNutritionData 获取食物营养数据（简化版本）
func getNutritionData(foodName string) map[string]interface{} {
	nutritionDB := map[string]map[string]interface{}{
		"米饭": {
			"calories": 130.0,
			"protein":  2.7,
			"carbs":    28.0,
			"fat":      0.3,
			"fiber":    0.4,
			"sugar":    0.1,
			"sodium":   1.0,
		},
		"鸡胸肉": {
			"calories": 165.0,
			"protein":  31.0,
			"carbs":    0.0,
			"fat":      3.6,
			"fiber":    0.0,
			"sugar":    0.0,
			"sodium":   74.0,
		},
		"鸡蛋": {
			"calories": 155.0,
			"protein":  13.0,
			"carbs":    1.1,
			"fat":      11.0,
			"fiber":    0.0,
			"sugar":    1.1,
			"sodium":   124.0,
		},
		"牛奶": {
			"calories": 42.0,
			"protein":  3.4,
			"carbs":    5.0,
			"fat":      1.0,
			"fiber":    0.0,
			"sugar":    5.0,
			"sodium":   44.0,
		},
		"苹果": {
			"calories": 52.0,
			"protein":  0.3,
			"carbs":    14.0,
			"fat":      0.2,
			"fiber":    2.4,
			"sugar":    10.0,
			"sodium":   1.0,
		},
		"香蕉": {
			"calories": 89.0,
			"protein":  1.1,
			"carbs":    23.0,
			"fat":      0.3,
			"fiber":    2.6,
			"sugar":    12.0,
			"sodium":   1.0,
		},
		"燕麦": {
			"calories": 389.0,
			"protein":  17.0,
			"carbs":    66.0,
			"fat":      7.0,
			"fiber":    11.0,
			"sugar":    1.0,
			"sodium":   2.0,
		},
		"三文鱼": {
			"calories": 208.0,
			"protein":  25.0,
			"carbs":    0.0,
			"fat":      12.0,
			"fiber":    0.0,
			"sugar":    0.0,
			"sodium":   44.0,
		},
	}

	return nutritionDB[foodName]
}

// searchFoods 搜索食物（简化版本）
func searchFoods(query string) []gin.H {
	foods := []string{"米饭", "鸡胸肉", "鸡蛋", "牛奶", "苹果", "香蕉", "燕麦", "三文鱼", "牛肉", "猪肉", "豆腐", "青菜", "胡萝卜", "土豆", "红薯"}

	var results []gin.H
	for _, food := range foods {
		if contains(food, query) {
			results = append(results, gin.H{
				"name": food,
				"type": "food",
			})
		}
	}

	return results
}

// contains 检查字符串是否包含子字符串
func contains(s, substr string) bool {
	return len(s) >= len(substr) && (s == substr ||
		(len(s) > len(substr) && (s[:len(substr)] == substr ||
			s[len(s)-len(substr):] == substr ||
			containsSubstring(s, substr))))
}

func containsSubstring(s, substr string) bool {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return true
		}
	}
	return false
}
