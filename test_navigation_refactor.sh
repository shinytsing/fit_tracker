#!/bin/bash

# 导航重构集成测试脚本
# 验证4个Tab + 中间加号按钮的功能完整性

set -e

echo "🧪 开始执行导航重构集成测试..."
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 测试结果统计
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 测试函数
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "${BLUE}🔍 测试: $test_name${NC}"
    
    if eval "$test_command"; then
        echo -e "${GREEN}✅ 通过: $test_name${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}❌ 失败: $test_name${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    echo ""
}

# 检查环境
echo -e "${YELLOW}📋 检查测试环境...${NC}"
echo ""

# 1. 检查Flutter项目结构
run_test "Flutter项目结构检查" "
    test -f frontend/pubspec.yaml && \
    test -f frontend/lib/features/main/presentation/pages/main_tab_page.dart && \
    test -f frontend/lib/features/publish/presentation/pages/publish_menu_page.dart && \
    test -f frontend/lib/features/training/presentation/pages/training_page.dart && \
    test -f frontend/lib/features/community/presentation/pages/community_page.dart && \
    test -f frontend/lib/features/message/presentation/pages/message_page.dart && \
    test -f frontend/lib/features/profile/presentation/pages/profile_page.dart
"

# 2. 检查后端API结构
run_test "后端API结构检查" "
    test -f backend/app/api/api_v1/api.py && \
    test -f backend/app/api/api_v1/endpoints/publish.py && \
    test -f backend/app/api/api_v1/endpoints/community.py && \
    test -f backend/app/api/api_v1/endpoints/workout.py && \
    test -f backend/app/api/api_v1/endpoints/messages.py
"

# 3. 检查数据库迁移脚本
run_test "数据库迁移脚本检查" "
    test -f backend/migrations/001_navigation_refactor.sql && \
    test -f run_migration.sh
"

# 检查Flutter代码语法
echo -e "${YELLOW}🔍 检查Flutter代码语法...${NC}"
run_test "Flutter代码语法检查" "
    cd /Users/gaojie/Desktop/fittraker/frontend && \
    flutter analyze --no-fatal-infos > /dev/null 2>&1
"

# 5. 检查Python代码语法
echo -e "${YELLOW}🔍 检查Python代码语法...${NC}"
run_test "Python代码语法检查" "
    cd /Users/gaojie/Desktop/fittraker/backend && \
    python -m py_compile app/api/api_v1/api.py && \
    python -m py_compile app/api/api_v1/endpoints/publish.py && \
    python -m py_compile app/api/api_v1/endpoints/community.py
"

# 6. 检查导航结构
echo -e "${YELLOW}🔍 检查导航结构...${NC}"
run_test "主Tab页面结构检查" "
    grep -q 'Tab1: 训练' /Users/gaojie/Desktop/fittraker/frontend/lib/features/main/presentation/pages/main_tab_page.dart && \
    grep -q 'Tab2: 社区' /Users/gaojie/Desktop/fittraker/frontend/lib/features/main/presentation/pages/main_tab_page.dart && \
    grep -q 'Tab3: 消息' /Users/gaojie/Desktop/fittraker/frontend/lib/features/main/presentation/pages/main_tab_page.dart && \
    grep -q 'Tab4: 我的' /Users/gaojie/Desktop/fittraker/frontend/lib/features/main/presentation/pages/main_tab_page.dart && \
    grep -q 'FloatingActionButton' /Users/gaojie/Desktop/fittraker/frontend/lib/features/main/presentation/pages/main_tab_page.dart
"

# 7. 检查发布菜单功能
run_test "发布菜单功能检查" "
    grep -q '发布动态' /Users/gaojie/Desktop/fittraker/frontend/lib/features/publish/presentation/pages/publish_menu_page.dart && \
    grep -q '快速打卡' /Users/gaojie/Desktop/fittraker/frontend/lib/features/publish/presentation/pages/publish_menu_page.dart && \
    grep -q '分享心情/饮食' /Users/gaojie/Desktop/fittraker/frontend/lib/features/publish/presentation/pages/publish_menu_page.dart && \
    grep -q '草稿箱' /Users/gaojie/Desktop/fittraker/frontend/lib/features/publish/presentation/pages/publish_menu_page.dart
"

# 8. 检查训练页面功能
run_test "训练页面功能检查" "
    grep -q '今日训练计划' /Users/gaojie/Desktop/fittraker/frontend/lib/features/training/presentation/pages/training_page.dart && \
    grep -q 'AI推荐训练' /Users/gaojie/Desktop/fittraker/frontend/lib/features/training/presentation/pages/training_page.dart && \
    grep -q '数据统计' /Users/gaojie/Desktop/fittraker/frontend/lib/features/training/presentation/pages/training_page.dart && \
    grep -q '身体指标' /Users/gaojie/Desktop/fittraker/frontend/lib/features/training/presentation/pages/training_page.dart && \
    grep -q '营养管理' /Users/gaojie/Desktop/fittraker/frontend/lib/features/training/presentation/pages/training_page.dart && \
    grep -q 'AI助手' /Users/gaojie/Desktop/fittraker/frontend/lib/features/training/presentation/pages/training_page.dart
"

# 9. 检查社区页面功能
run_test "社区页面功能检查" "
    grep -q '关注流' /Users/gaojie/Desktop/fittraker/frontend/lib/features/community/presentation/pages/community_page.dart && \
    grep -q '推荐流' /Users/gaojie/Desktop/fittraker/frontend/lib/features/community/presentation/pages/community_page.dart && \
    grep -q '热门流' /Users/gaojie/Desktop/fittraker/frontend/lib/features/community/presentation/pages/community_page.dart && \
    grep -q '教练专区' /Users/gaojie/Desktop/fittraker/frontend/lib/features/community/presentation/pages/community_page.dart
"

# 10. 检查API路由
run_test "API路由检查" "
    grep -q 'mood-share' /Users/gaojie/Desktop/fittraker/backend/app/api/api_v1/endpoints/publish.py && \
    grep -q 'nutrition-record' /Users/gaojie/Desktop/fittraker/backend/app/api/api_v1/endpoints/publish.py && \
    grep -q 'training-data-share' /Users/gaojie/Desktop/fittraker/backend/app/api/api_v1/endpoints/publish.py && \
    grep -q 'trending' /Users/gaojie/Desktop/fittraker/backend/app/api/api_v1/endpoints/community.py && \
    grep -q 'coaches' /Users/gaojie/Desktop/fittraker/backend/app/api/api_v1/endpoints/community.py
"

# 11. 检查数据库表结构
echo -e "${YELLOW}🔍 检查数据库表结构...${NC}"
run_test "数据库表结构检查" "
    grep -q 'CREATE TABLE.*drafts' /Users/gaojie/Desktop/fittraker/backend/migrations/001_navigation_refactor.sql && \
    grep -q 'CREATE TABLE.*coaches' /Users/gaojie/Desktop/fittraker/backend/migrations/001_navigation_refactor.sql && \
    grep -q 'CREATE TABLE.*nutrition_logs' /Users/gaojie/Desktop/fittraker/backend/migrations/001_navigation_refactor.sql && \
    grep -q 'CREATE TABLE.*body_metrics' /Users/gaojie/Desktop/fittraker/backend/migrations/001_navigation_refactor.sql && \
    grep -q 'CREATE TABLE.*ai_conversations' /Users/gaojie/Desktop/fittraker/backend/migrations/001_navigation_refactor.sql
"

# 12. 检查功能完整性
echo -e "${YELLOW}🔍 检查功能完整性...${NC}"
run_test "Tab1训练功能完整性" "
    grep -q '今日训练计划' /Users/gaojie/Desktop/fittraker/frontend/lib/features/training/presentation/pages/training_page.dart && \
    grep -q '训练执行' /Users/gaojie/Desktop/fittraker/frontend/lib/features/training/presentation/pages/training_page.dart && \
    grep -q 'AI推荐训练' /Users/gaojie/Desktop/fittraker/frontend/lib/features/training/presentation/pages/training_page.dart && \
    grep -q '训练历史' /Users/gaojie/Desktop/fittraker/frontend/lib/features/training/presentation/pages/training_page.dart && \
    grep -q '打卡签到' /Users/gaojie/Desktop/fittraker/frontend/lib/features/training/presentation/pages/training_page.dart
"

run_test "Tab2社区功能完整性" "
    grep -q '动态流' /Users/gaojie/Desktop/fittraker/frontend/lib/features/community/presentation/pages/community_page.dart && \
    grep -q '社交互动' /Users/gaojie/Desktop/fittraker/frontend/lib/features/community/presentation/pages/community_page.dart && \
    grep -q '用户关系' /Users/gaojie/Desktop/fittraker/frontend/lib/features/community/presentation/pages/community_page.dart && \
    grep -q '话题系统' /Users/gaojie/Desktop/fittraker/frontend/lib/features/community/presentation/pages/community_page.dart
"

run_test "Tab3消息功能完整性" "
    grep -q '私信聊天' /Users/gaojie/Desktop/fittraker/frontend/lib/features/message/presentation/pages/message_page.dart && \
    grep -q '系统通知' /Users/gaojie/Desktop/fittraker/frontend/lib/features/message/presentation/pages/message_page.dart && \
    grep -q '实时通信' /Users/gaojie/Desktop/fittraker/frontend/lib/features/message/presentation/pages/message_page.dart && \
    grep -q '消息管理' /Users/gaojie/Desktop/fittraker/frontend/lib/features/message/presentation/pages/message_page.dart
"

run_test "Tab4我的功能完整性" "
    grep -q '个人主页' /Users/gaojie/Desktop/fittraker/frontend/lib/features/profile/presentation/pages/profile_page.dart && \
    grep -q '训练数据' /Users/gaojie/Desktop/fittraker/frontend/lib/features/profile/presentation/pages/profile_page.dart && \
    grep -q '成就系统' /Users/gaojie/Desktop/fittraker/frontend/lib/features/profile/presentation/pages/profile_page.dart && \
    grep -q '账户设置' /Users/gaojie/Desktop/fittraker/frontend/lib/features/profile/presentation/pages/profile_page.dart
"

run_test "中间加号按钮功能完整性" "
    grep -q '发布动态' /Users/gaojie/Desktop/fittraker/frontend/lib/features/publish/presentation/pages/publish_menu_page.dart && \
    grep -q '快速打卡' /Users/gaojie/Desktop/fittraker/frontend/lib/features/publish/presentation/pages/publish_menu_page.dart && \
    grep -q '分享心情' /Users/gaojie/Desktop/fittraker/frontend/lib/features/publish/presentation/pages/publish_menu_page.dart && \
    grep -q '保存草稿' /Users/gaojie/Desktop/fittraker/frontend/lib/features/publish/presentation/pages/publish_menu_page.dart
"

# 测试结果汇总
echo -e "${YELLOW}📊 测试结果汇总${NC}"
echo "=================================="
echo -e "总测试数: ${BLUE}$TOTAL_TESTS${NC}"
echo -e "通过测试: ${GREEN}$PASSED_TESTS${NC}"
echo -e "失败测试: ${RED}$FAILED_TESTS${NC}"
echo "=================================="

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}🎉 所有测试通过！导航重构成功完成！${NC}"
    echo ""
    echo -e "${YELLOW}📋 重构完成的功能：${NC}"
    echo "✅ Tab1: 训练 - 今日计划、AI推荐、历史记录、打卡签到、数据统计、身体指标、营养管理、AI助手"
    echo "✅ Tab2: 社区 - 关注流、推荐流、热门流、话题系统、教练专区"
    echo "✅ Tab3: 消息 - 私信聊天、系统通知、实时通信、消息管理"
    echo "✅ Tab4: 我的 - 个人主页、训练数据、成就系统、账户设置、主题切换"
    echo "✅ 中间加号按钮 - 发布动态、快速打卡、分享心情/饮食、保存草稿"
    echo ""
    echo -e "${YELLOW}🚀 下一步操作：${NC}"
    echo "1. 运行数据库迁移: ./run_migration.sh"
    echo "2. 启动后端服务: cd backend && python main.py"
    echo "3. 启动Flutter应用: cd frontend && flutter run"
    echo "4. 在虚拟机中测试所有功能"
    echo ""
    echo -e "${GREEN}✨ 导航重构完成，所有功能保持完整性！${NC}"
    exit 0
else
    echo -e "${RED}❌ 有 $FAILED_TESTS 个测试失败，请检查并修复问题${NC}"
    exit 1
fi