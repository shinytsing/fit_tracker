import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'test_automation_framework.dart';
import 'api_test_module.dart';
import 'frontend_test_module.dart';
import 'test_report_generator.dart';

/// FitTracker 综合测试执行器
/// 用于执行所有测试并生成完整的测试报告
class FitTrackerTestExecutor {
  static final FitTrackerTestExecutor _instance = FitTrackerTestExecutor._internal();
  factory FitTrackerTestExecutor() => _instance;
  FitTrackerTestExecutor._internal();

  late FitTrackerTestFramework _testFramework;
  late FitTrackerAPITester _apiTester;
  late FitTrackerFrontendTester _frontendTester;
  late FitTrackerTestReportGenerator _reportGenerator;
  
  /// 初始化测试执行器
  Future<void> initialize() async {
    _testFramework = FitTrackerTestFramework();
    _apiTester = FitTrackerAPITester();
    _frontendTester = FitTrackerFrontendTester();
    _reportGenerator = FitTrackerTestReportGenerator();
    
    await _testFramework.initialize();
    await _apiTester.initialize();
    
    print('🚀 FitTracker 综合测试执行器初始化完成');
  }
  
  /// 执行API测试
  Future<APITestReport> executeAPITests() async {
    print('🔧 开始执行API测试...');
    
    try {
      final report = await _apiTester.runComprehensiveAPITests();
      
      // 保存API测试报告
      await _apiTester.saveReportToFile(report);
      
      print('✅ API测试完成');
      print('📊 API测试统计:');
      print('   总测试数: ${report.totalTests}');
      print('   通过: ${report.passedTests}');
      print('   失败: ${report.failedTests}');
      print('   警告: ${report.warningTests}');
      
      return report;
      
    } catch (e) {
      print('❌ API测试执行失败: $e');
      rethrow;
    }
  }
  
  /// 执行前端测试
  Future<FrontendTestReport> executeFrontendTests(WidgetTester tester) async {
    print('🎨 开始执行前端测试...');
    
    try {
      await _frontendTester.initialize(tester);
      final report = await _frontendTester.runComprehensiveFrontendTests();
      
      // 保存前端测试报告
      await _frontendTester.saveReportToFile(report);
      
      print('✅ 前端测试完成');
      print('📊 前端测试统计:');
      print('   总测试数: ${report.totalTests}');
      print('   通过: ${report.passedTests}');
      print('   失败: ${report.failedTests}');
      print('   警告: ${report.warningTests}');
      
      return report;
      
    } catch (e) {
      print('❌ 前端测试执行失败: $e');
      rethrow;
    }
  }
  
  /// 执行综合测试
  Future<ComprehensiveTestReport> executeComprehensiveTests({
    WidgetTester? tester,
    String? testEnvironment,
    String? testVersion,
  }) async {
    print('🚀 开始执行 FitTracker 综合测试...');
    
    final startTime = DateTime.now();
    
    try {
      // 执行API测试
      final apiReport = await executeAPITests();
      
      // 执行前端测试（如果提供了tester）
      FrontendTestReport? frontendReport;
      if (tester != null) {
        frontendReport = await executeFrontendTests(tester);
      } else {
        // 创建模拟的前端测试报告
        frontendReport = FrontendTestReport(
          testName: 'FitTracker 前端测试（模拟）',
          startTime: startTime,
          endTime: DateTime.now(),
          totalDuration: 0,
          totalTests: 0,
          passedTests: 0,
          failedTests: 0,
          warningTests: 0,
          testResults: [],
          summary: '前端测试未执行（缺少WidgetTester）',
        );
      }
      
      // 生成综合测试报告
      final comprehensiveReport = await _reportGenerator.generateComprehensiveReport(
        apiReport: apiReport,
        frontendReport: frontendReport,
        testEnvironment: testEnvironment ?? 'Development',
        testVersion: testVersion ?? '1.0.0',
      );
      
      // 保存综合测试报告
      await _reportGenerator.saveReportToFile(comprehensiveReport);
      
      // 生成测试仪表板数据
      final dashboardData = _reportGenerator.generateDashboardData(comprehensiveReport);
      final dashboardFile = File('fittracker_test_dashboard_${DateTime.now().millisecondsSinceEpoch}.json');
      await dashboardFile.writeAsString(JsonEncoder.withIndent('  ').convert(dashboardData));
      print('📊 测试仪表板数据已保存: ${dashboardFile.path}');
      
      print('✅ 综合测试完成！');
      print('📊 综合测试统计:');
      print('   总测试数: ${comprehensiveReport.totalTests}');
      print('   通过: ${comprehensiveReport.totalPassed}');
      print('   失败: ${comprehensiveReport.totalFailed}');
      print('   警告: ${comprehensiveReport.totalWarning}');
      print('   成功率: ${comprehensiveReport.totalTests > 0 ? (comprehensiveReport.totalPassed / comprehensiveReport.totalTests * 100).toStringAsFixed(2) : '0.00'}%');
      print('   质量评分: ${comprehensiveReport.qualityAssessment.overallScore.toStringAsFixed(2)} (${comprehensiveReport.qualityAssessment.qualityLevel})');
      
      // 打印测试建议
      if (comprehensiveReport.recommendations.isNotEmpty) {
        print('\n💡 测试建议:');
        for (final recommendation in comprehensiveReport.recommendations) {
          print('   $recommendation');
        }
      }
      
      return comprehensiveReport;
      
    } catch (e) {
      print('❌ 综合测试执行失败: $e');
      rethrow;
    }
  }
  
  /// 执行快速测试（仅API）
  Future<APITestReport> executeQuickTests() async {
    print('⚡ 开始执行快速测试（仅API）...');
    
    try {
      final report = await executeAPITests();
      
      print('✅ 快速测试完成！');
      print('📊 快速测试统计:');
      print('   总测试数: ${report.totalTests}');
      print('   通过: ${report.passedTests}');
      print('   失败: ${report.failedTests}');
      print('   警告: ${report.warningTests}');
      
      return report;
      
    } catch (e) {
      print('❌ 快速测试执行失败: $e');
      rethrow;
    }
  }
  
  /// 执行性能测试
  Future<Map<String, dynamic>> executePerformanceTests() async {
    print('⚡ 开始执行性能测试...');
    
    try {
      final performanceResults = <String, dynamic>{};
      
      // API性能测试
      final apiPerformanceTests = await _apiTester.testPerformance();
      final apiResponseTimes = apiPerformanceTests
          .where((r) => r.responseTime != null)
          .map((r) => r.responseTime!)
          .toList();
      
      if (apiResponseTimes.isNotEmpty) {
        final avgResponseTime = apiResponseTimes.reduce((a, b) => a + b) / apiResponseTimes.length;
        final maxResponseTime = apiResponseTimes.reduce((a, b) => a > b ? a : b);
        final minResponseTime = apiResponseTimes.reduce((a, b) => a < b ? a : b);
        
        performanceResults['api'] = {
          'averageResponseTime': avgResponseTime,
          'maxResponseTime': maxResponseTime,
          'minResponseTime': minResponseTime,
          'testCount': apiResponseTimes.length,
        };
        
        print('📊 API性能测试结果:');
        print('   平均响应时间: ${avgResponseTime.toStringAsFixed(2)}ms');
        print('   最大响应时间: ${maxResponseTime}ms');
        print('   最小响应时间: ${minResponseTime}ms');
      }
      
      // 保存性能测试结果
      final performanceFile = File('fittracker_performance_test_${DateTime.now().millisecondsSinceEpoch}.json');
      await performanceFile.writeAsString(JsonEncoder.withIndent('  ').convert(performanceResults));
      print('📄 性能测试结果已保存: ${performanceFile.path}');
      
      return performanceResults;
      
    } catch (e) {
      print('❌ 性能测试执行失败: $e');
      rethrow;
    }
  }
  
  /// 执行错误处理测试
  Future<List<APITestResult>> executeErrorHandlingTests() async {
    print('🛡️ 开始执行错误处理测试...');
    
    try {
      final errorResults = await _apiTester.testErrorHandling();
      
      print('✅ 错误处理测试完成');
      print('📊 错误处理测试统计:');
      print('   总测试数: ${errorResults.length}');
      print('   通过: ${errorResults.where((r) => r.status == APITestStatus.passed).length}');
      print('   失败: ${errorResults.where((r) => r.status == APITestStatus.failed).length}');
      print('   警告: ${errorResults.where((r) => r.status == APITestStatus.warning).length}');
      
      return errorResults;
      
    } catch (e) {
      print('❌ 错误处理测试执行失败: $e');
      rethrow;
    }
  }
  
  /// 生成测试摘要
  Future<String> generateTestSummary(ComprehensiveTestReport report) async {
    final summary = StringBuffer();
    
    summary.writeln('FitTracker 自动化测试摘要');
    summary.writeln('========================');
    summary.writeln();
    summary.writeln('测试时间: ${report.startTime.toIso8601String()} - ${report.endTime.toIso8601String()}');
    summary.writeln('测试环境: ${report.testEnvironment}');
    summary.writeln('测试版本: ${report.testVersion}');
    summary.writeln();
    summary.writeln('总体统计:');
    summary.writeln('- 总测试数: ${report.totalTests}');
    summary.writeln('- 通过: ${report.totalPassed}');
    summary.writeln('- 失败: ${report.totalFailed}');
    summary.writeln('- 警告: ${report.totalWarning}');
    summary.writeln('- 成功率: ${report.totalTests > 0 ? (report.totalPassed / report.totalTests * 100).toStringAsFixed(2) : '0.00'}%');
    summary.writeln();
    summary.writeln('质量评估:');
    summary.writeln('- 总体质量: ${report.qualityAssessment.overallScore.toStringAsFixed(2)} (${report.qualityAssessment.qualityLevel})');
    summary.writeln('- API质量: ${report.qualityAssessment.apiQuality.toStringAsFixed(2)}');
    summary.writeln('- 前端质量: ${report.qualityAssessment.frontendQuality.toStringAsFixed(2)}');
    summary.writeln('- 测试覆盖率: ${report.qualityAssessment.testCoverage.toStringAsFixed(2)}');
    summary.writeln('- 性能评分: ${report.qualityAssessment.performanceScore.toStringAsFixed(2)}');
    summary.writeln('- 错误处理: ${report.qualityAssessment.errorHandlingScore.toStringAsFixed(2)}');
    summary.writeln();
    
    if (report.recommendations.isNotEmpty) {
      summary.writeln('测试建议:');
      for (final recommendation in report.recommendations) {
        summary.writeln('- $recommendation');
      }
      summary.writeln();
    }
    
    return summary.toString();
  }
  
  /// 清理测试资源
  void cleanup() {
    print('🧹 清理测试资源...');
    // 这里可以添加清理逻辑
    print('✅ 测试资源清理完成');
  }
}

/// 测试配置类
class TestConfig {
  final bool runAPITests;
  final bool runFrontendTests;
  final bool runPerformanceTests;
  final bool runErrorHandlingTests;
  final String? testEnvironment;
  final String? testVersion;
  final Duration? timeout;
  
  TestConfig({
    this.runAPITests = true,
    this.runFrontendTests = true,
    this.runPerformanceTests = false,
    this.runErrorHandlingTests = false,
    this.testEnvironment,
    this.testVersion,
    this.timeout,
  });
  
  /// 创建默认配置
  factory TestConfig.defaultConfig() {
    return TestConfig(
      runAPITests: true,
      runFrontendTests: true,
      runPerformanceTests: false,
      runErrorHandlingTests: false,
      testEnvironment: 'Development',
      testVersion: '1.0.0',
    );
  }
  
  /// 创建快速测试配置
  factory TestConfig.quickTest() {
    return TestConfig(
      runAPITests: true,
      runFrontendTests: false,
      runPerformanceTests: false,
      runErrorHandlingTests: false,
      testEnvironment: 'Development',
      testVersion: '1.0.0',
    );
  }
  
  /// 创建完整测试配置
  factory TestConfig.fullTest() {
    return TestConfig(
      runAPITests: true,
      runFrontendTests: true,
      runPerformanceTests: true,
      runErrorHandlingTests: true,
      testEnvironment: 'Development',
      testVersion: '1.0.0',
    );
  }
}
