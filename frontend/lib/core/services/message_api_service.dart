import 'package:dio/dio.dart';
import 'api_service.dart';

/// 消息 API 服务
class MessageApiService {
  static final Dio _dio = ApiService.instance;
  
  /// 获取聊天列表
  static Future<List<Map<String, dynamic>>> getChats({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get('/messages/chats', queryParameters: {
        'page': page,
        'page_size': pageSize,
      });
      
      return List<Map<String, dynamic>>.from(response.data['items'] ?? []);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '获取聊天列表失败');
    }
  }
  
  /// 获取聊天消息
  static Future<List<Map<String, dynamic>>> getMessages({
    required String chatId,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _dio.get('/messages/chats/$chatId/messages', queryParameters: {
        'page': page,
        'page_size': pageSize,
      });
      
      return List<Map<String, dynamic>>.from(response.data['items'] ?? []);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '获取消息失败');
    }
  }
  
  /// 发送消息
  static Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String content,
    String? messageType,
    List<String>? attachments,
  }) async {
    try {
      final response = await _dio.post('/messages/chats/$chatId/messages', data: {
        'content': content,
        if (messageType != null) 'message_type': messageType,
        if (attachments != null) 'attachments': attachments,
      });
      
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '发送消息失败');
    }
  }
  
  /// 创建聊天
  static Future<Map<String, dynamic>> createChat({
    required String userId,
    String? initialMessage,
  }) async {
    try {
      final response = await _dio.post('/messages/chats', data: {
        'user_id': userId,
        if (initialMessage != null) 'initial_message': initialMessage,
      });
      
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '创建聊天失败');
    }
  }
  
  /// 获取通知列表
  static Future<List<Map<String, dynamic>>> getNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get('/messages/notifications', queryParameters: {
        'page': page,
        'page_size': pageSize,
      });
      
      return List<Map<String, dynamic>>.from(response.data['items'] ?? []);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '获取通知失败');
    }
  }
  
  /// 标记通知为已读
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _dio.put('/messages/notifications/$notificationId/read');
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '标记通知已读失败');
    }
  }
  
  /// 标记所有通知为已读
  static Future<void> markAllNotificationsAsRead() async {
    try {
      await _dio.put('/messages/notifications/read-all');
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '标记所有通知已读失败');
    }
  }
  
  /// 删除消息
  static Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    try {
      await _dio.delete('/messages/chats/$chatId/messages/$messageId');
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '删除消息失败');
    }
  }
  
  /// 上传文件
  static Future<Map<String, dynamic>> uploadFile({
    required String filePath,
    String? fileType,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        if (fileType != null) 'file_type': fileType,
      });
      
      final response = await _dio.post('/messages/upload', data: formData);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? '文件上传失败');
    }
  }
}
