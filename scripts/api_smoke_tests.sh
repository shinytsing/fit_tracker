#!/bin/bash

# API 接口自动化测试脚本
# 测试所有主要的 API 端点

set -e

BASE_URL="http://localhost:8080"
API_BASE="$BASE_URL/api/v1"
LOG_FILE="reports/api_test.log"
TOKEN=""

# 创建日志目录
mkdir -p reports

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 检查服务健康状态
check_health() {
    log "检查服务健康状态..."
    
    if curl -sSf "$BASE_URL/health" > /dev/null; then
        log "✓ 服务健康检查通过"
        return 0
    else
        log "✗ 服务健康检查失败"
        return 1
    fi
}

# 用户注册
register_user() {
    log "测试用户注册..."
    
    local response=$(curl -s -w "\n%{http_code}" -X POST "$API_BASE/auth/register" \
        -H "Content-Type: application/json" \
        -d '{
            "username": "testuser",
            "email": "test@example.com",
            "password": "password123",
            "nickname": "测试用户"
        }')
    
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" -eq 201 ]; then
        log "✓ 用户注册成功"
        return 0
    else
        log "✗ 用户注册失败 (HTTP $http_code): $body"
        return 1
    fi
}

# 用户登录
login_user() {
    log "测试用户登录..."
    
    local response=$(curl -s -w "\n%{http_code}" -X POST "$API_BASE/auth/login" \
        -H "Content-Type: application/json" \
        -d '{
            "username": "testuser",
            "password": "password123"
        }')
    
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" -eq 200 ]; then
        log "✓ 用户登录成功"
        TOKEN=$(echo "$body" | jq -r '.token')
        if [ "$TOKEN" = "null" ] || [ -z "$TOKEN" ]; then
            log "✗ 登录响应中没有 token"
            return 1
        fi
        log "获取到 token: ${TOKEN:0:20}..."
        return 0
    else
        log "✗ 用户登录失败 (HTTP $http_code): $body"
        return 1
    fi
}

# 创建健身房
create_gym() {
    log "测试创建健身房..."
    
    local response=$(curl -s -w "\n%{http_code}" -X POST "$API_BASE/gyms" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN" \
        -d '{
            "name": "测试健身房",
            "address": "北京市朝阳区三里屯",
            "lat": 39.9042,
            "lng": 116.4074,
            "description": "现代化健身房，设备齐全",
            "phone": "010-12345678",
            "opening_hours": "{\"monday\": \"06:00-22:00\"}",
            "facilities": "{\"pool\": true, \"sauna\": true}"
        }')
    
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" -eq 201 ]; then
        log "✓ 健身房创建成功"
        GYM_ID=$(echo "$body" | jq -r '.id')
        log "健身房 ID: $GYM_ID"
        return 0
    else
        log "✗ 健身房创建失败 (HTTP $http_code): $body"
        return 1
    fi
}

# 获取健身房列表
get_gyms() {
    log "测试获取健身房列表..."
    
    local response=$(curl -s -w "\n%{http_code}" -X GET "$API_BASE/gyms" \
        -H "Authorization: Bearer $TOKEN")
    
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" -eq 200 ]; then
        local gym_count=$(echo "$body" | jq '.gyms | length')
        log "✓ 获取健身房列表成功，共 $gym_count 个健身房"
        return 0
    else
        log "✗ 获取健身房列表失败 (HTTP $http_code): $body"
        return 1
    fi
}

# 获取健身房详情
get_gym_detail() {
    log "测试获取健身房详情..."
    
    if [ -z "$GYM_ID" ]; then
        log "✗ 没有健身房 ID，跳过测试"
        return 1
    fi
    
    local response=$(curl -s -w "\n%{http_code}" -X GET "$API_BASE/gyms/$GYM_ID" \
        -H "Authorization: Bearer $TOKEN")
    
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" -eq 200 ]; then
        local gym_name=$(echo "$body" | jq -r '.gym.name')
        local buddies_count=$(echo "$body" | jq -r '.current_buddies_count')
        log "✓ 获取健身房详情成功: $gym_name (当前搭子数: $buddies_count)"
        return 0
    else
        log "✗ 获取健身房详情失败 (HTTP $http_code): $body"
        return 1
    fi
}

# 申请加入健身房
join_gym() {
    log "测试申请加入健身房..."
    
    if [ -z "$GYM_ID" ]; then
        log "✗ 没有健身房 ID，跳过测试"
        return 1
    fi
    
    local response=$(curl -s -w "\n%{http_code}" -X POST "$API_BASE/gyms/$GYM_ID/join" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN" \
        -d '{
            "goal": "增肌",
            "time_slot": "2025-01-05T19:00:00Z",
            "duration_minutes": 60,
            "experience_level": "beginner",
            "message": "希望找到健身搭子一起训练"
        }')
    
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" -eq 201 ]; then
        local status=$(echo "$body" | jq -r '.status')
        log "✓ 申请加入健身房成功，状态: $status"
        return 0
    else
        log "✗ 申请加入健身房失败 (HTTP $http_code): $body"
        return 1
    fi
}

# 发布动态
create_post() {
    log "测试发布动态..."
    
    local response=$(curl -s -w "\n%{http_code}" -X POST "$API_BASE/posts" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN" \
        -d '{
            "content": "今天完成了30分钟的跑步训练！感觉很棒！",
            "type": "workout",
            "tags": ["健身", "跑步", "打卡"]
        }')
    
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" -eq 201 ]; then
        local content=$(echo "$body" | jq -r '.content')
        log "✓ 发布动态成功: $content"
        return 0
    else
        log "✗ 发布动态失败 (HTTP $http_code): $body"
        return 1
    fi
}

# 获取动态列表
get_posts() {
    log "测试获取动态列表..."
    
    local response=$(curl -s -w "\n%{http_code}" -X GET "$API_BASE/posts" \
        -H "Authorization: Bearer $TOKEN")
    
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" -eq 200 ]; then
        local post_count=$(echo "$body" | jq '.posts | length')
        log "✓ 获取动态列表成功，共 $post_count 条动态"
        return 0
    else
        log "✗ 获取动态列表失败 (HTTP $http_code): $body"
        return 1
    fi
}

# 获取用户信息
get_profile() {
    log "测试获取用户信息..."
    
    local response=$(curl -s -w "\n%{http_code}" -X GET "$API_BASE/users/profile" \
        -H "Authorization: Bearer $TOKEN")
    
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" -eq 200 ]; then
        local username=$(echo "$body" | jq -r '.username')
        log "✓ 获取用户信息成功: $username"
        return 0
    else
        log "✗ 获取用户信息失败 (HTTP $http_code): $body"
        return 1
    fi
}

# 主测试函数
run_tests() {
    log "开始 API 自动化测试..."
    log "测试目标: $BASE_URL"
    
    local failed_tests=0
    local total_tests=0
    
    # 定义测试函数列表
    local tests=(
        "check_health"
        "register_user"
        "login_user"
        "create_gym"
        "get_gyms"
        "get_gym_detail"
        "join_gym"
        "create_post"
        "get_posts"
        "get_profile"
    )
    
    # 执行测试
    for test_func in "${tests[@]}"; do
        total_tests=$((total_tests + 1))
        
        if $test_func; then
            log "✓ $test_func 通过"
        else
            log "✗ $test_func 失败"
            failed_tests=$((failed_tests + 1))
        fi
        
        log "---"
    done
    
    # 输出测试结果
    log "测试完成!"
    log "总测试数: $total_tests"
    log "通过数: $((total_tests - failed_tests))"
    log "失败数: $failed_tests"
    
    if [ $failed_tests -eq 0 ]; then
        log "🎉 所有测试通过!"
        return 0
    else
        log "❌ 有 $failed_tests 个测试失败"
        return 1
    fi
}

# 检查依赖
check_dependencies() {
    if ! command -v curl &> /dev/null; then
        echo "错误: 需要安装 curl"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        echo "错误: 需要安装 jq"
        exit 1
    fi
}

# 主函数
main() {
    check_dependencies
    
    # 清空日志文件
    > "$LOG_FILE"
    
    # 运行测试
    if run_tests; then
        echo "API 测试全部通过!"
        exit 0
    else
        echo "API 测试失败，请查看日志: $LOG_FILE"
        exit 1
    fi
}

# 如果直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
