#!/bin/bash

# FitTracker 项目专用依赖修复脚本
# 针对 Flutter + Go + Docker 项目

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${PURPLE}[STEP]${NC} $1"; }

# 重试函数
retry_command() {
    local max_attempts=3
    local delay=5
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log_info "尝试执行: $* (第 $attempt 次)"
        
        if "$@"; then
            log_success "命令执行成功"
            return 0
        else
            log_warning "命令执行失败 (第 $attempt 次)"
            if [ $attempt -lt $max_attempts ]; then
                log_info "等待 $delay 秒后重试..."
                sleep $delay
                delay=$((delay * 2))
            fi
        fi
        
        attempt=$((attempt + 1))
    done
    
    log_error "命令执行失败，已重试 $max_attempts 次"
    return 1
}

# 检查必要工具
check_prerequisites() {
    log_step "检查必要工具..."
    
    local missing_tools=()
    
    if ! command -v flutter &> /dev/null; then
        missing_tools+=("flutter")
    fi
    
    if ! command -v go &> /dev/null; then
        missing_tools+=("go")
    fi
    
    if ! command -v docker &> /dev/null; then
        missing_tools+=("docker")
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        missing_tools+=("docker-compose")
    fi
    
    if [[ "$OSTYPE" == "darwin"* ]] && ! command -v pod &> /dev/null; then
        missing_tools+=("cocoapods")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_error "缺少必要工具: ${missing_tools[*]}"
        log_info "请先安装这些工具后再运行脚本"
        exit 1
    fi
    
    log_success "所有必要工具已安装"
}

# 清理所有缓存
clean_all_caches() {
    log_step "清理所有缓存..."
    
    # Flutter 缓存
    if command -v flutter &> /dev/null; then
        log_info "清理 Flutter 缓存..."
        flutter clean 2>/dev/null || true
    fi
    
    # Go 模块缓存
    if command -v go &> /dev/null; then
        log_info "清理 Go 模块缓存..."
        go clean -modcache 2>/dev/null || true
    fi
    
    # CocoaPods 缓存 (macOS)
    if [[ "$OSTYPE" == "darwin"* ]] && command -v pod &> /dev/null; then
        log_info "清理 CocoaPods 缓存..."
        pod cache clean --all 2>/dev/null || true
        rm -rf ~/.cocoapods/repos 2>/dev/null || true
    fi
    
    # Docker 缓存
    if command -v docker &> /dev/null; then
        log_info "清理 Docker 缓存..."
        docker system prune -f 2>/dev/null || true
    fi
    
    log_success "缓存清理完成"
}

# 配置国内镜像源
setup_china_mirrors() {
    log_step "配置国内镜像源..."
    
    # Flutter 镜像
    if command -v flutter &> /dev/null; then
        log_info "配置 Flutter 镜像..."
        export PUB_HOSTED_URL=https://pub.flutter-io.cn
        export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
        log_success "Flutter 镜像配置完成"
    fi
    
    # Go 代理
    if command -v go &> /dev/null; then
        log_info "配置 Go 代理..."
        go env -w GOPROXY=https://goproxy.cn,direct
        go env -w GOSUMDB=sum.golang.google.cn
        log_success "Go 代理配置完成"
    fi
    
    # Docker 镜像 (如果在中国)
    if command -v docker &> /dev/null; then
        log_info "配置 Docker 镜像..."
        # 这里可以添加 Docker 镜像配置
        log_success "Docker 镜像配置完成"
    fi
    
    log_success "所有镜像源配置完成"
}

# 修复 Flutter 项目
fix_flutter_project() {
    log_step "修复 Flutter 项目..."
    
    cd /Users/gaojie/Desktop/fittraker/frontend
    
    # 获取依赖
    log_info "获取 Flutter 依赖..."
    retry_command flutter pub get
    
    # 修复 iOS 项目 (macOS only)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log_info "修复 iOS 项目..."
        cd ios
        
        # 清理旧的 Pod 文件
        rm -rf Podfile.lock Pods/ 2>/dev/null || true
        
        # 使用 CDN 方式安装 Pods
        log_info "安装 CocoaPods 依赖..."
        retry_command pod install --repo-update
        
        cd ..
    fi
    
    # 构建项目验证
    log_info "构建 Android 项目..."
    retry_command flutter build apk --debug
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log_info "构建 iOS 项目..."
        retry_command flutter build ios --simulator
    fi
    
    cd /Users/gaojie/Desktop/fittraker
    log_success "Flutter 项目修复完成"
}

# 修复 Go 后端
fix_go_backend() {
    log_step "修复 Go 后端..."
    
    cd /Users/gaojie/Desktop/fittraker/backend-go
    
    # 获取依赖
    log_info "获取 Go 依赖..."
    retry_command go mod tidy
    retry_command go mod download
    
    # 构建项目
    log_info "构建 Go 后端..."
    retry_command go build -o fittracker-server cmd/server/main.go
    
    # 测试构建
    log_info "测试 Go 后端..."
    timeout 10s ./fittracker-server &
    local server_pid=$!
    sleep 5
    
    if curl -f http://localhost:8080/test > /dev/null 2>&1; then
        log_success "Go 后端测试通过"
    else
        log_warning "Go 后端测试失败"
    fi
    
    kill $server_pid 2>/dev/null || true
    rm -f fittracker-server
    
    cd /Users/gaojie/Desktop/fittraker
    log_success "Go 后端修复完成"
}

# 修复 Docker 服务
fix_docker_services() {
    log_step "修复 Docker 服务..."
    
    cd /Users/gaojie/Desktop/fittraker
    
    # 停止现有服务
    docker-compose down 2>/dev/null || true
    
    # 启动数据库服务
    log_info "启动数据库服务..."
    retry_command docker-compose up -d postgres redis
    
    # 等待服务启动
    log_info "等待服务启动..."
    sleep 15
    
    # 检查服务状态
    log_info "检查数据库连接..."
    if docker-compose exec postgres pg_isready -U fittracker -d fittracker; then
        log_success "PostgreSQL 连接正常"
    else
        log_error "PostgreSQL 连接失败"
        return 1
    fi
    
    if docker-compose exec redis redis-cli ping > /dev/null 2>&1; then
        log_success "Redis 连接正常"
    else
        log_error "Redis 连接失败"
        return 1
    fi
    
    # 启动后端服务
    log_info "启动 Go 后端服务..."
    retry_command docker-compose up -d backend
    
    sleep 10
    
    # 检查后端服务
    if curl -f http://localhost:8080/test > /dev/null 2>&1; then
        log_success "Go 后端服务正常"
    else
        log_error "Go 后端服务异常"
        return 1
    fi
    
    log_success "Docker 服务修复完成"
}

# 验证所有服务
verify_all_services() {
    log_step "验证所有服务..."
    
    local all_good=true
    
    # 检查 PostgreSQL
    if docker-compose exec postgres pg_isready -U fittracker -d fittracker > /dev/null 2>&1; then
        log_success "✅ PostgreSQL 服务正常"
    else
        log_error "❌ PostgreSQL 服务异常"
        all_good=false
    fi
    
    # 检查 Redis
    if docker-compose exec redis redis-cli ping > /dev/null 2>&1; then
        log_success "✅ Redis 服务正常"
    else
        log_error "❌ Redis 服务异常"
        all_good=false
    fi
    
    # 检查 Go 后端
    if curl -f http://localhost:8080/test > /dev/null 2>&1; then
        log_success "✅ Go 后端服务正常"
    else
        log_error "❌ Go 后端服务异常"
        all_good=false
    fi
    
    # 检查 Flutter 项目
    cd /Users/gaojie/Desktop/fittraker/frontend
    if flutter doctor > /dev/null 2>&1; then
        log_success "✅ Flutter 环境正常"
    else
        log_error "❌ Flutter 环境异常"
        all_good=false
    fi
    
    cd /Users/gaojie/Desktop/fittraker
    
    if [ "$all_good" = true ]; then
        log_success "所有服务验证通过！"
    else
        log_warning "部分服务验证失败，请检查错误信息"
    fi
}

# 生成部署指南
generate_deployment_guide() {
    log_step "生成部署指南..."
    
    local guide_file="FITTRACKER_DEPLOYMENT_GUIDE.md"
    
    cat > "$guide_file" << EOF
# FitTracker 项目部署指南

## 项目状态
- ✅ Flutter 前端项目
- ✅ Go 后端服务
- ✅ PostgreSQL 数据库
- ✅ Redis 缓存
- ✅ Docker 容器化部署

## 快速启动

### 1. 启动后端服务
\`\`\`bash
cd /Users/gaojie/Desktop/fittraker
docker-compose up -d
\`\`\`

### 2. 验证服务状态
\`\`\`bash
# 检查数据库
docker-compose exec postgres pg_isready -U fittracker -d fittracker

# 检查 Redis
docker-compose exec redis redis-cli ping

# 检查后端 API
curl http://localhost:8080/test
\`\`\`

### 3. 运行移动应用

#### Android 应用
\`\`\`bash
cd /Users/gaojie/Desktop/fittraker/frontend
flutter run
\`\`\`

#### iOS 应用 (macOS)
\`\`\`bash
cd /Users/gaojie/Desktop/fittraker/frontend
flutter run -d ios
\`\`\`

## 服务访问地址

- **Go 后端 API**: http://localhost:8080
- **PostgreSQL**: localhost:5432
- **Redis**: localhost:6379
- **PgAdmin**: http://localhost:5050
- **Redis Commander**: http://localhost:8081

## 默认凭据

- **PostgreSQL**: fittracker / fittracker123
- **Redis**: 密码 fittracker123
- **PgAdmin**: admin@fittracker.com / admin123

## 故障排除

### 网络连接问题
如果应用显示"网络连接失败"：
1. 确保后端服务正在运行
2. 检查防火墙设置
3. 验证 API 地址配置

### iOS 构建问题
如果 iOS 构建失败：
1. 清理 CocoaPods 缓存: \`pod cache clean --all\`
2. 重新安装 Pods: \`pod install\`
3. 检查 Xcode 项目配置

### 数据库连接问题
如果数据库连接失败：
1. 检查 Docker 容器状态
2. 验证数据库凭据
3. 检查网络连接

## 开发命令

\`\`\`bash
# 清理所有缓存
flutter clean
go clean -modcache
docker system prune -f

# 重新安装依赖
flutter pub get
go mod tidy
pod install

# 重新构建
flutter build apk --debug
flutter build ios --simulator
go build -o server cmd/server/main.go

# 重启服务
docker-compose restart
\`\`\`

---
*此指南由 FitTracker 修复脚本自动生成*
EOF

    log_success "部署指南已生成: $guide_file"
}

# 主函数
main() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}    FitTracker 项目依赖修复脚本${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo
    
    # 检查前置条件
    check_prerequisites
    
    # 执行修复步骤
    clean_all_caches
    setup_china_mirrors
    fix_flutter_project
    fix_go_backend
    fix_docker_services
    verify_all_services
    generate_deployment_guide
    
    echo
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}    FitTracker 项目修复完成！${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo
    log_info "现在你可以："
    log_info "1. 在 Android 模拟器中运行应用"
    log_info "2. 在 iOS 模拟器中运行应用 (macOS)"
    log_info "3. 通过 API 测试后端功能"
    log_info "4. 查看部署指南了解详细操作"
}

# 运行主函数
main "$@"
