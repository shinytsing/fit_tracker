import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/bottom_navigation.dart';
import 'features/training/presentation/pages/training_page.dart';
import 'features/community/presentation/pages/community_page.dart';
import 'features/messages/presentation/pages/messages_page.dart';
import 'features/profile/presentation/pages/profile_page_fixed.dart';

/// 基于Figma设计重构的主应用
/// 完全按照Gymates Fitness Social App设计规范实现
void main() {
  runApp(
    const ProviderScope(
      child: FigmaRefactoredApp(),
    ),
  );
}

class FigmaRefactoredApp extends StatelessWidget {
  const FigmaRefactoredApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gymates Fitness Social App',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String _activeTab = 'training';
  bool _showFloatingMenu = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // 内容区域
            Expanded(
              child: _buildCurrentPage(),
            ),
            
            // 底部导航栏
            BottomNavigation(
              activeTab: _activeTab,
              onTabChange: (tab) {
                setState(() {
                  _activeTab = tab;
                });
              },
              onFloatingButtonClick: () {
                setState(() {
                  _showFloatingMenu = true;
                });
              },
            ),
          ],
        ),
      ),
      // 浮动操作菜单
      floatingActionButton: _showFloatingMenu
          ? _buildFloatingActionMenu()
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// 构建当前页面
  Widget _buildCurrentPage() {
    switch (_activeTab) {
      case 'training':
        return const TrainingPage();
      case 'community':
        return const CommunityPage();
      case 'messages':
        return const MessagesPage();
      case 'profile':
        return const ProfilePage();
      default:
        return const TrainingPage();
    }
  }

  /// 构建浮动操作菜单
  Widget _buildFloatingActionMenu() {
    return Container(
      margin: const EdgeInsets.only(bottom: 80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 菜单项
          _buildFloatingMenuItem(
            icon: Icons.fitness_center,
            label: '开始训练',
            onTap: () {
              setState(() {
                _showFloatingMenu = false;
                _activeTab = 'training';
              });
            },
          ),
          const SizedBox(height: 12),
          _buildFloatingMenuItem(
            icon: Icons.camera_alt,
            label: '拍照记录',
            onTap: () {
              setState(() {
                _showFloatingMenu = false;
              });
              _showSnackBar('拍照记录功能开发中...');
            },
          ),
          const SizedBox(height: 12),
          _buildFloatingMenuItem(
            icon: Icons.group_add,
            label: '邀请好友',
            onTap: () {
              setState(() {
                _showFloatingMenu = false;
              });
              _showSnackBar('邀请好友功能开发中...');
            },
          ),
          const SizedBox(height: 12),
          _buildFloatingMenuItem(
            icon: Icons.emoji_events,
            label: '创建挑战',
            onTap: () {
              setState(() {
                _showFloatingMenu = false;
                _activeTab = 'community';
              });
            },
          ),
          const SizedBox(height: 20),
          // 关闭按钮
          GestureDetector(
            onTap: () {
              setState(() {
                _showFloatingMenu = false;
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.close,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建浮动菜单项
  Widget _buildFloatingMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示提示信息
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
      ),
    );
  }
}
