import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../training/presentation/pages/training_page.dart';
import '../../../community/presentation/pages/community_page.dart';
import '../../../message/presentation/pages/message_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../post/presentation/pages/create_post_page.dart';

class MainTabPage extends ConsumerStatefulWidget {
  const MainTabPage({super.key});

  @override
  ConsumerState<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends ConsumerState<MainTabPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TrainingPage(),
    const CommunityPage(),
    const SizedBox.shrink(), // 加号按钮占位
    const MessagePage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
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
                _buildAddButton(),
                _buildTabItem(
                  icon: MdiIcons.messageOutline,
                  label: '消息',
                  index: 3,
                ),
                _buildTabItem(
                  icon: MdiIcons.accountOutline,
                  label: '我',
                  index: 4,
                ),
              ],
            ),
          ),
        ),
      ),
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

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _onAddButtonTapped,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          MdiIcons.plus,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    if (index == 2) return; // 加号按钮不切换tab
    
    setState(() {
      _currentIndex = index;
    });
  }

  void _onAddButtonTapped() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreatePostPage(),
      ),
    );
  }
}
