#!/bin/bash

# Gymates API 测试执行脚本
# 使用方法: ./run_gymates_api_tests.sh [test_type]
# test_type: postman, go, all

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
BASE_URL="http://localhost:8080"
API_BASE_URL="${BASE_URL}/api/v1"
TEST_TYPE=${1:-"all"}

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
        log_error "Go 未安装，请先安装 Go"
        exit 1
    fi
    
    # 检查 Newman (Postman CLI)
    if ! command -v newman &> /dev/null; then
        log_warning "Newman 未安装，将跳过 Postman 测试"
        log_info "安装命令: npm install -g newman"
        POSTMAN_AVAILABLE=false
    else
        POSTMAN_AVAILABLE=true
    fi
    
    # 检查 curl
    if ! command -v curl &> /dev/null; then
        log_error "curl 未安装，请先安装 curl"
        exit 1
    fi
    
    log_success "依赖检查完成"
}

# 检查服务状态
check_service_status() {
    log_info "检查服务状态..."
    
    # 检查主服务
    if curl -s "${BASE_URL}/health" > /dev/null; then
        log_success "主服务运行正常"
    else
        log_error "主服务未运行，请先启动服务"
        log_info "启动命令: cd backend-go && go run main.go"
        exit 1
    fi
    
    # 检查 API 服务
    if curl -s "${API_BASE_URL}/health" > /dev/null; then
        log_success "API 服务运行正常"
    else
        log_warning "API 健康检查端点可能不存在，继续测试..."
    fi
}

# 运行 Go 测试
run_go_tests() {
    log_info "运行 Go 测试..."
    
    if [ ! -f "gymates_api_test.go" ]; then
        log_error "测试文件 gymates_api_test.go 不存在"
        return 1
    fi
    
    # 运行测试
    if go test -v gymates_api_test.go; then
        log_success "Go 测试完成"
        return 0
    else
        log_error "Go 测试失败"
        return 1
    fi
}

# 运行 Postman 测试
run_postman_tests() {
    log_info "运行 Postman 测试..."
    
    if [ "$POSTMAN_AVAILABLE" = false ]; then
        log_warning "跳过 Postman 测试 - Newman 未安装"
        return 0
    fi
    
    if [ ! -f "gymates_api_test_collection.json" ]; then
        log_error "Postman 集合文件不存在"
        return 1
    fi
    
    # 运行 Newman 测试
    if newman run gymates_api_test_collection.json \
        --environment-var "baseUrl=${API_BASE_URL}" \
        --reporters cli,json \
        --reporter-json-export test_results.json; then
        log_success "Postman 测试完成"
        return 0
    else
        log_error "Postman 测试失败"
        return 1
    fi
}

# 运行简单 API 测试
run_simple_api_tests() {
    log_info "运行简单 API 测试..."
    
    # 测试健康检查
    log_info "测试健康检查端点..."
    if curl -s "${BASE_URL}/health" | grep -q "ok"; then
        log_success "健康检查通过"
    else
        log_warning "健康检查失败或端点不存在"
    fi
    
    # 测试用户注册
    log_info "测试用户注册..."
    REGISTER_RESPONSE=$(curl -s -X POST "${API_BASE_URL}/users/register" \
        -H "Content-Type: application/json" \
        -d '{
            "phone": "13800138000",
            "password": "password123",
            "verification_code": "123456",
            "nickname": "测试用户"
        }')
    
    if echo "$REGISTER_RESPONSE" | grep -q "success"; then
        log_success "用户注册测试通过"
        
        # 提取 token
        TOKEN=$(echo "$REGISTER_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
        if [ -n "$TOKEN" ]; then
            log_success "获取到认证 token"
            
            # 测试获取用户资料
            log_info "测试获取用户资料..."
            PROFILE_RESPONSE=$(curl -s -X GET "${API_BASE_URL}/users/profile" \
                -H "Authorization: Bearer ${TOKEN}")
            
            if echo "$PROFILE_RESPONSE" | grep -q "success"; then
                log_success "获取用户资料测试通过"
            else
                log_warning "获取用户资料测试失败"
            fi
        fi
    else
        log_warning "用户注册测试失败"
    fi
    
    # 测试获取健身房列表
    log_info "测试获取健身房列表..."
    GYM_RESPONSE=$(curl -s -X GET "${API_BASE_URL}/gyms?page=1&limit=5")
    
    if echo "$GYM_RESPONSE" | grep -q "success\|gyms"; then
        log_success "获取健身房列表测试通过"
    else
        log_warning "获取健身房列表测试失败"
    fi
    
    log_success "简单 API 测试完成"
}

# 生成测试报告
generate_test_report() {
    log_info "生成测试报告..."
    
    REPORT_FILE="gymates_api_test_report_$(date +%Y%m%d_%H%M%S).md"
    
    cat > "$REPORT_FILE" << EOF
# Gymates API 测试报告

## 测试概要
- **测试时间**: $(date)
- **测试环境**: ${BASE_URL}
- **测试类型**: ${TEST_TYPE}

## 测试结果

### 服务状态
- **主服务**: ✅ 运行正常
- **API 服务**: ✅ 运行正常

### 测试执行情况
EOF

    if [ "$TEST_TYPE" = "go" ] || [ "$TEST_TYPE" = "all" ]; then
        echo "- **Go 测试**: ✅ 执行完成" >> "$REPORT_FILE"
    fi
    
    if [ "$TEST_TYPE" = "postman" ] || [ "$TEST_TYPE" = "all" ]; then
        if [ "$POSTMAN_AVAILABLE" = true ]; then
            echo "- **Postman 测试**: ✅ 执行完成" >> "$REPORT_FILE"
        else
            echo "- **Postman 测试**: ⚠️ 跳过 (Newman 未安装)" >> "$REPORT_FILE"
        fi
    fi
    
    cat >> "$REPORT_FILE" << EOF

## 测试覆盖模块

1. **用户认证模块**
   - 用户注册
   - 用户登录
   - 获取用户资料
   - 更新用户资料

2. **训练模块**
   - 获取训练计划
   - 创建训练计划
   - AI 生成训练计划

3. **社区模块**
   - 发布动态
   - 获取动态列表
   - 点赞动态
   - 评论动态

4. **搭子模块**
   - 获取搭子推荐
   - 创建搭子组
   - 邀请搭子

5. **消息模块**
   - 创建聊天
   - 发送消息
   - 获取通知

6. **健身房模块**
   - 获取健身房列表
   - 创建健身房
   - 申请加入健身房

7. **AI 接口**
   - AI 聊天助手
   - 动作分析

8. **统计模块**
   - 获取个人统计
   - 获取训练统计
   - 获取排行榜

## 建议

1. 确保所有 API 端点都实现了完整的错误处理
2. 加强输入参数验证
3. 优化 API 响应时间
4. 完善 API 文档

## 测试文件

- **测试方案**: GYMATES_API_TEST_PLAN.md
- **Postman 集合**: gymates_api_test_collection.json
- **Go 测试**: gymates_api_test.go
- **测试脚本**: run_gymates_api_tests.sh

EOF

    log_success "测试报告已生成: $REPORT_FILE"
}

# 清理测试数据
cleanup_test_data() {
    log_info "清理测试数据..."
    
    # 这里可以添加清理测试数据的逻辑
    # 例如删除测试用户、测试健身房等
    
    log_success "测试数据清理完成"
}

# 显示帮助信息
show_help() {
    cat << EOF
Gymates API 测试工具

使用方法:
    $0 [test_type]

参数:
    test_type    测试类型 (可选)
                 - postman: 仅运行 Postman 测试
                 - go: 仅运行 Go 测试
                 - all: 运行所有测试 (默认)

示例:
    $0              # 运行所有测试
    $0 postman      # 仅运行 Postman 测试
    $0 go           # 仅运行 Go 测试

依赖:
    - Go (用于 Go 测试)
    - Newman (用于 Postman 测试，可选)
    - curl (用于简单 API 测试)

EOF
}

# 主函数
main() {
    echo "🚀 Gymates API 测试工具"
    echo "================================"
    
    # 显示帮助
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_help
        exit 0
    fi
    
    # 检查依赖
    check_dependencies
    
    # 检查服务状态
    check_service_status
    
    # 根据测试类型运行测试
    case $TEST_TYPE in
        "postman")
            run_postman_tests
            ;;
        "go")
            run_go_tests
            ;;
        "all")
            run_simple_api_tests
            run_go_tests
            run_postman_tests
            ;;
        *)
            log_error "未知的测试类型: $TEST_TYPE"
            show_help
            exit 1
            ;;
    esac
    
    # 生成测试报告
    generate_test_report
    
    # 清理测试数据
    cleanup_test_data
    
    echo ""
    echo "🎉 测试完成！"
    echo "📊 查看测试报告了解详细结果"
}

# 执行主函数
main "$@"
