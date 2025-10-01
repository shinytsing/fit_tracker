#!/bin/bash

# FitTracker 快速启动脚本
# 支持 Docker 和本地开发环境

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

# 检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        log_error "$1 命令未找到，请先安装 $1"
        exit 1
    fi
}

# 检查 Docker 环境
check_docker() {
    log_info "检查 Docker 环境..."
    if ! docker --version &> /dev/null; then
        log_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi
    
    if ! docker-compose --version &> /dev/null; then
        log_error "Docker Compose 未安装，请先安装 Docker Compose"
        exit 1
    fi
    
    log_success "Docker 环境检查通过"
}

# 检查 Go 环境
check_go() {
    log_info "检查 Go 环境..."
    if ! go version &> /dev/null; then
        log_error "Go 未安装，请先安装 Go 1.21+"
        exit 1
    fi
    
    local go_version=$(go version | cut -d' ' -f3 | sed 's/go//')
    local major_version=$(echo $go_version | cut -d'.' -f1)
    local minor_version=$(echo $go_version | cut -d'.' -f2)
    
    if [ "$major_version" -lt 1 ] || ([ "$major_version" -eq 1 ] && [ "$minor_version" -lt 21 ]); then
        log_error "Go 版本过低，需要 1.21+，当前版本: $go_version"
        exit 1
    fi
    
    log_success "Go 环境检查通过 (版本: $go_version)"
}

# 检查 Flutter 环境
check_flutter() {
    log_info "检查 Flutter 环境..."
    if ! flutter --version &> /dev/null; then
        log_error "Flutter 未安装，请先安装 Flutter 3.2+"
        exit 1
    fi
    
    log_success "Flutter 环境检查通过"
}

# 检查 PostgreSQL
check_postgres() {
    log_info "检查 PostgreSQL..."
    if ! pg_isready -h localhost -p 5432 &> /dev/null; then
        log_warning "PostgreSQL 未运行，将使用 Docker 启动"
        return 1
    fi
    log_success "PostgreSQL 检查通过"
}

# 检查 Redis
check_redis() {
    log_info "检查 Redis..."
    if ! redis-cli ping &> /dev/null; then
        log_warning "Redis 未运行，将使用 Docker 启动"
        return 1
    fi
    log_success "Redis 检查通过"
}

# 启动 Docker 服务
start_docker_services() {
    log_info "启动 Docker 服务..."
    cd backend-go
    
    # 检查环境配置文件
    if [ ! -f .env ]; then
        log_info "创建环境配置文件..."
        cp env.example .env
        log_warning "请编辑 backend-go/.env 文件配置相关参数"
    fi
    
    # 启动服务
    docker-compose up -d
    
    # 等待服务启动
    log_info "等待服务启动..."
    sleep 10
    
    # 检查服务状态
    if docker-compose ps | grep -q "Up"; then
        log_success "Docker 服务启动成功"
    else
        log_error "Docker 服务启动失败"
        docker-compose logs
        exit 1
    fi
    
    cd ..
}

# 启动本地后端服务
start_local_backend() {
    log_info "启动本地后端服务..."
    cd backend-go
    
    # 检查环境配置文件
    if [ ! -f .env ]; then
        log_info "创建环境配置文件..."
        cp env.example .env
        log_warning "请编辑 backend-go/.env 文件配置相关参数"
    fi
    
    # 下载依赖
    log_info "下载 Go 依赖..."
    go mod download
    
    # 启动服务
    log_info "启动后端服务..."
    go run cmd/server/main.go &
    BACKEND_PID=$!
    
    # 等待服务启动
    sleep 5
    
    # 检查服务状态
    if curl -s http://localhost:8080/health > /dev/null; then
        log_success "后端服务启动成功 (PID: $BACKEND_PID)"
    else
        log_error "后端服务启动失败"
        kill $BACKEND_PID 2>/dev/null || true
        exit 1
    fi
    
    cd ..
}

# 启动 Flutter 前端
start_flutter_frontend() {
    log_info "启动 Flutter 前端..."
    cd frontend
    
    # 检查依赖
    if [ ! -d "build" ]; then
        log_info "获取 Flutter 依赖..."
        flutter pub get
    fi
    
    # 启动 Flutter 应用
    log_info "启动 Flutter 应用..."
    flutter run -d chrome --web-port 3000 &
    FLUTTER_PID=$!
    
    # 等待服务启动
    sleep 10
    
    log_success "Flutter 前端启动成功 (PID: $FLUTTER_PID)"
    log_info "前端访问地址: http://localhost:3000"
    
    cd ..
}

# 显示服务信息
show_service_info() {
    log_info "服务信息:"
    echo "=================================="
    echo "后端 API: http://localhost:8080"
    echo "前端应用: http://localhost:3000"
    echo "API 文档: http://localhost:8080/api/v1/docs"
    echo "健康检查: http://localhost:8080/health"
    echo "=================================="
}

# 停止服务
stop_services() {
    log_info "停止服务..."
    
    # 停止 Flutter 应用
    if [ ! -z "$FLUTTER_PID" ]; then
        kill $FLUTTER_PID 2>/dev/null || true
        log_info "Flutter 应用已停止"
    fi
    
    # 停止后端服务
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null || true
        log_info "后端服务已停止"
    fi
    
    # 停止 Docker 服务
    if [ -d "backend-go" ]; then
        cd backend-go
        docker-compose down 2>/dev/null || true
        log_info "Docker 服务已停止"
        cd ..
    fi
    
    log_success "所有服务已停止"
}

# 清理环境
cleanup() {
    log_info "清理环境..."
    
    # 停止服务
    stop_services
    
    # 清理 Docker 资源
    if [ -d "backend-go" ]; then
        cd backend-go
        docker-compose down -v 2>/dev/null || true
        docker system prune -f 2>/dev/null || true
        cd ..
    fi
    
    log_success "环境清理完成"
}

# 显示帮助信息
show_help() {
    echo "FitTracker 快速启动脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  start      启动所有服务 (默认)"
    echo "  stop       停止所有服务"
    echo "  restart    重启所有服务"
    echo "  status     查看服务状态"
    echo "  logs       查看服务日志"
    echo "  clean      清理环境"
    echo "  docker     使用 Docker 启动服务"
    echo "  local      使用本地环境启动服务"
    echo "  backend    仅启动后端服务"
    echo "  frontend   仅启动前端服务"
    echo "  help       显示帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 start          # 启动所有服务"
    echo "  $0 docker         # 使用 Docker 启动"
    echo "  $0 local          # 使用本地环境启动"
    echo "  $0 stop           # 停止所有服务"
    echo "  $0 status         # 查看服务状态"
}

# 查看服务状态
show_status() {
    log_info "服务状态:"
    echo "=================================="
    
    # 检查后端服务
    if curl -s http://localhost:8080/health > /dev/null 2>&1; then
        echo "后端服务: ✅ 运行中 (http://localhost:8080)"
    else
        echo "后端服务: ❌ 未运行"
    fi
    
    # 检查前端服务
    if curl -s http://localhost:3000 > /dev/null 2>&1; then
        echo "前端服务: ✅ 运行中 (http://localhost:3000)"
    else
        echo "前端服务: ❌ 未运行"
    fi
    
    # 检查数据库
    if pg_isready -h localhost -p 5432 > /dev/null 2>&1; then
        echo "PostgreSQL: ✅ 运行中"
    else
        echo "PostgreSQL: ❌ 未运行"
    fi
    
    # 检查 Redis
    if redis-cli ping > /dev/null 2>&1; then
        echo "Redis: ✅ 运行中"
    else
        echo "Redis: ❌ 未运行"
    fi
    
    echo "=================================="
}

# 查看服务日志
show_logs() {
    log_info "服务日志:"
    echo "=================================="
    
    if [ -d "backend-go" ]; then
        cd backend-go
        echo "Docker 服务日志:"
        docker-compose logs --tail=50
        cd ..
    fi
    
    echo "=================================="
}

# 主函数
main() {
    local command=${1:-start}
    
    case $command in
        start)
            log_info "启动 FitTracker 服务..."
            
            # 检查环境
            check_docker
            check_go
            check_flutter
            
            # 检查本地服务
            local use_docker=false
            if ! check_postgres || ! check_redis; then
                use_docker=true
            fi
            
            # 启动服务
            if [ "$use_docker" = true ]; then
                start_docker_services
            else
                start_local_backend
            fi
            
            start_flutter_frontend
            show_service_info
            ;;
        stop)
            stop_services
            ;;
        restart)
            stop_services
            sleep 2
            main start
            ;;
        status)
            show_status
            ;;
        logs)
            show_logs
            ;;
        clean)
            cleanup
            ;;
        docker)
            log_info "使用 Docker 启动服务..."
            check_docker
            start_docker_services
            start_flutter_frontend
            show_service_info
            ;;
        local)
            log_info "使用本地环境启动服务..."
            check_go
            check_flutter
            check_postgres
            check_redis
            start_local_backend
            start_flutter_frontend
            show_service_info
            ;;
        backend)
            log_info "仅启动后端服务..."
            check_go
            start_local_backend
            ;;
        frontend)
            log_info "仅启动前端服务..."
            check_flutter
            start_flutter_frontend
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "未知命令: $command"
            show_help
            exit 1
            ;;
    esac
}

# 捕获中断信号
trap 'log_warning "收到中断信号，正在停止服务..."; stop_services; exit 0' INT TERM

# 执行主函数
main "$@"
