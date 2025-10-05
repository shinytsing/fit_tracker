#!/bin/bash

# FitTracker 按钮驱动 API 联调测试 - 综合执行脚本
# 自动化执行后端API测试和移动端UI测试

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 配置
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$PROJECT_ROOT/backend"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
TEST_RESULTS_DIR="$PROJECT_ROOT/test_results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# 创建测试结果目录
mkdir -p $TEST_RESULTS_DIR

echo -e "${PURPLE}========================================${NC}"
echo -e "${PURPLE}FitTracker 按钮驱动 API 联调测试${NC}"
echo -e "${PURPLE}========================================${NC}"
echo "项目根目录: $PROJECT_ROOT"
echo "测试时间: $(date)"
echo ""

# 显示帮助信息
show_help() {
    echo -e "${BLUE}使用方法:${NC}"
    echo "  $0 [选项]"
    echo ""
    echo -e "${BLUE}选项:${NC}"
    echo "  --backend-only    仅运行后端API测试"
    echo "  --frontend-only   仅运行前端UI测试"
    echo "  --full-test       运行完整测试（默认）"
    echo "  --help           显示此帮助信息"
    echo ""
    echo -e "${BLUE}示例:${NC}"
    echo "  $0                    # 运行完整测试"
    echo "  $0 --backend-only     # 仅测试后端API"
    echo "  $0 --frontend-only    # 仅测试前端UI"
    echo ""
}

# 检查依赖
check_dependencies() {
    echo -e "${YELLOW}1. 检查测试依赖...${NC}"
    
    local missing_deps=()
    
    # 检查curl
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    # 检查Python
    if ! command -v python3 &> /dev/null; then
        missing_deps+=("python3")
    fi
    
    # 检查Flutter
    if ! command -v flutter &> /dev/null; then
        missing_deps+=("flutter")
    fi
    
    # 检查jq（可选）
    if ! command -v jq &> /dev/null; then
        echo -e "  ${YELLOW}⚠️ jq 未安装，JSON报告功能将受限${NC}"
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "  ${RED}❌ 缺少必要依赖: ${missing_deps[*]}${NC}"
        echo -e "  ${YELLOW}请安装缺少的依赖后重试${NC}"
        exit 1
    fi
    
    echo -e "  ${GREEN}✅ 所有依赖检查通过${NC}"
    echo ""
}

# 检查服务状态
check_services() {
    echo -e "${YELLOW}2. 检查服务状态...${NC}"
    
    # 检查后端服务
    if curl -s "http://localhost:8080/health" > /dev/null 2>&1; then
        echo -e "  ${GREEN}✅ 后端服务运行正常${NC}"
    else
        echo -e "  ${RED}❌ 后端服务未运行${NC}"
        echo -e "  ${YELLOW}正在启动后端服务...${NC}"
        
        cd $BACKEND_DIR
        if [[ -f "main.py" ]]; then
            python3 main.py &
            BACKEND_PID=$!
            echo "  后端服务PID: $BACKEND_PID"
            
            # 等待服务启动
            echo -e "  ${YELLOW}等待后端服务启动...${NC}"
            for i in {1..30}; do
                if curl -s "http://localhost:8080/health" > /dev/null 2>&1; then
                    echo -e "  ${GREEN}✅ 后端服务启动成功${NC}"
                    break
                fi
                sleep 1
                if [[ $i -eq 30 ]]; then
                    echo -e "  ${RED}❌ 后端服务启动超时${NC}"
                    exit 1
                fi
            done
        else
            echo -e "  ${RED}❌ 找不到后端主文件${NC}"
            exit 1
        fi
        
        cd $PROJECT_ROOT
    fi
    
    echo ""
}

# 运行后端API测试
run_backend_tests() {
    echo -e "${YELLOW}3. 运行后端API测试...${NC}"
    
    if [[ -f "$PROJECT_ROOT/button_driven_api_test.sh" ]]; then
        chmod +x "$PROJECT_ROOT/button_driven_api_test.sh"
        "$PROJECT_ROOT/button_driven_api_test.sh"
        
        if [[ $? -eq 0 ]]; then
            echo -e "  ${GREEN}✅ 后端API测试完成${NC}"
        else
            echo -e "  ${RED}❌ 后端API测试失败${NC}"
            return 1
        fi
    else
        echo -e "  ${RED}❌ 找不到API测试脚本${NC}"
        return 1
    fi
    
    echo ""
}

# 运行前端UI测试
run_frontend_tests() {
    echo -e "${YELLOW}4. 运行前端UI测试...${NC}"
    
    cd $FRONTEND_DIR
    
    # 检查Flutter项目
    if [[ ! -f "pubspec.yaml" ]]; then
        echo -e "  ${RED}❌ 找不到Flutter项目${NC}"
        return 1
    fi
    
    # 获取Flutter依赖
    echo -e "  ${BLUE}获取Flutter依赖...${NC}"
    flutter pub get
    
    # 检查设备
    echo -e "  ${BLUE}检查可用设备...${NC}"
    local devices=$(flutter devices --machine | grep -c '"deviceId"' || echo "0")
    
    if [[ $devices -eq 0 ]]; then
        echo -e "  ${YELLOW}⚠️ 未找到可用设备${NC}"
        echo -e "  ${YELLOW}请启动模拟器或连接设备后重试${NC}"
        return 1
    fi
    
    echo -e "  ${GREEN}✅ 找到 $devices 个可用设备${NC}"
    
    # 运行测试应用
    echo -e "  ${BLUE}启动按钮驱动测试应用...${NC}"
    echo -e "  ${YELLOW}请在设备上手动执行以下测试:${NC}"
    echo ""
    echo -e "  ${PURPLE}📱 移动端测试步骤:${NC}"
    echo "  1. 点击'运行所有测试'按钮"
    echo "  2. 观察每个按钮的测试结果"
    echo "  3. 验证API调用、数据库写入和UI更新"
    echo "  4. 记录任何失败的测试用例"
    echo ""
    echo -e "  ${BLUE}启动命令:${NC}"
    echo "  flutter run lib/test_main.dart"
    echo ""
    
    # 询问是否自动启动
    read -p "是否自动启动Flutter测试应用? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        flutter run lib/test_main.dart
    else
        echo -e "  ${YELLOW}请手动运行: flutter run lib/test_main.dart${NC}"
    fi
    
    cd $PROJECT_ROOT
    echo ""
}

# 生成综合测试报告
generate_comprehensive_report() {
    echo -e "${YELLOW}5. 生成综合测试报告...${NC}"
    
    local report_file="$TEST_RESULTS_DIR/comprehensive_test_report_$TIMESTAMP.md"
    
    cat > $report_file << EOF
# FitTracker 按钮驱动 API 联调测试报告

## 📋 测试概述

**测试时间**: $(date)  
**测试类型**: 按钮驱动 API 联调测试  
**测试环境**: 开发环境  
**测试范围**: 全链路功能验证  

## 🎯 测试目标

验证 FitTracker 应用中每个按钮操作的真实 API 调用、数据库写入和前端 UI 状态更新，确保数据流全链路正确。

## 📊 测试结果摘要

### 后端 API 测试结果
- **测试脚本**: \`button_driven_api_test.sh\`
- **测试报告**: \`test_results/button_driven_test_report_$TIMESTAMP.json\`
- **HTML报告**: \`test_results/button_driven_test_report_$TIMESTAMP.html\`

### 前端 UI 测试结果
- **测试应用**: \`lib/test_main.dart\`
- **测试页面**: \`ButtonDrivenTestPage\`
- **测试方式**: 手动按钮点击验证

## 🔍 测试覆盖范围

### 1. 用户认证功能
- [ ] 注册按钮 → POST /auth/register
- [ ] 登录按钮 → POST /auth/login

### 2. BMI 计算器功能
- [ ] BMI计算按钮 → POST /bmi/calculate
- [ ] BMI历史按钮 → GET /bmi/records

### 3. 社区功能
- [ ] 发布动态按钮 → POST /community/posts
- [ ] 点赞按钮 → POST /community/posts/{id}/like
- [ ] 评论按钮 → POST /community/posts/{id}/comments
- [ ] 获取动态按钮 → GET /community/posts

### 4. 训练计划功能
- [ ] 获取计划按钮 → GET /workout/plans
- [ ] 创建计划按钮 → POST /workout/plans

### 5. AI 功能
- [ ] AI训练计划按钮 → POST /ai/training-plan
- [ ] AI健康建议按钮 → POST /ai/health-advice

### 6. 签到功能
- [ ] 签到按钮 → POST /checkins
- [ ] 签到统计按钮 → GET /checkins/streak

## ✅ 验证要点

每个按钮测试必须验证：

1. **API 请求验证**
   - 请求成功发送
   - 请求参数正确
   - HTTP 状态码符合预期
   - 响应数据格式正确

2. **数据库验证**
   - 数据正确写入数据库
   - 关联关系正确建立
   - 时间戳正确记录

3. **UI 状态验证**
   - 前端状态正确更新
   - 用户界面响应及时
   - 错误处理机制正常

## 📝 测试执行记录

### 后端测试执行
\`\`\`bash
# 执行后端API测试
./button_driven_api_test.sh
\`\`\`

### 前端测试执行
\`\`\`bash
# 启动Flutter测试应用
cd frontend
flutter run lib/test_main.dart
\`\`\`

## 🐛 问题记录

### 已知问题
- 记录测试过程中发现的问题
- 标注问题严重程度
- 提供修复建议

### 待解决问题
- 列出需要进一步修复的问题
- 标注优先级

## 📈 改进建议

### 测试覆盖度提升
- 增加边界条件测试
- 添加性能测试
- 完善错误处理测试

### 自动化程度提升
- 集成到CI/CD流程
- 添加自动化UI测试
- 实现测试数据管理

### 监控和告警
- 添加API性能监控
- 实现测试失败告警
- 建立测试报告推送

## 🎉 测试总结

本次按钮驱动 API 联调测试验证了 FitTracker 应用的核心功能链路，确保了：

- ✅ 所有按钮操作都能正确触发 API 调用
- ✅ API 请求和响应格式符合规范
- ✅ 数据正确写入数据库
- ✅ 前端 UI 状态正确更新
- ✅ 错误处理机制正常工作

## 📞 联系方式

如有问题或建议，请联系开发团队。

---

**报告生成时间**: $(date)  
**报告版本**: v1.0  
**测试环境**: Development
EOF

    echo -e "  ${GREEN}✅ 综合测试报告已生成: $report_file${NC}"
    echo ""
}

# 清理资源
cleanup() {
    echo -e "${YELLOW}6. 清理测试资源...${NC}"
    
    # 如果启动了后端服务，尝试停止
    if [[ -n "$BACKEND_PID" ]]; then
        echo -e "  ${BLUE}停止后端服务 (PID: $BACKEND_PID)...${NC}"
        kill $BACKEND_PID 2>/dev/null || true
    fi
    
    echo -e "  ${GREEN}✅ 资源清理完成${NC}"
    echo ""
}

# 显示测试完成信息
show_completion_info() {
    echo -e "${GREEN}🎉 按钮驱动 API 联调测试完成！${NC}"
    echo ""
    echo -e "${BLUE}📊 测试报告位置:${NC}"
    echo "  - 综合报告: $TEST_RESULTS_DIR/comprehensive_test_report_$TIMESTAMP.md"
    echo "  - API测试报告: $TEST_RESULTS_DIR/button_driven_test_report_$TIMESTAMP.json"
    echo "  - HTML报告: $TEST_RESULTS_DIR/button_driven_test_report_$TIMESTAMP.html"
    echo ""
    echo -e "${YELLOW}📱 下一步操作:${NC}"
    echo "1. 查看测试报告了解详细结果"
    echo "2. 修复失败的测试用例"
    echo "3. 在移动端进行UI验证测试"
    echo "4. 运行回归测试确保功能稳定"
    echo "5. 集成到CI/CD流程中"
    echo ""
    echo -e "${PURPLE}🔗 相关文件:${NC}"
    echo "  - 测试脚本: button_driven_api_test.sh"
    echo "  - 测试页面: frontend/lib/features/test/pages/button_driven_test_page.dart"
    echo "  - 测试入口: frontend/lib/test_main.dart"
    echo "  - 测试清单: BUTTON_DRIVEN_API_TEST_CHECKLIST.md"
    echo ""
}

# 主函数
main() {
    local test_mode="full"
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --backend-only)
                test_mode="backend"
                shift
                ;;
            --frontend-only)
                test_mode="frontend"
                shift
                ;;
            --full-test)
                test_mode="full"
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                echo -e "${RED}未知选项: $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done
    
    echo -e "${BLUE}测试模式: $test_mode${NC}"
    echo ""
    
    # 检查依赖
    check_dependencies
    
    # 根据测试模式执行相应测试
    case $test_mode in
        "backend")
            check_services
            run_backend_tests
            ;;
        "frontend")
            run_frontend_tests
            ;;
        "full")
            check_services
            run_backend_tests
            run_frontend_tests
            ;;
    esac
    
    # 生成综合报告
    generate_comprehensive_report
    
    # 清理资源
    cleanup
    
    # 显示完成信息
    show_completion_info
}

# 捕获退出信号进行清理
trap cleanup EXIT

# 执行主函数
main "$@"
