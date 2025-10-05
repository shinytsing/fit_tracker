import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/models.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../shared/widgets/custom_widgets.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';

/// 可交互的"我的"页面
/// 包含7个优化后的功能卡片，支持点击跳转和子页面展示
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    
    // 加载初始数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // 头部区域 - 完全按照 Figma 设计
            _buildHeader(),
            
            // 内容区域
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 用户信息头部
                    _buildProfileHeader(profileState),
                    
                    const SizedBox(height: 16),
                    
                    // PRO 升级横幅
                    _buildProBanner(),
                    
                    const SizedBox(height: 16),
                    
                    // 功能列表
                    _buildFunctionList(),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建头部区域 - 完全按照 Figma 设计
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '我的',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.inputBackground,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.settings,
              color: AppTheme.textSecondary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
      body: SingleChildScrollView(
        child: Column(
        children: [
            // 用户信息头部
            if (profileState.user != null)
              ProfileHeader(
                user: profileState.user!,
                onEditProfile: () => _navigateToEditProfile(),
                onViewFollowers: () => _showFeatureDialog(
                  title: '粉丝列表',
                  description: '查看关注我的用户',
                  features: ['粉丝列表', '粉丝互动', '关注管理'],
                ),
                onViewFollowing: () => _showFeatureDialog(
                  title: '关注列表',
                  description: '查看我关注的用户',
                  features: ['关注列表', '取消关注', '关注管理'],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // PRO 升级横幅
            _buildProBanner(),
            
            const SizedBox(height: 16),
            
            // 功能列表
            _buildFunctionList(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 构建用户信息头部 - 完全按照 Figma 设计
  Widget _buildProfileHeader(ProfileState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 用户头像和信息
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        color: Color(0xFF6366F1),
                        size: 40,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1),
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
                    const Text(
                      '健身爱好者',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '坚持就是胜利 💪',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 统计数据
                    Row(
                      children: [
                        _buildStatItem('156', '关注'),
                        const SizedBox(width: 24),
                        _buildStatItem('1.2k', '粉丝'),
                        const SizedBox(width: 24),
                        _buildStatItem('89', '动态'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 编辑资料按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _navigateToEditProfile(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '编辑资料',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  /// 构建 PRO 升级横幅
  Widget _buildProBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
  /// 构建 PRO 升级横幅 - 完全按照 Figma 设计
  Widget _buildProBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.star,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '升级到 PRO',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '解锁更多高级功能',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '升级',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建功能列表 - 完全按照 Figma 设计
  Widget _buildFunctionList() {
    final functionGroups = [
      {
        'title': '训练与数据',
        'items': [
          {'icon': Icons.fitness_center, 'title': '训练计划', 'subtitle': '管理你的训练计划'},
          {'icon': Icons.analytics, 'title': '数据统计', 'subtitle': '查看训练数据'},
          {'icon': Icons.trending_up, 'title': '目标管理', 'subtitle': '设置和跟踪目标'},
        ],
      },
      {
        'title': '社交与社区',
        'items': [
          {'icon': Icons.people, 'title': '我的关注', 'subtitle': '查看关注的人'},
          {'icon': Icons.group, 'title': '我的粉丝', 'subtitle': '查看粉丝列表'},
          {'icon': Icons.share, 'title': '我的动态', 'subtitle': '管理发布的动态'},
        ],
      },
      {
        'title': '成就与AI',
        'items': [
          {'icon': Icons.emoji_events, 'title': '我的成就', 'subtitle': '查看获得的成就'},
          {'icon': Icons.psychology, 'title': 'AI助手', 'subtitle': '智能健身建议'},
          {'icon': Icons.recommend, 'title': '个性化推荐', 'subtitle': '基于AI的推荐'},
        ],
      },
      {
        'title': '健身房服务',
        'items': [
          {'icon': Icons.location_on, 'title': '附近健身房', 'subtitle': '查找附近的健身房'},
          {'icon': Icons.group_add, 'title': '找搭子', 'subtitle': '寻找健身伙伴'},
          {'icon': Icons.schedule, 'title': '课程预约', 'subtitle': '预约健身课程'},
        ],
      },
      {
        'title': '消息与通知',
        'items': [
          {'icon': Icons.message, 'title': '消息中心', 'subtitle': '查看所有消息'},
          {'icon': Icons.notifications, 'title': '通知设置', 'subtitle': '管理通知偏好'},
        ],
      },
      {
        'title': '设置与帮助',
        'items': [
          {'icon': Icons.settings, 'title': '设置', 'subtitle': '应用设置'},
          {'icon': Icons.help, 'title': '帮助中心', 'subtitle': '获取帮助'},
          {'icon': Icons.info, 'title': '关于我们', 'subtitle': '了解应用信息'},
        ],
      },
      {
        'title': '其他',
        'items': [
          {'icon': Icons.logout, 'title': '退出登录', 'subtitle': '安全退出账户', 'isDestructive': true},
        ],
      },
    ];

    return Column(
      children: functionGroups.map((group) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                group['title'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: (group['items'] as List).asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isLast = index == (group['items'] as List).length - 1;
                  
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isLast ? Colors.transparent : const Color(0xFFE5E7EB),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (item['isDestructive'] as bool? ?? false)
                              ? const Color(0xFFEF4444).withOpacity(0.1)
                              : const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: (item['isDestructive'] as bool? ?? false)
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF6366F1),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        item['title'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: (item['isDestructive'] as bool? ?? false)
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF1F2937),
                        ),
                      ),
                      subtitle: Text(
                        item['subtitle'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF9CA3AF),
                        size: 20,
                      ),
                      onTap: () => _handleFunctionTap(item['title'] as String),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  /// 处理功能点击
  void _handleFunctionTap(String title) {
    // TODO: 实现各个功能的导航
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title 功能开发中...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 导航到编辑资料页面
  void _navigateToEditProfile() {
    // TODO: 实现编辑资料页面导航
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('编辑资料功能开发中...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  }
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.star,
            color: Colors.yellow,
            size: 24,
          ),
          const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text(
                  'Gymates PRO',
                      style: TextStyle(
                    fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                const SizedBox(height: 4),
                const Text(
                  '升级为 Gymates PRO',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  ' 享受更多专业功能',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                ),
              ),
            ],
          ),
          ),
          TextButton(
            onPressed: () => _navigateToProUpgrade(),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              '升级',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            ),
          ],
        ),
    );
  }

  /// 构建功能列表
  Widget _buildFunctionList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
          // 训练与数据
          _buildFunctionCard(
            icon: Icons.fitness_center,
            iconColor: Colors.blue,
            title: '训练与数据',
            subtitle: '训练计划、数据统计、身体指标',
            onTap: () => _navigateToTrainingData(),
          ),
          
          _buildDivider(),
          
          // 社交与社区
          _buildFunctionCard(
            icon: Icons.people,
            iconColor: Colors.orange,
            title: '社交与社区',
            subtitle: '好友动态、寻找健身伙伴',
            onTap: () => _navigateToSocialCommunity(),
          ),
          
          _buildDivider(),
          
          // 成就与助手
          _buildFunctionCard(
            icon: Icons.emoji_events,
            iconColor: Colors.amber,
            title: '成就与助手',
            subtitle: '个人成就、AI智能建议',
            onTap: () => _navigateToAchievementAI(),
          ),
          
          _buildDivider(),
          
          // 健身房服务
          _buildFunctionCard(
            icon: Icons.location_on,
            iconColor: Colors.red,
            title: '健身房服务',
            subtitle: '附近健身房及入驻信息',
            onTap: () => _navigateToGyms(),
          ),
          
          _buildDivider(),
          
          // 消息与通知
          _buildFunctionCard(
            icon: Icons.message,
            iconColor: Colors.teal,
            title: '消息与通知',
            subtitle: '系统通知与私信集中管理',
            onTap: () => _navigateToMessages(),
          ),
          
          _buildDivider(),
          
          // 设置与帮助
          _buildFunctionCard(
            icon: Icons.settings,
            iconColor: Colors.grey,
            title: '设置与帮助',
            subtitle: '账号设置、隐私、使用帮助',
            onTap: () => _navigateToSettingsHelp(),
          ),
          
          _buildDivider(),
          
          // 关于与分享
          _buildFunctionCard(
            icon: Icons.info_outline,
            iconColor: Colors.blue,
            title: '关于与分享',
            subtitle: '应用信息、推荐给朋友',
            onTap: () => _navigateToAboutShare(),
          ),
          
          _buildDivider(),
          
          // 注销
          _buildFunctionCard(
            icon: Icons.logout,
            iconColor: Colors.red,
            title: '注销',
            subtitle: '退出当前账户',
            onTap: () => _showLogoutDialog(),
            showTrailing: false,
          ),
              ],
            ),
    );
  }

  /// 构建功能卡片
  Widget _buildFunctionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showTrailing = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
      children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                    title,
                          style: const TextStyle(
                      fontSize: 16,
                            fontWeight: FontWeight.w600,
                      color: Colors.black87,
                          ),
                        ),
                  const SizedBox(height: 4),
                        Text(
                    subtitle,
                          style: TextStyle(
                      fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
            if (showTrailing)
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

  /// 构建分割线
  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: Colors.grey[200],
    );
  }

  // 导航方法
  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit_profile':
        _navigateToEditProfile();
        break;
      case 'share_profile':
        _shareProfile();
        break;
      case 'privacy_settings':
        _navigateToPrivacySettings();
        break;
    }
  }

  void _navigateToTrainingData() {
    context.push('/profile/training-data');
  }

  void _navigateToSocialCommunity() {
    context.push('/profile/community');
  }

  void _navigateToAchievementAI() {
    _showSubPageDialog(
      title: '成就与助手',
      items: [
        _SubPageItem(
          icon: Icons.emoji_events,
          iconColor: Colors.amber,
          title: '成就系统',
          subtitle: '查看获得的成就和奖励',
          onTap: () => _navigateToAchievements(),
        ),
        _SubPageItem(
          icon: Icons.smart_toy,
          iconColor: Colors.cyan,
          title: 'AI 助手',
          subtitle: '智能训练建议和分析',
          onTap: () => _navigateToAI(),
        ),
      ],
    );
  }

  void _navigateToGyms() {
    _showFeatureDialog(
      title: '健身房服务',
      description: '查找附近的健身房，查看入驻信息',
      features: [
        '附近健身房搜索',
        '健身房详情查看',
        '预约和评价功能',
        '健身房入驻申请',
      ],
    );
  }

  void _navigateToMessages() {
    _showFeatureDialog(
      title: '消息与通知',
      description: '系统通知与私信集中管理',
      features: [
        '系统消息通知',
        '好友私信聊天',
        '训练提醒推送',
        '社区互动通知',
      ],
    );
  }

  void _navigateToSettingsHelp() {
    _showSubPageDialog(
      title: '设置与帮助',
      items: [
        _SubPageItem(
          icon: Icons.settings,
          iconColor: Colors.grey,
          title: '应用设置',
          subtitle: '账号、隐私、通知等所有设置',
          onTap: () => _navigateToAppSettings(),
        ),
        _SubPageItem(
          icon: Icons.help,
          iconColor: Colors.purple,
          title: '帮助与反馈',
          subtitle: '使用帮助和问题反馈',
          onTap: () => _navigateToHelp(),
          ),
      ],
    );
  }

  void _navigateToAboutShare() {
    _showSubPageDialog(
      title: '关于与分享',
      items: [
        _SubPageItem(
          icon: Icons.info_outline,
          iconColor: Colors.blue,
          title: '关于 Gymates',
          subtitle: '版本信息和团队介绍',
          onTap: () => _navigateToAbout(),
        ),
        _SubPageItem(
          icon: Icons.share,
          iconColor: Colors.blue,
          title: '分享 Gymates',
          subtitle: '推荐给朋友使用',
          onTap: () => _shareProfile(),
        ),
      ],
    );
  }

  void _navigateToProUpgrade() {
    _showFeatureDialog(
      title: 'Gymates PRO',
      description: '解锁更多专业功能',
      features: [
        '无限训练计划创建',
        '高级数据分析和图表',
        '专属AI训练建议',
        '优先客服支持',
        '无广告体验',
        '专属徽章和成就',
      ],
    );
  }

  void _navigateToEditProfile() {
    _showFeatureDialog(
      title: '编辑资料',
      description: '修改个人信息和头像',
      features: [
        '修改昵称和签名',
        '更换头像',
        '设置健身目标',
        '完善个人信息',
      ],
    );
  }

  void _navigateToTrainingPlans() {
    _showFeatureDialog(
      title: '训练计划',
      description: '管理个人训练计划',
      features: [
        '创建自定义训练计划',
        '查看训练历史',
        '设置训练提醒',
        '分享训练计划',
      ],
    );
  }

  void _navigateToDataStats() {
    _showFeatureDialog(
      title: '数据统计',
      description: '查看训练数据和图表',
      features: [
        '训练时长统计',
        '卡路里消耗图表',
        '体重变化趋势',
        '运动类型分析',
      ],
    );
  }

  void _navigateToBodyMetrics() {
    _showFeatureDialog(
      title: '身体指标',
      description: '记录身体数据变化',
      features: [
        '体重记录',
        '体脂率测量',
        '肌肉量统计',
        'BMI计算',
      ],
    );
  }

  void _navigateToCommunity() {
    _showFeatureDialog(
      title: '社区动态',
      description: '查看好友和社区动态',
      features: [
        '关注好友动态',
        '发布训练分享',
        '点赞和评论',
        '发现热门内容',
      ],
    );
  }

  void _navigateToBuddies() {
    _showFeatureDialog(
      title: '健身伙伴',
      description: '寻找健身伙伴和组队',
      features: [
        '附近健身伙伴',
        '创建训练小组',
        '约练功能',
        '伙伴推荐',
      ],
    );
  }

  void _navigateToAchievements() {
    _showFeatureDialog(
      title: '成就系统',
      description: '查看获得的成就和奖励',
      features: [
        '训练成就徽章',
        '连续打卡奖励',
        '里程碑达成',
        '成就分享',
      ],
    );
  }

  void _navigateToAI() {
    _showFeatureDialog(
      title: 'AI 助手',
      description: '智能训练建议和分析',
      features: [
        '个性化训练建议',
        '动作识别指导',
        '训练强度分析',
        '智能营养建议',
      ],
    );
  }

  void _navigateToAppSettings() {
    _showFeatureDialog(
      title: '应用设置',
      description: '账号、隐私、通知等所有设置',
      features: [
        '账号安全设置',
        '隐私权限管理',
        '通知推送设置',
        '主题和语言',
      ],
    );
  }

  void _navigateToHelp() {
    _showFeatureDialog(
      title: '帮助与反馈',
      description: '使用帮助和问题反馈',
      features: [
        '常见问题解答',
        '使用教程',
        '问题反馈',
        '联系客服',
      ],
    );
  }

  void _navigateToAbout() {
    _showFeatureDialog(
      title: '关于 Gymates',
      description: '版本信息和团队介绍',
      features: [
        '版本: 1.0.0',
        '开发团队介绍',
        '用户协议',
        '隐私政策',
      ],
    );
  }

  void _navigateToPrivacySettings() {
    _showFeatureDialog(
      title: '隐私设置',
      description: '管理个人隐私和安全',
      features: [
        '个人信息可见性',
        '位置信息权限',
        '数据使用授权',
        '账号安全',
      ],
    );
  }

  void _shareProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('分享 Gymates 功能开发中'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToLogin() {
    context.push('/auth/login');
  }

  void _navigateToRegister() {
    context.push('/auth/register');
  }

  /// 显示注销确认对话框
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认注销'),
        content: const Text('确定要退出当前账户吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleLogout();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 处理注销
  void _handleLogout() async {
    try {
      await ref.read(authProvider.notifier).logout();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已成功注销'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // 跳转到登录页面
        context.go('/auth/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('注销失败: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 显示子页面对话框
  void _showSubPageDialog({
    required String title,
    required List<_SubPageItem> items,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
      decoration: BoxDecoration(
                    color: item.iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.iconColor,
                    size: 20,
                  ),
                ),
                title: Text(item.title),
                subtitle: Text(item.subtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).pop();
                  item.onTap();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  /// 显示功能详情对话框
  void _showFeatureDialog({
    required String title,
    required String description,
    required List<String> features,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
              const Text(
              '功能特点:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
          Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

/// 子页面项数据模型
class _SubPageItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _SubPageItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}