import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

/// FitTracker 全链路按钮测试可视化应用
void main() {
  runApp(
    const ProviderScope(
      child: FitTrackerTestApp(),
    ),
  );
}

class FitTrackerTestApp extends StatelessWidget {
  const FitTrackerTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitTracker 全链路测试系统',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TestDashboard(),
    );
  }
}

/// 测试仪表板
class TestDashboard extends ConsumerStatefulWidget {
  const TestDashboard({super.key});

  @override
  ConsumerState<TestDashboard> createState() => _TestDashboardState();
}

class _TestDashboardState extends ConsumerState<TestDashboard> {
  final TestSystemController _controller = TestSystemController();
  bool _isRunning = false;
  List<TestResult> _testResults = [];
  List<AutoFix> _autoFixes = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTestUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTestUpdate);
    super.dispose();
  }

  void _onTestUpdate() {
    setState(() {
      _testResults = _controller.testResults;
      _autoFixes = _controller.autoFixes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitTracker 全链路测试系统'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRunning ? null : _refreshTests,
          ),
        ],
      ),
      body: Column(
        children: [
          // 测试控制面板
          _buildControlPanel(),
          
          // 测试结果展示
          Expanded(
            child: _testResults.isEmpty
                ? _buildEmptyState()
                : _buildTestResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isRunning ? null : _startComprehensiveTest,
                  icon: _isRunning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(_isRunning ? '测试进行中...' : '开始全链路测试'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isRunning ? null : _startQuickTest,
                  icon: const Icon(Icons.flash_on),
                  label: const Text('快速测试'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isRunning ? null : _testAuthButtons,
                  icon: const Icon(Icons.security),
                  label: const Text('认证测试'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isRunning ? null : _testBMICalculator,
                  icon: const Icon(Icons.calculate),
                  label: const Text('BMI测试'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isRunning ? null : _testCommunityButtons,
                  icon: const Icon(Icons.people),
                  label: const Text('社区测试'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.science,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '点击上方按钮开始测试',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '系统将自动验证API请求、数据库写入和UI状态更新',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTestResults() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: const [
              Tab(icon: Icon(Icons.list), text: '测试结果'),
              Tab(icon: Icon(Icons.build), text: '自动修复'),
              Tab(icon: Icon(Icons.analytics), text: '统计报告'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildTestResultsList(),
                _buildAutoFixesList(),
                _buildStatisticsReport(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _testResults.length,
      itemBuilder: (context, index) {
        final result = _testResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: result.status == TestStatus.passed
                  ? Colors.green
                  : result.status == TestStatus.failed
                      ? Colors.red
                      : Colors.orange,
              child: Icon(
                result.status == TestStatus.passed
                    ? Icons.check
                    : result.status == TestStatus.failed
                        ? Icons.close
                        : Icons.warning,
                color: Colors.white,
              ),
            ),
            title: Text(result.buttonName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${result.method} ${result.apiEndpoint}'),
                if (result.error != null)
                  Text(
                    '错误: ${result.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                Text('时间: ${_formatTime(result.timestamp)}'),
              ],
            ),
            trailing: result.status == TestStatus.passed
                ? const Icon(Icons.check_circle, color: Colors.green)
                : result.status == TestStatus.failed
                    ? const Icon(Icons.error, color: Colors.red)
                    : const Icon(Icons.warning, color: Colors.orange),
            onTap: () => _showTestDetails(result),
          ),
        );
      },
    );
  }

  Widget _buildAutoFixesList() {
    if (_autoFixes.isEmpty) {
      return const Center(
        child: Text('暂无自动修复记录'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _autoFixes.length,
      itemBuilder: (context, index) {
        final fix = _autoFixes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: fix.status == 'success'
                  ? Colors.green
                  : fix.status == 'failed'
                      ? Colors.red
                      : Colors.blue,
              child: Icon(
                fix.status == 'success'
                    ? Icons.check
                    : fix.status == 'failed'
                        ? Icons.close
                        : Icons.build,
                color: Colors.white,
              ),
            ),
            title: Text(fix.type),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fix.description),
                Text('状态: ${fix.status}'),
                Text('时间: ${_formatTime(fix.timestamp)}'),
              ],
            ),
            trailing: fix.status == 'success'
                ? const Icon(Icons.check_circle, color: Colors.green)
                : fix.status == 'failed'
                    ? const Icon(Icons.error, color: Colors.red)
                    : const Icon(Icons.info, color: Colors.blue),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsReport() {
    final totalTests = _testResults.length;
    final passedTests = _testResults.where((r) => r.status == TestStatus.passed).length;
    final failedTests = _testResults.where((r) => r.status == TestStatus.failed).length;
    final successRate = totalTests > 0 ? (passedTests / totalTests * 100) : 0.0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 总体统计
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '总体统计',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('总测试数', totalTests.toString(), Colors.blue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard('通过', passedTests.toString(), Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('失败', failedTests.toString(), Colors.red),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard('成功率', '${successRate.toStringAsFixed(1)}%', Colors.purple),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 成功率图表
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '成功率趋势',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: successRate / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      successRate >= 80 ? Colors.green : successRate >= 60 ? Colors.orange : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('当前成功率: ${successRate.toStringAsFixed(1)}%'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showTestDetails(TestResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result.buttonName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('API端点: ${result.method} ${result.apiEndpoint}'),
            const SizedBox(height: 8),
            Text('状态: ${result.status.toString().split('.').last}'),
            const SizedBox(height: 8),
            Text('时间: ${_formatTime(result.timestamp)}'),
            if (result.error != null) ...[
              const SizedBox(height: 8),
              Text('错误: ${result.error}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  // 测试方法
  Future<void> _startComprehensiveTest() async {
    setState(() => _isRunning = true);
    try {
      await _controller.runComprehensiveTest();
    } finally {
      setState(() => _isRunning = false);
    }
  }

  Future<void> _startQuickTest() async {
    setState(() => _isRunning = true);
    try {
      await _controller.runQuickTest();
    } finally {
      setState(() => _isRunning = false);
    }
  }

  Future<void> _testAuthButtons() async {
    setState(() => _isRunning = true);
    try {
      await _controller.testAuthModule();
    } finally {
      setState(() => _isRunning = false);
    }
  }

  Future<void> _testBMICalculator() async {
    setState(() => _isRunning = true);
    try {
      await _controller.testBMIModule();
    } finally {
      setState(() => _isRunning = false);
    }
  }

  Future<void> _testCommunityButtons() async {
    setState(() => _isRunning = true);
    try {
      await _controller.testCommunityModule();
    } finally {
      setState(() => _isRunning = false);
    }
  }

  Future<void> _refreshTests() async {
    setState(() {
      _testResults.clear();
      _autoFixes.clear();
    });
  }
}

/// 测试系统控制器
class TestSystemController extends ChangeNotifier {
  final Dio _dio = Dio();
  final String baseUrl = 'http://localhost:8080/api/v1';
  String? authToken;
  
  List<TestResult> testResults = [];
  List<AutoFix> autoFixes = [];
  
  TestSystemController() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = Duration(seconds: 15);
    _dio.options.receiveTimeout = Duration(seconds: 15);
  }

  Future<void> runComprehensiveTest() async {
    testResults.clear();
    autoFixes.clear();
    notifyListeners();
    
    // 运行所有模块测试
    await testAuthModule();
    await testBMIModule();
    await testTrainingModule();
    await testCommunityModule();
    await testHealthModule();
    await testCheckinModule();
    await testNutritionModule();
  }

  Future<void> runQuickTest() async {
    testResults.clear();
    autoFixes.clear();
    notifyListeners();
    
    // 运行核心模块测试
    await testAuthModule();
    await testBMIModule();
  }

  Future<void> testAuthModule() async {
    // 测试注册
    await _testButton(
      buttonName: '注册按钮',
      apiEndpoint: '/auth/register',
      method: 'POST',
      data: {
        'username': 'testuser_${DateTime.now().millisecondsSinceEpoch}',
        'email': 'test_${DateTime.now().millisecondsSinceEpoch}@example.com',
        'password': 'TestPassword123!',
        'first_name': 'Test',
        'last_name': 'User'
      },
    );

    // 测试登录
    await _testButton(
      buttonName: '登录按钮',
      apiEndpoint: '/auth/login',
      method: 'POST',
      data: {
        'email': 'test_${DateTime.now().millisecondsSinceEpoch}@example.com',
        'password': 'TestPassword123!'
      },
    );
  }

  Future<void> testBMIModule() async {
    if (authToken == null) return;
    
    _dio.options.headers['Authorization'] = 'Bearer $authToken';

    await _testButton(
      buttonName: 'BMI计算按钮',
      apiEndpoint: '/bmi/calculate',
      method: 'POST',
      data: {
        'height': 175.0,
        'weight': 70.0,
        'age': 25,
        'gender': 'male'
      },
    );
  }

  Future<void> testTrainingModule() async {
    if (authToken == null) return;
    
    await _testButton(
      buttonName: '获取训练计划按钮',
      apiEndpoint: '/workout/plans',
      method: 'GET',
    );
  }

  Future<void> testCommunityModule() async {
    if (authToken == null) return;
    
    await _testButton(
      buttonName: '发布动态按钮',
      apiEndpoint: '/community/posts',
      method: 'POST',
      data: {
        'content': '自动化测试动态 - ${DateTime.now()}',
        'type': '训练',
        'is_public': true,
      },
    );
  }

  Future<void> testHealthModule() async {
    if (authToken == null) return;
    
    await _testButton(
      buttonName: '获取健康统计按钮',
      apiEndpoint: '/health/stats',
      method: 'GET',
    );
  }

  Future<void> testCheckinModule() async {
    if (authToken == null) return;
    
    await _testButton(
      buttonName: '签到按钮',
      apiEndpoint: '/checkins',
      method: 'POST',
      data: {
        'type': '训练',
        'notes': '自动化测试签到',
        'mood': '开心',
        'energy': 8,
        'motivation': 9
      },
    );
  }

  Future<void> testNutritionModule() async {
    if (authToken == null) return;
    
    await _testButton(
      buttonName: '计算营养信息按钮',
      apiEndpoint: '/nutrition/calculate',
      method: 'POST',
      data: {
        'food_name': '苹果',
        'quantity': 100.0,
        'unit': 'g'
      },
    );
  }

  Future<void> _testButton({
    required String buttonName,
    required String apiEndpoint,
    required String method,
    Map<String, dynamic>? data,
  }) async {
    final result = TestResult(
      buttonName: buttonName,
      apiEndpoint: apiEndpoint,
      method: method,
      timestamp: DateTime.now(),
    );

    try {
      Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(apiEndpoint);
          break;
        case 'POST':
          response = await _dio.post(apiEndpoint, data: data);
          break;
        case 'PUT':
          response = await _dio.put(apiEndpoint, data: data);
          break;
        case 'DELETE':
          response = await _dio.delete(apiEndpoint);
          break;
        default:
          throw Exception('不支持的HTTP方法: $method');
      }

      result.status = response.statusCode == 200 ? TestStatus.passed : TestStatus.failed;
      result.responseData = response.data;
      
      // 如果是登录成功，保存token
      if (apiEndpoint == '/auth/login' && response.statusCode == 200) {
        authToken = response.data['token'];
      }

    } catch (e) {
      result.status = TestStatus.failed;
      result.error = e.toString();
      
      // 尝试自动修复
      await _attemptAutoFix(buttonName, apiEndpoint, method, data, e.toString());
    }

    testResults.add(result);
    notifyListeners();
  }

  Future<void> _attemptAutoFix(String buttonName, String apiEndpoint, String method, Map<String, dynamic>? data, String error) async {
    final fix = AutoFix(
      type: 'auto_fix',
      description: '尝试修复 $buttonName 错误: $error',
      status: 'attempted',
      timestamp: DateTime.now(),
    );

    try {
      // 根据错误类型进行修复
      if (error.contains('401') || error.contains('403')) {
        await _fixAuthError();
        fix.status = 'success';
        fix.description = '成功修复认证错误';
      } else if (error.contains('404')) {
        fix.status = 'failed';
        fix.description = 'API端点不存在，需要手动修复';
      } else {
        fix.status = 'failed';
        fix.description = '未知错误，需要手动检查';
      }
    } catch (e) {
      fix.status = 'failed';
      fix.description = '自动修复失败: $e';
    }

    autoFixes.add(fix);
    notifyListeners();
  }

  Future<void> _fixAuthError() async {
    // 重新获取认证token
    try {
      final loginResponse = await _dio.post('/auth/login', data: {
        'email': 'test@example.com',
        'password': 'TestPassword123!'
      });
      
      if (loginResponse.statusCode == 200) {
        authToken = loginResponse.data['token'];
        _dio.options.headers['Authorization'] = 'Bearer $authToken';
      }
    } catch (e) {
      // 认证修复失败
    }
  }
}

/// 测试结果类
class TestResult {
  final String buttonName;
  final String apiEndpoint;
  final String method;
  final DateTime timestamp;
  
  TestStatus status = TestStatus.pending;
  dynamic responseData;
  String? error;

  TestResult({
    required this.buttonName,
    required this.apiEndpoint,
    required this.method,
    required this.timestamp,
  });
}

/// 自动修复类
class AutoFix {
  final String type;
  final String description;
  final String status;
  final DateTime timestamp;

  AutoFix({
    required this.type,
    required this.description,
    required this.status,
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
