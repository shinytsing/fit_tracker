import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';

/// 数据统计网格组件
/// 显示用户的各种训练数据统计
class StatsGrid extends StatelessWidget {
  final UserStats stats;
  final Function(String) onStatTap;

  const StatsGrid({
    super.key,
    required this.stats,
    required this.onStatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '数据概览',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // 主要统计网格
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              '总训练时长',
              '${stats.totalTrainingMinutes}分钟',
              MdiIcons.clockOutline,
              Colors.blue,
              'training_time',
            ),
            _buildStatCard(
              '完成训练',
              '${stats.completedWorkouts}次',
              MdiIcons.dumbbell,
              Colors.orange,
              'completed_workouts',
            ),
            _buildStatCard(
              '消耗卡路里',
              '${stats.totalCaloriesBurned}卡',
              MdiIcons.fire,
              Colors.red,
              'calories_burned',
            ),
            _buildStatCard(
              '连续打卡',
              '${stats.currentStreak}天',
              MdiIcons.calendarCheck,
              Colors.green,
              'checkin_streak',
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 次要统计网格
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.2,
          children: [
            _buildSmallStatCard(
              '平均时长',
              '${stats.averageWorkoutDuration}分钟',
              MdiIcons.timerOutline,
              Colors.purple,
              'avg_duration',
            ),
            _buildSmallStatCard(
              '训练频率',
              '${stats.workoutFrequency}次/周',
              MdiIcons.chartLine,
              Colors.teal,
              'workout_frequency',
            ),
            _buildSmallStatCard(
              '最大重量',
              '${stats.maxWeightLifted}kg',
              MdiIcons.weightLifter,
              Colors.indigo,
              'max_weight',
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 本周统计
        _buildWeeklyStats(),
      ],
    );
  }

  /// 构建统计卡片
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String statType,
  ) {
    return GestureDetector(
      onTap: () => onStatTap(statType),
      child: Container(
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建小统计卡片
  Widget _buildSmallStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String statType,
  ) {
    return GestureDetector(
      onTap: () => onStatTap(statType),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建本周统计
  Widget _buildWeeklyStats() {
    return Container(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                MdiIcons.calendarWeek,
                color: AppTheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '本周统计',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildWeeklyStatItem(
                  '训练次数',
                  '${stats.weeklyWorkouts}次',
                  MdiIcons.dumbbell,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildWeeklyStatItem(
                  '训练时长',
                  '${stats.weeklyMinutes}分钟',
                  MdiIcons.clockOutline,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildWeeklyStatItem(
                  '消耗卡路里',
                  '${stats.weeklyCalories}卡',
                  MdiIcons.fire,
                  Colors.red,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 本周目标进度
          if (stats.weeklyGoal != null) ...[
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  '本周目标进度',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${stats.weeklyGoal!.progress}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: stats.weeklyGoal!.progress >= 100 
                        ? Colors.green 
                        : AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: stats.weeklyGoal!.progress / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                stats.weeklyGoal!.progress >= 100 
                    ? Colors.green 
                    : AppTheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${stats.weeklyGoal!.current}/${stats.weeklyGoal!.target} ${stats.weeklyGoal!.unit}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建本周统计项
  Widget _buildWeeklyStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
