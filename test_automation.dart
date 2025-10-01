import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

/// FitTracker 自动化功能测试脚本
/// 测试所有核心功能和特色功能
class FitTrackerTester {
  final Dio _dio = Dio();
  final String baseUrl = 'http://localhost:8080/api/v1';
  String? authToken;
  Map<String, dynamic> testResults = {};

  FitTrackerTester() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = Duration(seconds: 10);
    _dio.options.receiveTimeout = Duration(seconds: 10);
  }

  /// 运行所有测试
  Future<Map<String, dynamic>> runAllTests() async {
    print('🚀 开始 FitTracker 自动化测试...\n');
    
    // 测试后端服务状态
    await _testBackendHealth();
    
    // 测试用户认证功能
    await _testUserAuthentication();
    
    // 测试BMI计算器
    await _testBMICalculator();
    
    // 测试营养计算器
    await _testNutritionCalculator();
    
    // 测试运动追踪
    await _testWorkoutTracking();
    
    // 测试训练计划
    await _testTrainingPlans();
    
    // 测试健康监测
    await _testHealthMonitoring();
    
    // 测试社区互动
    await _testCommunityFeatures();
    
    // 测试签到功能
    await _testCheckinSystem();
    
    // 测试AI特色功能
    await _testAIFeatures();
    
    return testResults;
  }

  /// 测试后端服务健康状态
  Future<void> _testBackendHealth() async {
    print('📡 测试后端服务健康状态...');
    try {
      final response = await _dio.get('/health');
      if (response.statusCode == 200) {
        testResults['backend_health'] = {
          'status': '✅ 通过',
          'response': response.data,
          'timestamp': DateTime.now().toIso8601String()
        };
        print('✅ 后端服务健康检查通过');
      } else {
        testResults['backend_health'] = {
          'status': '❌ 失败',
          'error': 'HTTP ${response.statusCode}',
          'timestamp': DateTime.now().toIso8601String()
        };
        print('❌ 后端服务健康检查失败');
      }
    } catch (e) {
      testResults['backend_health'] = {
        'status': '❌ 失败',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String()
      };
      print('❌ 后端服务连接失败: $e');
    }
    print('');
  }

  /// 测试用户认证功能
  Future<void> _testUserAuthentication() async {
    print('🔐 测试用户认证功能...');
    
    // 测试用户注册
    try {
      final registerData = {
        'username': 'testuser_${DateTime.now().millisecondsSinceEpoch}',
        'email': 'test_${DateTime.now().millisecondsSinceEpoch}@example.com',
        'password': 'TestPassword123!',
        'first_name': 'Test',
        'last_name': 'User'
      };
      
      final response = await _dio.post('/auth/register', data: registerData);
      if (response.statusCode == 201 || response.statusCode == 200) {
        testResults['user_registration'] = {
          'status': '✅ 通过',
          'data': response.data,
          'timestamp': DateTime.now().toIso8601String()
        };
        print('✅ 用户注册测试通过');
        
        // 测试用户登录
        try {
          final loginData = {
            'email': registerData['email'],
            'password': registerData['password']
          };
          
          final loginResponse = await _dio.post('/auth/login', data: loginData);
          if (loginResponse.statusCode == 200) {
            authToken = loginResponse.data['token'];
            testResults['user_login'] = {
              'status': '✅ 通过',
              'token_received': authToken != null,
              'timestamp': DateTime.now().toIso8601String()
            };
            print('✅ 用户登录测试通过');
          } else {
            testResults['user_login'] = {
              'status': '❌ 失败',
              'error': 'HTTP ${loginResponse.statusCode}',
              'timestamp': DateTime.now().toIso8601String()
            };
            print('❌ 用户登录测试失败');
          }
        } catch (e) {
          testResults['user_login'] = {
            'status': '❌ 失败',
            'error': e.toString(),
            'timestamp': DateTime.now().toIso8601String()
          };
          print('❌ 用户登录测试失败: $e');
        }
      } else {
        testResults['user_registration'] = {
          'status': '❌ 失败',
          'error': 'HTTP ${response.statusCode}',
          'timestamp': DateTime.now().toIso8601String()
        };
        print('❌ 用户注册测试失败');
      }
    } catch (e) {
      testResults['user_registration'] = {
        'status': '❌ 失败',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String()
      };
      print('❌ 用户注册测试失败: $e');
    }
    print('');
  }

  /// 测试BMI计算器
  Future<void> _testBMICalculator() async {
    print('📊 测试BMI计算器...');
    
    if (authToken == null) {
      testResults['bmi_calculator'] = {
        'status': '⚠️ 跳过',
        'reason': '需要认证token',
        'timestamp': DateTime.now().toIso8601String()
      };
      print('⚠️ BMI计算器测试跳过 - 需要认证');
      print('');
      return;
    }

    try {
      final bmiData = {
        'height': 175,
        'weight': 70,
        'age': 25,
        'gender': 'male'
      };
      
      _dio.options.headers['Authorization'] = 'Bearer $authToken';
      final response = await _dio.post('/bmi/calculate', data: bmiData);
      
      if (response.statusCode == 200) {
        final bmiResult = response.data;
        testResults['bmi_calculator'] = {
          'status': '✅ 通过',
          'bmi_value': bmiResult['bmi'],
          'health_status': bmiResult['status'],
          'recommendation': bmiResult['recommendation'],
          'timestamp': DateTime.now().toIso8601String()
        };
        print('✅ BMI计算器测试通过 - BMI: ${bmiResult['bmi']}, 状态: ${bmiResult['status']}');
      } else {
        testResults['bmi_calculator'] = {
          'status': '❌ 失败',
          'error': 'HTTP ${response.statusCode}',
          'timestamp': DateTime.now().toIso8601String()
        };
        print('❌ BMI计算器测试失败');
      }
    } catch (e) {
      testResults['bmi_calculator'] = {
        'status': '❌ 失败',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String()
      };
      print('❌ BMI计算器测试失败: $e');
    }
    print('');
  }

  /// 测试营养计算器
  Future<void> _testNutritionCalculator() async {
    print('🥗 测试营养计算器...');
    
    if (authToken == null) {
      testResults['nutrition_calculator'] = {
        'status': '⚠️ 跳过',
        'reason': '需要认证token',
        'timestamp': DateTime.now().toIso8601String()
      };
      print('⚠️ 营养计算器测试跳过 - 需要认证');
      print('');
      return;
    }

    try {
      // 测试食物搜索
      final searchResponse = await _dio.get('/nutrition/search?q=鸡胸肉');
      if (searchResponse.statusCode == 200) {
        print('✅ 食物搜索功能正常');
        
        // 测试营养计算
        final nutritionData = {
          'food_name': '鸡胸肉',
          'quantity': 100,
          'unit': 'g'
        };
        
        final calcResponse = await _dio.post('/nutrition/calculate', data: nutritionData);
        if (calcResponse.statusCode == 200) {
          testResults['nutrition_calculator'] = {
            'status': '✅ 通过',
            'calories': calcResponse.data['calories'],
            'protein': calcResponse.data['protein'],
            'carbs': calcResponse.data['carbs'],
            'fat': calcResponse.data['fat'],
            'timestamp': DateTime.now().toIso8601String()
          };
          print('✅ 营养计算器测试通过 - 热量: ${calcResponse.data['calories']}kcal');
        } else {
          testResults['nutrition_calculator'] = {
            'status': '❌ 失败',
            'error': '营养计算失败',
            'timestamp': DateTime.now().toIso8601String()
          };
          print('❌ 营养计算器测试失败');
        }
      } else {
        testResults['nutrition_calculator'] = {
          'status': '❌ 失败',
          'error': '食物搜索失败',
          'timestamp': DateTime.now().toIso8601String()
        };
        print('❌ 营养计算器测试失败');
      }
    } catch (e) {
      testResults['nutrition_calculator'] = {
        'status': '❌ 失败',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String()
      };
      print('❌ 营养计算器测试失败: $e');
    }
    print('');
  }

  /// 测试运动追踪
  Future<void> _testWorkoutTracking() async {
    print('💪 测试运动追踪...');
    
    if (authToken == null) {
      testResults['workout_tracking'] = {
        'status': '⚠️ 跳过',
        'reason': '需要认证token',
        'timestamp': DateTime.now().toIso8601String()
      };
      print('⚠️ 运动追踪测试跳过 - 需要认证');
      print('');
      return;
    }

    try {
      // 创建运动记录
      final workoutData = {
        'name': '测试训练',
        'type': '力量训练',
        'duration': 60,
        'calories': 300,
        'difficulty': '中级',
        'notes': '自动化测试记录',
        'rating': 4.5
      };
      
      final createResponse = await _dio.post('/workouts', data: workoutData);
      if (createResponse.statusCode == 201 || createResponse.statusCode == 200) {
        final workoutId = createResponse.data['id'];
        print('✅ 运动记录创建成功');
        
        // 获取运动记录列表
        final listResponse = await _dio.get('/workouts');
        if (listResponse.statusCode == 200) {
          testResults['workout_tracking'] = {
            'status': '✅ 通过',
            'workout_created': true,
            'workout_id': workoutId,
            'total_workouts': listResponse.data['total'],
            'timestamp': DateTime.now().toIso8601String()
          };
          print('✅ 运动追踪测试通过 - 总记录数: ${listResponse.data['total']}');
        } else {
          testResults['workout_tracking'] = {
            'status': '❌ 失败',
            'error': '获取运动记录失败',
            'timestamp': DateTime.now().toIso8601String()
          };
          print('❌ 运动追踪测试失败');
        }
      } else {
        testResults['workout_tracking'] = {
          'status': '❌ 失败',
          'error': '创建运动记录失败',
          'timestamp': DateTime.now().toIso8601String()
        };
        print('❌ 运动追踪测试失败');
      }
    } catch (e) {
      testResults['workout_tracking'] = {
        'status': '❌ 失败',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String()
      };
      print('❌ 运动追踪测试失败: $e');
    }
    print('');
  }

  /// 测试训练计划
  Future<void> _testTrainingPlans() async {
    print('📋 测试训练计划...');
    
    if (authToken == null) {
      testResults['training_plans'] = {
        'status': '⚠️ 跳过',
        'reason': '需要认证token',
        'timestamp': DateTime.now().toIso8601String()
      };
      print('⚠️ 训练计划测试跳过 - 需要认证');
      print('');
      return;
    }

    try {
      // 获取训练计划列表
      final plansResponse = await _dio.get('/plans');
      if (plansResponse.statusCode == 200) {
        // 获取运动动作列表
        final exercisesResponse = await _dio.get('/plans/exercises');
        if (exercisesResponse.statusCode == 200) {
          testResults['training_plans'] = {
            'status': '✅ 通过',
            'plans_count': plansResponse.data['total'] ?? 0,
            'exercises_count': exercisesResponse.data['total'] ?? 0,
            'timestamp': DateTime.now().toIso8601String()
          };
          print('✅ 训练计划测试通过 - 计划数: ${plansResponse.data['total'] ?? 0}, 动作数: ${exercisesResponse.data['total'] ?? 0}');
        } else {
          testResults['training_plans'] = {
            'status': '❌ 失败',
            'error': '获取运动动作失败',
            'timestamp': DateTime.now().toIso8601String()
          };
          print('❌ 训练计划测试失败');
        }
      } else {
        testResults['training_plans'] = {
          'status': '❌ 失败',
          'error': '获取训练计划失败',
          'timestamp': DateTime.now().toIso8601String()
        };
        print('❌ 训练计划测试失败');
      }
    } catch (e) {
      testResults['training_plans'] = {
        'status': '❌ 失败',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String()
      };
      print('❌ 训练计划测试失败: $e');
    }
    print('');
  }

  /// 测试健康监测
  Future<void> _testHealthMonitoring() async {
    print('❤️ 测试健康监测...');
    
    if (authToken == null) {
      testResults['health_monitoring'] = {
        'status': '⚠️ 跳过',
        'reason': '需要认证token',
        'timestamp': DateTime.now().toIso8601String()
      };
      print('⚠️ 健康监测测试跳过 - 需要认证');
      print('');
      return;
    }

    try {
      // 获取用户统计信息
      final statsResponse = await _dio.get('/profile/stats');
      if (statsResponse.statusCode == 200) {
        testResults['health_monitoring'] = {
          'status': '✅ 通过',
          'user_stats': statsResponse.data,
          'timestamp': DateTime.now().toIso8601String()
        };
        print('✅ 健康监测测试通过 - 用户统计信息获取成功');
      } else {
        testResults['health_monitoring'] = {
          'status': '❌ 失败',
          'error': '获取用户统计失败',
          'timestamp': DateTime.now().toIso8601String()
        };
        print('❌ 健康监测测试失败');
      }
    } catch (e) {
      testResults['health_monitoring'] = {
        'status': '❌ 失败',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String()
      };
      print('❌ 健康监测测试失败: $e');
    }
    print('');
  }

  /// 测试社区互动
  Future<void> _testCommunityFeatures() async {
    print('👥 测试社区互动...');
    
    if (authToken == null) {
      testResults['community_features'] = {
        'status': '⚠️ 跳过',
        'reason': '需要认证token',
        'timestamp': DateTime.now().toIso8601String()
      };
      print('⚠️ 社区互动测试跳过 - 需要认证');
      print('');
      return;
    }

    try {
      // 创建社区帖子
      final postData = {
        'content': '自动化测试帖子 - ${DateTime.now()}',
        'type': '训练',
        'is_public': true
      };
      
      final createResponse = await _dio.post('/community/posts', data: postData);
      if (createResponse.statusCode == 201 || createResponse.statusCode == 200) {
        final postId = createResponse.data['id'];
        print('✅ 社区帖子创建成功');
        
        // 获取社区帖子列表
        final postsResponse = await _dio.get('/community/posts');
        if (postsResponse.statusCode == 200) {
          testResults['community_features'] = {
            'status': '✅ 通过',
            'post_created': true,
            'post_id': postId,
            'total_posts': postsResponse.data['total'] ?? 0,
            'timestamp': DateTime.now().toIso8601String()
          };
          print('✅ 社区互动测试通过 - 总帖子数: ${postsResponse.data['total'] ?? 0}');
        } else {
          testResults['community_features'] = {
            'status': '❌ 失败',
            'error': '获取社区帖子失败',
            'timestamp': DateTime.now().toIso8601String()
          };
          print('❌ 社区互动测试失败');
        }
      } else {
        testResults['community_features'] = {
          'status': '❌ 失败',
          'error': '创建社区帖子失败',
          'timestamp': DateTime.now().toIso8601String()
        };
        print('❌ 社区互动测试失败');
      }
    } catch (e) {
      testResults['community_features'] = {
        'status': '❌ 失败',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String()
      };
      print('❌ 社区互动测试失败: $e');
    }
    print('');
  }

  /// 测试签到功能
  Future<void> _testCheckinSystem() async {
    print('📅 测试签到功能...');
    
    if (authToken == null) {
      testResults['checkin_system'] = {
        'status': '⚠️ 跳过',
        'reason': '需要认证token',
        'timestamp': DateTime.now().toIso8601String()
      };
      print('⚠️ 签到功能测试跳过 - 需要认证');
      print('');
      return;
    }

    try {
      // 创建签到记录
      final checkinData = {
        'type': '训练',
        'notes': '自动化测试签到',
        'mood': '开心',
        'energy': 8,
        'motivation': 9
      };
      
      final createResponse = await _dio.post('/checkins', data: checkinData);
      if (createResponse.statusCode == 201 || createResponse.statusCode == 200) {
        print('✅ 签到记录创建成功');
        
        // 获取签到统计
        final streakResponse = await _dio.get('/checkins/streak');
        if (streakResponse.statusCode == 200) {
          testResults['checkin_system'] = {
            'status': '✅ 通过',
            'checkin_created': true,
            'current_streak': streakResponse.data['current_streak'] ?? 0,
            'longest_streak': streakResponse.data['longest_streak'] ?? 0,
            'timestamp': DateTime.now().toIso8601String()
          };
          print('✅ 签到功能测试通过 - 当前连续: ${streakResponse.data['current_streak'] ?? 0}天');
        } else {
          testResults['checkin_system'] = {
            'status': '❌ 失败',
            'error': '获取签到统计失败',
            'timestamp': DateTime.now().toIso8601String()
          };
          print('❌ 签到功能测试失败');
        }
      } else {
        testResults['checkin_system'] = {
          'status': '❌ 失败',
          'error': '创建签到记录失败',
          'timestamp': DateTime.now().toIso8601String()
        };
        print('❌ 签到功能测试失败');
      }
    } catch (e) {
      testResults['checkin_system'] = {
        'status': '❌ 失败',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String()
      };
      print('❌ 签到功能测试失败: $e');
    }
    print('');
  }

  /// 测试AI特色功能
  Future<void> _testAIFeatures() async {
    print('🤖 测试AI特色功能...');
    
    // AI功能目前在后端可能还未完全实现，先测试基础功能
    testResults['ai_features'] = {
      'status': '⚠️ 待实现',
      'note': 'AI训练计划生成、实时运动指导、健康数据趋势分析等功能需要进一步开发',
      'timestamp': DateTime.now().toIso8601String()
    };
    print('⚠️ AI特色功能待实现 - 需要进一步开发');
    print('');
  }

  /// 生成测试报告
  void generateReport() {
    print('📊 测试报告生成中...\n');
    
    int totalTests = testResults.length;
    int passedTests = testResults.values.where((result) => result['status'].toString().contains('✅')).length;
    int failedTests = testResults.values.where((result) => result['status'].toString().contains('❌')).length;
    int skippedTests = testResults.values.where((result) => result['status'].toString().contains('⚠️')).length;
    
    print('=' * 60);
    print('📋 FitTracker 自动化测试报告');
    print('=' * 60);
    print('测试时间: ${DateTime.now().toIso8601String()}');
    print('总测试数: $totalTests');
    print('通过测试: $passedTests');
    print('失败测试: $failedTests');
    print('跳过测试: $skippedTests');
    print('成功率: ${((passedTests / totalTests) * 100).toStringAsFixed(1)}%');
    print('=' * 60);
    
    print('\n📊 详细测试结果:');
    testResults.forEach((testName, result) {
      print('${result['status']} $testName');
      if (result['error'] != null) {
        print('   错误: ${result['error']}');
      }
      if (result['note'] != null) {
        print('   备注: ${result['note']}');
      }
    });
    
    print('\n🎯 测试总结:');
    if (passedTests == totalTests) {
      print('🎉 所有测试通过！FitTracker应用功能完整！');
    } else if (passedTests > failedTests) {
      print('✅ 大部分测试通过，应用基本功能正常！');
    } else {
      print('⚠️ 部分测试失败，需要进一步修复！');
    }
    
    print('\n📝 建议:');
    print('1. 确保后端服务正常运行');
    print('2. 检查数据库连接状态');
    print('3. 验证API端点配置');
    print('4. 完善AI特色功能实现');
    print('5. 进行移动端UI测试');
  }
}

/// 主函数
void main() async {
  final tester = FitTrackerTester();
  await tester.runAllTests();
  tester.generateReport();
}
