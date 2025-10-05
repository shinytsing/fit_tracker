import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../core/theme/app_theme.dart';

class AIPlanGenerator extends StatelessWidget {
  const AIPlanGenerator({super.key});

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      _SuggestionItem(
        title: '胸部训练',
        subtitle: '针对胸大肌发展',
        duration: '30分钟',
      ),
      _SuggestionItem(
        title: '有氧燃脂',
        subtitle: 'HIIT高强度训练',
        duration: '20分钟',
      ),
      _SuggestionItem(
        title: '腿部训练',
        subtitle: '下肢力量强化',
        duration: '40分钟',
      ),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和更多推荐按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    MdiIcons.star,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'AI训练推荐',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.foreground,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // TODO: 更多推荐逻辑
                },
                child: Text(
                  '更多推荐',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 推荐列表
          ...suggestions.map((item) => _buildSuggestionItem(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(_SuggestionItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.duration,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              MdiIcons.arrowRight,
              color: AppTheme.primaryColor,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionItem {
  final String title;
  final String subtitle;
  final String duration;

  _SuggestionItem({
    required this.title,
    required this.subtitle,
    required this.duration,
  });
}
