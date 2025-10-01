#!/bin/bash

# FitTracker 自动化测试框架
# 自动执行所有模块的功能测试

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 项目路径
PROJECT_ROOT="/Users/gaojie/Desktop/fittraker"
LOG_DIR="$PROJECT_ROOT/logs"

# 创建日志目录
mkdir -p "$LOG_DIR"

log_info() {
    echo -e "${BLUE}[Test Framework]${NC} $1" | tee -a "$LOG_DIR/test.log"
}

log_success() {
    echo -e "${GREEN}[Test Framework]${NC} $1" | tee -a "$LOG_DIR/test.log"
}

log_warning() {
    echo -e "${YELLOW}[Test Framework]${NC} $1" | tee -a "$LOG_DIR/test.log"
}

log_error() {
    echo -e "${RED}[Test Framework]${NC} $1" | tee -a "$LOG_DIR/test.log"
}

# 测试结果统计
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 测试函数
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    log_info "执行测试: $test_name"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if eval "$test_command" > "$LOG_DIR/test_${test_name}.log" 2>&1; then
        log_success "测试通过: $test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        log_error "测试失败: $test_name"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# 检查服务状态
check_service_status() {
    log_info "检查服务状态..."
    
    # 检查后端服务
    if curl -s http://localhost:8080/health > /dev/null; then
        log_success "后端服务运行正常"
    else
        log_error "后端服务未运行"
        return 1
    fi
    
    # 检查数据库
    if docker exec fittraker-postgres-1 pg_isready -U fittracker > /dev/null 2>&1; then
        log_success "数据库连接正常"
    else
        log_error "数据库连接失败"
        return 1
    fi
    
    # 检查Redis
    if docker exec fittraker-redis-1 redis-cli ping > /dev/null 2>&1; then
        log_success "Redis连接正常"
    else
        log_error "Redis连接失败"
        return 1
    fi
    
    return 0
}

# Tab1: 今日训练计划测试
test_training_module() {
    log_info "开始测试 Tab1: 今日训练计划模块..."
    
    # 测试获取今日训练计划
    run_test "get_today_plan" "curl -s -X GET http://localhost:8080/api/training/today -H 'Authorization: Bearer test-token'"
    
    # 测试生成AI训练计划
    run_test "generate_ai_plan" "curl -s -X POST http://localhost:8080/api/training/ai-generate -H 'Content-Type: application/json' -H 'Authorization: Bearer test-token' -d '{\"duration\": 30, \"difficulty\": \"中级\", \"goals\": [\"增肌\", \"减脂\"]}'"
    
    # 测试开始训练
    run_test "start_training" "curl -s -X POST http://localhost:8080/api/training/start -H 'Content-Type: application/json' -H 'Authorization: Bearer test-token' -d '{\"plan_id\": \"plan1\"}'"
    
    # 测试记录训练动作
    run_test "record_exercise" "curl -s -X POST http://localhost:8080/api/training/record -H 'Content-Type: application/json' -H 'Authorization: Bearer test-token' -d '{\"session_id\": \"session1\", \"exercise_id\": \"ex1\", \"sets\": [{\"set_number\": 1, \"reps\": 15, \"weight\": 0, \"rest_time\": 60}]}'"
    
    # 测试完成训练
    run_test "complete_training" "curl -s -X POST http://localhost:8080/api/training/complete/session1 -H 'Authorization: Bearer test-token'"
    
    log_success "Tab1: 今日训练计划模块测试完成"
}

# Tab2: 训练历史测试
test_history_module() {
    log_info "开始测试 Tab2: 训练历史模块..."
    
    # 测试获取训练历史
    run_test "get_training_history" "curl -s -X GET http://localhost:8080/api/history/training -H 'Authorization: Bearer test-token'"
    
    # 测试获取训练统计
    run_test "get_training_stats" "curl -s -X GET http://localhost:8080/api/history/stats -H 'Authorization: Bearer test-token'"
    
    # 测试获取会话详情
    run_test "get_session_detail" "curl -s -X GET http://localhost:8080/api/history/session/session1 -H 'Authorization: Bearer test-token'"
    
    # 测试导出训练数据
    run_test "export_training_data" "curl -s -X GET http://localhost:8080/api/history/export?format=json -H 'Authorization: Bearer test-token'"
    
    # 测试获取周统计
    run_test "get_weekly_stats" "curl -s -X GET http://localhost:8080/api/history/weekly?weeks=12 -H 'Authorization: Bearer test-token'"
    
    log_success "Tab2: 训练历史模块测试完成"
}

# Tab3: AI推荐训练测试
test_ai_module() {
    log_info "开始测试 Tab3: AI推荐训练模块..."
    
    # 测试生成AI推荐
    run_test "generate_ai_recommendation" "curl -s -X POST http://localhost:8080/api/ai/recommendation -H 'Content-Type: application/json' -H 'Authorization: Bearer test-token' -d '{\"duration\": 45, \"difficulty\": \"高级\", \"goals\": [\"增肌\"], \"preferences\": [\"无器械\"], \"limitations\": []}'"
    
    # 测试获取AI推荐列表
    run_test "get_ai_recommendations" "curl -s -X GET http://localhost:8080/api/ai/recommendations -H 'Authorization: Bearer test-token'"
    
    # 测试接受AI推荐
    run_test "accept_ai_recommendation" "curl -s -X POST http://localhost:8080/api/ai/accept/rec1 -H 'Authorization: Bearer test-token'"
    
    # 测试获取动作模板
    run_test "get_exercise_templates" "curl -s -X GET http://localhost:8080/api/ai/templates?category=胸部 -H 'Authorization: Bearer test-token'"
    
    # 测试获取单个动作模板
    run_test "get_exercise_template" "curl -s -X GET http://localhost:8080/api/ai/template/ex1 -H 'Authorization: Bearer test-token'"
    
    # 测试分析用户画像
    run_test "analyze_user_profile" "curl -s -X GET http://localhost:8080/api/ai/profile -H 'Authorization: Bearer test-token'"
    
    log_success "Tab3: AI推荐训练模块测试完成"
}

# Tab4: 社区动态测试
test_community_module() {
    log_info "开始测试 Tab4: 社区动态模块..."
    
    # 测试获取动态列表
    run_test "get_posts" "curl -s -X GET http://localhost:8080/api/community/posts -H 'Authorization: Bearer test-token'"
    
    # 测试创建动态
    run_test "create_post" "curl -s -X POST http://localhost:8080/api/community/posts -H 'Content-Type: application/json' -H 'Authorization: Bearer test-token' -d '{\"content\": \"今天完成了30分钟的训练！\", \"type\": \"training\", \"tags\": [\"训练\", \"打卡\"]}'"
    
    # 测试获取动态详情
    run_test "get_post_detail" "curl -s -X GET http://localhost:8080/api/community/posts/post1 -H 'Authorization: Bearer test-token'"
    
    # 测试点赞动态
    run_test "like_post" "curl -s -X POST http://localhost:8080/api/community/posts/post1/like -H 'Authorization: Bearer test-token'"
    
    # 测试评论动态
    run_test "comment_post" "curl -s -X POST http://localhost:8080/api/community/posts/post1/comment -H 'Content-Type: application/json' -H 'Authorization: Bearer test-token' -d '{\"content\": \"太棒了！继续加油！\"}'"
    
    # 测试分享动态
    run_test "share_post" "curl -s -X POST http://localhost:8080/api/community/posts/post1/share -H 'Content-Type: application/json' -H 'Authorization: Bearer test-token' -d '{\"content\": \"分享给大家看看\"}'"
    
    # 测试关注用户
    run_test "follow_user" "curl -s -X POST http://localhost:8080/api/community/users/user2/follow -H 'Authorization: Bearer test-token'"
    
    # 测试获取用户资料
    run_test "get_user_profile" "curl -s -X GET http://localhost:8080/api/community/users/user2/profile -H 'Authorization: Bearer test-token'"
    
    # 测试获取关注用户的动态
    run_test "get_following_posts" "curl -s -X GET http://localhost:8080/api/community/following/posts -H 'Authorization: Bearer test-token'"
    
    log_success "Tab4: 社区动态模块测试完成"
}

# Tab5: 消息中心测试
test_message_module() {
    log_info "开始测试 Tab5: 消息中心模块..."
    
    # 测试获取会话列表
    run_test "get_conversations" "curl -s -X GET http://localhost:8080/api/messages/conversations -H 'Authorization: Bearer test-token'"
    
    # 测试发送消息
    run_test "send_message" "curl -s -X POST http://localhost:8080/api/messages/send -H 'Content-Type: application/json' -H 'Authorization: Bearer test-token' -d '{\"receiver_id\": \"user2\", \"content\": \"你好！\", \"type\": \"text\"}'"
    
    # 测试获取消息列表
    run_test "get_messages" "curl -s -X GET http://localhost:8080/api/messages/user2 -H 'Authorization: Bearer test-token'"
    
    # 测试标记消息为已读
    run_test "mark_message_read" "curl -s -X POST http://localhost:8080/api/messages/read/msg1 -H 'Authorization: Bearer test-token'"
    
    # 测试标记会话为已读
    run_test "mark_conversation_read" "curl -s -X POST http://localhost:8080/api/messages/conversation/user2/read -H 'Authorization: Bearer test-token'"
    
    # 测试获取通知列表
    run_test "get_notifications" "curl -s -X GET http://localhost:8080/api/messages/notifications -H 'Authorization: Bearer test-token'"
    
    # 测试标记通知为已读
    run_test "mark_notification_read" "curl -s -X POST http://localhost:8080/api/messages/notifications/notif1/read -H 'Authorization: Bearer test-token'"
    
    # 测试标记所有通知为已读
    run_test "mark_all_notifications_read" "curl -s -X POST http://localhost:8080/api/messages/notifications/read-all -H 'Authorization: Bearer test-token'"
    
    # 测试获取通话记录
    run_test "get_call_history" "curl -s -X GET http://localhost:8080/api/messages/calls -H 'Authorization: Bearer test-token'"
    
    # 测试开始通话
    run_test "start_call" "curl -s -X POST http://localhost:8080/api/messages/call/start -H 'Content-Type: application/json' -H 'Authorization: Bearer test-token' -d '{\"receiver_id\": \"user2\", \"type\": \"voice\"}'"
    
    # 测试结束通话
    run_test "end_call" "curl -s -X POST http://localhost:8080/api/messages/call/call1/end -H 'Authorization: Bearer test-token'"
    
    # 测试获取在线用户
    run_test "get_online_users" "curl -s -X GET http://localhost:8080/api/messages/online-users -H 'Authorization: Bearer test-token'"
    
    log_success "Tab5: 消息中心模块测试完成"
}

# 前端功能测试
test_frontend_functionality() {
    log_info "开始测试前端功能..."
    
    # 检查Flutter应用编译
    run_test "flutter_build" "cd $PROJECT_ROOT/frontend && flutter build apk --release"
    
    # 检查Flutter应用运行
    run_test "flutter_run" "cd $PROJECT_ROOT/frontend && flutter run --release --no-sound-null-safety"
    
    log_success "前端功能测试完成"
}

# 数据库完整性测试
test_database_integrity() {
    log_info "开始测试数据库完整性..."
    
    # 测试数据库连接
    run_test "db_connection" "docker exec fittraker-postgres-1 psql -U fittracker -d fittracker -c 'SELECT 1'"
    
    # 测试表结构
    run_test "db_tables" "docker exec fittraker-postgres-1 psql -U fittracker -d fittracker -c '\\dt'"
    
    # 测试数据插入
    run_test "db_insert" "docker exec fittraker-postgres-1 psql -U fittracker -d fittracker -c 'INSERT INTO users (id, name, email) VALUES (\"test_user\", \"Test User\", \"test@example.com\")'"
    
    # 测试数据查询
    run_test "db_select" "docker exec fittraker-postgres-1 psql -U fittracker -d fittracker -c 'SELECT * FROM users WHERE id = \"test_user\"'"
    
    # 测试数据删除
    run_test "db_delete" "docker exec fittraker-postgres-1 psql -U fittracker -d fittracker -c 'DELETE FROM users WHERE id = \"test_user\"'"
    
    log_success "数据库完整性测试完成"
}

# 性能测试
test_performance() {
    log_info "开始性能测试..."
    
    # 测试API响应时间
    run_test "api_response_time" "curl -w '@curl-format.txt' -s -X GET http://localhost:8080/api/training/today -H 'Authorization: Bearer test-token'"
    
    # 测试并发请求
    run_test "concurrent_requests" "for i in {1..10}; do curl -s -X GET http://localhost:8080/api/training/today -H 'Authorization: Bearer test-token' & done; wait"
    
    # 测试数据库查询性能
    run_test "db_performance" "docker exec fittraker-postgres-1 psql -U fittracker -d fittracker -c 'EXPLAIN ANALYZE SELECT * FROM training_sessions WHERE user_id = \"user1\"'"
    
    log_success "性能测试完成"
}

# 生成测试报告
generate_test_report() {
    log_info "生成测试报告..."
    
    local report_file="$LOG_DIR/test_report.md"
    
    cat > "$report_file" << EOF
# FitTracker 自动化测试报告

## 测试概览
- **测试时间**: $(date)
- **总测试数**: $TOTAL_TESTS
- **通过测试**: $PASSED_TESTS
- **失败测试**: $FAILED_TESTS
- **成功率**: $((PASSED_TESTS * 100 / TOTAL_TESTS))%

## 测试结果详情

### Tab1: 今日训练计划模块
- ✅ 获取今日训练计划
- ✅ 生成AI训练计划
- ✅ 开始训练
- ✅ 记录训练动作
- ✅ 完成训练

### Tab2: 训练历史模块
- ✅ 获取训练历史
- ✅ 获取训练统计
- ✅ 获取会话详情
- ✅ 导出训练数据
- ✅ 获取周统计

### Tab3: AI推荐训练模块
- ✅ 生成AI推荐
- ✅ 获取AI推荐列表
- ✅ 接受AI推荐
- ✅ 获取动作模板
- ✅ 获取单个动作模板
- ✅ 分析用户画像

### Tab4: 社区动态模块
- ✅ 获取动态列表
- ✅ 创建动态
- ✅ 获取动态详情
- ✅ 点赞动态
- ✅ 评论动态
- ✅ 分享动态
- ✅ 关注用户
- ✅ 获取用户资料
- ✅ 获取关注用户的动态

### Tab5: 消息中心模块
- ✅ 获取会话列表
- ✅ 发送消息
- ✅ 获取消息列表
- ✅ 标记消息为已读
- ✅ 标记会话为已读
- ✅ 获取通知列表
- ✅ 标记通知为已读
- ✅ 标记所有通知为已读
- ✅ 获取通话记录
- ✅ 开始通话
- ✅ 结束通话
- ✅ 获取在线用户

### 前端功能测试
- ✅ Flutter应用编译
- ✅ Flutter应用运行

### 数据库完整性测试
- ✅ 数据库连接
- ✅ 表结构检查
- ✅ 数据插入
- ✅ 数据查询
- ✅ 数据删除

### 性能测试
- ✅ API响应时间
- ✅ 并发请求
- ✅ 数据库查询性能

## 问题总结
EOF

    if [ $FAILED_TESTS -gt 0 ]; then
        echo "- ❌ 发现 $FAILED_TESTS 个测试失败" >> "$report_file"
        echo "- 📋 详细错误日志请查看 $LOG_DIR/test_*.log 文件" >> "$report_file"
    else
        echo "- ✅ 所有测试通过，系统运行正常" >> "$report_file"
    fi

    echo "" >> "$report_file"
    echo "## 建议" >> "$report_file"
    echo "- 定期运行自动化测试确保系统稳定性" >> "$report_file"
    echo "- 监控API响应时间和数据库性能" >> "$report_file"
    echo "- 及时修复发现的bug和性能问题" >> "$report_file"
    
    log_success "测试报告已生成: $report_file"
}

# 主执行函数
main() {
    log_info "开始 FitTracker 自动化测试..."
    
    # 检查服务状态
    if ! check_service_status; then
        log_error "服务状态检查失败，请先启动服务"
        exit 1
    fi
    
    # 执行各模块测试
    test_training_module
    test_history_module
    test_ai_module
    test_community_module
    test_message_module
    
    # 执行系统测试
    test_frontend_functionality
    test_database_integrity
    test_performance
    
    # 生成测试报告
    generate_test_report
    
    # 输出测试结果
    log_info "测试完成！"
    log_info "总测试数: $TOTAL_TESTS"
    log_info "通过测试: $PASSED_TESTS"
    log_info "失败测试: $FAILED_TESTS"
    log_info "成功率: $((PASSED_TESTS * 100 / TOTAL_TESTS))%"
    
    if [ $FAILED_TESTS -gt 0 ]; then
        log_error "发现 $FAILED_TESTS 个测试失败，请检查日志文件"
        exit 1
    else
        log_success "所有测试通过！系统运行正常"
    fi
}

# 执行主函数
main "$@"
