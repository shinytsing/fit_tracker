/// 应用路由配置
/// 使用 GoRouter 管理应用导航

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/test/pages/test_api_page.dart';

/// 路由路径常量
class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String test = '/test';
}

/// 应用路由 Provider
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: authState.isAuthenticated ? AppRoutes.home : AppRoutes.login,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == AppRoutes.login;
      
      // 如果未认证且不在登录页面，重定向到登录页
      if (!isAuthenticated && !isLoggingIn) {
        return AppRoutes.login;
      }
      
      // 如果已认证且在登录页面，重定向到首页
      if (isAuthenticated && isLoggingIn) {
        return AppRoutes.home;
      }
      
      return null;
    },
    routes: [
      // 认证路由
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      
      // 主应用路由
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const TestApiPage(),
      ),
      
      GoRoute(
        path: AppRoutes.test,
        name: 'test',
        builder: (context, state) => const TestApiPage(),
      ),
    ],
  );
});