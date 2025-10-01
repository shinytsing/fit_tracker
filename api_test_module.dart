import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'test_automation_framework.dart';

/// FitTracker API 测试模块
/// 专门用于测试后端API接口的功能
class FitTrackerAPITester {
  static final FitTrackerAPITester _instance = FitTrackerAPITester._internal();
  factory FitTrackerAPITester() => _instance;
  FitTrackerAPITester._internal();

  late Dio _dio;
  String _baseUrl = 'http://10.0.2.2:8080/api/v1';
  String? _authToken;
  
  // 测试结果存储
  List<APITestResult> _testResults = [];
  
  /// 初始化API测试器
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
    
    print('🔧 API测试器初始化完成');
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
  
  /// 执行单个API测试
  Future<APITestResult> testAPI({
    required String module,
    required String function,
    required String endpoint,
    required String method,
    Map<String, dynamic>? requestData,
    Map<String, dynamic>? queryParams,
    int expectedStatusCode = 200,
    bool requiresAuth = true,
    Map<String, dynamic>? expectedResponseStructure,
    Duration? timeout,
  }) async {
    final testResult = APITestResult(
      module: module,
      function: function,
      endpoint: endpoint,
      method: method,
      requestData: requestData,
      queryParams: queryParams,
      timestamp: DateTime.now(),
    );
    
    try {
      // 检查认证要求
      if (requiresAuth && _authToken == null) {
        testResult.status = APITestStatus.failed;
        testResult.errorMessage = '需要认证但未提供Token';
        _testResults.add(testResult);
        return testResult;
      }
      
      // 设置超时
      if (timeout != null) {
        _dio.options.connectTimeout = timeout;
        _dio.options.receiveTimeout = timeout;
      }
      
      // 执行API调用
      Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(endpoint, queryParameters: queryParams);
          break;
        case 'POST':
          response = await _dio.post(endpoint, data: requestData, queryParameters: queryParams);
          break;
        case 'PUT':
          response = await _dio.put(endpoint, data: requestData, queryParameters: queryParams);
          break;
        case 'DELETE':
          response = await _dio.delete(endpoint, data: requestData, queryParameters: queryParams);
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
        testResult.status = APITestStatus.passed;
        
        // 验证响应数据结构
        if (expectedResponseStructure != null) {
          final validationResult = _validateResponseStructure(response.data, expectedResponseStructure);
          if (!validationResult.isValid) {
            testResult.status = APITestStatus.warning;
            testResult.errorMessage = '响应结构验证失败: ${validationResult.errorMessage}';
          }
        }
      } else {
        testResult.status = APITestStatus.failed;
        testResult.errorMessage = '状态码不匹配: 期望 $expectedStatusCode, 实际 ${response.statusCode}';
      }
      
    } catch (e) {
      testResult.status = APITestStatus.failed;
      testResult.errorMessage = 'API调用失败: $e';
      
      // 如果是DioException，记录更详细的错误信息
      if (e is DioException) {
        testResult.statusCode = e.response?.statusCode;
        testResult.errorMessage = 'DioException: ${e.message}';
        if (e.response?.data != null) {
          testResult.errorMessage += '\n响应数据: ${e.response?.data}';
        }
      }
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
            } else if (expectedType == 'number' && actualValue is! num) {
              return ResponseValidationResult(
                isValid: false,
                errorMessage: '字段 $key 类型错误: 期望 Number, 实际 ${actualValue.runtimeType}',
              );
            } else if (expectedType == 'boolean' && actualValue is! bool) {
              return ResponseValidationResult(
                isValid: false,
                errorMessage: '字段 $key 类型错误: 期望 Boolean, 实际 ${actualValue.runtimeType}',
              );
            } else if (expectedType == 'array' && actualValue is! List) {
              return ResponseValidationResult(
                isValid: false,
                errorMessage: '字段 $key 类型错误: 期望 Array, 实际 ${actualValue.runtimeType}',
              );
            } else if (expectedType == 'object' && actualValue is! Map) {
              return ResponseValidationResult(
                isValid: false,
                errorMessage: '字段 $key 类型错误: 期望 Object, 实际 ${actualValue.runtimeType}',
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
  
  /// 测试健康检查端点
  Future<APITestResult> testHealthCheck() async {
    return await testAPI(
      module: '系统健康检查',
      function: '健康检查',
      endpoint: '/health',
      method: 'GET',
      expectedStatusCode: 200,
      requiresAuth: false,
      expectedResponseStructure: {
        'status': 'string',
        'message': 'string',
      },
    );
  }
  
  /// 测试用户认证模块
  Future<List<APITestResult>> testAuthModule() async {
    print('🔐 测试用户认证模块...');
    final results = <APITestResult>[];
    
    // 测试用户注册
    final registerResult = await testAPI(
      module: '用户认证',
      function: '用户注册',
      endpoint: '/auth/register',
      method: 'POST',
      requestData: {
        'username': 'testuser_${DateTime.now().millisecondsSinceEpoch}',
        'email': 'test_${DateTime.now().millisecondsSinceEpoch}@example.com',
        'password': 'Test123456!',
        'first_name': '测试',
        'last_name': '用户',
      },
      expectedStatusCode: 201,
      requiresAuth: false,
      expectedResponseStructure: {
        'data': {
          'user': 'object',
          'token': 'string',
        },
      },
    );
    results.add(registerResult);
    
    // 如果注册成功，保存token用于后续测试
    if (registerResult.status == APITestStatus.passed && registerResult.responseData != null) {
      final token = registerResult.responseData['data']['token'];
      setAuthToken(token);
    }
    
    // 测试用户登录
    final loginResult = await testAPI(
      module: '用户认证',
      function: '用户登录',
      endpoint: '/auth/login',
      method: 'POST',
      requestData: {
        'email': 'test_${DateTime.now().millisecondsSinceEpoch}@example.com',
        'password': 'Test123456!',
      },
      expectedStatusCode: 200,
      requiresAuth: false,
      expectedResponseStructure: {
        'data': {
          'user': 'object',
          'token': 'string',
        },
      },
    );
    results.add(loginResult);
    
    // 测试获取用户资料
    final profileResult = await testAPI(
      module: '用户认证',
      function: '获取用户资料',
      endpoint: '/profile',
      method: 'GET',
      expectedStatusCode: 200,
      expectedResponseStructure: {
        'data': {
          'id': 'number',
          'username': 'string',
          'email': 'string',
        },
      },
    );
    results.add(profileResult);
    
    // 测试更新用户资料
    final updateProfileResult = await testAPI(
      module: '用户认证',
      function: '更新用户资料',
      endpoint: '/profile',
      method: 'PUT',
      requestData: {
        'first_name': '更新测试',
        'last_name': '用户',
        'bio': '自动化测试用户',
      },
      expectedStatusCode: 200,
      expectedResponseStructure: {
        'data': {
          'id': 'number',
          'username': 'string',
          'email': 'string',
        },
      },
    );
    results.add(updateProfileResult);
    
    // 测试用户登出
    final logoutResult = await testAPI(
      module: '用户认证',
      function: '用户登出',
      endpoint: '/auth/logout',
      method: 'POST',
      expectedStatusCode: 200,
    );
    results.add(logoutResult);
    
    return results;
  }
  
  /// 测试运动记录模块
  Future<List<APITestResult>> testWorkoutModule() async {
    print('💪 测试运动记录模块...');
    final results = <APITestResult>[];
    
    // 测试获取训练记录
    final getWorkoutsResult = await testAPI(
      module: '运动记录',
      function: '获取训练记录',
      endpoint: '/workouts',
      method: 'GET',
      queryParams: {'page': 1, 'limit': 10},
      expectedStatusCode: 200,
      expectedResponseStructure: {
        'data': 'array',
        'pagination': 'object',
      },
    );
    results.add(getWorkoutsResult);
    
    // 测试创建训练记录
    final createWorkoutResult = await testAPI(
      module: '运动记录',
      function: '创建训练记录',
      endpoint: '/workouts',
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
      expectedStatusCode: 201,
      expectedResponseStructure: {
        'data': {
          'id': 'number',
          'name': 'string',
          'type': 'string',
          'duration': 'number',
          'calories': 'number',
        },
      },
    );
    results.add(createWorkoutResult);
    
    // 测试获取训练计划
    final getPlansResult = await testAPI(
      module: '运动记录',
      function: '获取训练计划',
      endpoint: '/plans',
      method: 'GET',
      queryParams: {'page': 1, 'limit': 10},
      expectedStatusCode: 200,
      expectedResponseStructure: {
        'data': 'array',
        'pagination': 'object',
      },
    );
    results.add(getPlansResult);
    
    // 测试获取运动动作
    final getExercisesResult = await testAPI(
      module: '运动记录',
      function: '获取运动动作',
      endpoint: '/plans/exercises',
      method: 'GET',
      queryParams: {'page': 1, 'limit': 20},
      expectedStatusCode: 200,
      expectedResponseStructure: {
        'data': 'array',
        'pagination': 'object',
      },
    );
    results.add(getExercisesResult);
    
    return results;
  }
  
  /// 测试BMI计算模块
  Future<List<APITestResult>> testBMIModule() async {
    print('📊 测试BMI计算模块...');
    final results = <APITestResult>[];
    
    // 测试BMI计算
    final calculateBMIResult = await testAPI(
      module: 'BMI计算',
      function: 'BMI计算',
      endpoint: '/bmi/calculate',
      method: 'POST',
      requestData: {
        'height': 175.0,
        'weight': 70.0,
        'age': 25,
        'gender': 'male',
      },
      expectedStatusCode: 200,
      expectedResponseStructure: {
        'data': {
          'bmi': 'number',
          'category': 'string',
          'recommendation': 'string',
        },
      },
    );
    results.add(calculateBMIResult);
    
    // 测试创建BMI记录
    final createBMIRecordResult = await testAPI(
      module: 'BMI计算',
      function: '创建BMI记录',
      endpoint: '/bmi/records',
      method: 'POST',
      requestData: {
        'height': 175.0,
        'weight': 70.0,
        'age': 25,
        'gender': 'male',
        'notes': '自动化测试记录',
      },
      expectedStatusCode: 201,
      expectedResponseStructure: {
        'data': {
          'id': 'number',
          'bmi': 'number',
          'created_at': 'string',
        },
      },
    );
    results.add(createBMIRecordResult);
    
    // 测试获取BMI记录
    final getBMIRecordsResult = await testAPI(
      module: 'BMI计算',
      function: '获取BMI记录',
      endpoint: '/bmi/records',
      method: 'GET',
      expectedStatusCode: 200,
      expectedResponseStructure: {
        'data': 'array',
      },
    );
    results.add(getBMIRecordsResult);
    
    return results;
  }
  
  /// 测试营养管理模块
  Future<List<APITestResult>> testNutritionModule() async {
    print('🥗 测试营养管理模块...');
    final results = <APITestResult>[];
    
    // 测试计算营养信息
    final calculateNutritionResult = await testAPI(
      module: '营养管理',
      function: '计算营养信息',
      endpoint: '/nutrition/calculate',
      method: 'POST',
      requestData: {
        'food_name': '苹果',
        'quantity': 100.0,
        'unit': 'g',
      },
      expectedStatusCode: 200,
      expectedResponseStructure: {
        'data': {
          'calories': 'number',
          'protein': 'number',
          'carbs': 'number',
          'fat': 'number',
        },
      },
    );
    results.add(calculateNutritionResult);
    
    // 测试搜索食物
    final searchFoodsResult = await testAPI(
      module: '营养管理',
      function: '搜索食物',
      endpoint: '/nutrition/search',
      method: 'GET',
      queryParams: {'q': '苹果'},
      expectedStatusCode: 200,
      expectedResponseStructure: {
        'data': 'array',
      },
    );
    results.add(searchFoodsResult);
    
    // 测试获取每日摄入
    final getDailyIntakeResult = await testAPI(
      module: '营养管理',
      function: '获取每日摄入',
      endpoint: '/nutrition/daily',
      method: 'GET',
      expectedStatusCode: 200,
      expectedResponseStructure: {
        'data': {
          'calories': 'number',
          'protein': 'number',
          'carbs': 'number',
          'fat': 'number',
        },
      },
    );
    results.add(getDailyIntakeResult);
    
    // 测试创建营养记录
    final createNutritionRecordResult = await testAPI(
      module: '营养管理',
      function: '创建营养记录',
      endpoint: '/nutrition/records',
      method: 'POST',
      requestData: {
        'date': DateTime.now().toIso8601String().split('T')[0],
        'meal_type': 'breakfast',
        'food_name': '苹果',
        'quantity': 100.0,
        'unit': 'g',
        'notes': '自动化测试记录',
      },
      expectedStatusCode: 201,
      expectedResponseStructure: {
        'data': {
          'id': 'number',
          'food_name': 'string',
          'quantity': 'number',
        },
      },
    );
    results.add(createNutritionRecordResult);
    
    // 测试获取营养记录
    final getNutritionRecordsResult = await testAPI(
      module: '营养管理',
      function: '获取营养记录',
      endpoint: '/nutrition/records',
      method: 'GET',
      queryParams: {'page': 1, 'limit': 20},
      expectedStatusCode: 200,
      expectedResponseStructure: {
        'data': 'array',
        'pagination': 'object',
      },
    );
    results.add(getNutritionRecordsResult);
    
    return results;
  }
  
  /// 测试社区功能模块
  Future<List<APITestResult>> testCommunityModule() async {
    print('👥 测试社区功能模块...');
    final results = <APITestResult>[];
    
    // 测试获取社区动态
    final getPostsResult = await testAPI(
      module: '社区功能',
      function: '获取社区动态',
      endpoint: '/community/posts',
      method: 'GET',
      queryParams: {'page': 1, 'limit': 10},
      expectedStatusCode: 200,
      expectedResponseStructure: {
        'data': 'array',
        'pagination': 'object',
      },
    );
    results.add(getPostsResult);
    
    // 测试发布动态
    final createPostResult = await testAPI(
      module: '社区功能',
      function: '发布动态',
      endpoint: '/community/posts',
      method: 'POST',
      requestData: {
        'content': '这是自动化测试发布的动态',
        'type': 'workout',
        'is_public': true,
      },
      expectedStatusCode: 201,
      expectedResponseStructure: {
        'data': {
          'id': 'number',
          'content': 'string',
          'created_at': 'string',
        },
      },
    );
    results.add(createPostResult);
    
    // 测试获取挑战列表
    final getChallengesResult = await testAPI(
      module: '社区功能',
      function: '获取挑战列表',
      endpoint: '/community/challenges',
      method: 'GET',
      queryParams: {'page': 1, 'limit': 10},
      expectedStatusCode: 200,
      expectedResponseStructure: {
        'data': 'array',
        'pagination': 'object',
      },
    );
    results.add(getChallengesResult);
    
    return results;
  }
  
  /// 测试签到功能模块
  Future<List<APITestResult>> testCheckinModule() async {
    print('✅ 测试签到功能模块...');
    final results = <APITestResult>[];
    
    // 测试获取签到记录
    final getCheckinsResult = await testAPI(
      module: '签到功能',
      function: '获取签到记录',
      endpoint: '/checkins',
      method: 'GET',
      queryParams: {'page': 1, 'limit': 30},
      expectedStatusCode: 200,
      expectedResponseStructure: {
        'data': 'array',
      },
    );
    results.add(getCheckinsResult);
    
    // 测试创建签到记录
    final createCheckinResult = await testAPI(
      module: '签到功能',
      function: '创建签到记录',
      endpoint: '/checkins',
      method: 'POST',
      requestData: {
        'type': 'workout',
        'notes': '自动化测试签到',
        'mood': 'happy',
        'energy': 8,
        'motivation': 9,
      },
      expectedStatusCode: 201,
      expectedResponseStructure: {
        'data': {
          'id': 'number',
          'type': 'string',
          'created_at': 'string',
        },
      },
    );
    results.add(createCheckinResult);
    
    // 测试获取签到日历
    final getCheckinCalendarResult = await testAPI(
      module: '签到功能',
      function: '获取签到日历',
      endpoint: '/checkins/calendar',
      method: 'GET',
      queryParams: {
        'year': DateTime.now().year,
        'month': DateTime.now().month,
      },
      expectedStatusCode: 200,
      expectedResponseStructure: {
        'data': 'object',
      },
    );
    results.add(getCheckinCalendarResult);
    
    // 测试获取签到连续天数
    final getCheckinStreakResult = await testAPI(
      module: '签到功能',
      function: '获取签到连续天数',
      endpoint: '/checkins/streak',
      method: 'GET',
      expectedStatusCode: 200,
      expectedResponseStructure: {
        'data': {
          'current_streak': 'number',
          'longest_streak': 'number',
        },
      },
    );
    results.add(getCheckinStreakResult);
    
    // 测试获取成就
    final getAchievementsResult = await testAPI(
      module: '签到功能',
      function: '获取成就',
      endpoint: '/checkins/achievements',
      method: 'GET',
      expectedStatusCode: 200,
      expectedResponseStructure: {
        'data': 'array',
      },
    );
    results.add(getAchievementsResult);
    
    return results;
  }
  
  /// 测试错误处理和边界条件
  Future<List<APITestResult>> testErrorHandling() async {
    print('🔍 测试错误处理和边界条件...');
    final results = <APITestResult>[];
    
    // 测试无效的API调用
    final invalidApiResult = await testAPI(
      module: '错误处理',
      function: '无效API调用',
      endpoint: '/invalid/endpoint',
      method: 'GET',
      expectedStatusCode: 404,
    );
    results.add(invalidApiResult);
    
    // 测试无效的认证
    clearAuthToken();
    final unauthorizedResult = await testAPI(
      module: '错误处理',
      function: '未认证访问',
      endpoint: '/profile',
      method: 'GET',
      expectedStatusCode: 401,
    );
    results.add(unauthorizedResult);
    
    // 测试无效的请求数据
    final invalidDataResult = await testAPI(
      module: '错误处理',
      function: '无效请求数据',
      endpoint: '/auth/login',
      method: 'POST',
      requestData: {
        'email': 'invalid-email',
        'password': '',
      },
      expectedStatusCode: 400,
      requiresAuth: false,
    );
    results.add(invalidDataResult);
    
    // 测试缺少必需字段
    final missingFieldResult = await testAPI(
      module: '错误处理',
      function: '缺少必需字段',
      endpoint: '/auth/register',
      method: 'POST',
      requestData: {
        'username': 'testuser',
        // 缺少email和password
      },
      expectedStatusCode: 400,
      requiresAuth: false,
    );
    results.add(missingFieldResult);
    
    return results;
  }
  
  /// 测试性能指标
  Future<List<APITestResult>> testPerformance() async {
    print('⚡ 测试性能指标...');
    final results = <APITestResult>[];
    
    // 测试多个API调用的响应时间
    for (int i = 0; i < 5; i++) {
      final result = await testAPI(
        module: '性能测试',
        function: 'API响应时间测试',
        endpoint: '/profile',
        method: 'GET',
        timeout: const Duration(seconds: 5),
      );
      results.add(result);
    }
    
    return results;
  }
  
  /// 执行全面API测试
  Future<APITestReport> runComprehensiveAPITests() async {
    print('🚀 开始执行 FitTracker 全面API测试...');
    _testResults.clear();
    
    final startTime = DateTime.now();
    
    try {
      // 测试各个模块
      final healthResult = await testHealthCheck();
      final authResults = await testAuthModule();
      final workoutResults = await testWorkoutModule();
      final bmiResults = await testBMIModule();
      final nutritionResults = await testNutritionModule();
      final communityResults = await testCommunityModule();
      final checkinResults = await testCheckinModule();
      final errorResults = await testErrorHandling();
      final performanceResults = await testPerformance();
      
      final endTime = DateTime.now();
      final totalDuration = endTime.difference(startTime).inMilliseconds;
      
      // 生成测试报告
      final report = APITestReport(
        testName: 'FitTracker 全面API测试',
        startTime: startTime,
        endTime: endTime,
        totalDuration: totalDuration,
        totalTests: _testResults.length,
        passedTests: _testResults.where((r) => r.status == APITestStatus.passed).length,
        failedTests: _testResults.where((r) => r.status == APITestStatus.failed).length,
        warningTests: _testResults.where((r) => r.status == APITestStatus.warning).length,
        testResults: _testResults,
        summary: _generateAPITestSummary(),
      );
      
      print('✅ API测试完成！');
      print('📊 测试统计:');
      print('   总测试数: ${report.totalTests}');
      print('   通过: ${report.passedTests}');
      print('   失败: ${report.failedTests}');
      print('   警告: ${report.warningTests}');
      print('   总耗时: ${report.totalDuration}ms');
      
      return report;
      
    } catch (e) {
      print('❌ API测试执行失败: $e');
      rethrow;
    }
  }
  
  /// 生成API测试摘要
  String _generateAPITestSummary() {
    final totalTests = _testResults.length;
    final passedTests = _testResults.where((r) => r.status == APITestStatus.passed).length;
    final failedTests = _testResults.where((r) => r.status == APITestStatus.failed).length;
    final warningTests = _testResults.where((r) => r.status == APITestStatus.warning).length;
    
    final successRate = totalTests > 0 ? (passedTests / totalTests * 100).toStringAsFixed(2) : '0.00';
    
    return '''
API测试摘要:
- 总测试数: $totalTests
- 通过: $passedTests (${successRate}%)
- 失败: $failedTests
- 警告: $warningTests
- 成功率: ${successRate}%

模块测试结果:
${_getAPIModuleSummary()}
''';
  }
  
  /// 获取API模块测试摘要
  String _getAPIModuleSummary() {
    final moduleGroups = <String, List<APITestResult>>{};
    
    for (final result in _testResults) {
      moduleGroups.putIfAbsent(result.module, () => []).add(result);
    }
    
    final summary = StringBuffer();
    for (final entry in moduleGroups.entries) {
      final module = entry.key;
      final results = entry.value;
      final passed = results.where((r) => r.status == APITestStatus.passed).length;
      final failed = results.where((r) => r.status == APITestStatus.failed).length;
      final warning = results.where((r) => r.status == APITestStatus.warning).length;
      
      summary.writeln('- $module: $passed 通过, $failed 失败, $warning 警告');
    }
    
    return summary.toString();
  }
  
  /// 生成JSON格式的API测试报告
  Map<String, dynamic> generateJsonReport(APITestReport report) {
    return {
      'apiTestReport': {
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
          'endpoint': result.endpoint,
          'method': result.method,
          'requestData': result.requestData,
          'queryParams': result.queryParams,
          'responseData': result.responseData,
          'statusCode': result.statusCode,
          'responseTime': result.responseTime,
          'status': result.status.toString().split('.').last,
          'errorMessage': result.errorMessage,
          'timestamp': result.timestamp.toIso8601String(),
        }).toList(),
      },
    };
  }
  
  /// 生成Markdown格式的API测试报告
  String generateMarkdownReport(APITestReport report) {
    final buffer = StringBuffer();
    
    buffer.writeln('# FitTracker API 自动化测试报告');
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
    final moduleGroups = <String, List<APITestResult>>{};
    for (final result in report.testResults) {
      moduleGroups.putIfAbsent(result.module, () => []).add(result);
    }
    
    for (final entry in moduleGroups.entries) {
      final module = entry.key;
      final results = entry.value;
      
      buffer.writeln('### $module');
      buffer.writeln();
      
      for (final result in results) {
        final statusIcon = result.status == APITestStatus.passed ? '✅' : 
                          result.status == APITestStatus.failed ? '❌' : '⚠️';
        
        buffer.writeln('#### $statusIcon ${result.function}');
        buffer.writeln();
        buffer.writeln('| 项目 | 值 |');
        buffer.writeln('|------|-----|');
        buffer.writeln('| API端点 | `${result.method} ${result.endpoint}` |');
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
        
        if (result.errorMessage != null) {
          buffer.writeln('| 错误信息 | ${result.errorMessage} |');
        }
        
        buffer.writeln();
      }
    }
    
    return buffer.toString();
  }
  
  /// 保存API测试报告到文件
  Future<void> saveReportToFile(APITestReport report, {String? filename}) async {
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
    final defaultFilename = filename ?? 'fittracker_api_test_report_$timestamp';
    
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

/// API测试结果类
class APITestResult {
  final String module;
  final String function;
  final String endpoint;
  final String method;
  final Map<String, dynamic>? requestData;
  final Map<String, dynamic>? queryParams;
  final DateTime timestamp;
  
  dynamic responseData;
  int? statusCode;
  int? responseTime;
  APITestStatus status = APITestStatus.pending;
  String? errorMessage;
  
  APITestResult({
    required this.module,
    required this.function,
    required this.endpoint,
    required this.method,
    this.requestData,
    this.queryParams,
    required this.timestamp,
  });
}

/// API测试状态枚举
enum APITestStatus {
  pending,
  passed,
  failed,
  warning,
}

/// API测试报告类
class APITestReport {
  final String testName;
  final DateTime startTime;
  final DateTime endTime;
  final int totalDuration;
  final int totalTests;
  final int passedTests;
  final int failedTests;
  final int warningTests;
  final List<APITestResult> testResults;
  final String summary;
  
  APITestReport({
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
