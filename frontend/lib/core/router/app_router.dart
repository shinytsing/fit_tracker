import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/main/presentation/pages/home_page.dart';
import '../../features/community/presentation/pages/gym_search_page.dart';
import '../../features/community/presentation/pages/gym_detail_page.dart';
import '../../features/community/presentation/pages/join_gym_buddy_page.dart';
import '../../features/auth/presentation/pages/auth_register_page.dart';
import '../../features/auth/presentation/pages/modern_login_page.dart';
import '../../features/auth/presentation/pages/phone_login_page.dart';
import '../../features/auth/presentation/pages/profile_setup_page.dart';
import '../../features/profile/presentation/pages/training_data_page.dart';
import '../../features/profile/presentation/pages/community_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../test_api_page.dart';
import '../auth/auth_provider.dart';
import '../models/models.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final isOnAuthPage = state.fullPath?.startsWith('/auth/') ?? false;
      final isOnSplashPage = state.fullPath == '/splash';
      
      // 如果正在加载，允许停留在当前页面
      if (isLoading) {
        return null;
      }
      
      // 如果已登录且在认证页面或启动页，重定向到首页
      if (isAuthenticated && (isOnAuthPage || isOnSplashPage)) {
        return '/';
      }
      
      // 如果未登录且不在认证页面和启动页，重定向到登录页
      if (!isAuthenticated && !isOnAuthPage && !isOnSplashPage) {
        return '/auth/login';
      }
      
      return null;
    },
    routes: [
      // 启动页
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      // 首页
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      // 健身房相关路由
      GoRoute(
        path: '/community/gym-search',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          final query = args?['query'] as String?;
          return GymSearchPage(initialQuery: query);
        },
      ),
      GoRoute(
        path: '/community/nearby-gyms',
        builder: (context, state) => const GymSearchPage(),
      ),
      GoRoute(
        path: '/community/top-rated-gyms',
        builder: (context, state) => const GymSearchPage(),
      ),
      GoRoute(
        path: '/community/popular-gyms',
        builder: (context, state) => const GymSearchPage(),
      ),
      GoRoute(
        path: '/community/gym-detail',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          final gymName = args?['name'] as String?;
          return GymDetailPage(gymName: gymName);
        },
      ),
      GoRoute(
        path: '/community/join-gym-buddy',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          final gymName = args?['name'] as String?;
          return JoinGymBuddyPage(gymName: gymName);
        },
      ),
      // 认证相关路由
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const ModernLoginPage(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const AuthRegisterPage(),
      ),
      GoRoute(
        path: '/auth/phone-login',
        builder: (context, state) => const PhoneLoginPage(),
      ),
      GoRoute(
        path: '/auth/profile-setup',
        builder: (context, state) => const ProfileSetupPage(),
      ),
      // 个人中心相关路由
      GoRoute(
        path: '/profile/training-data',
        builder: (context, state) => const TrainingDataPage(),
      ),
      GoRoute(
        path: '/profile/community',
        builder: (context, state) => const CommunityPage(),
      ),
      // API测试页面
      GoRoute(
        path: '/test-api',
        builder: (context, state) => const TestApiPage(),
      ),
    ],
  );
});