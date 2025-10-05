import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../core/theme/app_theme.dart';

/// 基于Figma设计的搭子页面
/// 完全按照Gymates Fitness Social App设计规范实现
class MatesPage extends ConsumerStatefulWidget {
  const MatesPage({super.key});

  @override
  ConsumerState<MatesPage> createState() => _MatesPageState();
}

class _MatesPageState extends ConsumerState<MatesPage> {
  final bool isIOS = Platform.isIOS;
  String _selectedTab = '推荐';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isIOS ? const Color(0xFFF9FAFB) : AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '健身搭子',
            style: TextStyle(
              fontSize: isIOS ? 28 : 24,
              fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
          ),
          Row(
            children: [
              _buildHeaderButton(Icons.search, _showSearch),
              const SizedBox(width: 12),
              _buildHeaderButton(Icons.filter_list, _showFilter),
            ],
          ),
        ],
      ),
    );
  }

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

  Widget _buildTabs() {
    final tabs = ['推荐', '附近', '同好'];
    
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _selectedTab == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = tab;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isIOS ? 16 : 14,
                    fontWeight: isSelected 
                        ? (isIOS ? FontWeight.w600 : FontWeight.w500)
                        : FontWeight.w400,
                    color: isSelected 
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

  Widget _buildContent() {
    switch (_selectedTab) {
      case '推荐':
        return _buildRecommendContent();
      case '附近':
        return _buildNearbyContent();
      case '同好':
        return _buildSimilarContent();
      default:
        return _buildRecommendContent();
    }
  }

  Widget _buildRecommendContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildMatesList(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
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
            '快速找搭子',
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
                child: _buildQuickActionCard(
                  '健身房找搭子',
                  Icons.fitness_center,
                  const Color(0xFF6366F1),
                  _showGymFinder,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  '户外运动',
                  Icons.park,
                  const Color(0xFF10B981),
                  _showOutdoorFinder,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  '瑜伽搭子',
                  Icons.self_improvement,
                  const Color(0xFFF59E0B),
                  _showYogaFinder,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  '跑步伙伴',
                  Icons.directions_run,
                  const Color(0xFFEF4444),
                  _showRunningFinder,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: isIOS ? 12 : 10,
                fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                color: const Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatesList() {
    final mates = [
      {
        'name': '健身达人小李',
        'age': 25,
        'distance': '1.2km',
        'level': '中级',
        'interests': ['力量训练', '跑步'],
        'avatar': '👨‍💼',
        'online': true,
      },
      {
        'name': '瑜伽小仙女',
        'age': 23,
        'distance': '0.8km',
        'level': '高级',
        'interests': ['瑜伽', '普拉提'],
        'avatar': '👩‍🦰',
        'online': true,
      },
      {
        'name': '跑步爱好者',
        'age': 28,
        'distance': '2.1km',
        'level': '中级',
        'interests': ['跑步', '骑行'],
        'avatar': '👨‍🏃',
        'online': false,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '推荐搭子',
          style: TextStyle(
            fontSize: isIOS ? 18 : 16,
            fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        ...mates.map((mate) => _buildMateCard(mate)).toList(),
      ],
    );
  }

  Widget _buildMateCard(Map<String, dynamic> mate) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    mate['avatar'],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              if (mate['online'])
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
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
                Row(
                  children: [
                    Text(
                      mate['name'],
                      style: TextStyle(
                        fontSize: isIOS ? 16 : 14,
                        fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        mate['level'],
                        style: TextStyle(
                          fontSize: isIOS ? 10 : 8,
                          color: const Color(0xFF6366F1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${mate['age']}岁 • ${mate['distance']}',
                  style: TextStyle(
                    fontSize: isIOS ? 12 : 10,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: (mate['interests'] as List<String>).map((interest) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        interest,
                        style: TextStyle(
                          fontSize: isIOS ? 10 : 8,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () => _sendMessage(mate['name']),
                icon: const Icon(
                  Icons.message,
                  color: Color(0xFF6366F1),
                ),
              ),
              IconButton(
                onPressed: () => _addFriend(mate['name']),
                icon: const Icon(
                  Icons.person_add,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyContent() {
    return const Center(
      child: Text('附近搭子功能开发中...'),
    );
  }

  Widget _buildSimilarContent() {
    return const Center(
      child: Text('同好搭子功能开发中...'),
    );
  }

  void _showSearch() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        ),
        title: const Text('搜索搭子'),
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

  void _showFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        ),
        title: const Text('筛选条件'),
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

  void _showGymFinder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        ),
        title: const Text('健身房找搭子'),
        content: const Text('健身房搭子功能开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showOutdoorFinder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        ),
        title: const Text('户外运动'),
        content: const Text('户外运动搭子功能开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showYogaFinder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        ),
        title: const Text('瑜伽搭子'),
        content: const Text('瑜伽搭子功能开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showRunningFinder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        ),
        title: const Text('跑步伙伴'),
        content: const Text('跑步伙伴功能开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('给$name发送消息功能开发中'),
        backgroundColor: const Color(0xFF6366F1),
      ),
    );
  }

  void _addFriend(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('添加$name为好友功能开发中'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }
}
