/// 全局错误处理服务
/// 提供统一的错误处理和用户友好的错误提示

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ErrorHandler {
  /// 处理错误并显示用户友好的提示
  static void handleError(BuildContext context, dynamic error) {
    String message = '发生未知错误';
    bool shouldRetry = false;
    
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = '网络连接超时，请检查网络设置';
          shouldRetry = true;
          break;
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode != null && statusCode == 401) {
            message = '登录已过期，请重新登录';
            // 跳转到登录页
            Navigator.of(context).pushReplacementNamed('/login');
            return;
          } else if (statusCode != null && statusCode == 403) {
            message = '权限不足，无法访问此功能';
          } else if (statusCode != null && statusCode == 404) {
            message = '请求的资源不存在';
          } else if (statusCode != null && statusCode >= 500) {
            message = '服务器错误，请稍后重试';
            shouldRetry = true;
          } else {
            message = error.response?.data?['error'] ?? '请求失败';
          }
          break;
        case DioExceptionType.connectionError:
          message = '网络连接失败，请检查网络设置';
          shouldRetry = true;
          break;
        case DioExceptionType.cancel:
          message = '请求已取消';
          break;
        default:
          message = error.message ?? '网络错误';
      }
    } else if (error is Exception) {
      message = error.toString();
    }
    
    // 显示错误提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: shouldRetry ? SnackBarAction(
          label: '重试',
          textColor: Colors.white,
          onPressed: () {
            // 可以添加重试逻辑
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ) : null,
      ),
    );
  }

  /// 处理成功消息
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 处理警告消息
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 处理信息消息
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
