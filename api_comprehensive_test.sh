#!/bin/bash

# FitTracker API 综合测试脚本
# 覆盖所有核心 API 功能的自测脚本

# set -e  # 遇到错误立即退出 - 注释掉以便继续执行所有测试

# 配置变量
BASE_URL="http://localhost:8000"
API_BASE="${BASE_URL}/api/v1"
TEST_USER_ID=""
ACCESS_TOKEN=""

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
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_status="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    log_info "运行测试: $test_name"
    
    # 执行测试命令
    local response
    local status_code
    local response_body
    
    response=$(eval "$test_command" 2>&1)
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        status_code=$(echo "$response" | tail -n 1)
        response_body=$(echo "$response" | sed '$d')
        
        if [ "$status_code" = "$expected_status" ]; then
            log_success "✓ $test_name - 状态码: $status_code"
            echo "响应: $response_body" | head -c 200
            echo "..."
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            log_error "✗ $test_name - 期望状态码: $expected_status, 实际: $status_code"
            echo "响应: $response_body"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        log_error "✗ $test_name - 请求失败 (退出码: $exit_code)"
        echo "错误: $response"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    echo ""
}

# 检查服务状态
check_service() {
    log_info "检查后端服务状态..."
    
    local health_response
    if health_response=$(curl -s -w "%{http_code}" -o /dev/null "${BASE_URL}/health"); then
        if [ "$health_response" = "200" ]; then
            log_success "后端服务运行正常"
            return 0
        else
            log_error "后端服务健康检查失败，状态码: $health_response"
            return 1
        fi
    else
        log_error "无法连接到后端服务"
        return 1
    fi
}

# 1. 基础健康检查测试
test_health_endpoints() {
    log_info "=== 1. 基础健康检查测试 ==="
    
    run_test "根路径健康检查" \
        "curl -s -w '%{http_code}' -o /dev/null '${BASE_URL}/'" \
        "200"
    
    run_test "健康检查端点" \
        "curl -s -w '%{http_code}' -o /dev/null '${BASE_URL}/health'" \
        "200"
    
    run_test "API文档端点" \
        "curl -s -w '%{http_code}' -o /dev/null '${API_BASE}/docs'" \
        "200"
}

# 2. 用户认证测试
test_auth_endpoints() {
    log_info "=== 2. 用户认证测试 ==="
    
    # 测试用户注册
    local register_data='{
        "username": "testuser_'$(date +%s)'",
        "email": "test_'$(date +%s)'@example.com",
        "password": "testpass123",
        "phone": "13800138000",
        "bio": "测试用户",
        "fitness_goal": "减脂",
        "height": 175.0,
        "weight": 70.0,
        "age": 25,
        "gender": "男"
    }'
    
    log_info "注册测试用户..."
    local register_response
    register_response=$(curl -s -X POST "${API_BASE}/auth/register" \
        -H "Content-Type: application/json" \
        -d "$register_data")
    
    if echo "$register_response" | grep -q '"id"'; then
        TEST_USER_ID=$(echo "$register_response" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
        log_success "用户注册成功，用户ID: $TEST_USER_ID"
        
        # 测试用户登录
        log_info "测试用户登录..."
        local username=$(echo "$register_data" | grep -o '"username":"[^"]*"' | cut -d'"' -f4)
        local login_response
        login_response=$(curl -s -X POST "${API_BASE}/auth/login" \
            -H "Content-Type: application/json" \
            -d "{\"username\":\"${username}\",\"password\":\"testpass123\"}")
        
        if echo "$login_response" | grep -q '"access_token"'; then
            ACCESS_TOKEN=$(echo "$login_response" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
            log_success "用户登录成功，获得访问令牌"
        else
            log_error "用户登录失败"
            echo "登录响应: $login_response"
        fi
    else
        log_error "用户注册失败"
        echo "注册响应: $register_response"
    fi
    
    # 测试获取当前用户信息
    if [ -n "$ACCESS_TOKEN" ]; then
        run_test "获取当前用户信息" \
            "curl -s -w '%{http_code}' -H 'Authorization: Bearer $ACCESS_TOKEN' '${API_BASE}/auth/me'" \
            "200"
    fi
}

# 3. BMI计算器测试
test_bmi_endpoints() {
    log_info "=== 3. BMI计算器测试 ==="
    
    if [ -z "$TEST_USER_ID" ]; then
        log_warning "跳过BMI测试 - 没有有效的用户ID"
        return
    fi
    
    # 测试BMI计算
    local bmi_calc_data='{
        "height": 175.0,
        "weight": 70.0,
        "age": 25,
        "gender": "男"
    }'
    
    run_test "BMI计算" \
        "curl -s -w '%{http_code}' -X POST '${API_BASE}/bmi/calculate?user_id=$TEST_USER_ID' \
        -H 'Content-Type: application/json' \
        -d '$bmi_calc_data'" \
        "200"
    
    # 测试创建BMI记录
    local bmi_record_data='{
        "height": 175.0,
        "weight": 70.0,
        "bmi": 22.86,
        "category": "正常",
        "notes": "测试记录"
    }'
    
    run_test "创建BMI记录" \
        "curl -s -w '%{http_code}' -X POST '${API_BASE}/bmi/records?user_id=$TEST_USER_ID' \
        -H 'Content-Type: application/json' \
        -d '$bmi_record_data'" \
        "200"
    
    # 测试获取BMI记录
    run_test "获取BMI记录列表" \
        "curl -s -w '%{http_code}' '${API_BASE}/bmi/records?user_id=$TEST_USER_ID'" \
        "200"
    
    # 测试BMI统计
    run_test "获取BMI统计" \
        "curl -s -w '%{http_code}' '${API_BASE}/bmi/stats?user_id=$TEST_USER_ID&period=month'" \
        "200"
    
    # 测试BMI趋势
    run_test "获取BMI趋势" \
        "curl -s -w '%{http_code}' '${API_BASE}/bmi/trend?user_id=$TEST_USER_ID&days=30'" \
        "200"
    
    # 测试健康建议
    run_test "获取健康建议" \
        "curl -s -w '%{http_code}' '${API_BASE}/bmi/advice?user_id=$TEST_USER_ID&bmi=22.86'" \
        "200"
}

# 4. 健身训练计划测试
test_workout_endpoints() {
    log_info "=== 4. 健身训练计划测试 ==="
    
    if [ -z "$TEST_USER_ID" ]; then
        log_warning "跳过健身测试 - 没有有效的用户ID"
        return
    fi
    
    # 测试获取训练计划列表
    run_test "获取训练计划列表" \
        "curl -s -w '%{http_code}' '${API_BASE}/workout/plans?user_id=$TEST_USER_ID'" \
        "200"
    
    # 测试创建训练计划
    local plan_data='{
        "name": "测试训练计划",
        "plan_type": "减脂",
        "difficulty_level": "初级",
        "duration_weeks": 4,
        "description": "这是一个测试训练计划",
        "exercises": [
            {
                "name": "俯卧撑",
                "sets": 3,
                "reps": 10,
                "duration": 30
            },
            {
                "name": "深蹲",
                "sets": 3,
                "reps": 15,
                "duration": 45
            }
        ]
    }'
    
    run_test "创建训练计划" \
        "curl -s -w '%{http_code}' -X POST '${API_BASE}/workout/plans?user_id=$TEST_USER_ID' \
        -H 'Content-Type: application/json' \
        -d '$plan_data'" \
        "200"
    
    # 测试获取运动动作列表
    run_test "获取运动动作列表" \
        "curl -s -w '%{http_code}' '${API_BASE}/workout/exercises'" \
        "200"
    
    # 测试按类别获取运动动作
    run_test "按类别获取运动动作" \
        "curl -s -w '%{http_code}' '${API_BASE}/workout/exercises?category=力量'" \
        "200"
    
    # 测试获取训练记录
    run_test "获取训练记录" \
        "curl -s -w '%{http_code}' '${API_BASE}/workout/records?user_id=$TEST_USER_ID'" \
        "200"
    
    # 测试获取训练进度
    run_test "获取训练进度" \
        "curl -s -w '%{http_code}' '${API_BASE}/workout/progress/$TEST_USER_ID?period=week'" \
        "200"
}

# 5. AI服务测试
test_ai_endpoints() {
    log_info "=== 5. AI服务测试 ==="
    
    if [ -z "$TEST_USER_ID" ]; then
        log_warning "跳过AI测试 - 没有有效的用户ID"
        return
    fi
    
    # 测试AI生成训练计划
    local ai_plan_data='{
        "goal": "减脂",
        "difficulty": "初级",
        "duration": 4,
        "available_equipment": ["哑铃", "瑜伽垫"],
        "user_preferences": {
            "preferred_time": "晚上",
            "workout_duration": 30
        },
        "fitness_level": "初学者",
        "target_muscle_groups": ["胸肌", "腿部"],
        "time_per_session": 30
    }'
    
    run_test "AI生成训练计划" \
        "curl -s -w '%{http_code}' -X POST '${API_BASE}/workout/ai/generate-plan?user_id=$TEST_USER_ID' \
        -H 'Content-Type: application/json' \
        -d '$ai_plan_data'" \
        "200"
}

# 6. 用户管理测试
test_user_endpoints() {
    log_info "=== 6. 用户管理测试 ==="
    
    # 测试获取用户列表
    run_test "获取用户列表" \
        "curl -s -w '%{http_code}' '${API_BASE}/users/'" \
        "200"
    
    # 测试获取特定用户信息
    if [ -n "$TEST_USER_ID" ]; then
        run_test "获取特定用户信息" \
            "curl -s -w '%{http_code}' '${API_BASE}/users/$TEST_USER_ID'" \
            "200"
    fi
}

# 7. 文件上传测试（如果有相关端点）
test_file_upload() {
    log_info "=== 7. 文件上传测试 ==="
    
    # 创建一个测试图片文件
    local test_image="/tmp/test_image.png"
    if command -v convert >/dev/null 2>&1; then
        convert -size 100x100 xc:white "$test_image"
        log_info "创建测试图片: $test_image"
        
        # 测试图片上传（假设有上传端点）
        run_test "图片上传测试" \
            "curl -s -w '%{http_code}' -X POST '${API_BASE}/upload/image' \
            -F 'file=@$test_image' \
            -F 'user_id=$TEST_USER_ID'" \
            "200"
        
        # 清理测试文件
        rm -f "$test_image"
    else
        log_warning "跳过文件上传测试 - 未安装ImageMagick"
    fi
}

# 8. 错误处理测试
test_error_handling() {
    log_info "=== 8. 错误处理测试 ==="
    
    # 测试无效的API端点
    run_test "无效API端点" \
        "curl -s -w '%{http_code}' '${API_BASE}/invalid/endpoint'" \
        "404"
    
    # 测试无效的用户ID
    run_test "无效用户ID" \
        "curl -s -w '%{http_code}' '${API_BASE}/users/invalid-user-id'" \
        "404"
    
    # 测试无效的认证令牌
    run_test "无效认证令牌" \
        "curl -s -w '%{http_code}' -H 'Authorization: Bearer invalid-token' '${API_BASE}/auth/me'" \
        "401"
    
    # 测试无效的请求数据
    run_test "无效请求数据" \
        "curl -s -w '%{http_code}' -X POST '${API_BASE}/auth/register' \
        -H 'Content-Type: application/json' \
        -d '{\"invalid\": \"data\"}'" \
        "422"
}

# 9. 性能测试
test_performance() {
    log_info "=== 9. 性能测试 ==="
    
    # 测试并发请求
    log_info "测试并发请求性能..."
    local start_time=$(date +%s)
    
    for i in {1..10}; do
        curl -s "${BASE_URL}/health" > /dev/null &
    done
    wait
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_info "10个并发请求完成时间: ${duration}秒"
    
    # 测试响应时间
    log_info "测试单个请求响应时间..."
    local response_time
    response_time=$(curl -s -w "%{time_total}" -o /dev/null "${BASE_URL}/health")
    log_info "健康检查响应时间: ${response_time}秒"
}

# 10. 数据完整性测试
test_data_integrity() {
    log_info "=== 10. 数据完整性测试 ==="
    
    if [ -z "$TEST_USER_ID" ]; then
        log_warning "跳过数据完整性测试 - 没有有效的用户ID"
        return
    fi
    
    # 测试数据一致性
    log_info "测试用户数据一致性..."
    
    # 获取用户信息
    local user_info
    user_info=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" "${API_BASE}/auth/me")
    
    if echo "$user_info" | grep -q "$TEST_USER_ID"; then
        log_success "用户数据一致性检查通过"
    else
        log_error "用户数据一致性检查失败"
    fi
    
    # 测试BMI数据关联
    log_info "测试BMI数据关联..."
    local bmi_records
    bmi_records=$(curl -s "${API_BASE}/bmi/records?user_id=$TEST_USER_ID")
    
    if echo "$bmi_records" | grep -q '"user_id"'; then
        log_success "BMI数据关联检查通过"
    else
        log_warning "BMI数据关联检查 - 可能没有记录"
    fi
}

# 生成测试报告
generate_report() {
    log_info "=== 测试报告 ==="
    echo "总测试数: $TOTAL_TESTS"
    echo "通过测试: $PASSED_TESTS"
    echo "失败测试: $FAILED_TESTS"
    echo "成功率: $(( PASSED_TESTS * 100 / TOTAL_TESTS ))%"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        log_success "所有测试通过！API服务运行正常。"
        return 0
    else
        log_error "有 $FAILED_TESTS 个测试失败，请检查API服务。"
        return 1
    fi
}

# 清理函数
cleanup() {
    log_info "清理测试数据..."
    # 这里可以添加清理测试用户的代码
    # 例如删除测试用户等
}

# 主函数
main() {
    log_info "开始 FitTracker API 综合测试"
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
    test_file_upload
    test_error_handling
    test_performance
    test_data_integrity
    
    # 生成报告
    echo ""
    generate_report
    
    # 清理
    cleanup
    
    log_info "测试完成"
}

# 捕获中断信号
trap cleanup EXIT

# 运行主函数
main "$@"
