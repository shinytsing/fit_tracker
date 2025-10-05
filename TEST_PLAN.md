# FitTracker Flutter 应用测试计划

## 📋 测试概述

本测试计划涵盖了 FitTracker Flutter 应用的所有核心功能，包括单元测试和集成测试，确保 API 调用正确、状态更新正确、UI 反馈正确。

## 🎯 测试目标

- 验证所有 API 调用正确映射到对应的端点
- 确保状态管理（Riverpod）正常工作
- 验证 UI 交互与后端 API 的集成
- 测试错误处理和用户反馈机制
- 确保数据模型正确解析和转换

## 📱 核心功能测试

### 1. 认证流程测试

#### 1.1 用户注册测试
**测试文件**: `test/auth/register_test.dart`

**测试用例**:
- ✅ 成功注册新用户
- ✅ 注册时邮箱格式验证
- ✅ 注册时密码强度验证
- ✅ 重复邮箱注册失败
- ✅ 网络错误处理
- ✅ 注册成功后自动登录

**API 端点**: `POST /auth/register`

**测试步骤**:
```dart
testWidgets('用户注册成功', (WidgetTester tester) async {
  // 1. 模拟 API 响应
  when(mockApiService.post('/auth/register', data: anyNamed('data')))
      .thenAnswer((_) async => Response(
        data: {
          'data': {
            'user': mockUserJson,
            'token': 'mock_token',
            'refresh_token': 'mock_refresh_token'
          }
        },
        statusCode: 200,
      ));

  // 2. 构建注册页面
  await tester.pumpWidget(createTestWidget(RegisterPage()));

  // 3. 填写注册表单
  await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
  await tester.enterText(find.byKey(Key('password_field')), 'password123');
  await tester.enterText(find.byKey(Key('username_field')), 'testuser');

  // 4. 点击注册按钮
  await tester.tap(find.byKey(Key('register_button')));
  await tester.pumpAndSettle();

  // 5. 验证结果
  expect(find.text('注册成功'), findsOneWidget);
  verify(mockApiService.post('/auth/register', data: anyNamed('data'))).called(1);
});
```

#### 1.2 用户登录测试
**测试文件**: `test/auth/login_test.dart`

**测试用例**:
- ✅ 成功登录
- ✅ 错误密码登录失败
- ✅ 不存在的用户登录失败
- ✅ Token 自动保存
- ✅ 登录后跳转到主页面

**API 端点**: `POST /auth/login`

### 2. 训练功能测试

#### 2.1 训练打卡流程测试
**测试文件**: `test/training/workout_test.dart`

**测试用例**:
- ✅ 开始训练
- ✅ 完成训练
- ✅ 获取今日训练计划
- ✅ 训练记录保存
- ✅ 训练统计更新

**API 端点**:
- `POST /workouts/track` - 开始训练
- `PUT /workouts/{id}/complete` - 完成训练
- `GET /workouts/plans/today` - 获取今日计划

**测试步骤**:
```dart
testWidgets('开始训练流程', (WidgetTester tester) async {
  // 1. 模拟获取今日训练计划
  when(mockApiService.get('/workouts/plans/today'))
      .thenAnswer((_) async => Response(
        data: {'data': mockTodayPlanJson},
        statusCode: 200,
      ));

  // 2. 模拟开始训练
  when(mockApiService.post('/workouts/track', data: anyNamed('data')))
      .thenAnswer((_) async => Response(
        data: {'data': mockWorkoutJson},
        statusCode: 201,
      ));

  // 3. 构建训练页面
  await tester.pumpWidget(createTestWidget(TrainingPage()));

  // 4. 等待今日计划加载
  await tester.pumpAndSettle();

  // 5. 点击开始训练按钮
  await tester.tap(find.text('开始训练'));
  await tester.pumpAndSettle();

  // 6. 验证 API 调用
  verify(mockApiService.post('/workouts/track', data: anyNamed('data'))).called(1);
  expect(find.text('训练已开始！'), findsOneWidget);
});
```

#### 2.2 AI 训练计划生成测试
**测试文件**: `test/training/ai_plan_test.dart`

**测试用例**:
- ✅ AI 生成训练计划
- ✅ 表单验证
- ✅ 生成参数传递
- ✅ 生成结果展示
- ✅ 保存生成的计划

**API 端点**: `POST /workout/ai/generate-plan`

### 3. 社区功能测试

#### 3.1 社区发帖/点赞/评论测试
**测试文件**: `test/community/post_test.dart`

**测试用例**:
- ✅ 发布训练动态
- ✅ 发布饮食动态
- ✅ 发布普通动态
- ✅ 点赞动态
- ✅ 取消点赞
- ✅ 评论动态
- ✅ 动态列表加载

**API 端点**:
- `POST /community/posts` - 发布动态
- `POST /community/posts/{id}/like` - 点赞
- `DELETE /community/posts/{id}/like` - 取消点赞
- `POST /community/posts/{id}/comments` - 评论

**测试步骤**:
```dart
testWidgets('发布训练动态', (WidgetTester tester) async {
  // 1. 模拟发布动态 API
  when(mockApiService.post('/community/posts', data: anyNamed('data')))
      .thenAnswer((_) async => Response(
        data: {'data': mockPostJson},
        statusCode: 201,
      ));

  // 2. 构建社区页面
  await tester.pumpWidget(createTestWidget(CommunityPage()));

  // 3. 点击浮动按钮
  await tester.tap(find.byKey(Key('floating_action_button')));
  await tester.pumpAndSettle();

  // 4. 选择发布训练
  await tester.tap(find.text('发布训练'));
  await tester.pumpAndSettle();

  // 5. 填写内容
  await tester.enterText(find.byKey(Key('content_field')), '今天完成了胸肌训练！');
  
  // 6. 点击发布
  await tester.tap(find.text('发布'));
  await tester.pumpAndSettle();

  // 7. 验证结果
  verify(mockApiService.post('/community/posts', data: anyNamed('data'))).called(1);
  expect(find.text('发布成功！'), findsOneWidget);
});
```

#### 3.2 挑战功能测试
**测试文件**: `test/community/challenge_test.dart`

**测试用例**:
- ✅ 获取挑战列表
- ✅ 参与挑战
- ✅ 挑战排行榜
- ✅ 挑战进度更新

**API 端点**:
- `GET /community/challenges` - 获取挑战列表
- `POST /community/challenges/{id}/join` - 参与挑战

### 4. 消息功能测试

#### 4.1 消息收发测试
**测试文件**: `test/messages/message_test.dart`

**测试用例**:
- ✅ 获取消息列表
- ✅ 发送消息
- ✅ 获取通知列表
- ✅ 标记通知已读
- ✅ 实时消息更新

**API 端点**:
- `GET /messages` - 获取消息列表
- `POST /messages` - 发送消息
- `GET /notifications` - 获取通知
- `PUT /notifications/{id}/read` - 标记已读

### 5. BMI 计算测试

#### 5.1 BMI 计算/记录测试
**测试文件**: `test/bmi/bmi_test.dart`

**测试用例**:
- ✅ BMI 计算
- ✅ 保存 BMI 记录
- ✅ 获取 BMI 历史记录
- ✅ BMI 统计信息
- ✅ 数据验证

**API 端点**:
- `POST /bmi/calculate` - 计算 BMI
- `POST /bmi/records` - 保存记录
- `GET /bmi/records` - 获取记录
- `GET /bmi/stats` - 获取统计

**测试步骤**:
```dart
testWidgets('BMI 计算功能', (WidgetTester tester) async {
  // 1. 模拟 BMI 计算 API
  when(mockApiService.post('/bmi/calculate', data: anyNamed('data')))
      .thenAnswer((_) async => Response(
        data: {
          'data': {
            'bmi': 22.5,
            'category': '正常',
            'recommendation': '保持当前体重',
            'ideal_weight_min': 60.0,
            'ideal_weight_max': 70.0
          }
        },
        statusCode: 200,
      ));

  // 2. 构建 BMI 计算页面
  await tester.pumpWidget(createTestWidget(BMICalculatorPage()));

  // 3. 输入身高体重
  await tester.enterText(find.byKey(Key('height_field')), '175');
  await tester.enterText(find.byKey(Key('weight_field')), '70');
  await tester.enterText(find.byKey(Key('age_field')), '25');

  // 4. 选择性别
  await tester.tap(find.text('男'));
  await tester.pumpAndSettle();

  // 5. 点击计算
  await tester.tap(find.text('计算 BMI'));
  await tester.pumpAndSettle();

  // 6. 验证结果
  verify(mockApiService.post('/bmi/calculate', data: anyNamed('data'))).called(1);
  expect(find.text('BMI: 22.5'), findsOneWidget);
  expect(find.text('正常'), findsOneWidget);
});
```

## 🔧 集成测试

### 1. 端到端用户流程测试

#### 1.1 完整用户注册到使用流程
**测试文件**: `test/integration/user_flow_test.dart`

**测试场景**:
1. 用户注册
2. 用户登录
3. 查看今日训练计划
4. 开始训练
5. 完成训练
6. 发布训练动态
7. 查看社区动态
8. 计算 BMI
9. 查看个人资料

#### 1.2 社区互动流程测试
**测试文件**: `test/integration/community_flow_test.dart`

**测试场景**:
1. 浏览社区动态
2. 点赞动态
3. 评论动态
4. 发布自己的动态
5. 参与挑战
6. 查看挑战排行榜

### 2. API 集成测试

#### 2.1 网络错误处理测试
**测试文件**: `test/integration/network_error_test.dart`

**测试场景**:
- 网络连接失败
- 服务器错误 (500)
- 认证失败 (401)
- 请求超时
- 数据解析错误

#### 2.2 状态管理测试
**测试文件**: `test/integration/state_management_test.dart`

**测试场景**:
- Provider 状态更新
- 状态持久化
- 状态重置
- 多 Provider 协作

## 📊 性能测试

### 1. 加载性能测试
**测试文件**: `test/performance/loading_test.dart`

**测试指标**:
- 页面加载时间
- API 响应时间
- 内存使用情况
- 电池消耗

### 2. 并发测试
**测试文件**: `test/performance/concurrent_test.dart`

**测试场景**:
- 多个 API 同时调用
- 大量数据加载
- 频繁状态更新

## 🛠️ 测试工具和配置

### 1. 测试依赖
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.2
  build_runner: ^2.4.7
  http: ^1.1.0
  integration_test:
    sdk: flutter
```

### 2. Mock 服务配置
```dart
// test/mocks/mock_api_service.dart
@GenerateMocks([ApiService])
void main() {}

// 使用 Mockito 生成 Mock 类
// flutter packages pub run build_runner build
```

### 3. 测试数据
```dart
// test/fixtures/test_data.dart
class TestData {
  static const Map<String, dynamic> mockUserJson = {
    'id': 1,
    'username': 'testuser',
    'email': 'test@example.com',
    'first_name': 'Test',
    'last_name': 'User',
    'avatar': null,
    'bio': null,
    'created_at': '2024-01-01T00:00:00Z',
    'updated_at': '2024-01-01T00:00:00Z',
  };

  static const Map<String, dynamic> mockWorkoutJson = {
    'id': 1,
    'name': '胸肌训练',
    'type': '力量训练',
    'duration': 45,
    'calories': 350,
    'difficulty': '中等',
    'notes': null,
    'rating': 4.5,
    'created_at': '2024-01-01T10:30:00Z',
    'exercises': [],
  };
}
```

## 📈 测试覆盖率目标

- **单元测试覆盖率**: ≥ 80%
- **集成测试覆盖率**: ≥ 70%
- **API 调用覆盖率**: 100%
- **关键用户流程覆盖率**: 100%

## 🚀 测试执行

### 1. 运行所有测试
```bash
flutter test
```

### 2. 运行特定测试
```bash
# 运行认证测试
flutter test test/auth/

# 运行训练功能测试
flutter test test/training/

# 运行社区功能测试
flutter test test/community/
```

### 3. 生成测试覆盖率报告
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### 4. 运行集成测试
```bash
flutter test integration_test/
```

## 📝 测试报告

### 1. 测试结果格式
- 测试用例总数
- 通过/失败数量
- 覆盖率百分比
- 性能指标
- 错误日志

### 2. 持续集成
- GitHub Actions 自动测试
- 测试失败时阻止合并
- 定期生成测试报告

## 🔍 测试验证清单

### API 调用验证
- [ ] 所有 API 端点正确映射
- [ ] 请求参数格式正确
- [ ] 响应数据正确解析
- [ ] 错误状态码处理
- [ ] Token 自动添加

### 状态管理验证
- [ ] Provider 状态正确更新
- [ ] 状态变化触发 UI 重建
- [ ] 状态持久化工作正常
- [ ] 多 Provider 协作正常

### UI 交互验证
- [ ] 按钮点击触发正确 API
- [ ] 表单提交数据正确
- [ ] 加载状态显示正确
- [ ] 错误提示显示正确
- [ ] 成功反馈显示正确

### 数据流验证
- [ ] API 响应 → 模型转换
- [ ] 模型数据 → Provider 状态
- [ ] Provider 状态 → UI 显示
- [ ] 用户操作 → API 调用

## 📋 测试维护

### 1. 测试数据更新
- 定期更新 Mock 数据
- 保持与 API 响应格式同步
- 添加新的测试场景

### 2. 测试用例维护
- 新增功能时添加对应测试
- 修复 Bug 时添加回归测试
- 定期审查和优化测试用例

### 3. 测试环境管理
- 开发环境测试配置
- 测试环境数据准备
- 生产环境测试验证

---

## 📞 测试支持

如有测试相关问题，请联系：
- **测试负责人**: FitTracker 开发团队
- **测试文档**: 项目内 `test/` 目录
- **测试工具**: Flutter Test + Mockito
- **问题反馈**: GitHub Issues

---

*测试计划最后更新: 2024年12月*
*版本: v1.0.0*
*维护者: FitTracker 测试团队*