# 🚀 FitTracker 全量重构计划

## 📊 项目现状分析

### 🔍 当前问题
1. **技术栈不一致**: 文档显示FastAPI+Python，但要求Go语言
2. **前端结构混乱**: 部分模块有Clean Architecture，部分没有
3. **命名不统一**: 组件和页面命名规范不一致
4. **耦合度高**: 业务逻辑和UI混合
5. **测试覆盖不全**: 部分模块缺少测试
6. **API设计散乱**: 路由和数据库操作不规范

### ✅ 现有优势
1. **功能完整**: 五大核心模块已实现
2. **Material3设计**: UI风格统一
3. **Riverpod状态管理**: 架构基础良好
4. **AI服务集成**: 多LLM支持已实现

## 🎯 重构目标

### 后端重构 (Python → Go)
- **Go + Gin框架** 替代 FastAPI
- **GORM** 替代 SQLAlchemy  
- **统一API设计** RESTful + 错误处理
- **模块化服务** 清晰的分层架构
- **完整测试覆盖** 单元测试 + 集成测试

### 前端重构 (Flutter + Riverpod)
- **统一命名规范** 所有组件和页面
- **完整Clean Architecture** data/domain/presentation三层
- **组件化设计** 可复用的UI组件库
- **状态管理优化** 减少重复代码
- **Widget测试** 所有UI组件测试

## 📋 重构计划

### Phase 1: 核心架构重构
1. **后端Go重构**
   - 创建Go项目结构
   - 实现核心服务层
   - 数据库模型和迁移
   - API路由和中间件

2. **前端架构统一**
   - 统一命名规范
   - Clean Architecture完整实现
   - 共享组件库
   - 状态管理优化

### Phase 2: 模块重构 (按优先级)
1. **健身中心模块** (最高优先级)
2. **BMI计算器模块**
3. **营养计算器模块**
4. **签到日历模块**
5. **社区互动模块**

### Phase 3: 测试和优化
1. **完善测试覆盖**
2. **性能优化**
3. **文档更新**
4. **部署配置**

## 🏗️ 新架构设计

### 后端架构 (Go)
```
backend/
├── cmd/
│   └── server/
│       └── main.go          # 应用入口
├── internal/
│   ├── api/                 # API层
│   │   ├── handlers/        # HTTP处理器
│   │   ├── middleware/      # 中间件
│   │   └── routes/         # 路由定义
│   ├── domain/             # 领域层
│   │   ├── models/         # 领域模型
│   │   ├── repositories/   # 仓储接口
│   │   └── services/       # 业务服务
│   ├── infrastructure/     # 基础设施层
│   │   ├── database/       # 数据库
│   │   ├── cache/          # 缓存
│   │   └── external/       # 外部服务
│   └── config/             # 配置
├── pkg/                    # 公共包
│   ├── logger/             # 日志
│   ├── validator/          # 验证器
│   └── utils/              # 工具函数
├── migrations/             # 数据库迁移
├── tests/                  # 测试文件
└── docs/                   # API文档
```

### 前端架构 (Flutter)
```
frontend/lib/
├── core/                   # 核心功能
│   ├── constants/          # 常量
│   ├── errors/            # 错误处理
│   ├── network/           # 网络层
│   ├── router/            # 路由
│   ├── theme/             # 主题
│   └── utils/             # 工具函数
├── features/              # 功能模块
│   └── {feature}/
│       ├── data/           # 数据层
│       │   ├── datasources/ # 数据源
│       │   ├── models/     # 数据模型
│       │   └── repositories/ # 仓储实现
│       ├── domain/         # 领域层
│       │   ├── entities/   # 实体
│       │   ├── repositories/ # 仓储接口
│       │   └── usecases/  # 用例
│       └── presentation/   # 表现层
│           ├── pages/      # 页面
│           ├── widgets/    # 组件
│           └── providers/  # 状态管理
├── shared/                # 共享组件
│   ├── widgets/           # 通用组件
│   ├── models/            # 通用模型
│   └── services/          # 通用服务
└── main.dart              # 应用入口
```

## 🔧 技术选型

### 后端技术栈
- **语言**: Go 1.21+
- **框架**: Gin/Echo
- **ORM**: GORM
- **数据库**: PostgreSQL 15+
- **缓存**: Redis 7.0+
- **认证**: JWT + bcrypt
- **文档**: Swagger/OpenAPI
- **测试**: Testify + GoMock

### 前端技术栈
- **框架**: Flutter 3.16+
- **状态管理**: Riverpod 2.4+
- **网络**: Dio 5.3+
- **本地存储**: Hive 2.2+
- **路由**: Go Router 12.0+
- **UI**: Material Design 3
- **测试**: Flutter Test + Mockito

## 📝 命名规范

### 后端命名规范
- **包名**: 小写，单词间用下划线
- **文件名**: 小写，单词间用下划线
- **结构体**: PascalCase
- **方法/函数**: PascalCase
- **变量**: camelCase
- **常量**: UPPER_CASE

### 前端命名规范
- **文件名**: snake_case
- **类名**: PascalCase
- **方法/变量**: camelCase
- **常量**: UPPER_CASE
- **私有成员**: 下划线前缀

## 🧪 测试策略

### 后端测试
- **单元测试**: 覆盖率 > 80%
- **集成测试**: API端点测试
- **数据库测试**: 使用testcontainers
- **性能测试**: 压力测试

### 前端测试
- **单元测试**: Provider和Service测试
- **Widget测试**: 所有UI组件测试
- **集成测试**: 页面流程测试
- **Golden测试**: UI一致性测试

## 🚀 实施步骤

### Step 1: 环境准备
1. 创建Go项目结构
2. 配置开发环境
3. 设置CI/CD流程

### Step 2: 核心服务
1. 用户认证服务
2. 数据库连接和迁移
3. 基础API框架

### Step 3: 模块重构
1. 健身中心模块
2. BMI计算器模块
3. 营养计算器模块
4. 签到日历模块
5. 社区互动模块

### Step 4: 测试和优化
1. 完善测试覆盖
2. 性能优化
3. 文档更新

## 📊 验收标准

### 功能验收
- [ ] 所有原有功能正常工作
- [ ] 新功能按需求实现
- [ ] API响应时间 < 200ms
- [ ] 前端页面加载时间 < 2s

### 代码质量
- [ ] 后端测试覆盖率 > 80%
- [ ] 前端Widget测试覆盖率 > 90%
- [ ] 代码审查通过
- [ ] 无严重安全漏洞

### 部署验收
- [ ] Docker容器正常启动
- [ ] 数据库迁移成功
- [ ] CI/CD流程正常
- [ ] 生产环境稳定运行

---

*重构计划版本: v1.0*  
*创建时间: 2025-09-30*  
*预计完成时间: 2025-10-15*
