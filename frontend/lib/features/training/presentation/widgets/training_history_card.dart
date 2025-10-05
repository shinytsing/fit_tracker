import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/models/training_models.dart';
import '../providers/training_provider.dart' as provider;

class TrainingHistoryCard extends StatelessWidget {
  final TrainingPlan plan;

  const TrainingHistoryCard({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MM月dd日');
    final timeFormat = DateFormat('HH:mm');
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  MdiIcons.dumbbell,
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${dateFormat.format(plan.date)} ${timeFormat.format(plan.date)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(plan.status),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              _buildInfoItem(
                icon: MdiIcons.clockOutline,
                label: '时长',
                value: '${plan.duration}分钟',
              ),
              const SizedBox(width: 16),
              _buildInfoItem(
                icon: MdiIcons.fire,
                label: '消耗',
                value: '${plan.calories}卡',
              ),
              const SizedBox(width: 16),
              _buildInfoItem(
                icon: MdiIcons.formatListBulleted,
                label: '动作',
                value: '${plan.exercises.length}个',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(TrainingStatus status) {
    Color color;
    String text;
    IconData icon;
    
    switch (status) {
      case TrainingStatus.pending:
        color = Colors.orange;
        text = '待开始';
        icon = MdiIcons.clockOutline;
        break;
      case TrainingStatus.inProgress:
        color = Colors.blue;
        text = '进行中';
        icon = MdiIcons.play;
        break;
      case TrainingStatus.completed:
        color = Colors.green;
        text = '已完成';
        icon = MdiIcons.check;
        break;
      case TrainingStatus.skipped:
        color = Colors.grey;
        text = '已跳过';
        icon = MdiIcons.skipNext;
        break;
      case TrainingStatus.planned:
        color = Colors.purple;
        text = '已计划';
        icon = MdiIcons.calendar;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
