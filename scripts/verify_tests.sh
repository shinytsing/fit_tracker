#!/bin/bash

# FitTracker 测试验证脚本
# 用于快速验证测试环境是否正常工作

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
    log_info "检查测试依赖..."
    
    # 检查 Go
    if ! command -v go &> /dev/null; then
        log_error "Go 未安装"
        return 1
    fi
    
    # 检查 Flutter
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter 未安装"
        return 1
    fi
    
    # 检查 Docker
    if ! command -v docker &> /dev/null; then
        log_warning "Docker 未安装，将跳过容器化测试"
    fi
    
    log_success "依赖检查完成"
    return 0
}

# 验证 Go 测试
verify_go_tests() {
    log_info "验证 Go 测试..."
    
    cd backend-go
    
    # 检查测试文件
    if [ ! -f "internal/api/handlers/handlers_test.go" ]; then
        log_error "Go 测试文件不存在"
        return 1
    fi
    
    # 检查测试依赖
    if ! go mod download; then
        log_error "Go 依赖下载失败"
        return 1
    fi
    
    # 运行简单测试
    if ! go test ./internal/api/handlers -v -run="TestRegister"; then
        log_error "Go 测试失败"
        return 1
    fi
    
    cd ..
    log_success "Go 测试验证通过"
    return 0
}

# 验证 Flutter 测试
verify_flutter_tests() {
    log_info "验证 Flutter 测试..."
    
    cd frontend
    
    # 检查测试文件
    if [ ! -f "test/widget_test.dart" ]; then
        log_error "Flutter 测试文件不存在"
        return 1
    fi
    
    # 检查依赖
    if ! flutter pub get; then
        log_error "Flutter 依赖获取失败"
        return 1
    fi
    
    # 运行简单测试
    if ! flutter test test/widget_test.dart --reporter=compact; then
        log_error "Flutter 测试失败"
        return 1
    fi
    
    cd ..
    log_success "Flutter 测试验证通过"
    return 0
}

# 验证 Docker 测试
verify_docker_tests() {
    log_info "验证 Docker 测试..."
    
    # 检查 Docker 是否可用
    if ! command -v docker &> /dev/null; then
        log_warning "Docker 不可用，跳过验证"
        return 0
    fi
    
    # 检查测试配置文件
    if [ ! -f "docker-compose.test.yml" ]; then
        log_error "Docker 测试配置文件不存在"
        return 1
    fi
    
    # 检查测试 Dockerfile
    if [ ! -f "backend-go/Dockerfile.test" ]; then
        log_error "Go 测试 Dockerfile 不存在"
        return 1
    fi
    
    if [ ! -f "frontend/Dockerfile.test" ]; then
        log_error "Flutter 测试 Dockerfile 不存在"
        return 1
    fi
    
    log_success "Docker 测试验证通过"
    return 0
}

# 验证 CI/CD 配置
verify_cicd_config() {
    log_info "验证 CI/CD 配置..."
    
    # 检查 GitHub Actions 配置
    if [ ! -f ".github/workflows/ci.yml" ]; then
        log_error "GitHub Actions 配置文件不存在"
        return 1
    fi
    
    # 检查测试脚本
    if [ ! -f "scripts/run_tests.sh" ]; then
        log_error "测试运行脚本不存在"
        return 1
    fi
    
    # 检查脚本权限
    if [ ! -x "scripts/run_tests.sh" ]; then
        log_warning "测试脚本没有执行权限，正在修复..."
        chmod +x scripts/run_tests.sh
    fi
    
    log_success "CI/CD 配置验证通过"
    return 0
}

# 验证测试数据
verify_test_data() {
    log_info "验证测试数据..."
    
    # 检查测试数据生成器
    if [ ! -f "backend-go/test_data_generator.go" ]; then
        log_error "测试数据生成器不存在"
        return 1
    fi
    
    log_success "测试数据验证通过"
    return 0
}

# 主函数
main() {
    log_info "开始验证 FitTracker 测试环境..."
    
    local all_passed=true
    
    # 检查依赖
    if ! check_dependencies; then
        all_passed=false
    fi
    
    # 验证 Go 测试
    if ! verify_go_tests; then
        all_passed=false
    fi
    
    # 验证 Flutter 测试
    if ! verify_flutter_tests; then
        all_passed=false
    fi
    
    # 验证 Docker 测试
    if ! verify_docker_tests; then
        all_passed=false
    fi
    
    # 验证 CI/CD 配置
    if ! verify_cicd_config; then
        all_passed=false
    fi
    
    # 验证测试数据
    if ! verify_test_data; then
        all_passed=false
    fi
    
    # 显示结果
    if [ "$all_passed" = true ]; then
        log_success "所有测试验证通过！"
        log_info "可以运行以下命令开始测试："
        echo "  ./scripts/run_tests.sh --all"
        echo "  ./scripts/run_tests.sh --go-only"
        echo "  ./scripts/run_tests.sh --flutter-only"
        echo "  ./scripts/run_tests.sh --performance"
        return 0
    else
        log_error "部分测试验证失败，请检查上述错误"
        return 1
    fi
}

# 运行主函数
main "$@"
