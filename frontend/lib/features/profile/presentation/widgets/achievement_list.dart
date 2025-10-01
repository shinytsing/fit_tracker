import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';

/// 成就列表组件
/// 显示用户的所有成就，包括已完成和未完成的
class AchievementList extends StatelessWidget {
  final List<Achievement> achievements;
  final Function(Achievement) onAchievementTap;
  final Function(String) onClaimReward;

  const AchievementList({
    super.key,
    required this.achievements,
    required this.onAchievementTap,
    required this.onClaimReward,
  });

  @override
  Widget build(BuildContext context) {
    // 分离已完成和未完成的成就
    final completedAchievements = achievements.where((a) => a.isCompleted).toList();
    final incompleteAchievements = achievements.where((a) => !a.isCompleted).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 已完成成就
        if (completedAchievements.isNotEmpty) ...[
          _buildSectionHeader('已完成成就', completedAchievements.length),
          const SizedBox(height: 12),
          ...completedAchievements.map((achievement) {
            return _buildAchievementCard(achievement, true);
          }).toList(),
          const SizedBox(height: 24),
        ],
        
        // 未完成成就
        if (incompleteAchievements.isNotEmpty) ...[
          _buildSectionHeader('进行中成就', incompleteAchievements.length),
          const SizedBox(height: 12),
          ...incompleteAchievements.map((achievement) {
            return _buildAchievementCard(achievement, false);
          }).toList(),
        ],
        
        // 空状态
        if (achievements.isEmpty)
          _buildEmptyState(),
      ],
    );
  }

  /// 构建章节标题
  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建成就卡片
  Widget _buildAchievementCard(Achievement achievement, bool isCompleted) {
    return GestureDetector(
      onTap: () => onAchievementTap(achievement),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: isCompleted 
              ? Border.all(color: Colors.green.withOpacity(0.3), width: 2)
              : null,
        ),
        child: Row(
          children: [
            // 成就图标
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isCompleted 
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getAchievementIcon(achievement.type ?? 'general'),
                color: isCompleted 
                    ? Colors.green
                    : Colors.grey[400],
                size: 30,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // 成就信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child:                           Text(
                            achievement.title ?? achievement.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isCompleted 
                                  ? Colors.black87
                                  : Colors.grey[600],
                            ),
                          ),
                      ),
                      if (isCompleted && (achievement.isRewardClaimed ?? false))
                        Icon(
                          MdiIcons.checkCircle,
                          color: Colors.green,
                          size: 20,
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 进度条（未完成成就）
                  if (!isCompleted && achievement.progress != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: achievement.progress!.current / achievement.progress!.target,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getAchievementColor(achievement.type ?? 'general'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${achievement.progress!.current}/${achievement.progress!.target}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  
                  // 奖励信息
                  Row(
                    children: [
                      if ((achievement.pointsReward ?? 0) > 0) ...[
                        Icon(
                          Icons.monetization_on,
                          color: Colors.amber[600],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${achievement.pointsReward ?? 0}积分',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (achievement.badgeReward != null) ...[
                        Icon(
                          MdiIcons.medal,
                          color: Colors.purple[600],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          achievement.badgeReward!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.purple[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  // 完成时间
                  if (isCompleted && achievement.completedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '完成于 ${_formatDate(achievement.completedAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // 操作按钮
            Column(
              children: [
                if (isCompleted && !(achievement.isRewardClaimed ?? false))
                  ElevatedButton(
                    onPressed: () => onClaimReward(achievement.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: const Text(
                      '领取',
                      style: TextStyle(fontSize: 12),
                    ),
                  )
                else if (!isCompleted)
                  Icon(
                    Icons.lock_outline,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                
                const SizedBox(height: 4),
                
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            MdiIcons.trophyOutline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无成就',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '开始训练，解锁更多成就吧！',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 获取成就图标
  IconData _getAchievementIcon(String type) {
    switch (type) {
      case 'first_workout':
        return MdiIcons.dumbbell;
      case 'streak_7':
      case 'streak_30':
      case 'streak_100':
        return MdiIcons.calendarCheck;
      case 'total_workouts':
        return MdiIcons.trophy;
      case 'calories_burned':
        return MdiIcons.fire;
      case 'weight_lifted':
        return MdiIcons.weightLifter;
      case 'distance_covered':
        return MdiIcons.run;
      case 'social':
        return MdiIcons.accountGroup;
      case 'challenge':
        return MdiIcons.flag;
      case 'level_up':
        return MdiIcons.star;
      default:
        return MdiIcons.medal;
    }
  }

  /// 获取成就颜色
  Color _getAchievementColor(String type) {
    switch (type) {
      case 'first_workout':
        return Colors.blue;
      case 'streak_7':
      case 'streak_30':
      case 'streak_100':
        return Colors.green;
      case 'total_workouts':
        return Colors.orange;
      case 'calories_burned':
        return Colors.red;
      case 'weight_lifted':
        return Colors.purple;
      case 'distance_covered':
        return Colors.teal;
      case 'social':
        return Colors.pink;
      case 'challenge':
        return Colors.indigo;
      case 'level_up':
        return Colors.amber;
      default:
        return AppTheme.primary;
    }
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
