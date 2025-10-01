#!/bin/bash

# FitTracker API 全面测试脚本
# 测试所有API端点并生成详细报告

echo "🧪 FitTracker API 全面测试开始..."
echo "=================================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 测试结果存储
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# API基础URL
BASE_URL="http://localhost:8080/api/v1"
TOKEN=""

# 测试函数
run_test() {
    local test_name="$1"
    local method="$2"
    local endpoint="$3"
    local data="$4"
    local expected_status="$5"
    local description="$6"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "${BLUE}测试: $test_name${NC}"
    echo "描述: $description"
    echo "端点: $method $endpoint"
    
    # 执行测试
    local response
    if [ -n "$TOKEN" ] && [ -n "$data" ]; then
        response=$(curl -s -w '%{http_code}' -X $method -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d "$data" "$BASE_URL$endpoint")
    elif [ -n "$TOKEN" ]; then
        response=$(curl -s -w '%{http_code}' -X $method -H "Authorization: Bearer $TOKEN" "$BASE_URL$endpoint")
    elif [ -n "$data" ]; then
        response=$(curl -s -w '%{http_code}' -X $method -H "Content-Type: application/json" -d "$data" "$BASE_URL$endpoint")
    else
        response=$(curl -s -w '%{http_code}' -X $method "$BASE_URL$endpoint")
    fi
    
    local status_code="${response: -3}"
    local body="${response%???}"
    
    echo "响应状态码: $status_code"
    echo "响应内容: $body"
    
    # 检查结果
    if [ "$status_code" = "$expected_status" ]; then
        echo -e "${GREEN}✅ 测试通过${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}❌ 测试失败 - 期望状态码: $expected_status, 实际: $status_code${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    
    echo "----------------------------------------"
}

# 1. 用户认证API测试
echo -e "${YELLOW}📝 1. 用户认证API测试${NC}"

# 测试用户注册
run_test "用户注册" "POST" "/auth/register" '{"email":"test@example.com","password":"test123","username":"testuser","name":"Test User"}' "201" "注册新用户"

# 测试用户登录
echo "获取登录令牌..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
    -H 'Content-Type: application/json' \
    -d '{"email":"test@example.com","password":"test123"}')

echo "登录响应: $LOGIN_RESPONSE"

# 提取token
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*"' | cut -d'"' -f4 2>/dev/null)
if [ -n "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
    echo -e "${GREEN}✅ 登录成功，获取到令牌${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${RED}❌ 登录失败，无法获取令牌${NC}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# 2. BMI计算API测试
echo -e "${YELLOW}📊 2. BMI计算API测试${NC}"

run_test "BMI计算-正常" "POST" "/bmi/calculate" '{"height":175,"weight":70,"age":25,"gender":"male"}' "200" "正常BMI计算"
run_test "BMI计算-偏瘦" "POST" "/bmi/calculate" '{"height":175,"weight":50,"age":25,"gender":"male"}' "200" "偏瘦BMI计算"
run_test "BMI计算-肥胖" "POST" "/bmi/calculate" '{"height":175,"weight":100,"age":25,"gender":"female"}' "200" "肥胖BMI计算"
run_test "BMI计算-无效参数" "POST" "/bmi/calculate" '{"height":0,"weight":70,"age":25,"gender":"male"}' "400" "无效参数测试"

# 3. 社区API测试
echo -e "${YELLOW}👥 3. 社区API测试${NC}"

run_test "获取社区动态" "GET" "/community/posts" "" "200" "获取社区动态列表"
run_test "发布动态" "POST" "/community/posts" '{"content":"测试动态内容","type":"训练","is_public":true}' "201" "发布社区动态"

# 4. 营养API测试
echo -e "${YELLOW}🍎 4. 营养API测试${NC}"

run_test "计算营养" "POST" "/nutrition/calculate" '{"food_name":"苹果","quantity":100,"unit":"g"}' "200" "计算食物营养"
run_test "搜索食物" "GET" "/nutrition/foods?q=苹果" "" "200" "搜索食物"

# 5. 训练API测试
echo -e "${YELLOW}💪 5. 训练API测试${NC}"

run_test "获取训练计划" "GET" "/workouts/plans" "" "200" "获取训练计划列表"

# 6. 签到API测试
echo -e "${YELLOW}📅 6. 签到API测试${NC}"

run_test "获取签到记录" "GET" "/checkins" "" "200" "获取签到记录"

# 7. 用户资料API测试
echo -e "${YELLOW}👤 7. 用户资料API测试${NC}"

run_test "获取用户资料" "GET" "/users/profile" "" "200" "获取用户资料"

# 8. 错误处理测试
echo -e "${YELLOW}⚠️ 8. 错误处理测试${NC}"

run_test "无效端点" "GET" "/invalid/endpoint" "" "404" "测试404错误处理"

# 生成测试报告
echo -e "\n${BLUE}📊 测试结果汇总${NC}"
echo "=================="
echo "总测试数: $TOTAL_TESTS"
echo -e "通过: ${GREEN}$PASSED_TESTS${NC}"
echo -e "失败: ${RED}$FAILED_TESTS${NC}"
if [ $TOTAL_TESTS -gt 0 ]; then
    echo "成功率: $(( (PASSED_TESTS * 100) / TOTAL_TESTS ))%"
fi

echo -e "\n${GREEN}🎉 API测试完成！${NC}"
