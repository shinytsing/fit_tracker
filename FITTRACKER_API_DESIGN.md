# FitTracker MVP API 设计文档

## 📋 API 接口规范

### 基础信息
- **Base URL**: `https://api.fittracker.com/api/v1`
- **认证方式**: JWT Bearer Token
- **数据格式**: JSON
- **字符编码**: UTF-8
- **时区**: Asia/Shanghai

### 通用响应格式
```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": "2024-01-01T00:00:00Z"
}
```

### 错误响应格式
```json
{
  "code": 400,
  "message": "参数错误",
  "error": "详细错误信息",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

## 🔐 认证模块 API

### 1. 用户注册
```http
POST /auth/register
Content-Type: application/json

{
  "phone": "13800138000",
  "password": "password123",
  "verification_code": "123456",
  "nickname": "健身达人"
}
```

**响应:**
```json
{
  "code": 200,
  "message": "注册成功",
  "data": {
    "user": {
      "id": 1,
      "phone": "13800138000",
      "nickname": "健身达人",
      "avatar": "",
      "created_at": "2024-01-01T00:00:00Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_at": "2024-01-08T00:00:00Z"
  }
}
```

### 2. 用户登录
```http
POST /auth/login
Content-Type: application/json

{
  "phone": "13800138000",
  "password": "password123"
}
```

### 3. 微信登录
```http
POST /auth/wechat
Content-Type: application/json

{
  "code": "wx_code_from_miniprogram",
  "encrypted_data": "encrypted_user_data",
  "iv": "initialization_vector"
}
```

### 4. Apple 登录
```http
POST /auth/apple
Content-Type: application/json

{
  "identity_token": "apple_identity_token",
  "authorization_code": "apple_authorization_code",
  "user_identifier": "apple_user_id"
}
```

### 5. 刷新 Token
```http
POST /auth/refresh
Authorization: Bearer <token>
```

### 6. 用户登出
```http
POST /auth/logout
Authorization: Bearer <token>
```

## 👤 用户模块 API

### 1. 获取用户信息
```http
GET /users/profile
Authorization: Bearer <token>
```

**响应:**
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "phone": "13800138000",
    "nickname": "健身达人",
    "avatar": "https://cdn.fittracker.com/avatars/1.jpg",
    "bio": "热爱健身的普通人",
    "fitness_tags": ["力量训练", "有氧运动"],
    "fitness_goal": "增肌塑形",
    "location": "北京市朝阳区",
    "is_verified": false,
    "followers_count": 120,
    "following_count": 85,
    "total_workouts": 45,
    "total_checkins": 30,
    "current_streak": 7,
    "longest_streak": 21,
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```

### 2. 更新用户信息
```http
PUT /users/profile
Authorization: Bearer <token>
Content-Type: application/json

{
  "nickname": "新昵称",
  "bio": "新的个人简介",
  "fitness_tags": ["力量训练", "瑜伽"],
  "fitness_goal": "减脂塑形",
  "location": "上海市浦东新区"
}
```

### 3. 上传头像
```http
POST /users/avatar
Authorization: Bearer <token>
Content-Type: multipart/form-data

avatar: <file>
```

### 4. 获取其他用户信息
```http
GET /users/{user_id}
Authorization: Bearer <token>
```

### 5. 关注用户
```http
POST /users/follow
Authorization: Bearer <token>
Content-Type: application/json

{
  "user_id": 2
}
```

### 6. 取消关注
```http
DELETE /users/follow
Authorization: Bearer <token>
Content-Type: application/json

{
  "user_id": 2
}
```

## 📱 社区模块 API

### 1. 获取动态列表
```http
GET /posts?page=1&limit=20&type=all&topic_id=1
Authorization: Bearer <token>
```

**查询参数:**
- `page`: 页码 (默认: 1)
- `limit`: 每页数量 (默认: 20, 最大: 100)
- `type`: 动态类型 (all, workout, nutrition, general)
- `topic_id`: 话题ID (可选)
- `user_id`: 用户ID (可选，查看特定用户动态)

**响应:**
```json
{
  "code": 200,
  "data": {
    "posts": [
      {
        "id": 1,
        "user": {
          "id": 1,
          "nickname": "健身达人",
          "avatar": "https://cdn.fittracker.com/avatars/1.jpg",
          "is_verified": false
        },
        "content": "今天完成了45分钟的力量训练！",
        "images": [
          "https://cdn.fittracker.com/posts/1_1.jpg",
          "https://cdn.fittracker.com/posts/1_2.jpg"
        ],
        "video_url": "",
        "type": "workout",
        "tags": ["力量训练", "健身打卡"],
        "location": "健身房",
        "workout_data": {
          "duration": 45,
          "calories": 350,
          "exercises": ["深蹲", "卧推", "硬拉"]
        },
        "is_featured": false,
        "view_count": 156,
        "share_count": 3,
        "likes_count": 12,
        "comments_count": 5,
        "is_liked": true,
        "is_following": false,
        "created_at": "2024-01-01T10:30:00Z",
        "updated_at": "2024-01-01T10:30:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 150,
      "pages": 8
    }
  }
}
```

### 2. 发布动态
```http
POST /posts
Authorization: Bearer <token>
Content-Type: multipart/form-data

content: "今天完成了45分钟的力量训练！"
images: <file1>, <file2>
type: "workout"
tags: ["力量训练", "健身打卡"]
location: "健身房"
workout_data: {"duration": 45, "calories": 350}
```

### 3. 获取动态详情
```http
GET /posts/{post_id}
Authorization: Bearer <token>
```

### 4. 编辑动态
```http
PUT /posts/{post_id}
Authorization: Bearer <token>
Content-Type: application/json

{
  "content": "更新后的内容",
  "tags": ["新标签"]
}
```

### 5. 删除动态
```http
DELETE /posts/{post_id}
Authorization: Bearer <token>
```

### 6. 点赞动态
```http
POST /posts/{post_id}/like
Authorization: Bearer <token>
```

### 7. 取消点赞
```http
DELETE /posts/{post_id}/like
Authorization: Bearer <token>
```

### 8. 评论动态
```http
POST /posts/{post_id}/comments
Authorization: Bearer <token>
Content-Type: application/json

{
  "content": "评论内容",
  "parent_id": 0
}
```

**响应:**
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "user": {
      "id": 2,
      "nickname": "评论者",
      "avatar": "https://cdn.fittracker.com/avatars/2.jpg"
    },
    "content": "评论内容",
    "parent_id": 0,
    "likes_count": 0,
    "is_liked": false,
    "created_at": "2024-01-01T11:00:00Z"
  }
}
```

### 9. 获取评论列表
```http
GET /posts/{post_id}/comments?page=1&limit=20
Authorization: Bearer <token>
```

## 🏋️ 训练模块 API

### 1. 获取训练记录
```http
GET /workouts?page=1&limit=20&user_id=1&type=all
Authorization: Bearer <token>
```

**响应:**
```json
{
  "code": 200,
  "data": {
    "workouts": [
      {
        "id": 1,
        "user_id": 1,
        "plan_id": 1,
        "name": "胸肌训练",
        "type": "力量训练",
        "duration": 45,
        "calories": 350,
        "difficulty": "中等",
        "notes": "今天状态不错",
        "rating": 4.5,
        "exercises": [
          {
            "id": 1,
            "name": "卧推",
            "sets": 4,
            "reps": "8-10",
            "weight": "80kg",
            "rest_time": "2分钟"
          }
        ],
        "created_at": "2024-01-01T10:30:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 45,
      "pages": 3
    }
  }
}
```

### 2. 记录训练
```http
POST /workouts
Authorization: Bearer <token>
Content-Type: application/json

{
  "plan_id": 1,
  "name": "胸肌训练",
  "type": "力量训练",
  "duration": 45,
  "calories": 350,
  "difficulty": "中等",
  "notes": "今天状态不错",
  "rating": 4.5,
  "exercises": [
    {
      "exercise_id": 1,
      "sets": 4,
      "reps": "8-10",
      "weight": "80kg",
      "rest_time": "2分钟"
    }
  ]
}
```

### 3. 获取训练计划
```http
GET /plans?page=1&limit=20&type=all&difficulty=all
Authorization: Bearer <token>
```

**响应:**
```json
{
  "code": 200,
  "data": {
    "plans": [
      {
        "id": 1,
        "name": "新手增肌计划",
        "description": "适合健身新手的增肌训练计划",
        "type": "增肌",
        "difficulty": "初级",
        "duration": 4,
        "is_public": true,
        "is_ai": false,
        "creator": {
          "id": 1,
          "nickname": "健身教练",
          "avatar": "https://cdn.fittracker.com/avatars/1.jpg"
        },
        "workouts_count": 12,
        "likes_count": 156,
        "is_liked": false,
        "created_at": "2024-01-01T00:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 50,
      "pages": 3
    }
  }
}
```

### 4. 创建训练计划
```http
POST /plans
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "我的训练计划",
  "description": "个人定制训练计划",
  "type": "增肌",
  "difficulty": "中级",
  "duration": 6,
  "is_public": false,
  "workouts": [
    {
      "name": "胸肌训练",
      "type": "力量训练",
      "exercises": [
        {
          "exercise_id": 1,
          "sets": 4,
          "reps": "8-10",
          "weight": "80kg"
        }
      ]
    }
  ]
}
```

### 5. AI 生成训练计划
```http
POST /ai/generate-plan
Authorization: Bearer <token>
Content-Type: application/json

{
  "goal": "增肌",
  "level": "初级",
  "duration": 4,
  "frequency": "每周3次",
  "equipment": ["哑铃", "杠铃"],
  "focus": ["胸肌", "背肌"],
  "constraints": "每次训练时间不超过1小时"
}
```

**响应:**
```json
{
  "code": 200,
  "data": {
    "plan": {
      "name": "AI生成增肌计划",
      "description": "基于您的需求AI生成的个性化训练计划",
      "type": "增肌",
      "difficulty": "初级",
      "duration": 4,
      "is_ai": true,
      "workouts": [
        {
          "name": "胸肌训练日",
          "type": "力量训练",
          "exercises": [
            {
              "name": "卧推",
              "description": "主要锻炼胸大肌",
              "sets": 4,
              "reps": "8-10",
              "weight": "建议从空杠开始",
              "instructions": "平躺在卧推凳上，双手握杠铃..."
            }
          ]
        }
      ]
    },
    "generation_id": "ai_gen_123456"
  }
}
```

### 6. AI 计划反馈
```http
POST /ai/feedback
Authorization: Bearer <token>
Content-Type: application/json

{
  "generation_id": "ai_gen_123456",
  "rating": 4,
  "feedback": "计划很好，但希望能增加一些有氧运动",
  "used": true
}
```

## 🤝 健身搭子模块 API

### 1. 获取搭子推荐
```http
GET /buddies/recommendations?page=1&limit=10
Authorization: Bearer <token>
```

**响应:**
```json
{
  "code": 200,
  "data": {
    "recommendations": [
      {
        "user": {
          "id": 2,
          "nickname": "健身伙伴",
          "avatar": "https://cdn.fittracker.com/avatars/2.jpg",
          "bio": "寻找健身搭子",
          "location": "北京市朝阳区",
          "fitness_tags": ["力量训练", "有氧运动"],
          "fitness_goal": "增肌塑形"
        },
        "match_score": 85,
        "match_reasons": [
          "相同的健身目标",
          "相近的训练时间",
          "相同的地理位置"
        ],
        "workout_preferences": {
          "time": "晚上7-9点",
          "location": "健身房",
          "type": "力量训练"
        }
      }
    ]
  }
}
```

### 2. 申请搭子
```http
POST /buddies/request
Authorization: Bearer <token>
Content-Type: application/json

{
  "buddy_id": 2,
  "message": "你好，我想和你一起健身！",
  "workout_preferences": {
    "time": "晚上7-9点",
    "location": "健身房",
    "type": "力量训练"
  }
}
```

### 3. 获取搭子申请
```http
GET /buddies/requests?type=received&page=1&limit=20
Authorization: Bearer <token>
```

**查询参数:**
- `type`: received(收到的申请) / sent(发送的申请)

### 4. 接受搭子申请
```http
PUT /buddies/{request_id}/accept
Authorization: Bearer <token>
Content-Type: application/json

{
  "message": "很高兴和你一起健身！"
}
```

### 5. 拒绝搭子申请
```http
PUT /buddies/{request_id}/reject
Authorization: Bearer <token>
Content-Type: application/json

{
  "reason": "时间不合适"
}
```

### 6. 获取搭子列表
```http
GET /buddies?page=1&limit=20
Authorization: Bearer <token>
```

### 7. 删除搭子关系
```http
DELETE /buddies/{buddy_id}
Authorization: Bearer <token>
```

## 👨‍🏫 教练模块 API

### 1. 获取教练列表
```http
GET /coaches?page=1&limit=20&specialty=all&location=all
Authorization: Bearer <token>
```

**响应:**
```json
{
  "code": 200,
  "data": {
    "coaches": [
      {
        "id": 3,
        "user": {
          "id": 3,
          "nickname": "专业教练",
          "avatar": "https://cdn.fittracker.com/avatars/3.jpg",
          "bio": "5年健身教练经验",
          "location": "北京市朝阳区",
          "is_verified": true
        },
        "specialty": ["力量训练", "减脂塑形"],
        "experience": 5,
        "certifications": ["ACE认证", "NSCA认证"],
        "rating": 4.8,
        "students_count": 120,
        "hourly_rate": 300,
        "is_available": true,
        "introduction": "专业的力量训练和减脂塑形教练..."
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 25,
      "pages": 2
    }
  }
}
```

### 2. 申请成为教练
```http
POST /coaches/apply
Authorization: Bearer <token>
Content-Type: multipart/form-data

specialty: ["力量训练", "减脂塑形"]
experience: 3
certifications: ["ACE认证"]
hourly_rate: 200
introduction: "我有3年的健身教练经验..."
certificate_files: <file1>, <file2>
```

### 3. 分配训练计划
```http
POST /coaches/{coach_id}/assign-plan
Authorization: Bearer <token>
Content-Type: application/json

{
  "student_id": 1,
  "plan_id": 1,
  "message": "为你制定了新的训练计划"
}
```

### 4. 获取学员列表
```http
GET /coaches/students?page=1&limit=20
Authorization: Bearer <token>
```

### 5. 获取学员进度
```http
GET /coaches/students/{student_id}/progress
Authorization: Bearer <token>
```

## 📊 数据模型设计

### 用户表 (users)
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- 基础信息
    phone VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    password_hash VARCHAR(255),
    nickname VARCHAR(50) NOT NULL,
    avatar VARCHAR(500),
    bio TEXT,
    
    -- 健身信息
    fitness_tags JSONB DEFAULT '[]',
    fitness_goal VARCHAR(100),
    location VARCHAR(200),
    
    -- 认证状态
    is_verified BOOLEAN DEFAULT FALSE,
    verification_level INTEGER DEFAULT 0,
    
    -- 社交统计
    followers_count INTEGER DEFAULT 0,
    following_count INTEGER DEFAULT 0,
    
    -- 健身统计
    total_workouts INTEGER DEFAULT 0,
    total_checkins INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    
    -- 第三方登录
    wechat_openid VARCHAR(100),
    apple_user_id VARCHAR(100),
    
    -- 索引
    INDEX idx_users_phone (phone),
    INDEX idx_users_email (email),
    INDEX idx_users_location (location),
    INDEX idx_users_fitness_tags USING GIN (fitness_tags)
);
```

### 社区动态表 (posts)
```sql
CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    user_id INTEGER NOT NULL REFERENCES users(id),
    content TEXT NOT NULL,
    images JSONB DEFAULT '[]',
    video_url VARCHAR(500),
    type VARCHAR(50) DEFAULT 'general',
    is_public BOOLEAN DEFAULT TRUE,
    
    -- 社区扩展
    tags JSONB DEFAULT '[]',
    location VARCHAR(200),
    workout_data JSONB,
    is_featured BOOLEAN DEFAULT FALSE,
    
    -- 统计信息
    view_count INTEGER DEFAULT 0,
    share_count INTEGER DEFAULT 0,
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    
    -- 索引
    INDEX idx_posts_user_id (user_id),
    INDEX idx_posts_type (type),
    INDEX idx_posts_created_at (created_at),
    INDEX idx_posts_tags USING GIN (tags),
    INDEX idx_posts_workout_data USING GIN (workout_data)
);
```

### 健身搭子关系表 (workout_buddies)
```sql
CREATE TABLE workout_buddies (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    user_id INTEGER NOT NULL REFERENCES users(id),
    buddy_id INTEGER NOT NULL REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'pending', -- pending, accepted, rejected, blocked
    
    -- 匹配信息
    workout_preferences JSONB,
    location_match BOOLEAN DEFAULT FALSE,
    schedule_match BOOLEAN DEFAULT FALSE,
    goal_match BOOLEAN DEFAULT FALSE,
    
    -- 申请信息
    request_message TEXT,
    response_message TEXT,
    requested_at TIMESTAMP WITH TIME ZONE,
    responded_at TIMESTAMP WITH TIME ZONE,
    
    -- 约束
    UNIQUE(user_id, buddy_id),
    CHECK(user_id != buddy_id),
    
    -- 索引
    INDEX idx_workout_buddies_user_id (user_id),
    INDEX idx_workout_buddies_buddy_id (buddy_id),
    INDEX idx_workout_buddies_status (status)
);
```

### AI 训练计划生成记录表 (ai_plan_generations)
```sql
CREATE TABLE ai_plan_generations (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    user_id INTEGER NOT NULL REFERENCES users(id),
    generation_id VARCHAR(100) UNIQUE NOT NULL,
    prompt JSONB NOT NULL,
    generated_plan JSONB NOT NULL,
    
    -- 用户反馈
    user_feedback TEXT,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    used BOOLEAN DEFAULT FALSE,
    feedback_at TIMESTAMP WITH TIME ZONE,
    
    -- 索引
    INDEX idx_ai_plan_generations_user_id (user_id),
    INDEX idx_ai_plan_generations_generation_id (generation_id),
    INDEX idx_ai_plan_generations_created_at (created_at)
);
```

### 教练-学员关系表 (coach_student_relations)
```sql
CREATE TABLE coach_student_relations (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    coach_id INTEGER NOT NULL REFERENCES users(id),
    student_id INTEGER NOT NULL REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'active', -- active, paused, ended
    
    -- 教练信息
    specialty JSONB DEFAULT '[]',
    hourly_rate DECIMAL(10,2),
    introduction TEXT,
    
    -- 关系管理
    assigned_plans JSONB DEFAULT '[]',
    progress_tracking JSONB DEFAULT '{}',
    last_interaction TIMESTAMP WITH TIME ZONE,
    
    -- 约束
    UNIQUE(coach_id, student_id),
    CHECK(coach_id != student_id),
    
    -- 索引
    INDEX idx_coach_student_coach_id (coach_id),
    INDEX idx_coach_student_student_id (student_id),
    INDEX idx_coach_student_status (status)
);
```

## 🔄 状态码规范

### HTTP 状态码
- `200`: 成功
- `201`: 创建成功
- `400`: 请求参数错误
- `401`: 未授权
- `403`: 禁止访问
- `404`: 资源不存在
- `409`: 资源冲突
- `422`: 数据验证失败
- `429`: 请求过于频繁
- `500`: 服务器内部错误

### 业务状态码
- `1000`: 成功
- `1001`: 参数错误
- `1002`: 数据不存在
- `1003`: 权限不足
- `1004`: 操作失败
- `2001`: 用户不存在
- `2002`: 密码错误
- `2003`: Token 过期
- `2004`: 用户已存在
- `3001`: 动态不存在
- `3002`: 无权操作
- `4001`: 搭子申请已存在
- `4002`: 不能申请自己
- `5001`: AI 服务异常

## 📱 移动端适配

### 分页参数
- 默认每页 20 条记录
- 最大每页 100 条记录
- 支持游标分页和偏移分页

### 图片处理
- 支持 JPEG、PNG 格式
- 最大文件大小 10MB
- 自动压缩和格式转换
- 支持多图上传

### 缓存策略
- 用户信息缓存 1 小时
- 动态列表缓存 5 分钟
- 训练计划缓存 30 分钟
- 使用 ETag 支持条件请求

---

## 🎯 总结

这个 API 设计文档涵盖了 FitTracker MVP 的所有核心功能，包括：

1. **完整的认证体系** - 支持手机号、微信、Apple 登录
2. **丰富的社区功能** - 发布动态、点赞评论、话题标签
3. **智能训练系统** - AI 生成计划、训练记录、进度追踪
4. **社交搭子系统** - 智能推荐、申请匹配、关系管理
5. **专业教练服务** - 教练认证、学员管理、计划分配

**设计特点:**
- RESTful API 设计规范
- 统一的响应格式
- 完善的错误处理
- 灵活的查询参数
- 合理的分页机制
- 安全的数据验证

**下一步:**
1. 实现后端 API 接口
2. 编写 API 文档和测试用例
3. 集成前端调用
4. 进行接口联调测试
