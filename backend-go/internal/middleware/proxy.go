package middleware

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

// AIProxyConfig AI代理配置
type AIProxyConfig struct {
	BaseURL string
	Timeout time.Duration
	APIKey  string
	Headers map[string]string
}

// AIProxy AI代理中间件
func AIProxy(config *AIProxyConfig) gin.HandlerFunc {
	client := &http.Client{
		Timeout: config.Timeout,
	}

	return func(c *gin.Context) {
		// 构建目标URL
		targetURL := config.BaseURL + c.Request.URL.Path
		if c.Request.URL.RawQuery != "" {
			targetURL += "?" + c.Request.URL.RawQuery
		}

		// 读取请求体
		body, err := io.ReadAll(c.Request.Body)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Failed to read request body"})
			c.Abort()
			return
		}

		// 创建新的请求
		req, err := http.NewRequest(c.Request.Method, targetURL, bytes.NewBuffer(body))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create proxy request"})
			c.Abort()
			return
		}

		// 复制请求头
		for key, values := range c.Request.Header {
			for _, value := range values {
				req.Header.Add(key, value)
			}
		}

		// 设置自定义头
		for key, value := range config.Headers {
			req.Header.Set(key, value)
		}

		// 设置API密钥
		if config.APIKey != "" {
			req.Header.Set("Authorization", "Bearer "+config.APIKey)
		}

		// 发送请求
		resp, err := client.Do(req)
		if err != nil {
			c.JSON(http.StatusBadGateway, gin.H{"error": "Failed to proxy request to AI service"})
			c.Abort()
			return
		}
		defer resp.Body.Close()

		// 复制响应头
		for key, values := range resp.Header {
			for _, value := range values {
				c.Header(key, value)
			}
		}

		// 复制响应体
		responseBody, err := io.ReadAll(resp.Body)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read response body"})
			c.Abort()
			return
		}

		// 设置状态码并返回响应
		c.Data(resp.StatusCode, resp.Header.Get("Content-Type"), responseBody)
	}
}

// AIRequestLogger AI请求日志中间件
func AIRequestLogger() gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()

		// 记录请求信息
		requestInfo := map[string]interface{}{
			"method":     c.Request.Method,
			"path":       c.Request.URL.Path,
			"user_agent": c.Request.UserAgent(),
			"ip":         c.ClientIP(),
			"timestamp":  start.Unix(),
		}

		// 如果是POST/PUT请求，记录请求体大小
		if c.Request.Method == "POST" || c.Request.Method == "PUT" {
			requestInfo["content_length"] = c.Request.ContentLength
		}

		// 记录用户ID（如果已认证）
		if userID, exists := c.Get("user_id"); exists {
			requestInfo["user_id"] = userID
		}

		// 处理请求
		c.Next()

		// 记录响应信息
		duration := time.Since(start)
		requestInfo["duration_ms"] = duration.Milliseconds()
		requestInfo["status_code"] = c.Writer.Status()

		// 输出日志
		logData, _ := json.Marshal(requestInfo)
		fmt.Printf("[AI_PROXY] %s\n", string(logData))
	}
}

// AIResponseTransformer AI响应转换中间件
func AIResponseTransformer() gin.HandlerFunc {
	return func(c *gin.Context) {
		// 创建一个响应写入器来捕获响应
		writer := &responseWriter{
			ResponseWriter: c.Writer,
			body:           &bytes.Buffer{},
		}
		c.Writer = writer

		c.Next()

		// 检查是否是AI相关的响应
		if c.Request.URL.Path[:4] == "/ai/" {
			// 解析响应
			var response map[string]interface{}
			if err := json.Unmarshal(writer.body.Bytes(), &response); err == nil {
				// 添加通用字段
				response["timestamp"] = time.Now().Unix()
				response["api_version"] = "v1"

				// 如果有用户ID，添加到响应中
				if userID, exists := c.Get("user_id"); exists {
					response["user_id"] = userID
				}

				// 重新序列化响应
				if newResponse, err := json.Marshal(response); err == nil {
					writer.body.Reset()
					writer.body.Write(newResponse)
				}
			}
		}
	}
}

// responseWriter 响应写入器
type responseWriter struct {
	gin.ResponseWriter
	body *bytes.Buffer
}

func (w *responseWriter) Write(data []byte) (int, error) {
	w.body.Write(data)
	return w.ResponseWriter.Write(data)
}

func (w *responseWriter) WriteString(s string) (int, error) {
	w.body.WriteString(s)
	return w.ResponseWriter.WriteString(s)
}

// AIErrorHandler AI错误处理中间件
func AIErrorHandler() gin.HandlerFunc {
	return func(c *gin.Context) {
		defer func() {
			if err := recover(); err != nil {
				// 记录错误
				fmt.Printf("[AI_ERROR] %v\n", err)

				// 返回标准错误响应
				c.JSON(http.StatusInternalServerError, gin.H{
					"error":      "AI service error",
					"message":    "An error occurred while processing your request",
					"timestamp":  time.Now().Unix(),
					"request_id": c.GetString("request_id"),
				})
			}
		}()

		c.Next()

		// 检查响应状态码
		if c.Writer.Status() >= 400 {
			// 记录错误响应
			fmt.Printf("[AI_ERROR] Status: %d, Path: %s\n", c.Writer.Status(), c.Request.URL.Path)
		}
	}
}
