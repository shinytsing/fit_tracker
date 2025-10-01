#!/bin/bash

# FitTracker 自动化测试演示脚本
# 展示如何使用自动化测试系统

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT="/Users/gaojie/Desktop/fittraker"

# 打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}[$(date '+%H:%M:%S')] ${message}${NC}"
}

# 打印标题
print_title() {
    echo -e "${PURPLE}"
    echo "=================================================="
    echo "  $1"
    echo "=================================================="
    echo -e "${NC}"
}

# 打印步骤
print_step() {
    echo -e "${CYAN}步骤 $1: $2${NC}"
}

# 演示开始
print_title "FitTracker 自动化测试系统演示"

print_message $BLUE "🚀 欢迎使用 FitTracker 自动化测试系统！"
print_message $YELLOW "本演示将展示如何使用自动化测试系统来验证 FitTracker 应用的功能。"

echo
print_step "1" "检查测试环境"
print_message $BLUE "检查 Dart 环境..."
if command -v dart &> /dev/null; then
    print_message $GREEN "✅ Dart 环境正常"
    dart --version
else
    print_message $RED "❌ Dart 环境未安装"
    exit 1
fi

echo
print_message $BLUE "检查 Flutter 环境..."
if command -v flutter &> /dev/null; then
    print_message $GREEN "✅ Flutter 环境正常"
    flutter --version
else
    print_message $RED "❌ Flutter 环境未安装"
    exit 1
fi

echo
print_step "2" "展示测试文件结构"
print_message $BLUE "测试系统包含以下文件："
echo
echo "📁 核心测试框架："
echo "   - test_automation_framework.dart      # 核心测试框架"
echo "   - api_test_module.dart                # API 测试模块"
echo "   - frontend_test_module.dart           # 前端测试模块"
echo "   - test_report_generator.dart          # 测试报告生成器"
echo "   - test_executor.dart                  # 测试执行器"
echo
echo "📁 测试入口："
echo "   - test_automation_main.dart           # 主测试入口"
echo "   - test_automation.sh                  # 完整测试脚本"
echo "   - run_tests.sh                        # 快速测试脚本"
echo
echo "📁 文档："
echo "   - TEST_AUTOMATION_README.md           # 详细使用说明"

echo
print_step "3" "展示测试功能"
print_message $BLUE "测试系统支持以下功能："
echo
echo "🧪 测试模块："
echo "   - API 接口测试 (用户认证、运动记录、BMI计算等)"
echo "   - 前端交互测试 (页面加载、表单输入、按钮点击等)"
echo "   - 性能测试 (API响应时间、应用性能)"
echo "   - 错误处理测试 (边界条件、异常情况)"
echo
echo "📊 报告生成："
echo "   - JSON 格式报告 (结构化数据)"
echo "   - Markdown 格式报告 (人类可读)"
echo "   - 测试摘要 (简洁概览)"
echo "   - 质量评估 (综合评分)"
echo "   - 仪表板数据 (可视化展示)"

echo
print_step "4" "演示测试命令"
print_message $BLUE "以下是常用的测试命令："
echo
echo "🚀 执行所有测试："
echo "   ./run_tests.sh"
echo
echo "⚡ 仅执行 API 测试："
echo "   ./run_tests.sh --api"
echo
echo "🎨 执行综合测试："
echo "   ./run_tests.sh --comprehensive"
echo
echo "📊 查看测试报告："
echo "   ./run_tests.sh --reports"
echo
echo "🧹 清理测试文件："
echo "   ./run_tests.sh --cleanup"

echo
print_step "5" "演示测试执行"
print_message $BLUE "现在演示如何执行快速 API 测试..."

cd "$PROJECT_ROOT"

# 检查后端服务是否运行
print_message $YELLOW "检查后端服务状态..."
if curl -s "http://localhost:8080/api/v1/health" > /dev/null 2>&1; then
    print_message $GREEN "✅ 后端服务正在运行"
else
    print_message $YELLOW "⚠️ 后端服务未运行，将尝试启动..."
    print_message $BLUE "请手动启动后端服务："
    echo "   cd backend-go"
    echo "   go run cmd/server/main.go"
    echo
    print_message $YELLOW "或者使用完整测试脚本："
    echo "   ./test_automation.sh"
    echo
    print_message $BLUE "演示将跳过实际测试执行，仅展示命令..."
fi

echo
print_step "6" "展示测试报告示例"
print_message $BLUE "测试完成后会生成以下报告文件："
echo
echo "📄 JSON 格式报告："
echo "   fittracker_comprehensive_test_report_*.json"
echo "   fittracker_api_test_report_*.json"
echo "   fittracker_frontend_test_report_*.json"
echo
echo "📄 Markdown 格式报告："
echo "   fittracker_comprehensive_test_report_*.md"
echo
echo "📊 仪表板数据："
echo "   fittracker_test_dashboard_*.json"
echo
echo "📈 性能测试结果："
echo "   fittracker_performance_test_*.json"

echo
print_step "7" "展示测试结果解读"
print_message $BLUE "测试结果状态说明："
echo
echo "✅ 通过 (passed)    - 测试成功执行，结果符合预期"
echo "❌ 失败 (failed)    - 测试执行失败，需要修复"
echo "⚠️ 警告 (warning)   - 测试执行成功，但结果不完全符合预期"
echo
print_message $BLUE "质量评估等级："
echo "优秀 (90-100分)     - 测试覆盖率高，功能稳定"
echo "良好 (80-89分)      - 测试覆盖率良好，功能基本稳定"
echo "一般 (70-79分)      - 测试覆盖率一般，存在一些问题"
echo "较差 (60-69分)      - 测试覆盖率较低，存在较多问题"
echo "需要改进 (<60分)    - 测试覆盖率很低，需要大量改进"

echo
print_step "8" "展示故障排除"
print_message $BLUE "常见问题及解决方案："
echo
echo "🔧 连接失败："
echo "   - 检查后端服务是否启动"
echo "   - 检查网络连接"
echo "   - 验证 API 地址配置"
echo
echo "🔐 认证失败："
echo "   - 检查用户注册/登录功能"
echo "   - 验证 Token 生成和验证"
echo
echo "⏱️ 测试超时："
echo "   - 增加超时时间"
echo "   - 检查服务性能"
echo "   - 优化测试用例"

echo
print_title "演示完成"

print_message $GREEN "🎉 FitTracker 自动化测试系统演示完成！"
print_message $BLUE "📚 更多详细信息请查看："
echo "   - TEST_AUTOMATION_README.md (详细使用说明)"
echo "   - 各个测试模块的源代码注释"
echo
print_message $YELLOW "💡 开始使用："
echo "   1. 确保后端服务运行"
echo "   2. 执行 ./run_tests.sh --api 进行快速测试"
echo "   3. 查看生成的测试报告"
echo "   4. 根据报告结果优化应用"
echo
print_message $PURPLE "🚀 祝您测试愉快！"
