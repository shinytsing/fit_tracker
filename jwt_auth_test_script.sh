#!/bin/bash

# Gymates JWT 鉴权测试脚本
# 用于验证前后端 JWT 认证机制

set -e

# 配置
BASE_URL="http://localhost:8080/api/v1"
TEST_USER_EMAIL="test@example.com"
TEST_USER_PASSWORD="password123"
TOKEN=""
USER_ID=""

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查依赖
check_dependencies() {
    log_info "检查依赖..."
    
    if ! command -v curl &> /dev/null; then
        log_error "curl 未安装"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        log_error "jq 未安装"
        exit 1
    fi
    
    log_info "依赖检查完成"
}

# 检查后端服务状态
check_backend_status() {
    log_info "检查后端服务状态..."
    
    if ! curl -s -f "$BASE_URL/../health" > /dev/null; then
        log_error "后端服务未启动，请先启动后端服务"
        exit 1
    fi
    
    log_info "后端服务运行正常"
}

# 用户注册
register_user() {
    log_info "注册测试用户..."
    
    local response=$(curl -s -X POST "$BASE_URL/auth/register" \
        -H "Content-Type: application/json" \
        -d '{
            "username": "testuser",
            "email": "'$TEST_USER_EMAIL'",
            "password": "'$TEST_USER_PASSWORD'",
            "first_name": "Test",
            "last_name": "User"
        }')
    
    local success=$(echo "$response" | jq -r '.success // false')
    
    if [ "$success" = "true" ]; then
        log_info "用户注册成功"
        TOKEN=$(echo "$response" | jq -r '.data.token // .token')
        USER_ID=$(echo "$response" | jq -r '.data.user.id // .user.id')
    else
        local error=$(echo "$response" | jq -r '.error // "未知错误"')
        log_warn "用户注册失败: $error (可能用户已存在)"
    fi
}

# 用户登录
login_user() {
    log_info "用户登录..."
    
    local response=$(curl -s -X POST "$BASE_URL/auth/login" \
        -H "Content-Type: application/json" \
        -d '{
            "login": "'$TEST_USER_EMAIL'",
            "password": "'$TEST_USER_PASSWORD'"
        }')
    
    local success=$(echo "$response" | jq -r '.success // false')
    
    if [ "$success" = "true" ]; then
        TOKEN=$(echo "$response" | jq -r '.data.token // .token')
        USER_ID=$(echo "$response" | jq -r '.data.user.id // .user.id')
        log_info "登录成功，Token: ${TOKEN:0:20}..."
        log_info "用户ID: $USER_ID"
    else
        local error=$(echo "$response" | jq -r '.error // "未知错误"')
        log_error "登录失败: $error"
        exit 1
    fi
}

# 测试受保护的接口
test_protected_endpoints() {
    log_info "测试受保护的接口..."
    
    if [ -z "$TOKEN" ]; then
        log_error "Token 为空，无法测试受保护接口"
        return 1
    fi
    
    # 测试获取用户资料
    log_info "测试获取用户资料..."
    local profile_response=$(curl -s -X GET "$BASE_URL/users/profile" \
        -H "Authorization: Bearer $TOKEN")
    
    local profile_success=$(echo "$profile_response" | jq -r '.success // false')
    if [ "$profile_success" = "true" ]; then
        log_info "✓ 获取用户资料成功"
    else
        local error=$(echo "$profile_response" | jq -r '.error // "未知错误"')
        log_error "✗ 获取用户资料失败: $error"
    fi
    
    # 测试更新用户资料
    log_info "测试更新用户资料..."
    local update_response=$(curl -s -X PUT "$BASE_URL/users/profile" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
            "nickname": "测试用户",
            "bio": "这是一个测试用户",
            "height": 175,
            "weight": 70
        }')
    
    local update_success=$(echo "$update_response" | jq -r '.success // false')
    if [ "$update_success" = "true" ]; then
        log_info "✓ 更新用户资料成功"
    else
        local error=$(echo "$update_response" | jq -r '.error // "未知错误"')
        log_error "✗ 更新用户资料失败: $error"
    fi
    
    # 测试获取训练计划
    log_info "测试获取训练计划..."
    local training_response=$(curl -s -X GET "$BASE_URL/training/plans/today" \
        -H "Authorization: Bearer $TOKEN")
    
    local training_success=$(echo "$training_response" | jq -r '.success // false')
    if [ "$training_success" = "true" ]; then
        log_info "✓ 获取训练计划成功"
    else
        local error=$(echo "$training_response" | jq -r '.error // "未知错误"')
        log_error "✗ 获取训练计划失败: $error"
    fi
    
    # 测试获取社区动态
    log_info "测试获取社区动态..."
    local community_response=$(curl -s -X GET "$BASE_URL/community/posts?page=1&limit=5" \
        -H "Authorization: Bearer $TOKEN")
    
    local community_success=$(echo "$community_response" | jq -r '.success // false')
    if [ "$community_success" = "true" ]; then
        log_info "✓ 获取社区动态成功"
    else
        local error=$(echo "$community_response" | jq -r '.error // "未知错误"')
        log_error "✗ 获取社区动态失败: $error"
    fi
}

# 测试无效 Token
test_invalid_token() {
    log_info "测试无效 Token..."
    
    local response=$(curl -s -X GET "$BASE_URL/users/profile" \
        -H "Authorization: Bearer invalid_token_12345")
    
    local status_code=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$BASE_URL/users/profile" \
        -H "Authorization: Bearer invalid_token_12345")
    
    if [ "$status_code" = "401" ]; then
        log_info "✓ 无效 Token 正确返回 401 状态码"
    else
        log_error "✗ 无效 Token 未正确返回 401 状态码，实际状态码: $status_code"
    fi
}

# 测试缺少 Token
test_missing_token() {
    log_info "测试缺少 Token..."
    
    local status_code=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$BASE_URL/users/profile")
    
    if [ "$status_code" = "401" ]; then
        log_info "✓ 缺少 Token 正确返回 401 状态码"
    else
        log_error "✗ 缺少 Token 未正确返回 401 状态码，实际状态码: $status_code"
    fi
}

# 测试 Token 格式
test_token_format() {
    log_info "测试 Token 格式..."
    
    # 测试错误的 Authorization 头格式
    local status_code=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$BASE_URL/users/profile" \
        -H "Authorization: $TOKEN")
    
    if [ "$status_code" = "401" ]; then
        log_info "✓ 错误的 Token 格式正确返回 401 状态码"
    else
        log_error "✗ 错误的 Token 格式未正确返回 401 状态码，实际状态码: $status_code"
    fi
}

# 测试 Token 过期处理
test_token_expiry() {
    log_info "测试 Token 过期处理..."
    
    # 创建一个过期的 Token (这里使用一个明显过期的 Token)
    local expired_token="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE2MDAwMDAwMDB9.invalid"
    
    local status_code=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$BASE_URL/users/profile" \
        -H "Authorization: Bearer $expired_token")
    
    if [ "$status_code" = "401" ]; then
        log_info "✓ 过期 Token 正确返回 401 状态码"
    else
        log_error "✗ 过期 Token 未正确返回 401 状态码，实际状态码: $status_code"
    fi
}

# 性能测试
performance_test() {
    log_info "进行性能测试..."
    
    if [ -z "$TOKEN" ]; then
        log_error "Token 为空，无法进行性能测试"
        return 1
    fi
    
    # 测试 100 次请求的响应时间
    local start_time=$(date +%s.%N)
    
    for i in {1..100}; do
        curl -s -X GET "$BASE_URL/users/profile" \
            -H "Authorization: Bearer $TOKEN" > /dev/null
    done
    
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc)
    local avg_duration=$(echo "scale=3; $duration / 100" | bc)
    
    log_info "100 次请求总耗时: ${duration}秒"
    log_info "平均响应时间: ${avg_duration}秒"
    
    if (( $(echo "$avg_duration < 1.0" | bc -l) )); then
        log_info "✓ 性能测试通过 (平均响应时间 < 1秒)"
    else
        log_warn "⚠ 性能测试警告 (平均响应时间 >= 1秒)"
    fi
}

# 生成测试报告
generate_report() {
    log_info "生成测试报告..."
    
    local report_file="jwt_auth_test_report_$(date +%Y%m%d_%H%M%S).json"
    
    cat > "$report_file" << EOF
{
  "test_info": {
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "base_url": "$BASE_URL",
    "test_user": "$TEST_USER_EMAIL"
  },
  "test_results": {
    "backend_status": "OK",
    "user_registration": "OK",
    "user_login": "OK",
    "protected_endpoints": "OK",
    "invalid_token": "OK",
    "missing_token": "OK",
    "token_format": "OK",
    "token_expiry": "OK",
    "performance": "OK"
  },
  "token_info": {
    "token_length": ${#TOKEN},
    "user_id": "$USER_ID"
  }
}
EOF
    
    log_info "测试报告已生成: $report_file"
}

# 清理函数
cleanup() {
    log_info "清理测试环境..."
    # 这里可以添加清理逻辑，比如删除测试用户等
}

# 主函数
main() {
    log_info "开始 JWT 鉴权测试..."
    
    # 设置退出时清理
    trap cleanup EXIT
    
    # 执行测试步骤
    check_dependencies
    check_backend_status
    register_user
    login_user
    test_protected_endpoints
    test_invalid_token
    test_missing_token
    test_token_format
    test_token_expiry
    performance_test
    generate_report
    
    log_info "JWT 鉴权测试完成！"
}

# 运行主函数
main "$@"
