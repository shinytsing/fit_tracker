#!/bin/bash

# FitTracker 快速测试脚本
# 用于快速验证系统功能

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目路径
PROJECT_ROOT="/Users/gaojie/Desktop/fittraker"

log() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')] ✅${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date '+%H:%M:%S')] ❌${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[$(date '+%H:%M:%S')] ⚠️${NC} $1"
}

# 显示横幅
echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║    FitTracker 快速测试系统                                    ║"
echo "║                                                              ║"
echo "║    🚀 快速验证 | 🔧 自动修复 | 📊 实时报告                  ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# 检查服务状态
check_services() {
    log "检查服务状态..."
    
    # 检查后端服务
    if curl -s http://localhost:8080/health > /dev/null 2>&1; then
        log_success "后端服务运行正常"
    else
        log_warning "后端服务未运行，尝试启动..."
        cd "$PROJECT_ROOT"
        docker-compose up -d
        sleep 10
        
        if curl -s http://localhost:8080/health > /dev/null 2>&1; then
            log_success "后端服务启动成功"
        else
            log_error "后端服务启动失败"
            return 1
        fi
    fi
    
    # 检查数据库
    if curl -s http://localhost:8080/health/database > /dev/null 2>&1; then
        log_success "数据库连接正常"
    else
        log_warning "数据库连接异常"
    fi
}

# 运行Dart测试
run_dart_test() {
    log "运行 Dart 全链路按钮测试..."
    
    cd "$PROJECT_ROOT"
    
    # 检查Dart文件是否存在
    if [ ! -f "comprehensive_button_test_system_simple.dart" ]; then
        log_error "测试文件不存在: comprehensive_button_test_system_simple.dart"
        return 1
    fi
    
    # 运行测试
    dart run comprehensive_button_test_system_simple.dart
    
    if [ $? -eq 0 ]; then
        log_success "Dart 测试完成"
    else
        log_error "Dart 测试失败"
        return 1
    fi
}

# 运行Flutter测试应用
run_flutter_app() {
    log "启动 Flutter 测试应用..."
    
    cd "$PROJECT_ROOT/test_app"
    
    # 检查Flutter项目是否存在
    if [ ! -f "pubspec.yaml" ]; then
        log_error "Flutter 测试应用不存在"
        return 1
    fi
    
    # 获取依赖
    flutter pub get
    
    # 运行应用
    log_info "启动 Flutter 测试应用..."
    flutter run --debug &
    
    local flutter_pid=$!
    log_success "Flutter 测试应用已启动 (PID: $flutter_pid)"
    
    # 等待应用启动
    sleep 5
    
    return 0
}

# 显示测试结果
show_results() {
    log "显示测试结果..."
    
    # 检查是否有测试报告
    if [ -f "fittracker_comprehensive_test_report.json" ]; then
        log_success "测试报告已生成"
        
        # 显示简要统计
        local total_tests=$(cat fittracker_comprehensive_test_report.json | jq -r '.testReport.summary.totalButtons // "N/A"')
        local passed_tests=$(cat fittracker_comprehensive_test_report.json | jq -r '.testReport.summary.passedButtons // "N/A"')
        local failed_tests=$(cat fittracker_comprehensive_test_report.json | jq -r '.testReport.summary.failedButtons // "N/A"')
        local success_rate=$(cat fittracker_comprehensive_test_report.json | jq -r '.testReport.summary.successRate // "N/A"')
        
        echo ""
        echo "📊 测试统计:"
        echo "   总测试数: $total_tests"
        echo "   通过: $passed_tests"
        echo "   失败: $failed_tests"
        echo "   成功率: $success_rate"
        echo ""
        
        # 显示报告文件位置
        echo "📄 测试报告:"
        echo "   JSON: fittracker_comprehensive_test_report.json"
        echo "   HTML: fittracker_comprehensive_test_report.html"
        echo "   Markdown: fittracker_comprehensive_test_report.md"
        echo ""
    else
        log_warning "未找到测试报告"
    fi
}

# 清理资源
cleanup() {
    log "清理测试资源..."
    
    # 停止Flutter应用
    pkill -f "flutter run" 2>/dev/null || true
    
    log_success "资源清理完成"
}

# 设置清理陷阱
trap cleanup EXIT

# 主执行流程
main() {
    local start_time=$(date +%s)
    
    # 检查服务
    check_services
    
    # 运行Dart测试
    run_dart_test
    
    # 启动Flutter应用
    run_flutter_app
    
    # 显示结果
    show_results
    
    # 计算耗时
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_success "快速测试完成！总耗时: ${duration}秒"
    
    echo -e "${GREEN}"
    echo "🎉 FitTracker 快速测试完成！"
    echo "💡 运行 './run_comprehensive_tests.sh --full' 进行完整测试"
    echo -e "${NC}"
}

# 运行主函数
main "$@"
