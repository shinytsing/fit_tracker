import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fittracker/frontend/lib/core/services/api_services.dart';
import 'package:fittracker/frontend/lib/core/models/models.dart';

/// FitTracker 自动化测试框架
/// 用于测试前端与后端 API 交互功能
class FitTrackerTestFramework {
  static final FitTrackerTestFramework _instance = FitTrackerTestFramework._internal();
  factory FitTrackerTestFramework() => _instance;
  FitTrackerTestFramework._internal();

  late Dio _dio;
  late AuthApiService _authService;
  late WorkoutApiService _workoutService;
  late CommunityApiService _communityService;
  late CheckinApiService _checkinService;
  late NutritionApiService _nutritionService;
  
  String? _authToken;
  String _baseUrl = 'http://10.0.2.2:8080/api/v1';
  
  // 测试结果存储
  List<TestResult> _testResults = [];
  
  /// 初始化测试框架
  Future<void> initialize() async {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _authService = AuthApiService();
    _workoutService = WorkoutApiService();
    _communityService = CommunityApiService();
    _checkinService = CheckinApiService();
    _nutritionService = NutritionApiService();
    
    print('🚀 FitTracker 测试框架初始化完成');
  }
  
  /// 设置认证Token
  void setAuthToken(String token) {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
  
  /// 清除认证Token
  void clearAuthToken() {
    _authToken = null;
    _dio.options.headers.remove('Authorization');
  }
  
  /// 执行API测试
  Future<TestResult> testApiCall({
    required String module,
    required String function,
    required String apiUrl,
    required String method,
    Map<String, dynamic>? requestData,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? expectedResponse,
    int expectedStatusCode = 200,
    bool requiresAuth = true,
  }) async {
    final testResult = TestResult(
      module: module,
      function: function,
      apiUrl: apiUrl,
      method: method,
      requestData: requestData,
      queryParams: queryParams,
      timestamp: DateTime.now(),
    );
    
    try {
      // 检查认证要求
      if (requiresAuth && _authToken == null) {
        testResult.status = TestStatus.failed;
        testResult.errorDescription = '需要认证但未提供Token';
        _testResults.add(testResult);
        return testResult;
      }
      
      // 执行API调用
      Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(apiUrl, queryParameters: queryParams);
          break;
        case 'POST':
          response = await _dio.post(apiUrl, data: requestData, queryParameters: queryParams);
          break;
        case 'PUT':
          response = await _dio.put(apiUrl, data: requestData, queryParameters: queryParams);
          break;
        case 'DELETE':
          response = await _dio.delete(apiUrl, data: requestData, queryParameters: queryParams);
          break;
        default:
          throw Exception('不支持的HTTP方法: $method');
      }
      
      // 记录响应
      testResult.responseData = response.data;
      testResult.statusCode = response.statusCode;
      testResult.responseTime = DateTime.now().difference(testResult.timestamp).inMilliseconds;
      
      // 验证状态码
      if (response.statusCode == expectedStatusCode) {
        testResult.status = TestStatus.passed;
        
        // 验证响应数据结构
        if (expectedResponse != null) {
          final validationResult = _validateResponseStructure(response.data, expectedResponse);
          if (!validationResult.isValid) {
            testResult.status = TestStatus.warning;
            testResult.errorDescription = '响应结构验证失败: ${validationResult.errorMessage}';
          }
        }
      } else {
        testResult.status = TestStatus.failed;
        testResult.errorDescription = '状态码不匹配: 期望 $expectedStatusCode, 实际 ${response.statusCode}';
      }
      
    } catch (e) {
      testResult.status = TestStatus.failed;
      testResult.errorDescription = 'API调用失败: $e';
    }
    
    _testResults.add(testResult);
    return testResult;
  }
  
  /// 验证响应结构
  ResponseValidationResult _validateResponseStructure(dynamic actual, Map<String, dynamic> expected) {
    try {
      if (actual is Map<String, dynamic>) {
        for (final key in expected.keys) {
          if (!actual.containsKey(key)) {
            return ResponseValidationResult(
              isValid: false,
              errorMessage: '缺少字段: $key',
            );
          }
          
          final expectedType = expected[key];
          final actualValue = actual[key];
          
          if (expectedType is String) {
            if (expectedType == 'string' && actualValue is! String) {
              return ResponseValidationResult(
                isValid: false,
                errorMessage: '字段 $key 类型错误: 期望 String, 实际 ${actualValue.runtimeType}',
              );
            }
          } else if (expectedType is Map<String, dynamic>) {
            if (actualValue is! Map<String, dynamic>) {
              return ResponseValidationResult(
                isValid: false,
                errorMessage: '字段 $key 类型错误: 期望 Map, 实际 ${actualValue.runtimeType}',
              );
            }
            final nestedResult = _validateResponseStructure(actualValue, expectedType);
            if (!nestedResult.isValid) {
              return nestedResult;
            }
          }
        }
      }
      
      return ResponseValidationResult(isValid: true);
    } catch (e) {
      return ResponseValidationResult(
        isValid: false,
        errorMessage: '验证过程出错: $e',
      );
    }
  }
  
  /// 测试用户认证模块
  Future<List<TestResult>> testAuthModule() async {
    print('🔐 开始测试用户认证模块...');
    final results = <TestResult>[];
    
    // 测试用户注册
    final registerResult = await testApiCall(
      module: '认证模块',
      function: '用户注册',
      apiUrl: '/auth/register',
      method: 'POST',
      requestData: {
        'username': 'testuser_${DateTime.now().millisecondsSinceEpoch}',
        'email': 'test_${DateTime.now().millisecondsSinceEpoch}@example.com',
        'password': 'Test123456!',
        'first_name': '测试',
        'last_name': '用户',
      },
      expectedResponse: {
        'data': {
          'user': 'string',
          'token': 'string',
        },
      },
      requiresAuth: false,
    );
    results.add(registerResult);
    
    // 如果注册成功，保存token用于后续测试
    if (registerResult.status == TestStatus.passed && registerResult.responseData != null) {
      final token = registerResult.responseData['data']['token'];
      setAuthToken(token);
    }
    
    // 测试用户登录
    final loginResult = await testApiCall(
      module: '认证模块',
      function: '用户登录',
      apiUrl: '/auth/login',
      method: 'POST',
      requestData: {
        'email': 'test_${DateTime.now().millisecondsSinceEpoch}@example.com',
        'password': 'Test123456!',
      },
      expectedResponse: {
        'data': {
          'user': 'string',
          'token': 'string',
        },
      },
      requiresAuth: false,
    );
    results.add(loginResult);
    
    // 测试获取用户资料
    final profileResult = await testApiCall(
      module: '认证模块',
      function: '获取用户资料',
      apiUrl: '/profile',
      method: 'GET',
      expectedResponse: {
        'data': {
          'id': 'string',
          'username': 'string',
          'email': 'string',
        },
      },
    );
    results.add(profileResult);
    
    // 测试用户登出
    final logoutResult = await testApiCall(
      module: '认证模块',
      function: '用户登出',
      apiUrl: '/auth/logout',
      method: 'POST',
    );
    results.add(logoutResult);
    
    return results;
  }
  
  /// 测试运动记录模块
  Future<List<TestResult>> testWorkoutModule() async {
    print('💪 开始测试运动记录模块...');
    final results = <TestResult>[];
    
    // 测试获取训练记录
    final getWorkoutsResult = await testApiCall(
      module: '运动记录模块',
      function: '获取训练记录',
      apiUrl: '/workouts',
      method: 'GET',
      queryParams: {'page': 1, 'limit': 10},
      expectedResponse: {
        'data': 'string',
        'pagination': 'string',
      },
    );
    results.add(getWorkoutsResult);
    
    // 测试创建训练记录
    final createWorkoutResult = await testApiCall(
      module: '运动记录模块',
      function: '创建训练记录',
      apiUrl: '/workouts',
      method: 'POST',
      requestData: {
        'name': '测试训练',
        'type': 'cardio',
        'duration': 30,
        'calories': 300,
        'difficulty': 'medium',
        'notes': '自动化测试创建',
        'rating': 4.5,
      },
      expectedResponse: {
        'data': {
          'id': 'string',
          'name': 'string',
          'type': 'string',
        },
      },
    );
    results.add(createWorkoutResult);
    
    // 测试获取训练计划
    final getPlansResult = await testApiCall(
      module: '运动记录模块',
      function: '获取训练计划',
      apiUrl: '/plans',
      method: 'GET',
      queryParams: {'page': 1, 'limit': 10},
      expectedResponse: {
        'data': 'string',
        'pagination': 'string',
      },
    );
    results.add(getPlansResult);
    
    // 测试获取运动动作
    final getExercisesResult = await testApiCall(
      module: '运动记录模块',
      function: '获取运动动作',
      apiUrl: '/plans/exercises',
      method: 'GET',
      queryParams: {'page': 1, 'limit': 20},
      expectedResponse: {
        'data': 'string',
        'pagination': 'string',
      },
    );
    results.add(getExercisesResult);
    
    return results;
  }
  
  /// 测试BMI计算模块
  Future<List<TestResult>> testBMIModule() async {
    print('📊 开始测试BMI计算模块...');
    final results = <TestResult>[];
    
    // 测试BMI计算
    final calculateBMIResult = await testApiCall(
      module: 'BMI计算模块',
      function: 'BMI计算',
      apiUrl: '/bmi/calculate',
      method: 'POST',
      requestData: {
        'height': 175.0,
        'weight': 70.0,
        'age': 25,
        'gender': 'male',
      },
      expectedResponse: {
        'data': {
          'bmi': 'string',
          'category': 'string',
          'recommendation': 'string',
        },
      },
    );
    results.add(calculateBMIResult);
    
    // 测试创建BMI记录
    final createBMIRecordResult = await testApiCall(
      module: 'BMI计算模块',
      function: '创建BMI记录',
      apiUrl: '/bmi/records',
      method: 'POST',
      requestData: {
        'height': 175.0,
        'weight': 70.0,
        'age': 25,
        'gender': 'male',
        'notes': '自动化测试记录',
      },
      expectedResponse: {
        'data': {
          'id': 'string',
          'bmi': 'string',
          'created_at': 'string',
        },
      },
    );
    results.add(createBMIRecordResult);
    
    // 测试获取BMI记录
    final getBMIRecordsResult = await testApiCall(
      module: 'BMI计算模块',
      function: '获取BMI记录',
      apiUrl: '/bmi/records',
      method: 'GET',
      expectedResponse: {
        'data': 'string',
      },
    );
    results.add(getBMIRecordsResult);
    
    return results;
  }
  
  /// 测试营养管理模块
  Future<List<TestResult>> testNutritionModule() async {
    print('🥗 开始测试营养管理模块...');
    final results = <TestResult>[];
    
    // 测试计算营养信息
    final calculateNutritionResult = await testApiCall(
      module: '营养管理模块',
      function: '计算营养信息',
      apiUrl: '/nutrition/calculate',
      method: 'POST',
      requestData: {
        'food_name': '苹果',
        'quantity': 100.0,
        'unit': 'g',
      },
      expectedResponse: {
        'data': {
          'calories': 'string',
          'protein': 'string',
          'carbs': 'string',
          'fat': 'string',
        },
      },
    );
    results.add(calculateNutritionResult);
    
    // 测试搜索食物
    final searchFoodsResult = await testApiCall(
      module: '营养管理模块',
      function: '搜索食物',
      apiUrl: '/nutrition/search',
      method: 'GET',
      queryParams: {'q': '苹果'},
      expectedResponse: {
        'data': 'string',
      },
    );
    results.add(searchFoodsResult);
    
    // 测试获取每日摄入
    final getDailyIntakeResult = await testApiCall(
      module: '营养管理模块',
      function: '获取每日摄入',
      apiUrl: '/nutrition/daily',
      method: 'GET',
      expectedResponse: {
        'data': {
          'calories': 'string',
          'protein': 'string',
          'carbs': 'string',
          'fat': 'string',
        },
      },
    );
    results.add(getDailyIntakeResult);
    
    // 测试创建营养记录
    final createNutritionRecordResult = await testApiCall(
      module: '营养管理模块',
      function: '创建营养记录',
      apiUrl: '/nutrition/records',
      method: 'POST',
      requestData: {
        'date': DateTime.now().toIso8601String().split('T')[0],
        'meal_type': 'breakfast',
        'food_name': '苹果',
        'quantity': 100.0,
        'unit': 'g',
        'notes': '自动化测试记录',
      },
      expectedResponse: {
        'data': {
          'id': 'string',
          'food_name': 'string',
          'quantity': 'string',
        },
      },
    );
    results.add(createNutritionRecordResult);
    
    // 测试获取营养记录
    final getNutritionRecordsResult = await testApiCall(
      module: '营养管理模块',
      function: '获取营养记录',
      apiUrl: '/nutrition/records',
      method: 'GET',
      queryParams: {'page': 1, 'limit': 20},
      expectedResponse: {
        'data': 'string',
        'pagination': 'string',
      },
    );
    results.add(getNutritionRecordsResult);
    
    return results;
  }
  
  /// 测试社区功能模块
  Future<List<TestResult>> testCommunityModule() async {
    print('👥 开始测试社区功能模块...');
    final results = <TestResult>[];
    
    // 测试获取社区动态
    final getPostsResult = await testApiCall(
      module: '社区功能模块',
      function: '获取社区动态',
      apiUrl: '/community/posts',
      method: 'GET',
      queryParams: {'page': 1, 'limit': 10},
      expectedResponse: {
        'data': 'string',
        'pagination': 'string',
      },
    );
    results.add(getPostsResult);
    
    // 测试发布动态
    final createPostResult = await testApiCall(
      module: '社区功能模块',
      function: '发布动态',
      apiUrl: '/community/posts',
      method: 'POST',
      requestData: {
        'content': '这是自动化测试发布的动态',
        'type': 'workout',
        'is_public': true,
      },
      expectedResponse: {
        'data': {
          'id': 'string',
          'content': 'string',
          'created_at': 'string',
        },
      },
    );
    results.add(createPostResult);
    
    // 测试获取挑战列表
    final getChallengesResult = await testApiCall(
      module: '社区功能模块',
      function: '获取挑战列表',
      apiUrl: '/community/challenges',
      method: 'GET',
      queryParams: {'page': 1, 'limit': 10},
      expectedResponse: {
        'data': 'string',
        'pagination': 'string',
      },
    );
    results.add(getChallengesResult);
    
    return results;
  }
  
  /// 测试签到功能模块
  Future<List<TestResult>> testCheckinModule() async {
    print('✅ 开始测试签到功能模块...');
    final results = <TestResult>[];
    
    // 测试获取签到记录
    final getCheckinsResult = await testApiCall(
      module: '签到功能模块',
      function: '获取签到记录',
      apiUrl: '/checkins',
      method: 'GET',
      queryParams: {'page': 1, 'limit': 30},
      expectedResponse: {
        'data': 'string',
      },
    );
    results.add(getCheckinsResult);
    
    // 测试创建签到记录
    final createCheckinResult = await testApiCall(
      module: '签到功能模块',
      function: '创建签到记录',
      apiUrl: '/checkins',
      method: 'POST',
      requestData: {
        'type': 'workout',
        'notes': '自动化测试签到',
        'mood': 'happy',
        'energy': 8,
        'motivation': 9,
      },
      expectedResponse: {
        'data': {
          'id': 'string',
          'type': 'string',
          'created_at': 'string',
        },
      },
    );
    results.add(createCheckinResult);
    
    // 测试获取签到日历
    final getCheckinCalendarResult = await testApiCall(
      module: '签到功能模块',
      function: '获取签到日历',
      apiUrl: '/checkins/calendar',
      method: 'GET',
      queryParams: {
        'year': DateTime.now().year,
        'month': DateTime.now().month,
      },
      expectedResponse: {
        'data': 'string',
      },
    );
    results.add(getCheckinCalendarResult);
    
    // 测试获取签到连续天数
    final getCheckinStreakResult = await testApiCall(
      module: '签到功能模块',
      function: '获取签到连续天数',
      apiUrl: '/checkins/streak',
      method: 'GET',
      expectedResponse: {
        'data': {
          'current_streak': 'string',
          'longest_streak': 'string',
        },
      },
    );
    results.add(getCheckinStreakResult);
    
    // 测试获取成就
    final getAchievementsResult = await testApiCall(
      module: '签到功能模块',
      function: '获取成就',
      apiUrl: '/checkins/achievements',
      method: 'GET',
      expectedResponse: {
        'data': 'string',
      },
    );
    results.add(getAchievementsResult);
    
    return results;
  }
  
  /// 执行全面测试
  Future<TestReport> runComprehensiveTests() async {
    print('🚀 开始执行 FitTracker 全面自动化测试...');
    _testResults.clear();
    
    final startTime = DateTime.now();
    
    try {
      // 测试各个模块
      final authResults = await testAuthModule();
      final workoutResults = await testWorkoutModule();
      final bmiResults = await testBMIModule();
      final nutritionResults = await testNutritionModule();
      final communityResults = await testCommunityModule();
      final checkinResults = await testCheckinModule();
      
      final endTime = DateTime.now();
      final totalDuration = endTime.difference(startTime).inMilliseconds;
      
      // 生成测试报告
      final report = TestReport(
        testName: 'FitTracker 全面自动化测试',
        startTime: startTime,
        endTime: endTime,
        totalDuration: totalDuration,
        totalTests: _testResults.length,
        passedTests: _testResults.where((r) => r.status == TestStatus.passed).length,
        failedTests: _testResults.where((r) => r.status == TestStatus.failed).length,
        warningTests: _testResults.where((r) => r.status == TestStatus.warning).length,
        testResults: _testResults,
        summary: _generateTestSummary(),
      );
      
      print('✅ 测试完成！');
      print('📊 测试统计:');
      print('   总测试数: ${report.totalTests}');
      print('   通过: ${report.passedTests}');
      print('   失败: ${report.failedTests}');
      print('   警告: ${report.warningTests}');
      print('   总耗时: ${report.totalDuration}ms');
      
      return report;
      
    } catch (e) {
      print('❌ 测试执行失败: $e');
      rethrow;
    }
  }
  
  /// 生成测试摘要
  String _generateTestSummary() {
    final totalTests = _testResults.length;
    final passedTests = _testResults.where((r) => r.status == TestStatus.passed).length;
    final failedTests = _testResults.where((r) => r.status == TestStatus.failed).length;
    final warningTests = _testResults.where((r) => r.status == TestStatus.warning).length;
    
    final successRate = totalTests > 0 ? (passedTests / totalTests * 100).toStringAsFixed(2) : '0.00';
    
    return '''
测试摘要:
- 总测试数: $totalTests
- 通过: $passedTests (${successRate}%)
- 失败: $failedTests
- 警告: $warningTests
- 成功率: ${successRate}%

模块测试结果:
${_getModuleSummary()}
''';
  }
  
  /// 获取模块测试摘要
  String _getModuleSummary() {
    final moduleGroups = <String, List<TestResult>>{};
    
    for (final result in _testResults) {
      moduleGroups.putIfAbsent(result.module, () => []).add(result);
    }
    
    final summary = StringBuffer();
    for (final entry in moduleGroups.entries) {
      final module = entry.key;
      final results = entry.value;
      final passed = results.where((r) => r.status == TestStatus.passed).length;
      final failed = results.where((r) => r.status == TestStatus.failed).length;
      final warning = results.where((r) => r.status == TestStatus.warning).length;
      
      summary.writeln('- $module: $passed 通过, $failed 失败, $warning 警告');
    }
    
    return summary.toString();
  }
  
  /// 生成JSON格式的测试报告
  Map<String, dynamic> generateJsonReport(TestReport report) {
    return {
      'testReport': {
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
          'apiUrl': result.apiUrl,
          'method': result.method,
          'requestData': result.requestData,
          'queryParams': result.queryParams,
          'responseData': result.responseData,
          'statusCode': result.statusCode,
          'responseTime': result.responseTime,
          'status': result.status.toString().split('.').last,
          'errorDescription': result.errorDescription,
          'timestamp': result.timestamp.toIso8601String(),
        }).toList(),
      },
    };
  }
  
  /// 生成Markdown格式的测试报告
  String generateMarkdownReport(TestReport report) {
    final buffer = StringBuffer();
    
    buffer.writeln('# FitTracker 自动化测试报告');
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
    final moduleGroups = <String, List<TestResult>>{};
    for (final result in report.testResults) {
      moduleGroups.putIfAbsent(result.module, () => []).add(result);
    }
    
    for (final entry in moduleGroups.entries) {
      final module = entry.key;
      final results = entry.value;
      
      buffer.writeln('### $module');
      buffer.writeln();
      
      for (final result in results) {
        final statusIcon = result.status == TestStatus.passed ? '✅' : 
                          result.status == TestStatus.failed ? '❌' : '⚠️';
        
        buffer.writeln('#### $statusIcon ${result.function}');
        buffer.writeln();
        buffer.writeln('| 项目 | 值 |');
        buffer.writeln('|------|-----|');
        buffer.writeln('| API URL | `${result.method} ${result.apiUrl}` |');
        buffer.writeln('| 状态码 | ${result.statusCode ?? 'N/A'} |');
        buffer.writeln('| 响应时间 | ${result.responseTime ?? 'N/A'}ms |');
        buffer.writeln('| 测试状态 | ${result.status.toString().split('.').last} |');
        
        if (result.requestData != null) {
          buffer.writeln('| 请求数据 | ```json\n${JsonEncoder.withIndent('  ').convert(result.requestData)}\n``` |');
        }
        
        if (result.queryParams != null) {
          buffer.writeln('| 查询参数 | ```json\n${JsonEncoder.withIndent('  ').convert(result.queryParams)}\n``` |');
        }
        
        if (result.responseData != null) {
          buffer.writeln('| 响应数据 | ```json\n${JsonEncoder.withIndent('  ').convert(result.responseData)}\n``` |');
        }
        
        if (result.errorDescription != null) {
          buffer.writeln('| 错误描述 | ${result.errorDescription} |');
        }
        
        buffer.writeln();
      }
    }
    
    return buffer.toString();
  }
  
  /// 保存测试报告到文件
  Future<void> saveReportToFile(TestReport report, {String? filename}) async {
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
    final defaultFilename = filename ?? 'fittracker_test_report_$timestamp';
    
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

/// 测试结果类
class TestResult {
  final String module;
  final String function;
  final String apiUrl;
  final String method;
  final Map<String, dynamic>? requestData;
  final Map<String, dynamic>? queryParams;
  final DateTime timestamp;
  
  dynamic responseData;
  int? statusCode;
  int? responseTime;
  TestStatus status = TestStatus.pending;
  String? errorDescription;
  
  TestResult({
    required this.module,
    required this.function,
    required this.apiUrl,
    required this.method,
    this.requestData,
    this.queryParams,
    required this.timestamp,
  });
}

/// 测试状态枚举
enum TestStatus {
  pending,
  passed,
  failed,
  warning,
}

/// 测试报告类
class TestReport {
  final String testName;
  final DateTime startTime;
  final DateTime endTime;
  final int totalDuration;
  final int totalTests;
  final int passedTests;
  final int failedTests;
  final int warningTests;
  final List<TestResult> testResults;
  final String summary;
  
  TestReport({
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

/// 响应验证结果类
class ResponseValidationResult {
  final bool isValid;
  final String? errorMessage;
  
  ResponseValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}
