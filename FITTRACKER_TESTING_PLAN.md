# FitTracker MVP 自动化测试方案

## 🎯 测试策略概览

**测试目标**: 确保 FitTracker MVP 功能完整、性能稳定、用户体验良好  
**测试覆盖**: 单元测试、集成测试、E2E测试、性能测试  
**测试工具**: Go testify、Flutter test、Postman、k6、Playwright  
**测试环境**: 开发环境、测试环境、预生产环境  

## 🧪 测试分层架构

```
┌─────────────────────────────────────────────────────────┐
│                    E2E 测试层                            │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────┐ │
│  │   用户流程测试   │  │   跨平台测试     │  │  性能测试 │ │
│  │  (Playwright)   │  │  (Flutter)      │  │   (k6)   │ │
│  └─────────────────┘  └─────────────────┘  └──────────┘ │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│                   集成测试层                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────┐ │
│  │   API 测试       │  │   数据库测试     │  │  第三方集成│ │
│  │  (Postman)      │  │  (PostgreSQL)   │  │  (微信/AI) │ │
│  └─────────────────┘  └─────────────────┘  └──────────┘ │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│                   单元测试层                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────┐ │
│  │   Go 单元测试    │  │  Flutter 测试    │  │  工具函数  │ │
│  │  (testify)      │  │  (flutter_test) │  │  测试     │ │
│  └─────────────────┘  └─────────────────┘  └──────────┘ │
└─────────────────────────────────────────────────────────┘
```

## 🔧 后端测试 (Go)

### 单元测试框架
```go
// 使用 testify 框架
import (
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/mock"
    "github.com/stretchr/testify/suite"
)
```

### 核心测试用例

#### 1. 用户认证测试
```go
func TestUserAuth(t *testing.T) {
    tests := []struct {
        name     string
        phone    string
        password string
        wantErr  bool
    }{
        {
            name:     "正常登录",
            phone:    "13800138000",
            password: "password123",
            wantErr:  false,
        },
        {
            name:     "密码错误",
            phone:    "13800138000",
            password: "wrongpassword",
            wantErr:  true,
        },
        {
            name:     "用户不存在",
            phone:    "13900139000",
            password: "password123",
            wantErr:  true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            user, err := authService.Login(tt.phone, tt.password)
            if tt.wantErr {
                assert.Error(t, err)
                assert.Nil(t, user)
            } else {
                assert.NoError(t, err)
                assert.NotNil(t, user)
                assert.Equal(t, tt.phone, user.Phone)
            }
        })
    }
}
```

#### 2. AI 服务测试
```go
func TestAIService(t *testing.T) {
    mockAI := &MockAIService{}
    
    // 设置 mock 期望
    mockAI.On("GenerateWorkoutPlan", mock.Anything).Return(&PlanResponse{
        Name: "AI生成计划",
        Workouts: []Workout{},
    }, nil)
    
    // 测试 AI 计划生成
    plan, err := mockAI.GenerateWorkoutPlan(&PlanRequest{
        Goal: "增肌",
        Level: "初级",
    })
    
    assert.NoError(t, err)
    assert.Equal(t, "AI生成计划", plan.Name)
    mockAI.AssertExpectations(t)
}
```

#### 3. 搭子匹配测试
```go
func TestBuddyMatching(t *testing.T) {
    user := &User{
        ID: 1,
        FitnessTags: []string{"力量训练"},
        Location: "北京市朝阳区",
        FitnessGoal: "增肌",
    }
    
    candidates := []*User{
        {
            ID: 2,
            FitnessTags: []string{"力量训练", "有氧运动"},
            Location: "北京市朝阳区",
            FitnessGoal: "增肌",
        },
        {
            ID: 3,
            FitnessTags: []string{"瑜伽"},
            Location: "上海市浦东区",
            FitnessGoal: "减脂",
        },
    }
    
    matches := MatchBuddies(user, candidates)
    
    assert.Len(t, matches, 1)
    assert.Equal(t, int64(2), matches[0].User.ID)
    assert.Greater(t, matches[0].Score, 70.0)
}
```

### 测试覆盖率目标
- **核心业务逻辑**: 100% 覆盖
- **API 接口**: > 90% 覆盖
- **工具函数**: > 80% 覆盖
- **整体覆盖率**: > 85%

## 📱 前端测试 (Flutter)

### 测试框架配置
```yaml
# pubspec.yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  integration_test:
    sdk: flutter
```

### 核心测试用例

#### 1. 状态管理测试
```dart
void main() {
  group('AuthNotifier', () {
    late AuthNotifier notifier;
    late MockAuthRepository mockRepository;
    
    setUp(() {
      mockRepository = MockAuthRepository();
      notifier = AuthNotifier();
    });
    
    test('登录成功应该更新状态', () async {
      // Arrange
      when(mockRepository.login(any, any))
          .thenAnswer((_) async => LoginResponse(
            user: User(id: 1, phone: '13800138000'),
            token: 'token123',
          ));
      
      // Act
      await notifier.login('13800138000', 'password123');
      
      // Assert
      expect(notifier.state.isAuthenticated, true);
      expect(notifier.state.user?.phone, '13800138000');
      expect(notifier.state.token, 'token123');
    });
    
    test('登录失败应该显示错误', () async {
      // Arrange
      when(mockRepository.login(any, any))
          .thenThrow(Exception('登录失败'));
      
      // Act
      await notifier.login('13800138000', 'wrongpassword');
      
      // Assert
      expect(notifier.state.isAuthenticated, false);
      expect(notifier.state.error, isNotNull);
    });
  });
}
```

#### 2. Widget 测试
```dart
void main() {
  group('PostCard Widget', () {
    testWidgets('应该正确显示动态内容', (tester) async {
      // Arrange
      final post = Post(
        id: 1,
        content: '测试动态内容',
        user: User(nickname: '测试用户'),
        images: ['image1.jpg', 'image2.jpg'],
        likesCount: 10,
      );
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: PostCard(post: post),
        ),
      );
      
      // Assert
      expect(find.text('测试动态内容'), findsOneWidget);
      expect(find.text('测试用户'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.byType(Image), findsNWidgets(2));
    });
    
    testWidgets('点击点赞应该触发回调', (tester) async {
      // Arrange
      bool liked = false;
      final post = Post(id: 1, content: '测试');
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: PostCard(
            post: post,
            onLike: () => liked = true,
          ),
        ),
      );
      
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();
      
      // Assert
      expect(liked, true);
    });
  });
}
```

#### 3. 集成测试
```dart
void main() {
  group('用户登录流程', () {
    testWidgets('完整登录流程测试', (tester) async {
      // 启动应用
      await tester.pumpWidget(MyApp());
      
      // 等待应用加载
      await tester.pumpAndSettle();
      
      // 输入手机号
      await tester.enterText(find.byKey(Key('phone_field')), '13800138000');
      
      // 输入密码
      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      
      // 点击登录按钮
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();
      
      // 验证跳转到首页
      expect(find.text('首页'), findsOneWidget);
      expect(find.text('13800138000'), findsOneWidget);
    });
  });
}
```

## 🔌 API 集成测试

### Postman 测试集合
```json
{
  "info": {
    "name": "FitTracker API Tests",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "用户认证",
      "item": [
        {
          "name": "用户注册",
          "request": {
            "method": "POST",
            "header": [{"key": "Content-Type", "value": "application/json"}],
            "body": {
              "mode": "raw",
              "raw": "{\"phone\":\"13800138000\",\"password\":\"password123\"}"
            },
            "url": "{{base_url}}/auth/register"
          },
          "event": [
            {
              "listen": "test",
              "script": {
                "exec": [
                  "pm.test('状态码应该是200', function () {",
                  "    pm.response.to.have.status(200);",
                  "});",
                  "",
                  "pm.test('响应包含用户信息', function () {",
                  "    const jsonData = pm.response.json();",
                  "    pm.expect(jsonData.data.user).to.have.property('id');",
                  "    pm.expect(jsonData.data.user).to.have.property('phone');",
                  "});"
                ]
              }
            }
          ]
        }
      ]
    }
  ]
}
```

### 自动化测试脚本
```bash
#!/bin/bash
# run_api_tests.sh

echo "开始 API 集成测试..."

# 启动测试环境
docker-compose -f docker-compose.test.yml up -d

# 等待服务启动
sleep 30

# 运行 Postman 测试
newman run tests/postman/FitTracker_API_Tests.postman_collection.json \
  --environment tests/postman/test_environment.json \
  --reporters cli,json \
  --reporter-json-export test_results.json

# 检查测试结果
if [ $? -eq 0 ]; then
    echo "✅ API 测试通过"
else
    echo "❌ API 测试失败"
    exit 1
fi

# 清理测试环境
docker-compose -f docker-compose.test.yml down
```

## ⚡ 性能测试 (k6)

### 负载测试脚本
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 100 }, // 2分钟内达到100用户
    { duration: '5m', target: 100 }, // 保持100用户5分钟
    { duration: '2m', target: 200 }, // 2分钟内达到200用户
    { duration: '5m', target: 200 }, // 保持200用户5分钟
    { duration: '2m', target: 0 },   // 2分钟内降到0用户
  ],
  thresholds: {
    http_req_duration: ['p(95)<200'], // 95%的请求响应时间小于200ms
    http_req_failed: ['rate<0.1'],   // 错误率小于10%
  },
};

const BASE_URL = 'https://api.fittracker.com/api/v1';

export default function() {
  // 测试用户登录
  let loginResponse = http.post(`${BASE_URL}/auth/login`, JSON.stringify({
    phone: '13800138000',
    password: 'password123'
  }), {
    headers: { 'Content-Type': 'application/json' },
  });
  
  check(loginResponse, {
    '登录状态码是200': (r) => r.status === 200,
    '登录响应时间小于200ms': (r) => r.timings.duration < 200,
  });
  
  let token = loginResponse.json('data.token');
  
  // 测试获取动态列表
  let postsResponse = http.get(`${BASE_URL}/posts`, {
    headers: { 'Authorization': `Bearer ${token}` },
  });
  
  check(postsResponse, {
    '动态列表状态码是200': (r) => r.status === 200,
    '动态列表响应时间小于300ms': (r) => r.timings.duration < 300,
  });
  
  sleep(1);
}
```

### 压力测试脚本
```javascript
import http from 'k6/http';
import { check } from 'k6';

export let options = {
  vus: 1000, // 1000个虚拟用户
  duration: '10m', // 持续10分钟
  thresholds: {
    http_req_duration: ['p(99)<500'], // 99%的请求响应时间小于500ms
    http_req_failed: ['rate<0.05'],  // 错误率小于5%
  },
};

export default function() {
  let response = http.get('https://api.fittracker.com/api/v1/posts');
  
  check(response, {
    '状态码是200': (r) => r.status === 200,
    '响应时间合理': (r) => r.timings.duration < 1000,
  });
}
```

## 🎭 E2E 测试 (Playwright)

### 用户流程测试
```javascript
const { test, expect } = require('@playwright/test');

test.describe('FitTracker E2E 测试', () => {
  test('完整用户注册登录流程', async ({ page }) => {
    // 访问应用
    await page.goto('https://app.fittracker.com');
    
    // 点击注册按钮
    await page.click('text=注册');
    
    // 填写注册信息
    await page.fill('input[placeholder="手机号"]', '13800138000');
    await page.fill('input[placeholder="密码"]', 'password123');
    await page.fill('input[placeholder="验证码"]', '123456');
    
    // 点击注册
    await page.click('button[type="submit"]');
    
    // 验证注册成功
    await expect(page).toHaveURL(/.*home/);
    await expect(page.locator('text=13800138000')).toBeVisible();
  });
  
  test('发布动态流程', async ({ page }) => {
    // 登录
    await page.goto('https://app.fittracker.com/login');
    await page.fill('input[placeholder="手机号"]', '13800138000');
    await page.fill('input[placeholder="密码"]', 'password123');
    await page.click('button[type="submit"]');
    
    // 进入社区页面
    await page.click('text=社区');
    
    // 点击发布动态
    await page.click('button:has-text("发布动态")');
    
    // 填写动态内容
    await page.fill('textarea[placeholder="分享你的健身心得..."]', '今天完成了45分钟的力量训练！');
    
    // 上传图片
    await page.setInputFiles('input[type="file"]', 'test_images/workout.jpg');
    
    // 发布
    await page.click('button:has-text("发布")');
    
    // 验证发布成功
    await expect(page.locator('text=今天完成了45分钟的力量训练！')).toBeVisible();
  });
  
  test('AI训练计划生成', async ({ page }) => {
    // 登录并进入训练页面
    await page.goto('https://app.fittracker.com/workout');
    
    // 点击AI教练
    await page.click('text=AI教练');
    
    // 填写训练需求
    await page.selectOption('select[name="goal"]', '增肌');
    await page.selectOption('select[name="level"]', '初级');
    await page.selectOption('select[name="duration"]', '4周');
    
    // 生成计划
    await page.click('button:has-text("生成计划")');
    
    // 等待AI生成
    await page.waitForSelector('text=计划生成完成', { timeout: 30000 });
    
    // 验证计划生成
    await expect(page.locator('text=AI生成增肌计划')).toBeVisible();
    await expect(page.locator('button:has-text("使用计划")')).toBeVisible();
  });
});
```

## 📊 测试报告和监控

### 测试报告生成
```bash
#!/bin/bash
# generate_test_report.sh

echo "生成测试报告..."

# 运行所有测试
echo "运行单元测试..."
go test -v -coverprofile=coverage.out ./...

echo "运行Flutter测试..."
flutter test --coverage

echo "运行API测试..."
newman run tests/postman/FitTracker_API_Tests.postman_collection.json \
  --reporters cli,json \
  --reporter-json-export api_test_results.json

echo "运行性能测试..."
k6 run tests/performance/load_test.js --out json=performance_results.json

echo "运行E2E测试..."
npx playwright test --reporter=json --output-file=e2e_results.json

# 生成综合报告
node scripts/generate_test_report.js
```

### 测试监控面板
```yaml
# Grafana Dashboard 配置
dashboard:
  title: "FitTracker 测试监控"
  panels:
    - title: "测试覆盖率"
      type: "stat"
      targets:
        - expr: "go_test_coverage"
    - title: "API响应时间"
      type: "graph"
      targets:
        - expr: "api_response_time_p95"
    - title: "测试通过率"
      type: "stat"
      targets:
        - expr: "test_pass_rate"
```

## 🚀 CI/CD 集成

### GitHub Actions 配置
```yaml
name: FitTracker Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  backend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-go@v3
        with:
          go-version: '1.24'
      
      - name: 运行Go测试
        run: |
          go test -v -coverprofile=coverage.out ./...
          go tool cover -html=coverage.out -o coverage.html
      
      - name: 上传覆盖率报告
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.out

  frontend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: 运行Flutter测试
        run: |
          flutter test --coverage
          flutter test integration_test/
      
      - name: 上传测试报告
        uses: actions/upload-artifact@v3
        with:
          name: flutter-test-results
          path: test/

  api-tests:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      
      redis:
        image: redis:7
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - uses: actions/checkout@v3
      
      - name: 启动后端服务
        run: |
          docker-compose -f docker-compose.test.yml up -d
          sleep 30
      
      - name: 运行API测试
        run: |
          npm install -g newman
          newman run tests/postman/FitTracker_API_Tests.postman_collection.json
      
      - name: 运行性能测试
        run: |
          npm install -g k6
          k6 run tests/performance/load_test.js

  e2e-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: 安装Playwright
        run: |
          npm install
          npx playwright install
      
      - name: 运行E2E测试
        run: |
          npx playwright test
      
      - name: 上传测试结果
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: playwright-report
          path: playwright-report/
```

## 📋 测试检查清单

### 功能测试检查清单
- [ ] 用户注册登录功能正常
- [ ] 微信/Apple登录集成正常
- [ ] 动态发布和浏览功能正常
- [ ] 点赞评论功能正常
- [ ] AI训练计划生成正常
- [ ] 训练记录功能正常
- [ ] 搭子推荐和申请正常
- [ ] 教练服务功能正常

### 性能测试检查清单
- [ ] API响应时间 < 200ms
- [ ] 应用启动时间 < 3s
- [ ] 并发用户数 > 1000
- [ ] 数据库查询性能良好
- [ ] 图片加载速度正常
- [ ] 内存使用合理

### 安全测试检查清单
- [ ] 用户密码加密存储
- [ ] JWT Token安全
- [ ] SQL注入防护
- [ ] XSS攻击防护
- [ ] 文件上传安全
- [ ] API接口限流

### 兼容性测试检查清单
- [ ] Android 5.0+ 兼容
- [ ] iOS 12.0+ 兼容
- [ ] 不同屏幕尺寸适配
- [ ] 网络环境适配
- [ ] 浏览器兼容性

---

## 🎯 总结

这个自动化测试方案提供了 FitTracker MVP 的完整测试覆盖：

1. **多层次测试架构** - 单元测试、集成测试、E2E测试
2. **自动化测试工具** - Go testify、Flutter test、Postman、k6、Playwright
3. **CI/CD 集成** - GitHub Actions 自动化测试流程
4. **性能监控** - 实时性能指标监控
5. **测试报告** - 详细的测试结果和覆盖率报告

**关键优势:**
- 全面的测试覆盖，确保质量
- 自动化测试流程，提高效率
- 持续集成，快速发现问题
- 性能监控，保证用户体验

**下一步:**
1. 搭建测试环境和工具
2. 编写核心功能测试用例
3. 配置 CI/CD 自动化流程
4. 建立测试监控和报告机制
