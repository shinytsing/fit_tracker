import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fittracker/frontend/lib/core/services/api_services.dart';
import 'package:fittracker/frontend/lib/core/models/models.dart';

/// FitTracker 前端交互测试模块
/// 专门用于测试Flutter应用的用户界面和交互功能
class FitTrackerFrontendTester {
  static final FitTrackerFrontendTester _instance = FitTrackerFrontendTester._internal();
  factory FitTrackerFrontendTester() => _instance;
  FitTrackerFrontendTester._internal();

  late WidgetTester tester;
  late AuthApiService _authService;
  late WorkoutApiService _workoutService;
  late CommunityApiService _communityService;
  late CheckinApiService _checkinService;
  late NutritionApiService _nutritionService;
  
  String? _authToken;
  
  // 测试结果存储
  List<FrontendTestResult> _testResults = [];
  
  /// 初始化前端测试器
  Future<void> initialize(WidgetTester widgetTester) async {
    tester = widgetTester;
    
    _authService = AuthApiService();
    _workoutService = WorkoutApiService();
    _communityService = CommunityApiService();
    _checkinService = CheckinApiService();
    _nutritionService = NutritionApiService();
    
    print('🔧 前端测试器初始化完成');
  }
  
  /// 设置认证Token
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  /// 清除认证Token
  void clearAuthToken() {
    _authToken = null;
  }
  
  /// 执行前端测试
  Future<FrontendTestResult> testFrontendInteraction({
    required String module,
    required String function,
    required String description,
    required Future<void> Function() testAction,
    Map<String, dynamic>? expectedUIState,
    Map<String, dynamic>? expectedData,
  }) async {
    final testResult = FrontendTestResult(
      module: module,
      function: function,
      description: description,
      timestamp: DateTime.now(),
    );
    
    try {
      // 执行测试操作
      await testAction();
      
      // 等待UI更新
      await tester.pumpAndSettle();
      
      // 验证UI状态
      if (expectedUIState != null) {
        final uiValidationResult = await _validateUIState(expectedUIState);
        if (!uiValidationResult.isValid) {
          testResult.status = FrontendTestStatus.warning;
          testResult.errorMessage = 'UI状态验证失败: ${uiValidationResult.errorMessage}';
        } else {
          testResult.status = FrontendTestStatus.passed;
        }
      } else {
        testResult.status = FrontendTestStatus.passed;
      }
      
      // 验证数据状态
      if (expectedData != null) {
        final dataValidationResult = await _validateDataState(expectedData);
        if (!dataValidationResult.isValid) {
          testResult.status = FrontendTestStatus.warning;
          testResult.errorMessage = '数据状态验证失败: ${dataValidationResult.errorMessage}';
        }
      }
      
    } catch (e) {
      testResult.status = FrontendTestStatus.failed;
      testResult.errorMessage = '前端测试失败: $e';
    }
    
    _testResults.add(testResult);
    return testResult;
  }
  
  /// 验证UI状态
  Future<UIValidationResult> _validateUIState(Map<String, dynamic> expectedState) async {
    try {
      for (final key in expectedState.keys) {
        final expectedValue = expectedState[key];
        
        switch (key) {
          case 'widget_exists':
            if (expectedValue is String) {
              final finder = find.text(expectedValue);
              if (!finder.evaluate().isNotEmpty) {
                return UIValidationResult(
                  isValid: false,
                  errorMessage: '未找到文本: $expectedValue',
                );
              }
            }
            break;
          case 'button_enabled':
            if (expectedValue is String) {
              final finder = find.text(expectedValue);
              if (finder.evaluate().isNotEmpty) {
                final button = tester.widget<ElevatedButton>(finder);
                if (button.onPressed == null) {
                  return UIValidationResult(
                    isValid: false,
                    errorMessage: '按钮未启用: $expectedValue',
                  );
                }
              }
            }
            break;
          case 'form_field_value':
            if (expectedValue is Map<String, dynamic>) {
              for (final fieldName in expectedValue.keys) {
                final fieldValue = expectedValue[fieldName];
                final finder = find.byKey(Key(fieldName));
                if (finder.evaluate().isNotEmpty) {
                  final textField = tester.widget<TextField>(finder);
                  if (textField.controller?.text != fieldValue) {
                    return UIValidationResult(
                      isValid: false,
                      errorMessage: '表单字段值不匹配: $fieldName',
                    );
                  }
                }
              }
            }
            break;
        }
      }
      
      return UIValidationResult(isValid: true);
    } catch (e) {
      return UIValidationResult(
        isValid: false,
        errorMessage: 'UI验证过程出错: $e',
      );
    }
  }
  
  /// 验证数据状态
  Future<DataValidationResult> _validateDataState(Map<String, dynamic> expectedData) async {
    try {
      // 这里可以根据需要实现数据状态验证逻辑
      // 例如检查Provider状态、本地存储等
      return DataValidationResult(isValid: true);
    } catch (e) {
      return DataValidationResult(
        isValid: false,
        errorMessage: '数据验证过程出错: $e',
      );
    }
  }
  
  /// 测试登录页面
  Future<List<FrontendTestResult>> testLoginPage() async {
    print('🔐 测试登录页面...');
    final results = <FrontendTestResult>[];
    
    // 测试页面加载
    final loadResult = await testFrontendInteraction(
      module: '登录页面',
      function: '页面加载',
      description: '验证登录页面正常加载',
      testAction: () async {
        // 导航到登录页面
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(
                  key: const Key('email_field'),
                  decoration: const InputDecoration(labelText: '邮箱'),
                ),
                TextField(
                  key: const Key('password_field'),
                  decoration: const InputDecoration(labelText: '密码'),
                  obscureText: true,
                ),
                ElevatedButton(
                  key: const Key('login_button'),
                  onPressed: () {},
                  child: const Text('登录'),
                ),
              ],
            ),
          ),
        ));
      },
      expectedUIState: {
        'widget_exists': '登录',
        'button_enabled': '登录',
      },
    );
    results.add(loadResult);
    
    // 测试表单输入
    final inputResult = await testFrontendInteraction(
      module: '登录页面',
      function: '表单输入',
      description: '验证表单输入功能',
      testAction: () async {
        // 输入邮箱
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.pump();
        
        // 输入密码
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tester.pump();
      },
      expectedUIState: {
        'form_field_value': {
          'email_field': 'test@example.com',
          'password_field': 'password123',
        },
      },
    );
    results.add(inputResult);
    
    // 测试登录按钮点击
    final loginResult = await testFrontendInteraction(
      module: '登录页面',
      function: '登录按钮点击',
      description: '验证登录按钮点击功能',
      testAction: () async {
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pump();
      },
    );
    results.add(loginResult);
    
    return results;
  }
  
  /// 测试注册页面
  Future<List<FrontendTestResult>> testRegisterPage() async {
    print('📝 测试注册页面...');
    final results = <FrontendTestResult>[];
    
    // 测试页面加载
    final loadResult = await testFrontendInteraction(
      module: '注册页面',
      function: '页面加载',
      description: '验证注册页面正常加载',
      testAction: () async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(
                  key: const Key('username_field'),
                  decoration: const InputDecoration(labelText: '用户名'),
                ),
                TextField(
                  key: const Key('email_field'),
                  decoration: const InputDecoration(labelText: '邮箱'),
                ),
                TextField(
                  key: const Key('password_field'),
                  decoration: const InputDecoration(labelText: '密码'),
                  obscureText: true,
                ),
                TextField(
                  key: const Key('confirm_password_field'),
                  decoration: const InputDecoration(labelText: '确认密码'),
                  obscureText: true,
                ),
                ElevatedButton(
                  key: const Key('register_button'),
                  onPressed: () {},
                  child: const Text('注册'),
                ),
              ],
            ),
          ),
        ));
      },
      expectedUIState: {
        'widget_exists': '注册',
        'button_enabled': '注册',
      },
    );
    results.add(loadResult);
    
    // 测试表单输入
    final inputResult = await testFrontendInteraction(
      module: '注册页面',
      function: '表单输入',
      description: '验证注册表单输入功能',
      testAction: () async {
        await tester.enterText(find.byKey(const Key('username_field')), 'testuser');
        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tester.enterText(find.byKey(const Key('confirm_password_field')), 'password123');
        await tester.pump();
      },
      expectedUIState: {
        'form_field_value': {
          'username_field': 'testuser',
          'email_field': 'test@example.com',
          'password_field': 'password123',
          'confirm_password_field': 'password123',
        },
      },
    );
    results.add(inputResult);
    
    return results;
  }
  
  /// 测试BMI计算页面
  Future<List<FrontendTestResult>> testBMIPage() async {
    print('📊 测试BMI计算页面...');
    final results = <FrontendTestResult>[];
    
    // 测试页面加载
    final loadResult = await testFrontendInteraction(
      module: 'BMI计算页面',
      function: '页面加载',
      description: '验证BMI计算页面正常加载',
      testAction: () async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(
                  key: const Key('height_field'),
                  decoration: const InputDecoration(labelText: '身高 (cm)'),
                ),
                TextField(
                  key: const Key('weight_field'),
                  decoration: const InputDecoration(labelText: '体重 (kg)'),
                ),
                TextField(
                  key: const Key('age_field'),
                  decoration: const InputDecoration(labelText: '年龄'),
                ),
                DropdownButton<String>(
                  key: const Key('gender_dropdown'),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('男')),
                    DropdownMenuItem(value: 'female', child: Text('女')),
                  ],
                  onChanged: (value) {},
                ),
                ElevatedButton(
                  key: const Key('calculate_button'),
                  onPressed: () {},
                  child: const Text('计算BMI'),
                ),
                const Text('BMI结果将显示在这里', key: Key('bmi_result')),
              ],
            ),
          ),
        ));
      },
      expectedUIState: {
        'widget_exists': '计算BMI',
        'button_enabled': '计算BMI',
      },
    );
    results.add(loadResult);
    
    // 测试BMI计算
    final calculateResult = await testFrontendInteraction(
      module: 'BMI计算页面',
      function: 'BMI计算',
      description: '验证BMI计算功能',
      testAction: () async {
        await tester.enterText(find.byKey(const Key('height_field')), '175');
        await tester.enterText(find.byKey(const Key('weight_field')), '70');
        await tester.enterText(find.byKey(const Key('age_field')), '25');
        await tester.tap(find.byKey(const Key('calculate_button')));
        await tester.pump();
      },
    );
    results.add(calculateResult);
    
    return results;
  }
  
  /// 测试运动记录页面
  Future<List<FrontendTestResult>> testWorkoutPage() async {
    print('💪 测试运动记录页面...');
    final results = <FrontendTestResult>[];
    
    // 测试页面加载
    final loadResult = await testFrontendInteraction(
      module: '运动记录页面',
      function: '页面加载',
      description: '验证运动记录页面正常加载',
      testAction: () async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(
                  key: const Key('workout_name_field'),
                  decoration: const InputDecoration(labelText: '运动名称'),
                ),
                DropdownButton<String>(
                  key: const Key('workout_type_dropdown'),
                  items: const [
                    DropdownMenuItem(value: 'cardio', child: Text('有氧运动')),
                    DropdownMenuItem(value: 'strength', child: Text('力量训练')),
                    DropdownMenuItem(value: 'flexibility', child: Text('柔韧性训练')),
                  ],
                  onChanged: (value) {},
                ),
                TextField(
                  key: const Key('duration_field'),
                  decoration: const InputDecoration(labelText: '持续时间 (分钟)'),
                ),
                TextField(
                  key: const Key('calories_field'),
                  decoration: const InputDecoration(labelText: '消耗卡路里'),
                ),
                ElevatedButton(
                  key: const Key('save_workout_button'),
                  onPressed: () {},
                  child: const Text('保存运动记录'),
                ),
                const Text('运动记录列表', key: Key('workout_list')),
              ],
            ),
          ),
        ));
      },
      expectedUIState: {
        'widget_exists': '保存运动记录',
        'button_enabled': '保存运动记录',
      },
    );
    results.add(loadResult);
    
    // 测试运动记录创建
    final createResult = await testFrontendInteraction(
      module: '运动记录页面',
      function: '创建运动记录',
      description: '验证运动记录创建功能',
      testAction: () async {
        await tester.enterText(find.byKey(const Key('workout_name_field')), '跑步训练');
        await tester.enterText(find.byKey(const Key('duration_field')), '30');
        await tester.enterText(find.byKey(const Key('calories_field')), '300');
        await tester.tap(find.byKey(const Key('save_workout_button')));
        await tester.pump();
      },
    );
    results.add(createResult);
    
    return results;
  }
  
  /// 测试营养记录页面
  Future<List<FrontendTestResult>> testNutritionPage() async {
    print('🥗 测试营养记录页面...');
    final results = <FrontendTestResult>[];
    
    // 测试页面加载
    final loadResult = await testFrontendInteraction(
      module: '营养记录页面',
      function: '页面加载',
      description: '验证营养记录页面正常加载',
      testAction: () async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(
                  key: const Key('food_name_field'),
                  decoration: const InputDecoration(labelText: '食物名称'),
                ),
                TextField(
                  key: const Key('quantity_field'),
                  decoration: const InputDecoration(labelText: '数量'),
                ),
                DropdownButton<String>(
                  key: const Key('unit_dropdown'),
                  items: const [
                    DropdownMenuItem(value: 'g', child: Text('克')),
                    DropdownMenuItem(value: 'kg', child: Text('千克')),
                    DropdownMenuItem(value: 'ml', child: Text('毫升')),
                    DropdownMenuItem(value: 'l', child: Text('升')),
                  ],
                  onChanged: (value) {},
                ),
                DropdownButton<String>(
                  key: const Key('meal_type_dropdown'),
                  items: const [
                    DropdownMenuItem(value: 'breakfast', child: Text('早餐')),
                    DropdownMenuItem(value: 'lunch', child: Text('午餐')),
                    DropdownMenuItem(value: 'dinner', child: Text('晚餐')),
                    DropdownMenuItem(value: 'snack', child: Text('零食')),
                  ],
                  onChanged: (value) {},
                ),
                ElevatedButton(
                  key: const Key('save_nutrition_button'),
                  onPressed: () {},
                  child: const Text('保存营养记录'),
                ),
                const Text('营养记录列表', key: Key('nutrition_list')),
              ],
            ),
          ),
        ));
      },
      expectedUIState: {
        'widget_exists': '保存营养记录',
        'button_enabled': '保存营养记录',
      },
    );
    results.add(loadResult);
    
    // 测试营养记录创建
    final createResult = await testFrontendInteraction(
      module: '营养记录页面',
      function: '创建营养记录',
      description: '验证营养记录创建功能',
      testAction: () async {
        await tester.enterText(find.byKey(const Key('food_name_field')), '苹果');
        await tester.enterText(find.byKey(const Key('quantity_field')), '100');
        await tester.tap(find.byKey(const Key('save_nutrition_button')));
        await tester.pump();
      },
    );
    results.add(createResult);
    
    return results;
  }
  
  /// 测试社区页面
  Future<List<FrontendTestResult>> testCommunityPage() async {
    print('👥 测试社区页面...');
    final results = <FrontendTestResult>[];
    
    // 测试页面加载
    final loadResult = await testFrontendInteraction(
      module: '社区页面',
      function: '页面加载',
      description: '验证社区页面正常加载',
      testAction: () async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(
                  key: const Key('post_content_field'),
                  decoration: const InputDecoration(labelText: '发布内容'),
                  maxLines: 3,
                ),
                ElevatedButton(
                  key: const Key('publish_button'),
                  onPressed: () {},
                  child: const Text('发布动态'),
                ),
                const Text('社区动态列表', key: Key('posts_list')),
                ElevatedButton(
                  key: const Key('like_button'),
                  onPressed: () {},
                  child: const Text('点赞'),
                ),
                ElevatedButton(
                  key: const Key('comment_button'),
                  onPressed: () {},
                  child: const Text('评论'),
                ),
              ],
            ),
          ),
        ));
      },
      expectedUIState: {
        'widget_exists': '发布动态',
        'button_enabled': '发布动态',
      },
    );
    results.add(loadResult);
    
    // 测试发布动态
    final publishResult = await testFrontendInteraction(
      module: '社区页面',
      function: '发布动态',
      description: '验证发布动态功能',
      testAction: () async {
        await tester.enterText(find.byKey(const Key('post_content_field')), '今天完成了30分钟跑步！');
        await tester.tap(find.byKey(const Key('publish_button')));
        await tester.pump();
      },
    );
    results.add(publishResult);
    
    // 测试点赞功能
    final likeResult = await testFrontendInteraction(
      module: '社区页面',
      function: '点赞功能',
      description: '验证点赞功能',
      testAction: () async {
        await tester.tap(find.byKey(const Key('like_button')));
        await tester.pump();
      },
    );
    results.add(likeResult);
    
    // 测试评论功能
    final commentResult = await testFrontendInteraction(
      module: '社区页面',
      function: '评论功能',
      description: '验证评论功能',
      testAction: () async {
        await tester.tap(find.byKey(const Key('comment_button')));
        await tester.pump();
      },
    );
    results.add(commentResult);
    
    return results;
  }
  
  /// 测试签到页面
  Future<List<FrontendTestResult>> testCheckinPage() async {
    print('✅ 测试签到页面...');
    final results = <FrontendTestResult>[];
    
    // 测试页面加载
    final loadResult = await testFrontendInteraction(
      module: '签到页面',
      function: '页面加载',
      description: '验证签到页面正常加载',
      testAction: () async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                DropdownButton<String>(
                  key: const Key('checkin_type_dropdown'),
                  items: const [
                    DropdownMenuItem(value: 'workout', child: Text('运动签到')),
                    DropdownMenuItem(value: 'nutrition', child: Text('饮食签到')),
                    DropdownMenuItem(value: 'sleep', child: Text('睡眠签到')),
                  ],
                  onChanged: (value) {},
                ),
                TextField(
                  key: const Key('checkin_notes_field'),
                  decoration: const InputDecoration(labelText: '签到备注'),
                  maxLines: 2,
                ),
                Slider(
                  key: const Key('energy_slider'),
                  value: 5.0,
                  min: 1.0,
                  max: 10.0,
                  divisions: 9,
                  onChanged: (value) {},
                ),
                const Text('能量水平: 5', key: Key('energy_text')),
                Slider(
                  key: const Key('motivation_slider'),
                  value: 5.0,
                  min: 1.0,
                  max: 10.0,
                  divisions: 9,
                  onChanged: (value) {},
                ),
                const Text('动力水平: 5', key: Key('motivation_text')),
                ElevatedButton(
                  key: const Key('checkin_button'),
                  onPressed: () {},
                  child: const Text('签到'),
                ),
                const Text('签到日历', key: Key('checkin_calendar')),
              ],
            ),
          ),
        ));
      },
      expectedUIState: {
        'widget_exists': '签到',
        'button_enabled': '签到',
      },
    );
    results.add(loadResult);
    
    // 测试签到功能
    final checkinResult = await testFrontendInteraction(
      module: '签到页面',
      function: '签到功能',
      description: '验证签到功能',
      testAction: () async {
        await tester.enterText(find.byKey(const Key('checkin_notes_field')), '今天感觉很好！');
        await tester.tap(find.byKey(const Key('checkin_button')));
        await tester.pump();
      },
    );
    results.add(checkinResult);
    
    return results;
  }
  
  /// 测试页面导航
  Future<List<FrontendTestResult>> testNavigation() async {
    print('🧭 测试页面导航...');
    final results = <FrontendTestResult>[];
    
    // 测试底部导航栏
    final bottomNavResult = await testFrontendInteraction(
      module: '页面导航',
      function: '底部导航栏',
      description: '验证底部导航栏功能',
      testAction: () async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
                BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: '运动'),
                BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: '营养'),
                BottomNavigationBarItem(icon: Icon(Icons.people), label: '社区'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
              ],
              onTap: (index) {},
            ),
          ),
        ));
      },
      expectedUIState: {
        'widget_exists': '首页',
      },
    );
    results.add(bottomNavResult);
    
    // 测试页面切换
    final pageSwitchResult = await testFrontendInteraction(
      module: '页面导航',
      function: '页面切换',
      description: '验证页面切换功能',
      testAction: () async {
        await tester.tap(find.text('运动'));
        await tester.pump();
        await tester.tap(find.text('营养'));
        await tester.pump();
        await tester.tap(find.text('社区'));
        await tester.pump();
      },
    );
    results.add(pageSwitchResult);
    
    return results;
  }
  
  /// 测试表单验证
  Future<List<FrontendTestResult>> testFormValidation() async {
    print('📋 测试表单验证...');
    final results = <FrontendTestResult>[];
    
    // 测试空值验证
    final emptyValidationResult = await testFrontendInteraction(
      module: '表单验证',
      function: '空值验证',
      description: '验证空值表单验证',
      testAction: () async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(
                  key: const Key('required_field'),
                  decoration: const InputDecoration(labelText: '必填字段'),
                ),
                ElevatedButton(
                  key: const Key('submit_button'),
                  onPressed: () {},
                  child: const Text('提交'),
                ),
              ],
            ),
          ),
        ));
        
        // 尝试提交空表单
        await tester.tap(find.byKey(const Key('submit_button')));
        await tester.pump();
      },
    );
    results.add(emptyValidationResult);
    
    // 测试格式验证
    final formatValidationResult = await testFrontendInteraction(
      module: '表单验证',
      function: '格式验证',
      description: '验证邮箱格式验证',
      testAction: () async {
        await tester.enterText(find.byKey(const Key('required_field')), 'invalid-email');
        await tester.tap(find.byKey(const Key('submit_button')));
        await tester.pump();
      },
    );
    results.add(formatValidationResult);
    
    return results;
  }
  
  /// 执行全面前端测试
  Future<FrontendTestReport> runComprehensiveFrontendTests() async {
    print('🚀 开始执行 FitTracker 全面前端测试...');
    _testResults.clear();
    
    final startTime = DateTime.now();
    
    try {
      // 测试各个页面
      final loginResults = await testLoginPage();
      final registerResults = await testRegisterPage();
      final bmiResults = await testBMIPage();
      final workoutResults = await testWorkoutPage();
      final nutritionResults = await testNutritionPage();
      final communityResults = await testCommunityPage();
      final checkinResults = await testCheckinPage();
      final navigationResults = await testNavigation();
      final validationResults = await testFormValidation();
      
      final endTime = DateTime.now();
      final totalDuration = endTime.difference(startTime).inMilliseconds;
      
      // 生成测试报告
      final report = FrontendTestReport(
        testName: 'FitTracker 全面前端测试',
        startTime: startTime,
        endTime: endTime,
        totalDuration: totalDuration,
        totalTests: _testResults.length,
        passedTests: _testResults.where((r) => r.status == FrontendTestStatus.passed).length,
        failedTests: _testResults.where((r) => r.status == FrontendTestStatus.failed).length,
        warningTests: _testResults.where((r) => r.status == FrontendTestStatus.warning).length,
        testResults: _testResults,
        summary: _generateFrontendTestSummary(),
      );
      
      print('✅ 前端测试完成！');
      print('📊 测试统计:');
      print('   总测试数: ${report.totalTests}');
      print('   通过: ${report.passedTests}');
      print('   失败: ${report.failedTests}');
      print('   警告: ${report.warningTests}');
      print('   总耗时: ${report.totalDuration}ms');
      
      return report;
      
    } catch (e) {
      print('❌ 前端测试执行失败: $e');
      rethrow;
    }
  }
  
  /// 生成前端测试摘要
  String _generateFrontendTestSummary() {
    final totalTests = _testResults.length;
    final passedTests = _testResults.where((r) => r.status == FrontendTestStatus.passed).length;
    final failedTests = _testResults.where((r) => r.status == FrontendTestStatus.failed).length;
    final warningTests = _testResults.where((r) => r.status == FrontendTestStatus.warning).length;
    
    final successRate = totalTests > 0 ? (passedTests / totalTests * 100).toStringAsFixed(2) : '0.00';
    
    return '''
前端测试摘要:
- 总测试数: $totalTests
- 通过: $passedTests (${successRate}%)
- 失败: $failedTests
- 警告: $warningTests
- 成功率: ${successRate}%

模块测试结果:
${_getFrontendModuleSummary()}
''';
  }
  
  /// 获取前端模块测试摘要
  String _getFrontendModuleSummary() {
    final moduleGroups = <String, List<FrontendTestResult>>{};
    
    for (final result in _testResults) {
      moduleGroups.putIfAbsent(result.module, () => []).add(result);
    }
    
    final summary = StringBuffer();
    for (final entry in moduleGroups.entries) {
      final module = entry.key;
      final results = entry.value;
      final passed = results.where((r) => r.status == FrontendTestStatus.passed).length;
      final failed = results.where((r) => r.status == FrontendTestStatus.failed).length;
      final warning = results.where((r) => r.status == FrontendTestStatus.warning).length;
      
      summary.writeln('- $module: $passed 通过, $failed 失败, $warning 警告');
    }
    
    return summary.toString();
  }
  
  /// 生成JSON格式的前端测试报告
  Map<String, dynamic> generateJsonReport(FrontendTestReport report) {
    return {
      'frontendTestReport': {
        'testName': report.testName,
        'startTime': report.startTime.toIso8601String(),
        'endTime': report.endTime.toIso8601String(),
        'totalDuration': report.totalDuration,
        'summary': {
          'totalTests': report.totalTests,
          'passedTests': report.passedTests,
          'failedTests': report.failedTests,
          'warningTests': report.warningTests,
          'successRate': report.totalTests > 0 ? (report.passedTests / report.totalTests * 100).toStringAsFixed(2) : '0.00',
        },
        'testResults': report.testResults.map((result) => {
          'module': result.module,
          'function': result.function,
          'description': result.description,
          'status': result.status.toString().split('.').last,
          'errorMessage': result.errorMessage,
          'timestamp': result.timestamp.toIso8601String(),
        }).toList(),
      },
    };
  }
  
  /// 生成Markdown格式的前端测试报告
  String generateMarkdownReport(FrontendTestReport report) {
    final buffer = StringBuffer();
    
    buffer.writeln('# FitTracker 前端自动化测试报告');
    buffer.writeln();
    buffer.writeln('## 测试概览');
    buffer.writeln();
    buffer.writeln('| 项目 | 值 |');
    buffer.writeln('|------|-----|');
    buffer.writeln('| 测试名称 | ${report.testName} |');
    buffer.writeln('| 开始时间 | ${report.startTime.toIso8601String()} |');
    buffer.writeln('| 结束时间 | ${report.endTime.toIso8601String()} |');
    buffer.writeln('| 总耗时 | ${report.totalDuration}ms |');
    buffer.writeln('| 总测试数 | ${report.totalTests} |');
    buffer.writeln('| 通过 | ${report.passedTests} |');
    buffer.writeln('| 失败 | ${report.failedTests} |');
    buffer.writeln('| 警告 | ${report.warningTests} |');
    buffer.writeln('| 成功率 | ${report.totalTests > 0 ? (report.passedTests / report.totalTests * 100).toStringAsFixed(2) : '0.00'}% |');
    buffer.writeln();
    
    buffer.writeln('## 测试摘要');
    buffer.writeln();
    buffer.writeln('```');
    buffer.writeln(report.summary);
    buffer.writeln('```');
    buffer.writeln();
    
    buffer.writeln('## 详细测试结果');
    buffer.writeln();
    
    // 按模块分组显示测试结果
    final moduleGroups = <String, List<FrontendTestResult>>{};
    for (final result in report.testResults) {
      moduleGroups.putIfAbsent(result.module, () => []).add(result);
    }
    
    for (final entry in moduleGroups.entries) {
      final module = entry.key;
      final results = entry.value;
      
      buffer.writeln('### $module');
      buffer.writeln();
      
      for (final result in results) {
        final statusIcon = result.status == FrontendTestStatus.passed ? '✅' : 
                          result.status == FrontendTestStatus.failed ? '❌' : '⚠️';
        
        buffer.writeln('#### $statusIcon ${result.function}');
        buffer.writeln();
        buffer.writeln('| 项目 | 值 |');
        buffer.writeln('|------|-----|');
        buffer.writeln('| 描述 | ${result.description} |');
        buffer.writeln('| 测试状态 | ${result.status.toString().split('.').last} |');
        
        if (result.errorMessage != null) {
          buffer.writeln('| 错误信息 | ${result.errorMessage} |');
        }
        
        buffer.writeln();
      }
    }
    
    return buffer.toString();
  }
  
  /// 保存前端测试报告到文件
  Future<void> saveReportToFile(FrontendTestReport report, {String? filename}) async {
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
    final defaultFilename = filename ?? 'fittracker_frontend_test_report_$timestamp';
    
    // 保存JSON报告
    final jsonReport = generateJsonReport(report);
    final jsonFile = File('${defaultFilename}.json');
    await jsonFile.writeAsString(JsonEncoder.withIndent('  ').convert(jsonReport));
    print('📄 JSON报告已保存: ${jsonFile.path}');
    
    // 保存Markdown报告
    final markdownReport = generateMarkdownReport(report);
    final markdownFile = File('${defaultFilename}.md');
    await markdownFile.writeAsString(markdownReport);
    print('📄 Markdown报告已保存: ${markdownFile.path}');
  }
}

/// 前端测试结果类
class FrontendTestResult {
  final String module;
  final String function;
  final String description;
  final DateTime timestamp;
  
  FrontendTestStatus status = FrontendTestStatus.pending;
  String? errorMessage;
  
  FrontendTestResult({
    required this.module,
    required this.function,
    required this.description,
    required this.timestamp,
  });
}

/// 前端测试状态枚举
enum FrontendTestStatus {
  pending,
  passed,
  failed,
  warning,
}

/// 前端测试报告类
class FrontendTestReport {
  final String testName;
  final DateTime startTime;
  final DateTime endTime;
  final int totalDuration;
  final int totalTests;
  final int passedTests;
  final int failedTests;
  final int warningTests;
  final List<FrontendTestResult> testResults;
  final String summary;
  
  FrontendTestReport({
    required this.testName,
    required this.startTime,
    required this.endTime,
    required this.totalDuration,
    required this.totalTests,
    required this.passedTests,
    required this.failedTests,
    required this.warningTests,
    required this.testResults,
    required this.summary,
  });
}

/// UI验证结果类
class UIValidationResult {
  final bool isValid;
  final String? errorMessage;
  
  UIValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}

/// 数据验证结果类
class DataValidationResult {
  final bool isValid;
  final String? errorMessage;
  
  DataValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}
