# FitTracker MVP 技术架构设计

## 🏗️ 整体架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                        FitTracker MVP 架构                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐    ┌──────────────┐ │
│  │   Flutter App   │    │   Flutter App   │    │   Web Admin  │ │
│  │   (Android)     │    │   (iOS)         │    │   (Optional) │ │
│  └─────────┬───────┘    └─────────┬───────┘    └──────┬───────┘ │
│            │                      │                   │         │
│            └──────────────────────┼───────────────────┘         │
│                                   │                             │
│  ┌─────────────────────────────────▼─────────────────────────────┐ │
│  │                    Nginx 反向代理                              │ │
│  │              (负载均衡 + SSL + 静态资源)                        │ │
│  └─────────────────────────┬───────────────────────────────────┘ │
│                            │                                   │
│  ┌─────────────────────────▼───────────────────────────────────┐ │
│  │                Go 后端服务集群                               │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │ │
│  │  │   API 服务   │  │  AI 服务    │  │   文件上传服务       │ │ │
│  │  │  (Gin)      │  │ (混元大模型) │  │   (图片/视频)       │ │ │
│  │  └─────────────┘  └─────────────┘  └─────────────────────┘ │ │
│  └─────────────────────────┬───────────────────────────────────┘ │
│                            │                                   │
│  ┌─────────────────────────▼───────────────────────────────────┐ │
│  │                    数据存储层                                │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │ │
│  │  │ PostgreSQL  │  │    Redis     │  │   对象存储 (OSS)     │ │ │
│  │  │  (主数据库)  │  │   (缓存)     │  │   (图片/视频)       │ │ │
│  │  └─────────────┘  └─────────────┘  └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                    监控与分析                               │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │ │
│  │  │ Prometheus  │  │   Grafana    │  │   PostHog/Amplitude │ │ │
│  │  │  (指标监控)  │  │  (可视化)    │  │   (用户行为分析)    │ │ │
│  │  └─────────────┘  └─────────────┘  └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## 🛠️ 技术选型

### 前端技术栈
- **框架**: Flutter 3.16+ (跨平台)
- **状态管理**: Riverpod 2.4+
- **路由**: GoRouter 12.1+
- **网络请求**: Dio 5.4+ + Retrofit
- **本地存储**: Hive + SharedPreferences
- **图片处理**: Cached Network Image
- **UI组件**: Material Design 3

### 后端技术栈
- **语言**: Go 1.24+
- **框架**: Gin 1.9+
- **数据库**: PostgreSQL 15+ (主数据库)
- **缓存**: Redis 7+ (会话 + 缓存)
- **ORM**: GORM 1.30+
- **认证**: JWT + OAuth2 (微信/Apple)
- **文件存储**: 阿里云OSS / 腾讯云COS

### AI 服务
- **大模型**: 混元大模型 (腾讯)
- **备用方案**: DeepSeek API
- **功能**: 训练计划生成、内容审核

### 部署方案
- **容器化**: Docker + Docker Compose
- **云服务**: 推荐腾讯云 (国内访问优化)
- **CDN**: 腾讯云CDN
- **域名**: 备案域名 + SSL证书

## 📊 数据库设计

### 核心表结构
```sql
-- 用户表 (已有)
users (id, username, email, password_hash, avatar, bio, fitness_tags, location, ...)

-- 社区动态表 (已有)
posts (id, user_id, content, images, type, tags, likes_count, comments_count, ...)

-- 训练计划表 (已有)
training_plans (id, name, description, type, difficulty, duration, is_ai, ...)

-- 训练记录表 (已有)
workouts (id, user_id, plan_id, name, type, duration, calories, ...)

-- 健身搭子关系表 (新增)
workout_buddies (
    id, user_id, buddy_id, status, created_at, 
    workout_preferences, location_match, schedule_match
)

-- AI 训练计划生成记录 (新增)
ai_plan_generations (
    id, user_id, prompt, generated_plan, 
    user_feedback, rating, created_at
)

-- 教练-学员关系表 (新增)
coach_student_relations (
    id, coach_id, student_id, status, 
    assigned_plans, progress_tracking, created_at
)
```

## 🔌 API 设计

### 认证模块
```
POST /api/v1/auth/register          # 用户注册
POST /api/v1/auth/login             # 用户登录
POST /api/v1/auth/wechat            # 微信登录
POST /api/v1/auth/apple             # Apple登录
POST /api/v1/auth/refresh           # 刷新Token
POST /api/v1/auth/logout            # 用户登出
```

### 用户模块
```
GET    /api/v1/users/profile        # 获取用户信息
PUT    /api/v1/users/profile        # 更新用户信息
POST   /api/v1/users/avatar         # 上传头像
GET    /api/v1/users/{id}           # 获取其他用户信息
POST   /api/v1/users/follow         # 关注用户
DELETE /api/v1/users/follow         # 取消关注
```

### 社区模块
```
GET    /api/v1/posts                # 获取动态列表
POST   /api/v1/posts                # 发布动态
GET    /api/v1/posts/{id}           # 获取动态详情
PUT    /api/v1/posts/{id}           # 编辑动态
DELETE /api/v1/posts/{id}           # 删除动态
POST   /api/v1/posts/{id}/like      # 点赞动态
POST   /api/v1/posts/{id}/comment   # 评论动态
```

### 训练模块
```
GET    /api/v1/workouts             # 获取训练记录
POST   /api/v1/workouts             # 记录训练
GET    /api/v1/plans                # 获取训练计划
POST   /api/v1/plans                # 创建训练计划
POST   /api/v1/ai/generate-plan     # AI生成训练计划
POST   /api/v1/ai/feedback          # AI计划反馈
```

### 健身搭子模块
```
GET    /api/v1/buddies              # 获取搭子推荐
POST   /api/v1/buddies/request      # 申请搭子
GET    /api/v1/buddies/requests     # 获取搭子申请
PUT    /api/v1/buddies/{id}/accept  # 接受搭子申请
DELETE /api/v1/buddies/{id}         # 删除搭子关系
```

### 教练模块
```
GET    /api/v1/coaches              # 获取教练列表
POST   /api/v1/coaches/apply        # 申请教练
POST   /api/v1/coaches/{id}/assign  # 分配训练计划
GET    /api/v1/coaches/students     # 获取学员列表
```

## 🚀 MVP 开发路线图

### Phase 1: 基础功能 (2-3周)
**优先级: P0 (必须完成)**

1. **用户认证系统**
   - 手机号注册/登录
   - 微信登录集成
   - Apple登录集成
   - JWT Token管理

2. **用户资料管理**
   - 个人信息编辑
   - 头像上传
   - 健身偏好设置

3. **基础社区功能**
   - 发布动态 (文字+图片)
   - 浏览动态列表
   - 点赞功能
   - 评论功能

### Phase 2: 核心功能 (3-4周)
**优先级: P0 (必须完成)**

4. **AI训练计划**
   - 混元大模型集成
   - 训练计划生成
   - 计划一键使用
   - 用户反馈收集

5. **训练记录**
   - 训练打卡
   - 训练数据记录
   - 进度追踪

6. **健身搭子系统**
   - 搭子推荐算法
   - 搭子申请/接受
   - 搭子匹配

### Phase 3: 增强功能 (2-3周)
**优先级: P1 (重要)**

7. **教练系统**
   - 教练认证
   - 学员管理
   - 计划分配

8. **内容审核**
   - 敏感词过滤
   - 图片内容审核
   - 举报机制

9. **推送通知**
   - 训练提醒
   - 社交互动通知
   - 系统消息

### Phase 4: 优化功能 (1-2周)
**优先级: P2 (优化)**

10. **性能优化**
    - 图片懒加载
    - 数据分页
    - 缓存策略

11. **数据分析**
    - 用户行为埋点
    - 关键指标统计
    - 管理后台

## 🧪 自动化测试方案

### 单元测试
```go
// 后端 Go 测试
- 使用 testify 框架
- 测试覆盖率 > 80%
- 核心业务逻辑 100% 覆盖
```

```dart
// 前端 Flutter 测试
- 使用 flutter_test
- Widget 测试覆盖主要组件
- Provider 状态测试
```

### 集成测试
```yaml
# API 集成测试
- 使用 Postman/Newman
- 自动化 API 测试套件
- 数据库集成测试
```

### E2E 测试
```dart
// Flutter 集成测试
- 使用 integration_test
- 关键用户流程测试
- 跨平台兼容性测试
```

### 性能测试
```bash
# 压力测试
- 使用 k6 进行 API 压力测试
- 数据库性能测试
- 缓存性能测试
```

## 📈 关键指标 (KPI)

### 用户指标
- **DAU**: 日活跃用户数
- **MAU**: 月活跃用户数
- **次日留存**: > 40%
- **7日留存**: > 20%

### 功能指标
- **发帖转化率**: > 15%
- **AI计划使用率**: > 30%
- **搭子匹配成功率**: > 25%
- **训练打卡率**: > 60%

### 技术指标
- **API响应时间**: < 200ms
- **应用启动时间**: < 3s
- **崩溃率**: < 0.1%
- **网络成功率**: > 99%

## 🔒 安全与合规

### 数据安全
- 用户密码加密存储 (bcrypt)
- 敏感数据脱敏
- API 接口限流
- SQL 注入防护

### 隐私合规
- 符合《个人信息保护法》
- 用户数据最小化原则
- 数据删除权实现
- 隐私政策透明

### 内容安全
- 敏感词过滤
- 图片内容审核
- 用户举报机制
- 内容分级管理

## 🚀 部署方案

### 开发环境
```bash
# 本地开发
docker-compose up -d
```

### 测试环境
```bash
# 腾讯云测试环境
- 2核4G 服务器
- PostgreSQL 数据库
- Redis 缓存
- 对象存储
```

### 生产环境
```bash
# 腾讯云生产环境
- 4核8G 服务器 (可扩展)
- PostgreSQL 主从复制
- Redis 集群
- CDN 加速
- 负载均衡
```

## 📱 移动端适配

### Android
- 最低版本: API 21 (Android 5.0)
- 目标版本: API 34 (Android 14)
- 权限管理: 相机、存储、位置

### iOS
- 最低版本: iOS 12.0
- 目标版本: iOS 17.0
- 权限管理: 相机、相册、位置

## 🔄 CI/CD 流程

```yaml
# GitHub Actions 工作流
1. 代码提交触发
2. 运行测试套件
3. 构建 Docker 镜像
4. 部署到测试环境
5. 运行集成测试
6. 部署到生产环境
7. 发送部署通知
```

## 📊 监控告警

### 应用监控
- Prometheus + Grafana
- 关键指标监控
- 异常告警

### 日志管理
- 结构化日志
- 日志聚合分析
- 错误追踪

### 用户分析
- PostHog 用户行为分析
- 转化漏斗分析
- A/B 测试支持

---

## 🎯 总结

这个技术方案基于你现有的项目基础，充分利用了已有的 Go 后端和 Flutter 前端架构。通过分阶段开发，确保 MVP 核心功能快速上线，同时为后续迭代预留扩展空间。

**关键优势:**
1. 基于现有代码，开发效率高
2. 技术栈成熟稳定，维护成本低
3. 云服务选择合理，国内访问优化
4. 安全合规考虑周全，降低法律风险
5. 监控体系完善，便于运营优化

**下一步行动:**
1. 确认技术选型和架构设计
2. 开始 Phase 1 开发
3. 搭建 CI/CD 流程
4. 准备测试环境部署
