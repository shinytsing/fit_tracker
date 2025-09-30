# FitTracker - 热血健身打卡社交应用

## 🎯 项目概述

FitTracker 是一款专注于健身打卡和社交互动的移动应用，采用热血积极的设计风格，帮助用户记录健身历程，分享健身成果，建立健身社区。

## ✨ 核心功能

### 🏋️‍♂️ 健身中心
- **训练计划管理**: 个性化训练方案，AI智能推荐
- **动作指导**: 视频教程库，详细动作说明
- **进度跟踪**: 训练记录，强度调节，数据统计
- **实时指导**: 运动过程中的实时反馈和建议

### 📊 BMI计算器
- **身体指标计算**: BMI、体脂率、肌肉量等
- **健康评估**: 综合健康状态分析
- **目标设定**: 减脂、增肌、塑形目标制定
- **趋势分析**: 身体数据变化趋势图表

### 🥗 营养计算器
- **卡路里计算**: 精确的摄入/消耗平衡计算
- **营养分析**: 蛋白质、碳水、脂肪等营养素分析
- **饮食建议**: 个性化营养方案推荐
- **食物数据库**: 丰富的食物营养信息库

### 📅 签到日历
- **习惯养成**: 每日打卡，培养健身习惯
- **打卡记录**: 训练、饮食、睡眠等多维度记录
- **连续天数**: 连续打卡天数统计
- **成就徽章**: 激励用户的成就系统

### 🏃‍♂️ 运动追踪
- **运动记录**: 跑步、骑行、游泳等多种运动
- **消耗统计**: 卡路里、距离、时长等数据
- **目标设定**: 每日/每周运动目标
- **实时监测**: 心率、步数等实时数据

### 📋 训练计划
- **个性化方案**: 根据用户情况定制训练计划
- **强度调节**: 动态调整训练强度
- **进度管理**: 训练进度跟踪和管理
- **效果评估**: 训练效果分析和建议

### ❤️ 健康监测
- **心率监测**: 静息心率、运动心率监测
- **睡眠分析**: 睡眠质量、时长分析
- **压力评估**: 压力指数评估和建议
- **数据趋势**: 健康数据变化趋势分析

### 👥 社区互动
- **健身分享**: 动态发布，成果展示
- **经验交流**: 健身心得、技巧分享
- **挑战赛**: 月度挑战、团队竞赛
- **社交功能**: 关注、点赞、评论、私信

## 🛠️ 技术架构

### 前端技术栈
- **框架**: Flutter 3.16+ (跨平台移动端)
- **状态管理**: Riverpod 2.4+ (响应式状态管理)
- **网络请求**: Dio 5.3+ (HTTP客户端)
- **本地存储**: Hive 2.2+ (轻量级数据库)
- **路由管理**: Go Router 12.0+ (声明式路由)
- **UI组件**: Material Design 3 (现代UI设计)

### 后端技术栈
- **框架**: FastAPI 0.104+ (高性能Python Web框架)
- **数据库**: PostgreSQL 15+ (关系型数据库)
- **ORM**: SQLAlchemy 2.0+ (Python ORM)
- **认证**: JWT + PassLib (安全认证)
- **缓存**: Redis 7.0+ (内存数据库)
- **文件存储**: AWS S3 / 阿里云OSS (云存储)

### 基础设施
- **容器化**: Docker + Docker Compose
- **CI/CD**: GitHub Actions (自动化部署)
- **部署平台**: Railway / Fly.io / Vercel
- **监控**: Sentry + OpenTelemetry (错误监控)
- **日志**: ELK Stack (日志管理)
- **CDN**: CloudFlare (静态资源加速)

## 🎨 设计特色

### 热血积极的设计风格
- **主色调**: 热血橙色 (#FF6B35) + 活力红色 (#E53E3E)
- **设计理念**: 现代简约 + 运动活力
- **情感表达**: 积极向上、充满能量、激励人心
- **用户体验**: 简洁直观、操作流畅、视觉冲击力强

### 视觉元素
- **图标**: 线性图标 + 填充图标，2px线条粗细
- **按钮**: 渐变背景 + 圆角设计，12px圆角半径
- **卡片**: 白色背景 + 轻微阴影，16px圆角半径
- **动画**: 平滑转场 + 交互反馈，300ms动画时长

## 📱 项目结构

```
fittraker/
├── backend/                 # FastAPI 后端服务
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
├── frontend/               # Flutter 前端应用
│   ├── lib/
│   │   ├── core/          # 核心功能
│   │   ├── features/      # 功能模块
│   │   ├── shared/        # 共享组件
│   │   └── main.dart      # 应用入口
│   ├── pubspec.yaml       # Flutter 依赖
│   └── Dockerfile         # Docker 配置
├── infra/                  # 基础设施配置
│   ├── docker-compose.yml # Docker Compose
│   └── nginx.conf         # Nginx 配置
├── docs/                   # 项目文档
├── scripts/                # 工具脚本
└── .github/workflows/      # CI/CD 配置
```

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

### 开发环境
```bash
# 后端开发
cd backend
pip install -r requirements.txt
python main.py

# 前端开发
cd frontend
flutter pub get
flutter run
```

### Docker 部署
```bash
# 启动所有服务
docker-compose -f infra/docker-compose.yml up -d

# 查看服务状态
docker-compose -f infra/docker-compose.yml ps
```

## 📊 数据库设计

### 核心表结构
- **users**: 用户信息表
- **checkins**: 健身打卡表
- **workouts**: 运动记录表
- **nutrition_logs**: 营养记录表
- **health_records**: 健康记录表
- **training_plans**: 训练计划表
- **exercises**: 运动动作表
- **challenges**: 挑战赛表
- **follows**: 关注关系表
- **likes**: 点赞表
- **comments**: 评论表

### 索引优化
- 用户表：用户名、邮箱、创建时间索引
- 打卡表：用户ID、创建时间、运动类型索引
- 关注表：关注者ID、被关注者ID索引
- 点赞表：用户ID、打卡ID索引

## 🔒 安全设计

### 认证与授权
- **JWT Token**: 访问令牌 + 刷新令牌机制
- **密码安全**: bcrypt哈希 + 盐值
- **API限流**: Redis实现令牌桶算法
- **CORS配置**: 严格的前端域名限制

### 数据安全
- **数据加密**: 敏感数据AES-256加密
- **SQL注入防护**: SQLAlchemy ORM参数化查询
- **XSS防护**: 输入验证 + 输出转义
- **CSRF防护**: 双重提交Cookie模式

## 📈 性能优化

### 数据库优化
- **连接池**: SQLAlchemy连接池配置
- **查询优化**: 索引优化 + 查询分析
- **读写分离**: 主从数据库架构
- **分库分表**: 按用户ID分片

### 缓存策略
- **Redis缓存**: 热点数据缓存
- **CDN缓存**: 静态资源缓存
- **应用缓存**: 内存缓存
- **缓存更新**: 主动更新 + 过期策略

### 前端优化
- **图片优化**: WebP格式 + 懒加载
- **代码分割**: 按路由分割
- **资源压缩**: Gzip压缩
- **离线缓存**: Service Worker

## 🧪 测试策略

### 单元测试
- **后端**: pytest + 覆盖率报告
- **前端**: Flutter test + 单元测试
- **覆盖率**: > 80% 代码覆盖率

### 集成测试
- **API测试**: FastAPI TestClient
- **E2E测试**: Flutter Integration Test
- **性能测试**: 负载测试 + 压力测试

### 代码质量
- **Python**: Black + isort + flake8 + mypy
- **Dart**: dart format + dart analyze
- **Git**: Conventional Commits规范

## 🚀 部署方案

### 开发环境
- **本地开发**: Docker Compose
- **热重载**: 代码变更自动重启
- **调试工具**: 完整的调试环境

### 生产环境
- **容器化部署**: Docker + Kubernetes
- **负载均衡**: Nginx + HAProxy
- **数据库**: PostgreSQL 集群
- **缓存**: Redis 集群

### 云平台部署
- **Railway**: 简单快速的部署
- **Fly.io**: 全球分布式部署
- **Vercel**: 前端静态部署
- **AWS**: 企业级部署方案

## 📊 监控与日志

### 应用监控
- **错误监控**: Sentry实时错误追踪
- **性能监控**: APM性能分析
- **业务监控**: 关键指标监控
- **健康检查**: 服务健康状态

### 日志管理
- **结构化日志**: JSON格式日志
- **日志级别**: DEBUG/INFO/WARN/ERROR
- **日志聚合**: ELK Stack
- **日志分析**: 实时分析 + 告警

### 链路追踪
- **分布式追踪**: OpenTelemetry
- **请求追踪**: 全链路请求追踪
- **性能分析**: 慢查询分析
- **依赖分析**: 服务依赖关系

## 🎯 未来规划

### 短期目标 (1-3个月)
- ✅ 完成核心功能开发
- ✅ 实现用户认证系统
- ✅ 部署到生产环境
- ✅ 完成基础测试

### 中期目标 (3-6个月)
- 🔄 添加AI训练计划生成
- 🔄 实现实时运动指导
- 🔄 完善社区功能
- 🔄 优化用户体验

### 长期目标 (6-12个月)
- 🔮 支持智能穿戴设备
- 🔮 实现AR/VR训练
- 🔮 添加AI营养师功能
- 🔮 扩展国际市场

## 📞 联系方式

- 📧 邮箱: contact@fittracker.com
- 🐛 问题反馈: https://github.com/shinytsing/fit-tracker/issues
- 📖 文档: https://docs.fittracker.com
- 💬 社区: https://community.fittracker.com
- 🐦 微博: @FitTracker官方
- 📱 微信: FitTracker健身

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

感谢所有为 FitTracker 项目做出贡献的开发者和用户！

---

**FitTracker** - 让健身更有趣，让坚持更简单！ 💪🔥

*热血健身，成就更好的自己！*
