#!/bin/bash

# FitTracker 自动化测试脚本
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 项目根目录
PROJECT_ROOT="/Users/gaojie/Desktop/fittraker"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
BACKEND_DIR="$PROJECT_ROOT/backend-go"

# 打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}[$(date '+%H:%M:%S')] ${message}${NC}"
}

# 检查服务状态
check_service_status() {
    local service_name=$1
    local port=$2
    
    if curl -s "http://localhost:$port" > /dev/null 2>&1; then
        print_message $GREEN "✅ $service_name 服务运行正常 (端口: $port)"
        return 0
    else
        print_message $RED "❌ $service_name 服务未运行 (端口: $port)"
        return 1
    fi
}

# 启动后端服务
start_backend() {
    print_message $BLUE "🚀 启动后端服务..."
    
    cd "$BACKEND_DIR"
    
    # 检查Go环境
    if ! command -v go &> /dev/null; then
        print_message $RED "❌ Go 环境未安装"
        exit 1
    fi
    
    # 安装依赖
    print_message $YELLOW "📦 安装Go依赖..."
    go mod tidy
    go mod download
    
    # 启动服务
    print_message $YELLOW "🔄 启动后端服务..."
    nohup go run cmd/server/main.go > "$PROJECT_ROOT/backend.log" 2>&1 &
    BACKEND_PID=$!
    
    # 等待服务启动
    sleep 5
    
    # 检查服务状态
    if check_service_status "后端API" 8080; then
        print_message $GREEN "✅ 后端服务启动成功 (PID: $BACKEND_PID)"
        echo $BACKEND_PID > "$PROJECT_ROOT/backend.pid"
    else
        print_message $RED "❌ 后端服务启动失败"
        exit 1
    fi
}

# 启动前端服务
start_frontend() {
    print_message $BLUE "🚀 启动前端服务..."
    
    cd "$FRONTEND_DIR"
    
    # 检查Flutter环境
    if ! command -v flutter &> /dev/null; then
        print_message $RED "❌ Flutter 环境未安装"
        exit 1
    fi
    
    # 获取Flutter依赖
    print_message $YELLOW "📦 获取Flutter依赖..."
    flutter pub get
    
    # 启动Flutter应用
    print_message $YELLOW "🔄 启动Flutter应用..."
    nohup flutter run --debug > "$PROJECT_ROOT/frontend.log" 2>&1 &
    FRONTEND_PID=$!
    
    # 等待应用启动
    sleep 10
    
    print_message $GREEN "✅ 前端应用启动成功 (PID: $FRONTEND_PID)"
    echo $FRONTEND_PID > "$PROJECT_ROOT/frontend.pid"
}

# 执行API测试
run_api_tests() {
    print_message $BLUE "🧪 执行API测试..."
    
    cd "$PROJECT_ROOT"
    
    # 检查Dart环境
    if ! command -v dart &> /dev/null; then
        print_message $RED "❌ Dart 环境未安装"
        exit 1
    fi
    
    # 执行测试
    print_message $YELLOW "🔄 运行自动化测试..."
    dart test_automation_main.dart
    
    if [ $? -eq 0 ]; then
        print_message $GREEN "✅ API测试执行成功"
    else
        print_message $RED "❌ API测试执行失败"
        return 1
    fi
}

# 清理资源
cleanup() {
    print_message $YELLOW "🧹 清理资源..."
    
    # 停止后端服务
    if [ -f "$PROJECT_ROOT/backend.pid" ]; then
        local backend_pid=$(cat "$PROJECT_ROOT/backend.pid")
        if kill -0 "$backend_pid" 2>/dev/null; then
            kill "$backend_pid"
            print_message $GREEN "✅ 后端服务已停止"
        fi
        rm -f "$PROJECT_ROOT/backend.pid"
    fi
    
    # 停止前端服务
    if [ -f "$PROJECT_ROOT/frontend.pid" ]; then
        local frontend_pid=$(cat "$PROJECT_ROOT/frontend.pid")
        if kill -0 "$frontend_pid" 2>/dev/null; then
            kill "$frontend_pid"
            print_message $GREEN "✅ 前端服务已停止"
        fi
        rm -f "$PROJECT_ROOT/frontend.pid"
    fi

# 清理临时文件
    rm -f "$PROJECT_ROOT/backend.log"
    rm -f "$PROJECT_ROOT/frontend.log"
}

# 显示帮助信息
show_help() {
    cat << EOF
FitTracker 自动化测试脚本

用法: $0 [选项]

选项:
    -h, --help          显示此帮助信息
    -b, --backend-only  仅测试后端API
    -a, --all           执行完整测试（默认）
    -c, --cleanup       清理资源

示例:
    $0                  # 执行完整测试
    $0 --backend-only   # 仅测试后端
    $0 --cleanup        # 清理资源

EOF
}

# 主函数
main() {
    print_message $BLUE "🚀 FitTracker 自动化测试开始..."
    
    # 设置信号处理
    trap cleanup EXIT INT TERM
    
    # 解析命令行参数
    case "${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
        -b|--backend-only)
            start_backend
            run_api_tests
            ;;
        -a|--all)
            start_backend
            start_frontend
            run_api_tests
            ;;
        -c|--cleanup)
            cleanup
            exit 0
            ;;
        "")
            # 默认执行完整测试
            start_backend
            start_frontend
            run_api_tests
            ;;
        *)
            print_message $RED "❌ 未知选项: $1"
            show_help
            exit 1
            ;;
    esac
    
    print_message $GREEN "✅ 测试完成！"
}

# 执行主函数
main "$@"