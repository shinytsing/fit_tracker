/// 个人资料页面
/// 用户个人信息和设置界面

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_widgets.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../core/router/app_router.dart';

/// 个人资料页面
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人资料'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 实现设置功能
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 用户信息卡片
            CustomCard(
              child: Column(
                children: [
                  CustomAvatar(
                    initials: user?.name.substring(0, 1) ?? 'U',
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? '用户',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'user@example.com',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('训练天数', '12', '天'),
                      _buildStatItem('完成挑战', '3', '个'),
                      _buildStatItem('获得成就', '8', '个'),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 功能菜单
            CustomCard(
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    '编辑资料',
                    Icons.edit,
                    () {
                      // TODO: 实现编辑资料功能
                    },
                  ),
                  const Divider(),
                  _buildMenuItem(
                    context,
                    '训练记录',
                    Icons.fitness_center,
                    () {
                      // TODO: 实现训练记录功能
                    },
                  ),
                  const Divider(),
                  _buildMenuItem(
                    context,
                    '饮食记录',
                    Icons.restaurant,
                    () {
                      // TODO: 实现饮食记录功能
                    },
                  ),
                  const Divider(),
                  _buildMenuItem(
                    context,
                    '健康数据',
                    Icons.analytics,
                    () {
                      // TODO: 实现健康数据功能
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 设置菜单
            CustomCard(
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    '通知设置',
                    Icons.notifications,
                    () {
                      // TODO: 实现通知设置功能
                    },
                  ),
                  const Divider(),
                  _buildMenuItem(
                    context,
                    '隐私设置',
                    Icons.privacy_tip,
                    () {
                      // TODO: 实现隐私设置功能
                    },
                  ),
                  const Divider(),
                  _buildMenuItem(
                    context,
                    '帮助与反馈',
                    Icons.help,
                    () {
                      // TODO: 实现帮助与反馈功能
                    },
                  ),
                  const Divider(),
                  _buildMenuItem(
                    context,
                    '关于我们',
                    Icons.info,
                    () {
                      // TODO: 实现关于我们功能
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 登出按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: authState.isLoading ? null : () => _handleLogout(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                  foregroundColor: Colors.white,
                ),
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('登出'),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(
          '$label ($unit)',
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondaryColor),
      onTap: onTap,
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认登出'),
        content: const Text('您确定要登出吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
      
      if (context.mounted) {
        context.go(AppRoutes.login);
      }
    }
  }
}