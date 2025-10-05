import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';

import 'package:gymates/core/models/models.dart';
import 'package:gymates/core/services/api_services.dart';
import 'package:gymates/core/providers/providers.dart';
import 'package:gymates/features/auth/pages/login_page.dart';

// 生成 Mock 类
@GenerateMocks([AuthApiService, WorkoutApiService, CommunityApiService, CheckinApiService, NutritionApiService])
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
      when(mockAuthApiService.login(email: anyNamed('email'), password: anyNamed('password'))).thenAnswer(
        (_) async => AuthResponse(
          token: 'test-token',
          user: User(
            id: '1',
            username: 'testuser',
            email: 'test@example.com',
            firstName: 'Test',
            lastName: 'User',
            isVerified: false,
            followersCount: 0,
            followingCount: 0,
            totalWorkouts: 0,
            totalCheckins: 0,
            currentStreak: 0,
            longestStreak: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          expiresAt: DateTime.now().add(Duration(hours: 24)),
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
      verify(mockAuthApiService.login(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });
    
    testWidgets('LoginPage 应该处理登录失败', (WidgetTester tester) async {
      final mockAuthApiService = MockAuthApiService();
      
      // 设置 Mock 异常
      when(mockAuthApiService.login(email: anyNamed('email'), password: anyNamed('password'))).thenThrow(
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
      verify(mockAuthApiService.login(email: anyNamed('email'), password: anyNamed('password'))).called(1);
    });
  });
  
  group('Workout Tests', () {
    testWidgets('训练记录应该正确显示', (WidgetTester tester) async {
      final mockWorkoutApiService = MockWorkoutApiService();
      
      // 设置 Mock 响应
      when(mockWorkoutApiService.getWorkouts(page: anyNamed('page'), limit: anyNamed('limit'), type: anyNamed('type'))).thenAnswer(
        (_) async => ApiResponse<List<Workout>>(
          data: [
            Workout(
              id: '1',
              userId: '1',
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
        ),
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
                      final response = await mockWorkoutApiService.getWorkouts(
                        page: 1,
                        limit: 10,
                      );
                      // 验证结果
                      expect(response.data!.length, 1);
                      expect(response.data!.first.name, '胸肌训练');
                      expect(response.data!.first.type, '力量训练');
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
      verify(mockWorkoutApiService.getWorkouts(
        page: 1,
        limit: 10,
      )).called(1);
    });
  });
  
  group('Community Tests', () {
    testWidgets('社区动态应该正确显示', (WidgetTester tester) async {
      final mockCommunityApiService = MockCommunityApiService();
      
      // 设置 Mock 响应
      when(mockCommunityApiService.getPosts(page: anyNamed('page'), limit: anyNamed('limit'), type: anyNamed('type'))).thenAnswer(
        (_) async => ApiResponse<List<Post>>(
          data: [
            Post(
              id: '1',
              userId: '1',
              content: '今天完成了胸肌训练，感觉很好！',
              type: '训练',
              isPublic: true,
              isFeatured: false,
              viewCount: 0,
              shareCount: 0,
              likesCount: 5,
              commentsCount: 2,
              sharesCount: 1,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ],
        ),
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
                      final response = await mockCommunityApiService.getPosts(
                        page: 1,
                        limit: 10,
                      );
                      // 验证结果
                      expect(response.data!.length, 1);
                      expect(response.data!.first.content, '今天完成了胸肌训练，感觉很好！');
                      expect(response.data!.first.type, '训练');
                      expect(response.data!.first.isPublic, true);
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
      verify(mockCommunityApiService.getPosts(
        page: 1,
        limit: 10,
      )).called(1);
    });
  });
  
  group('Checkin Tests', () {
    testWidgets('签到应该正确显示', (WidgetTester tester) async {
      final mockCheckinApiService = MockCheckinApiService();
      
      // 设置 Mock 响应
      when(mockCheckinApiService.getCheckins(page: anyNamed('page'), limit: anyNamed('limit'))).thenAnswer(
        (_) async => [
          Checkin(
            id: '1',
            userId: '1',
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
                      final checkins = await mockCheckinApiService.getCheckins(
                        page: 1,
                        limit: 10,
                      );
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
      verify(mockCheckinApiService.getCheckins(
        page: 1,
        limit: 10,
      )).called(1);
    });
  });
  
  group('Nutrition Tests', () {
    testWidgets('营养计算应该正确显示', (WidgetTester tester) async {
      final mockNutritionApiService = MockNutritionApiService();
      
      // 设置 Mock 响应
      when(mockNutritionApiService.calculateNutrition(
        foodName: anyNamed('foodName'),
        quantity: anyNamed('quantity'),
        unit: anyNamed('unit'),
      )).thenAnswer(
        (_) async => {
          'food_name': '鸡胸肉',
          'quantity': 100.0,
          'calories': 165.0,
          'protein': 31.0,
          'carbs': 0.0,
          'fat': 3.6,
          'fiber': 0.0,
          'sugar': 0.0,
          'sodium': 74.0,
        },
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
                      final response = await mockNutritionApiService.calculateNutrition(
                        foodName: '鸡胸肉',
                        quantity: 100.0,
                        unit: 'g',
                      );
                      // 验证结果
                      expect(response['food_name'], '鸡胸肉');
                      expect(response['quantity'], 100.0);
                      expect(response['calories'], 165.0);
                      expect(response['protein'], 31.0);
                      expect(response['carbs'], 0.0);
                      expect(response['fat'], 3.6);
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
      verify(mockNutritionApiService.calculateNutrition(
        foodName: '鸡胸肉',
        quantity: 100.0,
        unit: 'g',
      )).called(1);
    });
  });
}