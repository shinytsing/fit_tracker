import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'test_automation_framework.dart';
import 'test_executor.dart';

/// FitTracker 自动化测试主入口
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('FitTracker 自动化测试套件', () {
    late FitTrackerTestExecutor testExecutor;
    
    setUpAll(() async {
      testExecutor = FitTrackerTestExecutor();
      await testExecutor.initialize();
    });
    
    testWidgets('执行综合自动化测试', (WidgetTester tester) async {
      print('🚀 开始执行 FitTracker 综合自动化测试...');
      
      try {
        // 执行综合测试
        final report = await testExecutor.executeComprehensiveTests(
          tester: tester,
          testEnvironment: 'Development',
          testVersion: '1.0.0',
        );
        
        // 验证测试结果
        expect(report.totalTests, greaterThan(0), reason: '应该有测试执行');
        
        // 生成测试摘要
        final summary = await testExecutor.generateTestSummary(report);
        print('\n📊 测试摘要:');
        print(summary);
        
        // 测试完成
        print('\n✅ 综合测试完成！报告已保存到文件。');
        
      } catch (e) {
        print('❌ 综合测试执行失败: $e');
        fail('综合测试执行失败: $e');
      }
    });
    
    testWidgets('执行快速API测试', (WidgetTester tester) async {
      print('⚡ 执行快速API测试...');
      
      try {
        final report = await testExecutor.executeQuickTests();
        
        expect(report.totalTests, greaterThan(0), reason: '应该有API测试执行');
        
        print('✅ 快速API测试完成: ${report.totalTests} 个测试');
        
      } catch (e) {
        print('❌ 快速API测试失败: $e');
        fail('快速API测试失败: $e');
      }
    });
    
    testWidgets('执行性能测试', (WidgetTester tester) async {
      print('⚡ 执行性能测试...');
      
      try {
        final performanceResults = await testExecutor.executePerformanceTests();
        
        expect(performanceResults, isNotEmpty, reason: '应该有性能测试结果');
        
        print('✅ 性能测试完成');
        
      } catch (e) {
        print('❌ 性能测试失败: $e');
        fail('性能测试失败: $e');
      }
    });
    
    testWidgets('执行错误处理测试', (WidgetTester tester) async {
      print('🛡️ 执行错误处理测试...');
      
      try {
        final errorResults = await testExecutor.executeErrorHandlingTests();
        
        expect(errorResults, isNotEmpty, reason: '应该有错误处理测试结果');
        
        print('✅ 错误处理测试完成: ${errorResults.length} 个测试');
        
      } catch (e) {
        print('❌ 错误处理测试失败: $e');
        fail('错误处理测试失败: $e');
      }
    });
    
    tearDownAll(() {
      testExecutor.cleanup();
    });
  });
}
