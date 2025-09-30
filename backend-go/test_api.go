package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

const baseURL = "http://localhost:8080/api/v1"

type AuthResponse struct {
	Message string `json:"message"`
	Data    struct {
		Token     string `json:"token"`
		User      User   `json:"user"`
		ExpiresAt string `json:"expires_at"`
	} `json:"data"`
}

type User struct {
	ID            int    `json:"id"`
	Username      string `json:"username"`
	Email         string `json:"email"`
	FirstName     string `json:"first_name"`
	LastName      string `json:"last_name"`
	TotalWorkouts int    `json:"total_workouts"`
	TotalCheckins int    `json:"total_checkins"`
	CurrentStreak int    `json:"current_streak"`
	LongestStreak int    `json:"longest_streak"`
}

type Workout struct {
	ID         int     `json:"id"`
	UserID     int     `json:"user_id"`
	Name       string  `json:"name"`
	Type       string  `json:"type"`
	Duration   int     `json:"duration"`
	Calories   int     `json:"calories"`
	Difficulty string  `json:"difficulty"`
	Notes      string  `json:"notes"`
	Rating     float64 `json:"rating"`
}

type Post struct {
	ID            int    `json:"id"`
	UserID        int    `json:"user_id"`
	Content       string `json:"content"`
	LikesCount    int    `json:"likes_count"`
	CommentsCount int    `json:"comments_count"`
	IsPublic      bool   `json:"is_public"`
}

var token string

func main() {
	fmt.Println("🚀 开始测试 FitTracker API...")

	// 测试健康检查
	testHealthCheck()

	// 测试用户注册
	testRegister()

	// 测试用户登录
	testLogin()

	// 测试获取用户资料
	testGetProfile()

	// 测试创建训练记录
	testCreateWorkout()

	// 测试获取训练记录
	testGetWorkouts()

	// 测试BMI计算
	testCalculateBMI()

	// 测试发布动态
	testCreatePost()

	// 测试获取动态
	testGetPosts()

	// 测试签到
	testCreateCheckin()

	// 测试获取签到记录
	testGetCheckins()

	fmt.Println("✅ 所有测试完成！")
}

func testHealthCheck() {
	fmt.Println("\n📋 测试健康检查...")

	resp, err := http.Get(baseURL + "/health")
	if err != nil {
		fmt.Printf("❌ 健康检查失败: %v\n", err)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode == 200 {
		fmt.Println("✅ 健康检查通过")
	} else {
		fmt.Printf("❌ 健康检查失败，状态码: %d\n", resp.StatusCode)
	}
}

func testRegister() {
	fmt.Println("\n👤 测试用户注册...")

	registerData := map[string]interface{}{
		"username":   "testuser",
		"email":      "test@example.com",
		"password":   "password123",
		"first_name": "Test",
		"last_name":  "User",
	}

	jsonData, _ := json.Marshal(registerData)
	resp, err := http.Post(baseURL+"/auth/register", "application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		fmt.Printf("❌ 注册失败: %v\n", err)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode == 201 {
		fmt.Println("✅ 用户注册成功")
	} else {
		body, _ := io.ReadAll(resp.Body)
		fmt.Printf("❌ 注册失败，状态码: %d, 响应: %s\n", resp.StatusCode, string(body))
	}
}

func testLogin() {
	fmt.Println("\n🔐 测试用户登录...")

	loginData := map[string]interface{}{
		"email":    "test@example.com",
		"password": "password123",
	}

	jsonData, _ := json.Marshal(loginData)
	resp, err := http.Post(baseURL+"/auth/login", "application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		fmt.Printf("❌ 登录失败: %v\n", err)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode == 200 {
		var authResp AuthResponse
		json.NewDecoder(resp.Body).Decode(&authResp)
		token = authResp.Data.Token
		fmt.Println("✅ 用户登录成功")
		fmt.Printf("   用户: %s (%s)\n", authResp.Data.User.Username, authResp.Data.User.Email)
	} else {
		body, _ := io.ReadAll(resp.Body)
		fmt.Printf("❌ 登录失败，状态码: %d, 响应: %s\n", resp.StatusCode, string(body))
	}
}

func testGetProfile() {
	fmt.Println("\n👤 测试获取用户资料...")

	if token == "" {
		fmt.Println("❌ 未登录，跳过测试")
		return
	}

	req, _ := http.NewRequest("GET", baseURL+"/users/profile", nil)
	req.Header.Set("Authorization", "Bearer "+token)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Printf("❌ 获取用户资料失败: %v\n", err)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode == 200 {
		fmt.Println("✅ 获取用户资料成功")
	} else {
		body, _ := io.ReadAll(resp.Body)
		fmt.Printf("❌ 获取用户资料失败，状态码: %d, 响应: %s\n", resp.StatusCode, string(body))
	}
}

func testCreateWorkout() {
	fmt.Println("\n💪 测试创建训练记录...")

	if token == "" {
		fmt.Println("❌ 未登录，跳过测试")
		return
	}

	workoutData := map[string]interface{}{
		"name":       "测试训练",
		"type":       "力量训练",
		"duration":   30,
		"calories":   200,
		"difficulty": "初级",
		"notes":      "API测试训练",
		"rating":     4.5,
	}

	jsonData, _ := json.Marshal(workoutData)
	req, _ := http.NewRequest("POST", baseURL+"/workouts", bytes.NewBuffer(jsonData))
	req.Header.Set("Authorization", "Bearer "+token)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Printf("❌ 创建训练记录失败: %v\n", err)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode == 201 {
		fmt.Println("✅ 创建训练记录成功")
	} else {
		body, _ := io.ReadAll(resp.Body)
		fmt.Printf("❌ 创建训练记录失败，状态码: %d, 响应: %s\n", resp.StatusCode, string(body))
	}
}

func testGetWorkouts() {
	fmt.Println("\n📋 测试获取训练记录...")

	if token == "" {
		fmt.Println("❌ 未登录，跳过测试")
		return
	}

	req, _ := http.NewRequest("GET", baseURL+"/workouts?page=1&limit=10", nil)
	req.Header.Set("Authorization", "Bearer "+token)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Printf("❌ 获取训练记录失败: %v\n", err)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode == 200 {
		fmt.Println("✅ 获取训练记录成功")
	} else {
		body, _ := io.ReadAll(resp.Body)
		fmt.Printf("❌ 获取训练记录失败，状态码: %d, 响应: %s\n", resp.StatusCode, string(body))
	}
}

func testCalculateBMI() {
	fmt.Println("\n📊 测试BMI计算...")

	if token == "" {
		fmt.Println("❌ 未登录，跳过测试")
		return
	}

	bmiData := map[string]interface{}{
		"height": 175,
		"weight": 70,
		"age":    25,
		"gender": "male",
	}

	jsonData, _ := json.Marshal(bmiData)
	req, _ := http.NewRequest("POST", baseURL+"/bmi/calculate", bytes.NewBuffer(jsonData))
	req.Header.Set("Authorization", "Bearer "+token)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Printf("❌ BMI计算失败: %v\n", err)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode == 200 {
		fmt.Println("✅ BMI计算成功")
	} else {
		body, _ := io.ReadAll(resp.Body)
		fmt.Printf("❌ BMI计算失败，状态码: %d, 响应: %s\n", resp.StatusCode, string(body))
	}
}

func testCreatePost() {
	fmt.Println("\n📝 测试发布动态...")

	if token == "" {
		fmt.Println("❌ 未登录，跳过测试")
		return
	}

	postData := map[string]interface{}{
		"content":   "今天完成了测试训练，感觉很好！",
		"type":      "训练",
		"is_public": true,
	}

	jsonData, _ := json.Marshal(postData)
	req, _ := http.NewRequest("POST", baseURL+"/community/posts", bytes.NewBuffer(jsonData))
	req.Header.Set("Authorization", "Bearer "+token)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Printf("❌ 发布动态失败: %v\n", err)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode == 201 {
		fmt.Println("✅ 发布动态成功")
	} else {
		body, _ := io.ReadAll(resp.Body)
		fmt.Printf("❌ 发布动态失败，状态码: %d, 响应: %s\n", resp.StatusCode, string(body))
	}
}

func testGetPosts() {
	fmt.Println("\n📋 测试获取动态...")

	if token == "" {
		fmt.Println("❌ 未登录，跳过测试")
		return
	}

	req, _ := http.NewRequest("GET", baseURL+"/community/posts?page=1&limit=10", nil)
	req.Header.Set("Authorization", "Bearer "+token)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Printf("❌ 获取动态失败: %v\n", err)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode == 200 {
		fmt.Println("✅ 获取动态成功")
	} else {
		body, _ := io.ReadAll(resp.Body)
		fmt.Printf("❌ 获取动态失败，状态码: %d, 响应: %s\n", resp.StatusCode, string(body))
	}
}

func testCreateCheckin() {
	fmt.Println("\n✅ 测试签到...")

	if token == "" {
		fmt.Println("❌ 未登录，跳过测试")
		return
	}

	checkinData := map[string]interface{}{
		"type":       "训练",
		"notes":      "完成了今天的训练",
		"mood":       "开心",
		"energy":     8,
		"motivation": 9,
	}

	jsonData, _ := json.Marshal(checkinData)
	req, _ := http.NewRequest("POST", baseURL+"/checkins", bytes.NewBuffer(jsonData))
	req.Header.Set("Authorization", "Bearer "+token)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Printf("❌ 签到失败: %v\n", err)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode == 201 {
		fmt.Println("✅ 签到成功")
	} else {
		body, _ := io.ReadAll(resp.Body)
		fmt.Printf("❌ 签到失败，状态码: %d, 响应: %s\n", resp.StatusCode, string(body))
	}
}

func testGetCheckins() {
	fmt.Println("\n📋 测试获取签到记录...")

	if token == "" {
		fmt.Println("❌ 未登录，跳过测试")
		return
	}

	req, _ := http.NewRequest("GET", baseURL+"/checkins?page=1&limit=10", nil)
	req.Header.Set("Authorization", "Bearer "+token)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Printf("❌ 获取签到记录失败: %v\n", err)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode == 200 {
		fmt.Println("✅ 获取签到记录成功")
	} else {
		body, _ := io.ReadAll(resp.Body)
		fmt.Printf("❌ 获取签到记录失败，状态码: %d, 响应: %s\n", resp.StatusCode, string(body))
	}
}
