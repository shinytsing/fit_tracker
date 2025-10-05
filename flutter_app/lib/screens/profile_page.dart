import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../core/theme/app_theme.dart';
import '../providers/providers.dart';

/// 基于Figma设计的现代化个人资料页面
/// 完全按照Gymates Fitness Social App设计规范实现
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final bool isIOS = Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    return Scaffold(
      backgroundColor: isIOS ? const Color(0xFFF9FAFB) : AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProfileCard(user),
                    const SizedBox(height: 24),
                    _buildStatsCard(),
                    const SizedBox(height: 24),
                    _buildSettingsList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建头部区域 - 基于Figma设计
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '我的',
            style: TextStyle(
              fontSize: isIOS ? 28 : 24,
              fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
          ),
          _buildHeaderButton(Icons.settings_rounded, _showSettings),
        ],
      ),
    );
  }

  /// 构建头部按钮
  Widget _buildHeaderButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: const Color(0xFF6B7280),
        ),
      ),
    );
  }

  /// 构建个人资料卡片 - 基于Figma设计
  Widget _buildProfileCard(user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isIOS ? 0.1 : 0.12),
            blurRadius: isIOS ? 20 : 4,
            offset: Offset(0, isIOS ? 10 : 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 头像和基本信息
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF6B7280),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? '健身达人',
                      style: TextStyle(
                        fontSize: isIOS ? 20 : 18,
                        fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'user@example.com',
                      style: TextStyle(
                        fontSize: isIOS ? 14 : 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '健身爱好者 • 已坚持30天',
                      style: TextStyle(
                        fontSize: isIOS ? 12 : 10,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 编辑资料按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _editProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
                ),
                elevation: 0,
              ),
              child: Text(
                '编辑资料',
                style: TextStyle(
                  fontSize: isIOS ? 14 : 12,
                  fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建统计卡片 - 基于Figma设计
  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isIOS ? 0.1 : 0.12),
            blurRadius: isIOS ? 20 : 4,
            offset: Offset(0, isIOS ? 10 : 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '我的数据',
            style: TextStyle(
              fontSize: isIOS ? 18 : 16,
              fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('训练次数', '156', Icons.fitness_center_rounded),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem('消耗卡路里', '12.3k', Icons.local_fire_department_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('训练时长', '45h', Icons.access_time_rounded),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem('连续天数', '30', Icons.calendar_today_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建统计项 - 基于Figma设计
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF6366F1),
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: isIOS ? 16 : 14,
              fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: isIOS ? 10 : 8,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建设置列表 - 基于Figma设计
  Widget _buildSettingsList() {
    final settingsItems = [
      {'icon': Icons.person_outline_rounded, 'title': '个人资料', 'subtitle': '编辑个人信息'},
      {'icon': Icons.notifications_outlined, 'title': '通知设置', 'subtitle': '管理通知偏好'},
      {'icon': Icons.privacy_tip_outlined, 'title': '隐私设置', 'subtitle': '控制数据隐私'},
      {'icon': Icons.help_outline_rounded, 'title': '帮助中心', 'subtitle': '常见问题解答'},
      {'icon': Icons.info_outline_rounded, 'title': '关于我们', 'subtitle': '版本信息和团队'},
      {'icon': Icons.logout_rounded, 'title': '退出登录', 'subtitle': '安全退出账户'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isIOS ? 0.1 : 0.12),
            blurRadius: isIOS ? 20 : 4,
            offset: Offset(0, isIOS ? 10 : 2),
          ),
        ],
      ),
      child: Column(
        children: settingsItems.map((item) {
          final isLast = item == settingsItems.last;
          return _buildSettingsItem(
            item['icon'] as IconData,
            item['title'] as String,
            item['subtitle'] as String,
            isLast,
          );
        }).toList(),
      ),
    );
  }

  /// 构建设置项 - 基于Figma设计
  Widget _buildSettingsItem(IconData icon, String title, String subtitle, bool isLast) {
    return InkWell(
      onTap: () => _handleSettingsTap(title),
      borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: isLast ? null : const Border(
            bottom: BorderSide(
              color: Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF6366F1),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isIOS ? 14 : 12,
                      fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isIOS ? 12 : 10,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: const Color(0xFF9CA3AF),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        ),
        title: const Text('编辑资料'),
        content: const Text('编辑资料功能开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        ),
        title: const Text('设置'),
        content: const Text('设置功能开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _handleSettingsTap(String title) {
    switch (title) {
      case '个人资料':
        _editProfile();
        break;
      case '通知设置':
      case '隐私设置':
      case '帮助中心':
      case '关于我们':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
            ),
            title: Text(title),
            content: Text('$title功能开发中，敬请期待！'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('确定'),
              ),
            ],
          ),
        );
        break;
      case '退出登录':
        _logout();
        break;
    }
  }

  void _logout() async {
    try {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.logout();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已安全退出'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('退出失败: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }
}