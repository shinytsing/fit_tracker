import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';

import 'package:fittracker/core/models/models.dart';
import 'package:fittracker/core/services/api_services.dart';
import 'package:fittracker/core/providers/providers.dart';
import 'package:fittracker/features/auth/pages/login_page.dart';
import 'package:fittracker/features/test/pages/test_api_page.dart';

// 生成 Mock 类
@GenerateMocks([AuthApiService, UserApiService, WorkoutApiService, BMIApiService, CommunityApiService, CheckinApiService, NutritionApiService])
import 'widget_test.mocks.dart';

void main() {
  group('LoginPage Widget Tests', () {
    testWidgets('LoginPage 应该显示登录表单', (WidgetTester tester) async {
      // 创建 Mock 服务
      final mockAuthApiService = MockAuthApiService();
      
      // 设置 Provider
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authApiServiceProvider.overrideWithValue(mockAuthApiService),
          ],
          child: MaterialApp(
            home: LoginPage(),
          ),
        ),
      );
      
      // 验证登录表单元素存在
      expect(find.text('登录'), findsOneWidget);
      expect(find.text('邮箱'), findsOneWidget);
      expect(find.text('密码'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
    
    testWidgets('LoginPage 应该验证表单输入', (WidgetTester tester) async {
      final mockAuthApiService = MockAuthApiService();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authApiServiceProvider.overrideWithValue(mockAuthApiService),
          ],
          child: MaterialApp(
            home: LoginPage(),
          ),
        ),
      );
      
      // 尝试提交空表单
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      // 验证错误消息
      expect(find.text('请输入邮箱'), findsOneWidget);
      expect(find.text('请输入密码'), findsOneWidget);
    });
    
    testWidgets('LoginPage 应该处理登录成功', (WidgetTester tester) async {
      final mockAuthApiService = MockAuthApiService();
      
      // 设置 Mock 响应
      when(mockAuthApiService.login(any)).thenAnswer(
        (_) async => AuthResponse(
          message: 'Login successful',
          token: 'test-token',
          user: User(
            id: 1,
            username: 'testuser',
            email: 'test@example.com',
          ),
        ),
      );
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authApiServiceProvider.overrideWithValue(mockAuthApiService),
          ],
          child: MaterialApp(
            home: LoginPage(),
          ),
        ),
      );
      
      // 输入邮箱和密码
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      
      // 提交表单
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      // 验证 API 调用
      verify(mockAuthApiService.login({
        'email': 'test@example.com',
        'password': 'password123',
      })).called(1);
    });
    
    testWidgets('LoginPage 应该处理登录失败', (WidgetTester tester) async {
      final mockAuthApiService = MockAuthApiService();
      
      // 设置 Mock 异常
      when(mockAuthApiService.login(any)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/login'),
          response: Response(
            requestOptions: RequestOptions(path: '/auth/login'),
            statusCode: 401,
            data: {'error': 'Invalid credentials'},
          ),
        ),
      );
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authApiServiceProvider.overrideWithValue(mockAuthApiService),
          ],
          child: MaterialApp(
            home: LoginPage(),
          ),
        ),
      );
      
      // 输入邮箱和密码
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'wrongpassword');
      
      // 提交表单
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      // 验证错误处理
      verify(mockAuthApiService.login(any)).called(1);
    });
  });
  
  group('TestApiPage Widget Tests', () {
    testWidgets('TestApiPage 应该显示测试按钮', (WidgetTester tester) async {
      final mockUserApiService = MockUserApiService();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userApiServiceProvider.overrideWithValue(mockUserApiService),
          ],
          child: MaterialApp(
            home: TestApiPage(),
          ),
        ),
      );
      
      // 验证测试按钮存在
      expect(find.text('Fetch User Profile'), findsOneWidget);
      expect(find.text('No data yet'), findsOneWidget);
    });
    
    testWidgets('TestApiPage 应该处理 API 调用成功', (WidgetTester tester) async {
      final mockUserApiService = MockUserApiService();
      
      // 设置 Mock 响应
      when(mockUserApiService.getProfile()).thenAnswer(
        (_) async => User(
          id: 1,
          username: 'testuser',
          email: 'test@example.com',
        ),
      );
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userApiServiceProvider.overrideWithValue(mockUserApiService),
          ],
          child: MaterialApp(
            home: TestApiPage(),
          ),
        ),
      );
      
      // 点击测试按钮
      await tester.tap(find.text('Fetch User Profile'));
      await tester.pump();
      
      // 验证 API 调用
      verify(mockUserApiService.getProfile()).called(1);
      
      // 验证响应显示
      expect(find.text('Profile: testuser, test@example.com'), findsOneWidget);
    });
    
    testWidgets('TestApiPage 应该处理 API 调用失败', (WidgetTester tester) async {
      final mockUserApiService = MockUserApiService();
      
      // 设置 Mock 异常
      when(mockUserApiService.getProfile()).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/users/profile'),
          response: Response(
            requestOptions: RequestOptions(path: '/users/profile'),
            statusCode: 401,
            data: {'error': 'Unauthorized'},
          ),
        ),
      );
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userApiServiceProvider.overrideWithValue(mockUserApiService),
          ],
          child: MaterialApp(
            home: TestApiPage(),
          ),
        ),
      );
      
      // 点击测试按钮
      await tester.tap(find.text('Fetch User Profile'));
      await tester.pump();
      
      // 验证 API 调用
      verify(mockUserApiService.getProfile()).called(1);
      
      // 验证错误显示
      expect(find.textContaining('Error fetching profile'), findsOneWidget);
    });
  });
  
  group('BMI Calculation Tests', () {
    testWidgets('BMI 计算应该显示正确的结果', (WidgetTester tester) async {
      final mockBMIApiService = MockBMIApiService();
      
      // 设置 Mock 响应
      when(mockBMIApiService.calculateBMI(any)).thenAnswer(
        (_) async => BMIResponse(
          bmi: 22.86,
          category: '正常',
          idealWeight: IdealWeight(min: 60.0, max: 80.0),
          bodyFat: 15.0,
          bmr: 1800.0,
          tdee: 2790.0,
        ),
      );
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bmiApiServiceProvider.overrideWithValue(mockBMIApiService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: '身高 (cm)'),
                    onChanged: (value) {},
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '体重 (kg)'),
                    onChanged: (value) {},
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // 模拟 BMI 计算
                      final response = await mockBMIApiService.calculateBMI({
                        'height': 175.0,
                        'weight': 70.0,
                        'age': 25,
                        'gender': 'male',
                      });
                      // 验证结果
                      expect(response.bmi, 22.86);
                      expect(response.category, '正常');
                    },
                    child: Text('计算 BMI'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      
      // 输入身高和体重
      await tester.enterText(find.byType(TextFormField).first, '175');
      await tester.enterText(find.byType(TextFormField).last, '70');
      
      // 点击计算按钮
      await tester.tap(find.text('计算 BMI'));
      await tester.pump();
      
      // 验证 API 调用
      verify(mockBMIApiService.calculateBMI({
        'height': 175.0,
        'weight': 70.0,
        'age': 25,
        'gender': 'male',
      })).called(1);
    });
  });
  
  group('Workout Tests', () {
    testWidgets('训练记录应该正确显示', (WidgetTester tester) async {
      final mockWorkoutApiService = MockWorkoutApiService();
      
      // 设置 Mock 响应
      when(mockWorkoutApiService.getWorkouts(any)).thenAnswer(
        (_) async => [
          Workout(
            id: 1,
            userId: 1,
            name: '胸肌训练',
            type: '力量训练',
            duration: 60,
            calories: 300,
            difficulty: '中级',
            notes: '训练效果很好',
            rating: 4.5,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
      );
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutApiServiceProvider.overrideWithValue(mockWorkoutApiService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ListView(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final workouts = await mockWorkoutApiService.getWorkouts({
                        'page': 1,
                        'limit': 10,
                      });
                      // 验证结果
                      expect(workouts.length, 1);
                      expect(workouts.first.name, '胸肌训练');
                      expect(workouts.first.type, '力量训练');
                    },
                    child: Text('获取训练记录'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      
      // 点击获取按钮
      await tester.tap(find.text('获取训练记录'));
      await tester.pump();
      
      // 验证 API 调用
      verify(mockWorkoutApiService.getWorkouts({
        'page': 1,
        'limit': 10,
      })).called(1);
    });
  });
  
  group('Community Tests', () {
    testWidgets('社区动态应该正确显示', (WidgetTester tester) async {
      final mockCommunityApiService = MockCommunityApiService();
      
      // 设置 Mock 响应
      when(mockCommunityApiService.getPosts(any)).thenAnswer(
        (_) async => [
          Post(
            id: 1,
            userId: 1,
            content: '今天完成了胸肌训练，感觉很好！',
            type: '训练',
            isPublic: true,
            likesCount: 5,
            commentsCount: 2,
            sharesCount: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
      );
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            communityApiServiceProvider.overrideWithValue(mockCommunityApiService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ListView(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final posts = await mockCommunityApiService.getPosts({
                        'page': 1,
                        'limit': 10,
                      });
                      // 验证结果
                      expect(posts.length, 1);
                      expect(posts.first.content, '今天完成了胸肌训练，感觉很好！');
                      expect(posts.first.type, '训练');
                      expect(posts.first.isPublic, true);
                    },
                    child: Text('获取动态'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      
      // 点击获取按钮
      await tester.tap(find.text('获取动态'));
      await tester.pump();
      
      // 验证 API 调用
      verify(mockCommunityApiService.getPosts({
        'page': 1,
        'limit': 10,
      })).called(1);
    });
  });
  
  group('Checkin Tests', () {
    testWidgets('签到应该正确显示', (WidgetTester tester) async {
      final mockCheckinApiService = MockCheckinApiService();
      
      // 设置 Mock 响应
      when(mockCheckinApiService.getCheckins(any)).thenAnswer(
        (_) async => [
          Checkin(
            id: 1,
            userId: 1,
            date: DateTime.now(),
            type: '训练',
            notes: '完成了今天的训练',
            mood: '开心',
            energy: 8,
            motivation: 9,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
      );
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            checkinApiServiceProvider.overrideWithValue(mockCheckinApiService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ListView(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final checkins = await mockCheckinApiService.getCheckins({
                        'page': 1,
                        'limit': 10,
                      });
                      // 验证结果
                      expect(checkins.length, 1);
                      expect(checkins.first.type, '训练');
                      expect(checkins.first.notes, '完成了今天的训练');
                      expect(checkins.first.mood, '开心');
                      expect(checkins.first.energy, 8);
                      expect(checkins.first.motivation, 9);
                    },
                    child: Text('获取签到记录'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      
      // 点击获取按钮
      await tester.tap(find.text('获取签到记录'));
      await tester.pump();
      
      // 验证 API 调用
      verify(mockCheckinApiService.getCheckins({
        'page': 1,
        'limit': 10,
      })).called(1);
    });
  });
  
  group('Nutrition Tests', () {
    testWidgets('营养计算应该正确显示', (WidgetTester tester) async {
      final mockNutritionApiService = MockNutritionApiService();
      
      // 设置 Mock 响应
      when(mockNutritionApiService.calculateNutrition(any)).thenAnswer(
        (_) async => NutritionResponse(
          foodName: '鸡胸肉',
          quantity: 100.0,
          calories: 165.0,
          protein: 31.0,
          carbs: 0.0,
          fat: 3.6,
          fiber: 0.0,
          sugar: 0.0,
          sodium: 74.0,
        ),
      );
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            nutritionApiServiceProvider.overrideWithValue(mockNutritionApiService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: '食物名称'),
                    onChanged: (value) {},
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '数量'),
                    onChanged: (value) {},
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final response = await mockNutritionApiService.calculateNutrition({
                        'food_name': '鸡胸肉',
                        'quantity': 100.0,
                        'unit': 'g',
                      });
                      // 验证结果
                      expect(response.foodName, '鸡胸肉');
                      expect(response.quantity, 100.0);
                      expect(response.calories, 165.0);
                      expect(response.protein, 31.0);
                      expect(response.carbs, 0.0);
                      expect(response.fat, 3.6);
                    },
                    child: Text('计算营养'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      
      // 输入食物名称和数量
      await tester.enterText(find.byType(TextFormField).first, '鸡胸肉');
      await tester.enterText(find.byType(TextFormField).last, '100');
      
      // 点击计算按钮
      await tester.tap(find.text('计算营养'));
      await tester.pump();
      
      // 验证 API 调用
      verify(mockNutritionApiService.calculateNutrition({
        'food_name': '鸡胸肉',
        'quantity': 100.0,
        'unit': 'g',
      })).called(1);
    });
  });
}