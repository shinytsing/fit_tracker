package services

import (
	"errors"
	"fmt"
	"time"

	"fittracker/internal/config"

	"github.com/golang-jwt/jwt/v5"
)

type AuthService struct {
	config      *config.Config
	userService *UserService
}

func NewAuthService(cfg *config.Config, userService *UserService) *AuthService {
	return &AuthService{
		config:      cfg,
		userService: userService,
	}
}

// GenerateToken 生成JWT token
func (s *AuthService) GenerateToken(userID uint) (string, error) {
	claims := jwt.MapClaims{
		"user_id": userID,
		"exp":     time.Now().Add(time.Duration(s.config.JWT.ExpiresIn) * time.Hour).Unix(),
		"iat":     time.Now().Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(s.config.JWT.SecretKey))
	if err != nil {
		return "", fmt.Errorf("failed to generate token: %w", err)
	}

	return tokenString, nil
}

// ValidateToken 验证JWT token
func (s *AuthService) ValidateToken(tokenString string) (uint, error) {
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(s.config.JWT.SecretKey), nil
	})

	if err != nil {
		return 0, fmt.Errorf("failed to parse token: %w", err)
	}

	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		if userID, ok := claims["user_id"].(float64); ok {
			return uint(userID), nil
		}
		return 0, errors.New("invalid token claims")
	}

	return 0, errors.New("invalid token")
}

// RefreshToken 刷新token
func (s *AuthService) RefreshToken(refreshToken string) (string, error) {
	// 验证refresh token
	userID, err := s.ValidateToken(refreshToken)
	if err != nil {
		return "", fmt.Errorf("invalid refresh token: %w", err)
	}

	// 生成新的access token
	newToken, err := s.GenerateToken(userID)
	if err != nil {
		return "", fmt.Errorf("failed to generate new token: %w", err)
	}

	return newToken, nil
}

// Logout 登出（将token加入黑名单）
func (s *AuthService) Logout(userID uint) error {
	// 这里可以实现将token加入Redis黑名单的逻辑
	// 为了简化，这里只是记录日志
	fmt.Printf("User %d logged out\n", userID)
	return nil
}
