#!/bin/bash

# 测试AI推荐服务集成
echo "=== 测试AI推荐服务集成 ==="

# 1. 用户注册和登录
echo "1. 用户注册和登录测试"
REGISTER_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser_ai",
    "email": "testuser_ai@example.com",
    "password": "password123"
  }')

echo "注册响应: $REGISTER_RESPONSE"

# 提取token
TOKEN=$(echo $REGISTER_RESPONSE | jq -r '.data.token')
echo "获取到Token: $TOKEN"

# 2. 测试AI生成训练计划
echo "2. 测试AI生成训练计划"
AI_PLAN_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/training/plans/ai-generate \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "goal": "增肌",
    "duration": 60,
    "difficulty": "中级",
    "muscle_groups": ["胸肌", "背肌", "腿部"],
    "include_cardio": true,
    "equipment": ["哑铃", "杠铃", "跑步机"],
    "preferences": {
      "rest_time": 60,
      "focus": "力量训练"
    }
  }')

echo "AI训练计划响应: $AI_PLAN_RESPONSE"

# 检查AI服务是否正常工作
if echo "$AI_PLAN_RESPONSE" | grep -q "error\|失败"; then
    echo "❌ AI服务调用失败"
    echo "可能的原因："
    echo "1. AI API密钥未配置"
    echo "2. AI服务URL不正确"
    echo "3. 网络连接问题"
    echo "4. AI服务配额不足"
else
    echo "✅ AI服务调用成功"
fi

# 3. 测试AI聊天功能
echo "3. 测试AI聊天功能"
AI_CHAT_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/ai/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": "我想增肌，有什么建议吗？",
    "context": "健身新手"
  }')

echo "AI聊天响应: $AI_CHAT_RESPONSE"

# 4. 测试AI营养计划生成
echo "4. 测试AI营养计划生成"
AI_NUTRITION_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/ai/nutrition-plan \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "goal": "增肌",
    "weight": 70,
    "height": 175,
    "age": 25,
    "activity_level": "中等",
    "dietary_restrictions": [],
    "preferences": {
      "meals_per_day": 3,
      "snacks": true
    }
  }')

echo "AI营养计划响应: $AI_NUTRITION_RESPONSE"

# 5. 检查AI服务配置
echo "5. 检查AI服务配置"
echo "环境变量检查："
echo "DEEPSEEK_API_KEY: ${DEEPSEEK_API_KEY:+已设置}"
echo "GROQ_API_KEY: ${GROQ_API_KEY:+已设置}"
echo "TENCENT_SECRET_ID: ${TENCENT_SECRET_ID:+已设置}"

# 6. 测试AI服务健康检查
echo "6. 测试AI服务健康检查"
HEALTH_RESPONSE=$(curl -s -X GET http://localhost:8080/api/v1/ai/health)

echo "AI服务健康检查响应: $HEALTH_RESPONSE"

echo "=== AI推荐服务集成测试完成 ==="
echo ""
echo "如果AI服务测试失败，请检查："
echo "1. 环境变量配置是否正确"
echo "2. AI API密钥是否有效"
echo "3. 网络连接是否正常"
echo "4. AI服务配额是否充足"
