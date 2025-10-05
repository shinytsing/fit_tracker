import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../training/presentation/pages/training_page.dart';
import '../../../community/presentation/pages/community_page.dart';
import '../../../messages/presentation/pages/messages_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const TrainingPage(),
    const CommunityPage(),
    const MessagesPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.fitness_center, '训练'),
                _buildNavItem(1, Icons.people, '社区'),
                _buildFloatingActionButton(),
                _buildNavItem(2, Icons.message, '消息'),
                _buildNavItem(3, Icons.person, '我的'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF6366F1) : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? const Color(0xFF6366F1) : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建浮动操作按钮 - 完全按照 Figma 设计
  Widget _buildFloatingActionButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: FloatingActionButton(
        onPressed: _showPublishOptions,
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 24,
        ),
        elevation: 8,
        mini: false,
      ),
    );
  }

  void _showPublishOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 拖拽指示器
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // 标题
                const Text(
                  '发布内容',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),

                // 发布选项
                _buildPublishOption(
                  icon: Icons.fitness_center,
                  title: '发布训练',
                  subtitle: '分享你的训练计划和成果',
                  color: const Color(0xFF3B82F6),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToPublishTraining();
                  },
                ),

                const SizedBox(height: 12),

                _buildPublishOption(
                  icon: Icons.restaurant,
                  title: '发布饮食',
                  subtitle: '分享你的健康饮食记录',
                  color: const Color(0xFF10B981),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToPublishNutrition();
                  },
                ),

                const SizedBox(height: 12),

                _buildPublishOption(
                  icon: Icons.article,
                  title: '发布动态',
                  subtitle: '分享你的健身心得和感悟',
                  color: const Color(0xFF8B5CF6),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToPublishPost();
                  },
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPublishOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: color,
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPublishTraining() {
    // TODO: 导航到发布训练页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('发布训练功能开发中...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToPublishNutrition() {
    // TODO: 导航到发布饮食页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('发布饮食功能开发中...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToPublishPost() {
    // TODO: 导航到发布动态页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('发布动态功能开发中...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
