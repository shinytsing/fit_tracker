# FitTracker Backend (Go)

FitTracker 健身打卡社交应用的后端服务，使用 Go 语言和 Gin 框架构建。

## 🚀 快速开始

### 环境要求

- Go 1.21+
- PostgreSQL 15+
- Redis 7.0+
- Docker (可选)

### 本地开发

1. **克隆项目**
```bash
git clone <repository-url>
cd fittracker/backend-go
```

2. **安装依赖**
```bash
go mod download
```

3. **配置环境变量**
```bash
cp env.example .env
# 编辑 .env 文件，配置数据库和Redis连接信息
```

4. **启动数据库**
```bash
# 使用Docker启动PostgreSQL和Redis
docker run -d --name postgres -e POSTGRES_PASSWORD=password -p 5432:5432 postgres:15
docker run -d --name redis -p 6379:6379 redis:7-alpine
```

5. **运行应用**
```bash
go run cmd/server/main.go
```

### Docker 部署

1. **构建镜像**
```bash
docker build -t fittracker-backend .
```

2. **运行容器**
```bash
docker run -d --name fittracker-backend -p 8080:8080 fittracker-backend
```

## 📁 项目结构

```
backend-go/
├── cmd/
│   └── server/
│       └── main.go          # 应用入口
├── internal/
│   ├── api/                 # API层
│   │   ├── handlers/        # HTTP处理器
│   │   ├── middleware/      # 中间件
│   │   └── routes/         # 路由定义
│   ├── config/             # 配置
│   ├── domain/             # 领域层
│   │   ├── models/         # 领域模型
│   │   ├── repositories/   # 仓储接口和实现
│   │   └── services/       # 业务服务
│   └── infrastructure/     # 基础设施层
│       └── database/       # 数据库连接
├── pkg/                    # 公共包
│   └── logger/             # 日志
├── migrations/             # 数据库迁移
├── tests/                  # 测试文件
├── go.mod                  # Go模块文件
├── go.sum                  # 依赖校验文件
├── Dockerfile              # Docker配置
└── README.md               # 项目说明
```

## 🔧 技术栈

- **语言**: Go 1.21+
- **框架**: Gin
- **ORM**: GORM
- **数据库**: PostgreSQL 15+
- **缓存**: Redis 7.0+
- **认证**: JWT
- **日志**: 标准库 + 自定义logger
- **测试**: Testify + GoMock

## 📚 API 文档

### 认证相关
- `POST /api/v1/auth/register` - 用户注册
- `POST /api/v1/auth/login` - 用户登录
- `POST /api/v1/auth/logout` - 用户登出
- `POST /api/v1/auth/refresh` - 刷新令牌

### 用户管理
- `GET /api/v1/users/profile` - 获取用户资料
- `PUT /api/v1/users/profile` - 更新用户资料
- `POST /api/v1/users/avatar` - 上传头像
- `GET /api/v1/users/stats` - 获取用户统计

### 健身中心
- `GET /api/v1/workouts` - 获取训练记录
- `POST /api/v1/workouts` - 创建训练记录
- `GET /api/v1/workouts/:id` - 获取单个训练记录
- `PUT /api/v1/workouts/:id` - 更新训练记录
- `DELETE /api/v1/workouts/:id` - 删除训练记录

### BMI计算器
- `POST /api/v1/bmi/calculate` - 计算BMI
- `GET /api/v1/bmi/records` - 获取BMI记录
- `POST /api/v1/bmi/records` - 创建BMI记录

### 营养计算器
- `POST /api/v1/nutrition/calculate` - 计算营养
- `GET /api/v1/nutrition/foods` - 搜索食物
- `GET /api/v1/nutrition/daily-intake` - 获取每日摄入

### 签到日历
- `GET /api/v1/checkins` - 获取签到记录
- `POST /api/v1/checkins` - 创建签到记录
- `GET /api/v1/checkins/calendar` - 获取签到日历
- `GET /api/v1/checkins/streak` - 获取连续签到天数

### 社区互动
- `GET /api/v1/community/posts` - 获取动态
- `POST /api/v1/community/posts` - 创建动态
- `POST /api/v1/community/posts/:id/like` - 点赞动态
- `POST /api/v1/community/posts/:id/comments` - 创建评论

### AI服务
- `POST /api/v1/ai/coach/workout-plan` - 生成训练计划
- `POST /api/v1/ai/coach/chat` - 与AI教练对话
- `POST /api/v1/ai/nutritionist/meal-plan` - 生成饮食计划
- `POST /api/v1/ai/nutritionist/chat` - 与AI营养师对话

## 🧪 测试

### 运行测试
```bash
# 运行所有测试
go test ./...

# 运行特定包的测试
go test ./internal/domain/services

# 运行测试并显示覆盖率
go test -cover ./...
```

### 测试覆盖率
```bash
# 生成覆盖率报告
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

## 🔒 安全

- JWT 认证和授权
- 密码哈希 (bcrypt)
- CORS 跨域配置
- 请求限流
- SQL 注入防护 (GORM)
- XSS 防护

## 📊 监控

- 健康检查端点: `GET /api/v1/health`
- 结构化日志输出
- 错误追踪和报告
- 性能指标收集

## 🚀 部署

### 生产环境配置

1. **环境变量**
```bash
ENVIRONMENT=production
LOG_LEVEL=info
DATABASE_URL=postgres://user:password@host:port/dbname?sslmode=require
REDIS_URL=redis://host:port/db
JWT_SECRET=your-production-secret-key
```

2. **Docker Compose**
```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      - DATABASE_URL=postgres://user:password@postgres:5432/fittracker
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - postgres
      - redis
  
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: fittracker
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
  
  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

## 🤝 贡献

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 支持

如有问题或建议，请通过以下方式联系：

- 创建 Issue
- 发送邮件至 support@fittracker.com
- 加入我们的 Discord 社区

---

*最后更新：2025-09-30*
*版本：v1.0.0*
