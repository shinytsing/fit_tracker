package handlers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

// AIRecommendTraining AI训练推荐
func (h *Handlers) AIRecommendTraining(c *gin.Context) {
	userID := c.GetUint("user_id")
	if userID == 0 {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "用户未登录",
			"code":  "UNAUTHORIZED",
		})
		return
	}

	// 获取用户个人资料
	profile, err := h.UserProfileService.GetProfile(userID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "请先完善个人资料",
			"code":  "PROFILE_REQUIRED",
		})
		return
	}

	// 构建AI推荐请求
	req := struct {
		Goal       string
		Duration   int
		Difficulty string
		Equipment  []string
		FocusAreas []string
	}{
		Goal:       profile.FitnessGoal,
		Duration:   60, // 默认60分钟
		Difficulty: h.getDifficultyByExperience(profile.ExerciseYears),
		Equipment:  []string{"哑铃", "杠铃", "自重"}, // 默认器械
		FocusAreas: []string{"全身"},             // 默认全身训练
	}

	// 调用AI服务生成训练计划
	plan, err := h.generateAITrainingPlan(req, profile)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "AI训练计划生成失败",
			"code":  "AI_GENERATION_FAILED",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "AI训练推荐生成成功",
		"data":    plan,
	})
}

// getDifficultyByExperience 根据运动年限获取难度等级
func (h *Handlers) getDifficultyByExperience(years int) string {
	if years <= 1 {
		return "初级"
	} else if years <= 3 {
		return "中级"
	} else {
		return "高级"
	}
}

// generateAITrainingPlan 生成AI训练计划
func (h *Handlers) generateAITrainingPlan(req interface{}, profile interface{}) (interface{}, error) {
	// 这里应该调用真实的AI服务，现在先返回模拟数据
	plan := map[string]interface{}{
		"id":              1,
		"user_id":         1,
		"name":            "AI个性化训练计划",
		"description":     "根据您的身体数据和健身目标生成的个性化训练计划",
		"date":            time.Now(),
		"duration":        60,
		"status":          "pending",
		"is_ai_generated": true,
		"ai_reason":       "基于您的身高体重、运动年限和健身目标生成",
		"created_at":      time.Now(),
		"updated_at":      time.Now(),
		"exercises": []map[string]interface{}{
			{
				"id":            1,
				"plan_id":       1,
				"name":          "深蹲",
				"description":   "基础腿部训练动作",
				"category":      "腿部",
				"difficulty":    "初级",
				"muscle_groups": []string{"股四头肌", "臀大肌"},
				"equipment":     []string{"自重"},
				"sets": []map[string]interface{}{
					{
						"id":          1,
						"exercise_id": 1,
						"reps":        8,
						"weight":      0,
						"rest_time":   60,
						"order":       1,
						"created_at":  time.Now(),
						"updated_at":  time.Now(),
					},
				},
				"order":      1,
				"created_at": time.Now(),
				"updated_at": time.Now(),
			},
			{
				"id":            2,
				"plan_id":       1,
				"name":          "俯卧撑",
				"description":   "基础胸部训练动作",
				"category":      "胸部",
				"difficulty":    "初级",
				"muscle_groups": []string{"胸大肌", "三角肌前束"},
				"equipment":     []string{"自重"},
				"sets": []map[string]interface{}{
					{
						"id":          2,
						"exercise_id": 2,
						"reps":        8,
						"weight":      0,
						"rest_time":   60,
						"order":       1,
						"created_at":  time.Now(),
						"updated_at":  time.Now(),
					},
				},
				"order":      2,
				"created_at": time.Now(),
				"updated_at": time.Now(),
			},
			{
				"id":            3,
				"plan_id":       1,
				"name":          "引体向上",
				"description":   "背部训练动作",
				"category":      "背部",
				"difficulty":    "初级",
				"muscle_groups": []string{"背阔肌", "肱二头肌"},
				"equipment":     []string{"单杠"},
				"sets": []map[string]interface{}{
					{
						"id":          3,
						"exercise_id": 3,
						"reps":        8,
						"weight":      0,
						"rest_time":   60,
						"order":       1,
						"created_at":  time.Now(),
						"updated_at":  time.Now(),
					},
				},
				"order":      3,
				"created_at": time.Now(),
				"updated_at": time.Now(),
			},
		},
	}

	return plan, nil
}
