#!/bin/bash

# Gymates 后端启动脚本 - 集成自动 API 测试
# 使用方法: bash run_server.sh

set -e

# 颜色定义
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

# 检查依赖
check_dependencies() {
    log_info "检查依赖..."
    
    # 检查 Go
    if ! command -v go &> /dev/null; then
        log_error "Go 未安装，请先安装 Go"
        exit 1
    fi
    
    # 检查 Go 版本
    GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
    log_info "Go 版本: $GO_VERSION"
    
    log_success "依赖检查完成"
}

# 检查环境
check_environment() {
    log_info "检查环境..."
    
    # 检查 .env 文件
    if [ ! -f ".env" ]; then
        log_warning ".env 文件不存在，使用默认配置"
        if [ -f "env.example" ]; then
            log_info "复制 env.example 到 .env"
            cp env.example .env
        fi
    fi
    
    # 检查数据库连接
    log_info "检查数据库配置..."
    
    log_success "环境检查完成"
}

# 安装依赖
install_dependencies() {
    log_info "安装 Go 依赖..."
    
    if [ -f "go.mod" ]; then
        go mod tidy
        log_success "Go 依赖安装完成"
    else
        log_warning "go.mod 文件不存在"
    fi
}

# 构建项目
build_project() {
    log_info "构建项目..."
    
    # 清理之前的构建
    if [ -f "main" ]; then
        rm -f main
    fi
    
    # 构建
    go build -o main .
    
    if [ -f "main" ]; then
        log_success "项目构建完成"
    else
        log_error "项目构建失败"
        exit 1
    fi
}

# 启动服务器
start_server() {
    log_info "启动服务器..."
    
    # 后台启动服务器
    ./main &
    SERVER_PID=$!
    
    log_info "服务器进程 ID: $SERVER_PID"
    
    # 等待服务器启动
    sleep 3
    
    # 检查服务器是否启动成功
    if kill -0 $SERVER_PID 2>/dev/null; then
        log_success "服务器启动成功"
    else
        log_error "服务器启动失败"
        exit 1
    fi
}

# 运行测试
run_tests() {
    log_info "运行 API 测试..."
    
    # 等待服务器完全启动
    sleep 2
    
    # 检查服务器健康状态
    if curl -s http://localhost:8080/health > /dev/null; then
        log_success "服务器健康检查通过"
    else
        log_warning "服务器健康检查失败，但继续运行测试"
    fi
    
    # 运行测试
    if go test ./tests -v; then
        log_success "所有测试通过"
    else
        log_warning "部分测试失败，但服务器继续运行"
    fi
}

# 清理函数
cleanup() {
    log_info "清理资源..."
    
    if [ ! -z "$SERVER_PID" ]; then
        log_info "停止服务器 (PID: $SERVER_PID)"
        kill $SERVER_PID 2>/dev/null || true
        wait $SERVER_PID 2>/dev/null || true
    fi
    
    # 清理构建文件
    if [ -f "main" ]; then
        rm -f main
    fi
    
    log_success "清理完成"
}

# 信号处理
trap cleanup EXIT INT TERM

# 显示帮助
show_help() {
    cat << EOF
Gymates 后端启动脚本

使用方法:
    $0 [选项]

选项:
    -h, --help      显示帮助信息
    -t, --test-only 仅运行测试
    -s, --server-only 仅启动服务器
    -b, --build-only 仅构建项目
    -c, --clean     清理构建文件

示例:
    $0              # 启动服务器并运行测试
    $0 --test-only  # 仅运行测试
    $0 --server-only # 仅启动服务器
    $0 --clean      # 清理构建文件

EOF
}

# 主函数
main() {
    echo "🚀 Gymates 后端启动脚本"
    echo "================================"
    
    # 解析命令行参数
    case "${1:-}" in
        "-h"|"--help")
            show_help
            exit 0
            ;;
        "-t"|"--test-only")
            log_info "仅运行测试模式"
            check_dependencies
            run_tests
            exit 0
            ;;
        "-s"|"--server-only")
            log_info "仅启动服务器模式"
            check_dependencies
            check_environment
            install_dependencies
            build_project
            start_server
            log_info "服务器运行中，按 Ctrl+C 停止"
            wait $SERVER_PID
            ;;
        "-b"|"--build-only")
            log_info "仅构建项目模式"
            check_dependencies
            install_dependencies
            build_project
            exit 0
            ;;
        "-c"|"--clean")
            log_info "清理模式"
            cleanup
            exit 0
            ;;
        "")
            # 默认模式：启动服务器并运行测试
            ;;
        *)
            log_error "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
    
    # 默认执行流程
    check_dependencies
    check_environment
    install_dependencies
    build_project
    start_server
    run_tests
    
    log_info "服务器运行中，按 Ctrl+C 停止"
    log_info "访问地址: http://localhost:8080"
    log_info "健康检查: http://localhost:8080/health"
    log_info "API 文档: http://localhost:8080/api/v1/docs"
    
    # 等待服务器进程
    wait $SERVER_PID
}

# 执行主函数
main "$@"
