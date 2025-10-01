# FitTracker 项目结构
# 模块化可运行的全栈健身应用

## 项目架构
```
fittracker/
├── frontend/                 # Flutter 前端
│   ├── lib/
│   │   ├── core/            # 核心服务
│   │   ├── features/        # 功能模块
│   │   │   ├── training/    # Tab1 - 训练模块
│   │   │   ├── community/   # Tab2 - 社区模块
│   │   │   ├── publish/     # Tab3 - 发布模块
│   │   │   ├── message/     # Tab4 - 消息模块
│   │   │   └── profile/     # Tab5 - 个人中心模块
│   │   ├── shared/          # 共享组件
│   │   └── main.dart        # 应用入口
│   ├── pubspec.yaml         # 依赖配置
│   └── android/ios/         # 平台配置
├── backend-go/              # Go 后端
│   ├── cmd/server/          # 服务入口
│   ├── internal/
│   │   ├── api/             # API 处理器
│   │   ├── services/        # 业务逻辑
│   │   ├── domain/          # 领域模型
│   │   └── database/        # 数据库
│   ├── scripts/             # SQL 脚本
│   └── go.mod               # Go 依赖
├── ai-service/              # AI 服务
│   ├── training_plans/       # 训练计划生成
│   └── templates/           # 动作模板
└── docker-compose.yml       # 容器编排
```

## 技术栈
- **前端**: Flutter 3.16+ + Riverpod 2.4+ + Material Design 3
- **后端**: Go 1.21+ + Gin 1.9+ + PostgreSQL 15+
- **AI**: OpenAI API + 本地动作模板
- **实时通信**: WebSocket + Server-Sent Events
- **部署**: Docker + Docker Compose

## 模块功能
1. **训练模块**: 今日计划、训练历史、AI训练计划、打卡签到、成就系统
2. **社区模块**: 发帖、关注流、推荐流、话题、挑战、点赞评论
3. **发布模块**: 发动态、打卡、上传训练记录、发布历史
4. **消息模块**: 私信、群聊、系统通知、实时通信、通话
5. **个人中心**: 个人资料、数据统计、成就、训练计划、设置
