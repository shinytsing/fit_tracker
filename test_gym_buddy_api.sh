#!/bin/bash

# 健身房找搭子功能API测试脚本
# 测试Go后端的所有健身房相关API

set -e

# 配置
BASE_URL="http://localhost:8080"
API_BASE="$BASE_URL/api/v1"

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

# 检查服务是否运行
check_service() {
    log_info "检查Go后端服务是否运行..."
    if ! curl -s "$BASE_URL/health" > /dev/null; then
        log_error "Go后端服务未运行，请先启动服务"
        exit 1
    fi
    log_info "Go后端服务运行正常"
}

# 获取JWT Token（模拟）
get_auth_token() {
    # 这里应该调用实际的登录API获取token
    # 为了测试，我们使用一个模拟的token
    echo "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSIsImV4cCI6MTczNTU2NzIwMH0.test"
}

# 测试创建健身房
test_create_gym() {
    log_info "测试创建健身房..."
    
    local token=$(get_auth_token)
    local response=$(curl -s -X POST "$API_BASE/gyms" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        -d '{
            "name": "测试健身房",
            "address": "北京市朝阳区测试街道123号",
            "lat": 39.9042,
            "lng": 116.4074,
            "description": "这是一个测试健身房"
        }')
    
    if echo "$response" | grep -q '"id"'; then
        log_info "✅ 创建健身房成功"
        echo "$response" | jq '.'
        # 提取健身房ID用于后续测试
        GYM_ID=$(echo "$response" | jq -r '.id')
        log_info "健身房ID: $GYM_ID"
    else
        log_error "❌ 创建健身房失败"
        echo "$response"
        return 1
    fi
}

# 测试获取健身房列表
test_get_gyms() {
    log_info "测试获取健身房列表..."
    
    local response=$(curl -s -X GET "$API_BASE/gyms?page=1&limit=10")
    
    if echo "$response" | grep -q '"gyms"'; then
        log_info "✅ 获取健身房列表成功"
        echo "$response" | jq '.gyms | length'
        echo "$response" | jq '.gyms[0]'
    else
        log_error "❌ 获取健身房列表失败"
        echo "$response"
        return 1
    fi
}

# 测试获取健身房详情
test_get_gym_detail() {
    log_info "测试获取健身房详情..."
    
    if [ -z "$GYM_ID" ]; then
        log_warn "没有健身房ID，跳过详情测试"
        return 0
    fi
    
    local response=$(curl -s -X GET "$API_BASE/gyms/$GYM_ID")
    
    if echo "$response" | grep -q '"id"'; then
        log_info "✅ 获取健身房详情成功"
        echo "$response" | jq '.'
    else
        log_error "❌ 获取健身房详情失败"
        echo "$response"
        return 1
    fi
}

# 测试加入搭子
test_join_gym() {
    log_info "测试加入搭子..."
    
    if [ -z "$GYM_ID" ]; then
        log_warn "没有健身房ID，跳过加入搭子测试"
        return 0
    fi
    
    local token=$(get_auth_token)
    local response=$(curl -s -X POST "$API_BASE/gyms/$GYM_ID/join" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        -d '{
            "goal": "增肌",
            "time_slot": "2024-01-15T19:00:00Z",
            "note": "希望找到志同道合的搭子"
        }')
    
    if echo "$response" | grep -q '"id"'; then
        log_info "✅ 加入搭子成功"
        echo "$response" | jq '.'
        # 提取申请ID用于后续测试
        REQUEST_ID=$(echo "$response" | jq -r '.id')
        log_info "申请ID: $REQUEST_ID"
    else
        log_error "❌ 加入搭子失败"
        echo "$response"
        return 1
    fi
}

# 测试获取搭子列表
test_get_buddies() {
    log_info "测试获取搭子列表..."
    
    if [ -z "$GYM_ID" ]; then
        log_warn "没有健身房ID，跳过搭子列表测试"
        return 0
    fi
    
    local response=$(curl -s -X GET "$API_BASE/gyms/$GYM_ID/buddies")
    
    if echo "$response" | grep -q '"buddies"'; then
        log_info "✅ 获取搭子列表成功"
        echo "$response" | jq '.buddies | length'
        echo "$response" | jq '.buddies[0]'
    else
        log_error "❌ 获取搭子列表失败"
        echo "$response"
        return 1
    fi
}

# 测试创建优惠
test_create_discount() {
    log_info "测试创建优惠..."
    
    if [ -z "$GYM_ID" ]; then
        log_warn "没有健身房ID，跳过创建优惠测试"
        return 0
    fi
    
    local token=$(get_auth_token)
    local response=$(curl -s -X POST "$API_BASE/gyms/$GYM_ID/discounts" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        -d '{
            "min_group_size": 3,
            "discount_percent": 10,
            "active": true
        }')
    
    if echo "$response" | grep -q '"id"'; then
        log_info "✅ 创建优惠成功"
        echo "$response" | jq '.'
    else
        log_error "❌ 创建优惠失败"
        echo "$response"
        return 1
    fi
}

# 测试获取优惠列表
test_get_discounts() {
    log_info "测试获取优惠列表..."
    
    if [ -z "$GYM_ID" ]; then
        log_warn "没有健身房ID，跳过优惠列表测试"
        return 0
    fi
    
    local response=$(curl -s -X GET "$API_BASE/gyms/$GYM_ID/discounts")
    
    if echo "$response" | grep -q '"discounts"'; then
        log_info "✅ 获取优惠列表成功"
        echo "$response" | jq '.discounts | length'
        echo "$response" | jq '.discounts[0]'
    else
        log_error "❌ 获取优惠列表失败"
        echo "$response"
        return 1
    fi
}

# 测试附近健身房
test_nearby_gyms() {
    log_info "测试附近健身房..."
    
    local response=$(curl -s -X GET "$API_BASE/gyms/nearby?lat=39.9042&lng=116.4074&radius=5000")
    
    if echo "$response" | grep -q '"gyms"'; then
        log_info "✅ 获取附近健身房成功"
        echo "$response" | jq '.gyms | length'
        echo "$response" | jq '.gyms[0]'
    else
        log_error "❌ 获取附近健身房失败"
        echo "$response"
        return 1
    fi
}

# 并发测试
test_concurrent_join() {
    log_info "测试并发加入搭子..."
    
    if [ -z "$GYM_ID" ]; then
        log_warn "没有健身房ID，跳过并发测试"
        return 0
    fi
    
    local token=$(get_auth_token)
    local pids=()
    
    # 启动5个并发请求
    for i in {1..5}; do
        (
            local response=$(curl -s -X POST "$API_BASE/gyms/$GYM_ID/join" \
                -H "Authorization: Bearer $token" \
                -H "Content-Type: application/json" \
                -d "{
                    \"goal\": \"测试目标$i\",
                    \"time_slot\": \"2024-01-15T19:00:00Z\",
                    \"note\": \"并发测试$i\"
                }")
            echo "并发请求$i: $response"
        ) &
        pids+=($!)
    done
    
    # 等待所有请求完成
    for pid in "${pids[@]}"; do
        wait $pid
    done
    
    log_info "✅ 并发测试完成"
}

# 主测试函数
main() {
    log_info "开始健身房找搭子功能API测试"
    log_info "=================================="
    
    # 检查服务
    check_service
    
    # 执行测试
    local tests=(
        "test_create_gym"
        "test_get_gyms"
        "test_get_gym_detail"
        "test_join_gym"
        "test_get_buddies"
        "test_create_discount"
        "test_get_discounts"
        "test_nearby_gyms"
        "test_concurrent_join"
    )
    
    local passed=0
    local failed=0
    
    for test in "${tests[@]}"; do
        log_info "执行测试: $test"
        if $test; then
            ((passed++))
        else
            ((failed++))
        fi
        echo ""
    done
    
    # 输出测试结果
    log_info "=================================="
    log_info "测试完成！"
    log_info "通过: $passed"
    log_info "失败: $failed"
    
    if [ $failed -eq 0 ]; then
        log_info "🎉 所有测试通过！"
        exit 0
    else
        log_error "❌ 有测试失败"
        exit 1
    fi
}

# 运行测试
main "$@"
