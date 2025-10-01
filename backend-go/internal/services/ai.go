package services

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"fittracker/internal/config"
	"fittracker/internal/models"
)

type AIService struct {
	config *config.Config
}

func NewAIService(cfg *config.Config) *AIService {
	return &AIService{
		config: cfg,
	}
}

// GenerateTrainingPlan 生成AI训练计划
func (s *AIService) GenerateTrainingPlan(req WorkoutPlanRequest) (*models.TrainingPlan, error) {
	// 构建提示词
	prompt := s.buildWorkoutPlanPrompt(req)

	// 调用AI服务
	response, err := s.callAIService(prompt)
	if err != nil {
		return nil, fmt.Errorf("failed to call AI service: %w", err)
	}

	// 解析AI响应并创建训练计划
	plan, err := s.parseWorkoutPlanResponse(response, req)
	if err != nil {
		return nil, fmt.Errorf("failed to parse AI response: %w", err)
	}

	return plan, nil
}

// buildWorkoutPlanPrompt 构建训练计划提示词
func (s *AIService) buildWorkoutPlanPrompt(req WorkoutPlanRequest) string {
	prompt := fmt.Sprintf(`
请为我生成一个个性化的健身训练计划，具体要求如下：

目标：%s
训练周期：%d天
难度等级：%s
健身经验：%s
可用器械：%s
每日训练时间：%d分钟
个人偏好：%s

请按照以下JSON格式返回训练计划：
{
  "title": "训练计划标题",
  "description": "计划描述",
  "difficulty": "难度等级",
  "duration": 训练天数,
  "sessions": [
    {
      "day": 1,
      "title": "训练日标题",
      "exercises": [
        {
          "name": "动作名称",
          "category": "动作分类",
          "sets": 组数,
          "reps": 次数,
          "weight": 重量,
          "duration": 持续时间,
          "rest_time": 休息时间,
          "notes": "注意事项"
        }
      ]
    }
  ]
}

请确保计划科学合理，适合我的水平和目标。
`, req.Goal, req.Duration, req.Difficulty, req.Experience, req.Equipment, req.TimePerDay, req.Preferences)

	return prompt
}

// callAIService 调用AI服务
func (s *AIService) callAIService(prompt string) (string, error) {
	// 优先使用腾讯混元大模型
	if s.config.AI.TencentSecretID != "" && s.config.AI.TencentSecretKey != "" {
		return s.callTencentHunyuan(prompt)
	}

	// 备用DeepSeek
	if s.config.AI.DeepSeekAPIKey != "" {
		return s.callDeepSeek(prompt)
	}

	// 备用Groq
	if s.config.AI.GroqAPIKey != "" {
		return s.callGroq(prompt)
	}

	return "", fmt.Errorf("no AI service configured")
}

// callTencentHunyuan 调用腾讯混元大模型
func (s *AIService) callTencentHunyuan(prompt string) (string, error) {
	// 这里需要实现腾讯混元大模型的API调用
	// 由于需要签名等复杂逻辑，这里返回模拟响应
	return s.getMockWorkoutPlanResponse(), nil
}

// callDeepSeek 调用DeepSeek API
func (s *AIService) callDeepSeek(prompt string) (string, error) {
	url := "https://api.deepseek.com/v1/chat/completions"

	payload := map[string]interface{}{
		"model": "deepseek-chat",
		"messages": []map[string]string{
			{
				"role":    "user",
				"content": prompt,
			},
		},
		"max_tokens":  2000,
		"temperature": 0.7,
	}

	jsonData, err := json.Marshal(payload)
	if err != nil {
		return "", fmt.Errorf("failed to marshal request: %w", err)
	}

	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return "", fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+s.config.AI.DeepSeekAPIKey)

	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return "", fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("failed to read response: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("API request failed with status %d: %s", resp.StatusCode, string(body))
	}

	var response map[string]interface{}
	if err := json.Unmarshal(body, &response); err != nil {
		return "", fmt.Errorf("failed to unmarshal response: %w", err)
	}

	choices, ok := response["choices"].([]interface{})
	if !ok || len(choices) == 0 {
		return "", fmt.Errorf("invalid response format")
	}

	choice, ok := choices[0].(map[string]interface{})
	if !ok {
		return "", fmt.Errorf("invalid choice format")
	}

	message, ok := choice["message"].(map[string]interface{})
	if !ok {
		return "", fmt.Errorf("invalid message format")
	}

	content, ok := message["content"].(string)
	if !ok {
		return "", fmt.Errorf("invalid content format")
	}

	return content, nil
}

// callGroq 调用Groq API
func (s *AIService) callGroq(prompt string) (string, error) {
	url := "https://api.groq.com/openai/v1/chat/completions"

	payload := map[string]interface{}{
		"model": "llama3-8b-8192",
		"messages": []map[string]string{
			{
				"role":    "user",
				"content": prompt,
			},
		},
		"max_tokens":  2000,
		"temperature": 0.7,
	}

	jsonData, err := json.Marshal(payload)
	if err != nil {
		return "", fmt.Errorf("failed to marshal request: %w", err)
	}

	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return "", fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+s.config.AI.GroqAPIKey)

	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return "", fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("failed to read response: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("API request failed with status %d: %s", resp.StatusCode, string(body))
	}

	var response map[string]interface{}
	if err := json.Unmarshal(body, &response); err != nil {
		return "", fmt.Errorf("failed to unmarshal response: %w", err)
	}

	choices, ok := response["choices"].([]interface{})
	if !ok || len(choices) == 0 {
		return "", fmt.Errorf("invalid response format")
	}

	choice, ok := choices[0].(map[string]interface{})
	if !ok {
		return "", fmt.Errorf("invalid choice format")
	}

	message, ok := choice["message"].(map[string]interface{})
	if !ok {
		return "", fmt.Errorf("invalid message format")
	}

	content, ok := message["content"].(string)
	if !ok {
		return "", fmt.Errorf("invalid content format")
	}

	return content, nil
}

// parseWorkoutPlanResponse 解析AI响应
func (s *AIService) parseWorkoutPlanResponse(response string, req WorkoutPlanRequest) (*models.TrainingPlan, error) {
	// 尝试解析JSON响应
	var planData map[string]interface{}
	if err := json.Unmarshal([]byte(response), &planData); err != nil {
		// 如果解析失败，使用模拟数据
		return s.createMockWorkoutPlan(req), nil
	}

	// 创建训练计划
	plan := &models.TrainingPlan{
		UserID:        "1",
		Name:          s.getString(planData, "title", "AI生成训练计划"),
		Description:   s.getString(planData, "description", ""),
		IsAIGenerated: true,
		Date:          time.Now(),
	}

	return plan, nil
}

// createMockWorkoutPlan 创建模拟训练计划
func (s *AIService) createMockWorkoutPlan(req WorkoutPlanRequest) *models.TrainingPlan {
	return &models.TrainingPlan{
		UserID:        "1",
		Name:          fmt.Sprintf("%s - %d天训练计划", req.Goal, req.Duration),
		Description:   fmt.Sprintf("针对%s目标的%d天训练计划，适合%s水平", req.Goal, req.Duration, req.Difficulty),
		IsAIGenerated: true,
		Date:          time.Now(),
	}
}

// getMockWorkoutPlanResponse 获取模拟训练计划响应
func (s *AIService) getMockWorkoutPlanResponse() string {
	return `{
		"title": "减脂塑形 - 30天训练计划",
		"description": "针对减脂塑形目标的30天训练计划，适合中级水平",
		"difficulty": "中级",
		"duration": 30,
		"sessions": [
			{
				"day": 1,
				"title": "全身力量训练",
				"exercises": [
					{
						"name": "深蹲",
						"category": "下肢",
						"sets": 3,
						"reps": 15,
						"weight": 0,
						"duration": 0,
						"rest_time": 60,
						"notes": "保持背部挺直，膝盖不超过脚尖"
					},
					{
						"name": "俯卧撑",
						"category": "上肢",
						"sets": 3,
						"reps": 12,
						"weight": 0,
						"duration": 0,
						"rest_time": 60,
						"notes": "保持身体成一条直线"
					}
				]
			}
		]
	}`
}

// 辅助方法
func (s *AIService) getString(data map[string]interface{}, key, defaultValue string) string {
	if value, ok := data[key].(string); ok {
		return value
	}
	return defaultValue
}

func (s *AIService) getInt(data map[string]interface{}, key string, defaultValue int) int {
	if value, ok := data[key].(float64); ok {
		return int(value)
	}
	return defaultValue
}

// WorkoutPlanRequest 训练计划请求结构
type WorkoutPlanRequest struct {
	Goal        string `json:"goal"`
	Duration    int    `json:"duration"`
	Difficulty  string `json:"difficulty"`
	Experience  string `json:"experience"`
	Equipment   string `json:"equipment"`
	TimePerDay  int    `json:"time_per_day"`
	Preferences string `json:"preferences"`
}
