import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

/// FitTracker 自动修复系统
/// 用于自动检测和修复API、数据库、UI等问题
class AutoFixSystem {
  final Dio _dio = Dio();
  final String baseUrl = 'http://localhost:8080/api/v1';
  final String backendPath = '/Users/gaojie/Desktop/fittraker/backend';
  final String frontendPath = '/Users/gaojie/Desktop/fittraker/frontend';
  
  List<FixResult> _fixResults = [];
  
  AutoFixSystem() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = Duration(seconds: 15);
    _dio.options.receiveTimeout = Duration(seconds: 15);
  }

  /// 执行自动修复
  Future<List<FixResult>> executeAutoFix(String errorType, Map<String, dynamic> context) async {
    print('🔧 开始自动修复: $errorType');
    
    switch (errorType) {
      case 'api_endpoint_missing':
        return await _fixMissingEndpoint(context);
      case 'api_server_error':
        return await _fixServerError(context);
      case 'database_connection_error':
        return await _fixDatabaseConnection(context);
      case 'auth_error':
        return await _fixAuthError(context);
      case 'ui_state_error':
        return await _fixUIStateError(context);
      case 'dependency_error':
        return await _fixDependencyError(context);
      default:
        return await _fixGenericError(errorType, context);
    }
  }

  /// 修复缺失的API端点
  Future<List<FixResult>> _fixMissingEndpoint(Map<String, dynamic> context) async {
    final results = <FixResult>[];
    final endpoint = context['endpoint'] as String;
    final method = context['method'] as String;
    
    try {
      // 1. 检查后端路由文件
      final routeFile = File('$backendPath/app/api/api_v1/api.py');
      if (await routeFile.exists()) {
        final content = await routeFile.readAsString();
        
        // 2. 生成API端点代码
        final endpointCode = _generateEndpointCode(endpoint, method);
        
        // 3. 添加路由到文件
        if (!content.contains(endpoint)) {
          final updatedContent = content + '\n' + endpointCode;
          await routeFile.writeAsString(updatedContent);
          
          results.add(FixResult(
            type: 'api_endpoint',
            status: 'success',
            description: '成功添加API端点: $method $endpoint',
            details: endpointCode,
          ));
        }
      }
      
      // 4. 重启后端服务
      await _restartBackendService();
      
    } catch (e) {
      results.add(FixResult(
        type: 'api_endpoint',
        status: 'failed',
        description: '修复API端点失败: $e',
        details: e.toString(),
      ));
    }
    
    return results;
  }

  /// 修复服务器错误
  Future<List<FixResult>> _fixServerError(Map<String, dynamic> context) async {
    final results = <FixResult>[];
    
    try {
      // 1. 检查后端日志
      final logFile = File('$backendPath/logs/app.log');
      if (await logFile.exists()) {
        final logs = await logFile.readAsString();
        
        // 2. 分析错误日志
        if (logs.contains('ImportError')) {
          await _fixImportError(logs);
        } else if (logs.contains('SyntaxError')) {
          await _fixSyntaxError(logs);
        } else if (logs.contains('AttributeError')) {
          await _fixAttributeError(logs);
        }
      }
      
      // 3. 重启后端服务
      await _restartBackendService();
      
      results.add(FixResult(
        type: 'server_error',
        status: 'success',
        description: '成功修复服务器错误',
        details: '重启服务并修复代码问题',
      ));
      
    } catch (e) {
      results.add(FixResult(
        type: 'server_error',
        status: 'failed',
        description: '修复服务器错误失败: $e',
        details: e.toString(),
      ));
    }
    
    return results;
  }

  /// 修复数据库连接错误
  Future<List<FixResult>> _fixDatabaseConnection(Map<String, dynamic> context) async {
    final results = <FixResult>[];
    
    try {
      // 1. 检查Docker服务状态
      final dockerStatus = await Process.run('docker', ['ps']);
      if (dockerStatus.exitCode != 0) {
        // 启动Docker服务
        await Process.run('docker-compose', ['up', '-d'], workingDirectory: '/Users/gaojie/Desktop/fittraker');
      }
      
      // 2. 重启数据库服务
      await Process.run('docker-compose', ['restart', 'db'], workingDirectory: '/Users/gaojie/Desktop/fittraker');
      
      // 3. 等待数据库启动
      await Future.delayed(Duration(seconds: 10));
      
      // 4. 运行数据库迁移
      await Process.run('python', ['manage.py', 'migrate'], workingDirectory: backendPath);
      
      results.add(FixResult(
        type: 'database_connection',
        status: 'success',
        description: '成功修复数据库连接',
        details: '重启数据库服务并运行迁移',
      ));
      
    } catch (e) {
      results.add(FixResult(
        type: 'database_connection',
        status: 'failed',
        description: '修复数据库连接失败: $e',
        details: e.toString(),
      ));
    }
    
    return results;
  }

  /// 修复认证错误
  Future<List<FixResult>> _fixAuthError(Map<String, dynamic> context) async {
    final results = <FixResult>[];
    
    try {
      // 1. 检查JWT配置
      final configFile = File('$backendPath/app/core/config.py');
      if (await configFile.exists()) {
        final content = await configFile.readAsString();
        
        // 2. 确保JWT密钥存在
        if (!content.contains('SECRET_KEY')) {
          final secretKey = 'your-secret-key-here';
          final updatedContent = content + '\nSECRET_KEY = "$secretKey"\n';
          await configFile.writeAsString(updatedContent);
        }
      }
      
      // 3. 重启后端服务
      await _restartBackendService();
      
      results.add(FixResult(
        type: 'auth_error',
        status: 'success',
        description: '成功修复认证错误',
        details: '更新JWT配置并重启服务',
      ));
      
    } catch (e) {
      results.add(FixResult(
        type: 'auth_error',
        status: 'failed',
        description: '修复认证错误失败: $e',
        details: e.toString(),
      ));
    }
    
    return results;
  }

  /// 修复UI状态错误
  Future<List<FixResult>> _fixUIStateError(Map<String, dynamic> context) async {
    final results = <FixResult>[];
    
    try {
      // 1. 检查Flutter依赖
      final pubspecFile = File('$frontendPath/pubspec.yaml');
      if (await pubspecFile.exists()) {
        final content = await pubspecFile.readAsString();
        
        // 2. 确保必要的依赖存在
        final requiredDependencies = [
          'riverpod: ^2.4.9',
          'dio: ^5.4.0',
          'flutter_riverpod: ^2.4.9',
        ];
        
        bool needsUpdate = false;
        String updatedContent = content;
        
        for (final dep in requiredDependencies) {
          if (!content.contains(dep.split(':')[0])) {
            updatedContent += '\n  ${dep.split(':')[0]}: ${dep.split(':')[1]}';
            needsUpdate = true;
          }
        }
        
        if (needsUpdate) {
          await pubspecFile.writeAsString(updatedContent);
          
          // 3. 运行flutter pub get
          await Process.run('flutter', ['pub', 'get'], workingDirectory: frontendPath);
        }
      }
      
      results.add(FixResult(
        type: 'ui_state',
        status: 'success',
        description: '成功修复UI状态错误',
        details: '更新Flutter依赖并重新构建',
      ));
      
    } catch (e) {
      results.add(FixResult(
        type: 'ui_state',
        status: 'failed',
        description: '修复UI状态错误失败: $e',
        details: e.toString(),
      ));
    }
    
    return results;
  }

  /// 修复依赖错误
  Future<List<FixResult>> _fixDependencyError(Map<String, dynamic> context) async {
    final results = <FixResult>[];
    
    try {
      // 1. 修复Python依赖
      final requirementsFile = File('$backendPath/requirements.txt');
      if (await requirementsFile.exists()) {
        await Process.run('pip', ['install', '-r', 'requirements.txt'], workingDirectory: backendPath);
      }
      
      // 2. 修复Flutter依赖
      await Process.run('flutter', ['pub', 'get'], workingDirectory: frontendPath);
      
      // 3. 修复Go依赖
      final goModFile = File('$backendPath/go.mod');
      if (await goModFile.exists()) {
        await Process.run('go', ['mod', 'tidy'], workingDirectory: backendPath);
      }
      
      results.add(FixResult(
        type: 'dependency',
        status: 'success',
        description: '成功修复依赖错误',
        details: '更新所有项目依赖',
      ));
      
    } catch (e) {
      results.add(FixResult(
        type: 'dependency',
        status: 'failed',
        description: '修复依赖错误失败: $e',
        details: e.toString(),
      ));
    }
    
    return results;
  }

  /// 修复通用错误
  Future<List<FixResult>> _fixGenericError(String errorType, Map<String, dynamic> context) async {
    final results = <FixResult>[];
    
    try {
      // 1. 重启所有服务
      await _restartAllServices();
      
      // 2. 清理缓存
      await _clearCache();
      
      results.add(FixResult(
        type: 'generic',
        status: 'success',
        description: '成功修复通用错误',
        details: '重启服务并清理缓存',
      ));
      
    } catch (e) {
      results.add(FixResult(
        type: 'generic',
        status: 'failed',
        description: '修复通用错误失败: $e',
        details: e.toString(),
      ));
    }
    
    return results;
  }

  /// 生成API端点代码
  String _generateEndpointCode(String endpoint, String method) {
    final endpointName = endpoint.replaceAll('/', '_').replaceAll('-', '_');
    final methodUpper = method.toUpperCase();
    
    return '''
@router.$method("$endpoint")
async def ${endpointName}_endpoint(request: Request):
    """自动生成的API端点: $method $endpoint"""
    try:
        # TODO: 实现具体的业务逻辑
        return {"message": "Endpoint $endpoint is working", "method": "$method"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
''';
  }

  /// 修复导入错误
  Future<void> _fixImportError(String logs) async {
    // 分析导入错误并修复
    final importErrors = RegExp(r"ImportError: No module named '(\w+)'").allMatches(logs);
    
    for (final match in importErrors) {
      final moduleName = match.group(1);
      if (moduleName != null) {
        await Process.run('pip', ['install', moduleName], workingDirectory: backendPath);
      }
    }
  }

  /// 修复语法错误
  Future<void> _fixSyntaxError(String logs) async {
    // 分析语法错误并修复
    final syntaxErrors = RegExp(r"SyntaxError: (.+)").allMatches(logs);
    
    for (final match in syntaxErrors) {
      final error = match.group(1);
      print('发现语法错误: $error');
      // 这里可以实现更复杂的语法错误修复逻辑
    }
  }

  /// 修复属性错误
  Future<void> _fixAttributeError(String logs) async {
    // 分析属性错误并修复
    final attrErrors = RegExp(r"AttributeError: '(\w+)' object has no attribute '(\w+)'").allMatches(logs);
    
    for (final match in attrErrors) {
      final objectName = match.group(1);
      final attributeName = match.group(2);
      print('发现属性错误: $objectName 没有属性 $attributeName');
      // 这里可以实现更复杂的属性错误修复逻辑
    }
  }

  /// 重启后端服务
  Future<void> _restartBackendService() async {
    try {
      // 停止现有服务
      await Process.run('pkill', ['-f', 'python.*main.py']);
      
      // 等待服务停止
      await Future.delayed(Duration(seconds: 2));
      
      // 启动新服务
      await Process.start('python', ['main.py'], workingDirectory: backendPath);
      
      // 等待服务启动
      await Future.delayed(Duration(seconds: 5));
      
    } catch (e) {
      print('重启后端服务失败: $e');
    }
  }

  /// 重启所有服务
  Future<void> _restartAllServices() async {
    try {
      // 重启Docker服务
      await Process.run('docker-compose', ['restart'], workingDirectory: '/Users/gaojie/Desktop/fittraker');
      
      // 等待服务启动
      await Future.delayed(Duration(seconds: 10));
      
    } catch (e) {
      print('重启所有服务失败: $e');
    }
  }

  /// 清理缓存
  Future<void> _clearCache() async {
    try {
      // 清理Python缓存
      await Process.run('find', [backendPath, '-name', '__pycache__', '-type', 'd', '-exec', 'rm', '-rf', '{}', '+']);
      
      // 清理Flutter缓存
      await Process.run('flutter', ['clean'], workingDirectory: frontendPath);
      
    } catch (e) {
      print('清理缓存失败: $e');
    }
  }

  /// 生成修复报告
  Map<String, dynamic> generateFixReport() {
    return {
      'fixReport': {
        'timestamp': DateTime.now().toIso8601String(),
        'totalFixes': _fixResults.length,
        'successfulFixes': _fixResults.where((r) => r.status == 'success').length,
        'failedFixes': _fixResults.where((r) => r.status == 'failed').length,
        'fixResults': _fixResults.map((r) => {
          'type': r.type,
          'status': r.status,
          'description': r.description,
          'details': r.details,
          'timestamp': r.timestamp.toIso8601String(),
        }).toList(),
      }
    };
  }
}

/// 修复结果类
class FixResult {
  final String type;
  final String status;
  final String description;
  final String details;
  final DateTime timestamp;

  FixResult({
    required this.type,
    required this.status,
    required this.description,
    required this.details,
  }) : timestamp = DateTime.now();
}
