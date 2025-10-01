import 'dart:convert';
import 'dart:io';
import 'api_test_module.dart';
import 'frontend_test_module.dart';

/// FitTracker 综合测试报告生成器
/// 用于整合API测试和前端测试的结果，生成统一的测试报告
class FitTrackerTestReportGenerator {
  static final FitTrackerTestReportGenerator _instance = FitTrackerTestReportGenerator._internal();
  factory FitTrackerTestReportGenerator() => _instance;
  FitTrackerTestReportGenerator._internal();

  /// 生成综合测试报告
  Future<ComprehensiveTestReport> generateComprehensiveReport({
    required APITestReport apiReport,
    required FrontendTestReport frontendReport,
    String? testEnvironment,
    String? testVersion,
  }) async {
    final startTime = DateTime.now();
    
    // 计算总体统计
    final totalTests = apiReport.totalTests + frontendReport.totalTests;
    final totalPassed = apiReport.passedTests + frontendReport.passedTests;
    final totalFailed = apiReport.failedTests + frontendReport.failedTests;
    final totalWarning = apiReport.warningTests + frontendReport.warningTests;
    
    // 生成综合摘要
    final summary = _generateComprehensiveSummary(
      apiReport: apiReport,
      frontendReport: frontendReport,
      totalTests: totalTests,
      totalPassed: totalPassed,
      totalFailed: totalFailed,
      totalWarning: totalWarning,
    );
    
    // 生成测试建议
    final recommendations = _generateRecommendations(
      apiReport: apiReport,
      frontendReport: frontendReport,
    );
    
    // 生成质量评估
    final qualityAssessment = _generateQualityAssessment(
      apiReport: apiReport,
      frontendReport: frontendReport,
      totalTests: totalTests,
      totalPassed: totalPassed,
    );
    
    final report = ComprehensiveTestReport(
      testName: 'FitTracker 综合自动化测试报告',
      startTime: startTime,
      endTime: DateTime.now(),
      testEnvironment: testEnvironment ?? 'Development',
      testVersion: testVersion ?? '1.0.0',
      apiReport: apiReport,
      frontendReport: frontendReport,
      totalTests: totalTests,
      totalPassed: totalPassed,
      totalFailed: totalFailed,
      totalWarning: totalWarning,
      summary: summary,
      recommendations: recommendations,
      qualityAssessment: qualityAssessment,
    );
    
    return report;
  }
  
  /// 生成综合摘要
  String _generateComprehensiveSummary({
    required APITestReport apiReport,
    required FrontendTestReport frontendReport,
    required int totalTests,
    required int totalPassed,
    required int totalFailed,
    required int totalWarning,
  }) {
    final successRate = totalTests > 0 ? (totalPassed / totalTests * 100).toStringAsFixed(2) : '0.00';
    
    return '''
FitTracker 综合测试摘要
========================

测试概览:
- 总测试数: $totalTests
- 通过: $totalPassed (${successRate}%)
- 失败: $totalFailed
- 警告: $totalWarning
- 成功率: ${successRate}%

模块测试结果:
- API测试: ${apiReport.passedTests}/${apiReport.totalTests} 通过 (${apiReport.totalTests > 0 ? (apiReport.passedTests / apiReport.totalTests * 100).toStringAsFixed(2) : '0.00'}%)
- 前端测试: ${frontendReport.passedTests}/${frontendReport.totalTests} 通过 (${frontendReport.totalTests > 0 ? (frontendReport.passedTests / frontendReport.totalTests * 100).toStringAsFixed(2) : '0.00'}%)

测试覆盖范围:
- 用户认证模块
- 运动记录模块
- BMI计算模块
- 营养管理模块
- 社区功能模块
- 签到功能模块
- 错误处理测试
- 性能测试
- 前端交互测试
- 表单验证测试

''';
  }
  
  /// 生成测试建议
  List<String> _generateRecommendations({
    required APITestReport apiReport,
    required FrontendTestReport frontendReport,
  }) {
    final recommendations = <String>[];
    
    // API测试建议
    if (apiReport.failedTests > 0) {
      recommendations.add('🔧 修复 ${apiReport.failedTests} 个API测试失败项');
    }
    
    if (apiReport.warningTests > 0) {
      recommendations.add('⚠️ 处理 ${apiReport.warningTests} 个API测试警告项');
    }
    
    // 前端测试建议
    if (frontendReport.failedTests > 0) {
      recommendations.add('🎨 修复 ${frontendReport.failedTests} 个前端测试失败项');
    }
    
    if (frontendReport.warningTests > 0) {
      recommendations.add('⚠️ 处理 ${frontendReport.warningTests} 个前端测试警告项');
    }
    
    // 性能建议
    final apiPerformanceTests = apiReport.testResults.where((r) => r.module == '性能测试').toList();
    if (apiPerformanceTests.isNotEmpty) {
      final avgResponseTime = apiPerformanceTests
          .where((r) => r.responseTime != null)
          .map((r) => r.responseTime!)
          .reduce((a, b) => a + b) / apiPerformanceTests.length;
      
      if (avgResponseTime > 2000) {
        recommendations.add('⚡ 优化API响应时间，当前平均: ${avgResponseTime.toStringAsFixed(2)}ms');
      }
    }
    
    // 覆盖率建议
    if (apiReport.totalTests < 20) {
      recommendations.add('📈 增加API测试覆盖率');
    }
    
    if (frontendReport.totalTests < 15) {
      recommendations.add('📈 增加前端测试覆盖率');
    }
    
    // 错误处理建议
    final errorTests = apiReport.testResults.where((r) => r.module == '错误处理').toList();
    if (errorTests.any((r) => r.status == APITestStatus.failed)) {
      recommendations.add('🛡️ 完善错误处理机制');
    }
    
    return recommendations;
  }
  
  /// 生成质量评估
  QualityAssessment _generateQualityAssessment({
    required APITestReport apiReport,
    required FrontendTestReport frontendReport,
    required int totalTests,
    required int totalPassed,
  }) {
    final successRate = totalTests > 0 ? (totalPassed / totalTests * 100) : 0.0;
    
    // 计算质量分数
    double qualityScore = 0.0;
    
    // 成功率权重 (40%)
    qualityScore += successRate * 0.4;
    
    // API测试质量权重 (30%)
    final apiSuccessRate = apiReport.totalTests > 0 ? (apiReport.passedTests / apiReport.totalTests * 100) : 0.0;
    qualityScore += apiSuccessRate * 0.3;
    
    // 前端测试质量权重 (20%)
    final frontendSuccessRate = frontendReport.totalTests > 0 ? (frontendReport.passedTests / frontendReport.totalTests * 100) : 0.0;
    qualityScore += frontendSuccessRate * 0.2;
    
    // 测试覆盖率权重 (10%)
    final coverageScore = _calculateCoverageScore(totalTests);
    qualityScore += coverageScore * 0.1;
    
    // 确定质量等级
    String qualityLevel;
    if (qualityScore >= 90) {
      qualityLevel = '优秀';
    } else if (qualityScore >= 80) {
      qualityLevel = '良好';
    } else if (qualityScore >= 70) {
      qualityLevel = '一般';
    } else if (qualityScore >= 60) {
      qualityLevel = '较差';
    } else {
      qualityLevel = '需要改进';
    }
    
    return QualityAssessment(
      overallScore: qualityScore,
      qualityLevel: qualityLevel,
      apiQuality: apiSuccessRate,
      frontendQuality: frontendSuccessRate,
      testCoverage: coverageScore,
      performanceScore: _calculatePerformanceScore(apiReport),
      errorHandlingScore: _calculateErrorHandlingScore(apiReport),
    );
  }
  
  /// 计算测试覆盖率分数
  double _calculateCoverageScore(int totalTests) {
    // 基于测试数量的覆盖率评分
    if (totalTests >= 50) return 100.0;
    if (totalTests >= 40) return 90.0;
    if (totalTests >= 30) return 80.0;
    if (totalTests >= 20) return 70.0;
    if (totalTests >= 10) return 60.0;
    return 50.0;
  }
  
  /// 计算性能分数
  double _calculatePerformanceScore(APITestReport apiReport) {
    final performanceTests = apiReport.testResults.where((r) => r.module == '性能测试').toList();
    if (performanceTests.isEmpty) return 0.0;
    
    final avgResponseTime = performanceTests
        .where((r) => r.responseTime != null)
        .map((r) => r.responseTime!)
        .reduce((a, b) => a + b) / performanceTests.length;
    
    // 基于响应时间的性能评分
    if (avgResponseTime <= 500) return 100.0;
    if (avgResponseTime <= 1000) return 90.0;
    if (avgResponseTime <= 2000) return 80.0;
    if (avgResponseTime <= 3000) return 70.0;
    if (avgResponseTime <= 5000) return 60.0;
    return 50.0;
  }
  
  /// 计算错误处理分数
  double _calculateErrorHandlingScore(APITestReport apiReport) {
    final errorTests = apiReport.testResults.where((r) => r.module == '错误处理').toList();
    if (errorTests.isEmpty) return 0.0;
    
    final passedErrorTests = errorTests.where((r) => r.status == APITestStatus.passed).length;
    return (passedErrorTests / errorTests.length) * 100.0;
  }
  
  /// 生成JSON格式的综合测试报告
  Map<String, dynamic> generateJsonReport(ComprehensiveTestReport report) {
    return {
      'comprehensiveTestReport': {
        'testName': report.testName,
        'startTime': report.startTime.toIso8601String(),
        'endTime': report.endTime.toIso8601String(),
        'testEnvironment': report.testEnvironment,
        'testVersion': report.testVersion,
        'summary': {
          'totalTests': report.totalTests,
          'totalPassed': report.totalPassed,
          'totalFailed': report.totalFailed,
          'totalWarning': report.totalWarning,
          'successRate': report.totalTests > 0 ? (report.totalPassed / report.totalTests * 100).toStringAsFixed(2) : '0.00',
        },
        'qualityAssessment': {
          'overallScore': report.qualityAssessment.overallScore,
          'qualityLevel': report.qualityAssessment.qualityLevel,
          'apiQuality': report.qualityAssessment.apiQuality,
          'frontendQuality': report.qualityAssessment.frontendQuality,
          'testCoverage': report.qualityAssessment.testCoverage,
          'performanceScore': report.qualityAssessment.performanceScore,
          'errorHandlingScore': report.qualityAssessment.errorHandlingScore,
        },
        'recommendations': report.recommendations,
        'apiReport': {
          'totalTests': report.apiReport.totalTests,
          'passedTests': report.apiReport.passedTests,
          'failedTests': report.apiReport.failedTests,
          'warningTests': report.apiReport.warningTests,
        },
        'frontendReport': {
          'totalTests': report.frontendReport.totalTests,
          'passedTests': report.frontendReport.passedTests,
          'failedTests': report.frontendReport.failedTests,
          'warningTests': report.frontendReport.warningTests,
        },
      },
    };
  }
  
  /// 生成Markdown格式的综合测试报告
  String generateMarkdownReport(ComprehensiveTestReport report) {
    final buffer = StringBuffer();
    
    buffer.writeln('# FitTracker 综合自动化测试报告');
    buffer.writeln();
    buffer.writeln('## 测试概览');
    buffer.writeln();
    buffer.writeln('| 项目 | 值 |');
    buffer.writeln('|------|-----|');
    buffer.writeln('| 测试名称 | ${report.testName} |');
    buffer.writeln('| 测试环境 | ${report.testEnvironment} |');
    buffer.writeln('| 测试版本 | ${report.testVersion} |');
    buffer.writeln('| 开始时间 | ${report.startTime.toIso8601String()} |');
    buffer.writeln('| 结束时间 | ${report.endTime.toIso8601String()} |');
    buffer.writeln('| 总测试数 | ${report.totalTests} |');
    buffer.writeln('| 通过 | ${report.totalPassed} |');
    buffer.writeln('| 失败 | ${report.totalFailed} |');
    buffer.writeln('| 警告 | ${report.totalWarning} |');
    buffer.writeln('| 成功率 | ${report.totalTests > 0 ? (report.totalPassed / report.totalTests * 100).toStringAsFixed(2) : '0.00'}% |');
    buffer.writeln();
    
    buffer.writeln('## 质量评估');
    buffer.writeln();
    buffer.writeln('| 评估项目 | 分数 | 等级 |');
    buffer.writeln('|----------|------|------|');
    buffer.writeln('| 总体质量 | ${report.qualityAssessment.overallScore.toStringAsFixed(2)} | ${report.qualityAssessment.qualityLevel} |');
    buffer.writeln('| API质量 | ${report.qualityAssessment.apiQuality.toStringAsFixed(2)} | - |');
    buffer.writeln('| 前端质量 | ${report.qualityAssessment.frontendQuality.toStringAsFixed(2)} | - |');
    buffer.writeln('| 测试覆盖率 | ${report.qualityAssessment.testCoverage.toStringAsFixed(2)} | - |');
    buffer.writeln('| 性能评分 | ${report.qualityAssessment.performanceScore.toStringAsFixed(2)} | - |');
    buffer.writeln('| 错误处理 | ${report.qualityAssessment.errorHandlingScore.toStringAsFixed(2)} | - |');
    buffer.writeln();
    
    buffer.writeln('## 测试摘要');
    buffer.writeln();
    buffer.writeln('```');
    buffer.writeln(report.summary);
    buffer.writeln('```');
    buffer.writeln();
    
    buffer.writeln('## 测试建议');
    buffer.writeln();
    for (final recommendation in report.recommendations) {
      buffer.writeln('- $recommendation');
    }
    buffer.writeln();
    
    buffer.writeln('## API测试结果');
    buffer.writeln();
    buffer.writeln('| 项目 | 值 |');
    buffer.writeln('|------|-----|');
    buffer.writeln('| 总测试数 | ${report.apiReport.totalTests} |');
    buffer.writeln('| 通过 | ${report.apiReport.passedTests} |');
    buffer.writeln('| 失败 | ${report.apiReport.failedTests} |');
    buffer.writeln('| 警告 | ${report.apiReport.warningTests} |');
    buffer.writeln('| 成功率 | ${report.apiReport.totalTests > 0 ? (report.apiReport.passedTests / report.apiReport.totalTests * 100).toStringAsFixed(2) : '0.00'}% |');
    buffer.writeln();
    
    buffer.writeln('## 前端测试结果');
    buffer.writeln();
    buffer.writeln('| 项目 | 值 |');
    buffer.writeln('|------|-----|');
    buffer.writeln('| 总测试数 | ${report.frontendReport.totalTests} |');
    buffer.writeln('| 通过 | ${report.frontendReport.passedTests} |');
    buffer.writeln('| 失败 | ${report.frontendReport.failedTests} |');
    buffer.writeln('| 警告 | ${report.frontendReport.warningTests} |');
    buffer.writeln('| 成功率 | ${report.frontendReport.totalTests > 0 ? (report.frontendReport.passedTests / report.frontendReport.totalTests * 100).toStringAsFixed(2) : '0.00'}% |');
    buffer.writeln();
    
    buffer.writeln('## 详细测试结果');
    buffer.writeln();
    
    // API测试详细结果
    buffer.writeln('### API测试详细结果');
    buffer.writeln();
    final apiModuleGroups = <String, List<APITestResult>>{};
    for (final result in report.apiReport.testResults) {
      apiModuleGroups.putIfAbsent(result.module, () => []).add(result);
    }
    
    for (final entry in apiModuleGroups.entries) {
      final module = entry.key;
      final results = entry.value;
      
      buffer.writeln('#### $module');
      buffer.writeln();
      
      for (final result in results) {
        final statusIcon = result.status == APITestStatus.passed ? '✅' : 
                          result.status == APITestStatus.failed ? '❌' : '⚠️';
        
        buffer.writeln('##### $statusIcon ${result.function}');
        buffer.writeln();
        buffer.writeln('| 项目 | 值 |');
        buffer.writeln('|------|-----|');
        buffer.writeln('| API端点 | `${result.method} ${result.endpoint}` |');
        buffer.writeln('| 状态码 | ${result.statusCode ?? 'N/A'} |');
        buffer.writeln('| 响应时间 | ${result.responseTime ?? 'N/A'}ms |');
        buffer.writeln('| 测试状态 | ${result.status.toString().split('.').last} |');
        
        if (result.errorMessage != null) {
          buffer.writeln('| 错误信息 | ${result.errorMessage} |');
        }
        
        buffer.writeln();
      }
    }
    
    // 前端测试详细结果
    buffer.writeln('### 前端测试详细结果');
    buffer.writeln();
    final frontendModuleGroups = <String, List<FrontendTestResult>>{};
    for (final result in report.frontendReport.testResults) {
      frontendModuleGroups.putIfAbsent(result.module, () => []).add(result);
    }
    
    for (final entry in frontendModuleGroups.entries) {
      final module = entry.key;
      final results = entry.value;
      
      buffer.writeln('#### $module');
      buffer.writeln();
      
      for (final result in results) {
        final statusIcon = result.status == FrontendTestStatus.passed ? '✅' : 
                          result.status == FrontendTestStatus.failed ? '❌' : '⚠️';
        
        buffer.writeln('##### $statusIcon ${result.function}');
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
  
  /// 保存综合测试报告到文件
  Future<void> saveReportToFile(ComprehensiveTestReport report, {String? filename}) async {
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
    final defaultFilename = filename ?? 'fittracker_comprehensive_test_report_$timestamp';
    
    // 保存JSON报告
    final jsonReport = generateJsonReport(report);
    final jsonFile = File('${defaultFilename}.json');
    await jsonFile.writeAsString(JsonEncoder.withIndent('  ').convert(jsonReport));
    print('📄 综合JSON报告已保存: ${jsonFile.path}');
    
    // 保存Markdown报告
    final markdownReport = generateMarkdownReport(report);
    final markdownFile = File('${defaultFilename}.md');
    await markdownFile.writeAsString(markdownReport);
    print('📄 综合Markdown报告已保存: ${markdownFile.path}');
    
    // 保存测试摘要
    final summaryFile = File('${defaultFilename}_summary.txt');
    await summaryFile.writeAsString(report.summary);
    print('📄 测试摘要已保存: ${summaryFile.path}');
  }
  
  /// 生成测试仪表板数据
  Map<String, dynamic> generateDashboardData(ComprehensiveTestReport report) {
    return {
      'dashboard': {
        'overview': {
          'totalTests': report.totalTests,
          'passedTests': report.totalPassed,
          'failedTests': report.totalFailed,
          'warningTests': report.totalWarning,
          'successRate': report.totalTests > 0 ? (report.totalPassed / report.totalTests * 100).toStringAsFixed(2) : '0.00',
          'qualityScore': report.qualityAssessment.overallScore,
          'qualityLevel': report.qualityAssessment.qualityLevel,
        },
        'modules': {
          'api': {
            'totalTests': report.apiReport.totalTests,
            'passedTests': report.apiReport.passedTests,
            'failedTests': report.apiReport.failedTests,
            'warningTests': report.apiReport.warningTests,
            'successRate': report.apiReport.totalTests > 0 ? (report.apiReport.passedTests / report.apiReport.totalTests * 100).toStringAsFixed(2) : '0.00',
          },
          'frontend': {
            'totalTests': report.frontendReport.totalTests,
            'passedTests': report.frontendReport.passedTests,
            'failedTests': report.frontendReport.failedTests,
            'warningTests': report.frontendReport.warningTests,
            'successRate': report.frontendReport.totalTests > 0 ? (report.frontendReport.passedTests / report.frontendReport.totalTests * 100).toStringAsFixed(2) : '0.00',
          },
        },
        'quality': {
          'overallScore': report.qualityAssessment.overallScore,
          'apiQuality': report.qualityAssessment.apiQuality,
          'frontendQuality': report.qualityAssessment.frontendQuality,
          'testCoverage': report.qualityAssessment.testCoverage,
          'performanceScore': report.qualityAssessment.performanceScore,
          'errorHandlingScore': report.qualityAssessment.errorHandlingScore,
        },
        'recommendations': report.recommendations,
        'timestamp': report.endTime.toIso8601String(),
      },
    };
  }
}

/// 综合测试报告类
class ComprehensiveTestReport {
  final String testName;
  final DateTime startTime;
  final DateTime endTime;
  final String testEnvironment;
  final String testVersion;
  final APITestReport apiReport;
  final FrontendTestReport frontendReport;
  final int totalTests;
  final int totalPassed;
  final int totalFailed;
  final int totalWarning;
  final String summary;
  final List<String> recommendations;
  final QualityAssessment qualityAssessment;
  
  ComprehensiveTestReport({
    required this.testName,
    required this.startTime,
    required this.endTime,
    required this.testEnvironment,
    required this.testVersion,
    required this.apiReport,
    required this.frontendReport,
    required this.totalTests,
    required this.totalPassed,
    required this.totalFailed,
    required this.totalWarning,
    required this.summary,
    required this.recommendations,
    required this.qualityAssessment,
  });
}

/// 质量评估类
class QualityAssessment {
  final double overallScore;
  final String qualityLevel;
  final double apiQuality;
  final double frontendQuality;
  final double testCoverage;
  final double performanceScore;
  final double errorHandlingScore;
  
  QualityAssessment({
    required this.overallScore,
    required this.qualityLevel,
    required this.apiQuality,
    required this.frontendQuality,
    required this.testCoverage,
    required this.performanceScore,
    required this.errorHandlingScore,
  });
}
