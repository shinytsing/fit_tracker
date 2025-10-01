#!/bin/bash

# FitTracker 生产环境部署脚本
# 使用方法: ./deploy.sh [environment] [tag]
# 例如: ./deploy.sh production latest

set -e

# 默认参数
ENVIRONMENT=${1:-production}
TAG=${2:-latest}
REGISTRY=${REGISTRY:-ghcr.io}
NAMESPACE=${NAMESPACE:-your-github-username}

# 颜色输出
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
    log_info "检查部署依赖..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose 未安装，请先安装 Docker Compose"
        exit 1
    fi
    
    log_success "依赖检查完成"
}

# 检查环境文件
check_env_file() {
    log_info "检查环境配置文件..."
    
    if [ ! -f ".env" ]; then
        log_warning "未找到 .env 文件，从示例文件创建..."
        if [ -f "env.prod.example" ]; then
            cp env.prod.example .env
            log_warning "请编辑 .env 文件并设置正确的配置值"
            log_warning "特别是数据库密码、JWT 密钥等敏感信息"
            read -p "按 Enter 继续，或 Ctrl+C 退出以编辑配置..."
        else
            log_error "未找到环境配置文件示例"
            exit 1
        fi
    fi
    
    log_success "环境配置文件检查完成"
}

# 拉取最新镜像
pull_images() {
    log_info "拉取 Docker 镜像..."
    
    # 设置镜像标签
    BACKEND_IMAGE="${REGISTRY}/${NAMESPACE}/fittracker-backend:${TAG}"
    FRONTEND_IMAGE="${REGISTRY}/${NAMESPACE}/fittracker-frontend:${TAG}"
    
    log_info "拉取后端镜像: ${BACKEND_IMAGE}"
    docker pull "${BACKEND_IMAGE}" || {
        log_error "拉取后端镜像失败"
        exit 1
    }
    
    log_info "拉取前端镜像: ${FRONTEND_IMAGE}"
    docker pull "${FRONTEND_IMAGE}" || {
        log_error "拉取前端镜像失败"
        exit 1
    }
    
    log_success "镜像拉取完成"
}

# 备份数据库
backup_database() {
    log_info "备份数据库..."
    
    # 检查是否有运行中的数据库容器
    if docker ps | grep -q fittracker-postgres-prod; then
        BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"
        log_info "创建数据库备份: ${BACKUP_FILE}"
        
        docker exec fittracker-postgres-prod pg_dump -U fittracker fittracker > "${BACKUP_FILE}" || {
            log_warning "数据库备份失败，继续部署..."
        }
        
        if [ -f "${BACKUP_FILE}" ]; then
            log_success "数据库备份完成: ${BACKUP_FILE}"
        fi
    else
        log_info "未检测到运行中的数据库，跳过备份"
    fi
}

# 停止现有服务
stop_services() {
    log_info "停止现有服务..."
    
    docker-compose -f docker-compose.prod.yml down || {
        log_warning "停止服务时出现警告，继续部署..."
    }
    
    log_success "服务停止完成"
}

# 启动服务
start_services() {
    log_info "启动服务..."
    
    # 设置环境变量
    export REGISTRY="${REGISTRY}"
    export NAMESPACE="${NAMESPACE}"
    export TAG="${TAG}"
    
    # 启动服务
    docker-compose -f docker-compose.prod.yml up -d || {
        log_error "启动服务失败"
        exit 1
    }
    
    log_success "服务启动完成"
}

# 等待服务就绪
wait_for_services() {
    log_info "等待服务就绪..."
    
    # 等待数据库
    log_info "等待数据库就绪..."
    timeout=60
    while [ $timeout -gt 0 ]; do
        if docker exec fittracker-postgres-prod pg_isready -U fittracker -d fittracker &> /dev/null; then
            log_success "数据库就绪"
            break
        fi
        sleep 2
        timeout=$((timeout - 2))
    done
    
    if [ $timeout -le 0 ]; then
        log_error "数据库启动超时"
        exit 1
    fi
    
    # 等待 Redis
    log_info "等待 Redis 就绪..."
    timeout=30
    while [ $timeout -gt 0 ]; do
        if docker exec fittracker-redis-prod redis-cli ping &> /dev/null; then
            log_success "Redis 就绪"
            break
        fi
        sleep 2
        timeout=$((timeout - 2))
    done
    
    if [ $timeout -le 0 ]; then
        log_error "Redis 启动超时"
        exit 1
    fi
    
    # 等待后端服务
    log_info "等待后端服务就绪..."
    timeout=60
    while [ $timeout -gt 0 ]; do
        if curl -f http://localhost:8080/health &> /dev/null; then
            log_success "后端服务就绪"
            break
        fi
        sleep 3
        timeout=$((timeout - 3))
    done
    
    if [ $timeout -le 0 ]; then
        log_error "后端服务启动超时"
        exit 1
    fi
}

# 健康检查
health_check() {
    log_info "执行健康检查..."
    
    # 检查后端健康状态
    if curl -f http://localhost:8080/health &> /dev/null; then
        log_success "后端服务健康检查通过"
    else
        log_error "后端服务健康检查失败"
        exit 1
    fi
    
    # 检查前端服务
    if curl -f http://localhost:3000 &> /dev/null; then
        log_success "前端服务健康检查通过"
    else
        log_warning "前端服务健康检查失败，但继续部署"
    fi
    
    # 检查数据库连接
    if docker exec fittracker-postgres-prod pg_isready -U fittracker -d fittracker &> /dev/null; then
        log_success "数据库连接检查通过"
    else
        log_error "数据库连接检查失败"
        exit 1
    fi
    
    # 检查 Redis 连接
    if docker exec fittracker-redis-prod redis-cli ping &> /dev/null; then
        log_success "Redis 连接检查通过"
    else
        log_error "Redis 连接检查失败"
        exit 1
    fi
}

# 显示部署信息
show_deployment_info() {
    log_success "部署完成！"
    echo ""
    echo "服务访问地址："
    echo "  前端应用: http://localhost:3000"
    echo "  后端 API: http://localhost:8080"
    echo "  API 文档: http://localhost:8080/docs"
    echo "  Grafana: http://localhost:3001"
    echo "  Prometheus: http://localhost:9090"
    echo ""
    echo "管理命令："
    echo "  查看服务状态: docker-compose -f docker-compose.prod.yml ps"
    echo "  查看服务日志: docker-compose -f docker-compose.prod.yml logs -f"
    echo "  停止服务: docker-compose -f docker-compose.prod.yml down"
    echo "  重启服务: docker-compose -f docker-compose.prod.yml restart"
    echo ""
    echo "镜像信息："
    echo "  后端: ${REGISTRY}/${NAMESPACE}/fittracker-backend:${TAG}"
    echo "  前端: ${REGISTRY}/${NAMESPACE}/fittracker-frontend:${TAG}"
}

# 主函数
main() {
    log_info "开始部署 FitTracker 到 ${ENVIRONMENT} 环境"
    log_info "使用镜像标签: ${TAG}"
    
    check_dependencies
    check_env_file
    pull_images
    backup_database
    stop_services
    start_services
    wait_for_services
    health_check
    show_deployment_info
    
    log_success "部署流程完成！"
}

# 执行主函数
main "$@"
