package handlers

import (
	"log"
	"math"
	"net/http"
	"time"

	"fittracker/internal/domain/models"

	"github.com/gin-gonic/gin"
)

// BMIRequest BMI计算请求
type BMIRequest struct {
	Height float64 `json:"height" binding:"required,gt=0"` // 身高(cm)
	Weight float64 `json:"weight" binding:"required,gt=0"` // 体重(kg)
	Age    int     `json:"age" binding:"required,gt=0"`    // 年龄
	Gender string  `json:"gender" binding:"required"`      // 性别: male/female
}

// BMIResponse BMI计算结果
type BMIResponse struct {
	BMI         float64 `json:"bmi"`
	Category    string  `json:"category"`
	IdealWeight struct {
		Min float64 `json:"min"`
		Max float64 `json:"max"`
	} `json:"ideal_weight"`
	BodyFat float64 `json:"body_fat"`
	BMR     float64 `json:"bmr"`
	TDEE    float64 `json:"tdee"`
}

// CalculateBMI 计算BMI
func (h *Handlers) CalculateBMI(c *gin.Context) {
	var req BMIRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "请求参数错误",
			"code":    "INVALID_REQUEST",
			"details": err.Error(),
		})
		return
	}

	// 参数验证
	if req.Height <= 0 || req.Weight <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "身高和体重必须大于0",
			"code":  "INVALID_PARAMETERS",
		})
		return
	}

	// 防止除零错误和数值溢出
	if req.Height < 50 || req.Height > 300 || req.Weight < 10 || req.Weight > 500 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "身高应在50-300cm之间，体重应在10-500kg之间",
			"code":  "PARAMETER_OUT_OF_RANGE",
		})
		return
	}

	// 计算BMI - 使用更安全的计算方式
	heightM := req.Height / 100.0
	if heightM <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "身高数据无效",
			"code":  "INVALID_HEIGHT",
		})
		return
	}

	bmi := req.Weight / (heightM * heightM)

	// 判断BMI分类
	var category string
	switch {
	case bmi < 18.5:
		category = "偏瘦"
	case bmi < 24:
		category = "正常"
	case bmi < 28:
		category = "偏胖"
	default:
		category = "肥胖"
	}

	// 计算理想体重范围
	idealMin := 18.5 * heightM * heightM
	idealMax := 24 * heightM * heightM

	// 计算体脂率 (简化公式)
	var bodyFat float64
	if req.Gender == "male" {
		bodyFat = (1.20 * bmi) + (0.23 * float64(req.Age)) - 16.2
	} else {
		bodyFat = (1.20 * bmi) + (0.23 * float64(req.Age)) - 5.4
	}

	// 计算基础代谢率 (BMR)
	var bmr float64
	if req.Gender == "male" {
		bmr = 88.362 + (13.397 * req.Weight) + (4.799 * req.Height) - (5.677 * float64(req.Age))
	} else {
		bmr = 447.593 + (9.247 * req.Weight) + (3.098 * req.Height) - (4.330 * float64(req.Age))
	}

	// 计算总消耗量 (TDEE) - 假设中等活动水平
	tdee := bmr * 1.55

	// 检查计算结果是否有效
	if math.IsNaN(bmi) || math.IsInf(bmi, 0) {
		log.Printf("BMI calculation resulted in invalid value: %f", bmi)
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "BMI计算结果无效",
			"code":  "CALCULATION_ERROR",
		})
		return
	}

	response := BMIResponse{
		BMI:      math.Round(bmi*100) / 100,
		Category: category,
		IdealWeight: struct {
			Min float64 `json:"min"`
			Max float64 `json:"max"`
		}{
			Min: math.Round(idealMin*100) / 100,
			Max: math.Round(idealMax*100) / 100,
		},
		BodyFat: math.Round(bodyFat*100) / 100,
		BMR:     math.Round(bmr*100) / 100,
		TDEE:    math.Round(tdee*100) / 100,
	}

	log.Printf("BMI calculation successful: height=%.1f, weight=%.1f, bmi=%.2f, category=%s",
		req.Height, req.Weight, response.BMI, response.Category)

	c.JSON(http.StatusOK, gin.H{
		"data": response,
	})
}

// CreateBMIRecord 创建BMI记录
func (h *Handlers) CreateBMIRecord(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var req struct {
		Height float64 `json:"height" binding:"required,gt=0"`
		Weight float64 `json:"weight" binding:"required,gt=0"`
		Age    int     `json:"age" binding:"required,gt=0"`
		Gender string  `json:"gender" binding:"required"`
		Notes  string  `json:"notes"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "请求参数错误",
			"code":    "INVALID_REQUEST",
			"details": err.Error(),
		})
		return
	}

	// 计算BMI
	heightM := req.Height / 100
	bmi := req.Weight / (heightM * heightM)

	// 创建健康记录
	record := &models.HealthRecord{
		UserID: userID.(uint),
		Date:   time.Now(),
		Type:   "bmi",
		Value:  bmi,
		Unit:   "kg/m²",
		Notes:  req.Notes,
	}

	if err := h.DB.Create(record).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "创建BMI记录失败",
			"code":  "CREATION_ERROR",
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "BMI记录创建成功",
		"data":    record,
	})
}

// GetBMIRecords 获取BMI记录
func (h *Handlers) GetBMIRecords(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var records []models.HealthRecord
	if err := h.DB.Where("user_id = ? AND type = ?", userID, "bmi").Order("date DESC").Find(&records).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "获取BMI记录失败",
			"code":  "DATABASE_ERROR",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": records,
	})
}
