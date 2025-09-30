# FitTracker - 部署指南

## 🚀 快速开始

### 环境要求
- Python 3.11+
- Flutter 3.16+
- Docker & Docker Compose
- PostgreSQL 15+
- Redis 7.0+

### 一键启动
```bash
# 克隆项目
git clone https://github.com/shinytsing/fit-tracker.git
cd fit-tracker

# 运行启动脚本
chmod +x scripts/setup.sh
./scripts/setup.sh
```

## 📱 功能特性

### 核心功能
- ✅ **健身中心**: 训练计划、动作指导、进度跟踪
- ✅ **BMI计算器**: 身体指标计算、健康评估
- ✅ **营养计算器**: 卡路里计算、营养分析、饮食建议
- ✅ **签到日历**: 习惯养成、打卡记录、连续天数
- ✅ **运动追踪**: 运动记录、消耗统计、目标设定
- ✅ **训练计划**: 个性化训练方案、强度调节
- ✅ **健康监测**: 心率监测、睡眠分析、压力评估
- ✅ **社区互动**: 健身分享、经验交流、挑战赛

### 技术特性
- 🔥 **热血设计**: 橙色+红色主色调，积极向上的UI设计
- 📱 **跨平台**: Flutter 支持 iOS/Android
- ⚡ **高性能**: FastAPI + PostgreSQL + Redis
- 🔒 **安全**: JWT认证 + 数据加密
- 📊 **监控**: Sentry + OpenTelemetry
- 🚀 **CI/CD**: GitHub Actions 自动化部署

## 🏗️ 项目结构

```
fittraker/
├── backend/                 # FastAPI 后端
│   ├── app/
│   │   ├── api/            # API 路由
│   │   ├── core/           # 核心配置
│   │   ├── models/         # 数据模型
│   │   ├── schemas/        # Pydantic 模式
│   │   ├── services/       # 业务逻辑
│   │   └── utils/          # 工具函数
│   ├── tests/              # 测试文件
│   ├── requirements.txt    # Python 依赖
│   └── Dockerfile          # Docker 配置
├── frontend/               # Flutter 前端
│   ├── lib/
│   │   ├── core/          # 核心功能
│   │   ├── features/      # 功能模块
│   │   ├── shared/        # 共享组件
│   │   └── main.dart      # 应用入口
│   ├── pubspec.yaml       # Flutter 依赖
│   └── Dockerfile         # Docker 配置
├── infra/                  # 基础设施
│   ├── docker-compose.yml # Docker Compose
│   └── nginx.conf         # Nginx 配置
├── docs/                   # 项目文档
├── scripts/                # 工具脚本
└── .github/workflows/      # CI/CD 配置
```

## 🛠️ 开发指南

### 后端开发
```bash
cd backend

# 安装依赖
pip install -r requirements.txt

# 启动开发服务器
python main.py

# 运行测试
pytest tests/ -v

# 代码格式化
black .
isort .

# 代码检查
flake8 .
mypy .
```

### 前端开发
```bash
cd frontend

# 安装依赖
flutter pub get

# 启动开发服务器
flutter run

# 运行测试
flutter test

# 代码分析
flutter analyze
```

## 🐳 Docker 部署

### 开发环境
```bash
# 启动所有服务
docker-compose -f infra/docker-compose.yml up -d

# 查看日志
docker-compose -f infra/docker-compose.yml logs -f

# 停止服务
docker-compose -f infra/docker-compose.yml down
```

### 生产环境
```bash
# 构建生产镜像
docker-compose -f infra/docker-compose.prod.yml build

# 启动生产服务
docker-compose -f infra/docker-compose.prod.yml up -d
```

## 🌐 部署平台

### Railway 部署
```bash
# 安装 Railway CLI
npm install -g @railway/cli

# 登录 Railway
railway login

# 部署项目
railway up
```

### Vercel 部署
```bash
# 安装 Vercel CLI
npm install -g vercel

# 部署前端
cd frontend
vercel --prod

# 部署后端
cd backend
vercel --prod
```

### Fly.io 部署
```bash
# 安装 Fly CLI
curl -L https://fly.io/install.sh | sh

# 部署应用
fly deploy
```

## 📊 监控与日志

### 应用监控
- **错误监控**: Sentry 实时错误追踪
- **性能监控**: APM 性能分析
- **业务监控**: 关键指标监控

### 日志管理
- **结构化日志**: JSON 格式日志
- **日志聚合**: ELK Stack
- **日志分析**: 实时分析 + 告警

## 🔧 环境配置

### 后端环境变量
```bash
# 数据库配置
DATABASE_URL=postgresql://user:pass@localhost:5432/fittracker
REDIS_URL=redis://localhost:6379

# 安全配置
SECRET_KEY=your-secret-key
ACCESS_TOKEN_EXPIRE_MINUTES=30

# 文件存储
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_S3_BUCKET=your-bucket

# 监控配置
SENTRY_DSN=your-sentry-dsn
```

### 前端环境变量
```bash
# API 配置
API_BASE_URL=https://api.fittracker.com

# 监控配置
SENTRY_DSN=your-sentry-dsn
```

## 🧪 测试

### 单元测试
```bash
# 后端测试
cd backend
pytest tests/ -v --cov=app

# 前端测试
cd frontend
flutter test
```

### 集成测试
```bash
# E2E 测试
cd frontend
flutter drive --target=test_driver/app.dart
```

## 📈 性能优化

### 数据库优化
- 索引优化
- 查询优化
- 连接池配置
- 读写分离

### 缓存策略
- Redis 缓存
- CDN 缓存
- 应用缓存
- 缓存更新策略

### 前端优化
- 图片优化
- 代码分割
- 资源压缩
- 离线缓存

## 🔒 安全配置

### 认证与授权
- JWT Token 机制
- 密码安全哈希
- API 限流
- CORS 配置

### 数据安全
- 数据加密
- SQL 注入防护
- XSS 防护
- CSRF 防护

## 📱 移动端部署

### iOS 部署
```bash
# 构建 iOS 应用
cd frontend
flutter build ios --release

# 上传到 App Store Connect
flutter build ipa
```

### Android 部署
```bash
# 构建 Android 应用
cd frontend
flutter build apk --release

# 构建 AAB 包
flutter build appbundle --release
```

## 🚀 持续集成

### GitHub Actions
- 自动测试
- 代码质量检查
- 安全扫描
- 自动部署

### 部署流程
1. 代码提交到 main 分支
2. 自动运行测试
3. 代码质量检查
4. 安全扫描
5. 构建镜像
6. 部署到生产环境

## 📞 支持与反馈

- 📧 邮箱: contact@fittracker.com
- 🐛 问题反馈: https://github.com/shinytsing/fit-tracker/issues
- 📖 文档: https://docs.fittracker.com
- 💬 社区: https://community.fittracker.com

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

---

**FitTracker** - 让健身更有趣，让坚持更简单！ 💪🔥
