# FitTracker 项目 API 完整总结文档

## 📋 项目概述

FitTracker 是一个现代化的健身打卡社交应用，采用全栈架构设计，包含多个后端服务和前端应用。

### 🏗️ 技术架构
- **后端服务**: Python FastAPI + Go Gin
- **前端应用**: Flutter (移动端)
- **数据库**: PostgreSQL
- **缓存**: Redis
- **认证**: JWT Bearer Token

---

## 🔧 后端服务架构

### 1. Python FastAPI 后端 (`backend/`)

**基础信息:**
- **Base URL**: `http://localhost:8000/api/v1`
- **框架**: FastAPI
- **认证**: JWT Bearer Token
- **文档**: `http://localhost:8000/api/v1/docs`

**API 路由结构:**
```
/api/v1/
├── /auth          # 认证模块
├── /users         # 用户管理
├── /bmi           # BMI计算器
├── /workout       # 训练模块
├── /community     # 社区模块
├── /messages      # 消息模块
└── /publish       # 发布模块
```

#### 🔐 认证模块 (`/auth`)
- `POST /auth/register` - 用户注册
- `POST /auth/login` - 用户登录
- `POST /auth/logout` - 用户登出
- `POST /auth/refresh` - 刷新Token
- `GET /auth/me` - 获取当前用户信息

#### 👤 用户模块 (`/users`)
- `GET /users/` - 获取用户列表
- `GET /users/{user_id}` - 获取特定用户信息
- `PUT /users/{user_id}` - 更新用户信息
- `POST /users/{user_id}/avatar` - 上传头像

#### 📊 BMI计算器模块 (`/bmi`)
- `POST /bmi/calculate` - 计算BMI
- `POST /bmi/records` - 创建BMI记录
- `GET /bmi/records` - 获取BMI记录列表
- `GET /bmi/stats` - 获取BMI统计信息

#### 💪 训练模块 (`/workout`)
- `GET /workout/plans` - 获取训练计划列表
- `POST /workout/plans` - 创建训练计划
- `GET /workout/plans/{plan_id}` - 获取特定训练计划
- `PUT /workout/plans/{plan_id}` - 更新训练计划
- `DELETE /workout/plans/{plan_id}` - 删除训练计划
- `POST /workout/ai/generate-plan` - AI生成训练计划

#### 👥 社区模块 (`/community`)
- `GET /community/posts` - 获取社区动态列表
- `POST /community/posts` - 发布动态
- `GET /community/posts/{post_id}` - 获取动态详情
- `POST /community/posts/{post_id}/like` - 点赞动态
- `POST /community/posts/{post_id}/comment` - 评论动态
- `GET /community/trending` - 获取热门动态

#### 💬 消息模块 (`/messages`)
- `GET /messages/chats` - 获取聊天列表
- `GET /messages/chats/{chat_id}` - 获取聊天详情
- `POST /messages/chats/{chat_id}/send` - 发送消息
- `GET /messages/notifications` - 获取通知列表

#### 📝 发布模块 (`/publish`)
- `POST /publish/post` - 发布内容
- `POST /publish/upload-image` - 上传图片

### 2. Go Gin 后端 (`backend-go/`)

**基础信息:**
- **Base URL**: `http://localhost:8080/api/v1`
- **框架**: Gin
- **认证**: JWT Bearer Token
- **文档**: `http://localhost:8080/api/v1/docs`

**API 路由结构:**
```
/api/v1/
├── /users         # 用户管理
├── /training      # 训练相关
├── /community     # 社区相关
├── /gyms          # 健身房相关
├── /rest          # 休息相关
├── /messages      # 消息相关
└── /teams         # 团队相关
```

#### 👤 用户管理 (`/users`)
- `POST /users/register` - 用户注册
- `POST /users/login` - 用户登录
- `POST /users/third-party-login` - 第三方登录
- `GET /users/profile` - 获取用户资料
- `PUT /users/profile` - 更新用户资料
- `POST /users/upload-avatar` - 上传头像
- `GET /users/buddies` - 获取健身搭子
- `POST /users/buddies` - 添加健身搭子
- `DELETE /users/buddies/{id}` - 删除健身搭子

#### 🏋️ 训练管理 (`/training`)
- `GET /training/today` - 获取今日训练计划
- `POST /training/ai-generate` - AI生成训练计划
- `GET /training/plans` - 获取训练计划列表
- `POST /training/plans` - 创建训练计划
- `GET /training/plans/{id}` - 获取特定训练计划
- `PUT /training/plans/{id}` - 更新训练计划
- `DELETE /training/plans/{id}` - 删除训练计划

#### 👥 社区管理 (`/community`)
- `GET /community/posts` - 获取社区动态
- `POST /community/posts` - 创建社区动态
- `GET /community/posts/{id}` - 获取动态详情
- `PUT /community/posts/{id}` - 更新动态
- `DELETE /community/posts/{id}` - 删除动态
- `POST /community/posts/{id}/like` - 点赞动态
- `POST /community/posts/{id}/comment` - 评论动态

#### 🏢 健身房管理 (`/gyms`)
- `GET /gyms` - 获取健身房列表
- `POST /gyms` - 创建健身房
- `GET /gyms/{id}` - 获取健身房详情
- `PUT /gyms/{id}` - 更新健身房信息
- `DELETE /gyms/{id}` - 删除健身房
- `POST /gyms/{id}/join` - 加入健身房
- `POST /gyms/{id}/accept` - 接受加入申请
- `POST /gyms/{id}/reject` - 拒绝加入申请
- `GET /gyms/{id}/buddies` - 获取健身房搭子
- `POST /gyms/{id}/discounts` - 创建健身房优惠
- `POST /gyms/{id}/reviews` - 创建健身房评价
- `GET /gyms/nearby` - 获取附近健身房

#### 😴 休息管理 (`/rest`)
- `POST /rest/start` - 开始休息
- `POST /rest/end` - 结束休息
- `GET /rest/sessions` - 获取休息记录
- `GET /rest/feed` - 获取休息动态
- `POST /rest/posts` - 发布休息动态
- `POST /rest/posts/{id}/like` - 点赞休息动态
- `POST /rest/posts/{id}/comment` - 评论休息动态

#### 💬 消息管理 (`/messages`)
- `GET /messages/chats` - 获取聊天列表
- `POST /messages/chats` - 创建聊天
- `GET /messages/chats/{id}` - 获取聊天详情
- `GET /messages/chats/{id}/messages` - 获取聊天消息
- `POST /messages/chats/{id}/messages` - 发送消息
- `PUT /messages/messages/{id}/read` - 标记消息已读
- `GET /messages/notifications` - 获取通知列表
- `PUT /messages/notifications/{id}/read` - 标记通知已读

#### 👥 团队管理 (`/teams`)
- `GET /teams` - 获取团队列表
- `POST /teams` - 创建团队
- `GET /teams/{id}` - 获取团队详情
- `POST /teams/{id}/join` - 加入团队

---

## 📱 前端应用架构

### Flutter 移动应用 (`flutter_app/`)

**基础信息:**
- **Base URL**: `http://10.0.2.2:8000/api/v1` (Android模拟器)
- **HTTP客户端**: Dio
- **状态管理**: Riverpod + Provider
- **本地存储**: SharedPreferences

#### 🔧 API服务架构

**核心服务类:**
- `ApiService` - 基础HTTP客户端
- `AuthApiService` - 认证相关API
- `WorkoutApiService` - 训练相关API
- `CommunityApiService` - 社区相关API
- `MessageApiService` - 消息相关API
- `CheckinApiService` - 签到相关API

#### 🔐 认证API集成
```dart
// 用户注册
POST /auth/register
{
  "username": "string",
  "email": "string", 
  "password": "string",
  "first_name": "string",
  "last_name": "string"
}

// 用户登录
POST /auth/login
{
  "email": "string",
  "password": "string"
}

// 获取用户资料
GET /users/profile
Authorization: Bearer <token>
```

#### 💪 训练API集成
```dart
// 获取训练记录
GET /workouts?page=1&limit=10

// 创建训练记录
POST /workouts
{
  "name": "string",
  "type": "string",
  "duration": 45,
  "calories": 350,
  "exercises": [...]
}

// 获取训练计划
GET /workouts/plans?page=1&limit=10

// AI生成训练计划
POST /workouts/ai/generate-plan
{
  "goal": "string",
  "level": "string",
  "duration": 4,
  "equipment": [...]
}
```

#### 👥 社区API集成
```dart
// 获取社区动态
GET /community/posts?page=1&limit=20

// 发布动态
POST /community/posts
{
  "content": "string",
  "images": [...],
  "type": "string",
  "tags": [...]
}

// 点赞动态
POST /community/posts/{id}/like

// 评论动态
POST /community/posts/{id}/comments
{
  "content": "string"
}
```

#### 📊 BMI计算API集成
```dart
// 计算BMI
POST /bmi/calculate
{
  "height": 175.0,
  "weight": 70.0,
  "age": 25,
  "gender": "male"
}

// 获取BMI记录
GET /bmi/records?page=1&limit=10
```

#### 💬 消息API集成
```dart
// 获取消息列表
GET /messages?page=1&limit=20

// 发送消息
POST /messages
{
  "receiver_id": 123,
  "content": "string"
}

// 获取通知列表
GET /notifications?page=1&limit=20
```

#### 📅 签到API集成
```dart
// 创建签到记录
POST /checkins
{
  "date": "2024-01-01",
  "notes": "string"
}

// 获取签到记录
GET /checkins?page=1&limit=30

// 获取连续签到天数
GET /checkins/streak
```

---

## 🔄 API调用流程

### 1. 认证流程
```
1. 用户注册/登录 → POST /auth/register 或 POST /auth/login
2. 获取Token → 响应中包含JWT Token
3. 存储Token → SharedPreferences本地存储
4. 自动添加Token → 请求头自动添加Authorization: Bearer <token>
5. Token过期处理 → 自动清除本地Token，引导重新登录
```

### 2. 数据获取流程
```
1. UI组件加载 → 触发Provider状态管理
2. API服务调用 → 调用对应的API服务方法
3. HTTP请求 → Dio发送GET/POST/PUT/DELETE请求
4. 数据处理 → 解析JSON响应，转换为模型对象
5. 状态更新 → 更新Provider状态，触发UI重建
6. 错误处理 → 统一错误处理和用户提示
```

### 3. 数据提交流程
```
1. 用户操作 → 点击按钮或表单提交
2. 数据验证 → 前端表单验证
3. API调用 → 发送POST/PUT请求
4. 服务器处理 → 后端业务逻辑处理
5. 响应处理 → 处理成功/失败响应
6. UI更新 → 更新界面状态和显示
```

---

## 📊 API统计总览

### 后端API数量统计

#### Python FastAPI后端
- **认证模块**: 5个接口
- **用户模块**: 4个接口
- **BMI模块**: 4个接口
- **训练模块**: 6个接口
- **社区模块**: 6个接口
- **消息模块**: 4个接口
- **发布模块**: 2个接口
- **总计**: 31个接口

#### Go Gin后端
- **用户管理**: 9个接口
- **训练管理**: 7个接口
- **社区管理**: 7个接口
- **健身房管理**: 12个接口
- **休息管理**: 7个接口
- **消息管理**: 8个接口
- **团队管理**: 4个接口
- **总计**: 54个接口

### 前端API集成统计

#### Flutter应用
- **认证服务**: 5个方法
- **训练服务**: 8个方法
- **社区服务**: 6个方法
- **消息服务**: 4个方法
- **签到服务**: 3个方法
- **BMI服务**: 3个方法
- **总计**: 29个API方法

---

## 🔧 技术特性

### 1. 认证与安全
- **JWT Token认证**: 无状态认证机制
- **自动Token管理**: 前端自动添加和刷新Token
- **权限控制**: 基于角色的访问控制
- **密码加密**: bcrypt哈希加密
- **CORS配置**: 跨域请求支持

### 2. 错误处理
- **统一错误格式**: 标准化的错误响应
- **HTTP状态码**: 符合RESTful规范
- **业务错误码**: 自定义业务错误码
- **前端错误处理**: 统一的错误提示机制

### 3. 数据管理
- **分页支持**: 所有列表接口支持分页
- **数据验证**: 前后端双重数据验证
- **缓存策略**: Redis缓存热点数据
- **数据模型**: 统一的数据模型定义

### 4. 性能优化
- **连接池**: 数据库连接池管理
- **异步处理**: 异步API调用
- **压缩传输**: 响应数据压缩
- **CDN支持**: 静态资源CDN加速

---

## 📱 移动端适配

### 1. 网络配置
- **Android模拟器**: `http://10.0.2.2:8000`
- **iOS模拟器**: `http://localhost:8000`
- **真机测试**: 使用实际IP地址
- **超时设置**: 30秒连接和接收超时

### 2. 状态管理
- **Riverpod**: 响应式状态管理
- **Provider**: 依赖注入和状态共享
- **本地存储**: SharedPreferences持久化
- **缓存策略**: 内存和磁盘双重缓存

### 3. UI交互
- **加载状态**: 所有API调用显示加载状态
- **错误提示**: 友好的错误提示信息
- **离线支持**: 基础离线功能支持
- **实时更新**: WebSocket实时通信

---

## 🚀 部署配置

### 1. 开发环境
```bash
# Python后端
cd backend
pip install -r requirements.txt
uvicorn main:app --reload --port 8000

# Go后端
cd backend-go
go mod download
go run cmd/server/main.go

# Flutter应用
cd flutter_app
flutter pub get
flutter run
```

### 2. 生产环境
```bash
# Docker部署
docker-compose up -d

# 环境变量配置
DATABASE_URL=postgres://user:password@host:port/dbname
REDIS_URL=redis://host:port/db
JWT_SECRET=your-secret-key
```

---

## 📈 监控与日志

### 1. 健康检查
- **Python后端**: `GET /health`
- **Go后端**: `GET /health`
- **数据库连接**: 自动健康检查
- **Redis连接**: 自动健康检查

### 2. 日志记录
- **结构化日志**: JSON格式日志输出
- **请求日志**: 记录所有API请求
- **错误日志**: 详细的错误信息记录
- **性能日志**: API响应时间统计

### 3. 指标监控
- **API调用次数**: 统计各接口调用频率
- **响应时间**: 监控API响应性能
- **错误率**: 统计API错误率
- **用户活跃度**: 用户使用情况统计

---

## 🔮 未来规划

### 1. API扩展
- **WebSocket支持**: 实时消息推送
- **GraphQL接口**: 灵活的数据查询
- **微服务架构**: 服务拆分和独立部署
- **API版本管理**: 多版本API支持

### 2. 功能增强
- **AI智能推荐**: 个性化内容推荐
- **视频处理**: 训练视频上传和处理
- **地理位置**: 基于位置的社交功能
- **数据分析**: 用户行为数据分析

### 3. 性能优化
- **CDN加速**: 静态资源全球加速
- **数据库优化**: 查询性能优化
- **缓存策略**: 多级缓存机制
- **负载均衡**: 高可用架构设计

---

## 📞 技术支持

### 开发团队
- **后端开发**: Python FastAPI + Go Gin
- **移动端开发**: Flutter
- **数据库设计**: PostgreSQL
- **DevOps**: Docker + CI/CD

### 联系方式
- **项目仓库**: GitHub
- **技术文档**: 项目内docs目录
- **API文档**: Swagger UI自动生成
- **问题反馈**: GitHub Issues

---

*文档最后更新: 2024年12月*
*版本: v1.0.0*
*维护者: FitTracker开发团队*
