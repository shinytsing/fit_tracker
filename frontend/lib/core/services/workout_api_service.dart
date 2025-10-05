import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

/// 训练计划 API 服务
class WorkoutApiService {
  static final Dio _dio = ApiService.instance;
  
  /// 获取训练计划列表
  static Future<List<Map<String, dynamic>>> getWorkoutPlans({
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      // 获取当前用户 ID
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? 'default_user';
      
      final response = await _dio.get('/workout/plans', queryParameters: {
        'user_id': userId,
        'skip': skip,
        'limit': limit,
      });
      
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '获取训练计划失败');
    }
  }
  
  /// 创建训练计划
  static Future<Map<String, dynamic>> createWorkoutPlan({
    required String name,
    required String planType,
    required String difficultyLevel,
    required int durationWeeks,
    String? description,
    List<Map<String, dynamic>>? exercises,
  }) async {
    try {
      final response = await _dio.post('/workout/plans', data: {
        'name': name,
        'plan_type': planType,
        'difficulty_level': difficultyLevel,
        'duration_weeks': durationWeeks,
        if (description != null) 'description': description,
        if (exercises != null) 'exercises': exercises,
      });
      
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '创建训练计划失败');
    }
  }
  
  /// 获取特定训练计划详情
  static Future<Map<String, dynamic>> getWorkoutPlan(String planId) async {
    try {
      final response = await _dio.get('/workout/plans/$planId');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '获取训练计划详情失败');
    }
  }
  
  /// 更新训练计划
  static Future<Map<String, dynamic>> updateWorkoutPlan({
    required String planId,
    String? name,
    String? planType,
    String? difficultyLevel,
    int? durationWeeks,
    String? description,
    List<Map<String, dynamic>>? exercises,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (planType != null) data['plan_type'] = planType;
      if (difficultyLevel != null) data['difficulty_level'] = difficultyLevel;
      if (durationWeeks != null) data['duration_weeks'] = durationWeeks;
      if (description != null) data['description'] = description;
      if (exercises != null) data['exercises'] = exercises;
      
      final response = await _dio.put('/workout/plans/$planId', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '更新训练计划失败');
    }
  }
  
  /// 删除训练计划
  static Future<void> deleteWorkoutPlan(String planId) async {
    try {
      await _dio.delete('/workout/plans/$planId');
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '删除训练计划失败');
    }
  }
  
  /// 获取运动动作列表
  static Future<List<Map<String, dynamic>>> getExercises({
    String? category,
    String? difficulty,
    String? equipment,
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'skip': skip,
        'limit': limit,
      };
      if (category != null) queryParams['category'] = category;
      if (difficulty != null) queryParams['difficulty'] = difficulty;
      if (equipment != null) queryParams['equipment'] = equipment;
      
      final response = await _dio.get('/workout/exercises', queryParameters: queryParams);
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '获取运动动作失败');
    }
  }
  
  /// 获取特定运动动作详情
  static Future<Map<String, dynamic>> getExercise(String exerciseId) async {
    try {
      final response = await _dio.get('/workout/exercises/$exerciseId');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '获取运动动作详情失败');
    }
  }
  
  /// 创建训练记录
  static Future<Map<String, dynamic>> createWorkoutRecord({
    required String planId,
    required DateTime startTime,
    required DateTime endTime,
    List<Map<String, dynamic>>? exercises,
    double? totalCalories,
    String? notes,
  }) async {
    try {
      final response = await _dio.post('/workout/records', data: {
        'plan_id': planId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        if (exercises != null) 'exercises': exercises,
        if (totalCalories != null) 'total_calories': totalCalories,
        if (notes != null) 'notes': notes,
      });
      
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '创建训练记录失败');
    }
  }
  
  /// 获取训练记录列表
  static Future<List<Map<String, dynamic>>> getWorkoutRecords({
    String? planId,
    String? startDate,
    String? endDate,
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'skip': skip,
        'limit': limit,
      };
      if (planId != null) queryParams['plan_id'] = planId;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      
      final response = await _dio.get('/workout/records', queryParameters: queryParams);
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '获取训练记录失败');
    }
  }
  
  /// 生成 AI 训练计划
  static Future<Map<String, dynamic>> generateAIPlan({
    required String goal,
    required String difficulty,
    required int duration,
    List<String>? availableEquipment,
    Map<String, dynamic>? userPreferences,
  }) async {
    try {
      final response = await _dio.post('/workout/ai/generate-plan', data: {
        'goal': goal,
        'difficulty': difficulty,
        'duration': duration,
        if (availableEquipment != null) 'available_equipment': availableEquipment,
        if (userPreferences != null) 'user_preferences': userPreferences,
      });
      
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'AI计划生成失败');
    }
  }
  
  /// 获取训练进度统计
  static Future<Map<String, dynamic>> getWorkoutProgress({
    String period = 'week',
  }) async {
    try {
      final response = await _dio.get('/workout/progress', queryParameters: {
        'period': period,
      });
      
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '获取训练进度失败');
    }
  }
  
  /// 提交动作反馈
  static Future<Map<String, dynamic>> submitExerciseFeedback({
    required String exerciseId,
    required Map<String, dynamic> feedbackData,
  }) async {
    try {
      final response = await _dio.post('/workout/exercises/$exerciseId/feedback', data: feedbackData);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '提交动作反馈失败');
    }
  }
}
