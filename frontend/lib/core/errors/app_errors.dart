/// 应用错误处理
/// 定义统一的错误类型和处理机制

/// 应用错误基类
abstract class AppError {
  final String message;
  final String? code;
  final dynamic details;

  const AppError({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'AppError: $message';
}

/// 网络错误
class NetworkError extends AppError {
  const NetworkError({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 服务器错误
class ServerError extends AppError {
  const ServerError({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 验证错误
class ValidationError extends AppError {
  const ValidationError({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 认证错误
class AuthError extends AppError {
  const AuthError({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 权限错误
class PermissionError extends AppError {
  const PermissionError({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 缓存错误
class CacheError extends AppError {
  const CacheError({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 未知错误
class UnknownError extends AppError {
  const UnknownError({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 结果类型，用于处理成功和失败的情况
sealed class Result<T> {
  const Result();
}

/// 成功结果
class Success<T> extends Result<T> {
  final T data;
  
  const Success(this.data);
}

/// 失败结果
class Failure<T> extends Result<T> {
  final AppError error;
  
  const Failure(this.error);
}

/// 扩展方法，用于处理结果
extension ResultExtensions<T> on Result<T> {
  /// 是否成功
  bool get isSuccess => this is Success<T>;
  
  /// 是否失败
  bool get isFailure => this is Failure<T>;
  
  /// 获取数据，失败时返回 null
  T? get dataOrNull => switch (this) {
    Success<T>(data: final data) => data,
    Failure<T>() => null,
  };
  
  /// 获取错误，成功时返回 null
  AppError? get errorOrNull => switch (this) {
    Success<T>() => null,
    Failure<T>(error: final error) => error,
  };
  
  /// 映射数据
  Result<R> map<R>(R Function(T) mapper) => switch (this) {
    Success<T>(data: final data) => Success(mapper(data)),
    Failure<T>(error: final error) => Failure<R>(error),
  };
  
  /// 处理结果
  R when<R>({
    required R Function(T) success,
    required R Function(AppError) failure,
  }) => switch (this) {
    Success<T>(data: final data) => success(data),
    Failure<T>(error: final error) => failure(error),
  };
}