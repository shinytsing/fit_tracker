# FitTracker - 技术架构设计文档

## 1. 技术栈选型

### 1.1 前端技术栈
- **框架**: Flutter 3.16+ (跨平台移动端)
- **状态管理**: Riverpod 2.4+ (响应式状态管理)
- **网络请求**: Dio 5.3+ (HTTP客户端)
- **本地存储**: Hive 2.2+ (轻量级数据库)
- **图片处理**: Image Picker + Image Cropper
- **UI组件**: Material Design 3
- **路由管理**: Go Router 12.0+
- **依赖注入**: GetIt 7.6+

### 1.2 后端技术栈
- **框架**: FastAPI 0.104+ (高性能Python Web框架)
- **数据库**: PostgreSQL 15+ (关系型数据库)
- **ORM**: SQLAlchemy 2.0+ (Python ORM)
- **认证**: JWT + PassLib (密码哈希)
- **文件存储**: AWS S3 / 阿里云OSS (图片存储)
- **缓存**: Redis 7.0+ (内存数据库)
- **任务队列**: Celery + Redis (异步任务)
- **API文档**: Swagger UI (自动生成)

### 1.3 基础设施
- **容器化**: Docker + Docker Compose
- **CI/CD**: GitHub Actions
- **部署平台**: Railway / Fly.io / Vercel
- **监控**: Sentry (错误监控) + OpenTelemetry (链路追踪)
- **日志**: ELK Stack (Elasticsearch + Logstash + Kibana)
- **CDN**: CloudFlare (静态资源加速)

## 2. 系统架构设计

### 2.1 整体架构
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   Flutter App   │    │   Flutter App   │
│    (iOS/Android)│    │    (iOS/Android)│    │    (iOS/Android)│
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Load Balancer │
                    │   (Nginx/CloudFlare) │
                    └─────────────────┘
                                 │
                    ┌─────────────────┐
                    │   FastAPI       │
                    │   (Backend API) │
                    └─────────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         │                       │                       │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   PostgreSQL    │    │     Redis       │    │   File Storage  │
│   (主数据库)     │    │   (缓存/会话)    │    │   (S3/OSS)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 2.2 微服务架构
```
┌─────────────────┐
│   API Gateway   │
│   (FastAPI)     │
└─────────────────┘
         │
         ├─── 用户服务 (User Service)
         ├─── 打卡服务 (Checkin Service)
         ├─── 社交服务 (Social Service)
         ├─── 统计服务 (Analytics Service)
         └─── 文件服务 (File Service)
```

## 3. 数据库设计

### 3.1 核心表结构
```sql
-- 用户表
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(500),
    bio TEXT,
    fitness_goal VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- 健身打卡表
CREATE TABLE checkins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    images JSONB, -- 存储图片URL数组
    tags JSONB, -- 存储标签数组
    workout_type VARCHAR(50),
    duration_minutes INTEGER,
    calories_burned INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 关注关系表
CREATE TABLE follows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    follower_id UUID REFERENCES users(id) ON DELETE CASCADE,
    following_id UUID REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(follower_id, following_id)
);

-- 点赞表
CREATE TABLE likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    checkin_id UUID REFERENCES checkins(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, checkin_id)
);

-- 评论表
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    checkin_id UUID REFERENCES checkins(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    parent_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 3.2 索引优化
```sql
-- 用户表索引
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);

-- 打卡表索引
CREATE INDEX idx_checkins_user_id ON checkins(user_id);
CREATE INDEX idx_checkins_created_at ON checkins(created_at);
CREATE INDEX idx_checkins_workout_type ON checkins(workout_type);

-- 关注表索引
CREATE INDEX idx_follows_follower_id ON follows(follower_id);
CREATE INDEX idx_follows_following_id ON follows(following_id);

-- 点赞表索引
CREATE INDEX idx_likes_user_id ON likes(user_id);
CREATE INDEX idx_likes_checkin_id ON likes(checkin_id);

-- 评论表索引
CREATE INDEX idx_comments_user_id ON comments(user_id);
CREATE INDEX idx_comments_checkin_id ON comments(checkin_id);
CREATE INDEX idx_comments_parent_id ON comments(parent_id);
```

## 4. API 设计

### 4.1 RESTful API 规范
```
Base URL: https://api.fittracker.com/v1

认证方式: Bearer Token (JWT)
Content-Type: application/json
```

### 4.2 核心API端点
```python
# 用户相关
POST   /auth/register          # 用户注册
POST   /auth/login             # 用户登录
POST   /auth/refresh            # 刷新Token
GET    /auth/me                 # 获取当前用户信息
PUT    /auth/me                 # 更新用户信息

# 打卡相关
GET    /checkins                # 获取打卡列表
POST   /checkins                # 创建打卡
GET    /checkins/{id}           # 获取打卡详情
PUT    /checkins/{id}           # 更新打卡
DELETE /checkins/{id}           # 删除打卡

# 社交相关
GET    /users/{id}/followers    # 获取粉丝列表
GET    /users/{id}/following    # 获取关注列表
POST   /users/{id}/follow       # 关注用户
DELETE /users/{id}/follow       # 取消关注

POST   /checkins/{id}/like      # 点赞打卡
DELETE /checkins/{id}/like      # 取消点赞
GET    /checkins/{id}/likes     # 获取点赞列表

GET    /checkins/{id}/comments  # 获取评论列表
POST   /checkins/{id}/comments  # 创建评论
PUT    /comments/{id}           # 更新评论
DELETE /comments/{id}           # 删除评论

# 统计相关
GET    /analytics/personal      # 个人统计
GET    /analytics/weekly        # 周报
GET    /analytics/monthly       # 月报
```

## 5. 安全设计

### 5.1 认证与授权
- **JWT Token**: 访问令牌 + 刷新令牌机制
- **密码安全**: bcrypt哈希 + 盐值
- **API限流**: Redis实现令牌桶算法
- **CORS配置**: 严格的前端域名限制

### 5.2 数据安全
- **数据加密**: 敏感数据AES-256加密
- **SQL注入防护**: SQLAlchemy ORM参数化查询
- **XSS防护**: 输入验证 + 输出转义
- **CSRF防护**: 双重提交Cookie模式

### 5.3 文件安全
- **文件类型验证**: 仅允许图片格式
- **文件大小限制**: 单张图片 < 10MB
- **病毒扫描**: 集成ClamAV扫描
- **CDN加速**: CloudFlare安全防护

## 6. 性能优化

### 6.1 数据库优化
- **连接池**: SQLAlchemy连接池配置
- **查询优化**: 索引优化 + 查询分析
- **读写分离**: 主从数据库架构
- **分库分表**: 按用户ID分片

### 6.2 缓存策略
- **Redis缓存**: 热点数据缓存
- **CDN缓存**: 静态资源缓存
- **应用缓存**: 内存缓存
- **缓存更新**: 主动更新 + 过期策略

### 6.3 前端优化
- **图片优化**: WebP格式 + 懒加载
- **代码分割**: 按路由分割
- **资源压缩**: Gzip压缩
- **离线缓存**: Service Worker

## 7. 监控与日志

### 7.1 应用监控
- **错误监控**: Sentry实时错误追踪
- **性能监控**: APM性能分析
- **业务监控**: 关键指标监控
- **健康检查**: 服务健康状态

### 7.2 日志管理
- **结构化日志**: JSON格式日志
- **日志级别**: DEBUG/INFO/WARN/ERROR
- **日志聚合**: ELK Stack
- **日志分析**: 实时分析 + 告警

### 7.3 链路追踪
- **分布式追踪**: OpenTelemetry
- **请求追踪**: 全链路请求追踪
- **性能分析**: 慢查询分析
- **依赖分析**: 服务依赖关系

## 8. 部署架构

### 8.1 容器化部署
```yaml
# docker-compose.yml
version: '3.8'
services:
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/fittracker
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis

  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    depends_on:
      - backend

  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=fittracker
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
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

### 8.2 CI/CD流程
```yaml
# .github/workflows/deploy.yml
name: Deploy to Production
on:
  push:
    branches: [main]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Tests
        run: |
          cd backend && python -m pytest
          cd frontend && flutter test

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Railway
        run: |
          # 部署到Railway
```

## 9. 开发规范

### 9.1 代码规范
- **Python**: Black + isort + flake8
- **Dart**: dart format + dart analyze
- **Git**: Conventional Commits规范
- **API**: OpenAPI 3.0规范

### 9.2 测试规范
- **单元测试**: pytest + Flutter test
- **集成测试**: FastAPI TestClient
- **E2E测试**: Flutter Integration Test
- **测试覆盖率**: > 80%

### 9.3 文档规范
- **API文档**: Swagger自动生成
- **代码文档**: 函数注释 + 类型注解
- **部署文档**: README + 部署指南
- **用户文档**: 用户手册 + FAQ

## 10. 扩展性设计

### 10.1 水平扩展
- **无状态服务**: 支持多实例部署
- **负载均衡**: Nginx/HAProxy
- **数据库分片**: 按用户ID分片
- **缓存集群**: Redis Cluster

### 10.2 功能扩展
- **插件化架构**: 模块化设计
- **API版本管理**: 向后兼容
- **微服务拆分**: 按业务域拆分
- **事件驱动**: 异步消息处理

这个技术架构设计为FitTracker提供了完整的技术方案，确保系统的可扩展性、可维护性和高性能。
