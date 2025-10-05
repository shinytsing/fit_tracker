#!/bin/bash

# FitTracker 全链路按钮测试与自动修复系统
# 主执行脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 项目路径
PROJECT_ROOT="/Users/gaojie/Desktop/fittraker"
BACKEND_PATH="$PROJECT_ROOT/backend"
FRONTEND_PATH="$PROJECT_ROOT/frontend"
TEST_APP_PATH="$PROJECT_ROOT/test_app"

# 日志文件
LOG_FILE="$PROJECT_ROOT/test_execution.log"
REPORT_DIR="$PROJECT_ROOT/test_reports"

# 创建报告目录
mkdir -p "$REPORT_DIR"

# 日志函数
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] ✅${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ❌${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️${NC} $1" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')] ℹ️${NC} $1" | tee -a "$LOG_FILE"
}

# 检查依赖
check_dependencies() {
    log "检查系统依赖..."
    
    # 检查Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi
    
    # 检查Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose 未安装，请先安装 Docker Compose"
        exit 1
    fi
    
    # 检查Python
    if ! command -v python3 &> /dev/null; then
        log_error "Python3 未安装，请先安装 Python3"
        exit 1
    fi
    
    # 检查Flutter
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter 未安装，请先安装 Flutter"
        exit 1
    fi
    
    # 检查Go
    if ! command -v go &> /dev/null; then
        log_warning "Go 未安装，某些功能可能不可用"
    fi
    
    log_success "依赖检查完成"
}

# 启动服务
start_services() {
    log "启动 FitTracker 服务..."
    
    # 启动Docker服务
    log "启动 Docker 服务..."
    cd "$PROJECT_ROOT"
    docker-compose up -d
    
    # 等待服务启动
    log "等待服务启动..."
    sleep 15
    
    # 检查服务状态
    check_service_health
}

# 检查服务健康状态
check_service_health() {
    log "检查服务健康状态..."
    
    # 检查后端服务
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s http://localhost:8080/health > /dev/null 2>&1; then
            log_success "后端服务健康检查通过"
            break
        else
            log_info "等待后端服务启动... (尝试 $attempt/$max_attempts)"
            sleep 2
            ((attempt++))
        fi
    done
    
    if [ $attempt -gt $max_attempts ]; then
        log_error "后端服务启动失败"
        return 1
    fi
    
    # 检查数据库
    if curl -s http://localhost:8080/health/database > /dev/null 2>&1; then
        log_success "数据库连接正常"
    else
        log_warning "数据库连接检查失败"
    fi
    
    # 检查Redis
    if docker exec fittracker-redis redis-cli ping > /dev/null 2>&1; then
        log_success "Redis 连接正常"
    else
        log_warning "Redis 连接检查失败"
    fi
}

# 运行Dart测试
run_dart_tests() {
    log "运行 Dart 全链路按钮测试..."
    
    cd "$PROJECT_ROOT"
    
    # 运行主测试系统
    dart run comprehensive_button_test_system.dart
    
    if [ $? -eq 0 ]; then
        log_success "Dart 测试完成"
    else
        log_error "Dart 测试失败"
        return 1
    fi
}

# 运行Flutter测试应用
run_flutter_test_app() {
    log "启动 Flutter 测试应用..."
    
    cd "$TEST_APP_PATH"
    
    # 获取依赖
    flutter pub get
    
    # 运行测试应用
    log_info "启动 Flutter 测试应用..."
    flutter run --debug &
    
    local flutter_pid=$!
    log_info "Flutter 测试应用 PID: $flutter_pid"
    
    # 等待应用启动
    sleep 10
    
    return 0
}

# 运行API测试
run_api_tests() {
    log "运行 API 测试..."
    
    cd "$PROJECT_ROOT"
    
    # 运行现有的API测试脚本
    if [ -f "test_all_apis.sh" ]; then
        bash test_all_apis.sh
    else
        log_warning "API 测试脚本不存在，跳过"
    fi
}

# 运行数据库测试
run_database_tests() {
    log "运行数据库测试..."
    
    cd "$PROJECT_ROOT"
    
    # 运行数据库验证
    dart run database_validation_system.dart
    
    if [ $? -eq 0 ]; then
        log_success "数据库测试完成"
    else
        log_error "数据库测试失败"
        return 1
    fi
}

# 运行自动修复测试
run_auto_fix_tests() {
    log "运行自动修复测试..."
    
    cd "$PROJECT_ROOT"
    
    # 运行自动修复系统
    dart run auto_fix_system.dart
    
    if [ $? -eq 0 ]; then
        log_success "自动修复测试完成"
    else
        log_error "自动修复测试失败"
        return 1
    fi
}

# 生成测试报告
generate_reports() {
    log "生成测试报告..."
    
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local report_file="$REPORT_DIR/fittracker_test_report_$timestamp"
    
    # 生成JSON报告
    if [ -f "fittracker_comprehensive_test_report.json" ]; then
        cp fittracker_comprehensive_test_report.json "$report_file.json"
        log_success "JSON 报告已生成: $report_file.json"
    fi
    
    # 生成HTML报告
    if [ -f "fittracker_comprehensive_test_report.html" ]; then
        cp fittracker_comprehensive_test_report.html "$report_file.html"
        log_success "HTML 报告已生成: $report_file.html"
    fi
    
    # 生成Markdown报告
    if [ -f "fittracker_comprehensive_test_report.md" ]; then
        cp fittracker_comprehensive_test_report.md "$report_file.md"
        log_success "Markdown 报告已生成: $report_file.md"
    fi
    
    # 生成控制台报告
    generate_console_report "$report_file"
}

# 生成控制台报告
generate_console_report() {
    local report_file="$1"
    
    log "生成控制台报告..."
    
    cat > "$report_file.txt" << EOF
========================================
FitTracker 全链路按钮测试与自动修复报告
========================================
测试时间: $(date '+%Y-%m-%d %H:%M:%S')
测试环境: macOS $(sw_vers -productVersion)
项目路径: $PROJECT_ROOT

========================================
服务状态检查
========================================
后端服务: $(curl -s http://localhost:8080/health > /dev/null 2>&1 && echo "✅ 正常" || echo "❌ 异常")
数据库: $(curl -s http://localhost:8080/health/database > /dev/null 2>&1 && echo "✅ 正常" || echo "❌ 异常")
Redis: $(docker exec fittracker-redis redis-cli ping > /dev/null 2>&1 && echo "✅ 正常" || echo "❌ 异常")

========================================
测试结果摘要
========================================
总测试数: $(find . -name "*test_report*.json" -exec cat {} \; | jq -r '.testReport.summary.totalButtons // "N/A"')
通过测试: $(find . -name "*test_report*.json" -exec cat {} \; | jq -r '.testReport.summary.passedButtons // "N/A"')
失败测试: $(find . -name "*test_report*.json" -exec cat {} \; | jq -r '.testReport.summary.failedButtons // "N/A"')
成功率: $(find . -name "*test_report*.json" -exec cat {} \; | jq -r '.testReport.summary.successRate // "N/A"')%

========================================
自动修复记录
========================================
$(find . -name "*test_report*.json" -exec cat {} \; | jq -r '.testReport.autoFixes[]? | "\(.type): \(.status) - \(.description)"' 2>/dev/null || echo "无自动修复记录")

========================================
建议
========================================
1. 确保所有服务正常运行
2. 定期运行自动化测试
3. 关注失败测试并及时修复
4. 保持测试环境与生产环境一致
5. 监控系统性能和稳定性

========================================
EOF
    
    log_success "控制台报告已生成: $report_file.txt"
}

# 清理资源
cleanup() {
    log "清理测试资源..."
    
    # 停止Flutter应用
    pkill -f "flutter run" 2>/dev/null || true
    
    # 停止Docker服务（可选）
    if [ "$1" = "--stop-services" ]; then
        cd "$PROJECT_ROOT"
        docker-compose down
        log_info "Docker 服务已停止"
    fi
    
    log_success "资源清理完成"
}

# 显示帮助信息
show_help() {
    cat << EOF
FitTracker 全链路按钮测试与自动修复系统

用法: $0 [选项]

选项:
    --help, -h              显示此帮助信息
    --quick                 运行快速测试
    --full                  运行完整测试
    --api-only              仅运行API测试
    --db-only               仅运行数据库测试
    --ui-only               仅运行UI测试
    --auto-fix-only         仅运行自动修复测试
    --stop-services         测试完成后停止服务
    --no-cleanup            不清理测试资源

示例:
    $0 --full               运行完整测试套件
    $0 --quick              运行快速测试
    $0 --api-only           仅测试API功能
    $0 --full --stop-services 运行完整测试并停止服务

EOF
}

# 主函数
main() {
    local start_time=$(date +%s)
    
    # 显示横幅
    echo -e "${PURPLE}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║    FitTracker 全链路按钮测试与自动修复系统                    ║
║                                                              ║
║    🚀 自动化测试 | 🔧 自动修复 | 📊 详细报告                ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    # 解析命令行参数
    local run_quick=false
    local run_full=false
    local run_api_only=false
    local run_db_only=false
    local run_ui_only=false
    local run_auto_fix_only=false
    local stop_services=false
    local no_cleanup=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_help
                exit 0
                ;;
            --quick)
                run_quick=true
                shift
                ;;
            --full)
                run_full=true
                shift
                ;;
            --api-only)
                run_api_only=true
                shift
                ;;
            --db-only)
                run_db_only=true
                shift
                ;;
            --ui-only)
                run_ui_only=true
                shift
                ;;
            --auto-fix-only)
                run_auto_fix_only=true
                shift
                ;;
            --stop-services)
                stop_services=true
                shift
                ;;
            --no-cleanup)
                no_cleanup=true
                shift
                ;;
            *)
                log_error "未知选项: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 如果没有指定任何选项，默认运行完整测试
    if [ "$run_quick" = false ] && [ "$run_full" = false ] && [ "$run_api_only" = false ] && [ "$run_db_only" = false ] && [ "$run_ui_only" = false ] && [ "$run_auto_fix_only" = false ]; then
        run_full=true
    fi
    
    # 设置清理陷阱
    if [ "$no_cleanup" = false ]; then
        trap 'cleanup $([ "$stop_services" = true ] && echo "--stop-services")' EXIT
    fi
    
    # 开始测试
    log "开始 FitTracker 全链路测试..."
    
    # 检查依赖
    check_dependencies
    
    # 启动服务
    start_services
    
    # 根据选项运行不同的测试
    if [ "$run_quick" = true ]; then
        log "运行快速测试..."
        run_dart_tests
        run_api_tests
    elif [ "$run_full" = true ]; then
        log "运行完整测试..."
        run_dart_tests
        run_api_tests
        run_database_tests
        run_auto_fix_tests
        run_flutter_test_app
    elif [ "$run_api_only" = true ]; then
        log "运行API测试..."
        run_api_tests
    elif [ "$run_db_only" = true ]; then
        log "运行数据库测试..."
        run_database_tests
    elif [ "$run_ui_only" = true ]; then
        log "运行UI测试..."
        run_flutter_test_app
    elif [ "$run_auto_fix_only" = true ]; then
        log "运行自动修复测试..."
        run_auto_fix_tests
    fi
    
    # 生成报告
    generate_reports
    
    # 计算总耗时
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_success "测试完成！总耗时: ${duration}秒"
    
    # 显示报告位置
    log_info "测试报告位置: $REPORT_DIR"
    log_info "日志文件: $LOG_FILE"
    
    echo -e "${GREEN}"
    echo "🎉 FitTracker 全链路测试与自动修复系统执行完成！"
    echo -e "${NC}"
}

# 运行主函数
main "$@"
