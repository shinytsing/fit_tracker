#!/bin/bash

echo "=== FitTracker 前后端交互测试 ==="
echo "测试时间: $(date)"
echo ""

# 检查服务状态
echo "1. 检查服务状态..."
echo "后端服务: $(curl -s http://localhost:8080/health | jq -r '.status' 2>/dev/null || echo '未响应')"
echo "前端服务: $(curl -s http://localhost:3000 | head -1 | grep -o '<!DOCTYPE html>' || echo '未响应')"
echo ""

# 测试用户注册
echo "2. 测试用户注册..."
REGISTER_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/users/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser'$(date +%s)'","email":"test'$(date +%s)'@example.com","password":"123456","nickname":"Test User"}')

if echo "$REGISTER_RESPONSE" | grep -q "注册成功"; then
  echo "✅ 用户注册成功"
  USER_ID=$(echo "$REGISTER_RESPONSE" | jq -r '.user.id' 2>/dev/null || echo "1")
else
  echo "❌ 用户注册失败"
  echo "响应: $REGISTER_RESPONSE"
fi
echo ""

# 测试用户登录
echo "3. 测试用户登录..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/users/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser'$(date +%s)'","password":"123456"}')

if echo "$LOGIN_RESPONSE" | grep -q "登录成功"; then
  echo "✅ 用户登录成功"
  TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.token' 2>/dev/null || echo "mock-jwt-token")
else
  echo "❌ 用户登录失败"
  echo "响应: $LOGIN_RESPONSE"
  TOKEN="mock-jwt-token"
fi
echo ""

# 测试训练计划 API
echo "4. 测试训练计划 API..."
TRAINING_RESPONSE=$(curl -s http://localhost:8080/api/v1/training/plans/today \
  -H "Authorization: Bearer $TOKEN")

if echo "$TRAINING_RESPONSE" | grep -q "plan"; then
  echo "✅ 训练计划 API 正常"
else
  echo "❌ 训练计划 API 异常"
  echo "响应: $TRAINING_RESPONSE"
fi
echo ""

# 测试社区 API
echo "5. 测试社区 API..."
COMMUNITY_RESPONSE=$(curl -s http://localhost:8080/api/v1/community/posts/recommend \
  -H "Authorization: Bearer $TOKEN")

if echo "$COMMUNITY_RESPONSE" | grep -q "posts"; then
  echo "✅ 社区 API 正常"
else
  echo "❌ 社区 API 异常"
  echo "响应: $COMMUNITY_RESPONSE"
fi
echo ""

# 测试消息 API
echo "6. 测试消息 API..."
MESSAGE_RESPONSE=$(curl -s http://localhost:8080/api/v1/messages/chats \
  -H "Authorization: Bearer $TOKEN")

if echo "$MESSAGE_RESPONSE" | grep -q "chats"; then
  echo "✅ 消息 API 正常"
else
  echo "❌ 消息 API 异常"
  echo "响应: $MESSAGE_RESPONSE"
fi
echo ""

# 测试 AI API
echo "7. 测试 AI API..."
AI_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/ai/training-plan \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"goal":"减脂","duration":30,"difficulty":"初级","equipment":["无器械"],"focus_areas":["全身"]}')

if echo "$AI_RESPONSE" | grep -q "plan"; then
  echo "✅ AI API 正常"
else
  echo "❌ AI API 异常"
  echo "响应: $AI_RESPONSE"
fi
echo ""

echo "=== 测试完成 ==="
echo "前端访问地址: http://localhost:3000"
echo "后端 API 地址: http://localhost:8080"
echo ""

# 检查端口占用
echo "服务端口状态:"
echo "前端 (3000): $(lsof -i :3000 | wc -l | xargs echo) 个连接"
echo "后端 (8080): $(lsof -i :8080 | wc -l | xargs echo) 个连接"
echo "数据库 (5432): $(lsof -i :5432 | wc -l | xargs echo) 个连接"
echo "Redis (6379): $(lsof -i :6379 | wc -l | xargs echo) 个连接"
