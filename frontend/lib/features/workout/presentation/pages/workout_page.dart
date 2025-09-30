/// 训练页面
/// 训练计划和记录界面

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_widgets.dart';

/// 训练页面
class WorkoutPage extends ConsumerStatefulWidget {
  const WorkoutPage({super.key});

  @override
  ConsumerState<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends ConsumerState<WorkoutPage> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('训练中心'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: 实现添加训练计划功能
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 标签页
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('训练计划', 0),
                ),
                Expanded(
                  child: _buildTabButton('AI 教练', 1),
                ),
                Expanded(
                  child: _buildTabButton('进度追踪', 2),
                ),
              ],
            ),
          ),
          
          // 内容区域
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildWorkoutPlanTab(),
                _buildAICoachTab(),
                _buildProgressTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildWorkoutPlanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 今日训练
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '今日训练',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildWorkoutItem(
                  '力量训练',
                  '胸肌 + 三头肌',
                  '45分钟',
                  '进行中',
                  AppTheme.primaryColor,
                ),
                const Divider(),
                _buildWorkoutItem(
                  '有氧运动',
                  '跑步机',
                  '30分钟',
                  '已完成',
                  AppTheme.successColor,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 训练计划
          Text(
            '训练计划',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildPlanCard(
            '新手入门计划',
            '适合健身新手的基础训练计划',
            '4周',
            '3次/周',
            AppTheme.primaryColor,
          ),
          
          const SizedBox(height: 12),
          
          _buildPlanCard(
            '增肌训练计划',
            '专注于肌肉增长的训练计划',
            '8周',
            '4次/周',
            AppTheme.warningColor,
          ),
          
          const SizedBox(height: 12),
          
          _buildPlanCard(
            '减脂训练计划',
            '高效燃脂的训练计划',
            '6周',
            '5次/周',
            AppTheme.successColor,
          ),
        ],
      ),
    );
  }

  Widget _buildAICoachTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI 教练建议
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'AI 教练建议',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Text(
                  '根据您的训练历史和目标，为您推荐：',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                
                _buildSuggestionItem('增加核心训练，提高身体稳定性'),
                _buildSuggestionItem('调整训练强度，避免过度训练'),
                _buildSuggestionItem('注意休息时间，保证肌肉恢复'),
                _buildSuggestionItem('补充蛋白质，支持肌肉生长'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 个性化训练
          Text(
            '个性化训练',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          CustomCard(
            child: Column(
              children: [
                _buildPersonalizedItem(
                  '上肢力量训练',
                  '针对您的上肢力量薄弱点',
                  '60分钟',
                  AppTheme.primaryColor,
                ),
                const Divider(),
                _buildPersonalizedItem(
                  '下肢爆发力训练',
                  '提升您的下肢爆发力',
                  '45分钟',
                  AppTheme.warningColor,
                ),
                const Divider(),
                _buildPersonalizedItem(
                  '全身协调训练',
                  '改善身体协调性和平衡',
                  '30分钟',
                  AppTheme.successColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 本周进度
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '本周进度',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildProgressItem('训练次数', '4', '5', '次', AppTheme.primaryColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildProgressItem('训练时长', '180', '200', '分钟', AppTheme.warningColor),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildProgressItem('卡路里', '800', '1000', 'kcal', AppTheme.successColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildProgressItem('完成率', '80', '100', '%', AppTheme.infoColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 训练记录
          Text(
            '训练记录',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          CustomCard(
            child: Column(
              children: [
                _buildRecordItem('2024-01-15', '力量训练', '45分钟', '已完成'),
                const Divider(),
                _buildRecordItem('2024-01-14', '有氧运动', '30分钟', '已完成'),
                const Divider(),
                _buildRecordItem('2024-01-13', '瑜伽', '60分钟', '已完成'),
                const Divider(),
                _buildRecordItem('2024-01-12', '力量训练', '50分钟', '已完成'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutItem(String title, String description, String duration, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                duration,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              CustomTag(
                text: status,
                backgroundColor: color.withValues(alpha: 0.1),
                textColor: color,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(String title, String description, String duration, String frequency, Color color) {
    return CustomCard(
      onTap: () {
        // TODO: 实现训练计划详情
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CustomTag(
                text: 'AI推荐',
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                textColor: AppTheme.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: AppTheme.textSecondaryColor),
              const SizedBox(width: 4),
              Text(
                duration,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.repeat, size: 16, color: AppTheme.textSecondaryColor),
              const SizedBox(width: 4),
              Text(
                frequency,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedItem(String title, String description, String duration, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            duration,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, String current, String target, String unit, Color color) {
    final percentage = (int.tryParse(current) ?? 0) / (int.tryParse(target) ?? 1);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '$current / $target $unit',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: color.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildRecordItem(String date, String workout, String duration, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                Text(
                  workout,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            duration,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(width: 12),
          CustomTag(
            text: status,
            backgroundColor: AppTheme.successColor.withValues(alpha: 0.1),
            textColor: AppTheme.successColor,
          ),
        ],
      ),
    );
  }
}