import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// FitTracker 按钮驱动 API 联调测试页面
/// 在移动端进行真实的按钮点击测试，验证API调用、数据库写入和UI更新
class ButtonDrivenTestPage extends StatefulWidget {
  @override
  _ButtonDrivenTestPageState createState() => _ButtonDrivenTestPageState();
}

class _ButtonDrivenTestPageState extends State<ButtonDrivenTestPage> {
  final Dio _dio = Dio();
  final String baseUrl = 'http://10.0.2.2:8080/api/v1'; // Android模拟器地址
  
  String? authToken;
  String? userId;
  bool isLoggedIn = false;
  String testStatus = '未开始';
  List<Map<String, dynamic>> testResults = [];
  List<Map<String, dynamic>> communityPosts = [];
  String? currentPostId;
  
  // 测试数据
  final TextEditingController _postContentController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _bmiHeightController = TextEditingController(text: '175');
  final TextEditingController _bmiWeightController = TextEditingController(text: '70');

  @override
  void initState() {
    super.initState();
    _initializeApi();
    _loadStoredToken();
  }

  void _initializeApi() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = Duration(seconds: 15);
    _dio.options.receiveTimeout = Duration(seconds: 15);
    
    // 添加请求日志
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('[API] $obj'),
    ));
  }

  Future<void> _loadStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      setState(() {
        authToken = token;
        isLoggedIn = true;
        _dio.options.headers['Authorization'] = 'Bearer $token';
      });
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    setState(() {
      authToken = token;
      isLoggedIn = true;
      _dio.options.headers['Authorization'] = 'Bearer $token';
    });
  }

  void _addTestResult(String buttonName, String status, String details) {
    setState(() {
      testResults.add({
        'button': buttonName,
        'status': status,
        'details': details,
        'timestamp': DateTime.now().toIso8601String(),
      });
    });
  }

  // ==================== 认证相关按钮测试 ====================
  
  Future<void> _testRegisterButton() async {
    setState(() => testStatus = '测试注册按钮...');
    
    try {
      final registerData = {
        'username': 'testuser_${DateTime.now().millisecondsSinceEpoch}',
        'email': 'test_${DateTime.now().millisecondsSinceEpoch}@example.com',
        'password': 'TestPassword123!',
        'first_name': 'Test',
        'last_name': 'User'
      };
      
      final response = await _dio.post('/auth/register', data: registerData);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _addTestResult('注册按钮', '✅ 通过', '用户注册成功');
        
        // 自动登录
        await _testLoginButton(registerData['email'], registerData['password']);
      } else {
        _addTestResult('注册按钮', '❌ 失败', 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      _addTestResult('注册按钮', '❌ 失败', e.toString());
    }
    
    setState(() => testStatus = '注册测试完成');
  }

  Future<void> _testLoginButton([String? email, String? password]) async {
    setState(() => testStatus = '测试登录按钮...');
    
    try {
      final loginData = {
        'email': email ?? 'test@example.com',
        'password': password ?? 'TestPassword123!'
      };
      
      final response = await _dio.post('/auth/login', data: loginData);
      
      if (response.statusCode == 200) {
        final token = response.data['token'];
        final userId = response.data['user_id'];
        
        if (token != null) {
          await _saveToken(token);
          _addTestResult('登录按钮', '✅ 通过', '登录成功，获取token');
        } else {
          _addTestResult('登录按钮', '❌ 失败', '未获取到token');
        }
      } else {
        _addTestResult('登录按钮', '❌ 失败', 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      _addTestResult('登录按钮', '❌ 失败', e.toString());
    }
    
    setState(() => testStatus = '登录测试完成');
  }

  // ==================== BMI计算器按钮测试 ====================
  
  Future<void> _testBMICalculateButton() async {
    if (!isLoggedIn) {
      _addTestResult('BMI计算按钮', '⚠️ 跳过', '需要先登录');
      return;
    }
    
    setState(() => testStatus = '测试BMI计算按钮...');
    
    try {
      final bmiData = {
        'height': double.parse(_bmiHeightController.text),
        'weight': double.parse(_bmiWeightController.text),
        'age': 25,
        'gender': 'male'
      };
      
      final response = await _dio.post('/bmi/calculate', data: bmiData);
      
      if (response.statusCode == 200) {
        final bmi = response.data['bmi'];
        final status = response.data['status'];
        _addTestResult('BMI计算按钮', '✅ 通过', 'BMI: $bmi, 状态: $status');
      } else {
        _addTestResult('BMI计算按钮', '❌ 失败', 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      _addTestResult('BMI计算按钮', '❌ 失败', e.toString());
    }
    
    setState(() => testStatus = 'BMI计算测试完成');
  }

  Future<void> _testBMIHistoryButton() async {
    if (!isLoggedIn) {
      _addTestResult('BMI历史按钮', '⚠️ 跳过', '需要先登录');
      return;
    }
    
    setState(() => testStatus = '测试BMI历史按钮...');
    
    try {
      final response = await _dio.get('/bmi/records');
      
      if (response.statusCode == 200) {
        final records = response.data is List ? response.data : response.data['records'];
        _addTestResult('BMI历史按钮', '✅ 通过', '获取到 ${records?.length ?? 0} 条记录');
      } else {
        _addTestResult('BMI历史按钮', '❌ 失败', 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      _addTestResult('BMI历史按钮', '❌ 失败', e.toString());
    }
    
    setState(() => testStatus = 'BMI历史测试完成');
  }

  // ==================== 社区功能按钮测试 ====================
  
  Future<void> _testCreatePostButton() async {
    if (!isLoggedIn) {
      _addTestResult('发布动态按钮', '⚠️ 跳过', '需要先登录');
      return;
    }
    
    setState(() => testStatus = '测试发布动态按钮...');
    
    try {
      final postData = {
        'content': _postContentController.text.isNotEmpty 
            ? _postContentController.text 
            : '自动化测试动态 - ${DateTime.now()}',
        'type': '训练',
        'is_public': true,
        'images': [],
        'tags': ['测试', '自动化']
      };
      
      final response = await _dio.post('/community/posts', data: postData);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        currentPostId = response.data['id']?.toString();
        _addTestResult('发布动态按钮', '✅ 通过', '动态发布成功，ID: $currentPostId');
        
        // 自动刷新动态列表
        await _testGetPostsButton();
      } else {
        _addTestResult('发布动态按钮', '❌ 失败', 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      _addTestResult('发布动态按钮', '❌ 失败', e.toString());
    }
    
    setState(() => testStatus = '发布动态测试完成');
  }

  Future<void> _testLikePostButton() async {
    if (!isLoggedIn) {
      _addTestResult('点赞按钮', '⚠️ 跳过', '需要先登录');
      return;
    }
    
    if (currentPostId == null) {
      _addTestResult('点赞按钮', '⚠️ 跳过', '需要先发布动态');
      return;
    }
    
    setState(() => testStatus = '测试点赞按钮...');
    
    try {
      final response = await _dio.post('/community/posts/$currentPostId/like');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _addTestResult('点赞按钮', '✅ 通过', '点赞成功');
      } else {
        _addTestResult('点赞按钮', '❌ 失败', 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      _addTestResult('点赞按钮', '❌ 失败', e.toString());
    }
    
    setState(() => testStatus = '点赞测试完成');
  }

  Future<void> _testCommentPostButton() async {
    if (!isLoggedIn) {
      _addTestResult('评论按钮', '⚠️ 跳过', '需要先登录');
      return;
    }
    
    if (currentPostId == null) {
      _addTestResult('评论按钮', '⚠️ 跳过', '需要先发布动态');
      return;
    }
    
    setState(() => testStatus = '测试评论按钮...');
    
    try {
      final commentData = {
        'content': _commentController.text.isNotEmpty 
            ? _commentController.text 
            : '这是一条自动化测试评论'
      };
      
      final response = await _dio.post('/community/posts/$currentPostId/comments', data: commentData);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _addTestResult('评论按钮', '✅ 通过', '评论发布成功');
      } else {
        _addTestResult('评论按钮', '❌ 失败', 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      _addTestResult('评论按钮', '❌ 失败', e.toString());
    }
    
    setState(() => testStatus = '评论测试完成');
  }

  Future<void> _testGetPostsButton() async {
    if (!isLoggedIn) {
      _addTestResult('获取动态按钮', '⚠️ 跳过', '需要先登录');
      return;
    }
    
    setState(() => testStatus = '测试获取动态按钮...');
    
    try {
      final response = await _dio.get('/community/posts');
      
      if (response.statusCode == 200) {
        final posts = response.data is List ? response.data : response.data['posts'];
        setState(() {
          communityPosts = List<Map<String, dynamic>>.from(posts ?? []);
        });
        _addTestResult('获取动态按钮', '✅ 通过', '获取到 ${communityPosts.length} 条动态');
      } else {
        _addTestResult('获取动态按钮', '❌ 失败', 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      _addTestResult('获取动态按钮', '❌ 失败', e.toString());
    }
    
    setState(() => testStatus = '获取动态测试完成');
  }

  // ==================== 训练计划按钮测试 ====================
  
  Future<void> _testGetTrainingPlansButton() async {
    if (!isLoggedIn) {
      _addTestResult('获取训练计划按钮', '⚠️ 跳过', '需要先登录');
      return;
    }
    
    setState(() => testStatus = '测试获取训练计划按钮...');
    
    try {
      final response = await _dio.get('/workout/plans');
      
      if (response.statusCode == 200) {
        final plans = response.data is List ? response.data : response.data['plans'];
        _addTestResult('获取训练计划按钮', '✅ 通过', '获取到 ${plans?.length ?? 0} 个训练计划');
      } else {
        _addTestResult('获取训练计划按钮', '❌ 失败', 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      _addTestResult('获取训练计划按钮', '❌ 失败', e.toString());
    }
    
    setState(() => testStatus = '获取训练计划测试完成');
  }

  Future<void> _testCreateTrainingPlanButton() async {
    if (!isLoggedIn) {
      _addTestResult('创建训练计划按钮', '⚠️ 跳过', '需要先登录');
      return;
    }
    
    setState(() => testStatus = '测试创建训练计划按钮...');
    
    try {
      final planData = {
        'name': '自动化测试训练计划',
        'description': '通过按钮测试创建的训练计划',
        'type': '力量训练',
        'difficulty': '中级',
        'duration_weeks': 4,
        'exercises': [
          {
            'name': '俯卧撑',
            'sets': 3,
            'reps': 15,
            'rest_seconds': 60
          },
          {
            'name': '深蹲',
            'sets': 3,
            'reps': 20,
            'rest_seconds': 60
          }
        ]
      };
      
      final response = await _dio.post('/workout/plans', data: planData);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final planId = response.data['id'];
        _addTestResult('创建训练计划按钮', '✅ 通过', '训练计划创建成功，ID: $planId');
      } else {
        _addTestResult('创建训练计划按钮', '❌ 失败', 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      _addTestResult('创建训练计划按钮', '❌ 失败', e.toString());
    }
    
    setState(() => testStatus = '创建训练计划测试完成');
  }

  // ==================== AI功能按钮测试 ====================
  
  Future<void> _testAITrainingPlanButton() async {
    if (!isLoggedIn) {
      _addTestResult('AI训练计划按钮', '⚠️ 跳过', '需要先登录');
      return;
    }
    
    setState(() => testStatus = '测试AI训练计划按钮...');
    
    try {
      final aiData = {
        'goal': '增肌',
        'duration': 30,
        'difficulty': '中级',
        'equipment': ['哑铃', '杠铃'],
        'time_per_day': 60,
        'preferences': '力量训练'
      };
      
      final response = await _dio.post('/ai/training-plan', data: aiData);
      
      if (response.statusCode == 200) {
        final plan = response.data['plan'] ?? response.data['exercises'];
        _addTestResult('AI训练计划按钮', '✅ 通过', 'AI生成训练计划成功');
      } else {
        _addTestResult('AI训练计划按钮', '❌ 失败', 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      _addTestResult('AI训练计划按钮', '❌ 失败', e.toString());
    }
    
    setState(() => testStatus = 'AI训练计划测试完成');
  }

  Future<void> _testAIHealthAdviceButton() async {
    if (!isLoggedIn) {
      _addTestResult('AI健康建议按钮', '⚠️ 跳过', '需要先登录');
      return;
    }
    
    setState(() => testStatus = '测试AI健康建议按钮...');
    
    try {
      final adviceData = {
        'bmi': 22.5,
        'age': 25,
        'gender': 'male',
        'activity_level': 'moderate'
      };
      
      final response = await _dio.post('/ai/health-advice', data: adviceData);
      
      if (response.statusCode == 200) {
        final advice = response.data['advice'] ?? response.data['recommendations'];
        _addTestResult('AI健康建议按钮', '✅ 通过', 'AI生成健康建议成功');
      } else {
        _addTestResult('AI健康建议按钮', '❌ 失败', 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      _addTestResult('AI健康建议按钮', '❌ 失败', e.toString());
    }
    
    setState(() => testStatus = 'AI健康建议测试完成');
  }

  // ==================== 签到功能按钮测试 ====================
  
  Future<void> _testCheckinButton() async {
    if (!isLoggedIn) {
      _addTestResult('签到按钮', '⚠️ 跳过', '需要先登录');
      return;
    }
    
    setState(() => testStatus = '测试签到按钮...');
    
    try {
      final checkinData = {
        'type': '训练',
        'notes': '自动化测试签到',
        'mood': '开心',
        'energy': 8,
        'motivation': 9
      };
      
      final response = await _dio.post('/checkins', data: checkinData);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _addTestResult('签到按钮', '✅ 通过', '签到成功');
      } else {
        _addTestResult('签到按钮', '❌ 失败', 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      _addTestResult('签到按钮', '❌ 失败', e.toString());
    }
    
    setState(() => testStatus = '签到测试完成');
  }

  Future<void> _testCheckinStatsButton() async {
    if (!isLoggedIn) {
      _addTestResult('签到统计按钮', '⚠️ 跳过', '需要先登录');
      return;
    }
    
    setState(() => testStatus = '测试签到统计按钮...');
    
    try {
      final response = await _dio.get('/checkins/streak');
      
      if (response.statusCode == 200) {
        final streak = response.data['current_streak'] ?? response.data['total_checkins'];
        _addTestResult('签到统计按钮', '✅ 通过', '获取签到统计成功');
      } else {
        _addTestResult('签到统计按钮', '❌ 失败', 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      _addTestResult('签到统计按钮', '❌ 失败', e.toString());
    }
    
    setState(() => testStatus = '签到统计测试完成');
  }

  // ==================== 运行所有测试 ====================
  
  Future<void> _runAllTests() async {
    setState(() {
      testResults.clear();
      testStatus = '开始运行所有测试...';
    });

    // 认证测试
    await _testRegisterButton();
    await Future.delayed(Duration(seconds: 1));
    
    // BMI测试
    await _testBMICalculateButton();
    await _testBMIHistoryButton();
    await Future.delayed(Duration(seconds: 1));
    
    // 社区测试
    await _testCreatePostButton();
    await _testLikePostButton();
    await _testCommentPostButton();
    await _testGetPostsButton();
    await Future.delayed(Duration(seconds: 1));
    
    // 训练计划测试
    await _testGetTrainingPlansButton();
    await _testCreateTrainingPlanButton();
    await Future.delayed(Duration(seconds: 1));
    
    // AI功能测试
    await _testAITrainingPlanButton();
    await _testAIHealthAdviceButton();
    await Future.delayed(Duration(seconds: 1));
    
    // 签到测试
    await _testCheckinButton();
    await _testCheckinStatsButton();
    
    setState(() => testStatus = '所有测试完成');
  }

  void _clearResults() {
    setState(() {
      testResults.clear();
      communityPosts.clear();
      currentPostId = null;
      testStatus = '结果已清除';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('按钮驱动 API 测试'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _runAllTests,
            tooltip: '运行所有测试',
          ),
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: _clearResults,
            tooltip: '清除结果',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状态显示
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('测试状态', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('当前状态: $testStatus'),
                    Text('登录状态: ${isLoggedIn ? "已登录" : "未登录"}'),
                    if (authToken != null) Text('Token: ${authToken!.substring(0, 20)}...'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // 认证测试区域
            _buildTestSection(
              title: '🔐 认证测试',
              buttons: [
                _buildTestButton('注册按钮', _testRegisterButton),
                _buildTestButton('登录按钮', () => _testLoginButton()),
              ],
            ),
            
            // BMI测试区域
            _buildTestSection(
              title: '📊 BMI计算器测试',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _bmiHeightController,
                        decoration: InputDecoration(labelText: '身高(cm)'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _bmiWeightController,
                        decoration: InputDecoration(labelText: '体重(kg)'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    _buildTestButton('BMI计算', _testBMICalculateButton),
                    SizedBox(width: 8),
                    _buildTestButton('BMI历史', _testBMIHistoryButton),
                  ],
                ),
              ],
            ),
            
            // 社区测试区域
            _buildTestSection(
              title: '👥 社区功能测试',
              children: [
                TextField(
                  controller: _postContentController,
                  decoration: InputDecoration(labelText: '动态内容'),
                  maxLines: 2,
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _commentController,
                  decoration: InputDecoration(labelText: '评论内容'),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildTestButton('发布动态', _testCreatePostButton),
                    _buildTestButton('点赞', _testLikePostButton),
                    _buildTestButton('评论', _testCommentPostButton),
                    _buildTestButton('获取动态', _testGetPostsButton),
                  ],
                ),
              ],
            ),
            
            // 训练计划测试区域
            _buildTestSection(
              title: '💪 训练计划测试',
              buttons: [
                _buildTestButton('获取计划', _testGetTrainingPlansButton),
                _buildTestButton('创建计划', _testCreateTrainingPlanButton),
              ],
            ),
            
            // AI功能测试区域
            _buildTestSection(
              title: '🤖 AI功能测试',
              buttons: [
                _buildTestButton('AI训练计划', _testAITrainingPlanButton),
                _buildTestButton('AI健康建议', _testAIHealthAdviceButton),
              ],
            ),
            
            // 签到测试区域
            _buildTestSection(
              title: '📅 签到功能测试',
              buttons: [
                _buildTestButton('签到', _testCheckinButton),
                _buildTestButton('签到统计', _testCheckinStatsButton),
              ],
            ),
            
            SizedBox(height: 16),
            
            // 测试结果
            if (testResults.isNotEmpty) ...[
              Text('测试结果', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...testResults.map((result) => Card(
                child: ListTile(
                  leading: Icon(
                    result['status'].toString().contains('✅') ? Icons.check_circle : 
                    result['status'].toString().contains('❌') ? Icons.error : Icons.warning,
                    color: result['status'].toString().contains('✅') ? Colors.green : 
                           result['status'].toString().contains('❌') ? Colors.red : Colors.orange,
                  ),
                  title: Text(result['button']),
                  subtitle: Text(result['details']),
                  trailing: Text(result['status']),
                ),
              )).toList(),
            ],
            
            // 社区动态列表
            if (communityPosts.isNotEmpty) ...[
              SizedBox(height: 16),
              Text('社区动态 (${communityPosts.length}条)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...communityPosts.take(5).map((post) => Card(
                child: ListTile(
                  title: Text(post['content'] ?? '无内容'),
                  subtitle: Text('作者: ${post['author_name'] ?? '未知'}'),
                  trailing: Text('${post['like_count'] ?? 0} 赞'),
                ),
              )).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestSection({
    required String title,
    List<Widget>? buttons,
    List<Widget>? children,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            if (children != null) ...children,
            if (buttons != null) Wrap(spacing: 8, runSpacing: 8, children: buttons),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(text),
    );
  }
}

/// 主应用
class ButtonDrivenTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitTracker 按钮驱动测试',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ButtonDrivenTestPage(),
    );
  }
}

/// 主函数
void main() {
  runApp(ButtonDrivenTestApp());
}
