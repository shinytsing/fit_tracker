import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../config/api_config.dart';

class RestApiService {
  static const String _baseUrl = ApiConfig.baseUrl;
  static const String _apiPrefix = '/api/v1/rest';

  // 获取认证头
  static Map<String, String> _getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 开始休息
  static Future<RestSession> startRest({
    required int duration,
    String? notes,
    String? token,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$_apiPrefix/start'),
      headers: _getHeaders(token),
      body: jsonEncode({
        'duration': duration,
        'notes': notes ?? '',
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return RestSession.fromJson(data['data']);
      }
    }

    throw Exception('开始休息失败: ${response.body}');
  }

  // 完成休息
  static Future<void> completeRest({
    required int sessionId,
    String? notes,
    String? token,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$_apiPrefix/complete'),
      headers: _getHeaders(token),
      body: jsonEncode({
        'session_id': sessionId,
        'notes': notes ?? '',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('完成休息失败: ${response.body}');
    }
  }

  // 获取组间动态流
  static Future<RestFeed> getRestFeed({
    int page = 1,
    int limit = 10,
    String? token,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$_apiPrefix/feed?page=$page&limit=$limit'),
      headers: _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return RestFeed.fromJson(data['data']);
      }
    }

    throw Exception('获取动态流失败: ${response.body}');
  }

  // 创建组间动态
  static Future<RestPost> createRestPost({
    required String content,
    String? imageUrl,
    required String type,
    String? token,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$_apiPrefix/posts'),
      headers: _getHeaders(token),
      body: jsonEncode({
        'content': content,
        'image_url': imageUrl,
        'type': type,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return RestPost.fromJson(data['data']);
      }
    }

    throw Exception('发布动态失败: ${response.body}');
  }

  // 点赞组间动态
  static Future<void> likeRestPost({
    required int postId,
    String? token,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$_apiPrefix/posts/$postId/like'),
      headers: _getHeaders(token),
    );

    if (response.statusCode != 200) {
      throw Exception('点赞失败: ${response.body}');
    }
  }

  // 评论组间动态
  static Future<void> commentRestPost({
    required int postId,
    required String content,
    String? token,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$_apiPrefix/posts/$postId/comment'),
      headers: _getHeaders(token),
      body: jsonEncode({
        'content': content,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('评论失败: ${response.body}');
    }
  }
}
