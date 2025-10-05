import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../core/theme/app_theme.dart';
import '../widgets/figma/custom_button.dart';
import '../services/api_service.dart';

/// 基于Figma设计的个人页面
/// 实现用户信息、设置等功能
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final bool isIOS = Platform.isIOS;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _apiService.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isIOS ? const Color(0xFFF9FAFB) : AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 头部区域
              _buildHeader(),
              
              // 用户信息卡片
              _buildUserInfoCard(),
              
              // 统计数据
              _buildStatsSection(),
              
              // 功能菜单
              _buildMenuSection(),
              
              // 设置选项
              _buildSettingsSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建头部区域
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '我的',
                  style: TextStyle(
                    fontSize: isIOS ? 28 : 24,
                    fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '管理你的健身数据',
                  style: TextStyle(
                    fontSize: isIOS ? 16 : 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildHeaderButton(
                icon: Icons.settings_outlined,
                onTap: () => _showSettings(),
              ),
              const SizedBox(width: 12),
              _buildHeaderButton(
                icon: Icons.notifications_outlined,
                onTap: () => _showNotifications(),
                hasNotification: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建头部按钮
  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
    bool hasNotification = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                icon,
                color: const Color(0xFF6B7280),
                size: 20,
              ),
            ),
            if (hasNotification)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建用户信息卡片
  Widget _buildUserInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: isIOS ? 20 : 12,
            offset: Offset(0, isIOS ? 10 : 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Center(
                  child: Text(
                    '👤',
                    style: TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '健身达人',
                      style: TextStyle(
                        fontSize: isIOS ? 24 : 20,
                        fontWeight: isIOS ? FontWeight.w700 : FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '中级 • 25岁',
                      style: TextStyle(
                        fontSize: isIOS ? 16 : 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '连续训练7天',
                            style: TextStyle(
                              fontSize: isIOS ? 12 : 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '力量训练',
                            style: TextStyle(
                              fontSize: isIOS ? 12 : 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _editProfile(),
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建统计数据区域
  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            '健身统计',
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
                child: _buildStatItem('45', '总训练次数', Icons.fitness_center),
              ),
              Expanded(
                child: _buildStatItem('2.3k', '消耗卡路里', Icons.local_fire_department),
              ),
              Expanded(
                child: _buildStatItem('7', '连续天数', Icons.calendar_today),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('12', '搭子数量', Icons.people),
              ),
              Expanded(
                child: _buildStatItem('156', '获得点赞', Icons.favorite),
              ),
              Expanded(
                child: _buildStatItem('4.8', '平均评分', Icons.star),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF6366F1),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isIOS ? 20 : 18,
            fontWeight: isIOS ? FontWeight.w700 : FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isIOS ? 12 : 10,
            color: const Color(0xFF6B7280),
            fontWeight: isIOS ? FontWeight.w500 : FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 构建功能菜单区域
  Widget _buildMenuSection() {
    return Container(
      margin: const EdgeInsets.all(16),
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
            '我的功能',
            style: TextStyle(
              fontSize: isIOS ? 18 : 16,
              fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          _buildMenuGrid(),
        ],
      ),
    );
  }

  /// 构建菜单网格
  Widget _buildMenuGrid() {
    final menuItems = [
      {'icon': Icons.fitness_center, 'label': '我的训练', 'color': const Color(0xFF6366F1)},
      {'icon': Icons.people, 'label': '我的搭子', 'color': const Color(0xFF10B981)},
      {'icon': Icons.favorite, 'label': '我的收藏', 'color': const Color(0xFFEF4444)},
      {'icon': Icons.history, 'label': '训练历史', 'color': const Color(0xFFF59E0B)},
      {'icon': Icons.analytics, 'label': '数据分析', 'color': const Color(0xFF8B5CF6)},
      {'icon': Icons.card_giftcard, 'label': '我的成就', 'color': const Color(0xFFEC4899)},
      {'icon': Icons.shopping_bag, 'label': '健身商城', 'color': const Color(0xFF06B6D4)},
      {'icon': Icons.help_outline, 'label': '帮助中心', 'color': const Color(0xFF6B7280)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuItem(
          icon: item['icon'] as IconData,
          label: item['label'] as String,
          color: item['color'] as Color,
          onTap: () => _onMenuTap(item['label'] as String),
        );
      },
    );
  }

  /// 构建菜单项
  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
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
            style: TextStyle(
              fontSize: isIOS ? 12 : 10,
              color: const Color(0xFF1F2937),
              fontWeight: isIOS ? FontWeight.w500 : FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 构建设置区域
  Widget _buildSettingsSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
          _buildSettingItem(
            icon: Icons.person_outline,
            title: '个人资料',
            subtitle: '编辑个人信息',
            onTap: () => _editProfile(),
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.security_outlined,
            title: '隐私设置',
            subtitle: '管理隐私和安全',
            onTap: () => _showPrivacySettings(),
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.notifications_outlined,
            title: '通知设置',
            subtitle: '管理推送通知',
            onTap: () => _showNotificationSettings(),
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.language_outlined,
            title: '语言设置',
            subtitle: '简体中文',
            onTap: () => _showLanguageSettings(),
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.help_outline,
            title: '帮助与反馈',
            subtitle: '获取帮助或反馈问题',
            onTap: () => _showHelp(),
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.info_outline,
            title: '关于我们',
            subtitle: '版本 1.0.0',
            onTap: () => _showAbout(),
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.logout,
            title: '退出登录',
            subtitle: '',
            onTap: () => _logout(),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  /// 构建设置项
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDestructive 
              ? const Color(0xFFEF4444).withOpacity(0.1)
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: isDestructive 
              ? const Color(0xFFEF4444)
              : const Color(0xFF6B7280),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: isIOS ? 16 : 14,
          fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
          color: isDestructive 
              ? const Color(0xFFEF4444)
              : const Color(0xFF1F2937),
        ),
      ),
      subtitle: subtitle.isNotEmpty ? Text(
        subtitle,
        style: TextStyle(
          fontSize: isIOS ? 14 : 12,
          color: const Color(0xFF6B7280),
        ),
      ) : null,
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  /// 构建分割线
  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 72,
      color: Colors.grey[200],
    );
  }

  // 事件处理方法
  void _editProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EditProfileBottomSheet(),
    );
  }

  void _showSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('设置功能开发中')),
    );
  }

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('通知功能开发中')),
    );
  }

  void _onMenuTap(String menuName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$menuName功能开发中')),
    );
  }

  void _showPrivacySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('隐私设置功能开发中')),
    );
  }

  void _showNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('通知设置功能开发中')),
    );
  }

  void _showLanguageSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('语言设置功能开发中')),
    );
  }

  void _showHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('帮助功能开发中')),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        ),
        title: const Text('关于我们'),
        content: const Text('FitTracker v1.0.0\n\n一个专业的健身社交应用，帮助您找到健身伙伴，记录训练数据，实现健身目标。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        ),
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实现退出登录逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已退出登录')),
              );
            },
            child: const Text(
              '确定',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }
}

/// 编辑个人资料底部弹窗
class EditProfileBottomSheet extends StatefulWidget {
  const EditProfileBottomSheet({super.key});

  @override
  State<EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String _selectedGender = '男';
  String _selectedLevel = '中级';
  final List<String> _selectedTags = ['力量训练'];

  @override
  void initState() {
    super.initState();
    _nicknameController.text = '健身达人';
    _bioController.text = '热爱健身的普通人';
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isIOS ? 20 : 16),
          topRight: Radius.circular(isIOS ? 20 : 16),
        ),
      ),
      child: Column(
        children: [
          // 头部
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                const Spacer(),
                Text(
                  '编辑资料',
                  style: TextStyle(
                    fontSize: isIOS ? 18 : 16,
                    fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _saveProfile,
                  child: const Text(
                    '保存',
                    style: TextStyle(
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 头像
                  _buildAvatarSection(),
                  
                  const SizedBox(height: 24),
                  
                  // 基本信息
                  _buildBasicInfoSection(),
                  
                  const SizedBox(height: 24),
                  
                  // 健身信息
                  _buildFitnessInfoSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    final isIOS = Platform.isIOS;
    
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _changeAvatar,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: const Color(0xFF6366F1),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Text(
                  '👤',
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击更换头像',
            style: TextStyle(
              fontSize: isIOS ? 14 : 12,
              color: const Color(0xFF6366F1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    final isIOS = Platform.isIOS;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '基本信息',
          style: TextStyle(
            fontSize: isIOS ? 18 : 16,
            fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        
        // 昵称
        TextField(
          controller: _nicknameController,
          decoration: InputDecoration(
            labelText: '昵称',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 性别
        Row(
          children: [
            Expanded(
              child: Text(
                '性别',
                style: TextStyle(
                  fontSize: isIOS ? 16 : 14,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            DropdownButton<String>(
              value: _selectedGender,
              items: const [
                DropdownMenuItem(value: '男', child: Text('男')),
                DropdownMenuItem(value: '女', child: Text('女')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGender = value!;
                });
              },
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 个人简介
        TextField(
          controller: _bioController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: '个人简介',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFitnessInfoSection() {
    final isIOS = Platform.isIOS;
    final fitnessTags = ['力量训练', '有氧运动', '瑜伽', '游泳', '跑步', '骑行'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '健身信息',
          style: TextStyle(
            fontSize: isIOS ? 18 : 16,
            fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        
        // 健身水平
        Row(
          children: [
            Expanded(
              child: Text(
                '健身水平',
                style: TextStyle(
                  fontSize: isIOS ? 16 : 14,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            DropdownButton<String>(
              value: _selectedLevel,
              items: const [
                DropdownMenuItem(value: '初级', child: Text('初级')),
                DropdownMenuItem(value: '中级', child: Text('中级')),
                DropdownMenuItem(value: '高级', child: Text('高级')),
                DropdownMenuItem(value: '专业', child: Text('专业')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedLevel = value!;
                });
              },
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 兴趣标签
        Text(
          '兴趣标签',
          style: TextStyle(
            fontSize: isIOS ? 16 : 14,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: fitnessTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedTags.remove(tag);
                  } else {
                    _selectedTags.add(tag);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: isIOS ? 12 : 10,
                    color: isSelected 
                        ? Colors.white
                        : const Color(0xFF6B7280),
                    fontWeight: isIOS ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _changeAvatar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('更换头像功能开发中')),
    );
  }

  void _saveProfile() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('个人资料已保存')),
    );
  }
}