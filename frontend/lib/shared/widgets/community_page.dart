import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../core/theme/app_theme.dart';
import 'community_feed_list.dart';
import 'community_challenge_cards.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String activeTab = 'following';

  final tabs = [
    _TabItem(id: 'following', label: '关注'),
    _TabItem(id: 'recommended', label: '推荐'),
    _TabItem(id: 'trending', label: '热门'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // 头部区域
            Container(
              color: AppTheme.card,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 标题和操作按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '社区',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.foreground,
                        ),
                      ),
                      Row(
                        children: [
                          _buildActionButton(MdiIcons.magnify),
                          const SizedBox(width: 12),
                          _buildActionButton(MdiIcons.filter),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 标签页
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.inputBackground,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: tabs.map((tab) {
                        final isActive = activeTab == tab.id;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                activeTab = tab.id;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isActive ? AppTheme.card : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                boxShadow: isActive ? AppTheme.cardShadow : null,
                              ),
                              child: Text(
                                tab.label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                                  color: isActive ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            
            // 内容区域
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 快速操作
                    _buildQuickActions(),
                    
                    const SizedBox(height: 24),
                    
                    // 挑战卡片
                    const CommunityChallengeCards(),
                    
                    const SizedBox(height: 24),
                    
                    // 最新动态
                    const CommunityFeedList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.inputBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        icon,
        color: AppTheme.textSecondaryColor,
        size: 20,
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(
        icon: MdiIcons.trendingUp,
        label: '挑战',
        color: const Color(0xFF3B82F6), // blue-500
      ),
      _QuickAction(
        icon: MdiIcons.accountSearch,
        label: '找搭子',
        color: const Color(0xFF10B981), // green-500
      ),
      _QuickAction(
        icon: MdiIcons.home,
        label: '健身房',
        color: const Color(0xFF8B5CF6), // purple-500
      ),
    ];

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppTheme.border),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: action.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    action.icon,
                    color: action.color,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  action.label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.foreground,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TabItem {
  final String id;
  final String label;

  _TabItem({required this.id, required this.label});
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
  });
}
