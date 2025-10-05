import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

/// FitTracker 数据库验证系统
/// 用于验证数据库写入、查询和关联关系
class DatabaseValidationSystem {
  final Dio _dio = Dio();
  final String baseUrl = 'http://localhost:8080/api/v1';
  final String dbHost = 'localhost';
  final String dbPort = '5432';
  final String dbName = 'fittracker';
  final String dbUser = 'postgres';
  final String dbPassword = 'password';
  
  List<ValidationResult> _validationResults = [];
  
  DatabaseValidationSystem() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = Duration(seconds: 15);
    _dio.options.receiveTimeout = Duration(seconds: 15);
  }

  /// 验证用户数据库操作
  Future<bool> validateUserInDatabase() async {
    try {
      // 1. 通过API查询用户
      final response = await _dio.get('/users/profile');
      if (response.statusCode != 200) {
        return false;
      }
      
      // 2. 验证用户数据结构
      final userData = response.data;
      final requiredFields = ['id', 'username', 'email', 'created_at'];
      
      for (final field in requiredFields) {
        if (!userData.containsKey(field)) {
          _validationResults.add(ValidationResult(
            type: 'user_validation',
            status: 'failed',
            description: '用户数据缺少字段: $field',
            details: userData.toString(),
          ));
          return false;
        }
      }
      
      // 3. 验证数据完整性
      if (userData['username'] == null || userData['email'] == null) {
        _validationResults.add(ValidationResult(
          type: 'user_validation',
          status: 'failed',
          description: '用户数据不完整',
          details: userData.toString(),
        ));
        return false;
      }
      
      _validationResults.add(ValidationResult(
        type: 'user_validation',
        status: 'success',
        description: '用户数据验证通过',
        details: userData.toString(),
      ));
      
      return true;
      
    } catch (e) {
      _validationResults.add(ValidationResult(
        type: 'user_validation',
        status: 'failed',
        description: '用户数据验证失败: $e',
        details: e.toString(),
      ));
      return false;
    }
  }

  /// 验证BMI记录数据库操作
  Future<bool> validateBMIRecordInDatabase() async {
    try {
      // 1. 通过API查询BMI记录
      final response = await _dio.get('/bmi/records');
      if (response.statusCode != 200) {
        return false;
      }
      
      // 2. 验证BMI记录数据结构
      final records = response.data is List ? response.data : response.data['records'];
      if (records == null || records.isEmpty) {
        _validationResults.add(ValidationResult(
          type: 'bmi_validation',
          status: 'warning',
          description: 'BMI记录为空',
          details: '可能还没有创建BMI记录',
        ));
        return true; // 空记录不算错误
      }
      
      // 3. 验证最新记录
      final latestRecord = records.first;
      final requiredFields = ['id', 'bmi', 'height', 'weight', 'created_at'];
      
      for (final field in requiredFields) {
        if (!latestRecord.containsKey(field)) {
          _validationResults.add(ValidationResult(
            type: 'bmi_validation',
            status: 'failed',
            description: 'BMI记录缺少字段: $field',
            details: latestRecord.toString(),
          ));
          return false;
        }
      }
      
      // 4. 验证BMI值合理性
      final bmi = latestRecord['bmi'];
      if (bmi == null || bmi < 10 || bmi > 100) {
        _validationResults.add(ValidationResult(
          type: 'bmi_validation',
          status: 'failed',
          description: 'BMI值不合理: $bmi',
          details: latestRecord.toString(),
        ));
        return false;
      }
      
      _validationResults.add(ValidationResult(
        type: 'bmi_validation',
        status: 'success',
        description: 'BMI记录验证通过',
        details: latestRecord.toString(),
      ));
      
      return true;
      
    } catch (e) {
      _validationResults.add(ValidationResult(
        type: 'bmi_validation',
        status: 'failed',
        description: 'BMI记录验证失败: $e',
        details: e.toString(),
      ));
      return false;
    }
  }

  /// 验证训练计划数据库操作
  Future<bool> validateTrainingPlanInDatabase() async {
    try {
      // 1. 通过API查询训练计划
      final response = await _dio.get('/workout/plans');
      if (response.statusCode != 200) {
        return false;
      }
      
      // 2. 验证训练计划数据结构
      final plans = response.data is List ? response.data : response.data['plans'];
      if (plans == null || plans.isEmpty) {
        _validationResults.add(ValidationResult(
          type: 'training_plan_validation',
          status: 'warning',
          description: '训练计划为空',
          details: '可能还没有创建训练计划',
        ));
        return true; // 空记录不算错误
      }
      
      // 3. 验证最新计划
      final latestPlan = plans.first;
      final requiredFields = ['id', 'name', 'type', 'created_at'];
      
      for (final field in requiredFields) {
        if (!latestPlan.containsKey(field)) {
          _validationResults.add(ValidationResult(
            type: 'training_plan_validation',
            status: 'failed',
            description: '训练计划缺少字段: $field',
            details: latestPlan.toString(),
          ));
          return false;
        }
      }
      
      // 4. 验证计划内容
      if (latestPlan['name'] == null || latestPlan['name'].toString().isEmpty) {
        _validationResults.add(ValidationResult(
          type: 'training_plan_validation',
          status: 'failed',
          description: '训练计划名称为空',
          details: latestPlan.toString(),
        ));
        return false;
      }
      
      _validationResults.add(ValidationResult(
        type: 'training_plan_validation',
        status: 'success',
        description: '训练计划验证通过',
        details: latestPlan.toString(),
      ));
      
      return true;
      
    } catch (e) {
      _validationResults.add(ValidationResult(
        type: 'training_plan_validation',
        status: 'failed',
        description: '训练计划验证失败: $e',
        details: e.toString(),
      ));
      return false;
    }
  }

  /// 验证社区动态数据库操作
  Future<bool> validatePostInDatabase(String? postId) async {
    if (postId == null) return false;
    
    try {
      // 1. 通过API查询特定动态
      final response = await _dio.get('/community/posts/$postId');
      if (response.statusCode != 200) {
        return false;
      }
      
      // 2. 验证动态数据结构
      final postData = response.data;
      final requiredFields = ['id', 'content', 'user_id', 'created_at'];
      
      for (final field in requiredFields) {
        if (!postData.containsKey(field)) {
          _validationResults.add(ValidationResult(
            type: 'post_validation',
            status: 'failed',
            description: '动态数据缺少字段: $field',
            details: postData.toString(),
          ));
          return false;
        }
      }
      
      // 3. 验证动态内容
      if (postData['content'] == null || postData['content'].toString().isEmpty) {
        _validationResults.add(ValidationResult(
          type: 'post_validation',
          status: 'failed',
          description: '动态内容为空',
          details: postData.toString(),
        ));
        return false;
      }
      
      _validationResults.add(ValidationResult(
        type: 'post_validation',
        status: 'success',
        description: '动态数据验证通过',
        details: postData.toString(),
      ));
      
      return true;
      
    } catch (e) {
      _validationResults.add(ValidationResult(
        type: 'post_validation',
        status: 'failed',
        description: '动态数据验证失败: $e',
        details: e.toString(),
      ));
      return false;
    }
  }

  /// 验证点赞数据库操作
  Future<bool> validateLikeInDatabase(String? postId) async {
    if (postId == null) return false;
    
    try {
      // 1. 通过API查询动态详情（包含点赞信息）
      final response = await _dio.get('/community/posts/$postId');
      if (response.statusCode != 200) {
        return false;
      }
      
      // 2. 验证点赞数据结构
      final postData = response.data;
      if (postData.containsKey('likes_count')) {
        final likesCount = postData['likes_count'];
        if (likesCount != null && likesCount >= 0) {
          _validationResults.add(ValidationResult(
            type: 'like_validation',
            status: 'success',
            description: '点赞数据验证通过',
            details: '点赞数: $likesCount',
          ));
          return true;
        }
      }
      
      // 3. 如果没有likes_count字段，尝试查询点赞列表
      final likesResponse = await _dio.get('/community/posts/$postId/likes');
      if (likesResponse.statusCode == 200) {
        _validationResults.add(ValidationResult(
          type: 'like_validation',
          status: 'success',
          description: '点赞数据验证通过',
          details: '点赞列表查询成功',
        ));
        return true;
      }
      
      _validationResults.add(ValidationResult(
        type: 'like_validation',
        status: 'warning',
        description: '点赞数据验证警告',
        details: '无法获取点赞信息，但API调用成功',
      ));
      
      return true;
      
    } catch (e) {
      _validationResults.add(ValidationResult(
        type: 'like_validation',
        status: 'failed',
        description: '点赞数据验证失败: $e',
        details: e.toString(),
      ));
      return false;
    }
  }

  /// 验证评论数据库操作
  Future<bool> validateCommentInDatabase(String? postId) async {
    if (postId == null) return false;
    
    try {
      // 1. 通过API查询评论列表
      final response = await _dio.get('/community/posts/$postId/comments');
      if (response.statusCode != 200) {
        return false;
      }
      
      // 2. 验证评论数据结构
      final comments = response.data is List ? response.data : response.data['comments'];
      if (comments == null) {
        _validationResults.add(ValidationResult(
          type: 'comment_validation',
          status: 'failed',
          description: '评论数据格式错误',
          details: response.data.toString(),
        ));
        return false;
      }
      
      // 3. 如果有评论，验证最新评论
      if (comments.isNotEmpty) {
        final latestComment = comments.first;
        final requiredFields = ['id', 'content', 'user_id', 'created_at'];
        
        for (final field in requiredFields) {
          if (!latestComment.containsKey(field)) {
            _validationResults.add(ValidationResult(
              type: 'comment_validation',
              status: 'failed',
              description: '评论数据缺少字段: $field',
              details: latestComment.toString(),
            ));
            return false;
          }
        }
      }
      
      _validationResults.add(ValidationResult(
        type: 'comment_validation',
        status: 'success',
        description: '评论数据验证通过',
        details: '评论数量: ${comments.length}',
      ));
      
      return true;
      
    } catch (e) {
      _validationResults.add(ValidationResult(
        type: 'comment_validation',
        status: 'failed',
        description: '评论数据验证失败: $e',
        details: e.toString(),
      ));
      return false;
    }
  }

  /// 验证健康记录数据库操作
  Future<bool> validateHealthRecordInDatabase() async {
    try {
      // 1. 通过API查询健康记录
      final response = await _dio.get('/health/records');
      if (response.statusCode != 200) {
        return false;
      }
      
      // 2. 验证健康记录数据结构
      final records = response.data is List ? response.data : response.data['records'];
      if (records == null || records.isEmpty) {
        _validationResults.add(ValidationResult(
          type: 'health_record_validation',
          status: 'warning',
          description: '健康记录为空',
          details: '可能还没有创建健康记录',
        ));
        return true; // 空记录不算错误
      }
      
      // 3. 验证最新记录
      final latestRecord = records.first;
      final requiredFields = ['id', 'type', 'value', 'created_at'];
      
      for (final field in requiredFields) {
        if (!latestRecord.containsKey(field)) {
          _validationResults.add(ValidationResult(
            type: 'health_record_validation',
            status: 'failed',
            description: '健康记录缺少字段: $field',
            details: latestRecord.toString(),
          ));
          return false;
        }
      }
      
      // 4. 验证记录值合理性
      final value = latestRecord['value'];
      if (value == null) {
        _validationResults.add(ValidationResult(
          type: 'health_record_validation',
          status: 'failed',
          description: '健康记录值为空',
          details: latestRecord.toString(),
        ));
        return false;
      }
      
      _validationResults.add(ValidationResult(
        type: 'health_record_validation',
        status: 'success',
        description: '健康记录验证通过',
        details: latestRecord.toString(),
      ));
      
      return true;
      
    } catch (e) {
      _validationResults.add(ValidationResult(
        type: 'health_record_validation',
        status: 'failed',
        description: '健康记录验证失败: $e',
        details: e.toString(),
      ));
      return false;
    }
  }

  /// 验证签到记录数据库操作
  Future<bool> validateCheckinInDatabase() async {
    try {
      // 1. 通过API查询签到记录
      final response = await _dio.get('/checkins');
      if (response.statusCode != 200) {
        return false;
      }
      
      // 2. 验证签到记录数据结构
      final checkins = response.data is List ? response.data : response.data['checkins'];
      if (checkins == null || checkins.isEmpty) {
        _validationResults.add(ValidationResult(
          type: 'checkin_validation',
          status: 'warning',
          description: '签到记录为空',
          details: '可能还没有创建签到记录',
        ));
        return true; // 空记录不算错误
      }
      
      // 3. 验证最新签到
      final latestCheckin = checkins.first;
      final requiredFields = ['id', 'type', 'created_at'];
      
      for (final field in requiredFields) {
        if (!latestCheckin.containsKey(field)) {
          _validationResults.add(ValidationResult(
            type: 'checkin_validation',
            status: 'failed',
            description: '签到记录缺少字段: $field',
            details: latestCheckin.toString(),
          ));
          return false;
        }
      }
      
      _validationResults.add(ValidationResult(
        type: 'checkin_validation',
        status: 'success',
        description: '签到记录验证通过',
        details: latestCheckin.toString(),
      ));
      
      return true;
      
    } catch (e) {
      _validationResults.add(ValidationResult(
        type: 'checkin_validation',
        status: 'failed',
        description: '签到记录验证失败: $e',
        details: e.toString(),
      ));
      return false;
    }
  }

  /// 验证营养记录数据库操作
  Future<bool> validateNutritionRecordInDatabase() async {
    try {
      // 1. 通过API查询营养记录
      final response = await _dio.get('/nutrition/records');
      if (response.statusCode != 200) {
        return false;
      }
      
      // 2. 验证营养记录数据结构
      final records = response.data is List ? response.data : response.data['records'];
      if (records == null || records.isEmpty) {
        _validationResults.add(ValidationResult(
          type: 'nutrition_record_validation',
          status: 'warning',
          description: '营养记录为空',
          details: '可能还没有创建营养记录',
        ));
        return true; // 空记录不算错误
      }
      
      // 3. 验证最新记录
      final latestRecord = records.first;
      final requiredFields = ['id', 'food_name', 'quantity', 'created_at'];
      
      for (final field in requiredFields) {
        if (!latestRecord.containsKey(field)) {
          _validationResults.add(ValidationResult(
            type: 'nutrition_record_validation',
            status: 'failed',
            description: '营养记录缺少字段: $field',
            details: latestRecord.toString(),
          ));
          return false;
        }
      }
      
      // 4. 验证记录值合理性
      final quantity = latestRecord['quantity'];
      if (quantity == null || quantity <= 0) {
        _validationResults.add(ValidationResult(
          type: 'nutrition_record_validation',
          status: 'failed',
          description: '营养记录数量不合理: $quantity',
          details: latestRecord.toString(),
        ));
        return false;
      }
      
      _validationResults.add(ValidationResult(
        type: 'nutrition_record_validation',
        status: 'success',
        description: '营养记录验证通过',
        details: latestRecord.toString(),
      ));
      
      return true;
      
    } catch (e) {
      _validationResults.add(ValidationResult(
        type: 'nutrition_record_validation',
        status: 'failed',
        description: '营养记录验证失败: $e',
        details: e.toString(),
      ));
      return false;
    }
  }

  /// 验证数据库连接
  Future<bool> validateDatabaseConnection() async {
    try {
      // 1. 通过健康检查API验证数据库连接
      final response = await _dio.get('/health/database');
      if (response.statusCode != 200) {
        return false;
      }
      
      // 2. 验证响应数据
      final healthData = response.data;
      if (healthData['status'] == 'healthy') {
        _validationResults.add(ValidationResult(
          type: 'database_connection',
          status: 'success',
          description: '数据库连接验证通过',
          details: healthData.toString(),
        ));
        return true;
      }
      
      _validationResults.add(ValidationResult(
        type: 'database_connection',
        status: 'failed',
        description: '数据库连接不健康',
        details: healthData.toString(),
      ));
      
      return false;
      
    } catch (e) {
      _validationResults.add(ValidationResult(
        type: 'database_connection',
        status: 'failed',
        description: '数据库连接验证失败: $e',
        details: e.toString(),
      ));
      return false;
    }
  }

  /// 生成数据库验证报告
  Map<String, dynamic> generateValidationReport() {
    return {
      'validationReport': {
        'timestamp': DateTime.now().toIso8601String(),
        'totalValidations': _validationResults.length,
        'successfulValidations': _validationResults.where((r) => r.status == 'success').length,
        'failedValidations': _validationResults.where((r) => r.status == 'failed').length,
        'warningValidations': _validationResults.where((r) => r.status == 'warning').length,
        'validationResults': _validationResults.map((r) => {
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

/// 验证结果类
class ValidationResult {
  final String type;
  final String status;
  final String description;
  final String details;
  final DateTime timestamp;

  ValidationResult({
    required this.type,
    required this.status,
    required this.description,
    required this.details,
  }) : timestamp = DateTime.now();
}
