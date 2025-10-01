import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/models.dart';
import '../providers/community_provider.dart';

class TopicTags extends ConsumerWidget {
  final List<Topic>? topics;
  final String? selectedTopicId;
  final Function(String)? onTopicSelected;
  final Function(String)? onTopicTap;
  
  const TopicTags({
    super.key,
    this.topics,
    this.selectedTopicId,
    this.onTopicSelected,
    this.onTopicTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsToShow = topics ?? ref.watch(communityProvider).topics;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '热门话题',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: 导航到话题页面
                },
                child: const Text('更多'),
              ),
            ],
          ),
        ),
        if (topicsToShow.isEmpty)
          _buildEmptyState(context)
        else
          _buildTopicList(context, topicsToShow),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Icon(
            Icons.tag_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无话题',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '话题正在加载中...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicList(BuildContext context, List<Topic> topics) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          final isSelected = topic.id == selectedTopicId;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: _buildTopicChip(context, topic, isSelected),
          );
        },
      ),
    );
  }

  Widget _buildTopicChip(BuildContext context, Topic topic, bool isSelected) {
    return GestureDetector(
      onTap: () {
        onTopicTap?.call(topic.id);
        onTopicSelected?.call(topic.id);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (topic.isHot)
                  Icon(
                    Icons.local_fire_department,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.orange,
                  ),
                if (topic.isHot) const SizedBox(width: 4),
                Text(
                  '#${topic.name}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility,
                  size: 12,
                  color: isSelected ? Colors.white70 : Colors.grey[600],
                ),
                const SizedBox(width: 2),
                Text(
                  '${topic.postsCount}',
                  style: TextStyle(
                    color: isSelected ? Colors.white70 : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.people,
                  size: 12,
                  color: isSelected ? Colors.white70 : Colors.grey[600],
                ),
                const SizedBox(width: 2),
                Text(
                  '${topic.followersCount}',
                  style: TextStyle(
                    color: isSelected ? Colors.white70 : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
