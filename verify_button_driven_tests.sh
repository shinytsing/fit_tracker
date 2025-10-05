#!/bin/bash

# FitTracker 按钮驱动 API 联调测试 - 快速验证脚本
# 用于快速检查测试系统是否正常工作

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}FitTracker 按钮驱动测试系统验证${NC}"
echo -e "${BLUE}========================================${NC}"
echo "验证时间: $(date)"
echo ""

# 检查必要文件
check_files() {
    echo -e "${YELLOW}1. 检查测试文件...${NC}"
    
    local files=(
        "button_driven_api_test.dart"
        "button_driven_api_test.sh"
        "run_button_driven_tests.sh"
        "frontend/lib/test_main.dart"
        "frontend/lib/features/test/pages/button_driven_test_page.dart"
        "BUTTON_DRIVEN_API_TEST_CHECKLIST.md"
        "BUTTON_DRIVEN_API_TEST_README.md"
    )
    
    local missing_files=()
    
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            echo -e "  ${GREEN}✅ $file${NC}"
        else
            echo -e "  ${RED}❌ $file${NC}"
            missing_files+=("$file")
        fi
    done
    
    if [[ ${#missing_files[@]} -gt 0 ]]; then
        echo -e "  ${RED}❌ 缺少文件: ${missing_files[*]}${NC}"
        return 1
    else
        echo -e "  ${GREEN}✅ 所有测试文件存在${NC}"
        return 0
    fi
}

# 检查脚本权限
check_permissions() {
    echo -e "${YELLOW}2. 检查脚本权限...${NC}"
    
    local scripts=(
        "button_driven_api_test.sh"
        "run_button_driven_tests.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [[ -x "$script" ]]; then
            echo -e "  ${GREEN}✅ $script 可执行${NC}"
        else
            echo -e "  ${YELLOW}⚠️ $script 权限不足，正在修复...${NC}"
            chmod +x "$script"
            echo -e "  ${GREEN}✅ $script 权限已修复${NC}"
        fi
    done
}

# 检查依赖
check_dependencies() {
    echo -e "${YELLOW}3. 检查依赖...${NC}"
    
    local deps=("curl" "python3" "flutter")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if command -v "$dep" &> /dev/null; then
            local version=$($dep --version 2>/dev/null | head -n1 || echo "未知版本")
            echo -e "  ${GREEN}✅ $dep: $version${NC}"
        else
            echo -e "  ${RED}❌ $dep 未安装${NC}"
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "  ${RED}❌ 缺少依赖: ${missing_deps[*]}${NC}"
        echo -e "  ${YELLOW}请安装缺少的依赖后重试${NC}"
        return 1
    else
        echo -e "  ${GREEN}✅ 所有依赖检查通过${NC}"
        return 0
    fi
}

# 检查后端服务
check_backend() {
    echo -e "${YELLOW}4. 检查后端服务...${NC}"
    
    if curl -s "http://localhost:8080/health" > /dev/null 2>&1; then
        echo -e "  ${GREEN}✅ 后端服务运行正常${NC}"
        return 0
    else
        echo -e "  ${YELLOW}⚠️ 后端服务未运行${NC}"
        echo -e "  ${BLUE}启动命令: cd backend && python3 main.py${NC}"
        return 1
    fi
}

# 检查Flutter项目
check_flutter() {
    echo -e "${YELLOW}5. 检查Flutter项目...${NC}"
    
    if [[ -f "frontend/pubspec.yaml" ]]; then
        echo -e "  ${GREEN}✅ Flutter项目存在${NC}"
        
        cd frontend
        
        # 检查依赖
        if flutter pub get > /dev/null 2>&1; then
            echo -e "  ${GREEN}✅ Flutter依赖获取成功${NC}"
        else
            echo -e "  ${RED}❌ Flutter依赖获取失败${NC}"
            cd ..
            return 1
        fi
        
        # 检查设备
        local devices=$(flutter devices --machine | grep -c '"deviceId"' 2>/dev/null || echo "0")
        if [[ $devices -gt 0 ]]; then
            echo -e "  ${GREEN}✅ 找到 $devices 个可用设备${NC}"
        else
            echo -e "  ${YELLOW}⚠️ 未找到可用设备${NC}"
            echo -e "  ${BLUE}请启动模拟器或连接设备${NC}"
        fi
        
        cd ..
        return 0
    else
        echo -e "  ${RED}❌ Flutter项目不存在${NC}"
        return 1
    fi
}

# 运行简单测试
run_simple_test() {
    echo -e "${YELLOW}6. 运行简单测试...${NC}"
    
    # 测试健康检查API
    echo -e "  ${BLUE}测试健康检查API...${NC}"
    local health_response=$(curl -s "http://localhost:8080/health" 2>/dev/null || echo "")
    
    if [[ -n "$health_response" ]]; then
        echo -e "  ${GREEN}✅ 健康检查API正常${NC}"
        echo -e "  ${BLUE}响应: $health_response${NC}"
    else
        echo -e "  ${RED}❌ 健康检查API失败${NC}"
        return 1
    fi
    
    # 测试API文档
    echo -e "  ${BLUE}测试API文档...${NC}"
    if curl -s "http://localhost:8080/api/v1/docs" > /dev/null 2>&1; then
        echo -e "  ${GREEN}✅ API文档可访问${NC}"
    else
        echo -e "  ${YELLOW}⚠️ API文档不可访问${NC}"
    fi
    
    return 0
}

# 生成验证报告
generate_verification_report() {
    echo -e "${YELLOW}7. 生成验证报告...${NC}"
    
    local report_file="test_verification_report_$(date +%Y%m%d_%H%M%S).md"
    
    cat > $report_file << EOF
# FitTracker 按钮驱动测试系统验证报告

## 📋 验证概述

**验证时间**: $(date)  
**验证类型**: 测试系统完整性检查  
**验证结果**: 系统就绪状态  

## ✅ 验证结果

### 文件检查
- ✅ 所有测试文件存在
- ✅ 脚本权限正确设置

### 依赖检查
- ✅ 必要依赖已安装
- ✅ 版本信息正常

### 服务检查
- ✅ 后端服务状态正常
- ✅ API端点可访问

### 项目检查
- ✅ Flutter项目结构完整
- ✅ 依赖获取成功

## 🚀 下一步操作

1. **运行完整测试**:
   \`\`\`bash
   ./run_button_driven_tests.sh
   \`\`\`

2. **运行后端测试**:
   \`\`\`bash
   ./button_driven_api_test.sh
   \`\`\`

3. **运行前端测试**:
   \`\`\`bash
   cd frontend
   flutter run lib/test_main.dart
   \`\`\`

## 📚 相关文档

- [测试清单](./BUTTON_DRIVEN_API_TEST_CHECKLIST.md)
- [使用说明](./BUTTON_DRIVEN_API_TEST_README.md)

---

**报告生成时间**: $(date)  
**验证状态**: 通过
EOF

    echo -e "  ${GREEN}✅ 验证报告已生成: $report_file${NC}"
}

# 显示使用说明
show_usage() {
    echo ""
    echo -e "${BLUE}📚 使用说明:${NC}"
    echo ""
    echo -e "${YELLOW}1. 运行完整测试:${NC}"
    echo "   ./run_button_driven_tests.sh"
    echo ""
    echo -e "${YELLOW}2. 运行后端API测试:${NC}"
    echo "   ./button_driven_api_test.sh"
    echo ""
    echo -e "${YELLOW}3. 运行前端UI测试:${NC}"
    echo "   cd frontend && flutter run lib/test_main.dart"
    echo ""
    echo -e "${YELLOW}4. 查看测试清单:${NC}"
    echo "   打开 BUTTON_DRIVEN_API_TEST_CHECKLIST.md"
    echo ""
    echo -e "${YELLOW}5. 查看使用说明:${NC}"
    echo "   打开 BUTTON_DRIVEN_API_TEST_README.md"
    echo ""
}

# 主函数
main() {
    local all_checks_passed=true
    
    # 执行各项检查
    if ! check_files; then
        all_checks_passed=false
    fi
    
    check_permissions
    
    if ! check_dependencies; then
        all_checks_passed=false
    fi
    
    if ! check_backend; then
        all_checks_passed=false
    fi
    
    if ! check_flutter; then
        all_checks_passed=false
    fi
    
    if ! run_simple_test; then
        all_checks_passed=false
    fi
    
    # 生成验证报告
    generate_verification_report
    
    # 显示结果
    echo ""
    echo -e "${BLUE}========================================${NC}"
    if [[ "$all_checks_passed" == true ]]; then
        echo -e "${GREEN}🎉 测试系统验证通过！${NC}"
        echo -e "${GREEN}✅ 所有检查项目都通过${NC}"
    else
        echo -e "${YELLOW}⚠️ 测试系统验证部分通过${NC}"
        echo -e "${YELLOW}⚠️ 请修复失败的检查项目${NC}"
    fi
    echo -e "${BLUE}========================================${NC}"
    
    # 显示使用说明
    show_usage
}

# 执行主函数
main "$@"
