import 'package:dio/dio.dart';
import 'api_service.dart';

/// 社区 API 服务
class CommunityApiService {
  static final Dio _dio = ApiService.instance;
  
  /// 发布动态
  static Future<Map<String, dynamic>> createPost({
    required String content,
    List<String>? images,
    List<String>? videos,
    String postType = 'text',
    List<String>? tags,
    String? location,
  }) async {
    try {
      final response = await _dio.post('/community/posts', data: {
        'content': content,
        if (images != null) 'images': images,
        if (videos != null) 'videos': videos,
        'post_type': postType,
        if (tags != null) 'tags': tags,
        if (location != null) 'location': location,
      });
      
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '发布动态失败');
    }
  }
  
  /// 获取动态列表
  static Future<List<Map<String, dynamic>>> getPosts({
    int page = 1,
    int pageSize = 20,
    String? type,
    String? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      if (type != null) queryParams['type'] = type;
      if (category != null) queryParams['category'] = category;
      
      final response = await _dio.get('/community/posts', queryParameters: queryParams);
      return List<Map<String, dynamic>>.from(response.data['items'] ?? []);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '获取动态列表失败');
    }
  }
  
  /// 点赞动态
  static Future<void> likePost(String postId) async {
    try {
      await _dio.post('/community/posts/$postId/like');
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '点赞失败');
    }
  }
  
  /// 取消点赞动态
  static Future<void> unlikePost(String postId) async {
    try {
      await _dio.delete('/community/posts/$postId/like');
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '取消点赞失败');
    }
  }
  
  /// 添加评论
  static Future<Map<String, dynamic>> addComment({
    required String postId,
    required String content,
  }) async {
    try {
      final response = await _dio.post('/community/posts/$postId/comments', data: {
        'content': content,
      });
      
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '添加评论失败');
    }
  }
  
  /// 获取评论列表
  static Future<List<Map<String, dynamic>>> getComments({
    required String postId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get('/community/posts/$postId/comments', queryParameters: {
        'page': page,
        'page_size': pageSize,
      });
      
      return List<Map<String, dynamic>>.from(response.data['items'] ?? []);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '获取评论列表失败');
    }
  }
  
  /// 关注用户
  static Future<void> followUser(String userId) async {
    try {
      await _dio.post('/community/users/$userId/follow');
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '关注用户失败');
    }
  }
  
  /// 取消关注用户
  static Future<void> unfollowUser(String userId) async {
    try {
      await _dio.delete('/community/users/$userId/follow');
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '取消关注失败');
    }
  }
  
  /// 获取关注列表
  static Future<List<Map<String, dynamic>>> getFollowing({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get('/community/following', queryParameters: {
        'page': page,
        'page_size': pageSize,
      });
      
      return List<Map<String, dynamic>>.from(response.data['items'] ?? []);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '获取关注列表失败');
    }
  }
  
  /// 获取粉丝列表
  static Future<List<Map<String, dynamic>>> getFollowers({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get('/community/followers', queryParameters: {
        'page': page,
        'page_size': pageSize,
      });
      
      return List<Map<String, dynamic>>.from(response.data['items'] ?? []);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '获取粉丝列表失败');
    }
  }
  
  /// 搜索用户
  static Future<List<Map<String, dynamic>>> searchUsers({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get('/community/users/search', queryParameters: {
        'q': query,
        'page': page,
        'page_size': pageSize,
      });
      
      return List<Map<String, dynamic>>.from(response.data['items'] ?? []);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '搜索用户失败');
    }
  }
}