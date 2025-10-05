#!/bin/bash

# FitTracker API 快速验证脚本
# 验证所有核心API都能独立运行并返回正确JSON

echo "🚀 FitTracker API 快速验证"
echo "=========================="
echo ""

BASE_URL="http://localhost:8000"
API_BASE="${BASE_URL}/api/v1"

# 检查服务状态
echo "1. 检查服务状态..."
if curl -s "$BASE_URL/health" | grep -q "healthy"; then
    echo "✅ 服务运行正常"
else
    echo "❌ 服务不可用，请先启动服务"
    exit 1
fi
echo ""

# 测试用户注册
echo "2. 测试用户注册..."
TIMESTAMP=$(date +%s)
REGISTER_RESPONSE=$(curl -s -X POST "$API_BASE/auth/register" \
    -H "Content-Type: application/json" \
    -d "{
        \"username\": \"testuser_$TIMESTAMP\",
        \"email\": \"test_$TIMESTAMP@example.com\",
        \"password\": \"testpass123\",
        \"phone\": \"13800138000\",
        \"bio\": \"测试用户\",
        \"fitness_goal\": \"减脂\",
        \"height\": 175.0,
        \"weight\": 70.0,
        \"age\": 25,
        \"gender\": \"男\"
    }")

if echo "$REGISTER_RESPONSE" | grep -q '"id"'; then
    USER_ID=$(echo "$REGISTER_RESPONSE" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
    echo "✅ 用户注册成功，ID: $USER_ID"
else
    echo "❌ 用户注册失败"
    echo "$REGISTER_RESPONSE"
    exit 1
fi
echo ""

# 测试用户登录
echo "3. 测试用户登录..."
LOGIN_RESPONSE=$(curl -s -X POST "$API_BASE/auth/login" \
    -H "Content-Type: application/json" \
    -d "{
        \"username\": \"testuser_$TIMESTAMP\",
        \"password\": \"testpass123\"
    }")

if echo "$LOGIN_RESPONSE" | grep -q '"access_token"'; then
    ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
    echo "✅ 用户登录成功，获得访问令牌"
else
    echo "❌ 用户登录失败"
    echo "$LOGIN_RESPONSE"
    exit 1
fi
echo ""

# 测试BMI计算
echo "4. 测试BMI计算..."
BMI_RESPONSE=$(curl -s -X POST "$API_BASE/bmi/calculate?user_id=$USER_ID" \
    -H "Content-Type: application/json" \
    -d "{
        \"height\": 175.0,
        \"weight\": 70.0,
        \"age\": 25,
        \"gender\": \"男\"
    }")

if echo "$BMI_RESPONSE" | grep -q '"bmi"'; then
    BMI_VALUE=$(echo "$BMI_RESPONSE" | grep -o '"bmi":[0-9.]*' | cut -d':' -f2)
    echo "✅ BMI计算成功，BMI值: $BMI_VALUE"
else
    echo "❌ BMI计算失败"
    echo "$BMI_RESPONSE"
    exit 1
fi
echo ""

# 测试创建BMI记录
echo "5. 测试创建BMI记录..."
BMI_RECORD_RESPONSE=$(curl -s -X POST "$API_BASE/bmi/records?user_id=$USER_ID" \
    -H "Content-Type: application/json" \
    -d "{
        \"height\": 175.0,
        \"weight\": 70.0,
        \"bmi\": $BMI_VALUE,
        \"category\": \"正常\",
        \"notes\": \"测试记录\"
    }")

if echo "$BMI_RECORD_RESPONSE" | grep -q '"id"'; then
    echo "✅ BMI记录创建成功"
else
    echo "❌ BMI记录创建失败"
    echo "$BMI_RECORD_RESPONSE"
    exit 1
fi
echo ""

# 测试创建训练计划
echo "6. 测试创建训练计划..."
PLAN_RESPONSE=$(curl -s -X POST "$API_BASE/workout/plans?user_id=$USER_ID" \
    -H "Content-Type: application/json" \
    -d "{
        \"name\": \"测试训练计划\",
        \"plan_type\": \"减脂\",
        \"difficulty_level\": \"初级\",
        \"duration_weeks\": 4,
        \"description\": \"这是一个测试训练计划\",
        \"exercises\": [
            {
                \"name\": \"俯卧撑\",
                \"sets\": 3,
                \"reps\": 10,
                \"duration\": 30
            },
            {
                \"name\": \"深蹲\",
                \"sets\": 3,
                \"reps\": 15,
                \"duration\": 45
            }
        ]
    }")

if echo "$PLAN_RESPONSE" | grep -q '"id"'; then
    echo "✅ 训练计划创建成功"
else
    echo "❌ 训练计划创建失败"
    echo "$PLAN_RESPONSE"
    exit 1
fi
echo ""

# 测试AI生成训练计划
echo "7. 测试AI生成训练计划..."
AI_PLAN_RESPONSE=$(curl -s -X POST "$API_BASE/workout/ai/generate-plan?user_id=$USER_ID" \
    -H "Content-Type: application/json" \
    -d "{
        \"goal\": \"减脂\",
        \"difficulty\": \"初级\",
        \"duration\": 4,
        \"available_equipment\": [\"哑铃\", \"瑜伽垫\"],
        \"user_preferences\": {
            \"preferred_time\": \"晚上\",
            \"workout_duration\": 30
        },
        \"fitness_level\": \"初学者\",
        \"target_muscle_groups\": [\"胸肌\", \"腿部\"],
        \"time_per_session\": 30
    }")

if echo "$AI_PLAN_RESPONSE" | grep -q '"plan"'; then
    echo "✅ AI训练计划生成成功"
else
    echo "❌ AI训练计划生成失败"
    echo "$AI_PLAN_RESPONSE"
    exit 1
fi
echo ""

# 测试获取运动动作列表
echo "8. 测试获取运动动作列表..."
EXERCISES_RESPONSE=$(curl -s "$API_BASE/workout/exercises")

if echo "$EXERCISES_RESPONSE" | grep -q '"name"'; then
    echo "✅ 运动动作列表获取成功"
else
    echo "❌ 运动动作列表获取失败"
    echo "$EXERCISES_RESPONSE"
    exit 1
fi
echo ""

# 测试获取用户列表
echo "9. 测试获取用户列表..."
USERS_RESPONSE=$(curl -s "$API_BASE/users/")

if echo "$USERS_RESPONSE" | grep -q '"username"'; then
    echo "✅ 用户列表获取成功"
else
    echo "❌ 用户列表获取失败"
    echo "$USERS_RESPONSE"
    exit 1
fi
echo ""

# 测试错误处理
echo "10. 测试错误处理..."
ERROR_RESPONSE=$(curl -s -w "\n%{http_code}" "$API_BASE/invalid/endpoint")
STATUS_CODE=$(echo "$ERROR_RESPONSE" | tail -n 1)

if [ "$STATUS_CODE" = "404" ]; then
    echo "✅ 错误处理正常，返回404状态码"
else
    echo "❌ 错误处理异常，状态码: $STATUS_CODE"
    exit 1
fi
echo ""

echo "🎉 所有API测试通过！"
echo "===================="
echo ""
echo "✅ 用户注册/登录 - 正常"
echo "✅ BMI计算器 - 正常"
echo "✅ 健身训练计划 - 正常"
echo "✅ AI服务 - 正常"
echo "✅ 数据存储 - 正常"
echo "✅ 错误处理 - 正常"
echo ""
echo "📊 测试结果: 10/10 通过"
echo "🚀 API服务运行正常，可以投入使用！"
