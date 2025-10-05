#!/bin/bash

# FitTracker Flutter 前端 API 联调测试脚本

echo "=========================================="
echo "FitTracker Flutter 前端 API 联调测试"
echo "=========================================="

# 检查后端服务是否运行
echo "1. 检查后端服务状态..."
BACKEND_URL="http://localhost:8000"
if curl -s "$BACKEND_URL/health" > /dev/null; then
    echo "✅ 后端服务运行正常"
else
    echo "❌ 后端服务未运行，请先启动后端服务"
    echo "   启动命令: cd backend && python main.py"
    exit 1
fi

# 测试健康检查端点
echo ""
echo "2. 测试健康检查端点..."
HEALTH_RESPONSE=$(curl -s "$BACKEND_URL/health")
echo "健康检查响应: $HEALTH_RESPONSE"

# 测试 API 文档端点
echo ""
echo "3. 测试 API 文档端点..."
if curl -s "$BACKEND_URL/api/v1/docs" > /dev/null; then
    echo "✅ API 文档可访问"
else
    echo "❌ API 文档不可访问"
fi

# 测试认证端点
echo ""
echo "4. 测试认证端点..."
echo "测试用户注册..."
REGISTER_RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/v1/auth/register" \
    -H "Content-Type: application/json" \
    -d '{
        "username": "testuser",
        "email": "test@example.com",
        "password": "testpassword123"
    }')

echo "注册响应: $REGISTER_RESPONSE"

# 测试 BMI 计算端点
echo ""
echo "5. 测试 BMI 计算端点..."
BMI_RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/v1/bmi/calculate" \
    -H "Content-Type: application/json" \
    -d '{
        "height": 175.0,
        "weight": 70.0,
        "age": 25,
        "gender": "male"
    }')

echo "BMI 计算响应: $BMI_RESPONSE"

# 测试训练计划端点
echo ""
echo "6. 测试训练计划端点..."
WORKOUT_RESPONSE=$(curl -s -X GET "$BACKEND_URL/api/v1/workout/plans")

echo "训练计划响应: $WORKOUT_RESPONSE"

# 检查 Flutter 应用配置
echo ""
echo "7. 检查 Flutter 应用配置..."
API_CONFIG_FILE="frontend/lib/core/config/api_config.dart"
if [ -f "$API_CONFIG_FILE" ]; then
    echo "✅ API 配置文件存在"
    echo "API 基础 URL:"
    grep "baseUrl" "$API_CONFIG_FILE"
else
    echo "❌ API 配置文件不存在"
fi

# 检查 API 服务文件
echo ""
echo "8. 检查 API 服务文件..."
API_SERVICE_FILES=(
    "frontend/lib/core/services/api_service.dart"
    "frontend/lib/core/services/auth_api_service.dart"
    "frontend/lib/core/services/bmi_api_service.dart"
    "frontend/lib/core/services/workout_api_service.dart"
    "frontend/lib/core/services/community_api_service.dart"
    "frontend/lib/core/services/message_api_service.dart"
)

for file in "${API_SERVICE_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file 存在"
    else
        echo "❌ $file 不存在"
    fi
done

echo ""
echo "=========================================="
echo "测试完成"
echo "=========================================="
echo ""
echo "下一步操作："
echo "1. 启动 Flutter 应用"
echo "2. 按照联调测试 checklist 逐项测试"
echo "3. 记录测试结果和问题"
echo ""
echo "Flutter 启动命令："
echo "cd frontend && flutter run"
