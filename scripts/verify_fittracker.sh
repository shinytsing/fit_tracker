#!/bin/bash

# FitTracker 快速验证脚本
# 用于快速检查所有服务状态

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 检查服务状态
check_service() {
    local service_name=$1
    local check_command=$2
    local expected_result=$3
    
    log_info "检查 $service_name..."
    
    if eval "$check_command" > /dev/null 2>&1; then
        log_success "✅ $service_name: $expected_result"
        return 0
    else
        log_error "❌ $service_name: 服务异常"
        return 1
    fi
}

# 主验证函数
main() {
    log_info "开始 FitTracker 服务验证..."
    
    cd /Users/gaojie/Desktop/fittraker
    
    # 检查核心服务
    check_service "PostgreSQL" "docker-compose exec postgres pg_isready -U fittracker -d fittracker" "数据库连接正常"
    check_service "Redis" "docker-compose exec redis redis-cli ping" "缓存服务正常"
    check_service "Go 后端" "curl -f http://localhost:8080/test" "API 服务正常"
    
    # 检查可选服务
    check_service "Nginx" "curl -f http://localhost:80" "反向代理正常" || log_warning "⚠️ Nginx 服务异常（可选）"
    check_service "PgAdmin" "curl -f http://localhost:5050" "数据库管理正常" || log_warning "⚠️ PgAdmin 服务异常（可选）"
    check_service "Redis Commander" "curl -f http://localhost:8081" "Redis 管理正常" || log_warning "⚠️ Redis Commander 服务异常（可选）"
    check_service "Prometheus" "curl -f http://localhost:9090" "监控服务正常" || log_warning "⚠️ Prometheus 服务异常（可选）"
    check_service "Grafana" "curl -f http://localhost:3001" "仪表板正常" || log_warning "⚠️ Grafana 服务异常（可选）"
    
    # 检查应用构建
    log_info "检查应用构建状态..."
    
    cd frontend
    
    # 检查 Flutter 项目
    if flutter doctor > /dev/null 2>&1; then
        log_success "✅ Flutter 环境正常"
    else
        log_error "❌ Flutter 环境异常"
    fi
    
    # 检查 iOS 构建
    if flutter build ios --simulator --no-pub > /dev/null 2>&1; then
        log_success "✅ iOS 应用构建正常"
    else
        log_warning "⚠️ iOS 应用构建异常"
    fi
    
    # 检查 Android 构建
    if flutter build apk --debug --no-pub > /dev/null 2>&1; then
        log_success "✅ Android 应用构建正常"
    else
        log_warning "⚠️ Android 应用构建异常"
    fi
    
    log_success "验证完成！"
    
    # 显示服务访问信息
    echo ""
    log_info "服务访问信息："
    echo "  Go 后端 API: http://localhost:8080"
    echo "  PostgreSQL: localhost:5432"
    echo "  Redis: localhost:6379"
    echo "  Nginx: http://localhost:80"
    echo "  PgAdmin: http://localhost:5050"
    echo "  Redis Commander: http://localhost:8081"
    echo "  Prometheus: http://localhost:9090"
    echo "  Grafana: http://localhost:3001"
}

# 运行验证
main "$@"
