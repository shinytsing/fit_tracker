import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/stats_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _editProfile() {
    // Navigate to edit profile screen
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isIOS = themeProvider.themeType == ThemeType.ios;
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[200]!,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '我的',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            CustomIconButton(
                              icon: Icons.settings,
                              onPressed: () {},
                              isIOS: isIOS,
                            ),
                            const SizedBox(width: 12),
                            CustomIconButton(
                              icon: Icons.notifications_outlined,
                              onPressed: () {},
                              isIOS: isIOS,
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Profile Info
                    Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: user?.avatar != null
                                  ? CachedNetworkImageProvider(user!.avatar!)
                                  : null,
                              child: user?.avatar == null
                                  ? const Icon(Icons.person, size: 40)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? '健身爱好者',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '坚持就是胜利 💪',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text(
                                    '156 关注',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '1.2k 粉丝',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '89 动态',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Edit Profile Button
                    CustomButton(
                      text: '编辑资料',
                      onPressed: _editProfile,
                      isIOS: isIOS,
                      backgroundColor: ThemeProvider.primaryColor,
                      textColor: Colors.white,
                    ),
                  ],
                ),
              ),

              // Stats
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '运动数据',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '查看详情',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            value: '127',
                            label: '训练天数',
                            subtitle: '连续打卡',
                            icon: Icons.calendar_today,
                            color: Colors.blue,
                            isIOS: isIOS,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            value: '12.5k',
                            label: '消耗卡路里',
                            subtitle: '本月累计',
                            icon: Icons.trending_up,
                            color: Colors.green,
                            isIOS: isIOS,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            value: '8',
                            label: '获得徽章',
                            subtitle: '成就解锁',
                            icon: Icons.emoji_events,
                            color: Colors.amber,
                            isIOS: isIOS,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            value: '85%',
                            label: '目标完成',
                            subtitle: '本周进度',
                            icon: Icons.flag,
                            color: Colors.purple,
                            isIOS: isIOS,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

                    // Function Menu
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '功能菜单',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomCard(
                            isIOS: isIOS,
                            child: Column(
                              children: [
                                _buildSettingsItem(
                                  context,
                                  Icons.bar_chart,
                                  '训练数据',
                                  '查看详细训练记录',
                                  () {},
                                ),
                                _buildSettingsItem(
                                  context,
                                  Icons.person_outline,
                                  '个人资料',
                                  '编辑个人信息',
                                  () {},
                                ),
                                _buildSettingsItem(
                                  context,
                                  Icons.notifications_outlined,
                                  '通知设置',
                                  '管理推送通知',
                                  () {},
                                ),
                                _buildSettingsItem(
                                  context,
                                  Icons.privacy_tip_outlined,
                                  '隐私设置',
                                  '隐私和安全',
                                  () {},
                                ),
                                _buildSettingsItem(
                                  context,
                                  Icons.help_outline,
                                  '帮助中心',
                                  '常见问题',
                                  () {},
                                ),
                                _buildSettingsItem(
                                  context,
                                  Icons.info_outline,
                                  '关于我们',
                                  '版本信息',
                                  () {},
                                ),
                                _buildSettingsItem(
                                  context,
                                  Icons.logout,
                                  '退出登录',
                                  '安全退出',
                                  _logout,
                                  isDestructive: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFunctionItem(BuildContext context, IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        // Navigate to function
      },
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, IconData icon, String label, String description, VoidCallback onTap, {bool isDestructive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDestructive ? Colors.red : null,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
