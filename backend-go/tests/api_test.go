package tests

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"testing"
	"time"
)

const (
	BaseURL = "http://localhost:8080/api/v1"
)

// 全局测试变量
var (
	authToken         string
	userID            string
	gymID             string
	postID            string
	chatID            string
	planID            string
	buddyGroupID      string
	buddyInvitationID string
	messageID         string
)

// ==================== 用户认证模块测试 ====================

// TestUserRegister 测试用户注册
func TestUserRegister(t *testing.T) {
	url := BaseURL + "/users/register"

	timestamp := time.Now().Unix()
	payload := map[string]interface{}{
		"username": fmt.Sprintf("testuser%d", timestamp%100000000),
		"email":    fmt.Sprintf("test%d@example.com", timestamp%100000000),
		"password": "password123",
		"nickname": "测试用户",
	}

	jsonData, _ := json.Marshal(payload)
	resp, err := http.Post(url, "application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		t.Fatalf("❌ User Register Failed - 请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		t.Errorf("❌ User Register Failed - 期望 201, 实际 %d", resp.StatusCode)
		return
	}

	var response map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&response); err != nil {
		t.Errorf("❌ User Register Failed - 解析响应失败: %v", err)
		return
	}

	if token, ok := response["token"].(string); ok {
		authToken = token
	}
	if user, ok := response["user"].(map[string]interface{}); ok {
		if uid, ok := user["uid"].(float64); ok {
			userID = fmt.Sprintf("%.0f", uid)
		}
	}

	fmt.Printf("✅ User Register OK - 用户ID: %s\n", userID)
}

// TestUserLogin 测试用户登录
func TestUserLogin(t *testing.T) {
	url := BaseURL + "/users/login"

	payload := map[string]interface{}{
		"username": "testuser123456",
		"password": "password123",
	}

	jsonData, _ := json.Marshal(payload)
	resp, err := http.Post(url, "application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		t.Fatalf("❌ User Login Failed - 请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("❌ User Login Failed - 期望 200, 实际 %d", resp.StatusCode)
		return
	}

	fmt.Printf("✅ User Login OK\n")
}

// TestGetUserProfile 测试获取用户资料
func TestGetUserProfile(t *testing.T) {
	if authToken == "" {
		t.Skip("跳过测试 - 没有认证token")
	}

	url := BaseURL + "/users/profile"

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		t.Fatalf("❌ Get User Profile Failed - 创建请求失败: %v", err)
	}

	req.Header.Set("Authorization", "Bearer "+authToken)

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		t.Fatalf("❌ Get User Profile Failed - 请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("❌ Get User Profile Failed - 期望 200, 实际 %d", resp.StatusCode)
		return
	}

	fmt.Printf("✅ Get User Profile OK\n")
}

// ==================== 健身房模块测试 ====================

// TestGetGyms 测试获取健身房列表
func TestGetGyms(t *testing.T) {
	url := BaseURL + "/gyms?page=1&limit=10&latitude=39.9042&longitude=116.4074&radius=5000"

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		t.Fatalf("❌ Get Gyms Failed - 创建请求失败: %v", err)
	}

	if authToken != "" {
		req.Header.Set("Authorization", "Bearer "+authToken)
	}

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		t.Fatalf("❌ Get Gyms Failed - 请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("❌ Get Gyms Failed - 期望 200, 实际 %d", resp.StatusCode)
		return
	}

	fmt.Printf("✅ Get Gyms OK\n")
}

// TestCreateGym 测试创建健身房
func TestCreateGym(t *testing.T) {
	if authToken == "" {
		t.Skip("跳过测试 - 没有认证token")
	}

	url := BaseURL + "/gyms"

	timestamp := time.Now().Unix()
	payload := map[string]interface{}{
		"name":          fmt.Sprintf("测试健身房_%d", timestamp),
		"address":       "北京市朝阳区测试路123号",
		"latitude":      39.9042,
		"longitude":     116.4074,
		"phone":         "010-12345678",
		"description":   "测试用的健身房",
		"facilities":    "器械区,有氧区,瑜伽室",
		"opening_hours": "06:00-22:00",
	}

	jsonData, _ := json.Marshal(payload)
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		t.Fatalf("❌ Create Gym Failed - 创建请求失败: %v", err)
	}

	req.Header.Set("Authorization", "Bearer "+authToken)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		t.Fatalf("❌ Create Gym Failed - 请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		t.Errorf("❌ Create Gym Failed - 期望 201, 实际 %d", resp.StatusCode)
		return
	}

	var response map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&response); err != nil {
		t.Errorf("❌ Create Gym Failed - 解析响应失败: %v", err)
		return
	}

	if data, ok := response["data"].(map[string]interface{}); ok {
		if id, ok := data["id"].(float64); ok {
			gymID = fmt.Sprintf("%.0f", id)
		}
	}

	fmt.Printf("✅ Create Gym OK - 健身房ID: %s\n", gymID)
}

// TestJoinGym 测试申请加入健身房
func TestJoinGym(t *testing.T) {
	if authToken == "" || gymID == "" {
		t.Skip("跳过测试 - 没有认证token或健身房ID")
	}

	url := BaseURL + "/gyms/" + gymID + "/join"

	payload := map[string]interface{}{
		"goal":      "减脂塑形",
		"time_slot": "19:00-21:00",
		"message":   "我想加入这个健身房的搭子组",
	}

	jsonData, _ := json.Marshal(payload)
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		t.Fatalf("❌ Join Gym Failed - 创建请求失败: %v", err)
	}

	req.Header.Set("Authorization", "Bearer "+authToken)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		t.Fatalf("❌ Join Gym Failed - 请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		t.Errorf("❌ Join Gym Failed - 期望 201, 实际 %d", resp.StatusCode)
		return
	}

	fmt.Printf("✅ Join Gym OK\n")
}

// ==================== 搭子模块测试 ====================

// TestGetBuddyRecommendations 测试获取搭子推荐
func TestGetBuddyRecommendations(t *testing.T) {
	if authToken == "" {
		t.Skip("跳过测试 - 没有认证token")
	}

	url := BaseURL + "/buddies/recommendations?page=1&limit=10"

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		t.Fatalf("❌ Get Buddy Recommendations Failed - 创建请求失败: %v", err)
	}

	req.Header.Set("Authorization", "Bearer "+authToken)

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		t.Fatalf("❌ Get Buddy Recommendations Failed - 请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("❌ Get Buddy Recommendations Failed - 期望 200, 实际 %d", resp.StatusCode)
		return
	}

	fmt.Printf("✅ Get Buddy Recommendations OK\n")
}

// TestCreateBuddyGroup 测试创建搭子组
func TestCreateBuddyGroup(t *testing.T) {
	if authToken == "" {
		t.Skip("跳过测试 - 没有认证token")
	}

	url := BaseURL + "/buddies/groups"

	timestamp := time.Now().Unix()
	payload := map[string]interface{}{
		"name":         fmt.Sprintf("测试搭子组_%d", timestamp),
		"description":  "一起健身，互相监督",
		"gym_id":       1,
		"max_members":  6,
		"workout_time": "19:00-21:00",
		"workout_days": []string{"周一", "周三", "周五"},
	}

	jsonData, _ := json.Marshal(payload)
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		t.Fatalf("❌ Create Buddy Group Failed - 创建请求失败: %v", err)
	}

	req.Header.Set("Authorization", "Bearer "+authToken)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		t.Fatalf("❌ Create Buddy Group Failed - 请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		t.Errorf("❌ Create Buddy Group Failed - 期望 201, 实际 %d", resp.StatusCode)
		return
	}

	var response map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&response); err != nil {
		t.Errorf("❌ Create Buddy Group Failed - 解析响应失败: %v", err)
		return
	}

	if data, ok := response["data"].(map[string]interface{}); ok {
		if id, ok := data["id"].(float64); ok {
			buddyGroupID = fmt.Sprintf("%.0f", id)
		}
	}

	fmt.Printf("✅ Create Buddy Group OK - 搭子组ID: %s\n", buddyGroupID)
}

// TestInviteBuddy 测试邀请搭子
func TestInviteBuddy(t *testing.T) {
	if authToken == "" {
		t.Skip("跳过测试 - 没有认证token")
	}

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

	jsonData, _ := json.Marshal(payload)
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		t.Fatalf("❌ Invite Buddy Failed - 创建请求失败: %v", err)
	}

	req.Header.Set("Authorization", "Bearer "+authToken)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		t.Fatalf("❌ Invite Buddy Failed - 请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		t.Errorf("❌ Invite Buddy Failed - 期望 201, 实际 %d", resp.StatusCode)
		return
	}

	var response map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&response); err != nil {
		t.Errorf("❌ Invite Buddy Failed - 解析响应失败: %v", err)
		return
	}

	if data, ok := response["data"].(map[string]interface{}); ok {
		if id, ok := data["invitation_id"].(float64); ok {
			buddyInvitationID = fmt.Sprintf("%.0f", id)
		}
	}

	fmt.Printf("✅ Invite Buddy OK - 邀请ID: %s\n", buddyInvitationID)
}

// ==================== 训练模块测试 ====================

// TestGetTrainingPlans 测试获取训练计划列表
func TestGetTrainingPlans(t *testing.T) {
	if authToken == "" {
		t.Skip("跳过测试 - 没有认证token")
	}

	url := BaseURL + "/training/plans?page=1&limit=10"

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		t.Fatalf("❌ Get Training Plans Failed - 创建请求失败: %v", err)
	}

	req.Header.Set("Authorization", "Bearer "+authToken)

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		t.Fatalf("❌ Get Training Plans Failed - 请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("❌ Get Training Plans Failed - 期望 200, 实际 %d", resp.StatusCode)
		return
	}

	fmt.Printf("✅ Get Training Plans OK\n")
}

// TestCreateTrainingPlan 测试创建训练计划
func TestCreateTrainingPlan(t *testing.T) {
	if authToken == "" {
		t.Skip("跳过测试 - 没有认证token")
	}

	url := BaseURL + "/training/plans"

	timestamp := time.Now().Unix()
	payload := map[string]interface{}{
		"name":        fmt.Sprintf("测试训练计划_%d", timestamp),
		"description": "适合初学者的减脂计划",
		"type":        "custom",
		"duration":    30,
		"frequency":   3,
		"difficulty":  "beginner",
		"goals":       []string{"减脂", "塑形"},
		"exercises":   []string{"深蹲", "俯卧撑", "平板支撑"},
	}

	jsonData, _ := json.Marshal(payload)
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		t.Fatalf("❌ Create Training Plan Failed - 创建请求失败: %v", err)
	}

	req.Header.Set("Authorization", "Bearer "+authToken)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		t.Fatalf("❌ Create Training Plan Failed - 请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		t.Errorf("❌ Create Training Plan Failed - 期望 201, 实际 %d", resp.StatusCode)
		return
	}

	var response map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&response); err != nil {
		t.Errorf("❌ Create Training Plan Failed - 解析响应失败: %v", err)
		return
	}

	if data, ok := response["data"].(map[string]interface{}); ok {
		if id, ok := data["id"].(float64); ok {
			planID = fmt.Sprintf("%.0f", id)
		}
	}

	fmt.Printf("✅ Create Training Plan OK - 计划ID: %s\n", planID)
}

// TestAIGenerateTrainingPlan 测试AI生成训练计划
func TestAIGenerateTrainingPlan(t *testing.T) {
	if authToken == "" {
		t.Skip("跳过测试 - 没有认证token")
	}

	url := BaseURL + "/ai/training-plan"

	payload := map[string]interface{}{
		"goal":           "减脂",
		"duration":       30,
		"difficulty":     "beginner",
		"muscle_groups":  []string{"全身"},
		"available_time": 60,
		"equipment":      []string{"哑铃", "瑜伽垫"},
	}

	jsonData, _ := json.Marshal(payload)
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		t.Fatalf("❌ AI Generate Training Plan Failed - 创建请求失败: %v", err)
	}

	req.Header.Set("Authorization", "Bearer "+authToken)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		t.Fatalf("❌ AI Generate Training Plan Failed - 请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("❌ AI Generate Training Plan Failed - 期望 200, 实际 %d", resp.StatusCode)
		return
	}

	fmt.Printf("✅ AI Generate Training Plan OK\n")
}

// ==================== 社区模块测试 ====================

// TestCreatePost 测试发布动态
func TestCreatePost(t *testing.T) {
	if authToken == "" {
		t.Skip("跳过测试 - 没有认证token")
	}

	url := BaseURL + "/posts"

	timestamp := time.Now().Unix()
	payload := map[string]interface{}{
		"content":   fmt.Sprintf("今天完成了30分钟有氧运动！时间戳：%d", timestamp),
		"images":    []string{"https://example.com/image1.jpg"},
		"type":      "workout",
		"is_public": true,
		"tags":      []string{"有氧", "健身"},
	}

	jsonData, _ := json.Marshal(payload)
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		t.Fatalf("❌ Create Post Failed - 创建请求失败: %v", err)
	}

	req.Header.Set("Authorization", "Bearer "+authToken)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		t.Fatalf("❌ Create Post Failed - 请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		t.Errorf("❌ Create Post Failed - 期望 201, 实际 %d", resp.StatusCode)
		return
	}

	var response map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&response); err != nil {
		t.Errorf("❌ Create Post Failed - 解析响应失败: %v", err)
		return
	}

	if data, ok := response["data"].(map[string]interface{}); ok {
		if id, ok := data["id"].(float64); ok {
			postID = fmt.Sprintf("%.0f", id)
		}
	}

	fmt.Printf("✅ Create Post OK - 动态ID: %s\n", postID)
}

// TestGetPosts 测试获取动态列表
func TestGetPosts(t *testing.T) {
	if authToken == "" {
		t.Skip("跳过测试 - 没有认证token")
	}

	url := BaseURL + "/posts?page=1&limit=20&type=recommend"

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		t.Fatalf("❌ Get Posts Failed - 创建请求失败: %v", err)
	}

	req.Header.Set("Authorization", "Bearer "+authToken)

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		t.Fatalf("❌ Get Posts Failed - 请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("❌ Get Posts Failed - 期望 200, 实际 %d", resp.StatusCode)
		return
	}

	fmt.Printf("✅ Get Posts OK\n")
}

// TestLikePost 测试点赞动态
func TestLikePost(t *testing.T) {
	if authToken == "" || postID == "" {
		t.Skip("跳过测试 - 没有认证token或动态ID")
	}

	url := BaseURL + "/posts/" + postID + "/like"

	req, err := http.NewRequest("POST", url, nil)
	if err != nil {
		t.Fatalf("❌ Like Post Failed - 创建请求失败: %v", err)
	}

	req.Header.Set("Authorization", "Bearer "+authToken)

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		t.Fatalf("❌ Like Post Failed - 请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("❌ Like Post Failed - 期望 200, 实际 %d", resp.StatusCode)
		return
	}

	fmt.Printf("✅ Like Post OK\n")
}

// ==================== 消息模块测试 ====================

// TestCreateChat 测试创建聊天
func TestCreateChat(t *testing.T) {
	if authToken == "" {
		t.Skip("跳过测试 - 没有认证token")
	}

	url := BaseURL + "/messages/chats"

	payload := map[string]interface{}{
		"user_id":         2,
		"initial_message": "你好，我想和你一起健身！",
	}

	jsonData, _ := json.Marshal(payload)
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		t.Fatalf("❌ Create Chat Failed - 创建请求失败: %v", err)
	}

	req.Header.Set("Authorization", "Bearer "+authToken)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		t.Fatalf("❌ Create Chat Failed - 请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		t.Errorf("❌ Create Chat Failed - 期望 201, 实际 %d", resp.StatusCode)
		return
	}

	var response map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&response); err != nil {
		t.Errorf("❌ Create Chat Failed - 解析响应失败: %v", err)
		return
	}

	if data, ok := response["data"].(map[string]interface{}); ok {
		if id, ok := data["chat_id"].(string); ok {
			chatID = id
		}
	}

	fmt.Printf("✅ Create Chat OK - 聊天ID: %s\n", chatID)
}

// TestSendMessage 测试发送消息
func TestSendMessage(t *testing.T) {
	if authToken == "" || chatID == "" {
		t.Skip("跳过测试 - 没有认证token或聊天ID")
	}

	url := BaseURL + "/messages/chats/" + chatID + "/messages"

	payload := map[string]interface{}{
		"type":      "text",
		"content":   "明天一起去健身房吧！",
		"media_url": nil,
	}

	jsonData, _ := json.Marshal(payload)
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		t.Fatalf("❌ Send Message Failed - 创建请求失败: %v", err)
	}

	req.Header.Set("Authorization", "Bearer "+authToken)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		t.Fatalf("❌ Send Message Failed - 请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		t.Errorf("❌ Send Message Failed - 期望 201, 实际 %d", resp.StatusCode)
		return
	}

	var response map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&response); err != nil {
		t.Errorf("❌ Send Message Failed - 解析响应失败: %v", err)
		return
	}

	if data, ok := response["data"].(map[string]interface{}); ok {
		if id, ok := data["id"].(float64); ok {
			messageID = fmt.Sprintf("%.0f", id)
		}
	}

	fmt.Printf("✅ Send Message OK - 消息ID: %s\n", messageID)
}

// TestGetNotifications 测试获取通知
func TestGetNotifications(t *testing.T) {
	if authToken == "" {
		t.Skip("跳过测试 - 没有认证token")
	}

	url := BaseURL + "/messages/notifications?page=1&limit=20"

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		t.Fatalf("❌ Get Notifications Failed - 创建请求失败: %v", err)
	}

	req.Header.Set("Authorization", "Bearer "+authToken)

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		t.Fatalf("❌ Get Notifications Failed - 请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("❌ Get Notifications Failed - 期望 200, 实际 %d", resp.StatusCode)
		return
	}

	fmt.Printf("✅ Get Notifications OK\n")
}

// ==================== 主测试函数 ====================

// TestAll 运行所有测试
func TestAll(t *testing.T) {
	fmt.Println("🚀 开始 Gymates API 测试...")
	fmt.Println(strings.Repeat("=", 50))

	// 1. 用户认证模块
	fmt.Println("📋 1. 用户认证模块测试")
	TestUserRegister(t)
	TestUserLogin(t)
	TestGetUserProfile(t)

	// 2. 健身房模块
	fmt.Println("\n📋 2. 健身房模块测试")
	TestGetGyms(t)
	TestCreateGym(t)
	TestJoinGym(t)

	// 3. 搭子模块
	fmt.Println("\n📋 3. 搭子模块测试")
	TestGetBuddyRecommendations(t)
	TestCreateBuddyGroup(t)
	TestInviteBuddy(t)

	// 4. 训练模块
	fmt.Println("\n📋 4. 训练模块测试")
	TestGetTrainingPlans(t)
	TestCreateTrainingPlan(t)
	TestAIGenerateTrainingPlan(t)

	// 5. 社区模块
	fmt.Println("\n📋 5. 社区模块测试")
	TestCreatePost(t)
	TestGetPosts(t)
	TestLikePost(t)

	// 6. 消息模块
	fmt.Println("\n📋 6. 消息模块测试")
	TestCreateChat(t)
	TestSendMessage(t)
	TestGetNotifications(t)

	fmt.Println("\n" + strings.Repeat("=", 50))
	fmt.Println("🎉 所有测试完成！")
}
