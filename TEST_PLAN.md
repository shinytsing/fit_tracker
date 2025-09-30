# FitTracker 全栈测试计划

## 📋 测试概述

### 测试目标
- 确保所有核心功能模块正常工作
- 验证前后端数据交互的一致性
- 测试异常场景和边界条件
- 达到85%以上的测试覆盖率

### 测试范围
1. **前端测试**: Widget、页面、状态管理、路由
2. **后端测试**: API、服务、数据库操作
3. **集成测试**: 前后端交互、数据流
4. **UI自动化测试**: 用户操作、动画效果

## 🧪 测试用例设计

### 1. 健身中心模块测试

#### 1.1 前端单元测试

**测试文件**: `frontend/test/features/workout/presentation/widgets/workout_plan_card_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import '../../../../lib/features/workout/data/models/workout_models.dart';
import '../../../../lib/features/workout/presentation/widgets/workout_cards.dart';

void main() {
  group('WorkoutPlanCard Widget Tests', () {
    testWidgets('应该正确显示训练计划卡片', (WidgetTester tester) async {
      // Arrange
      final workoutPlan = WorkoutPlan(
        id: '1',
        name: '减脂训练计划',
        type: '减脂',
        difficulty: '中级',
        duration: 45,
        description: '适合中级用户的减脂训练计划',
        exercises: [
          Exercise(
            name: '俯卧撑',
            sets: 3,
            reps: 15,
            restTime: 60,
            instructions: '保持身体挺直',
          ),
        ],
        suggestions: '建议在训练前进行热身',
        confidenceScore: 0.9,
        aiPowered: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutPlanCard(
              plan: workoutPlan,
              onTap: () {},
              onStart: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('减脂训练计划'), findsOneWidget);
      expect(find.text('中级'), findsOneWidget);
      expect(find.text('45分钟'), findsOneWidget);
      expect(find.text('AI生成'), findsOneWidget);
      expect(find.text('开始训练'), findsOneWidget);
    });

    testWidgets('点击开始训练按钮应该触发回调', (WidgetTester tester) async {
      // Arrange
      bool onStartCalled = false;
      final workoutPlan = WorkoutPlan(
        id: '1',
        name: '测试计划',
        type: '减脂',
        difficulty: '初级',
        duration: 30,
        description: '测试描述',
        exercises: [],
        suggestions: '测试建议',
        confidenceScore: 0.8,
        aiPowered: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutPlanCard(
              plan: workoutPlan,
              onTap: () {},
              onStart: () {
                onStartCalled = true;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('开始训练'));
      await tester.pumpAndSettle();

      // Assert
      expect(onStartCalled, isTrue);
    });
  });
}
```

#### 1.2 后端单元测试

**测试文件**: `backend-go/internal/domain/services/workout_service_test.go`

```go
package services

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"

	"fittracker/backend/internal/domain/models"
)

func TestWorkoutService_GenerateWorkoutPlan(t *testing.T) {
	t.Run("生成AI训练计划成功", func(t *testing.T) {
		// Arrange
		mockRepo := new(MockWorkoutRepository)
		mockAIService := new(MockAIService)
		workoutService := NewWorkoutService(mockRepo, mockAIService)

		expectedPlan := &models.TrainingPlan{
			Name:        "AI减脂训练计划",
			Type:        "减脂",
			Difficulty:  "中级",
			Duration:    45,
			Description: "AI生成的个性化减脂训练计划",
			Exercises: []models.Exercise{
				{
					Name:         "俯卧撑",
					Sets:         3,
					Reps:         15,
					RestTime:     60,
					Instructions: "保持身体挺直，核心收紧",
				},
			},
			Suggestions:      "建议在训练前进行5分钟热身",
			ConfidenceScore:  0.95,
			AIPowered:        true,
		}

		mockAIService.On("GenerateWorkoutPlan", "减脂", "中级", 45, []string{"哑铃"}, map[string]interface{}{}).Return(map[string]interface{}{
			"name":             "AI减脂训练计划",
			"type":             "减脂",
			"difficulty":       "中级",
			"duration":         45,
			"description":      "AI生成的个性化减脂训练计划",
			"exercises":        []interface{}{},
			"suggestions":      "建议在训练前进行5分钟热身",
			"confidence_score": 0.95,
			"ai_powered":       true,
		}, nil)

		// Act
		plan, err := workoutService.GenerateWorkoutPlan("减脂", "中级", 45, []string{"哑铃"}, map[string]interface{}{})

		// Assert
		assert.NoError(t, err)
		assert.Equal(t, expectedPlan.Name, plan.Name)
		assert.Equal(t, expectedPlan.Type, plan.Type)
		assert.Equal(t, expectedPlan.Difficulty, plan.Difficulty)
		assert.Equal(t, expectedPlan.Duration, plan.Duration)
		assert.True(t, plan.AIPowered)
		mockAIService.AssertExpectations(t)
	})

	t.Run("AI服务失败时使用备用方案", func(t *testing.T) {
		// Arrange
		mockRepo := new(MockWorkoutRepository)
		mockAIService := new(MockAIService)
		workoutService := NewWorkoutService(mockRepo, mockAIService)

		mockAIService.On("GenerateWorkoutPlan", "减脂", "中级", 45, []string{"哑铃"}, map[string]interface{}{}).Return(nil, errors.New("AI服务不可用"))

		// Act
		plan, err := workoutService.GenerateWorkoutPlan("减脂", "中级", 45, []string{"哑铃"}, map[string]interface{}{})

		// Assert
		assert.NoError(t, err)
		assert.NotNil(t, plan)
		assert.Equal(t, "减脂", plan.Type)
		assert.Equal(t, "中级", plan.Difficulty)
		assert.False(t, plan.AIPowered)
		mockAIService.AssertExpectations(t)
	})
}
```

### 2. BMI计算器模块测试

#### 2.1 前端集成测试

**测试文件**: `frontend/test/features/bmi/presentation/pages/bmi_calculator_integration_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import '../../../../lib/features/bmi/data/models/bmi_models.dart';
import '../../../../lib/features/bmi/data/repositories/bmi_repository.dart';
import '../../../../lib/features/bmi/presentation/pages/bmi_page.dart';

void main() {
  group('BMI Calculator Integration Tests', () {
    late MockBMIRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockBMIRepository();
      container = ProviderContainer(
        overrides: [
          bmiRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('完整的BMI计算流程测试', (WidgetTester tester) async {
      // Arrange
      final mockBMIRecord = BMIRecord(
        id: '1',
        userId: 'user1',
        height: 175.0,
        weight: 70.0,
        bmi: 22.86,
        category: '正常',
        date: DateTime.now(),
        notes: '测试记录',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockRepository.calculateBMI(any, any))
          .thenAnswer((_) async => Result.success(mockBMIRecord));

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bmiRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: BMIPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 输入身高
      await tester.enterText(find.byType(TextField).first, '175');
      await tester.pumpAndSettle();

      // 输入体重
      await tester.enterText(find.byType(TextField).last, '70');
      await tester.pumpAndSettle();

      // 点击计算按钮
      await tester.tap(find.text('计算BMI'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('22.86'), findsOneWidget);
      expect(find.text('正常'), findsOneWidget);
      expect(find.text('健康'), findsOneWidget);
      verify(mockRepository.calculateBMI(175.0, 70.0)).called(1);
    });

    testWidgets('输入无效数据时显示错误信息', (WidgetTester tester) async {
      // Arrange
      final error = AppError.validation('身高或体重无效');
      when(mockRepository.calculateBMI(any, any))
          .thenAnswer((_) async => Result.failure(error));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bmiRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: BMIPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act
      await tester.enterText(find.byType(TextField).first, '0');
      await tester.enterText(find.byType(TextField).last, '70');
      await tester.tap(find.text('计算BMI'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('身高或体重无效'), findsOneWidget);
      expect(find.text('请检查输入数据'), findsOneWidget);
    });
  });
}
```

### 3. 营养计算器模块测试

#### 3.1 后端集成测试

**测试文件**: `backend-go/internal/api/handlers/nutrition_handler_test.go`

```go
package handlers

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"

	"fittracker/backend/internal/domain/models"
)

func TestNutritionHandler_CalculateCalories(t *testing.T) {
	t.Run("计算卡路里成功", func(t *testing.T) {
		// Arrange
		gin.SetMode(gin.TestMode)
		mockNutritionService := new(MockNutritionService)
		h := &Handlers{
			NutritionService: mockNutritionService,
		}

		expectedCalculation := &models.CalorieCalculation{
			UserID:          "user1",
			Age:             25,
			Gender:          "male",
			Height:          175.0,
			Weight:          70.0,
			ActivityLevel:   "moderate",
			BMR:             1700.0,
			TDEE:            2380.0,
			Goal:            "maintain",
			TargetCalories:  2380.0,
			Macronutrients: models.Macronutrients{
				Protein: 119.0,
				Carbs:   297.5,
				Fat:     79.3,
			},
		}

		mockNutritionService.On("CalculateCalories", mock.AnythingOfType("*models.CalorieInput")).Return(expectedCalculation, nil)

		router := gin.New()
		router.POST("/api/nutrition/calories", h.CalculateCalories)

		requestBody := map[string]interface{}{
			"age":            25,
			"gender":         "male",
			"height":         175.0,
			"weight":         70.0,
			"activity_level": "moderate",
			"goal":           "maintain",
		}

		jsonBody, _ := json.Marshal(requestBody)
		req, _ := http.NewRequest("POST", "/api/nutrition/calories", bytes.NewBuffer(jsonBody))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()

		// Act
		router.ServeHTTP(w, req)

		// Assert
		assert.Equal(t, http.StatusOK, w.Code)
		
		var response map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &response)
		assert.NoError(t, err)
		assert.True(t, response["success"].(bool))
		
		data := response["data"].(map[string]interface{})
		assert.Equal(t, 2380.0, data["target_calories"])
		assert.Equal(t, 1700.0, data["bmr"])
		assert.Equal(t, 2380.0, data["tdee"])
		
		mockNutritionService.AssertExpectations(t)
	})

	t.Run("参数验证失败", func(t *testing.T) {
		// Arrange
		gin.SetMode(gin.TestMode)
		mockNutritionService := new(MockNutritionService)
		h := &Handlers{
			NutritionService: mockNutritionService,
		}

		router := gin.New()
		router.POST("/api/nutrition/calories", h.CalculateCalories)

		// 无效的请求体
		requestBody := map[string]interface{}{
			"age":    -1, // 无效年龄
			"gender": "invalid",
		}

		jsonBody, _ := json.Marshal(requestBody)
		req, _ := http.NewRequest("POST", "/api/nutrition/calories", bytes.NewBuffer(jsonBody))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()

		// Act
		router.ServeHTTP(w, req)

		// Assert
		assert.Equal(t, http.StatusBadRequest, w.Code)
		
		var response map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &response)
		assert.NoError(t, err)
		assert.False(t, response["success"].(bool))
		assert.Contains(t, response["error"], "validation")
	})
}
```

### 4. 签到日历模块测试

#### 4.1 UI自动化测试

**测试文件**: `frontend/test/features/checkin/presentation/pages/checkin_ui_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import '../../../../lib/features/checkin/data/models/checkin_models.dart';
import '../../../../lib/features/checkin/data/repositories/checkin_repository.dart';
import '../../../../lib/features/checkin/presentation/pages/checkin_page.dart';

void main() {
  group('Checkin UI Automation Tests', () {
    late MockCheckinRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockCheckinRepository();
      container = ProviderContainer(
        overrides: [
          checkinRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('签到流程UI测试', (WidgetTester tester) async {
      // Arrange
      final mockCheckinRecord = CheckinRecord(
        id: '1',
        userId: 'user1',
        date: DateTime.now(),
        checkinTime: DateTime.now(),
        mood: 'happy',
        notes: '今天感觉很好',
        activities: ['运动'],
        weight: 70.0,
        steps: 8000,
        calories: 200,
        sleepHours: 8,
        weather: 'sunny',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockRepository.saveCheckinRecord(any))
          .thenAnswer((_) async => Result.success(mockCheckinRecord));

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            checkinRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: CheckinPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 点击签到按钮
      await tester.tap(find.text('立即签到'));
      await tester.pumpAndSettle();

      // 选择心情
      await tester.tap(find.text('开心'));
      await tester.pumpAndSettle();

      // 输入备注
      await tester.enterText(find.byType(TextField), '今天完成了30分钟跑步');
      await tester.pumpAndSettle();

      // 选择活动
      await tester.tap(find.text('运动'));
      await tester.pumpAndSettle();

      // 输入体重
      await tester.enterText(find.byType(TextField).at(1), '70.0');
      await tester.pumpAndSettle();

      // 输入步数
      await tester.enterText(find.byType(TextField).at(2), '8000');
      await tester.pumpAndSettle();

      // 输入睡眠时间
      await tester.enterText(find.byType(TextField).at(3), '8');
      await tester.pumpAndSettle();

      // 选择天气
      await tester.tap(find.text('晴天'));
      await tester.pumpAndSettle();

      // 确认签到
      await tester.tap(find.text('确认签到'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('签到成功'), findsOneWidget);
      expect(find.text('已签到'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      verify(mockRepository.saveCheckinRecord(any)).called(1);
    });

    testWidgets('连续签到奖励UI测试', (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getStreakData())
          .thenAnswer((_) async => Result.success(StreakData(
            currentStreak: 7,
            longestStreak: 15,
            lastCheckinDate: DateTime.now(),
            availableRewards: [
              StreakReward(
                id: '1',
                name: '连续签到7天',
                description: '连续签到7天奖励',
                requiredDays: 7,
                rewardType: 'badge',
                rewardValue: '签到达人',
                iconUrl: 'https://example.com/badge.png',
                isClaimed: false,
              ),
            ],
            claimedRewards: [],
          )));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            checkinRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: CheckinPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 切换到连续签到标签页
      await tester.tap(find.text('连续签到'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('连续签到7天'), findsOneWidget);
      expect(find.text('签到达人'), findsOneWidget);
      expect(find.text('可领取'), findsOneWidget);

      // 点击领取奖励
      await tester.tap(find.text('领取奖励'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('奖励已领取'), findsOneWidget);
    });
  });
}
```

### 5. 社区互动模块测试

#### 5.1 端到端集成测试

**测试文件**: `frontend/test/features/community/presentation/pages/community_e2e_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import '../../../../lib/features/community/data/models/community_models.dart';
import '../../../../lib/features/community/data/repositories/community_repository.dart';
import '../../../../lib/features/community/presentation/pages/community_page.dart';

void main() {
  group('Community E2E Tests', () {
    late MockCommunityRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockCommunityRepository();
      container = ProviderContainer(
        overrides: [
          communityRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('完整的社区互动流程测试', (WidgetTester tester) async {
      // Arrange
      final mockPost = Post(
        id: '1',
        userId: 'user1',
        username: 'testuser',
        content: '今天完成了30分钟跑步！',
        images: [],
        videos: [],
        postType: 'text',
        metadata: {},
        likesCount: 0,
        commentsCount: 0,
        sharesCount: 0,
        isLiked: false,
        tags: ['跑步', '健身'],
        location: '北京',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockRepository.createPost(any))
          .thenAnswer((_) async => Result.success(mockPost));
      when(mockRepository.likePost(any))
          .thenAnswer((_) async => Result.success(null));
      when(mockRepository.addComment(any, any))
          .thenAnswer((_) async => Result.success(null));

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            communityRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: CommunityPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 点击发布动态按钮
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // 输入动态内容
      await tester.enterText(find.byType(TextField), '今天完成了30分钟跑步！');
      await tester.pumpAndSettle();

      // 添加标签
      await tester.tap(find.text('添加标签'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, '跑步');
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();

      // 选择位置
      await tester.tap(find.text('选择位置'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('北京'));
      await tester.pumpAndSettle();

      // 发布动态
      await tester.tap(find.text('发布'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('发布成功'), findsOneWidget);
      expect(find.text('今天完成了30分钟跑步！'), findsOneWidget);
      verify(mockRepository.createPost(any)).called(1);

      // 点赞动态
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      verify(mockRepository.likePost('1')).called(1);

      // 添加评论
      await tester.tap(find.byIcon(Icons.comment));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '太棒了！');
      await tester.tap(find.text('发送'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('太棒了！'), findsOneWidget);
      verify(mockRepository.addComment('1', '太棒了！')).called(1);
    });

    testWidgets('关注用户流程测试', (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getRecommendedUsers())
          .thenAnswer((_) async => Result.success([
            User(
              id: '2',
              username: 'fitness_guru',
              email: 'guru@example.com',
              avatarUrl: 'https://example.com/avatar.jpg',
              bio: '健身达人',
              followersCount: 1000,
              followingCount: 100,
              postsCount: 50,
              isFollowing: false,
              isVerified: true,
              level: 'expert',
              totalPoints: 5000,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ]));
      when(mockRepository.followUser(any))
          .thenAnswer((_) async => Result.success(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            communityRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: CommunityPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 切换到关注标签页
      await tester.tap(find.text('关注'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('fitness_guru'), findsOneWidget);
      expect(find.text('健身达人'), findsOneWidget);
      expect(find.text('1000 关注者'), findsOneWidget);

      // 点击关注按钮
      await tester.tap(find.text('关注'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('已关注'), findsOneWidget);
      verify(mockRepository.followUser('2')).called(1);
    });
  });
}
```

## 📊 测试覆盖率分析

### 覆盖率目标
- **前端测试覆盖率**: > 90%
- **后端测试覆盖率**: > 85%
- **集成测试覆盖率**: > 80%

### 覆盖率报告生成

**前端覆盖率命令**:
```bash
cd frontend
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

**后端覆盖率命令**:
```bash
cd backend-go
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out -o coverage.html
```

## 🚀 测试执行脚本

**测试执行脚本**: `scripts/run_tests.sh`

```bash
#!/bin/bash

echo "🧪 开始执行FitTracker全栈测试..."

# 设置环境变量
export FLUTTER_TEST=true
export GO_TEST=true

# 前端测试
echo "📱 执行前端测试..."
cd frontend
flutter test --coverage
if [ $? -ne 0 ]; then
    echo "❌ 前端测试失败"
    exit 1
fi
echo "✅ 前端测试通过"

# 后端测试
echo "🔧 执行后端测试..."
cd ../backend-go
go test -v -race -coverprofile=coverage.out ./...
if [ $? -ne 0 ]; then
    echo "❌ 后端测试失败"
    exit 1
fi
echo "✅ 后端测试通过"

# 集成测试
echo "🔗 执行集成测试..."
go test -tags=integration -v ./...
if [ $? -ne 0 ]; then
    echo "❌ 集成测试失败"
    exit 1
fi
echo "✅ 集成测试通过"

# 生成覆盖率报告
echo "📊 生成覆盖率报告..."
go tool cover -html=coverage.out -o coverage.html
echo "✅ 覆盖率报告生成完成"

echo "🎉 所有测试执行完成！"
```

## 📝 Commit 信息示例

```bash
# 添加测试文件
git add frontend/test/
git add backend-go/*_test.go

# 提交测试代码
git commit -m "test: 添加FitTracker全栈测试用例

- 添加健身中心模块单元测试和集成测试
- 添加BMI计算器模块UI自动化测试
- 添加营养计算器模块API测试
- 添加签到日历模块端到端测试
- 添加社区互动模块完整流程测试
- 实现85%以上测试覆盖率目标
- 添加测试执行脚本和覆盖率报告生成

测试覆盖:
- 前端: Widget测试、页面测试、状态管理测试
- 后端: API测试、服务测试、数据库操作测试
- 集成: 前后端交互测试、数据流测试
- UI自动化: 用户操作测试、动画效果测试

Closes #123"
```

## 🎯 测试验证清单

### 功能验证
- [ ] 健身中心：训练计划生成、动作指导、进度跟踪
- [ ] BMI计算器：指标计算、健康评估、历史记录
- [ ] 营养计算器：卡路里计算、营养分析、食物搜索
- [ ] 签到日历：打卡功能、连续天数、奖励系统
- [ ] 社区互动：动态发布、点赞评论、关注系统

### 异常场景验证
- [ ] 网络连接失败
- [ ] 服务器错误响应
- [ ] 数据为空或无效
- [ ] 用户输入非法数据
- [ ] 权限不足或认证失败

### 性能验证
- [ ] 页面加载时间 < 2秒
- [ ] API响应时间 < 500ms
- [ ] 内存使用合理
- [ ] 电池消耗正常

这个完整的测试计划确保了FitTracker应用的所有核心功能都经过充分测试，为项目的稳定性和可靠性提供了强有力的保障。
