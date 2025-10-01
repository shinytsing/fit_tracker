import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';
import '../../core/providers/community_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/custom_widgets.dart';

/// 热门话题组件
class HotTopicsWidget extends ConsumerWidget {
  const HotTopicsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communityState = ref.watch(communityNotifierProvider);
    final communityNotifier = ref.read(communityNotifierProvider.notifier);

    // 加载热门话题
    ref.listen(communityNotifierProvider, (previous, next) {
      if (next.hotTopics.isEmpty && !next.isLoading) {
        communityNotifier.loadHotTopics();
      }
    });

    if (communityState.hotTopics.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '热门话题',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: 跳转到话题页面
                },
                child: const Text('查看更多'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: communityState.hotTopics.map((topic) => _buildTopicChip(context, topic)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicChip(BuildContext context, Topic topic) {
    return InkWell(
      onTap: () {
        // TODO: 跳转到话题详情页
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getTopicColor(topic.color).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getTopicColor(topic.color).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (topic.icon != null) ...[
              Icon(
                _getTopicIcon(topic.icon!),
                size: 16,
                color: _getTopicColor(topic.color),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              '#${topic.name}',
              style: TextStyle(
                color: _getTopicColor(topic.color),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (topic.postsCount > 0) ...[
              const SizedBox(width: 4),
              Text(
                '${topic.postsCount}',
                style: TextStyle(
                  color: _getTopicColor(topic.color).withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getTopicColor(String? color) {
    if (color == null) return AppTheme.primaryColor;
    
    switch (color) {
      case '#FF6B35':
        return const Color(0xFFFF6B35);
      case '#4CAF50':
        return const Color(0xFF4CAF50);
      case '#FF9800':
        return const Color(0xFFFF9800);
      case '#2196F3':
        return const Color(0xFF2196F3);
      case '#9C27B0':
        return const Color(0xFF9C27B0);
      case '#E91E63':
        return const Color(0xFFE91E63);
      case '#795548':
        return const Color(0xFF795548);
      case '#607D8B':
        return const Color(0xFF607D8B);
      case '#00BCD4':
        return const Color(0xFF00BCD4);
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getTopicIcon(String icon) {
    switch (icon) {
      case 'fitness_center':
        return Icons.fitness_center;
      case 'trending_down':
        return Icons.trending_down;
      case 'trending_up':
        return Icons.trending_up;
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_run':
        return Icons.directions_run;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'pool':
        return Icons.pool;
      case 'directions_bike':
        return Icons.directions_bike;
      case 'tag':
        return Icons.tag;
      default:
        return Icons.tag;
    }
  }
}

/// 话题选择器组件
class TopicSelector extends StatefulWidget {
  final List<String> selectedTopics;
  final Function(List<String>) onTopicsChanged;

  const TopicSelector({
    super.key,
    required this.selectedTopics,
    required this.onTopicsChanged,
  });

  @override
  State<TopicSelector> createState() => _TopicSelectorState();
}

class _TopicSelectorState extends State<TopicSelector> {
  final List<String> _availableTopics = [
    '健身打卡',
    '减脂日记',
    '增肌计划',
    '健康饮食',
    '晨跑',
    '瑜伽',
    '力量训练',
    '马拉松',
    '游泳',
    '骑行',
    'HIIT',
    '普拉提',
    '拳击',
    '舞蹈',
    '登山',
    '篮球',
    '足球',
    '网球',
    '羽毛球',
    '乒乓球',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择话题标签',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTopics.map((topic) => _buildTopicChip(topic)).toList(),
        ),
        if (widget.selectedTopics.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            '已选择的话题：',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.selectedTopics.map((topic) => _buildSelectedTopicChip(topic)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTopicChip(String topic) {
    final isSelected = widget.selectedTopics.contains(topic);
    
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            widget.selectedTopics.remove(topic);
          } else {
            if (widget.selectedTopics.length < 5) { // 最多选择5个话题
              widget.selectedTopics.add(topic);
            }
          }
        });
        widget.onTopicsChanged(widget.selectedTopics);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primaryColor 
              : AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppTheme.primaryColor 
                : AppTheme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          '#$topic',
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.primaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTopicChip(String topic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '#$topic',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              setState(() {
                widget.selectedTopics.remove(topic);
              });
              widget.onTopicsChanged(widget.selectedTopics);
            },
            child: const Icon(
              Icons.close,
              size: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
