import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../core/theme/app_theme.dart';
import '../widgets/community/feed_list.dart';
import '../widgets/community/challenge_cards.dart';
import '../providers/providers.dart';

/// 基于Figma设计的现代化社区页面
/// 完全按照Gymates Fitness Social App设计规范实现
class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage> {
  String _activeTab = 'following';
  final bool isIOS = Platform.isIOS;

  @override
  Widget build(BuildContext context) {
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
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    const ChallengeCards(),
                    const SizedBox(height: 24),
                    _buildFeedSection(),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '社区',
                style: TextStyle(
                  fontSize: isIOS ? 28 : 24,
                  fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Row(
                children: [
                  _buildHeaderButton(Icons.search_rounded, _showSearchDialog),
                  const SizedBox(width: 12),
                  _buildHeaderButton(Icons.tune_rounded, _showFilterDialog),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTabs(),
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

  /// 构建标签页 - 基于Figma设计
  Widget _buildTabs() {
    final tabs = [
      {'id': 'following', 'label': '关注'},
      {'id': 'recommended', 'label': '推荐'},
      {'id': 'trending', 'label': '热门'},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isActive = _activeTab == tab['id'];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _activeTab = tab['id']!;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(isIOS ? 8 : 6),
                  boxShadow: isActive ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Text(
                  tab['label']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isIOS ? 14 : 12,
                    fontWeight: isActive 
                        ? (isIOS ? FontWeight.w600 : FontWeight.w500)
                        : (isIOS ? FontWeight.w500 : FontWeight.w400),
                    color: isActive 
                        ? const Color(0xFF6366F1) 
                        : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 构建快速操作 - 基于Figma设计
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.trending_up_rounded,
            label: '挑战',
            color: const Color(0xFF3B82F6),
            onTap: _showChallenges,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.search_rounded,
            label: '找搭子',
            color: const Color(0xFF10B981),
            onTap: _showBuddyFinder,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.fitness_center_rounded,
            label: '健身房',
            color: const Color(0xFF8B5CF6),
            onTap: _showGymFinder,
          ),
        ),
      ],
    );
  }

  /// 构建快速操作卡片 - 基于Figma设计
  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isIOS ? 16 : 12),
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isIOS ? 12 : 10,
                fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                color: const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建动态部分 - 基于Figma设计
  Widget _buildFeedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '最新动态',
          style: TextStyle(
            fontSize: isIOS ? 18 : 16,
            fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        const FeedList(),
      ],
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        ),
        title: const Text('搜索社区'),
        content: const Text('搜索功能开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        ),
        title: const Text('筛选动态'),
        content: const Text('筛选功能开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showChallenges() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        ),
        title: const Text('挑战'),
        content: const Text('挑战功能开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showBuddyFinder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        ),
        title: const Text('找搭子'),
        content: const Text('找搭子功能开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showGymFinder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        ),
        title: const Text('健身房'),
        content: const Text('健身房功能开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}