#!/bin/bash

# FitTracker 测试运行脚本
# 用于运行 Go 后端和 Flutter 前端的完整测试套件

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
    
    # 检查 Flutter
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter 未安装，请先安装 Flutter"
        exit 1
    fi
    
    # 检查 Docker
    if ! command -v docker &> /dev/null; then
        log_warning "Docker 未安装，将跳过容器化测试"
    fi
    
    # 检查 Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        log_warning "Docker Compose 未安装，将跳过容器化测试"
    fi
    
    log_success "依赖检查完成"
}

# 设置环境变量
setup_environment() {
    log_info "设置环境变量..."
    
    # 设置 Go 环境
    export GO111MODULE=on
    export CGO_ENABLED=1
    
    # 设置 Flutter 环境
    export FLUTTER_ROOT=$(which flutter | sed 's|/bin/flutter||')
    
    log_success "环境变量设置完成"
}

# 运行 Go 后端测试
run_go_tests() {
    log_info "运行 Go 后端测试..."
    
    cd backend-go
    
    # 下载依赖
    log_info "下载 Go 依赖..."
    go mod download
    
    # 运行单元测试
    log_info "运行单元测试..."
    go test ./... -v -race -coverprofile=coverage.out
    
    # 运行集成测试
    log_info "运行集成测试..."
    go test ./... -v -race -tags=integration -coverprofile=integration_coverage.out
    
    # 生成覆盖率报告
    log_info "生成覆盖率报告..."
    go tool cover -html=coverage.out -o coverage.html
    go tool cover -html=integration_coverage.out -o integration_coverage.html
    
    # 显示覆盖率统计
    log_info "覆盖率统计:"
    go tool cover -func=coverage.out | tail -1
    go tool cover -func=integration_coverage.out | tail -1
    
    cd ..
    
    log_success "Go 后端测试完成"
}

# 运行 Flutter 前端测试
run_flutter_tests() {
    log_info "运行 Flutter 前端测试..."
    
    cd frontend
    
    # 获取依赖
    log_info "获取 Flutter 依赖..."
    flutter pub get
    
    # 运行代码生成
    log_info "运行代码生成..."
    flutter pub run build_runner build --delete-conflicting-outputs
    
    # 运行单元测试
    log_info "运行 Flutter 单元测试..."
    flutter test --coverage
    
    # 运行集成测试
    log_info "运行 Flutter 集成测试..."
    flutter test integration_test/ --coverage
    
    # 生成覆盖率报告
    log_info "生成 Flutter 覆盖率报告..."
    if command -v lcov &> /dev/null; then
        lcov --summary coverage/lcov.info
    else
        log_warning "lcov 未安装，无法生成详细覆盖率报告"
    fi
    
    cd ..
    
    log_success "Flutter 前端测试完成"
}

# 运行容器化测试
run_docker_tests() {
    log_info "运行容器化测试..."
    
    # 检查 Docker 是否可用
    if ! command -v docker &> /dev/null || ! command -v docker-compose &> /dev/null; then
        log_warning "Docker 不可用，跳过容器化测试"
        return
    fi
    
    # 启动测试环境
    log_info "启动测试环境..."
    docker-compose -f docker-compose.test.yml up -d
    
    # 等待服务启动
    log_info "等待服务启动..."
    sleep 30
    
    # 运行测试
    log_info "运行容器化测试..."
    docker-compose -f docker-compose.test.yml exec backend-go go test ./... -v
    
    # 清理测试环境
    log_info "清理测试环境..."
    docker-compose -f docker-compose.test.yml down
    
    log_success "容器化测试完成"
}

# 运行性能测试
run_performance_tests() {
    log_info "运行性能测试..."
    
    cd backend-go
    
    # 运行基准测试
    log_info "运行基准测试..."
    go test -bench=. -benchmem -run=^$ ./...
    
    # 运行压力测试
    log_info "运行压力测试..."
    go test -race -count=100 ./...
    
    cd ..
    
    log_success "性能测试完成"
}

# 生成测试报告
generate_test_report() {
    log_info "生成测试报告..."
    
    # 创建报告目录
    mkdir -p test-reports
    
    # 生成 Go 测试报告
    if [ -f "backend-go/coverage.html" ]; then
        cp backend-go/coverage.html test-reports/go-coverage.html
        log_success "Go 覆盖率报告已保存到 test-reports/go-coverage.html"
    fi
    
    if [ -f "backend-go/integration_coverage.html" ]; then
        cp backend-go/integration_coverage.html test-reports/go-integration-coverage.html
        log_success "Go 集成测试覆盖率报告已保存到 test-reports/go-integration-coverage.html"
    fi
    
    # 生成 Flutter 测试报告
    if [ -f "frontend/coverage/lcov.info" ]; then
        cp frontend/coverage/lcov.info test-reports/flutter-coverage.info
        log_success "Flutter 覆盖率报告已保存到 test-reports/flutter-coverage.info"
    fi
    
    # 生成测试摘要
    cat > test-reports/summary.md << EOF
# FitTracker 测试报告

## 测试时间
$(date)

## Go 后端测试
- 单元测试: 完成
- 集成测试: 完成
- 覆盖率报告: test-reports/go-coverage.html
- 集成测试覆盖率报告: test-reports/go-integration-coverage.html

## Flutter 前端测试
- 单元测试: 完成
- 集成测试: 完成
- 覆盖率报告: test-reports/flutter-coverage.info

## 测试环境
- Go 版本: $(go version)
- Flutter 版本: $(flutter --version | head -1)
- 操作系统: $(uname -s)
- 架构: $(uname -m)

## 测试结果
所有测试已成功完成。
EOF
    
    log_success "测试报告已生成到 test-reports/ 目录"
}

# 清理测试文件
cleanup() {
    log_info "清理测试文件..."
    
    # 清理 Go 测试文件
    rm -f backend-go/coverage.out
    rm -f backend-go/integration_coverage.out
    rm -f backend-go/coverage.html
    rm -f backend-go/integration_coverage.html
    
    # 清理 Flutter 测试文件
    rm -rf frontend/coverage/
    
    log_success "清理完成"
}

# 显示帮助信息
show_help() {
    cat << EOF
FitTracker 测试运行脚本

用法: $0 [选项]

选项:
    -h, --help          显示帮助信息
    -g, --go-only       只运行 Go 后端测试
    -f, --flutter-only  只运行 Flutter 前端测试
    -d, --docker-only   只运行容器化测试
    -p, --performance   运行性能测试
    -c, --cleanup       清理测试文件
    -r, --report        生成测试报告
    -a, --all           运行所有测试（默认）

示例:
    $0                  # 运行所有测试
    $0 --go-only        # 只运行 Go 后端测试
    $0 --flutter-only   # 只运行 Flutter 前端测试
    $0 --performance    # 运行性能测试
    $0 --cleanup        # 清理测试文件
EOF
}

# 主函数
main() {
    local run_go=true
    local run_flutter=true
    local run_docker=true
    local run_performance=false
    local run_cleanup=false
    local run_report=false
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -g|--go-only)
                run_go=true
                run_flutter=false
                run_docker=false
                shift
                ;;
            -f|--flutter-only)
                run_go=false
                run_flutter=true
                run_docker=false
                shift
                ;;
            -d|--docker-only)
                run_go=false
                run_flutter=false
                run_docker=true
                shift
                ;;
            -p|--performance)
                run_performance=true
                shift
                ;;
            -c|--cleanup)
                run_cleanup=true
                shift
                ;;
            -r|--report)
                run_report=true
                shift
                ;;
            -a|--all)
                run_go=true
                run_flutter=true
                run_docker=true
                shift
                ;;
            *)
                log_error "未知选项: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 显示欢迎信息
    log_info "开始运行 FitTracker 测试套件..."
    log_info "测试时间: $(date)"
    
    # 检查依赖
    check_dependencies
    
    # 设置环境
    setup_environment
    
    # 运行测试
    if [ "$run_go" = true ]; then
        run_go_tests
    fi
    
    if [ "$run_flutter" = true ]; then
        run_flutter_tests
    fi
    
    if [ "$run_docker" = true ]; then
        run_docker_tests
    fi
    
    if [ "$run_performance" = true ]; then
        run_performance_tests
    fi
    
    # 生成报告
    if [ "$run_report" = true ]; then
        generate_test_report
    fi
    
    # 清理
    if [ "$run_cleanup" = true ]; then
        cleanup
    fi
    
    # 显示完成信息
    log_success "所有测试已完成！"
    log_info "测试时间: $(date)"
    
    if [ "$run_report" = true ]; then
        log_info "测试报告已生成到 test-reports/ 目录"
    fi
}

# 运行主函数
main "$@"