#!/bin/bash

# FitTracker 生产环境部署脚本
# 使用方法: ./deploy-prod.sh [环境] [操作]
# 示例: ./deploy-prod.sh production up

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

# 检查必要的工具
check_requirements() {
    log_info "检查部署环境..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose 未安装"
        exit 1
    fi
    
    log_success "环境检查通过"
}

# 检查环境变量文件
check_env_file() {
    if [ ! -f ".env.prod" ]; then
        log_error ".env.prod 文件不存在"
        log_info "请复制 env.prod.example 为 .env.prod 并配置相应的值"
        exit 1
    fi
    
    log_success "环境变量文件检查通过"
}

# 创建必要的目录
create_directories() {
    log_info "创建必要的目录..."
    
    mkdir -p logs
    mkdir -p nginx/ssl
    mkdir -p nginx/logs
    mkdir -p monitoring/grafana/dashboards
    mkdir -p monitoring/grafana/datasources
    
    log_success "目录创建完成"
}

# 构建镜像
build_images() {
    log_info "构建 Docker 镜像..."
    
    # 构建后端镜像
    log_info "构建后端镜像..."
    cd backend-go
    docker build -t fittracker-backend:latest .
    cd ..
    
    # 构建前端镜像
    log_info "构建前端镜像..."
    cd frontend
    docker build -t fittracker-frontend:latest .
    cd ..
    
    log_success "镜像构建完成"
}

# 启动服务
start_services() {
    log_info "启动生产环境服务..."
    
    docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d
    
    log_success "服务启动完成"
}

# 停止服务
stop_services() {
    log_info "停止生产环境服务..."
    
    docker-compose -f docker-compose.prod.yml --env-file .env.prod down
    
    log_success "服务停止完成"
}

# 重启服务
restart_services() {
    log_info "重启生产环境服务..."
    
    docker-compose -f docker-compose.prod.yml --env-file .env.prod restart
    
    log_success "服务重启完成"
}

# 查看服务状态
show_status() {
    log_info "查看服务状态..."
    
    docker-compose -f docker-compose.prod.yml --env-file .env.prod ps
}

# 查看日志
show_logs() {
    local service=${1:-""}
    
    if [ -n "$service" ]; then
        log_info "查看 $service 服务日志..."
        docker-compose -f docker-compose.prod.yml --env-file .env.prod logs -f "$service"
    else
        log_info "查看所有服务日志..."
        docker-compose -f docker-compose.prod.yml --env-file .env.prod logs -f
    fi
}

# 健康检查
health_check() {
    log_info "执行健康检查..."
    
    # 检查后端服务
    if curl -f http://localhost:8080/health > /dev/null 2>&1; then
        log_success "后端服务健康"
    else
        log_error "后端服务不健康"
        return 1
    fi
    
    # 检查前端服务
    if curl -f http://localhost:80 > /dev/null 2>&1; then
        log_success "前端服务健康"
    else
        log_error "前端服务不健康"
        return 1
    fi
    
    log_success "所有服务健康检查通过"
}

# 备份数据
backup_data() {
    local backup_dir="backups/$(date +%Y%m%d_%H%M%S)"
    
    log_info "开始备份数据到 $backup_dir..."
    
    mkdir -p "$backup_dir"
    
    # 备份数据库
    docker-compose -f docker-compose.prod.yml --env-file .env.prod exec -T db pg_dump -U fittracker fittracker > "$backup_dir/database.sql"
    
    # 备份 Redis 数据
    docker-compose -f docker-compose.prod.yml --env-file .env.prod exec -T redis redis-cli --rdb "$backup_dir/redis.rdb"
    
    log_success "数据备份完成: $backup_dir"
}

# 清理资源
cleanup() {
    log_info "清理未使用的 Docker 资源..."
    
    docker system prune -f
    docker volume prune -f
    
    log_success "清理完成"
}

# 显示帮助信息
show_help() {
    echo "FitTracker 生产环境部署脚本"
    echo ""
    echo "使用方法:"
    echo "  $0 [操作] [参数]"
    echo ""
    echo "操作:"
    echo "  up          启动所有服务"
    echo "  down        停止所有服务"
    echo "  restart     重启所有服务"
    echo "  status      查看服务状态"
    echo "  logs [服务] 查看日志 (可选指定服务名)"
    echo "  health      健康检查"
    echo "  backup      备份数据"
    echo "  cleanup     清理资源"
    echo "  help        显示帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 up                    # 启动所有服务"
    echo "  $0 logs backend          # 查看后端日志"
    echo "  $0 health                # 健康检查"
}

# 主函数
main() {
    local action=${1:-"help"}
    
    case $action in
        "up")
            check_requirements
            check_env_file
            create_directories
            build_images
            start_services
            sleep 10
            health_check
            ;;
        "down")
            stop_services
            ;;
        "restart")
            restart_services
            sleep 10
            health_check
            ;;
        "status")
            show_status
            ;;
        "logs")
            show_logs "$2"
            ;;
        "health")
            health_check
            ;;
        "backup")
            backup_data
            ;;
        "cleanup")
            cleanup
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# 执行主函数
main "$@"
