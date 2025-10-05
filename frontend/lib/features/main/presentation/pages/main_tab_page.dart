import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../training/presentation/pages/training_page.dart';
import '../../../community/presentation/pages/community_page.dart';
import '../../../message/presentation/pages/message_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../publish/presentation/pages/publish_menu_page.dart';

class MainTabPage extends ConsumerStatefulWidget {
  const MainTabPage({super.key});

  @override
  ConsumerState<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends ConsumerState<MainTabPage> {
  int _currentIndex = 0;

  // 新的4个Tab页面结构 - 按照功能重排表
  final List<Widget> _pages = [
    const TrainingPage(),    // Tab1: 训练
    const CommunityPage(),   // Tab2: 社区
    const MessagePage(),     // Tab3: 消息
    const ProfilePage(),     // Tab4: 我的
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabItem(
                  icon: MdiIcons.dumbbell,
                  label: '训练',
                  index: 0,
                ),
                _buildTabItem(
                  icon: MdiIcons.accountGroup,
                  label: '社区',
                  index: 1,
                ),
                // 中间留空给FloatingActionButton
                const SizedBox(width: 60), // 为FAB预留空间
                _buildTabItem(
                  icon: MdiIcons.messageOutline,
                  label: '消息',
                  index: 2,
                ),
                _buildTabItem(
                  icon: MdiIcons.accountOutline,
                  label: '我的',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 构建中间加号按钮
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _showPublishMenu(context),
      backgroundColor: AppTheme.primaryColor,
      elevation: 8,
      child: Icon(
        Icons.add,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  // 显示发布菜单
  void _showPublishMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const PublishMenuPage(),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                ? AppTheme.primaryColor 
                : Theme.of(context).iconTheme.color?.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected 
                  ? AppTheme.primaryColor 
                  : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
