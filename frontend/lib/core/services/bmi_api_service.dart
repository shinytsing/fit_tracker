import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

/// BMI 计算 API 服务
class BMIApiService {
  static final Dio _dio = ApiService.instance;
  
  /// 计算 BMI
  static Future<Map<String, dynamic>> calculateBMI({
    required double height,
    required double weight,
    int? age,
    String? gender,
  }) async {
    try {
      // 获取当前用户 ID
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? 'default_user';
      
      final response = await _dio.post('/bmi/calculate', 
        queryParameters: {'user_id': userId},
        data: {
          'height': height,
          'weight': weight,
          if (age != null) 'age': age,
          if (gender != null) 'gender': gender,
        });
      
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'BMI计算失败');
    }
  }
  
  /// 创建 BMI 记录
  static Future<Map<String, dynamic>> createBMIRecord({
    required double height,
    required double weight,
    required double bmi,
    String? notes,
  }) async {
    try {
      final response = await _dio.post('/bmi/records', data: {
        'height': height,
        'weight': weight,
        'bmi': bmi,
        if (notes != null) 'notes': notes,
      });
      
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '创建BMI记录失败');
    }
  }
  
  /// 获取 BMI 记录列表
  static Future<List<Map<String, dynamic>>> getBMIRecords({
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get('/bmi/records', queryParameters: {
        'skip': skip,
        'limit': limit,
      });
      
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '获取BMI记录失败');
    }
  }
  
  /// 获取 BMI 统计信息
  static Future<Map<String, dynamic>> getBMIStats({
    String period = 'month',
  }) async {
    try {
      final response = await _dio.get('/bmi/stats', queryParameters: {
        'period': period,
      });
      
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '获取BMI统计失败');
    }
  }
  
  /// 获取 BMI 趋势
  static Future<Map<String, dynamic>> getBMITrend({
    int days = 30,
  }) async {
    try {
      final response = await _dio.get('/bmi/trend', queryParameters: {
        'days': days,
      });
      
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '获取BMI趋势失败');
    }
  }
  
  /// 获取健康建议
  static Future<Map<String, dynamic>> getHealthAdvice({
    required double bmi,
  }) async {
    try {
      final response = await _dio.get('/bmi/advice', queryParameters: {
        'bmi': bmi,
      });
      
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '获取健康建议失败');
    }
  }
}
