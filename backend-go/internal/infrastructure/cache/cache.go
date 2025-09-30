package cache

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"fittracker/backend/internal/config"

	"github.com/go-redis/redis/v8"
)

// RedisClient Redis客户端
type RedisClient struct {
	client *redis.Client
	ctx    context.Context
}

// NewRedisClient 创建Redis客户端
func NewRedisClient(cfg *config.Config) (*RedisClient, error) {
	opt, err := redis.ParseURL(cfg.RedisURL)
	if err != nil {
		return nil, fmt.Errorf("解析Redis URL失败: %w", err)
	}

	client := redis.NewClient(opt)

	// 测试连接
	ctx := context.Background()
	_, err = client.Ping(ctx).Result()
	if err != nil {
		return nil, fmt.Errorf("Redis连接失败: %w", err)
	}

	return &RedisClient{
		client: client,
		ctx:    ctx,
	}, nil
}

// Close 关闭Redis连接
func (r *RedisClient) Close() error {
	return r.client.Close()
}

// Set 设置键值对
func (r *RedisClient) Set(key string, value interface{}, expiration time.Duration) error {
	data, err := json.Marshal(value)
	if err != nil {
		return fmt.Errorf("序列化数据失败: %w", err)
	}

	return r.client.Set(r.ctx, key, data, expiration).Err()
}

// Get 获取值
func (r *RedisClient) Get(key string, dest interface{}) error {
	data, err := r.client.Get(r.ctx, key).Result()
	if err != nil {
		if err == redis.Nil {
			return fmt.Errorf("键不存在: %s", key)
		}
		return fmt.Errorf("获取数据失败: %w", err)
	}

	return json.Unmarshal([]byte(data), dest)
}

// Del 删除键
func (r *RedisClient) Del(key string) error {
	return r.client.Del(r.ctx, key).Err()
}

// Exists 检查键是否存在
func (r *RedisClient) Exists(key string) (bool, error) {
	count, err := r.client.Exists(r.ctx, key).Result()
	return count > 0, err
}

// Expire 设置过期时间
func (r *RedisClient) Expire(key string, expiration time.Duration) error {
	return r.client.Expire(r.ctx, key, expiration).Err()
}

// TTL 获取剩余过期时间
func (r *RedisClient) TTL(key string) (time.Duration, error) {
	return r.client.TTL(r.ctx, key).Result()
}

// Incr 递增
func (r *RedisClient) Incr(key string) (int64, error) {
	return r.client.Incr(r.ctx, key).Result()
}

// Decr 递减
func (r *RedisClient) Decr(key string) (int64, error) {
	return r.client.Decr(r.ctx, key).Result()
}

// HSet 设置哈希字段
func (r *RedisClient) HSet(key string, field string, value interface{}) error {
	data, err := json.Marshal(value)
	if err != nil {
		return fmt.Errorf("序列化数据失败: %w", err)
	}

	return r.client.HSet(r.ctx, key, field, data).Err()
}

// HGet 获取哈希字段
func (r *RedisClient) HGet(key string, field string, dest interface{}) error {
	data, err := r.client.HGet(r.ctx, key, field).Result()
	if err != nil {
		if err == redis.Nil {
			return fmt.Errorf("字段不存在: %s.%s", key, field)
		}
		return fmt.Errorf("获取哈希字段失败: %w", err)
	}

	return json.Unmarshal([]byte(data), dest)
}

// HDel 删除哈希字段
func (r *RedisClient) HDel(key string, field string) error {
	return r.client.HDel(r.ctx, key, field).Err()
}

// HGetAll 获取所有哈希字段
func (r *RedisClient) HGetAll(key string) (map[string]string, error) {
	return r.client.HGetAll(r.ctx, key).Result()
}

// ZAdd 添加有序集合成员
func (r *RedisClient) ZAdd(key string, score float64, member interface{}) error {
	data, err := json.Marshal(member)
	if err != nil {
		return fmt.Errorf("序列化数据失败: %w", err)
	}

	return r.client.ZAdd(r.ctx, key, &redis.Z{
		Score:  score,
		Member: data,
	}).Err()
}

// ZRange 获取有序集合范围
func (r *RedisClient) ZRange(key string, start, stop int64) ([]string, error) {
	return r.client.ZRange(r.ctx, key, start, stop).Result()
}

// ZRevRange 获取有序集合范围（倒序）
func (r *RedisClient) ZRevRange(key string, start, stop int64) ([]string, error) {
	return r.client.ZRevRange(r.ctx, key, start, stop).Result()
}

// ZRank 获取成员排名
func (r *RedisClient) ZRank(key string, member interface{}) (int64, error) {
	data, err := json.Marshal(member)
	if err != nil {
		return 0, fmt.Errorf("序列化数据失败: %w", err)
	}

	return r.client.ZRank(r.ctx, key, string(data)).Result()
}

// ZScore 获取成员分数
func (r *RedisClient) ZScore(key string, member interface{}) (float64, error) {
	data, err := json.Marshal(member)
	if err != nil {
		return 0, fmt.Errorf("序列化数据失败: %w", err)
	}

	return r.client.ZScore(r.ctx, key, string(data)).Result()
}

// ZRem 删除有序集合成员
func (r *RedisClient) ZRem(key string, member interface{}) error {
	data, err := json.Marshal(member)
	if err != nil {
		return fmt.Errorf("序列化数据失败: %w", err)
	}

	return r.client.ZRem(r.ctx, key, string(data)).Err()
}

// LPush 左推入列表
func (r *RedisClient) LPush(key string, value interface{}) error {
	data, err := json.Marshal(value)
	if err != nil {
		return fmt.Errorf("序列化数据失败: %w", err)
	}

	return r.client.LPush(r.ctx, key, data).Err()
}

// RPush 右推入列表
func (r *RedisClient) RPush(key string, value interface{}) error {
	data, err := json.Marshal(value)
	if err != nil {
		return fmt.Errorf("序列化数据失败: %w", err)
	}

	return r.client.RPush(r.ctx, key, data).Err()
}

// LPop 左弹出列表
func (r *RedisClient) LPop(key string, dest interface{}) error {
	data, err := r.client.LPop(r.ctx, key).Result()
	if err != nil {
		if err == redis.Nil {
			return fmt.Errorf("列表为空: %s", key)
		}
		return fmt.Errorf("弹出数据失败: %w", err)
	}

	return json.Unmarshal([]byte(data), dest)
}

// RPop 右弹出列表
func (r *RedisClient) RPop(key string, dest interface{}) error {
	data, err := r.client.RPop(r.ctx, key).Result()
	if err != nil {
		if err == redis.Nil {
			return fmt.Errorf("列表为空: %s", key)
		}
		return fmt.Errorf("弹出数据失败: %w", err)
	}

	return json.Unmarshal([]byte(data), dest)
}

// LRange 获取列表范围
func (r *RedisClient) LRange(key string, start, stop int64) ([]string, error) {
	return r.client.LRange(r.ctx, key, start, stop).Result()
}

// LLen 获取列表长度
func (r *RedisClient) LLen(key string) (int64, error) {
	return r.client.LLen(r.ctx, key).Result()
}

// 缓存键常量
const (
	// 用户会话
	UserSessionKey = "user:session:%d" // user:session:123
	UserTokenKey   = "user:token:%s"   // user:token:abc123

	// 排行榜
	WorkoutLeaderboardKey   = "leaderboard:workouts"     // 训练排行榜
	CheckinLeaderboardKey   = "leaderboard:checkins"     // 签到排行榜
	ChallengeLeaderboardKey = "leaderboard:challenge:%d" // 挑战排行榜

	// 热门内容
	HotPostsKey = "hot:posts" // 热门动态
	HotUsersKey = "hot:users" // 热门用户

	// 缓存数据
	UserStatsKey = "cache:user:stats:%d" // 用户统计缓存
	PostStatsKey = "cache:post:stats:%d" // 动态统计缓存

	// 限流
	RateLimitKey = "rate:limit:%s:%s" // rate:limit:login:192.168.1.1

	// 临时数据
	TempDataKey = "temp:%s" // 临时数据
)

// 缓存时间常量
const (
	UserSessionTTL = 7 * 24 * time.Hour // 用户会话7天
	UserTokenTTL   = 24 * time.Hour     // Token 24小时
	LeaderboardTTL = 1 * time.Hour      // 排行榜1小时
	HotContentTTL  = 30 * time.Minute   // 热门内容30分钟
	UserStatsTTL   = 10 * time.Minute   // 用户统计10分钟
	PostStatsTTL   = 5 * time.Minute    // 动态统计5分钟
	RateLimitTTL   = 1 * time.Minute    // 限流1分钟
	TempDataTTL    = 1 * time.Hour      // 临时数据1小时
)

// CacheService 缓存服务
type CacheService struct {
	redis *RedisClient
}

// NewCacheService 创建缓存服务
func NewCacheService(redis *RedisClient) *CacheService {
	return &CacheService{
		redis: redis,
	}
}

// SetUserSession 设置用户会话
func (c *CacheService) SetUserSession(userID uint, sessionData interface{}) error {
	key := fmt.Sprintf(UserSessionKey, userID)
	return c.redis.Set(key, sessionData, UserSessionTTL)
}

// GetUserSession 获取用户会话
func (c *CacheService) GetUserSession(userID uint, dest interface{}) error {
	key := fmt.Sprintf(UserSessionKey, userID)
	return c.redis.Get(key, dest)
}

// DeleteUserSession 删除用户会话
func (c *CacheService) DeleteUserSession(userID uint) error {
	key := fmt.Sprintf(UserSessionKey, userID)
	return c.redis.Del(key)
}

// SetUserToken 设置用户Token
func (c *CacheService) SetUserToken(token string, userID uint) error {
	key := fmt.Sprintf(UserTokenKey, token)
	return c.redis.Set(key, userID, UserTokenTTL)
}

// GetUserToken 获取用户Token
func (c *CacheService) GetUserToken(token string) (uint, error) {
	key := fmt.Sprintf(UserTokenKey, token)
	var userID uint
	err := c.redis.Get(key, &userID)
	return userID, err
}

// DeleteUserToken 删除用户Token
func (c *CacheService) DeleteUserToken(token string) error {
	key := fmt.Sprintf(UserTokenKey, token)
	return c.redis.Del(key)
}

// UpdateWorkoutLeaderboard 更新训练排行榜
func (c *CacheService) UpdateWorkoutLeaderboard(userID uint, score int) error {
	return c.redis.ZAdd(WorkoutLeaderboardKey, float64(score), userID)
}

// GetWorkoutLeaderboard 获取训练排行榜
func (c *CacheService) GetWorkoutLeaderboard(limit int64) ([]string, error) {
	return c.redis.ZRevRange(WorkoutLeaderboardKey, 0, limit-1)
}

// UpdateCheckinLeaderboard 更新签到排行榜
func (c *CacheService) UpdateCheckinLeaderboard(userID uint, score int) error {
	return c.redis.ZAdd(CheckinLeaderboardKey, float64(score), userID)
}

// GetCheckinLeaderboard 获取签到排行榜
func (c *CacheService) GetCheckinLeaderboard(limit int64) ([]string, error) {
	return c.redis.ZRevRange(CheckinLeaderboardKey, 0, limit-1)
}

// UpdateChallengeLeaderboard 更新挑战排行榜
func (c *CacheService) UpdateChallengeLeaderboard(challengeID uint, userID uint, score int) error {
	key := fmt.Sprintf(ChallengeLeaderboardKey, challengeID)
	return c.redis.ZAdd(key, float64(score), userID)
}

// GetChallengeLeaderboard 获取挑战排行榜
func (c *CacheService) GetChallengeLeaderboard(challengeID uint, limit int64) ([]string, error) {
	key := fmt.Sprintf(ChallengeLeaderboardKey, challengeID)
	return c.redis.ZRevRange(key, 0, limit-1)
}

// AddHotPost 添加热门动态
func (c *CacheService) AddHotPost(postID uint, score float64) error {
	return c.redis.ZAdd(HotPostsKey, score, postID)
}

// GetHotPosts 获取热门动态
func (c *CacheService) GetHotPosts(limit int64) ([]string, error) {
	return c.redis.ZRevRange(HotPostsKey, 0, limit-1)
}

// AddHotUser 添加热门用户
func (c *CacheService) AddHotUser(userID uint, score float64) error {
	return c.redis.ZAdd(HotUsersKey, score, userID)
}

// GetHotUsers 获取热门用户
func (c *CacheService) GetHotUsers(limit int64) ([]string, error) {
	return c.redis.ZRevRange(HotUsersKey, 0, limit-1)
}

// SetUserStats 设置用户统计缓存
func (c *CacheService) SetUserStats(userID uint, stats interface{}) error {
	key := fmt.Sprintf(UserStatsKey, userID)
	return c.redis.Set(key, stats, UserStatsTTL)
}

// GetUserStats 获取用户统计缓存
func (c *CacheService) GetUserStats(userID uint, dest interface{}) error {
	key := fmt.Sprintf(UserStatsKey, userID)
	return c.redis.Get(key, dest)
}

// SetPostStats 设置动态统计缓存
func (c *CacheService) SetPostStats(postID uint, stats interface{}) error {
	key := fmt.Sprintf(PostStatsKey, postID)
	return c.redis.Set(key, stats, PostStatsTTL)
}

// GetPostStats 获取动态统计缓存
func (c *CacheService) GetPostStats(postID uint, dest interface{}) error {
	key := fmt.Sprintf(PostStatsKey, postID)
	return c.redis.Get(key, dest)
}

// CheckRateLimit 检查限流
func (c *CacheService) CheckRateLimit(action, identifier string, limit int) (bool, error) {
	key := fmt.Sprintf(RateLimitKey, action, identifier)
	count, err := c.redis.Incr(key)
	if err != nil {
		return false, err
	}

	if count == 1 {
		c.redis.Expire(key, RateLimitTTL)
	}

	return count <= int64(limit), nil
}

// SetTempData 设置临时数据
func (c *CacheService) SetTempData(key string, data interface{}) error {
	fullKey := fmt.Sprintf(TempDataKey, key)
	return c.redis.Set(fullKey, data, TempDataTTL)
}

// GetTempData 获取临时数据
func (c *CacheService) GetTempData(key string, dest interface{}) error {
	fullKey := fmt.Sprintf(TempDataKey, key)
	return c.redis.Get(fullKey, dest)
}

// DeleteTempData 删除临时数据
func (c *CacheService) DeleteTempData(key string) error {
	fullKey := fmt.Sprintf(TempDataKey, key)
	return c.redis.Del(fullKey)
}
