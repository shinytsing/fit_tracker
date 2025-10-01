# FitTracker 自动化测试系统

## 概述

FitTracker 自动化测试系统是一个全面的测试框架，用于验证 FitTracker 健康管理 App 的前端与后端 API 交互功能。该系统包含 API 测试、前端交互测试、性能测试和错误处理测试等多个模块。

## 功能特性

### 🧪 测试模块
- **API 接口测试**: 测试所有后端 API 接口的功能和响应
- **前端交互测试**: 测试 Flutter 应用的用户界面和交互功能
- **性能测试**: 测试 API 响应时间和应用性能
- **错误处理测试**: 测试各种错误情况和边界条件
- **综合测试**: 整合所有测试模块的完整测试套件

### 📊 测试覆盖范围
- 用户认证模块（登录、注册、登出）
- 运动记录模块（训练记录、训练计划、运动动作）
- BMI 计算模块（BMI 计算、记录管理）
- 营养管理模块（营养计算、食物搜索、记录管理）
- 社区功能模块（动态发布、点赞、评论、挑战）
- 签到功能模块（签到记录、日历、连续天数、成就）

### 📈 报告生成
- **JSON 格式报告**: 结构化的测试数据，便于程序处理
- **Markdown 格式报告**: 人类可读的详细测试报告
- **测试摘要**: 简洁的测试结果概览
- **质量评估**: 综合的质量评分和建议
- **仪表板数据**: 用于可视化展示的测试数据

## 文件结构

```
fittraker/
├── test_automation_framework.dart      # 核心测试框架
├── api_test_module.dart                # API 测试模块
├── frontend_test_module.dart           # 前端测试模块
├── test_report_generator.dart          # 测试报告生成器
├── test_executor.dart                  # 测试执行器
├── test_automation_main.dart           # 主测试入口
├── test_automation.sh                  # 完整测试脚本
└── run_tests.sh                        # 快速测试脚本
```

## 使用方法

### 1. 环境准备

确保已安装以下环境：
- Dart SDK
- Flutter SDK
- Go (用于后端服务)

### 2. 启动服务

在运行测试之前，需要启动后端服务：

```bash
# 启动后端服务
cd backend-go
go run cmd/server/main.go
```

### 3. 运行测试

#### 使用快速测试脚本（推荐）

```bash
# 执行所有测试
./run_tests.sh

# 仅执行 API 测试
./run_tests.sh --api

# 执行综合测试
./run_tests.sh --comprehensive

# 执行性能测试
./run_tests.sh --performance

# 执行错误处理测试
./run_tests.sh --error-handling

# 显示测试报告
./run_tests.sh --reports

# 清理测试文件
./run_tests.sh --cleanup
```

#### 使用完整测试脚本

```bash
# 执行完整测试（包括启动服务）
./test_automation.sh

# 仅测试后端
./test_automation.sh --backend-only

# 清理资源
./test_automation.sh --cleanup
```

#### 直接使用 Dart 命令

```bash
# 执行所有测试
dart test_automation_main.dart

# 执行特定测试
dart test_automation_main.dart --name="执行综合自动化测试"
dart test_automation_main.dart --name="执行快速API测试"
dart test_automation_main.dart --name="执行性能测试"
dart test_automation_main.dart --name="执行错误处理测试"
```

### 4. 查看测试报告

测试完成后，会生成以下文件：
- `fittracker_comprehensive_test_report_*.json` - 综合测试报告（JSON）
- `fittracker_comprehensive_test_report_*.md` - 综合测试报告（Markdown）
- `fittracker_api_test_report_*.json` - API 测试报告（JSON）
- `fittracker_frontend_test_report_*.json` - 前端测试报告（JSON）
- `fittracker_test_dashboard_*.json` - 测试仪表板数据
- `fittracker_performance_test_*.json` - 性能测试结果

## 测试配置

### API 测试配置

API 测试默认连接到 `http://10.0.2.2:8080/api/v1`，可以通过修改 `api_test_module.dart` 中的 `_baseUrl` 来更改。

### 前端测试配置

前端测试需要 Flutter 环境，确保设备或模拟器已连接。

### 测试超时设置

默认超时时间为 30 秒，可以通过修改相关文件中的 `timeout` 参数来调整。

## 测试结果解读

### 测试状态
- ✅ **通过 (passed)**: 测试成功执行，结果符合预期
- ❌ **失败 (failed)**: 测试执行失败，需要修复
- ⚠️ **警告 (warning)**: 测试执行成功，但结果不完全符合预期

### 质量评估
- **优秀 (90-100分)**: 测试覆盖率高，功能稳定
- **良好 (80-89分)**: 测试覆盖率良好，功能基本稳定
- **一般 (70-79分)**: 测试覆盖率一般，存在一些问题
- **较差 (60-69分)**: 测试覆盖率较低，存在较多问题
- **需要改进 (<60分)**: 测试覆盖率很低，需要大量改进

### 性能指标
- **响应时间**: API 平均响应时间
- **成功率**: 测试通过率
- **覆盖率**: 功能测试覆盖率

## 故障排除

### 常见问题

1. **连接失败**
   - 检查后端服务是否启动
   - 检查网络连接
   - 验证 API 地址配置

2. **认证失败**
   - 检查用户注册/登录功能
   - 验证 Token 生成和验证

3. **测试超时**
   - 增加超时时间
   - 检查服务性能
   - 优化测试用例

4. **Flutter 测试失败**
   - 检查 Flutter 环境
   - 确保设备/模拟器连接
   - 验证应用构建

### 调试技巧

1. **查看详细日志**
   ```bash
   dart test_automation_main.dart --verbose
   ```

2. **单独测试模块**
   ```bash
   dart test_automation_main.dart --name="测试认证模块"
   ```

3. **检查测试报告**
   ```bash
   ./run_tests.sh --reports
   ```

## 扩展开发

### 添加新的测试用例

1. 在相应的测试模块中添加新的测试方法
2. 更新测试执行器以包含新测试
3. 更新测试报告生成器以处理新结果

### 自定义测试配置

1. 修改 `TestConfig` 类以添加新的配置选项
2. 更新测试执行器以使用新配置
3. 在测试脚本中添加相应的命令行选项

### 集成 CI/CD

可以将测试系统集成到 CI/CD 管道中：

```yaml
# GitHub Actions 示例
name: FitTracker Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-dart@v1
      - uses: actions/setup-go@v2
      - run: go mod download
      - run: go run cmd/server/main.go &
      - run: dart test_automation_main.dart
```

## 贡献指南

1. Fork 项目
2. 创建功能分支
3. 添加测试用例
4. 运行测试确保通过
5. 提交 Pull Request

## 许可证

本项目采用 MIT 许可证。

## 联系方式

如有问题或建议，请通过以下方式联系：
- 创建 Issue
- 发送邮件
- 提交 Pull Request
