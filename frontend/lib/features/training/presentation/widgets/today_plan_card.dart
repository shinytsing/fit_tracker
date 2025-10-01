import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/models.dart';
import '../../domain/models/training_models.dart';

/// 今日计划卡片组件
/// 显示今日的训练计划，包括动作、组数、重量、完成状态
class TodayPlanCard extends StatelessWidget {
  final TrainingPlan plan;
  final VoidCallback onStartWorkout;
  final VoidCallback onViewDetails;

  const TodayPlanCard({
    super.key,
    required this.plan,
    required this.onStartWorkout,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 计划头部
          _buildPlanHeader(),
          
          // 计划信息
          _buildPlanInfo(),
          
          // 动作列表
          _buildExerciseList(),
          
          // 操作按钮
          _buildActionButtons(),
        ],
      ),
    );
  }

  /// 构建计划头部
  Widget _buildPlanHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              MdiIcons.dumbbell,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plan.description ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // 计划状态
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _getStatusText(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建计划信息
  Widget _buildPlanInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildInfoItem(
            '时长',
            '${plan.duration}分钟',
            MdiIcons.clockOutline,
            Colors.blue,
          ),
          const SizedBox(width: 20),
          _buildInfoItem(
            '动作',
            '${plan.exercises?.length ?? 0}个',
            MdiIcons.dumbbell,
            Colors.orange,
          ),
          const SizedBox(width: 20),
          _buildInfoItem(
            '消耗',
            '${plan.calories}卡',
            MdiIcons.fire,
            Colors.red,
          ),
          const SizedBox(width: 20),
          _buildInfoItem(
            '难度',
            _getDifficultyText(),
            MdiIcons.speedometer,
            _getDifficultyColor(),
          ),
        ],
      ),
    );
  }

  /// 构建信息项
  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建动作列表
  Widget _buildExerciseList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '训练动作',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onViewDetails,
                child: const Text('查看全部'),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 显示前3个动作
          ...(plan.exercises?.take(3).map((exercise) {
            return _buildExerciseItem(TrainingExercise(
              id: exercise.id,
              name: exercise.name,
              description: exercise.description ?? '',
              type: ExerciseType.strength,
              sets: [],
              restTime: 60,
              instructions: exercise.instructions ?? '',
              imageUrl: exercise.imageUrl,
              videoUrl: exercise.videoUrl,
              muscles: [],
              equipment: [],
            ));
          }).toList() ?? []),
          
          // 如果动作超过3个，显示更多按钮
          if ((plan.exercises?.length ?? 0) > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: TextButton(
                  onPressed: onViewDetails,
                  child: Text(
                    '还有${(plan.exercises?.length ?? 0) - 3}个动作',
                    style: TextStyle(color: AppTheme.primary),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建动作项
  Widget _buildExerciseItem(TrainingExercise exercise) {
    final completedSets = exercise.sets.where((set) => set.isCompleted).length;
    final totalSets = exercise.sets.length;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // 动作图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getExerciseTypeColor(exercise.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getExerciseTypeIcon(exercise.type),
              color: _getExerciseTypeColor(exercise.type),
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 动作信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${totalSets}组 • ${exercise.sets.first.reps}次 • ${exercise.sets.first.weight}kg',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // 完成状态
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: completedSets == totalSets 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$completedSets/$totalSets',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: completedSets == totalSets 
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onViewDetails,
              icon: const Icon(Icons.info_outline),
              label: const Text('查看详情'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: onStartWorkout,
              icon: const Icon(Icons.play_arrow),
              label: const Text('开始训练'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 辅助方法
  String _getStatusText() {
    switch (plan.status) {
      case 'active':
        return '进行中';
      case 'completed':
        return '已完成';
      case 'paused':
        return '已暂停';
      case 'draft':
        return '草稿';
      case 'cancelled':
        return '已取消';
      default:
        return '未知';
    }
  }

  String _getDifficultyText() {
    switch (plan.difficulty) {
      case 'beginner':
        return '初级';
      case 'intermediate':
        return '中级';
      case 'advanced':
        return '高级';
      default:
        return '未知';
    }
  }

  Color _getDifficultyColor() {
    switch (plan.difficulty) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getExerciseTypeIcon(ExerciseType type) {
    switch (type) {
      case ExerciseType.strength:
        return MdiIcons.weightLifter;
      case ExerciseType.cardio:
        return MdiIcons.run;
      case ExerciseType.flexibility:
        return MdiIcons.yoga;
      case ExerciseType.balance:
        return MdiIcons.scaleBalance;
      case ExerciseType.sports:
        return MdiIcons.soccer;
    }
  }

  Color _getExerciseTypeColor(ExerciseType type) {
    switch (type) {
      case ExerciseType.strength:
        return Colors.blue;
      case ExerciseType.cardio:
        return Colors.red;
      case ExerciseType.flexibility:
        return Colors.green;
      case ExerciseType.balance:
        return Colors.purple;
      case ExerciseType.sports:
        return Colors.orange;
    }
  }
}