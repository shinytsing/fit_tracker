#!/bin/bash

# FitTracker API 全面测试脚本
# 测试所有API端点并生成详细报告

set -e

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
    
    # 构建curl命令
    local curl_cmd="curl -s -w '%{http_code}' -X $method"
    
    if [ -n "$TOKEN" ]; then
        curl_cmd="$curl_cmd -H 'Authorization: Bearer $TOKEN'"
    fi
    
    if [ -n "$data" ]; then
        curl_cmd="$curl_cmd -H 'Content-Type: application/json' -d '$data'"
    fi
    
    curl_cmd="$curl_cmd $BASE_URL$endpoint"
    
    # 执行测试
    local response=$(eval $curl_cmd)
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
TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.data.token // empty' 2>/dev/null)
if [ -n "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
    echo -e "${GREEN}✅ 登录成功，获取到令牌${NC}"
    TEST_RESULTS["用户登录"]="PASS"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${RED}❌ 登录失败，无法获取令牌${NC}"
    TEST_RESULTS["用户登录"]="FAIL"
    API_ISSUES["用户登录"]="无法获取认证令牌"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# 测试刷新令牌
run_test "刷新令牌" "POST" "/auth/refresh" "" "200" "刷新认证令牌"

# 测试登出
run_test "用户登出" "POST" "/auth/logout" "" "200" "用户登出"

# 2. BMI计算API测试
echo -e "${YELLOW}📊 2. BMI计算API测试${NC}"

run_test "BMI计算-正常" "POST" "/bmi/calculate" '{"height":175,"weight":70,"age":25,"gender":"male"}' "200" "正常BMI计算"
run_test "BMI计算-偏瘦" "POST" "/bmi/calculate" '{"height":175,"weight":50,"age":25,"gender":"male"}' "200" "偏瘦BMI计算"
run_test "BMI计算-肥胖" "POST" "/bmi/calculate" '{"height":175,"weight":100,"age":25,"gender":"female"}' "200" "肥胖BMI计算"
run_test "BMI计算-无效参数" "POST" "/bmi/calculate" '{"height":0,"weight":70,"age":25,"gender":"male"}' "400" "无效参数测试"

# 测试BMI记录
run_test "创建BMI记录" "POST" "/bmi/records" '{"height":175,"weight":70,"age":25,"gender":"male","notes":"测试记录"}' "201" "创建BMI记录"
run_test "获取BMI记录" "GET" "/bmi/records" "" "200" "获取BMI记录列表"

# 3. 训练API测试
echo -e "${YELLOW}💪 3. 训练API测试${NC}"

run_test "获取训练计划" "GET" "/workouts/plans" "" "200" "获取训练计划列表"
run_test "创建训练计划" "POST" "/workouts/plans" '{"name":"测试计划","description":"测试描述","exercises":[]}' "201" "创建训练计划"
run_test "获取训练记录" "GET" "/workouts/records" "" "200" "获取训练记录"
run_test "创建训练记录" "POST" "/workouts/records" '{"plan_id":1,"exercises":[],"duration":30,"notes":"测试训练"}' "201" "创建训练记录"

# 4. 社区API测试
echo -e "${YELLOW}👥 4. 社区API测试${NC}"

run_test "获取社区动态" "GET" "/community/posts" "" "200" "获取社区动态列表"
run_test "发布动态" "POST" "/community/posts" '{"content":"测试动态内容","type":"训练","is_public":true}' "201" "发布社区动态"
run_test "获取单个动态" "GET" "/community/posts/1" "" "200" "获取单个动态详情"

# 测试点赞功能
run_test "点赞动态" "POST" "/community/posts/1/like" "" "200" "点赞动态"
run_test "取消点赞" "DELETE" "/community/posts/1/like" "" "200" "取消点赞"

# 测试评论功能
run_test "发表评论" "POST" "/community/posts/1/comment" '{"content":"测试评论"}' "201" "发表评论"
run_test "获取评论" "GET" "/community/posts/1/comments" "" "200" "获取评论列表"

# 5. 营养API测试
echo -e "${YELLOW}🍎 5. 营养API测试${NC}"

run_test "计算营养" "POST" "/nutrition/calculate" '{"food_name":"苹果","quantity":100,"unit":"g"}' "200" "计算食物营养"
run_test "搜索食物" "GET" "/nutrition/foods?q=苹果" "" "200" "搜索食物"
run_test "获取每日摄入" "GET" "/nutrition/daily-intake" "" "200" "获取每日营养摄入"
run_test "创建营养记录" "POST" "/nutrition/records" '{"date":"2025-09-30","meal_type":"早餐","food_name":"苹果","quantity":100,"unit":"g"}' "201" "创建营养记录"

# 6. 签到API测试
echo -e "${YELLOW}📅 6. 签到API测试${NC}"

run_test "获取签到记录" "GET" "/checkins" "" "200" "获取签到记录"
run_test "创建签到" "POST" "/checkins" '{"date":"2025-09-30","notes":"测试签到"}' "201" "创建签到"
run_test "获取签到日历" "GET" "/checkins/calendar" "" "200" "获取签到日历"
run_test "获取连续签到" "GET" "/checkins/streak" "" "200" "获取连续签到天数"

# 7. 用户资料API测试
echo -e "${YELLOW}👤 7. 用户资料API测试${NC}"

run_test "获取用户资料" "GET" "/users/profile" "" "200" "获取用户资料"
run_test "更新用户资料" "PUT" "/users/profile" '{"name":"更新后的名字","age":26}' "200" "更新用户资料"

# 8. 错误处理测试
echo -e "${YELLOW}⚠️ 8. 错误处理测试${NC}"

run_test "无效端点" "GET" "/invalid/endpoint" "" "404" "测试404错误处理"
run_test "无效JSON" "POST" "/bmi/calculate" '{"invalid":"json"' "400" "测试无效JSON处理"
run_test "缺少认证" "GET" "/users/profile" "" "401" "测试未认证访问"

# 生成测试报告
echo -e "\n${BLUE}📊 测试结果汇总${NC}"
echo "=================="
echo "总测试数: $TOTAL_TESTS"
echo -e "通过: ${GREEN}$PASSED_TESTS${NC}"
echo -e "失败: ${RED}$FAILED_TESTS${NC}"
echo "成功率: $(( (PASSED_TESTS * 100) / TOTAL_TESTS ))%"

# 生成JSON报告
cat > api_test_report.json << EOF
{
  "test_summary": {
    "total_tests": $TOTAL_TESTS,
    "passed_tests": $PASSED_TESTS,
    "failed_tests": $FAILED_TESTS,
    "success_rate": $(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
  },
  "test_results": {
EOF

# 添加测试结果
first=true
for test_name in "${!TEST_RESULTS[@]}"; do
    if [ "$first" = true ]; then
        first=false
    else
        echo "," >> api_test_report.json
    fi
    echo "    \"$test_name\": \"${TEST_RESULTS[$test_name]}\"" >> api_test_report.json
done

echo "  }," >> api_test_report.json
echo "  \"issues\": {" >> api_test_report.json

# 添加问题详情
first=true
for test_name in "${!API_ISSUES[@]}"; do
    if [ "$first" = true ]; then
        first=false
    else
        echo "," >> api_test_report.json
    fi
    echo "    \"$test_name\": \"${API_ISSUES[$test_name]}\"" >> api_test_report.json
done

echo "  }" >> api_test_report.json
echo "}" >> api_test_report.json

echo -e "\n${GREEN}🎉 API测试完成！${NC}"
echo "详细报告已保存到: api_test_report.json"

# 显示失败测试的详细信息
if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "\n${RED}❌ 失败的测试:${NC}"
    for test_name in "${!API_ISSUES[@]}"; do
        echo "  • $test_name: ${API_ISSUES[$test_name]}"
    done
fi
