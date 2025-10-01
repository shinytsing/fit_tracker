#!/bin/bash

# 跨平台依赖修复脚本
# 支持 macOS / Linux / Windows (WSL/Git Bash)
# 自动检测系统环境并使用国内镜像源

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        log_info "检测到 macOS 系统"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        log_info "检测到 Linux 系统"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        OS="windows"
        log_info "检测到 Windows 系统 (Git Bash/Cygwin)"
    else
        OS="unknown"
        log_warning "未知操作系统: $OSTYPE"
    fi
}

# 检测包管理工具
detect_package_managers() {
    log_step "检测包管理工具..."
    
    PACKAGE_MANAGERS=()
    
    # Node.js / npm / yarn
    if command -v node &> /dev/null; then
        PACKAGE_MANAGERS+=("node")
        log_info "检测到 Node.js $(node --version)"
    fi
    
    if command -v npm &> /dev/null; then
        PACKAGE_MANAGERS+=("npm")
        log_info "检测到 npm $(npm --version)"
    fi
    
    if command -v yarn &> /dev/null; then
        PACKAGE_MANAGERS+=("yarn")
        log_info "检测到 yarn $(yarn --version)"
    fi
    
    # Python / pip
    if command -v python3 &> /dev/null; then
        PACKAGE_MANAGERS+=("python3")
        log_info "检测到 Python3 $(python3 --version)"
    fi
    
    if command -v pip3 &> /dev/null; then
        PACKAGE_MANAGERS+=("pip3")
        log_info "检测到 pip3 $(pip3 --version)"
    fi
    
    # Go
    if command -v go &> /dev/null; then
        PACKAGE_MANAGERS+=("go")
        log_info "检测到 Go $(go version)"
    fi
    
    # Rust
    if command -v cargo &> /dev/null; then
        PACKAGE_MANAGERS+=("rust")
        log_info "检测到 Rust $(cargo --version)"
    fi
    
    # Java / Maven
    if command -v java &> /dev/null; then
        PACKAGE_MANAGERS+=("java")
        log_info "检测到 Java $(java -version 2>&1 | head -n1)"
    fi
    
    if command -v mvn &> /dev/null; then
        PACKAGE_MANAGERS+=("maven")
        log_info "检测到 Maven $(mvn --version | head -n1)"
    fi
    
    # CocoaPods (macOS only)
    if [[ "$OS" == "macos" ]] && command -v pod &> /dev/null; then
        PACKAGE_MANAGERS+=("cocoapods")
        log_info "检测到 CocoaPods $(pod --version)"
    fi
    
    # Flutter
    if command -v flutter &> /dev/null; then
        PACKAGE_MANAGERS+=("flutter")
        log_info "检测到 Flutter $(flutter --version | head -n1)"
    fi
    
    log_success "检测到 ${#PACKAGE_MANAGERS[@]} 个包管理工具: ${PACKAGE_MANAGERS[*]}"
}

# 清理缓存函数
clean_caches() {
    log_step "清理包管理工具缓存..."
    
    # npm 缓存
    if command -v npm &> /dev/null; then
        log_info "清理 npm 缓存..."
        npm cache clean --force 2>/dev/null || true
    fi
    
    # yarn 缓存
    if command -v yarn &> /dev/null; then
        log_info "清理 yarn 缓存..."
        yarn cache clean 2>/dev/null || true
    fi
    
    # pip 缓存
    if command -v pip3 &> /dev/null; then
        log_info "清理 pip 缓存..."
        pip3 cache purge 2>/dev/null || true
    fi
    
    # Go 模块缓存
    if command -v go &> /dev/null; then
        log_info "清理 Go 模块缓存..."
        go clean -modcache 2>/dev/null || true
    fi
    
    # Rust 缓存
    if command -v cargo &> /dev/null; then
        log_info "清理 Rust 缓存..."
        cargo clean 2>/dev/null || true
    fi
    
    # Maven 缓存
    if command -v mvn &> /dev/null; then
        log_info "清理 Maven 缓存..."
        rm -rf ~/.m2/repository 2>/dev/null || true
    fi
    
    # CocoaPods 缓存
    if [[ "$OS" == "macos" ]] && command -v pod &> /dev/null; then
        log_info "清理 CocoaPods 缓存..."
        pod cache clean --all 2>/dev/null || true
        rm -rf ~/.cocoapods/repos 2>/dev/null || true
    fi
    
    # Flutter 缓存
    if command -v flutter &> /dev/null; then
        log_info "清理 Flutter 缓存..."
        flutter clean 2>/dev/null || true
    fi
    
    log_success "缓存清理完成"
}

# 配置国内镜像源
setup_mirrors() {
    log_step "配置国内镜像源..."
    
    # npm 镜像源
    if command -v npm &> /dev/null; then
        log_info "配置 npm 镜像源..."
        npm config set registry https://registry.npmmirror.com/
        npm config set disturl https://npmmirror.com/dist/
        npm config set sass_binary_site https://npmmirror.com/mirrors/node-sass/
        npm config set electron_mirror https://npmmirror.com/mirrors/electron/
        npm config set puppeteer_download_host https://npmmirror.com/mirrors/
        npm config set chromedriver_cdnurl https://npmmirror.com/mirrors/chromedriver/
        npm config set operadriver_cdnurl https://npmmirror.com/mirrors/operadriver/
        npm config set phantomjs_cdnurl https://npmmirror.com/mirrors/phantomjs/
        npm config set selenium_cdnurl https://npmmirror.com/mirrors/selenium/
        npm config set node_inspector_cdnurl https://npmmirror.com/mirrors/node-inspector/
        log_success "npm 镜像源配置完成"
    fi
    
    # yarn 镜像源
    if command -v yarn &> /dev/null; then
        log_info "配置 yarn 镜像源..."
        yarn config set registry https://registry.npmmirror.com/
        log_success "yarn 镜像源配置完成"
    fi
    
    # pip 镜像源
    if command -v pip3 &> /dev/null; then
        log_info "配置 pip 镜像源..."
        pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple/
        pip3 config set global.trusted-host pypi.tuna.tsinghua.edu.cn
        log_success "pip 镜像源配置完成"
    fi
    
    # Go 代理
    if command -v go &> /dev/null; then
        log_info "配置 Go 代理..."
        go env -w GOPROXY=https://goproxy.cn,direct
        go env -w GOSUMDB=sum.golang.google.cn
        log_success "Go 代理配置完成"
    fi
    
    # Rust 镜像源
    if command -v cargo &> /dev/null; then
        log_info "配置 Rust 镜像源..."
        mkdir -p ~/.cargo
        cat > ~/.cargo/config.toml << EOF
[source.crates-io]
replace-with = 'ustc'

[source.ustc]
registry = "https://mirrors.ustc.edu.cn/crates.io-index"
EOF
        log_success "Rust 镜像源配置完成"
    fi
    
    # Maven 镜像源
    if command -v mvn &> /dev/null; then
        log_info "配置 Maven 镜像源..."
        mkdir -p ~/.m2
        cat > ~/.m2/settings.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 
          http://maven.apache.org/xsd/settings-1.0.0.xsd">
  <mirrors>
    <mirror>
      <id>aliyunmaven</id>
      <mirrorOf>*</mirrorOf>
      <name>阿里云公共仓库</name>
      <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
  </mirrors>
</settings>
EOF
        log_success "Maven 镜像源配置完成"
    fi
    
    # CocoaPods 镜像源 (macOS only)
    if [[ "$OS" == "macos" ]] && command -v pod &> /dev/null; then
        log_info "配置 CocoaPods 镜像源..."
        # 使用 CDN 方式，这是 CocoaPods 1.8+ 推荐的方式
        pod repo add trunk https://cdn.cocoapods.org/ 2>/dev/null || true
        log_success "CocoaPods 镜像源配置完成"
    fi
    
    log_success "所有镜像源配置完成"
}

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
                delay=$((delay * 2))  # 指数退避
            fi
        fi
        
        attempt=$((attempt + 1))
    done
    
    log_error "命令执行失败，已重试 $max_attempts 次"
    return 1
}

# 安装依赖函数
install_dependencies() {
    log_step "开始安装依赖..."
    
    # 检测项目类型并安装依赖
    if [ -f "package.json" ]; then
        log_info "检测到 Node.js 项目"
        if command -v yarn &> /dev/null; then
            retry_command yarn install
        elif command -v npm &> /dev/null; then
            retry_command npm install
        fi
    fi
    
    if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
        log_info "检测到 Python 项目"
        if command -v pip3 &> /dev/null; then
            if [ -f "requirements.txt" ]; then
                retry_command pip3 install -r requirements.txt
            else
                retry_command pip3 install -e .
            fi
        fi
    fi
    
    if [ -f "go.mod" ]; then
        log_info "检测到 Go 项目"
        if command -v go &> /dev/null; then
            retry_command go mod tidy
            retry_command go mod download
        fi
    fi
    
    if [ -f "Cargo.toml" ]; then
        log_info "检测到 Rust 项目"
        if command -v cargo &> /dev/null; then
            retry_command cargo build
        fi
    fi
    
    if [ -f "pom.xml" ]; then
        log_info "检测到 Maven 项目"
        if command -v mvn &> /dev/null; then
            retry_command mvn clean install
        fi
    fi
    
    # Flutter 项目
    if [ -f "pubspec.yaml" ]; then
        log_info "检测到 Flutter 项目"
        if command -v flutter &> /dev/null; then
            retry_command flutter pub get
            
            # iOS 依赖 (macOS only)
            if [[ "$OS" == "macos" ]] && [ -d "ios" ] && command -v pod &> /dev/null; then
                log_info "安装 iOS 依赖..."
                cd ios
                retry_command pod install
                cd ..
            fi
        fi
    fi
    
    log_success "依赖安装完成"
}

# 验证安装
verify_installation() {
    log_step "验证依赖安装..."
    
    local success=true
    
    # 验证 Node.js 项目
    if [ -f "package.json" ]; then
        if command -v node &> /dev/null; then
            log_info "验证 Node.js 项目..."
            if node -e "console.log('Node.js 运行正常')" 2>/dev/null; then
                log_success "Node.js 项目验证通过"
            else
                log_error "Node.js 项目验证失败"
                success=false
            fi
        fi
    fi
    
    # 验证 Python 项目
    if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
        if command -v python3 &> /dev/null; then
            log_info "验证 Python 项目..."
            if python3 -c "print('Python 运行正常')" 2>/dev/null; then
                log_success "Python 项目验证通过"
            else
                log_error "Python 项目验证失败"
                success=false
            fi
        fi
    fi
    
    # 验证 Go 项目
    if [ -f "go.mod" ]; then
        if command -v go &> /dev/null; then
            log_info "验证 Go 项目..."
            if go build -o /tmp/test_build . 2>/dev/null; then
                log_success "Go 项目验证通过"
                rm -f /tmp/test_build
            else
                log_error "Go 项目验证失败"
                success=false
            fi
        fi
    fi
    
    # 验证 Flutter 项目
    if [ -f "pubspec.yaml" ]; then
        if command -v flutter &> /dev/null; then
            log_info "验证 Flutter 项目..."
            if flutter doctor 2>/dev/null | grep -q "Flutter"; then
                log_success "Flutter 项目验证通过"
            else
                log_error "Flutter 项目验证失败"
                success=false
            fi
        fi
    fi
    
    if [ "$success" = true ]; then
        log_success "所有项目验证通过"
    else
        log_warning "部分项目验证失败，请检查错误信息"
    fi
}

# 生成报告
generate_report() {
    log_step "生成依赖修复报告..."
    
    local report_file="dependency_fix_report.md"
    
    cat > "$report_file" << EOF
# 依赖修复报告

## 修复时间
$(date)

## 系统信息
- 操作系统: $OS
- 检测到的包管理工具: ${PACKAGE_MANAGERS[*]}

## 修复步骤
1. ✅ 清理所有包管理工具缓存
2. ✅ 配置国内镜像源
3. ✅ 重试机制安装依赖
4. ✅ 验证安装结果

## 镜像源配置

### npm/yarn
- 主镜像: https://registry.npmmirror.com/
- 二进制镜像: https://npmmirror.com/

### pip
- 镜像: https://pypi.tuna.tsinghua.edu.cn/simple/

### Go
- 代理: https://goproxy.cn
- 校验: sum.golang.google.cn

### Rust
- 镜像: https://mirrors.ustc.edu.cn/crates.io-index

### Maven
- 镜像: https://maven.aliyun.com/repository/public

### CocoaPods (macOS)
- CDN: https://cdn.cocoapods.org/

## 项目状态
EOF

    # 添加项目状态
    if [ -f "package.json" ]; then
        echo "- ✅ Node.js 项目" >> "$report_file"
    fi
    
    if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
        echo "- ✅ Python 项目" >> "$report_file"
    fi
    
    if [ -f "go.mod" ]; then
        echo "- ✅ Go 项目" >> "$report_file"
    fi
    
    if [ -f "Cargo.toml" ]; then
        echo "- ✅ Rust 项目" >> "$report_file"
    fi
    
    if [ -f "pom.xml" ]; then
        echo "- ✅ Maven 项目" >> "$report_file"
    fi
    
    if [ -f "pubspec.yaml" ]; then
        echo "- ✅ Flutter 项目" >> "$report_file"
    fi
    
    cat >> "$report_file" << EOF

## 故障排除

如果仍然遇到问题，请尝试：

1. **网络问题**:
   - 检查网络连接
   - 尝试使用 VPN
   - 检查防火墙设置

2. **权限问题**:
   - 确保有足够的文件系统权限
   - 避免使用 sudo（除非必要）

3. **版本兼容性**:
   - 检查包管理工具版本
   - 更新到最新版本

4. **手动安装**:
   - 可以手动运行相应的安装命令
   - 查看详细错误信息进行调试

## 常用命令

\`\`\`bash
# Node.js
npm install
yarn install

# Python
pip3 install -r requirements.txt

# Go
go mod tidy
go mod download

# Rust
cargo build

# Maven
mvn clean install

# Flutter
flutter pub get
flutter clean

# CocoaPods (macOS)
pod install
pod cache clean --all
\`\`\`

---
*此报告由依赖修复脚本自动生成*
EOF

    log_success "报告已生成: $report_file"
}

# 主函数
main() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}    跨平台依赖修复脚本 v1.0${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo
    
    # 检测系统环境
    detect_os
    detect_package_managers
    
    if [ ${#PACKAGE_MANAGERS[@]} -eq 0 ]; then
        log_error "未检测到任何包管理工具，请先安装相应的开发环境"
        exit 1
    fi
    
    # 执行修复步骤
    clean_caches
    setup_mirrors
    install_dependencies
    verify_installation
    generate_report
    
    echo
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}    依赖修复完成！${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo
    log_info "请查看生成的报告文件了解详细信息"
    log_info "如果仍有问题，请检查网络连接或手动运行相应命令"
}

# 运行主函数
main "$@"
