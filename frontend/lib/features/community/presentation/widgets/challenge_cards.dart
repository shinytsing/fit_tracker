import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/models.dart';
import '../providers/community_provider.dart';

class ChallengeCards extends ConsumerWidget {
  final String? filter;
  final List<Challenge>? challenges;
  final Function(String)? onJoinChallenge;
  final Function(String)? onViewChallenge;
  
  const ChallengeCards({
    super.key,
    this.filter,
    this.challenges,
    this.onJoinChallenge,
    this.onViewChallenge,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communityState = ref.watch(communityProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '热门挑战',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: 导航到挑战页面
                },
                child: const Text('查看全部'),
              ),
            ],
          ),
        ),
        if (communityState.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (communityState.challenges.isEmpty)
          _buildEmptyState(context)
        else
          _buildChallengeList(context, communityState.challenges.cast<Challenge>()),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无挑战',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '挑战正在加载中...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeList(BuildContext context, List<Challenge> challenges) {
    final filteredChallenges = _filterChallenges(challenges, filter);
    
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filteredChallenges.length,
        itemBuilder: (context, index) {
          final challenge = filteredChallenges[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildChallengeCard(context, challenge),
          );
        },
      ),
    );
  }

  List<Challenge> _filterChallenges(List<Challenge> challenges, String? filter) {
    if (filter == null) return challenges;
    
    switch (filter) {
      case 'active':
        return challenges.where((c) => c.isActive).toList();
      case 'popular':
        return challenges.where((c) => c.participantsCount > 100).toList();
      case 'new':
        final now = DateTime.now();
        return challenges.where((c) => 
            now.difference(c.createdAt).inDays < 7
        ).toList();
      default:
        return challenges;
    }
  }

  Widget _buildChallengeCard(BuildContext context, Challenge challenge) {
    final now = DateTime.now();
    final daysLeft = challenge.endDate.difference(now).inDays;
    final progress = _calculateProgress(challenge);
    
    return GestureDetector(
      onTap: () {
        _showChallengeDetail(context, challenge);
      },
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 挑战图片/图标区域
            _buildChallengeHeader(context, challenge),
            
            // 挑战信息
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    challenge.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  
                  // 挑战统计
                  Row(
                    children: [
                      _buildStatItem(
                        context,
                        Icons.people,
                        '${challenge.participantsCount}',
                        '参与',
                      ),
                      const SizedBox(width: 16),
                      _buildStatItem(
                        context,
                        Icons.timer,
                        daysLeft > 0 ? '${daysLeft}天' : '已结束',
                        '剩余',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // 进度条
                  if (challenge.isActive) ...[
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(progress * 100).toInt()}% 完成',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeHeader(BuildContext context, Challenge challenge) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      child: Stack(
        children: [
          // 背景图标
          Positioned(
            right: 16,
            top: 16,
            child: Icon(
              _getChallengeIcon(challenge.type),
              size: 40,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          
          // 难度标签
          Positioned(
            left: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getDifficultyText(challenge.difficulty),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // 活跃状态
          if (challenge.isActive)
            Positioned(
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '进行中',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  IconData _getChallengeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cardio':
        return Icons.directions_run;
      case 'strength':
        return Icons.fitness_center;
      case 'flexibility':
        return Icons.accessibility_new;
      case 'endurance':
        return Icons.timer;
      case 'weight_loss':
        return Icons.monitor_weight;
      default:
        return Icons.emoji_events;
    }
  }

  String _getDifficultyText(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return '简单';
      case 'medium':
        return '中等';
      case 'hard':
        return '困难';
      default:
        return difficulty;
    }
  }

  double _calculateProgress(Challenge challenge) {
    // 这里应该根据用户的实际进度计算
    // 暂时返回随机值作为示例
    return 0.3 + (challenge.participantsCount % 100) / 100.0;
  }

  void _showChallengeDetail(BuildContext context, Challenge challenge) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildChallengeDetailSheet(context, challenge),
    );
  }

  Widget _buildChallengeDetailSheet(BuildContext context, Challenge challenge) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(
                _getChallengeIcon(challenge.type),
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  challenge.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 描述
          Text(
            challenge.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          
          // 挑战信息
          _buildDetailRow(context, '类型', challenge.type),
          _buildDetailRow(context, '难度', _getDifficultyText(challenge.difficulty)),
          _buildDetailRow(context, '开始时间', _formatDate(challenge.startDate)),
          _buildDetailRow(context, '结束时间', _formatDate(challenge.endDate)),
          _buildDetailRow(context, '参与人数', '${challenge.participantsCount}'),
          const SizedBox(height: 24),
          
          // 操作按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: 参与挑战
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('成功参与挑战！')),
                    );
                  },
                  child: const Text('参与挑战'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
