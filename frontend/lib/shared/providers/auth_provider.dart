/// 认证 Provider
/// 管理用户认证状态和操作

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/base_providers.dart';
import '../../core/errors/app_errors.dart';
import '../../core/services/auth_api_service.dart';

/// 用户模型
class User {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLoginAt: json['last_login_at'] != null 
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatar,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

/// 认证状态
class AuthState extends BaseState {
  final User? user;
  final String? token;
  final bool isAuthenticated;

  const AuthState({
    required super.loadingState,
    super.error,
    this.user,
    this.token,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    LoadingState? loadingState,
    AppError? error,
    User? user,
    String? token,
    bool? isAuthenticated,
  }) {
    return AuthState(
      loadingState: loadingState ?? this.loadingState,
      error: error ?? this.error,
      user: user ?? this.user,
      token: token ?? this.token,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// 认证 Provider
class AuthProvider extends BaseProvider<AuthState> {
  AuthProvider() : super(const AuthState(loadingState: LoadingState.idle));

  AuthState copyWith({
    LoadingState? loadingState,
    AppError? error,
  }) {
    return state.copyWith(
      loadingState: loadingState,
      error: error,
    );
  }

  /// 登录
  Future<void> login(String email, String password) async {
    setLoading();
    
    try {
      // 调用真实 API
      final response = await AuthApiService.login(
        username: email,
        password: password,
      );
      
      // 解析响应数据
      final userData = response['user'] ?? response;
      final user = User(
        id: userData['id'].toString(),
        email: userData['email'] ?? email,
        name: userData['username'] ?? userData['name'] ?? '用户',
        avatar: userData['avatar_url'],
        createdAt: DateTime.parse(userData['created_at'] ?? DateTime.now().toIso8601String()),
        lastLoginAt: DateTime.now(),
      );
      
      setSuccess();
      state = state.copyWith(
        user: user,
        token: response['access_token'] ?? response['token'],
        isAuthenticated: true,
      );
    } catch (e) {
      setError(AuthError(message: '登录失败: ${e.toString()}'));
    }
  }

  /// 注册
  Future<void> register(String email, String password, String name) async {
    setLoading();
    
    try {
      // 调用真实 API
      final response = await AuthApiService.register(
        username: name,
        email: email,
        password: password,
      );
      
      // 解析响应数据
      final userData = response['user'] ?? response;
      final user = User(
        id: userData['id'].toString(),
        email: userData['email'] ?? email,
        name: userData['username'] ?? name,
        avatar: userData['avatar_url'],
        createdAt: DateTime.parse(userData['created_at'] ?? DateTime.now().toIso8601String()),
      );
      
      setSuccess();
      state = state.copyWith(
        user: user,
        token: response['access_token'] ?? response['token'],
        isAuthenticated: true,
      );
    } catch (e) {
      setError(AuthError(message: '注册失败: ${e.toString()}'));
    }
  }

  /// 登出
  Future<void> logout() async {
    setLoading();
    
    try {
      // 调用真实 API
      await AuthApiService.logout();
      
      setSuccess();
      state = const AuthState(loadingState: LoadingState.success);
    } catch (e) {
      setError(AuthError(message: '登出失败: ${e.toString()}'));
    }
  }

  /// 更新用户信息
  Future<void> updateProfile({
    String? name,
    String? avatar,
  }) async {
    if (state.user == null) return;
    
    setLoading();
    
    try {
      // TODO: 实现实际的更新逻辑
      await Future.delayed(const Duration(seconds: 1)); // 模拟网络请求
      
      final updatedUser = state.user!.copyWith(
        name: name ?? state.user!.name,
        avatar: avatar ?? state.user!.avatar,
      );
      
      setSuccess();
      state = state.copyWith(user: updatedUser);
    } catch (e) {
      setError(AuthError(message: '更新失败: ${e.toString()}'));
    }
  }

  /// 检查认证状态
  Future<void> checkAuthStatus() async {
    setLoading();
    
    try {
      // 检查是否已登录
      final isLoggedIn = await AuthApiService.isLoggedIn();
      
      if (isLoggedIn) {
        // 获取当前用户信息
        final response = await AuthApiService.getCurrentUser();
        final userData = response['user'] ?? response;
        
        final user = User(
          id: userData['id'].toString(),
          email: userData['email'] ?? '',
          name: userData['username'] ?? userData['name'] ?? '用户',
          avatar: userData['avatar_url'],
          createdAt: DateTime.parse(userData['created_at'] ?? DateTime.now().toIso8601String()),
          lastLoginAt: DateTime.parse(userData['last_login_at'] ?? DateTime.now().toIso8601String()),
        );
        
        setSuccess();
        state = state.copyWith(
          user: user,
          token: 'stored_token',
          isAuthenticated: true,
        );
      } else {
        setSuccess();
        state = const AuthState(loadingState: LoadingState.success);
      }
    } catch (e) {
      setError(AuthError(message: '检查认证状态失败: ${e.toString()}'));
    }
  }
}

/// 认证 Provider 实例
final authProvider = StateNotifierProvider<AuthProvider, AuthState>((ref) {
  return AuthProvider();
});

/// 认证状态选择器
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});