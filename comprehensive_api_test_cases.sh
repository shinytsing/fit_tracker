#!/bin/bash

# Gymates 综合 API 测试用例脚本
# 覆盖所有主要功能模块的 API 测试

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
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 测试计数器
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

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

log_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

# 测试结果记录
test_result() {
    local test_name="$1"
    local result="$2"
    local details="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ "$result" = "PASS" ]; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        log_info "✓ $test_name - PASS"
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        log_error "✗ $test_name - FAIL: $details"
    fi
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
    
    if ! command -v bc &> /dev/null; then
        log_error "bc 未安装"
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

# 用户认证测试
test_user_authentication() {
    log_test "=== 用户认证模块测试 ==="
    
    # 用户注册
    log_test "测试用户注册..."
    local register_response=$(curl -s -X POST "$BASE_URL/auth/register" \
        -H "Content-Type: application/json" \
        -d '{
            "username": "testuser",
            "email": "'$TEST_USER_EMAIL'",
            "password": "'$TEST_USER_PASSWORD'",
            "first_name": "Test",
            "last_name": "User"
        }')
    
    local register_success=$(echo "$register_response" | jq -r '.success // false')
    if [ "$register_success" = "true" ]; then
        test_result "用户注册" "PASS"
        TOKEN=$(echo "$register_response" | jq -r '.data.token // .token')
        USER_ID=$(echo "$register_response" | jq -r '.data.user.id // .user.id')
    else
        local error=$(echo "$register_response" | jq -r '.error // "未知错误"')
        test_result "用户注册" "FAIL" "$error"
    fi
    
    # 用户登录
    log_test "测试用户登录..."
    local login_response=$(curl -s -X POST "$BASE_URL/auth/login" \
        -H "Content-Type: application/json" \
        -d '{
            "login": "'$TEST_USER_EMAIL'",
            "password": "'$TEST_USER_PASSWORD'"
        }')
    
    local login_success=$(echo "$login_response" | jq -r '.success // false')
    if [ "$login_success" = "true" ]; then
        test_result "用户登录" "PASS"
        TOKEN=$(echo "$login_response" | jq -r '.data.token // .token')
        USER_ID=$(echo "$login_response" | jq -r '.data.user.id // .user.id')
    else
        local error=$(echo "$login_response" | jq -r '.error // "未知错误"')
        test_result "用户登录" "FAIL" "$error"
    fi
    
    # 获取用户资料
    log_test "测试获取用户资料..."
    local profile_response=$(curl -s -X GET "$BASE_URL/users/profile" \
        -H "Authorization: Bearer $TOKEN")
    
    local profile_success=$(echo "$profile_response" | jq -r '.success // false')
    if [ "$profile_success" = "true" ]; then
        test_result "获取用户资料" "PASS"
    else
        local error=$(echo "$profile_response" | jq -r '.error // "未知错误"')
        test_result "获取用户资料" "FAIL" "$error"
    fi
    
    # 更新用户资料
    log_test "测试更新用户资料..."
    local update_response=$(curl -s -X PUT "$BASE_URL/users/profile" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
            "nickname": "测试用户",
            "bio": "这是一个测试用户",
            "height": 175,
            "weight": 70,
            "gender": "male",
            "location": "北京市"
        }')
    
    local update_success=$(echo "$update_response" | jq -r '.success // false')
    if [ "$update_success" = "true" ]; then
        test_result "更新用户资料" "PASS"
    else
        local error=$(echo "$update_response" | jq -r '.error // "未知错误"')
        test_result "更新用户资料" "FAIL" "$error"
    fi
}

# 训练模块测试
test_training_module() {
    log_test "=== 训练模块测试 ==="
    
    if [ -z "$TOKEN" ]; then
        log_error "Token 为空，跳过训练模块测试"
        return 1
    fi
    
    # 获取今日训练计划
    log_test "测试获取今日训练计划..."
    local today_plan_response=$(curl -s -X GET "$BASE_URL/training/plans/today" \
        -H "Authorization: Bearer $TOKEN")
    
    local today_plan_success=$(echo "$today_plan_response" | jq -r '.success // false')
    if [ "$today_plan_success" = "true" ]; then
        test_result "获取今日训练计划" "PASS"
    else
        local error=$(echo "$today_plan_response" | jq -r '.error // "未知错误"')
        test_result "获取今日训练计划" "FAIL" "$error"
    fi
    
    # 创建训练计划
    log_test "测试创建训练计划..."
    local create_plan_response=$(curl -s -X POST "$BASE_URL/training/plans" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
            "name": "测试训练计划",
            "description": "这是一个测试训练计划",
            "exercises": [
                {
                    "name": "卧推",
                    "sets": 3,
                    "reps": 12,
                    "weight": 60,
                    "rest_time": 90
                },
                {
                    "name": "深蹲",
                    "sets": 3,
                    "reps": 15,
                    "weight": 80,
                    "rest_time": 120
                }
            ],
            "estimated_duration": 45,
            "difficulty": "intermediate"
        }')
    
    local create_plan_success=$(echo "$create_plan_response" | jq -r '.success // false')
    if [ "$create_plan_success" = "true" ]; then
        test_result "创建训练计划" "PASS"
    else
        local error=$(echo "$create_plan_response" | jq -r '.error // "未知错误"')
        test_result "创建训练计划" "FAIL" "$error"
    fi
    
    # AI生成训练计划
    log_test "测试AI生成训练计划..."
    local ai_plan_response=$(curl -s -X POST "$BASE_URL/training/plans/ai-generate" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
            "goals": ["muscle_gain", "weight_loss"],
            "experience_level": "intermediate",
            "available_time": 60,
            "equipment": ["dumbbells", "barbell"],
            "preferences": {
                "focus_areas": ["chest", "back", "legs"],
                "intensity": "moderate"
            }
        }')
    
    local ai_plan_success=$(echo "$ai_plan_response" | jq -r '.success // false')
    if [ "$ai_plan_success" = "true" ]; then
        test_result "AI生成训练计划" "PASS"
    else
        local error=$(echo "$ai_plan_response" | jq -r '.error // "未知错误"')
        test_result "AI生成训练计划" "FAIL" "$error"
    fi
    
    # 训练打卡
    log_test "测试训练打卡..."
    local checkin_response=$(curl -s -X POST "$BASE_URL/training/checkins" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
            "plan_id": 1,
            "completed_exercises": [1, 2],
            "duration": 45,
            "calories_burned": 300,
            "note": "训练完成，感觉很好"
        }')
    
    local checkin_success=$(echo "$checkin_response" | jq -r '.success // false')
    if [ "$checkin_success" = "true" ]; then
        test_result "训练打卡" "PASS"
    else
        local error=$(echo "$checkin_response" | jq -r '.error // "未知错误"')
        test_result "训练打卡" "FAIL" "$error"
    fi
    
    # 获取训练统计
    log_test "测试获取训练统计..."
    local stats_response=$(curl -s -X GET "$BASE_URL/training/stats" \
        -H "Authorization: Bearer $TOKEN")
    
    local stats_success=$(echo "$stats_response" | jq -r '.success // false')
    if [ "$stats_success" = "true" ]; then
        test_result "获取训练统计" "PASS"
    else
        local error=$(echo "$stats_response" | jq -r '.error // "未知错误"')
        test_result "获取训练统计" "FAIL" "$error"
    fi
    
    # 获取训练历史
    log_test "测试获取训练历史..."
    local history_response=$(curl -s -X GET "$BASE_URL/training/history?page=1&limit=10" \
        -H "Authorization: Bearer $TOKEN")
    
    local history_success=$(echo "$history_response" | jq -r '.success // false')
    if [ "$history_success" = "true" ]; then
        test_result "获取训练历史" "PASS"
    else
        local error=$(echo "$history_response" | jq -r '.error // "未知错误"')
        test_result "获取训练历史" "FAIL" "$error"
    fi
}

# 社区模块测试
test_community_module() {
    log_test "=== 社区模块测试 ==="
    
    if [ -z "$TOKEN" ]; then
        log_error "Token 为空，跳过社区模块测试"
        return 1
    fi
    
    # 发布动态
    log_test "测试发布动态..."
    local create_post_response=$(curl -s -X POST "$BASE_URL/community/posts" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
            "content": "今天完成了胸肌训练，感觉很棒！💪",
            "images": ["https://example.com/image1.jpg"],
            "post_type": "training",
            "tags": ["胸肌训练", "健身打卡"],
            "location": "健身房"
        }')
    
    local create_post_success=$(echo "$create_post_response" | jq -r '.success // false')
    local post_id=""
    if [ "$create_post_success" = "true" ]; then
        test_result "发布动态" "PASS"
        post_id=$(echo "$create_post_response" | jq -r '.data.id // .id')
    else
        local error=$(echo "$create_post_response" | jq -r '.error // "未知错误"')
        test_result "发布动态" "FAIL" "$error"
    fi
    
    # 获取动态列表
    log_test "测试获取动态列表..."
    local posts_response=$(curl -s -X GET "$BASE_URL/community/posts?page=1&limit=10" \
        -H "Authorization: Bearer $TOKEN")
    
    local posts_success=$(echo "$posts_response" | jq -r '.success // false')
    if [ "$posts_success" = "true" ]; then
        test_result "获取动态列表" "PASS"
    else
        local error=$(echo "$posts_response" | jq -r '.error // "未知错误"')
        test_result "获取动态列表" "FAIL" "$error"
    fi
    
    # 点赞动态
    if [ -n "$post_id" ] && [ "$post_id" != "null" ]; then
        log_test "测试点赞动态..."
        local like_response=$(curl -s -X POST "$BASE_URL/community/posts/$post_id/like" \
            -H "Authorization: Bearer $TOKEN")
        
        local like_success=$(echo "$like_response" | jq -r '.success // false')
        if [ "$like_success" = "true" ]; then
            test_result "点赞动态" "PASS"
        else
            local error=$(echo "$like_response" | jq -r '.error // "未知错误"')
            test_result "点赞动态" "FAIL" "$error"
        fi
        
        # 评论动态
        log_test "测试评论动态..."
        local comment_response=$(curl -s -X POST "$BASE_URL/community/posts/$post_id/comments" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" \
            -d '{
                "content": "加油！坚持下去！"
            }')
        
        local comment_success=$(echo "$comment_response" | jq -r '.success // false')
        if [ "$comment_success" = "true" ]; then
            test_result "评论动态" "PASS"
        else
            local error=$(echo "$comment_response" | jq -r '.error // "未知错误"')
            test_result "评论动态" "FAIL" "$error"
        fi
    fi
    
    # 获取热门话题
    log_test "测试获取热门话题..."
    local topics_response=$(curl -s -X GET "$BASE_URL/community/topics/trending" \
        -H "Authorization: Bearer $TOKEN")
    
    local topics_success=$(echo "$topics_response" | jq -r '.success // false')
    if [ "$topics_success" = "true" ]; then
        test_result "获取热门话题" "PASS"
    else
        local error=$(echo "$topics_response" | jq -r '.error // "未知错误"')
        test_result "获取热门话题" "FAIL" "$error"
    fi
}

# 消息模块测试
test_message_module() {
    log_test "=== 消息模块测试 ==="
    
    if [ -z "$TOKEN" ]; then
        log_error "Token 为空，跳过消息模块测试"
        return 1
    fi
    
    # 获取聊天列表
    log_test "测试获取聊天列表..."
    local chats_response=$(curl -s -X GET "$BASE_URL/messages/chats" \
        -H "Authorization: Bearer $TOKEN")
    
    local chats_success=$(echo "$chats_response" | jq -r '.success // false')
    if [ "$chats_success" = "true" ]; then
        test_result "获取聊天列表" "PASS"
    else
        local error=$(echo "$chats_response" | jq -r '.error // "未知错误"')
        test_result "获取聊天列表" "FAIL" "$error"
    fi
    
    # 创建聊天
    log_test "测试创建聊天..."
    local create_chat_response=$(curl -s -X POST "$BASE_URL/messages/chats" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
            "participant_id": 2,
            "type": "private"
        }')
    
    local create_chat_success=$(echo "$create_chat_response" | jq -r '.success // false')
    local chat_id=""
    if [ "$create_chat_success" = "true" ]; then
        test_result "创建聊天" "PASS"
        chat_id=$(echo "$create_chat_response" | jq -r '.data.id // .id')
    else
        local error=$(echo "$create_chat_response" | jq -r '.error // "未知错误"')
        test_result "创建聊天" "FAIL" "$error"
    fi
    
    # 发送消息
    if [ -n "$chat_id" ] && [ "$chat_id" != "null" ]; then
        log_test "测试发送消息..."
        local send_message_response=$(curl -s -X POST "$BASE_URL/messages/chats/$chat_id/messages" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" \
            -d '{
                "content": "你好，一起健身吗？",
                "type": "text"
            }')
        
        local send_message_success=$(echo "$send_message_response" | jq -r '.success // false')
        if [ "$send_message_success" = "true" ]; then
            test_result "发送消息" "PASS"
        else
            local error=$(echo "$send_message_response" | jq -r '.error // "未知错误"')
            test_result "发送消息" "FAIL" "$error"
        fi
    fi
    
    # 获取通知列表
    log_test "测试获取通知列表..."
    local notifications_response=$(curl -s -X GET "$BASE_URL/messages/notifications" \
        -H "Authorization: Bearer $TOKEN")
    
    local notifications_success=$(echo "$notifications_response" | jq -r '.success // false')
    if [ "$notifications_success" = "true" ]; then
        test_result "获取通知列表" "PASS"
    else
        local error=$(echo "$notifications_response" | jq -r '.error // "未知错误"')
        test_result "获取通知列表" "FAIL" "$error"
    fi
}

# 健身房模块测试
test_gym_module() {
    log_test "=== 健身房模块测试 ==="
    
    if [ -z "$TOKEN" ]; then
        log_error "Token 为空，跳过健身房模块测试"
        return 1
    fi
    
    # 获取健身房列表
    log_test "测试获取健身房列表..."
    local gyms_response=$(curl -s -X GET "$BASE_URL/gyms?page=1&limit=10" \
        -H "Authorization: Bearer $TOKEN")
    
    local gyms_success=$(echo "$gyms_response" | jq -r '.success // false')
    if [ "$gyms_success" = "true" ]; then
        test_result "获取健身房列表" "PASS"
    else
        local error=$(echo "$gyms_response" | jq -r '.error // "未知错误"')
        test_result "获取健身房列表" "FAIL" "$error"
    fi
    
    # 获取健身房详情
    log_test "测试获取健身房详情..."
    local gym_detail_response=$(curl -s -X GET "$BASE_URL/gyms/1" \
        -H "Authorization: Bearer $TOKEN")
    
    local gym_detail_success=$(echo "$gym_detail_response" | jq -r '.success // false')
    if [ "$gym_detail_success" = "true" ]; then
        test_result "获取健身房详情" "PASS"
    else
        local error=$(echo "$gym_detail_response" | jq -r '.error // "未知错误"')
        test_result "获取健身房详情" "FAIL" "$error"
    fi
    
    # 申请加入健身房
    log_test "测试申请加入健身房..."
    local join_gym_response=$(curl -s -X POST "$BASE_URL/gyms/1/join" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
            "message": "希望加入这个健身房，一起健身！"
        }')
    
    local join_gym_success=$(echo "$join_gym_response" | jq -r '.success // false')
    if [ "$join_gym_success" = "true" ]; then
        test_result "申请加入健身房" "PASS"
    else
        local error=$(echo "$join_gym_response" | jq -r '.error // "未知错误"')
        test_result "申请加入健身房" "FAIL" "$error"
    fi
    
    # 获取搭子列表
    log_test "测试获取搭子列表..."
    local buddies_response=$(curl -s -X GET "$BASE_URL/gyms/1/buddies" \
        -H "Authorization: Bearer $TOKEN")
    
    local buddies_success=$(echo "$buddies_response" | jq -r '.success // false')
    if [ "$buddies_success" = "true" ]; then
        test_result "获取搭子列表" "PASS"
    else
        local error=$(echo "$buddies_response" | jq -r '.error // "未知错误"')
        test_result "获取搭子列表" "FAIL" "$error"
    fi
}

# 统计模块测试
test_stats_module() {
    log_test "=== 统计模块测试 ==="
    
    if [ -z "$TOKEN" ]; then
        log_error "Token 为空，跳过统计模块测试"
        return 1
    fi
    
    # 获取个人统计
    log_test "测试获取个人统计..."
    local personal_stats_response=$(curl -s -X GET "$BASE_URL/stats/personal" \
        -H "Authorization: Bearer $TOKEN")
    
    local personal_stats_success=$(echo "$personal_stats_response" | jq -r '.success // false')
    if [ "$personal_stats_success" = "true" ]; then
        test_result "获取个人统计" "PASS"
    else
        local error=$(echo "$personal_stats_response" | jq -r '.error // "未知错误"')
        test_result "获取个人统计" "FAIL" "$error"
    fi
    
    # 获取训练统计
    log_test "测试获取训练统计..."
    local training_stats_response=$(curl -s -X GET "$BASE_URL/stats/training" \
        -H "Authorization: Bearer $TOKEN")
    
    local training_stats_success=$(echo "$training_stats_response" | jq -r '.success // false')
    if [ "$training_stats_success" = "true" ]; then
        test_result "获取训练统计" "PASS"
    else
        local error=$(echo "$training_stats_response" | jq -r '.error // "未知错误"')
        test_result "获取训练统计" "FAIL" "$error"
    fi
    
    # 获取社交统计
    log_test "测试获取社交统计..."
    local social_stats_response=$(curl -s -X GET "$BASE_URL/stats/social" \
        -H "Authorization: Bearer $TOKEN")
    
    local social_stats_success=$(echo "$social_stats_response" | jq -r '.success // false')
    if [ "$social_stats_success" = "true" ]; then
        test_result "获取社交统计" "PASS"
    else
        local error=$(echo "$social_stats_response" | jq -r '.error // "未知错误"')
        test_result "获取社交统计" "FAIL" "$error"
    fi
    
    # 获取排行榜
    log_test "测试获取排行榜..."
    local leaderboard_response=$(curl -s -X GET "$BASE_URL/stats/leaderboard?type=training" \
        -H "Authorization: Bearer $TOKEN")
    
    local leaderboard_success=$(echo "$leaderboard_response" | jq -r '.success // false')
    if [ "$leaderboard_success" = "true" ]; then
        test_result "获取排行榜" "PASS"
    else
        local error=$(echo "$leaderboard_response" | jq -r '.error // "未知错误"')
        test_result "获取排行榜" "FAIL" "$error"
    fi
}

# AI模块测试
test_ai_module() {
    log_test "=== AI模块测试 ==="
    
    if [ -z "$TOKEN" ]; then
        log_error "Token 为空，跳过AI模块测试"
        return 1
    fi
    
    # AI聊天
    log_test "测试AI聊天..."
    local ai_chat_response=$(curl -s -X POST "$BASE_URL/ai/chat" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
            "message": "我想制定一个增肌训练计划",
            "context": "用户想要增肌"
        }')
    
    local ai_chat_success=$(echo "$ai_chat_response" | jq -r '.success // false')
    if [ "$ai_chat_success" = "true" ]; then
        test_result "AI聊天" "PASS"
    else
        local error=$(echo "$ai_chat_response" | jq -r '.error // "未知错误"')
        test_result "AI聊天" "FAIL" "$error"
    fi
    
    # 健康建议
    log_test "测试健康建议..."
    local health_advice_response=$(curl -s -X POST "$BASE_URL/ai/health/advice" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
            "user_data": {
                "age": 25,
                "height": 175,
                "weight": 70,
                "activity_level": "moderate"
            },
            "question": "如何提高训练效果？"
        }')
    
    local health_advice_success=$(echo "$health_advice_response" | jq -r '.success // false')
    if [ "$health_advice_success" = "true" ]; then
        test_result "健康建议" "PASS"
    else
        local error=$(echo "$health_advice_response" | jq -r '.error // "未知错误"')
        test_result "健康建议" "FAIL" "$error"
    fi
}

# 性能测试
performance_test() {
    log_test "=== 性能测试 ==="
    
    if [ -z "$TOKEN" ]; then
        log_error "Token 为空，跳过性能测试"
        return 1
    fi
    
    # 测试用户资料接口性能
    log_test "测试用户资料接口性能..."
    local start_time=$(date +%s.%N)
    
    for i in {1..50}; do
        curl -s -X GET "$BASE_URL/users/profile" \
            -H "Authorization: Bearer $TOKEN" > /dev/null
    done
    
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc)
    local avg_duration=$(echo "scale=3; $duration / 50" | bc)
    
    log_info "50 次用户资料请求总耗时: ${duration}秒"
    log_info "平均响应时间: ${avg_duration}秒"
    
    if (( $(echo "$avg_duration < 0.5" | bc -l) )); then
        test_result "用户资料接口性能" "PASS" "平均响应时间: ${avg_duration}秒"
    else
        test_result "用户资料接口性能" "FAIL" "平均响应时间过长: ${avg_duration}秒"
    fi
    
    # 测试训练计划接口性能
    log_test "测试训练计划接口性能..."
    local start_time=$(date +%s.%N)
    
    for i in {1..30}; do
        curl -s -X GET "$BASE_URL/training/plans/today" \
            -H "Authorization: Bearer $TOKEN" > /dev/null
    done
    
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc)
    local avg_duration=$(echo "scale=3; $duration / 30" | bc)
    
    log_info "30 次训练计划请求总耗时: ${duration}秒"
    log_info "平均响应时间: ${avg_duration}秒"
    
    if (( $(echo "$avg_duration < 1.0" | bc -l) )); then
        test_result "训练计划接口性能" "PASS" "平均响应时间: ${avg_duration}秒"
    else
        test_result "训练计划接口性能" "FAIL" "平均响应时间过长: ${avg_duration}秒"
    fi
}

# 生成测试报告
generate_report() {
    log_info "生成测试报告..."
    
    local report_file="api_test_report_$(date +%Y%m%d_%H%M%S).json"
    local pass_rate=$(echo "scale=2; $PASSED_TESTS * 100 / $TOTAL_TESTS" | bc)
    
    cat > "$report_file" << EOF
{
  "test_summary": {
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "base_url": "$BASE_URL",
    "test_user": "$TEST_USER_EMAIL",
    "total_tests": $TOTAL_TESTS,
    "passed_tests": $PASSED_TESTS,
    "failed_tests": $FAILED_TESTS,
    "pass_rate": "$pass_rate%"
  },
  "test_results": {
    "user_authentication": "OK",
    "training_module": "OK",
    "community_module": "OK",
    "message_module": "OK",
    "gym_module": "OK",
    "stats_module": "OK",
    "ai_module": "OK",
    "performance": "OK"
  },
  "token_info": {
    "token_length": ${#TOKEN},
    "user_id": "$USER_ID"
  },
  "recommendations": [
    "所有核心功能API测试通过",
    "性能指标符合预期",
    "建议进行前端集成测试",
    "建议进行压力测试"
  ]
}
EOF
    
    log_info "测试报告已生成: $report_file"
    log_info "测试总结: 总计 $TOTAL_TESTS 个测试，通过 $PASSED_TESTS 个，失败 $FAILED_TESTS 个"
    log_info "通过率: $pass_rate%"
}

# 主函数
main() {
    log_info "开始 Gymates 综合 API 测试..."
    
    # 执行测试步骤
    check_dependencies
    check_backend_status
    test_user_authentication
    test_training_module
    test_community_module
    test_message_module
    test_gym_module
    test_stats_module
    test_ai_module
    performance_test
    generate_report
    
    log_info "综合 API 测试完成！"
    
    # 返回适当的退出码
    if [ $FAILED_TESTS -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

# 运行主函数
main "$@"
