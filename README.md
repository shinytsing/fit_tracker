# FitTracker - 热血健身打卡社交应用

## 项目概述

FitTracker是一个现代化的全栈健身社交应用，使用Flutter前端和Go后端构建。应用提供AI智能训练推荐、社区互动、消息系统等完整功能。

## 功能特性

### 🏋️ 训练模块
- **今日训练计划**: 显示当天的训练安排
- **历史训练记录**: 查看过往训练历史
- **AI智能推荐**: 基于用户数据生成个性化训练计划
- **训练打卡**: 记录训练完成状态

### 👥 社区模块
- **关注流**: 查看关注用户的动态
- **推荐流**: 基于算法推荐相关内容
- **帖子互动**: 支持点赞、评论、转发
- **话题标签**: 热门话题和标签系统

### ➕ 发帖模块
- **多种内容类型**: 文字、图片、视频、训练记录
- **训练打卡**: 分享训练成果
- **位置标记**: 支持地理位置分享

### 💬 消息模块
- **私信聊天**: 支持文字、图片、语音消息
- **系统通知**: 点赞、评论、关注提醒
- **实时通信**: WebSocket支持

### 👤 个人中心
- **个人信息管理**: 头像、昵称、简介等
- **训练数据统计**: 训练时长、消耗卡路里等
- **成长体系**: 等级、积分、勋章系统
- **AI助手**: 智能问答和个性化建议

## 技术栈

### 前端 (Flutter)
- **框架**: Flutter 3.16+
- **状态管理**: Riverpod
- **路由**: GoRouter
- **网络请求**: Dio + Retrofit
- **本地存储**: Hive
- **UI组件**: Material Design 3

### 后端 (Go)
- **框架**: Gin
- **数据库**: PostgreSQL + GORM
- **缓存**: Redis
- **认证**: JWT
- **AI集成**: OpenAI API
- **实时通信**: WebSocket

### 部署
- **容器化**: Docker + Docker Compose
- **反向代理**: Nginx
- **监控**: Prometheus + Grafana
- **CI/CD**: GitHub Actions

## 项目结构

```
fittracker/
├── frontend/                 # Flutter前端
│   ├── lib/
│   │   ├── core/            # 核心配置
│   │   ├── features/        # 功能模块
│   │   │   ├── training/    # 训练模块
│   │   │   ├── community/   # 社区模块
│   │   │   ├── message/     # 消息模块
│   │   │   └── profile/     # 个人中心
│   │   └── shared/          # 共享组件
│   ├── test/               # 测试文件
│   └── pubspec.yaml        # 依赖配置
├── backend-go/             # Go后端
│   ├── cmd/               # 应用入口
│   ├── internal/          # 内部包
│   │   ├── api/           # API处理器
│   │   ├── models/        # 数据模型
│   │   ├── services/      # 业务逻辑
│   │   └── middleware/    # 中间件
│   ├── test/              # 测试文件
│   └── go.mod             # Go模块
├── docker-compose.yml     # Docker编排
├── run_tests.sh          # 测试脚本
└── README.md             # 项目文档
```

## 快速开始

### 环境要求

- Flutter 3.16+
- Go 1.21+
- Docker & Docker Compose
- PostgreSQL 15+
- Redis 7+

### 安装步骤

1. **克隆项目**
```bash
git clone https://github.com/your-username/fittracker.git
cd fittracker
```

2. **设置环境变量**
```bash
# 复制环境变量模板
cp backend-go/.env.example backend-go/.env
cp frontend/.env.example frontend/.env

# 编辑配置文件
vim backend-go/.env
vim frontend/.env
```

3. **使用Docker启动**
```bash
# 启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps
```

4. **手动启动（开发模式）**

**启动后端:**
```bash
cd backend-go
go mod tidy
go run cmd/server/main.go
```

**启动前端:**
```bash
cd frontend
flutter pub get
flutter run
```

### 访问应用

- **前端**: http://localhost:3000
- **后端API**: http://localhost:8080
- **API文档**: http://localhost:8080/swagger
- **监控面板**: http://localhost:3001

## 测试

### 运行测试

```bash
# 运行所有测试
./run_tests.sh

# 只测试前端
./run_tests.sh frontend

# 只测试后端
./run_tests.sh backend

# 只测试API
./run_tests.sh api
```

### 测试覆盖

- ✅ 单元测试
- ✅ 集成测试
- ✅ API测试
- ✅ Widget测试
- ✅ 性能测试

## API文档

### 认证接口

```http
POST /api/v1/users/register
POST /api/v1/users/login
GET  /api/v1/users/profile
PUT  /api/v1/users/profile
```

### 训练接口

```http
GET  /api/v1/training/plans/today
GET  /api/v1/training/plans/history
POST /api/v1/training/plans
POST /api/v1/training/plans/ai-generate
POST /api/v1/training/exercises/:id/complete
```

### 社区接口

```http
GET  /api/v1/community/posts/following
GET  /api/v1/community/posts/recommend
POST /api/v1/community/posts
POST /api/v1/community/posts/:id/like
POST /api/v1/community/users/:id/follow
```

### 消息接口

```http
GET  /api/v1/messages/chats
POST /api/v1/messages/chats
POST /api/v1/messages/chats/:id/messages
GET  /api/v1/messages/notifications
```

## 部署

### 生产环境部署

1. **配置生产环境**
```bash
# 设置生产环境变量
export ENVIRONMENT=production
export DATABASE_URL=postgres://user:pass@host:port/db
export REDIS_URL=redis://host:port
```

2. **构建生产镜像**
```bash
docker-compose -f docker-compose.prod.yml build
```

3. **部署到服务器**
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### 虚拟机部署

```bash
# 部署到Android虚拟机
./run_tests.sh deploy

# 部署到iOS模拟器
flutter install
```

## 开发指南

### 代码规范

- **Flutter**: 遵循Dart官方代码规范
- **Go**: 使用`gofmt`和`golint`
- **提交信息**: 使用约定式提交格式

### 分支管理

- `main`: 主分支，用于生产环境
- `develop`: 开发分支，用于集成测试
- `feature/*`: 功能分支
- `hotfix/*`: 热修复分支

### 贡献指南

1. Fork项目
2. 创建功能分支
3. 提交更改
4. 创建Pull Request

## 监控和日志

### 应用监控

- **Prometheus**: 指标收集
- **Grafana**: 可视化面板
- **Loki**: 日志聚合

### 日志级别

- `DEBUG`: 调试信息
- `INFO`: 一般信息
- `WARN`: 警告信息
- `ERROR`: 错误信息

## 常见问题

### Q: 如何重置数据库？
A: 删除Docker卷并重新创建
```bash
docker-compose down -v
docker-compose up -d
```

### Q: 如何更新依赖？
A: 前端使用`flutter pub upgrade`，后端使用`go mod tidy`

### Q: 如何调试WebSocket连接？
A: 检查防火墙设置和网络配置

## 许可证

本项目采用MIT许可证 - 查看[LICENSE](LICENSE)文件了解详情

## 联系方式

- **项目维护者**: [Your Name](mailto:your.email@example.com)
- **问题反馈**: [GitHub Issues](https://github.com/your-username/fittracker/issues)
- **讨论交流**: [GitHub Discussions](https://github.com/your-username/fittracker/discussions)

## 更新日志

### v1.0.0 (2024-01-01)
- ✨ 初始版本发布
- ✨ 完整的训练管理功能
- ✨ 社区互动功能
- ✨ 消息系统
- ✨ AI智能推荐
- ✨ 个人中心

---

**FitTracker** - 让健身更有趣，让坚持更简单！💪