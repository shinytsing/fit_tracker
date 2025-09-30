# FitTracker API 文档

## 概述

FitTracker API 是一个 RESTful API，提供健康管理应用的所有后端功能。API 使用 JSON 格式进行数据交换，支持 JWT 认证。

### 基础信息

- **Base URL**: `https://api.fittracker.com/api`
- **API Version**: v1
- **Content Type**: `application/json`
- **Authentication**: Bearer Token (JWT)

### 响应格式

所有 API 响应都遵循统一的格式：

```json
{
  "success": true,
  "data": {},
  "message": "操作成功",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

错误响应格式：

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "参数验证失败",
    "details": {}
  },
  "timestamp": "2024-01-01T00:00:00Z"
}
```

## 认证

### 登录

```http
POST /auth/login
```

**请求体:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**响应:**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "username": "testuser",
      "email": "user@example.com",
      "avatar_url": "https://example.com/avatar.jpg"
    }
  }
}
```

### 注册

```http
POST /auth/register
```

**请求体:**
```json
{
  "username": "testuser",
  "email": "user@example.com",
  "password": "password123"
}
```

### 刷新令牌

```http
POST /auth/refresh
```

**请求头:**
```
Authorization: Bearer <token>
```

## 用户管理

### 获取用户信息

```http
GET /users/{id}
```

**请求头:**
```
Authorization: Bearer <token>
```

**响应:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "username": "testuser",
    "email": "user@example.com",
    "avatar_url": "https://example.com/avatar.jpg",
    "bio": "健身爱好者",
    "level": "intermediate",
    "total_points": 1000,
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```

### 更新用户信息

```http
PUT /users/{id}
```

**请求头:**
```
Authorization: Bearer <token>
```

**请求体:**
```json
{
  "username": "newusername",
  "bio": "新的个人简介"
}
```

## 健身中心

### 获取训练计划

```http
GET /workouts/plans
```

**查询参数:**
- `page`: 页码 (默认: 1)
- `page_size`: 每页数量 (默认: 20)
- `type`: 训练类型 (减脂, 增肌, 塑形)
- `difficulty`: 难度 (初级, 中级, 高级)

**响应:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "name": "减脂训练计划",
        "type": "减脂",
        "difficulty": "中级",
        "duration": 45,
        "description": "适合中级用户的减脂训练计划",
        "exercises": [
          {
            "name": "俯卧撑",
            "sets": 3,
            "reps": 15,
            "rest_time": 60
          }
        ],
        "ai_powered": true,
        "created_at": "2024-01-01T00:00:00Z"
      }
    ],
    "total": 10,
    "page": 1,
    "page_size": 20
  }
}
```

### 创建训练记录

```http
POST /workouts
```

**请求头:**
```
Authorization: Bearer <token>
```

**请求体:**
```json
{
  "plan_id": 1,
  "start_time": "2024-01-01T10:00:00Z",
  "end_time": "2024-01-01T11:00:00Z",
  "exercises": [
    {
      "name": "俯卧撑",
      "sets": 3,
      "reps": 15,
      "weight": 0,
      "duration": 300
    }
  ],
  "total_calories": 300.0,
  "notes": "训练感觉很好"
}
```

### 生成AI训练计划

```http
POST /ai/workout-plan
```

**请求头:**
```
Authorization: Bearer <token>
```

**请求体:**
```json
{
  "goal": "减脂",
  "difficulty": "中级",
  "duration": 45,
  "available_equipment": ["哑铃", "瑜伽垫"],
  "user_preferences": {
    "favorite_exercises": ["俯卧撑", "深蹲"],
    "avoid_exercises": ["引体向上"]
  }
}
```

**响应:**
```json
{
  "success": true,
  "data": {
    "name": "AI减脂训练计划",
    "type": "减脂",
    "difficulty": "中级",
    "duration": 45,
    "description": "AI生成的个性化减脂训练计划",
    "exercises": [
      {
        "name": "俯卧撑",
        "sets": 3,
        "reps": 15,
        "rest_time": 60,
        "tips": "保持身体挺直，核心收紧"
      }
    ],
    "suggestions": "建议在训练前进行5分钟热身",
    "confidence_score": 0.95,
    "ai_powered": true,
    "ai_provider": "DeepSeek"
  }
}
```

## BMI计算器

### 计算BMI

```http
POST /bmi/calculate
```

**请求头:**
```
Authorization: Bearer <token>
```

**请求体:**
```json
{
  "height": 175.0,
  "weight": 70.0
}
```

**响应:**
```json
{
  "success": true,
  "data": {
    "bmi": 22.86,
    "category": "正常",
    "health_status": "健康",
    "recommendations": [
      "保持当前体重",
      "继续规律运动",
      "保持均衡饮食"
    ]
  }
}
```

### 计算心率

```http
POST /bmi/heart-rate
```

**请求头:**
```
Authorization: Bearer <token>
```

**请求体:**
```json
{
  "age": 25,
  "resting_heart_rate": 60
}
```

**响应:**
```json
{
  "success": true,
  "data": {
    "max_heart_rate": 195,
    "target_heart_rate": {
      "moderate": {
        "min": 117,
        "max": 136
      },
      "vigorous": {
        "min": 136,
        "max": 165
      }
    },
    "recommendations": "建议在中等强度区间进行有氧运动"
  }
}
```

### 计算1RM

```http
POST /bmi/one-rm
```

**请求头:**
```
Authorization: Bearer <token>
```

**请求体:**
```json
{
  "exercise": "卧推",
  "weight": 100.0,
  "reps": 8,
  "formula": "Epley"
}
```

**响应:**
```json
{
  "success": true,
  "data": {
    "exercise": "卧推",
    "one_rm": 125.0,
    "formula": "Epley",
    "confidence": "高",
    "training_zones": {
      "strength": "90-100%",
      "power": "80-90%",
      "hypertrophy": "70-80%",
      "endurance": "60-70%"
    }
  }
}
```

## 营养计算器

### 计算卡路里

```http
POST /nutrition/calories
```

**请求头:**
```
Authorization: Bearer <token>
```

**请求体:**
```json
{
  "age": 25,
  "gender": "male",
  "height": 175.0,
  "weight": 70.0,
  "activity_level": "moderate",
  "goal": "maintain"
}
```

**响应:**
```json
{
  "success": true,
  "data": {
    "bmr": 1700.0,
    "tdee": 2380.0,
    "target_calories": 2380.0,
    "macronutrients": {
      "protein": {
        "grams": 119.0,
        "calories": 476.0,
        "percentage": 20
      },
      "carbs": {
        "grams": 297.5,
        "calories": 1190.0,
        "percentage": 50
      },
      "fat": {
        "grams": 79.3,
        "calories": 714.0,
        "percentage": 30
      }
    },
    "recommendations": [
      "每天摄入足够的蛋白质",
      "选择复合碳水化合物",
      "适量摄入健康脂肪"
    ]
  }
}
```

### 添加营养记录

```http
POST /nutrition/records
```

**请求头:**
```
Authorization: Bearer <token>
```

**请求体:**
```json
{
  "meal_type": "breakfast",
  "food_name": "燕麦",
  "quantity": 100.0,
  "unit": "g",
  "calories": 350.0,
  "protein": 12.0,
  "carbs": 60.0,
  "fat": 6.0,
  "fiber": 10.0,
  "sugar": 1.0,
  "sodium": 2.0,
  "notes": "早餐燕麦"
}
```

### 搜索食物

```http
GET /nutrition/foods/search
```

**查询参数:**
- `q`: 搜索关键词
- `page`: 页码
- `page_size`: 每页数量

**响应:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "name": "燕麦",
        "brand": "桂格",
        "category": "谷物",
        "serving_size": 100.0,
        "serving_unit": "g",
        "calories": 350.0,
        "protein": 12.0,
        "carbs": 60.0,
        "fat": 6.0,
        "barcode": "1234567890"
      }
    ],
    "total": 50,
    "page": 1,
    "page_size": 20
  }
}
```

## 签到日历

### 执行签到

```http
POST /checkin
```

**请求头:**
```
Authorization: Bearer <token>
```

**请求体:**
```json
{
  "mood": "happy",
  "notes": "今天感觉很好",
  "activities": ["运动", "工作"],
  "weight": 70.0,
  "steps": 8000,
  "calories": 200,
  "sleep_hours": 8,
  "weather": "sunny"
}
```

### 获取签到记录

```http
GET /checkin/records
```

**查询参数:**
- `start_date`: 开始日期
- `end_date`: 结束日期
- `page`: 页码
- `page_size`: 每页数量

**响应:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "date": "2024-01-01",
        "checkin_time": "2024-01-01T08:00:00Z",
        "mood": "happy",
        "notes": "今天感觉很好",
        "activities": ["运动", "工作"],
        "weight": 70.0,
        "steps": 8000,
        "calories": 200,
        "sleep_hours": 8,
        "weather": "sunny"
      }
    ],
    "total": 30,
    "page": 1,
    "page_size": 20
  }
}
```

### 获取连续签到数据

```http
GET /checkin/streak
```

**请求头:**
```
Authorization: Bearer <token>
```

**响应:**
```json
{
  "success": true,
  "data": {
    "current_streak": 5,
    "longest_streak": 15,
    "last_checkin_date": "2024-01-01",
    "available_rewards": [
      {
        "id": 1,
        "name": "连续签到7天",
        "description": "连续签到7天奖励",
        "required_days": 7,
        "reward_type": "badge",
        "reward_value": "签到达人",
        "is_claimed": false
      }
    ]
  }
}
```

## 社区互动

### 发布动态

```http
POST /community/posts
```

**请求头:**
```
Authorization: Bearer <token>
```

**请求体:**
```json
{
  "content": "今天完成了30分钟跑步！",
  "images": ["image1.jpg", "image2.jpg"],
  "videos": [],
  "post_type": "text",
  "tags": ["跑步", "健身"],
  "location": "北京"
}
```

### 获取动态列表

```http
GET /community/posts
```

**查询参数:**
- `page`: 页码
- `page_size`: 每页数量
- `type`: 动态类型 (text, image, video, workout)
- `category`: 分类

**响应:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "user_id": 1,
        "username": "testuser",
        "avatar_url": "https://example.com/avatar.jpg",
        "content": "今天完成了30分钟跑步！",
        "images": ["image1.jpg"],
        "videos": [],
        "post_type": "text",
        "likes_count": 5,
        "comments_count": 2,
        "shares_count": 1,
        "is_liked": false,
        "tags": ["跑步", "健身"],
        "location": "北京",
        "created_at": "2024-01-01T10:00:00Z"
      }
    ],
    "total": 100,
    "page": 1,
    "page_size": 20
  }
}
```

### 点赞动态

```http
POST /community/posts/{id}/like
```

**请求头:**
```
Authorization: Bearer <token>
```

### 添加评论

```http
POST /community/posts/{id}/comments
```

**请求头:**
```
Authorization: Bearer <token>
```

**请求体:**
```json
{
  "content": "太棒了！"
}
```

### 关注用户

```http
POST /community/users/{id}/follow
```

**请求头:**
```
Authorization: Bearer <token>
```

### 获取关注列表

```http
GET /community/following
```

**请求头:**
```
Authorization: Bearer <token>
```

**响应:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 2,
        "username": "fitness_guru",
        "avatar_url": "https://example.com/avatar2.jpg",
        "bio": "健身达人",
        "followers_count": 1000,
        "following_count": 100,
        "posts_count": 50,
        "is_following": true,
        "is_verified": true,
        "level": "expert"
      }
    ],
    "total": 10,
    "page": 1,
    "page_size": 20
  }
}
```

## 错误码

| 错误码 | HTTP状态码 | 描述 |
|--------|------------|------|
| VALIDATION_ERROR | 400 | 参数验证失败 |
| UNAUTHORIZED | 401 | 未授权访问 |
| FORBIDDEN | 403 | 禁止访问 |
| NOT_FOUND | 404 | 资源不存在 |
| CONFLICT | 409 | 资源冲突 |
| RATE_LIMIT_EXCEEDED | 429 | 请求频率超限 |
| INTERNAL_ERROR | 500 | 服务器内部错误 |
| SERVICE_UNAVAILABLE | 503 | 服务不可用 |

## 限流

API 实施了以下限流策略：

- **通用API**: 10 请求/秒
- **登录接口**: 5 请求/分钟
- **AI服务**: 3 请求/分钟
- **文件上传**: 1 请求/秒

## 版本控制

API 使用 URL 路径进行版本控制：

- 当前版本: `/api/v1/`
- 未来版本: `/api/v2/`

## 支持

如有问题，请联系：

- **邮箱**: api-support@fittracker.com
- **文档**: https://docs.fittracker.com
- **状态页**: https://status.fittracker.com
