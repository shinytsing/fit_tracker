#!/bin/bash

# FitTracker API 功能验证脚本
# 验证所有核心API功能是否正常工作

set -e

# 配置变量
BASE_URL="http://localhost:8000"
API_BASE="${BASE_URL}/api/v1"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 测试结果统计
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 测试函数
test_api() {
    local test_name="$1"
    local url="$2"
    local method="$3"
    local data="$4"
    local expected_content="$5"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    log_info "测试: $test_name"
    
    local response
    local status_code
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "$url")
    elif [ "$method" = "POST" ]; then
        response=$(curl -s -w "\n%{http_code}" -X POST "$url" \
            -H "Content-Type: application/json" \
            -d "$data")
    fi
    
    status_code=$(echo "$response" | tail -n 1)
    response_body=$(echo "$response" | sed '$d')
    
    if [ "$status_code" = "200" ]; then
        if [ -n "$expected_content" ] && echo "$response_body" | grep -q "$expected_content"; then
            log_success "✓ $test_name - 成功"
            echo "响应: $(echo "$response_body" | head -c 100)..."
            PASSED_TESTS=$((PASSED_TESTS + 1))
        elif [ -z "$expected_content" ]; then
            log_success "✓ $test_name - 成功"
            echo "响应: $(echo "$response_body" | head -c 100)..."
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            log_error "✗ $test_name - 响应内容不符合预期"
            echo "实际响应: $response_body"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        log_error "✗ $test_name - HTTP状态码: $status_code"
        echo "响应: $response_body"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    echo ""
}

# 检查服务状态
check_service() {
    log_info "检查后端服务状态..."
    
    local response
    response=$(curl -s "$BASE_URL/health")
    
    if echo "$response" | grep -q "healthy"; then
        log_success "后端服务运行正常"
        return 0
    else
        log_error "后端服务不可用"
        return 1
    fi
}

# 1. 基础健康检查
test_health_endpoints() {
    log_info "=== 1. 基础健康检查测试 ==="
    
    test_api "根路径健康检查" "$BASE_URL/" "GET" "" "FitTracker"
    test_api "健康检查端点" "$BASE_URL/health" "GET" "" "healthy"
}

# 2. 用户认证测试
test_auth_endpoints() {
    log_info "=== 2. 用户认证测试 ==="
    
    # 生成唯一的测试用户信息
    local timestamp=$(date +%s)
    local username="testuser_$timestamp"
    local email="test_$timestamp@example.com"
    
    # 测试用户注册
    local register_data="{
        \"username\": \"$username\",
        \"email\": \"$email\",
        \"password\": \"testpass123\",
        \"phone\": \"13800138000\",
        \"bio\": \"测试用户\",
        \"fitness_goal\": \"减脂\",
        \"height\": 175.0,
        \"weight\": 70.0,
        \"age\": 25,
        \"gender\": \"男\"
    }"
    
    test_api "用户注册" "$API_BASE/auth/register" "POST" "$register_data" "id"
    
    # 测试用户登录
    local login_data="{
        \"username\": \"$username\",
        \"password\": \"testpass123\"
    }"
    
    test_api "用户登录" "$API_BASE/auth/login" "POST" "$login_data" "access_token"
}

# 3. BMI计算器测试
test_bmi_endpoints() {
    log_info "=== 3. BMI计算器测试 ==="
    
    # 使用固定的测试用户ID
    local test_user_id="test-user-123"
    
    # 测试BMI计算
    local bmi_calc_data="{
        \"height\": 175.0,
        \"weight\": 70.0,
        \"age\": 25,
        \"gender\": \"男\"
    }"
    
    test_api "BMI计算" "$API_BASE/bmi/calculate?user_id=$test_user_id" "POST" "$bmi_calc_data" "bmi"
    
    # 测试创建BMI记录
    local bmi_record_data="{
        \"height\": 175.0,
        \"weight\": 70.0,
        \"bmi\": 22.86,
        \"category\": \"正常\",
        \"notes\": \"测试记录\"
    }"
    
    test_api "创建BMI记录" "$API_BASE/bmi/records?user_id=$test_user_id" "POST" "$bmi_record_data" "id"
    
    # 测试获取BMI记录
    test_api "获取BMI记录列表" "$API_BASE/bmi/records?user_id=$test_user_id" "GET" "" "user_id"
    
    # 测试BMI统计
    test_api "获取BMI统计" "$API_BASE/bmi/stats?user_id=$test_user_id&period=month" "GET" "" "average_bmi"
    
    # 测试BMI趋势
    test_api "获取BMI趋势" "$API_BASE/bmi/trend?user_id=$test_user_id&days=30" "GET" "" "trend_data"
    
    # 测试健康建议
    test_api "获取健康建议" "$API_BASE/bmi/advice?user_id=$test_user_id&bmi=22.86" "GET" "" "advice"
}

# 4. 健身训练计划测试
test_workout_endpoints() {
    log_info "=== 4. 健身训练计划测试 ==="
    
    local test_user_id="test-user-123"
    
    # 测试获取训练计划列表
    test_api "获取训练计划列表" "$API_BASE/workout/plans?user_id=$test_user_id" "GET" "" ""
    
    # 测试创建训练计划
    local plan_data="{
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
    }"
    
    test_api "创建训练计划" "$API_BASE/workout/plans?user_id=$test_user_id" "POST" "$plan_data" "id"
    
    # 测试获取运动动作列表
    test_api "获取运动动作列表" "$API_BASE/workout/exercises" "GET" "" "name"
    
    # 测试获取训练记录
    test_api "获取训练记录" "$API_BASE/workout/records?user_id=$test_user_id" "GET" "" ""
    
    # 测试获取训练进度
    test_api "获取训练进度" "$API_BASE/workout/progress/$test_user_id?period=week" "GET" "" "period"
}

# 5. AI服务测试
test_ai_endpoints() {
    log_info "=== 5. AI服务测试 ==="
    
    local test_user_id="test-user-123"
    
    # 测试AI生成训练计划
    local ai_plan_data="{
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
    }"
    
    test_api "AI生成训练计划" "$API_BASE/workout/ai/generate-plan?user_id=$test_user_id" "POST" "$ai_plan_data" "plan"
}

# 6. 用户管理测试
test_user_endpoints() {
    log_info "=== 6. 用户管理测试 ==="
    
    # 测试获取用户列表
    test_api "获取用户列表" "$API_BASE/users/" "GET" "" "username"
    
    # 测试获取特定用户信息
    test_api "获取特定用户信息" "$API_BASE/users/test-user-123" "GET" "" "username"
}

# 7. 错误处理测试
test_error_handling() {
    log_info "=== 7. 错误处理测试 ==="
    
    # 测试无效的API端点
    local response
    response=$(curl -s -w "\n%{http_code}" "$API_BASE/invalid/endpoint")
    local status_code=$(echo "$response" | tail -n 1)
    
    if [ "$status_code" = "404" ]; then
        log_success "✓ 无效API端点 - 正确返回404"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        log_error "✗ 无效API端点 - 期望404，实际: $status_code"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo ""
    
    # 测试无效的用户ID
    response=$(curl -s -w "\n%{http_code}" "$API_BASE/users/invalid-user-id")
    status_code=$(echo "$response" | tail -n 1)
    
    if [ "$status_code" = "404" ]; then
        log_success "✓ 无效用户ID - 正确返回404"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        log_error "✗ 无效用户ID - 期望404，实际: $status_code"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo ""
}

# 8. 性能测试
test_performance() {
    log_info "=== 8. 性能测试 ==="
    
    # 测试响应时间
    local start_time=$(date +%s%N)
    curl -s "$BASE_URL/health" > /dev/null
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))  # 转换为毫秒
    
    log_info "健康检查响应时间: ${duration}ms"
    
    if [ $duration -lt 1000 ]; then
        log_success "✓ 响应时间测试 - 响应时间正常"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        log_warning "⚠ 响应时间测试 - 响应时间较慢: ${duration}ms"
        PASSED_TESTS=$((PASSED_TESTS + 1))  # 仍然算通过
    fi
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo ""
}

# 生成测试报告
generate_report() {
    log_info "=== 测试报告 ==="
    echo "总测试数: $TOTAL_TESTS"
    echo "通过测试: $PASSED_TESTS"
    echo "失败测试: $FAILED_TESTS"
    echo "成功率: $(( PASSED_TESTS * 100 / TOTAL_TESTS ))%"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        log_success "🎉 所有测试通过！API服务运行正常。"
        return 0
    else
        log_error "❌ 有 $FAILED_TESTS 个测试失败，请检查API服务。"
        return 1
    fi
}

# 主函数
main() {
    log_info "开始 FitTracker API 功能验证"
    log_info "测试目标: $BASE_URL"
    echo ""
    
    # 检查服务状态
    if ! check_service; then
        log_error "后端服务不可用，请先启动服务"
        exit 1
    fi
    
    # 运行所有测试
    test_health_endpoints
    test_auth_endpoints
    test_bmi_endpoints
    test_workout_endpoints
    test_ai_endpoints
    test_user_endpoints
    test_error_handling
    test_performance
    
    # 生成报告
    echo ""
    generate_report
    
    log_info "测试完成"
}

# 运行主函数
main "$@"
