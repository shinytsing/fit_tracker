import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/models.dart';
import '../providers/training_provider.dart';

class AchievementGrid extends ConsumerWidget {
  final List<Achievement>? achievements;
  final Function(Achievement)? onAchievementTap;
  final Function(String)? onClaimReward;
  
  const AchievementGrid({
    super.key,
    this.achievements,
    this.onAchievementTap,
    this.onClaimReward,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingState = ref.watch(trainingProvider);
    final achievementsToShow = achievements ?? trainingState.achievements;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '成就',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: 导航到成就页面
                },
                child: const Text('查看全部'),
              ),
            ],
          ),
        ),
        if (trainingState.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (trainingState.achievements.isEmpty)
          _buildEmptyState(context)
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: trainingState.achievements.take(6).length,
            itemBuilder: (context, index) {
              final achievement = trainingState.achievements[index];
              return _buildAchievementItem(context, achievement);
            },
          ),
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
            '还没有获得成就',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '继续训练解锁更多成就！',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(BuildContext context, Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;
    final isCompleted = achievement.isCompleted;
    
    return GestureDetector(
      onTap: () {
        _showAchievementDetail(context, achievement);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked 
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isUnlocked 
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
            width: isUnlocked ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Icon(
                  _getAchievementIcon(achievement.type),
                  size: 32,
                  color: isUnlocked 
                      ? Theme.of(context).primaryColor
                      : Colors.grey[400],
                ),
                if (isCompleted)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              achievement.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isUnlocked 
                    ? Theme.of(context).primaryColor
                    : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (achievement.pointsReward != null && achievement.pointsReward! > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.stars,
                      size: 12,
                      color: Colors.amber[600],
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${achievement.pointsReward}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.amber[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getAchievementIcon(String? type) {
    switch (type) {
      case 'first_workout':
        return Icons.fitness_center;
      case 'streak':
        return Icons.local_fire_department;
      case 'calories':
        return Icons.whatshot;
      case 'duration':
        return Icons.timer;
      case 'weight':
        return Icons.monitor_weight;
      case 'cardio':
        return Icons.directions_run;
      case 'strength':
        return Icons.fitness_center;
      default:
        return Icons.emoji_events;
    }
  }

  void _showAchievementDetail(BuildContext context, Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getAchievementIcon(achievement.type),
              color: achievement.isUnlocked 
                  ? Theme.of(context).primaryColor
                  : Colors.grey[400],
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(achievement.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              achievement.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (achievement.progress != null) ...[
              const SizedBox(height: 16),
              Text(
                '进度',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: achievement.progress!.current / achievement.progress!.target,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${achievement.progress!.current}/${achievement.progress!.target}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (achievement.pointsReward != null && achievement.pointsReward! > 0) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.stars,
                    size: 16,
                    color: Colors.amber[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '奖励 ${achievement.pointsReward} 积分',
                    style: TextStyle(
                      color: Colors.amber[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
