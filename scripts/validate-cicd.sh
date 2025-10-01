#!/bin/bash

# FitTracker CI/CD 配置验证脚本
# 用于验证 GitHub Actions 工作流配置是否正确

set -e

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

# 检查文件是否存在
check_file_exists() {
    local file_path="$1"
    local description="$2"
    
    if [ -f "$file_path" ]; then
        log_success "$description 文件存在: $file_path"
        return 0
    else
        log_error "$description 文件不存在: $file_path"
        return 1
    fi
}

# 检查 YAML 语法
check_yaml_syntax() {
    local file_path="$1"
    local description="$2"
    
    if command -v yamllint &> /dev/null; then
        if yamllint "$file_path" &> /dev/null; then
            log_success "$description YAML 语法正确"
            return 0
        else
            log_error "$description YAML 语法错误"
            yamllint "$file_path"
            return 1
        fi
    else
        log_warning "yamllint 未安装，跳过 YAML 语法检查"
        return 0
    fi
}

# 检查 Docker Compose 语法
check_docker_compose_syntax() {
    local file_path="$1"
    local description="$2"
    
    if docker-compose -f "$file_path" config &> /dev/null; then
        log_success "$description Docker Compose 语法正确"
        return 0
    else
        log_error "$description Docker Compose 语法错误"
        docker-compose -f "$file_path" config
        return 1
    fi
}

# 检查脚本权限
check_script_permissions() {
    local script_path="$1"
    local description="$2"
    
    if [ -x "$script_path" ]; then
        log_success "$description 脚本有执行权限"
        return 0
    else
        log_warning "$description 脚本没有执行权限，尝试添加..."
        chmod +x "$script_path"
        if [ -x "$script_path" ]; then
            log_success "$description 脚本权限已修复"
            return 0
        else
            log_error "$description 脚本权限修复失败"
            return 1
        fi
    fi
}

# 主验证函数
main() {
    log_info "开始验证 FitTracker CI/CD 配置..."
    
    local errors=0
    
    # 检查 GitHub Actions 工作流文件
    log_info "检查 GitHub Actions 工作流文件..."
    
    if ! check_file_exists ".github/workflows/ci.yml" "CI 工作流"; then
        ((errors++))
    fi
    
    if ! check_file_exists ".github/workflows/deploy.yml" "部署工作流"; then
        ((errors++))
    fi
    
    # 检查 YAML 语法
    log_info "检查 YAML 语法..."
    
    if ! check_yaml_syntax ".github/workflows/ci.yml" "CI 工作流"; then
        ((errors++))
    fi
    
    if ! check_yaml_syntax ".github/workflows/deploy.yml" "部署工作流"; then
        ((errors++))
    fi
    
    # 检查 Docker Compose 文件
    log_info "检查 Docker Compose 文件..."
    
    if ! check_file_exists "docker-compose.prod.yml" "生产环境 Docker Compose"; then
        ((errors++))
    fi
    
    if ! check_docker_compose_syntax "docker-compose.prod.yml" "生产环境 Docker Compose"; then
        ((errors++))
    fi
    
    # 检查环境配置文件
    log_info "检查环境配置文件..."
    
    if ! check_file_exists "env.prod.example" "生产环境配置示例"; then
        ((errors++))
    fi
    
    # 检查部署脚本
    log_info "检查部署脚本..."
    
    if ! check_file_exists "scripts/deploy.sh" "部署脚本"; then
        ((errors++))
    fi
    
    if ! check_script_permissions "scripts/deploy.sh" "部署脚本"; then
        ((errors++))
    fi
    
    # 检查监控配置文件
    log_info "检查监控配置文件..."
    
    if ! check_file_exists "monitoring/prometheus.yml" "Prometheus 配置"; then
        ((errors++))
    fi
    
    if ! check_file_exists "monitoring/loki-config.yml" "Loki 配置"; then
        ((errors++))
    fi
    
    if ! check_file_exists "monitoring/promtail-config.yml" "Promtail 配置"; then
        ((errors++))
    fi
    
    if ! check_file_exists "monitoring/grafana/datasources/datasources.yml" "Grafana 数据源配置"; then
        ((errors++))
    fi
    
    if ! check_file_exists "monitoring/grafana/dashboards/dashboards.yml" "Grafana 仪表板配置"; then
        ((errors++))
    fi
    
    # 检查项目结构
    log_info "检查项目结构..."
    
    if ! check_file_exists "backend-go/Dockerfile" "后端 Dockerfile"; then
        ((errors++))
    fi
    
    if ! check_file_exists "frontend/Dockerfile" "前端 Dockerfile"; then
        ((errors++))
    fi
    
    if ! check_file_exists "backend-go/go.mod" "Go 模块文件"; then
        ((errors++))
    fi
    
    if ! check_file_exists "frontend/pubspec.yaml" "Flutter 项目文件"; then
        ((errors++))
    fi
    
    # 输出验证结果
    echo ""
    if [ $errors -eq 0 ]; then
        log_success "所有 CI/CD 配置验证通过！"
        echo ""
        log_info "下一步操作："
        echo "1. 推送代码到 GitHub 仓库"
        echo "2. 在 GitHub 仓库中配置 Secrets"
        echo "3. 查看 Actions 标签页中的工作流运行状态"
        echo "4. 使用部署脚本进行生产环境部署"
        echo ""
        log_info "相关文档："
        echo "- README.md - 完整的项目文档"
        echo "- DEPLOYMENT.md - 部署指南"
        echo "- .github/workflows/ci.yml - CI 工作流配置"
        echo "- .github/workflows/deploy.yml - 部署工作流配置"
    else
        log_error "发现 $errors 个配置问题，请修复后重新运行验证"
        exit 1
    fi
}

# 执行主函数
main "$@"
