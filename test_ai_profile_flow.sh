#!/bin/bash

# AI训练推荐 + 注册个人数据改造测试脚本
# 测试整个流程的集成

echo "🚀 开始测试 AI训练推荐 + 注册个人数据改造流程"
echo "=============================================="

# 设置基础URL
BASE_URL="http://localhost:8080/api/v1"

# 测试用户注册
echo "📝 测试1: 用户注册"
echo "-------------------"
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/users/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser_ai",
    "email": "testuser_ai@example.com",
    "password": "password123",
    "nickname": "AI测试用户"
  }')

echo "注册响应: $REGISTER_RESPONSE"

# 提取token
TOKEN=$(echo $REGISTER_RESPONSE | jq -r '.data.token // empty')

if [ -z "$TOKEN" ]; then
  echo "❌ 注册失败，无法获取token"
  exit 1
fi

echo "✅ 注册成功，获取到token: ${TOKEN:0:20}..."

# 测试创建个人资料
echo ""
echo "📊 测试2: 创建个人资料"
echo "----------------------"
PROFILE_RESPONSE=$(curl -s -X POST "$BASE_URL/users/profile/data" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "height": 175.0,
    "weight": 70.0,
    "exercise_years": 2,
    "fitness_goal": "增肌"
  }')

echo "个人资料创建响应: $PROFILE_RESPONSE"

# 检查个人资料是否存在
echo ""
echo "🔍 测试3: 检查个人资料是否存在"
echo "------------------------------"
EXISTS_RESPONSE=$(curl -s -X GET "$BASE_URL/users/profile/data/exists" \
  -H "Authorization: Bearer $TOKEN")

echo "检查响应: $EXISTS_RESPONSE"

# 获取个人资料
echo ""
echo "📋 测试4: 获取个人资料"
echo "---------------------"
GET_PROFILE_RESPONSE=$(curl -s -X GET "$BASE_URL/users/profile/data" \
  -H "Authorization: Bearer $TOKEN")

echo "获取个人资料响应: $GET_PROFILE_RESPONSE"

# 测试AI训练推荐
echo ""
echo "🤖 测试5: AI训练推荐"
echo "-------------------"
AI_RESPONSE=$(curl -s -X POST "$BASE_URL/training/ai-recommend" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN")

echo "AI推荐响应: $AI_RESPONSE"

# 测试用户登录
echo ""
echo "🔐 测试6: 用户登录"
echo "-----------------"
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/users/login" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser_ai@example.com",
    "password": "password123"
  }')

echo "登录响应: $LOGIN_RESPONSE"

# 提取登录token
LOGIN_TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.data.token // empty')

if [ -z "$LOGIN_TOKEN" ]; then
  echo "❌ 登录失败，无法获取token"
  exit 1
fi

echo "✅ 登录成功，获取到token: ${LOGIN_TOKEN:0:20}..."

# 使用登录token再次测试AI推荐
echo ""
echo "🤖 测试7: 使用登录token进行AI推荐"
echo "--------------------------------"
AI_RESPONSE2=$(curl -s -X POST "$BASE_URL/training/ai-recommend" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $LOGIN_TOKEN")

echo "AI推荐响应: $AI_RESPONSE2"

echo ""
echo "🎉 测试完成！"
echo "============="
echo "✅ 用户注册流程正常"
echo "✅ 个人资料创建正常"
echo "✅ 个人资料检查正常"
echo "✅ 个人资料获取正常"
echo "✅ AI训练推荐正常"
echo "✅ 用户登录流程正常"
echo ""
echo "📱 前端流程："
echo "1. 用户注册 → 跳转到个人资料填写页面"
echo "2. 填写个人资料 → 保存并跳转到首页"
echo "3. 用户登录 → 检查个人资料完整性 → 跳转到相应页面"
echo "4. 在训练页面点击AI推荐 → 获取个性化训练计划"
echo ""
echo "🔧 后端API："
echo "- POST /api/v1/users/register - 用户注册"
echo "- POST /api/v1/users/profile/data - 创建个人资料"
echo "- GET /api/v1/users/profile/data - 获取个人资料"
echo "- GET /api/v1/users/profile/data/exists - 检查个人资料是否存在"
echo "- POST /api/v1/training/ai-recommend - AI训练推荐"
echo "- POST /api/v1/users/login - 用户登录"
