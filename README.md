# FitTracker - 热血健身打卡社交应用

## 项目概述

FitTracker 是一个现代化的全栈健身应用，集成了训练记录、BMI计算、营养分析、社区互动和挑战系统等功能。项目采用 Go + PostgreSQL + Redis 作为后端，Flutter + Riverpod 作为前端。

## 技术栈

### 后端
- **语言**: Go 1.24
- **框架**: Gin
- **数据库**: PostgreSQL 15
- **缓存**: Redis 7
- **ORM**: GORM
- **认证**: JWT
- **容器化**: Docker

### 前端
- **语言**: Dart
- **框架**: Flutter 3.2+
- **状态管理**: Riverpod
- **路由**: GoRouter
- **网络请求**: Dio
- **本地存储**: SharedPreferences + Hive

## 项目结构

```
fittraker/
├── backend-go/                 # Go 后端服务
│   ├── cmd/server/            # 服务器入口
│   ├── internal/              # 内部包
│   │   ├── api/              # API 层
│   │   ├── domain/            # 领域层
│   │   ├── infrastructure/    # 基础设施层
│   │   └── config/            # 配置
│   ├── scripts/              # 数据库脚本
│   └── Dockerfile            # Docker 配置
├── frontend/                  # Flutter 前端
│   ├── lib/                  # 源代码
│   │   ├── core/            # 核心模块
│   │   ├── features/        # 功能模块
│   │   └── shared/          # 共享组件
│   └── pubspec.yaml         # 依赖配置
├── docker-compose.yml        # Docker Compose 配置
└── README.md                 # 项目文档
```

## 快速开始

### 环境要求

- Docker & Docker Compose
- Go 1.24+ (本地开发)
- Flutter 3.2+ (本地开发)
- PostgreSQL 15+ (可选，本地开发)
- Redis 7+ (可选，本地开发)

### 使用 Docker Compose 运行

1. **克隆项目**
```bash
git clone <repository-url>
cd fittraker
```

2. **启动服务**
```bash
docker-compose up -d
```

3. **访问应用**
- 后端 API: http://localhost:8080
- 数据库管理: http://localhost:5050 (pgAdmin)
- Redis 管理: http://localhost:8081 (Redis Commander)

### 本地开发

#### 后端开发

1. **安装依赖**
```bash
cd backend-go
go mod download
```

2. **配置环境变量**
```bash
cp env.example .env
# 编辑 .env 文件，配置数据库和 Redis 连接
```

3. **启动数据库和 Redis**
```bash
docker-compose up postgres redis -d
```

4. **运行服务器**
```bash
go run cmd/server/main.go
```

#### 前端开发

1. **安装依赖**
```bash
cd frontend
flutter pub get
```

2. **运行应用**
```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web
flutter run -d web
```

## API 文档

### 认证相关

#### 用户注册
```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "username": "testuser",
  "email": "test@example.com",
  "password": "password123",
  "first_name": "Test",
  "last_name": "User"
}
```

#### 用户登录
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "password123"
}
```

#### 获取用户资料
```http
GET /api/v1/users/profile
Authorization: Bearer <token>
```

### 训练相关

#### 获取训练记录
```http
GET /api/v1/workouts?page=1&limit=10&type=力量训练
Authorization: Bearer <token>
```

#### 创建训练记录
```http
POST /api/v1/workouts
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "胸肌训练",
  "type": "力量训练",
  "duration": 60,
  "calories": 300,
  "difficulty": "中级",
  "notes": "训练效果很好",
  "rating": 4.5
}
```

#### 获取训练计划
```http
GET /api/v1/workouts/plans?page=1&limit=10&difficulty=初级
Authorization: Bearer <token>
```

### BMI 计算

#### 计算 BMI
```http
POST /api/v1/bmi/calculate
Authorization: Bearer <token>
Content-Type: application/json

{
  "height": 175,
  "weight": 70,
  "age": 25,
  "gender": "male"
}
```

#### 创建 BMI 记录
```http
POST /api/v1/bmi/records
Authorization: Bearer <token>
Content-Type: application/json

{
  "height": 175,
  "weight": 70,
  "age": 25,
  "gender": "male",
  "notes": "体重正常"
}
```

### 社区互动

#### 获取动态列表
```http
GET /api/v1/community/posts?page=1&limit=10&type=训练
Authorization: Bearer <token>
```

#### 发布动态
```http
POST /api/v1/community/posts
Authorization: Bearer <token>
Content-Type: application/json

{
  "content": "今天完成了胸肌训练，感觉很好！",
  "images": ["image1.jpg", "image2.jpg"],
  "type": "训练",
  "is_public": true
}
```

#### 点赞动态
```http
POST /api/v1/community/posts/{id}/like
Authorization: Bearer <token>
```

#### 关注用户
```http
POST /api/v1/community/follow/{user_id}
Authorization: Bearer <token>
```

### 签到系统

#### 创建签到
```http
POST /api/v1/checkins
Authorization: Bearer <token>
Content-Type: application/json

{
  "type": "训练",
  "notes": "完成了今天的训练",
  "mood": "开心",
  "energy": 8,
  "motivation": 9
}
```

#### 获取签到日历
```http
GET /api/v1/checkins/calendar?year=2024&month=1
Authorization: Bearer <token>
```

#### 获取签到统计
```http
GET /api/v1/checkins/streak
Authorization: Bearer <token>
```

### 营养分析

#### 计算营养信息
```http
POST /api/v1/nutrition/calculate
Authorization: Bearer <token>
Content-Type: application/json

{
  "food_name": "鸡胸肉",
  "quantity": 100,
  "unit": "g"
}
```

#### 搜索食物
```http
GET /api/v1/nutrition/foods?q=鸡胸肉
Authorization: Bearer <token>
```

#### 创建营养记录
```http
POST /api/v1/nutrition/records
Authorization: Bearer <token>
Content-Type: application/json

{
  "date": "2024-01-15",
  "meal_type": "lunch",
  "food_name": "鸡胸肉",
  "quantity": 150,
  "unit": "g",
  "notes": "午餐"
}
```

## 数据库 Schema

### 主要表结构

- **users**: 用户表
- **workouts**: 训练记录表
- **training_plans**: 训练计划表
- **exercises**: 运动动作表
- **checkins**: 签到记录表
- **posts**: 社区动态表
- **challenges**: 挑战表
- **nutrition_records**: 营养记录表

详细的数据库结构请参考 `backend-go/scripts/init.sql` 文件。

## 功能特性

### 已实现功能

✅ **用户认证系统**
- 用户注册/登录
- JWT Token 认证
- 用户资料管理
- 头像上传

✅ **训练记录系统**
- 训练记录 CRUD
- 训练计划管理
- 运动动作库
- BMI 计算器

✅ **社区互动系统**
- 动态发布/浏览
- 点赞/评论功能
- 用户关注系统
- 挑战参与

✅ **签到系统**
- 每日签到
- 签到日历
- 连续签到统计
- 成就系统

✅ **营养分析系统**
- 食物营养计算
- 营养记录管理
- 每日摄入统计

### 待实现功能

🔄 **AI 功能**
- AI 训练计划生成
- AI 营养师咨询
- 智能训练建议

🔄 **高级功能**
- 数据导出
- 社交分享
- 推送通知
- 离线模式

## 开发指南

### 代码规范

- Go 代码遵循标准 Go 代码规范
- Flutter 代码遵循 Dart 官方规范
- 使用 `gofmt` 和 `dart format` 格式化代码
- 提交前运行测试和代码检查

### 测试

#### 后端测试
```bash
cd backend-go
go test ./...
```

#### 前端测试
```bash
cd frontend
flutter test
```

## 测试

### 测试框架
- **Go 后端**: 使用 `testing` 包和 `httptest` 进行单元测试和集成测试
- **Flutter 前端**: 使用 `flutter_test` 进行 Widget 测试和集成测试
- **Mock 框架**: 使用 `testify/mock` 和 `mockito` 进行模拟测试
- **覆盖率**: 使用 `go tool cover` 和 `flutter test --coverage` 生成覆盖率报告

### 测试类型

#### Go 后端测试
- **单元测试**: 测试各个函数和方法的正确性
- **集成测试**: 测试 API 端点的完整功能
- **性能测试**: 使用 `go test -bench` 进行基准测试
- **压力测试**: 使用 `go test -race -count=100` 进行并发测试

#### Flutter 前端测试
- **Widget 测试**: 测试 UI 组件的渲染和交互
- **集成测试**: 测试完整的用户工作流程
- **API 测试**: 测试与后端 API 的交互

### 运行测试

#### 本地测试
```bash
# 运行所有测试
./scripts/run_tests.sh

# 只运行 Go 后端测试
./scripts/run_tests.sh --go-only

# 只运行 Flutter 前端测试
./scripts/run_tests.sh --flutter-only

# 运行性能测试
./scripts/run_tests.sh --performance

# 生成测试报告
./scripts/run_tests.sh --report
```

#### Go 后端测试
```bash
cd backend-go

# 运行单元测试
go test ./... -v -race -coverprofile=coverage.out

# 运行集成测试
go test ./... -v -race -tags=integration -coverprofile=integration_coverage.out

# 生成覆盖率报告
go tool cover -html=coverage.out -o coverage.html
go tool cover -html=integration_coverage.out -o integration_coverage.html

# 运行基准测试
go test -bench=. -benchmem -run=^$ ./...

# 运行压力测试
go test -race -count=100 ./...
```

#### Flutter 前端测试
```bash
cd frontend

# 获取依赖
flutter pub get

# 运行代码生成
flutter pub run build_runner build --delete-conflicting-outputs

# 运行单元测试
flutter test --coverage

# 运行集成测试
flutter test integration_test/ --coverage

# 分析代码
flutter analyze
```

#### Docker 测试
```bash
# 运行容器化测试
docker-compose -f docker-compose.test.yml up --build

# 运行特定测试服务
docker-compose -f docker-compose.test.yml run backend-go-test
docker-compose -f docker-compose.test.yml run frontend-test
```

### 测试覆盖率

#### Go 后端覆盖率
- 目标覆盖率: 80% 以上
- 关键模块覆盖率: 90% 以上
- 覆盖率报告: `backend-go/coverage.html`

#### Flutter 前端覆盖率
- 目标覆盖率: 70% 以上
- 关键页面覆盖率: 80% 以上
- 覆盖率报告: `frontend/coverage/lcov.info`

### CI/CD 测试

#### GitHub Actions
- 每次推送和 PR 都会自动运行测试
- 包含 Go 后端测试、Flutter 前端测试、Docker 测试
- 自动生成覆盖率报告和测试结果

#### 测试环境
- **PostgreSQL**: 使用测试数据库 `fittracker_test`
- **Redis**: 使用测试实例
- **隔离环境**: 每个测试使用独立的数据

### 测试数据

#### 测试数据生成
```bash
# 生成测试数据
cd backend-go
go run test_data_generator.go
```

#### 测试数据内容
- 3 个测试用户
- 3 个训练计划
- 5 个运动动作
- 3 个训练记录
- 3 个签到记录
- 3 个健康记录
- 3 个社区动态
- 6 个点赞记录
- 5 个评论
- 3 个关注关系
- 2 个挑战
- 3 个挑战参与记录
- 3 个营养记录

### 测试最佳实践

#### Go 测试
- 使用 `testify/assert` 进行断言
- 使用 `testify/mock` 进行模拟
- 测试边界条件和异常情况
- 使用表驱动测试
- 保持测试的独立性和可重复性

#### Flutter 测试
- 使用 `mockito` 进行 API 模拟
- 测试用户交互和状态变化
- 使用 `pumpAndSettle` 等待异步操作
- 测试错误处理和边界情况

#### 测试命名
- 使用描述性的测试名称
- 遵循 `TestFunctionName_Scenario_ExpectedResult` 格式
- 使用中文描述测试场景

### 测试报告

#### 测试报告位置
- Go 覆盖率报告: `test-reports/go-coverage.html`
- Go 集成测试覆盖率: `test-reports/go-integration-coverage.html`
- Flutter 覆盖率报告: `test-reports/flutter-coverage.info`
- 测试摘要: `test-reports/summary.md`

#### 测试报告内容
- 测试执行时间
- 测试通过率
- 覆盖率统计
- 性能基准
- 错误日志

### 部署

#### 生产环境部署

1. **构建镜像**
```bash
docker-compose -f docker-compose.prod.yml build
```

2. **启动服务**
```bash
docker-compose -f docker-compose.prod.yml up -d
```

3. **配置反向代理**
使用 Nginx 配置 SSL 证书和域名。

## 常见问题

### Q: 如何重置数据库？
A: 删除 Docker 卷并重新启动：
```bash
docker-compose down -v
docker-compose up -d
```

### Q: 如何查看日志？
A: 使用 Docker Compose 查看日志：
```bash
docker-compose logs -f backend
docker-compose logs -f frontend
```

### Q: 如何调试 API？
A: 使用 Postman 或 curl 测试 API，或者访问 http://localhost:8080/api/v1/health 检查服务状态。

## 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 联系方式

如有问题或建议，请通过以下方式联系：

- 项目 Issues: [GitHub Issues](https://github.com/your-repo/fittraker/issues)
- 邮箱: your-email@example.com

---

**FitTracker** - 让健身更有趣，让坚持更简单！💪