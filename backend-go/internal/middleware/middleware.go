package middleware

import (
	"context"
	"fmt"
	"net/http"
	"strings"
	"time"

	"gymates/internal/services"

	"github.com/gin-gonic/gin"
	"github.com/go-redis/redis/v8"
)

// CORS 跨域中间件
func CORS() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Origin, Content-Type, Accept, Authorization")
		c.Header("Access-Control-Allow-Credentials", "true")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}

		c.Next()
	}
}

// Logger 日志中间件
func Logger() gin.HandlerFunc {
	return gin.LoggerWithFormatter(func(param gin.LogFormatterParams) string {
		return fmt.Sprintf("%s - [%s] \"%s %s %s %d %s \"%s\" %s\"\n",
			param.ClientIP,
			param.TimeStamp.Format("02/Jan/2006:15:04:05 -0700"),
			param.Method,
			param.Path,
			param.Request.Proto,
			param.StatusCode,
			param.Latency,
			param.Request.UserAgent(),
			param.ErrorMessage,
		)
	})
}

// Recovery 恢复中间件
func Recovery() gin.HandlerFunc {
	return gin.Recovery()
}

// Auth 认证中间件
func Auth(authService *services.AuthService) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header required"})
			c.Abort()
			return
		}

		// 检查Bearer token格式
		tokenParts := strings.Split(authHeader, " ")
		if len(tokenParts) != 2 || tokenParts[0] != "Bearer" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid authorization header format"})
			c.Abort()
			return
		}

		token := tokenParts[1]
		userID, err := authService.ValidateToken(token)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
			c.Abort()
			return
		}

		// 将用户ID存储到上下文中
		c.Set("user_id", fmt.Sprintf("%d", userID))
		c.Next()
	}
}

// OptionalAuth 可选认证中间件
func OptionalAuth(authService *services.AuthService) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.Next()
			return
		}

		// 检查Bearer token格式
		tokenParts := strings.Split(authHeader, " ")
		if len(tokenParts) != 2 || tokenParts[0] != "Bearer" {
			c.Next()
			return
		}

		token := tokenParts[1]
		userID, err := authService.ValidateToken(token)
		if err != nil {
			c.Next()
			return
		}

		// 将用户ID存储到上下文中
		c.Set("user_id", fmt.Sprintf("%d", userID))
		c.Next()
	}
}

// RateLimit 请求限流中间件
func RateLimit(redisClient *redis.Client, limit int, window time.Duration) gin.HandlerFunc {
	return func(c *gin.Context) {
		clientIP := c.ClientIP()
		key := fmt.Sprintf("rate_limit:%s", clientIP)

		// 使用Redis实现滑动窗口限流
		now := time.Now().Unix()
		windowStart := now - int64(window.Seconds())

		// 清理过期的记录
		redisClient.ZRemRangeByScore(c.Request.Context(), key, "0", fmt.Sprintf("%d", windowStart))

		// 获取当前窗口内的请求数
		count, err := redisClient.ZCard(c.Request.Context(), key).Result()
		if err != nil {
			c.Next()
			return
		}

		// 检查是否超过限制
		if count >= int64(limit) {
			c.JSON(http.StatusTooManyRequests, gin.H{
				"error":       "Rate limit exceeded",
				"retry_after": window.Seconds(),
			})
			c.Abort()
			return
		}

		// 记录当前请求
		redisClient.ZAdd(c.Request.Context(), key, &redis.Z{
			Score:  float64(now),
			Member: fmt.Sprintf("%d", now),
		})

		// 设置过期时间
		redisClient.Expire(c.Request.Context(), key, window)

		c.Next()
	}
}

// RequestID 请求ID中间件
func RequestID() gin.HandlerFunc {
	return func(c *gin.Context) {
		requestID := c.GetHeader("X-Request-ID")
		if requestID == "" {
			requestID = fmt.Sprintf("%d", time.Now().UnixNano())
		}

		c.Header("X-Request-ID", requestID)
		c.Set("request_id", requestID)
		c.Next()
	}
}

// SecurityHeaders 安全头中间件
func SecurityHeaders() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Header("X-Content-Type-Options", "nosniff")
		c.Header("X-Frame-Options", "DENY")
		c.Header("X-XSS-Protection", "1; mode=block")
		c.Header("Strict-Transport-Security", "max-age=31536000; includeSubDomains")
		c.Header("Content-Security-Policy", "default-src 'self'")
		c.Next()
	}
}

// Timeout 超时中间件
func Timeout(timeout time.Duration) gin.HandlerFunc {
	return func(c *gin.Context) {
		// 设置请求超时
		c.Request = c.Request.WithContext(func() context.Context {
			ctx, cancel := context.WithTimeout(c.Request.Context(), timeout)
			c.Set("timeout_cancel", cancel)
			return ctx
		}())

		c.Next()

		// 清理资源
		if cancel, exists := c.Get("timeout_cancel"); exists {
			if cancelFunc, ok := cancel.(context.CancelFunc); ok {
				cancelFunc()
			}
		}
	}
}

// ValidateJSON JSON验证中间件
func ValidateJSON() gin.HandlerFunc {
	return func(c *gin.Context) {
		if c.Request.Method == "POST" || c.Request.Method == "PUT" || c.Request.Method == "PATCH" {
			contentType := c.GetHeader("Content-Type")
			if strings.Contains(contentType, "application/json") {
				// 检查请求体大小
				if c.Request.ContentLength > 10*1024*1024 { // 10MB
					c.JSON(http.StatusRequestEntityTooLarge, gin.H{
						"error": "Request body too large",
					})
					c.Abort()
					return
				}
			}
		}
		c.Next()
	}
}
