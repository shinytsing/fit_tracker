package services

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"time"
)

// LLMProvider 定义LLM提供商接口
type LLMProvider interface {
	Call(ctx context.Context, messages []Message) (*LLMResponse, error)
	GetName() string
	IsAvailable() bool
}

// Message LLM消息结构
type Message struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

// LLMResponse LLM响应结构
type LLMResponse struct {
	Content   string
	Provider  string
	Model     string
	Timestamp time.Time
}

// LLMManager 多LLM管理器
type LLMManager struct {
	providers []LLMProvider
	logger    *log.Logger
}

// NewLLMManager 创建新的LLM管理器
func NewLLMManager() *LLMManager {
	logger := log.New(os.Stdout, "[LLMManager] ", log.LstdFlags)
	
	manager := &LLMManager{
		providers: make([]LLMProvider, 0),
		logger:    logger,
	}
	
	// 按优先级添加提供商
	// 1. DeepSeek
	if apiKey := os.Getenv("DEEPSEEK_API_KEY"); apiKey != "" {
		manager.providers = append(manager.providers, NewDeepSeekProvider(apiKey))
		logger.Println("已加载 DeepSeek API")
	}
	
	// 2. 腾讯混元
	if secretID := os.Getenv("TENCENT_SECRET_ID"); secretID != "" {
		if secretKey := os.Getenv("TENCENT_SECRET_KEY"); secretKey != "" {
			manager.providers = append(manager.providers, NewTencentHunyuanProvider(secretID, secretKey))
			logger.Println("已加载 腾讯混元 API")
		}
	}
	
	// 3. AIMLAPI
	if apiKey := os.Getenv("AIMLAPI_API_KEY"); apiKey != "" {
		manager.providers = append(manager.providers, NewAIMLAPIProvider(apiKey))
		logger.Println("已加载 AIMLAPI")
	}
	
	if len(manager.providers) == 0 {
		logger.Println("警告: 未配置任何LLM API，将使用默认模拟响应")
	}
	
	return manager
}

// Call 调用LLM，自动尝试可用的提供商
func (m *LLMManager) Call(ctx context.Context, messages []Message) (*LLMResponse, error) {
	if len(m.providers) == 0 {
		return m.mockResponse(messages)
	}
	
	var lastError error
	
	// 按优先级尝试每个提供商
	for _, provider := range m.providers {
		if !provider.IsAvailable() {
			continue
		}
		
		m.logger.Printf("尝试使用 %s", provider.GetName())
		
		response, err := provider.Call(ctx, messages)
		if err != nil {
			m.logger.Printf("%s 调用失败: %v", provider.GetName(), err)
			lastError = err
			continue
		}
		
		m.logger.Printf("%s 调用成功", provider.GetName())
		return response, nil
	}
	
	if lastError != nil {
		return nil, fmt.Errorf("所有LLM提供商都失败: %w", lastError)
	}
	
	return nil, fmt.Errorf("没有可用的LLM提供商")
}

// mockResponse 模拟响应（当没有配置API时）
func (m *LLMManager) mockResponse(messages []Message) (*LLMResponse, error) {
	return &LLMResponse{
		Content:   "这是一个模拟的AI响应。请配置LLM API密钥以获得真实的AI功能。",
		Provider:  "Mock",
		Model:     "mock-model",
		Timestamp: time.Now(),
	}, nil
}

// =========================
// DeepSeek Provider
// =========================

type DeepSeekProvider struct {
	apiKey  string
	baseURL string
	model   string
	client  *http.Client
}

func NewDeepSeekProvider(apiKey string) *DeepSeekProvider {
	return &DeepSeekProvider{
		apiKey:  apiKey,
		baseURL: "https://api.deepseek.com/v1/chat/completions",
		model:   "deepseek-chat",
		client: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

func (p *DeepSeekProvider) GetName() string {
	return "DeepSeek"
}

func (p *DeepSeekProvider) IsAvailable() bool {
	return p.apiKey != ""
}

func (p *DeepSeekProvider) Call(ctx context.Context, messages []Message) (*LLMResponse, error) {
	requestBody := map[string]interface{}{
		"model":       p.model,
		"messages":    messages,
		"temperature": 0.7,
		"max_tokens":  2000,
	}
	
	jsonData, err := json.Marshal(requestBody)
	if err != nil {
		return nil, fmt.Errorf("序列化请求失败: %w", err)
	}
	
	req, err := http.NewRequestWithContext(ctx, "POST", p.baseURL, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("创建请求失败: %w", err)
	}
	
	req.Header.Set("Authorization", "Bearer "+p.apiKey)
	req.Header.Set("Content-Type", "application/json")
	
	resp, err := p.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("发送请求失败: %w", err)
	}
	defer resp.Body.Close()
	
	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("API返回错误 %d: %s", resp.StatusCode, string(body))
	}
	
	var result struct {
		Choices []struct {
			Message Message `json:"message"`
		} `json:"choices"`
		Model string `json:"model"`
	}
	
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("解析响应失败: %w", err)
	}
	
	if len(result.Choices) == 0 {
		return nil, fmt.Errorf("API返回空响应")
	}
	
	return &LLMResponse{
		Content:   result.Choices[0].Message.Content,
		Provider:  p.GetName(),
		Model:     result.Model,
		Timestamp: time.Now(),
	}, nil
}

// =========================
// 腾讯混元 Provider
// =========================

type TencentHunyuanProvider struct {
	secretID  string
	secretKey string
	baseURL   string
	model     string
	client    *http.Client
}

func NewTencentHunyuanProvider(secretID, secretKey string) *TencentHunyuanProvider {
	return &TencentHunyuanProvider{
		secretID:  secretID,
		secretKey: secretKey,
		baseURL:   "https://hunyuan.tencentcloudapi.com",
		model:     "hunyuan-lite",
		client: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

func (p *TencentHunyuanProvider) GetName() string {
	return "腾讯混元"
}

func (p *TencentHunyuanProvider) IsAvailable() bool {
	return p.secretID != "" && p.secretKey != ""
}

func (p *TencentHunyuanProvider) Call(ctx context.Context, messages []Message) (*LLMResponse, error) {
	// 腾讯混元API调用实现
	// 注意：腾讯混元API需要签名认证，这里简化实现
	requestBody := map[string]interface{}{
		"Model":    p.model,
		"Messages": messages,
	}
	
	jsonData, err := json.Marshal(requestBody)
	if err != nil {
		return nil, fmt.Errorf("序列化请求失败: %w", err)
	}
	
	req, err := http.NewRequestWithContext(ctx, "POST", p.baseURL, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("创建请求失败: %w", err)
	}
	
	// TODO: 实现腾讯云API签名
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", p.secretKey) // 简化实现
	
	resp, err := p.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("发送请求失败: %w", err)
	}
	defer resp.Body.Close()
	
	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("API返回错误 %d: %s", resp.StatusCode, string(body))
	}
	
	var result struct {
		Response struct {
			Choices []struct {
				Message Message `json:"Message"`
			} `json:"Choices"`
		} `json:"Response"`
	}
	
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("解析响应失败: %w", err)
	}
	
	if len(result.Response.Choices) == 0 {
		return nil, fmt.Errorf("API返回空响应")
	}
	
	return &LLMResponse{
		Content:   result.Response.Choices[0].Message.Content,
		Provider:  p.GetName(),
		Model:     p.model,
		Timestamp: time.Now(),
	}, nil
}

// =========================
// AIMLAPI Provider
// =========================

type AIMLAPIProvider struct {
	apiKey  string
	baseURL string
	model   string
	client  *http.Client
}

func NewAIMLAPIProvider(apiKey string) *AIMLAPIProvider {
	return &AIMLAPIProvider{
		apiKey:  apiKey,
		baseURL: "https://api.aimlapi.com/v1/chat/completions",
		model:   "gpt-3.5-turbo",
		client: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

func (p *AIMLAPIProvider) GetName() string {
	return "AIMLAPI"
}

func (p *AIMLAPIProvider) IsAvailable() bool {
	return p.apiKey != ""
}

func (p *AIMLAPIProvider) Call(ctx context.Context, messages []Message) (*LLMResponse, error) {
	requestBody := map[string]interface{}{
		"model":       p.model,
		"messages":    messages,
		"temperature": 0.7,
		"max_tokens":  2000,
	}
	
	jsonData, err := json.Marshal(requestBody)
	if err != nil {
		return nil, fmt.Errorf("序列化请求失败: %w", err)
	}
	
	req, err := http.NewRequestWithContext(ctx, "POST", p.baseURL, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("创建请求失败: %w", err)
	}
	
	req.Header.Set("Authorization", "Bearer "+p.apiKey)
	req.Header.Set("Content-Type", "application/json")
	
	resp, err := p.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("发送请求失败: %w", err)
	}
	defer resp.Body.Close()
	
	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("API返回错误 %d: %s", resp.StatusCode, string(body))
	}
	
	var result struct {
		Choices []struct {
			Message Message `json:"message"`
		} `json:"choices"`
		Model string `json:"model"`
	}
	
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("解析响应失败: %w", err)
	}
	
	if len(result.Choices) == 0 {
		return nil, fmt.Errorf("API返回空响应")
	}
	
	return &LLMResponse{
		Content:   result.Choices[0].Message.Content,
		Provider:  p.GetName(),
		Model:     result.Model,
		Timestamp: time.Now(),
	}, nil
}
