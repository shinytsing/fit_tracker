package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"testing"
	"time"
)

// 测试配置
const (
	BaseURL      = "http://localhost:8080/api/v1"
	TestPhone    = "13800138000"
	TestPassword = "password123"
)

// 测试数据结构
type TestUser struct {
	ID       int    `json:"id"`
	Phone    string `json:"phone"`
	Nickname string `json:"nickname"`
	Token    string `json:"token"`
}

type APIResponse struct {
	Success bool        `json:"success"`
	Data    interface{} `json:"data"`
	Message string      `json:"message"`
	Error   string      `json:"error"`
}

// 全局测试变量
var (
	testUser  TestUser
	authToken string
	gymID     string
	postID    string
	chatID    string
	planID    string
)

// 辅助函数
func makeRequest(method, url string, body interface{}, token string) (*http.Response, error) {
	var reqBody io.Reader
	if body != nil {
		jsonData, _ := json.Marshal(body)
		reqBody = bytes.NewBuffer(jsonData)
	}

	req, err := http.NewRequest(method, url, reqBody)
	if err != nil {
		return nil, err
	}

	req.Header.Set("Content-Type", "application/json")
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}

	client := &http.Client{Timeout: 30 * time.Second}
	return client.Do(req)
}

func parseResponse(resp *http.Response) (*APIResponse, error) {
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var apiResp APIResponse
	err = json.Unmarshal(body, &apiResp)
	return &apiResp, err
}

// 1. 用户认证模块测试
func TestUserRegistration(t *testing.T) {
	url := BaseURL + "/users/register"
	payload := map[string]interface{}{
		"phone":             TestPhone,
		"password":          TestPassword,
		"verification_code": "123456",
		"nickname":          "测试用户",
	}

	resp, err := makeRequest("POST", url, payload, "")
	if err != nil {
		t.Fatalf("请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		t.Errorf("期望状态码 201, 实际 %d", resp.StatusCode)
	}

	apiResp, err := parseResponse(resp)
	if err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		t.Errorf("注册失败: %s", apiResp.Error)
	}

	// 保存用户信息
	if data, ok := apiResp.Data.(map[string]interface{}); ok {
		if user, ok := data["user"].(map[string]interface{}); ok {
			testUser.ID = int(user["id"].(float64))
			testUser.Phone = user["phone"].(string)
			testUser.Nickname = user["nickname"].(string)
		}
		if token, ok := data["token"].(string); ok {
			testUser.Token = token
			authToken = token
		}
	}

	fmt.Printf("✅ 用户注册测试通过 - 用户ID: %d\n", testUser.ID)
}

func TestUserLogin(t *testing.T) {
	url := BaseURL + "/users/login"
	payload := map[string]interface{}{
		"login":    TestPhone,
		"password": TestPassword,
	}

	resp, err := makeRequest("POST", url, payload, "")
	if err != nil {
		t.Fatalf("请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("期望状态码 200, 实际 %d", resp.StatusCode)
	}

	apiResp, err := parseResponse(resp)
	if err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		t.Errorf("登录失败: %s", apiResp.Error)
	}

	fmt.Printf("✅ 用户登录测试通过\n")
}

func TestGetUserProfile(t *testing.T) {
	url := BaseURL + "/users/profile"

	resp, err := makeRequest("GET", url, nil, authToken)
	if err != nil {
		t.Fatalf("请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("期望状态码 200, 实际 %d", resp.StatusCode)
	}

	apiResp, err := parseResponse(resp)
	if err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		t.Errorf("获取用户资料失败: %s", apiResp.Error)
	}

	fmt.Printf("✅ 获取用户资料测试通过\n")
}

func TestUpdateUserProfile(t *testing.T) {
	url := BaseURL + "/users/profile"
	payload := map[string]interface{}{
		"nickname": "更新后的昵称",
		"bio":      "健身爱好者",
	}

	resp, err := makeRequest("PUT", url, payload, authToken)
	if err != nil {
		t.Fatalf("请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("期望状态码 200, 实际 %d", resp.StatusCode)
	}

	apiResp, err := parseResponse(resp)
	if err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		t.Errorf("更新用户资料失败: %s", apiResp.Error)
	}

	fmt.Printf("✅ 更新用户资料测试通过\n")
}

// 2. 训练模块测试
func TestGetTrainingPlans(t *testing.T) {
	url := BaseURL + "/training/plans?page=1&limit=10"

	resp, err := makeRequest("GET", url, nil, authToken)
	if err != nil {
		t.Fatalf("请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("期望状态码 200, 实际 %d", resp.StatusCode)
	}

	apiResp, err := parseResponse(resp)
	if err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		t.Errorf("获取训练计划失败: %s", apiResp.Error)
	}

	fmt.Printf("✅ 获取训练计划测试通过\n")
}

func TestCreateTrainingPlan(t *testing.T) {
	url := BaseURL + "/training/plans"
	payload := map[string]interface{}{
		"name":        "减脂训练计划",
		"description": "适合初学者的减脂计划",
		"type":        "custom",
		"duration":    30,
		"frequency":   3,
		"difficulty":  "beginner",
		"goals":       []string{"减脂", "塑形"},
		"exercises":   []string{"深蹲", "俯卧撑", "平板支撑"},
	}

	resp, err := makeRequest("POST", url, payload, authToken)
	if err != nil {
		t.Fatalf("请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		t.Errorf("期望状态码 201, 实际 %d", resp.StatusCode)
	}

	apiResp, err := parseResponse(resp)
	if err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		t.Errorf("创建训练计划失败: %s", apiResp.Error)
	}

	// 保存计划ID
	if data, ok := apiResp.Data.(map[string]interface{}); ok {
		if id, ok := data["id"].(string); ok {
			planID = id
		}
	}

	fmt.Printf("✅ 创建训练计划测试通过 - 计划ID: %s\n", planID)
}

func TestAIGenerateTrainingPlan(t *testing.T) {
	url := BaseURL + "/ai/training-plan"
	payload := map[string]interface{}{
		"goal":           "减脂",
		"duration":       30,
		"difficulty":     "beginner",
		"muscle_groups":  []string{"全身"},
		"available_time": 60,
		"equipment":      []string{"哑铃", "瑜伽垫"},
	}

	resp, err := makeRequest("POST", url, payload, authToken)
	if err != nil {
		t.Fatalf("请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("期望状态码 200, 实际 %d", resp.StatusCode)
	}

	apiResp, err := parseResponse(resp)
	if err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		t.Errorf("AI生成训练计划失败: %s", apiResp.Error)
	}

	fmt.Printf("✅ AI生成训练计划测试通过\n")
}

// 3. 社区模块测试
func TestCreatePost(t *testing.T) {
	url := BaseURL + "/posts"
	payload := map[string]interface{}{
		"content":   "今天完成了30分钟有氧运动！",
		"images":    []string{"https://example.com/image1.jpg"},
		"type":      "workout",
		"is_public": true,
		"tags":      []string{"有氧", "健身"},
	}

	resp, err := makeRequest("POST", url, payload, authToken)
	if err != nil {
		t.Fatalf("请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		t.Errorf("期望状态码 201, 实际 %d", resp.StatusCode)
	}

	apiResp, err := parseResponse(resp)
	if err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		t.Errorf("发布动态失败: %s", apiResp.Error)
	}

	// 保存动态ID
	if data, ok := apiResp.Data.(map[string]interface{}); ok {
		if id, ok := data["id"].(string); ok {
			postID = id
		}
	}

	fmt.Printf("✅ 发布动态测试通过 - 动态ID: %s\n", postID)
}

func TestGetPosts(t *testing.T) {
	url := BaseURL + "/posts?page=1&limit=20&type=recommend"

	resp, err := makeRequest("GET", url, nil, authToken)
	if err != nil {
		t.Fatalf("请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("期望状态码 200, 实际 %d", resp.StatusCode)
	}

	apiResp, err := parseResponse(resp)
	if err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		t.Errorf("获取动态列表失败: %s", apiResp.Error)
	}

	fmt.Printf("✅ 获取动态列表测试通过\n")
}

func TestLikePost(t *testing.T) {
	if postID == "" {
		t.Skip("跳过点赞测试 - 没有可用的动态ID")
	}

	url := BaseURL + "/posts/" + postID + "/like"

	resp, err := makeRequest("POST", url, nil, authToken)
	if err != nil {
		t.Fatalf("请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("期望状态码 200, 实际 %d", resp.StatusCode)
	}

	apiResp, err := parseResponse(resp)
	if err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		t.Errorf("点赞动态失败: %s", apiResp.Error)
	}

	fmt.Printf("✅ 点赞动态测试通过\n")
}

func TestCommentPost(t *testing.T) {
	if postID == "" {
		t.Skip("跳过评论测试 - 没有可用的动态ID")
	}

	url := BaseURL + "/posts/" + postID + "/comment"
	payload := map[string]interface{}{
		"content": "很棒！继续加油！",
	}

	resp, err := makeRequest("POST", url, payload, authToken)
	if err != nil {
		t.Fatalf("请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		t.Errorf("期望状态码 201, 实际 %d", resp.StatusCode)
	}

	apiResp, err := parseResponse(resp)
	if err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		t.Errorf("评论动态失败: %s", apiResp.Error)
	}

	fmt.Printf("✅ 评论动态测试通过\n")
}

// 4. 搭子模块测试
func TestGetBuddyRecommendations(t *testing.T) {
	url := BaseURL + "/buddies/recommendations?page=1&limit=10"

	resp, err := makeRequest("GET", url, nil, authToken)
	if err != nil {
		t.Fatalf("请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("期望状态码 200, 实际 %d", resp.StatusCode)
	}

	apiResp, err := parseResponse(resp)
	if err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		t.Errorf("获取搭子推荐失败: %s", apiResp.Error)
	}

	fmt.Printf("✅ 获取搭子推荐测试通过\n")
}

func TestCreateBuddyGroup(t *testing.T) {
	url := BaseURL + "/buddies/groups"
	payload := map[string]interface{}{
		"name":         "朝阳健身房搭子组",
		"description":  "一起健身，互相监督",
		"gym_id":       1,
		"max_members":  6,
		"workout_time": "19:00-21:00",
		"workout_days": []string{"周一", "周三", "周五"},
	}

	resp, err := makeRequest("POST", url, payload, authToken)
	if err != nil {
		t.Fatalf("请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		t.Errorf("期望状态码 201, 实际 %d", resp.StatusCode)
	}

	apiResp, err := parseResponse(resp)
	if err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		t.Errorf("创建搭子组失败: %s", apiResp.Error)
	}

	fmt.Printf("✅ 创建搭子组测试通过\n")
}

func TestInviteBuddy(t *testing.T) {
	url := BaseURL + "/buddies/invite"
	payload := map[string]interface{}{
		"buddy_id": 2,
		"message":  "你好，我想和你一起健身！",
		"workout_preferences": map[string]interface{}{
			"time":     "晚上7-9点",
			"location": "健身房",
			"type":     "力量训练",
		},
	}

	resp, err := makeRequest("POST", url, payload, authToken)
	if err != nil {
		t.Fatalf("请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		t.Errorf("期望状态码 201, 实际 %d", resp.StatusCode)
	}

	apiResp, err := parseResponse(resp)
	if err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		t.Errorf("邀请搭子失败: %s", apiResp.Error)
	}

	fmt.Printf("✅ 邀请搭子测试通过\n")
}

// 5. 消息模块测试
func TestCreateChat(t *testing.T) {
	url := BaseURL + "/messages/chats"
	payload := map[string]interface{}{
		"user_id":         2,
		"initial_message": "你好，我想和你一起健身！",
	}

	resp, err := makeRequest("POST", url, payload, authToken)
	if err != nil {
		t.Fatalf("请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		t.Errorf("期望状态码 201, 实际 %d", resp.StatusCode)
	}

	apiResp, err := parseResponse(resp)
	if err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		t.Errorf("创建聊天失败: %s", apiResp.Error)
	}

	// 保存聊天ID
	if data, ok := apiResp.Data.(map[string]interface{}); ok {
		if id, ok := data["chat_id"].(string); ok {
			chatID = id
		}
	}

	fmt.Printf("✅ 创建聊天测试通过 - 聊天ID: %s\n", chatID)
}

func TestSendMessage(t *testing.T) {
	if chatID == "" {
		t.Skip("跳过发送消息测试 - 没有可用的聊天ID")
	}

	url := BaseURL + "/messages/chats/" + chatID + "/messages"
	payload := map[string]interface{}{
		"type":      "text",
		"content":   "明天一起去健身房吧！",
		"media_url": nil,
	}

	resp, err := makeRequest("POST", url, payload, authToken)
	if err != nil {
		t.Fatalf("请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		t.Errorf("期望状态码 201, 实际 %d", resp.StatusCode)
	}

	apiResp, err := parseResponse(resp)
	if err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		t.Errorf("发送消息失败: %s", apiResp.Error)
	}

	fmt.Printf("✅ 发送消息测试通过\n")
}

func TestGetNotifications(t *testing.T) {
	url := BaseURL + "/messages/notifications?page=1&limit=20"

	resp, err := makeRequest("GET", url, nil, authToken)
	if err != nil {
		t.Fatalf("请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("期望状态码 200, 实际 %d", resp.StatusCode)
	}

	apiResp, err := parseResponse(resp)
	if err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		t.Errorf("获取通知失败: %s", apiResp.Error)
	}

	fmt.Printf("✅ 获取通知测试通过\n")
}

// 6. 健身房模块测试
func TestGetGyms(t *testing.T) {
	url := BaseURL + "/gyms?page=1&limit=20&latitude=39.9042&longitude=116.4074&radius=5000"

	resp, err := makeRequest("GET", url, nil, authToken)
	if err != nil {
		t.Fatalf("请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("期望状态码 200, 实际 %d", resp.StatusCode)
	}

	apiResp, err := parseResponse(resp)
	if err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		t.Errorf("获取健身房列表失败: %s", apiResp.Error)
	}

	fmt.Printf("✅ 获取健身房列表测试通过\n")
}

func TestCreateGym(t *testing.T) {
	url := BaseURL + "/gyms"
	payload := map[string]interface{}{
		"name":          "朝阳健身房",
		"address":       "北京市朝阳区xxx路xxx号",
		"latitude":      39.9042,
		"longitude":     116.4074,
		"phone":         "010-12345678",
		"description":   "设备齐全的现代化健身房",
		"facilities":    []string{"器械区", "有氧区", "瑜伽室"},
		"opening_hours": "06:00-22:00",
	}

	resp, err := makeRequest("POST", url, payload, authToken)
	if err != nil {
		t.Fatalf("请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		t.Errorf("期望状态码 201, 实际 %d", resp.StatusCode)
	}

	apiResp, err := parseResponse(resp)
	if err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		t.Errorf("创建健身房失败: %s", apiResp.Error)
	}

	// 保存健身房ID
	if data, ok := apiResp.Data.(map[string]interface{}); ok {
		if id, ok := data["id"].(string); ok {
			gymID = id
		}
	}

	fmt.Printf("✅ 创建健身房测试通过 - 健身房ID: %s\n", gymID)
}

func TestJoinGym(t *testing.T) {
	if gymID == "" {
		t.Skip("跳过加入健身房测试 - 没有可用的健身房ID")
	}

	url := BaseURL + "/gyms/" + gymID + "/join"
	payload := map[string]interface{}{
		"goal":      "减脂塑形",
		"time_slot": "19:00-21:00",
		"message":   "我想加入这个健身房的搭子组",
	}

	resp, err := makeRequest("POST", url, payload, authToken)
	if err != nil {
		t.Fatalf("请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		t.Errorf("期望状态码 201, 实际 %d", resp.StatusCode)
	}

	apiResp, err := parseResponse(resp)
	if err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		t.Errorf("申请加入健身房失败: %s", apiResp.Error)
	}

	fmt.Printf("✅ 申请加入健身房测试通过\n")
}

// 7. AI接口测试
func TestAIChat(t *testing.T) {
	url := BaseURL + "/ai/chat"
	payload := map[string]interface{}{
		"message": "如何正确做深蹲？",
		"context": map[string]interface{}{
			"user_level":        "beginner",
			"previous_messages": []interface{}{},
		},
	}

	resp, err := makeRequest("POST", url, payload, authToken)
	if err != nil {
		t.Fatalf("请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("期望状态码 200, 实际 %d", resp.StatusCode)
	}

	apiResp, err := parseResponse(resp)
	if err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		t.Errorf("AI聊天失败: %s", apiResp.Error)
	}

	fmt.Printf("✅ AI聊天测试通过\n")
}

func TestExerciseAnalyze(t *testing.T) {
	url := BaseURL + "/ai/exercise/analyze"
	payload := map[string]interface{}{
		"exercise_name": "深蹲",
		"form_data": map[string]interface{}{
			"knee_angle": 90,
			"back_angle": 45,
			"weight":     50,
		},
		"video_url": "https://example.com/form_video.mp4",
	}

	resp, err := makeRequest("POST", url, payload, authToken)
	if err != nil {
		t.Fatalf("请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("期望状态码 200, 实际 %d", resp.StatusCode)
	}

	apiResp, err := parseResponse(resp)
	if err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		t.Errorf("动作分析失败: %s", apiResp.Error)
	}

	fmt.Printf("✅ 动作分析测试通过\n")
}

// 8. 统计模块测试
func TestGetPersonalStats(t *testing.T) {
	url := BaseURL + "/stats/personal?period=month"

	resp, err := makeRequest("GET", url, nil, authToken)
	if err != nil {
		t.Fatalf("请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("期望状态码 200, 实际 %d", resp.StatusCode)
	}

	apiResp, err := parseResponse(resp)
	if err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		t.Errorf("获取个人统计失败: %s", apiResp.Error)
	}

	fmt.Printf("✅ 获取个人统计测试通过\n")
}

func TestGetTrainingStats(t *testing.T) {
	url := BaseURL + "/stats/training?period=week&start_date=2024-01-01&end_date=2024-01-07"

	resp, err := makeRequest("GET", url, nil, authToken)
	if err != nil {
		t.Fatalf("请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("期望状态码 200, 实际 %d", resp.StatusCode)
	}

	apiResp, err := parseResponse(resp)
	if err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		t.Errorf("获取训练统计失败: %s", apiResp.Error)
	}

	fmt.Printf("✅ 获取训练统计测试通过\n")
}

func TestGetLeaderboard(t *testing.T) {
	url := BaseURL + "/stats/leaderboard?type=weekly&category=calories"

	resp, err := makeRequest("GET", url, nil, authToken)
	if err != nil {
		t.Fatalf("请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("期望状态码 200, 实际 %d", resp.StatusCode)
	}

	apiResp, err := parseResponse(resp)
	if err != nil {
		t.Fatalf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		t.Errorf("获取排行榜失败: %s", apiResp.Error)
	}

	fmt.Printf("✅ 获取排行榜测试通过\n")
}

// 主测试函数
func TestAll(t *testing.T) {
	fmt.Println("🚀 开始 Gymates API 测试...")
	fmt.Println("=" * 50)

	// 1. 用户认证模块
	fmt.Println("📋 1. 用户认证模块测试")
	TestUserRegistration(t)
	TestUserLogin(t)
	TestGetUserProfile(t)
	TestUpdateUserProfile(t)

	// 2. 训练模块
	fmt.Println("\n📋 2. 训练模块测试")
	TestGetTrainingPlans(t)
	TestCreateTrainingPlan(t)
	TestAIGenerateTrainingPlan(t)

	// 3. 社区模块
	fmt.Println("\n📋 3. 社区模块测试")
	TestCreatePost(t)
	TestGetPosts(t)
	TestLikePost(t)
	TestCommentPost(t)

	// 4. 搭子模块
	fmt.Println("\n📋 4. 搭子模块测试")
	TestGetBuddyRecommendations(t)
	TestCreateBuddyGroup(t)
	TestInviteBuddy(t)

	// 5. 消息模块
	fmt.Println("\n📋 5. 消息模块测试")
	TestCreateChat(t)
	TestSendMessage(t)
	TestGetNotifications(t)

	// 6. 健身房模块
	fmt.Println("\n📋 6. 健身房模块测试")
	TestGetGyms(t)
	TestCreateGym(t)
	TestJoinGym(t)

	// 7. AI接口
	fmt.Println("\n📋 7. AI接口测试")
	TestAIChat(t)
	TestExerciseAnalyze(t)

	// 8. 统计模块
	fmt.Println("\n📋 8. 统计模块测试")
	TestGetPersonalStats(t)
	TestGetTrainingStats(t)
	TestGetLeaderboard(t)

	fmt.Println("\n" + "="*50)
	fmt.Println("🎉 所有测试完成！")
}

// 运行测试
func main() {
	// 这里可以添加命令行参数解析
	fmt.Println("Gymates API 测试工具")
	fmt.Println("使用方法: go test -v")
}
