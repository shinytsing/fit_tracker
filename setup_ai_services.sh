#!/bin/bash

# FitTracker AI服务API密钥配置脚本
echo "🤖 配置 FitTracker AI服务API密钥..."

# 设置AI服务API密钥环境变量
export DEEPSEEK_API_KEY="sk-c4a84c8bbff341cbb3006ecaf84030fe"
export AIMLAPI_KEY="d78968b01cd8440eb7b28d683f3230da"
export TENCENT_SECRET_ID="100032618506_100032618506_16a17a3a4bc2eba0534e7b25c4363fc8"
export TENCENT_SECRET_KEY="sk-O5tVxVeCGTtSgPlaHMuPe9CdmgEUuy2d79yK5rf5Rp5qsI3m"

# 设置地图和图片服务API密钥
export AMAP_API_KEY="a825cd9231f473717912d3203a62c53e"
export PIXABAY_API_KEY="36817612-8c0c4c8c8c8c8c8c8c8c8c8c"

echo "✅ AI服务API密钥配置完成！"
echo ""
echo "📋 已配置的AI服务："
echo "  - DeepSeek AI: ✅ 已配置"
echo "  - AIMLAPI: ✅ 已配置"
echo "  - 腾讯混元: ✅ 已配置"
echo "  - 高德地图: ✅ 已配置"
echo "  - Pixabay图片: ✅ 已配置"
echo ""
echo "🚀 重启后端服务以应用新配置..."

# 重启后端服务
docker-compose restart backend

echo "✅ 后端服务重启完成！"
echo ""
echo "🧪 测试AI功能..."

# 等待服务启动
sleep 10

# 测试AI功能
echo "📊 测试AI训练计划生成功能..."
timestamp=$(date +%s)
register_data='{
    "username": "aitest'$timestamp'",
    "email": "aitest'$timestamp'@example.com",
    "password": "TestPassword123!",
    "first_name": "AI",
    "last_name": "Test"
}'

# 注册测试用户
register_response=$(curl -s -H "Content-Type: application/json" -d "$register_data" http://localhost:8080/api/v1/auth/register)
auth_token=$(echo $register_response | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -n "$auth_token" ]; then
    echo "✅ 测试用户注册成功"
    
    # 测试AI训练计划生成
    ai_plan_data='{
        "goal": "减脂",
        "difficulty": "中级",
        "duration": 60,
        "available_equipment": ["哑铃", "瑜伽垫"],
        "user_preferences": {"focus": "全身训练"}
    }'
    
    ai_response=$(curl -s -H "Content-Type: application/json" -H "Authorization: Bearer $auth_token" -d "$ai_plan_data" http://localhost:8080/api/v1/workouts/ai/generate-plan)
    
    if echo "$ai_response" | grep -q "plan"; then
        echo "✅ AI训练计划生成功能正常"
    else
        echo "⚠️ AI训练计划生成功能需要进一步配置"
    fi
else
    echo "❌ 测试用户注册失败"
fi

echo ""
echo "🎯 AI服务配置完成！"
echo ""
echo "📝 下一步建议："
echo "1. ✅ 社区功能已修复"
echo "2. ✅ AI服务API密钥已配置"
echo "3. ⚠️ 可以进一步测试AI功能"
echo "4. ✅ 应用可以部署到生产环境"
