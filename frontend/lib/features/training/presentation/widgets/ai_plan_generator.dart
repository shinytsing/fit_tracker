import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/models.dart';
import '../providers/training_provider.dart';

/// AI训练计划生成器组件
/// 基于用户身体数据和训练历史生成个性化训练计划
class AIPlanGenerator extends StatefulWidget {
  final bool isGenerating;
  final VoidCallback onGeneratePlan;
  final Function(TrainingPlan)? onPlanGenerated;
  final Map<String, dynamic> userProfile;

  const AIPlanGenerator({
    super.key,
    required this.isGenerating,
    required this.onGeneratePlan,
    this.onPlanGenerated,
    required this.userProfile,
  });

  @override
  State<AIPlanGenerator> createState() => _AIPlanGeneratorState();
}

class _AIPlanGeneratorState extends State<AIPlanGenerator> {
  String _selectedGoal = '增肌';
  String _selectedDuration = '45分钟';
  String _selectedDifficulty = '中级';
  List<String> _selectedMuscleGroups = ['全身'];
  bool _includeCardio = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI教练介绍卡片
          _buildAICoachIntro(),
          
          const SizedBox(height: 24),
          
          // 用户身体数据展示
          _buildUserProfileCard(),
          
          const SizedBox(height: 24),
          
          // 训练偏好设置
          _buildPreferenceSettings(),
          
          const SizedBox(height: 24),
          
          // 生成按钮
          _buildGenerateButton(),
          
          const SizedBox(height: 24),
          
          // AI推荐说明
          _buildAIExplanation(),
        ],
      ),
    );
  }

  /// 构建AI教练介绍卡片
  Widget _buildAICoachIntro() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary,
            AppTheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // AI头像
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              MdiIcons.robot,
              color: Colors.white,
              size: 40,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // AI教练名称
          const Text(
            'AI健身教练',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // AI介绍
          Text(
            '基于您的身体数据和训练历史，为您生成最适合的个性化训练计划',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // AI能力标签
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCapabilityTag('个性化推荐'),
              _buildCapabilityTag('科学训练'),
              _buildCapabilityTag('实时调整'),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建能力标签
  Widget _buildCapabilityTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 构建用户资料卡片
  Widget _buildUserProfileCard() {
    return Container(
      width: double.infinity,
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
              Icon(MdiIcons.accountCircle, color: AppTheme.primary),
              const SizedBox(width: 8),
              const Text(
                '您的身体数据',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 身体数据网格
          Row(
            children: [
              Expanded(
                child: _buildDataItem(
                  '身高',
                  '${widget.userProfile['height']}cm',
                  MdiIcons.ruler,
                ),
              ),
              Expanded(
                child: _buildDataItem(
                  '体重',
                  '${widget.userProfile['weight']}kg',
                  MdiIcons.weightKilogram,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildDataItem(
                  '年龄',
                  '${widget.userProfile['age']}岁',
                  MdiIcons.cake,
                ),
              ),
              Expanded(
                child: _buildDataItem(
                  '健身水平',
                  widget.userProfile['fitnessLevel'],
                  MdiIcons.trendingUp,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // BMI计算
          _buildBMICalculation(),
        ],
      ),
    );
  }

  /// 构建数据项
  Widget _buildDataItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
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

  /// 构建BMI计算
  Widget _buildBMICalculation() {
    final height = (widget.userProfile['height'] ?? 0).toDouble();
    final weight = (widget.userProfile['weight'] ?? 0).toDouble();
    final bmi = weight / ((height / 100) * (height / 100));
    final bmiCategory = _getBMICategory(bmi);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bmiCategory['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bmiCategory['color'].withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(MdiIcons.chartLine, color: bmiCategory['color']),
          const SizedBox(width: 8),
          Text(
            'BMI: ${bmi.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: bmiCategory['color'],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            bmiCategory['text'],
            style: TextStyle(
              fontSize: 12,
              color: bmiCategory['color'],
            ),
          ),
        ],
      ),
    );
  }

  /// 获取BMI分类
  Map<String, dynamic> _getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return {'text': '偏瘦', 'color': Colors.blue};
    } else if (bmi < 24) {
      return {'text': '正常', 'color': Colors.green};
    } else if (bmi < 28) {
      return {'text': '偏胖', 'color': Colors.orange};
    } else {
      return {'text': '肥胖', 'color': Colors.red};
    }
  }

  /// 构建偏好设置
  Widget _buildPreferenceSettings() {
    return Container(
      width: double.infinity,
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
              Icon(MdiIcons.cog, color: AppTheme.primary),
              const SizedBox(width: 8),
              const Text(
                '训练偏好设置',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 训练目标
          _buildPreferenceItem(
            '训练目标',
            _selectedGoal,
            ['增肌', '减脂', '塑形', '增强体质'],
            (value) => setState(() => _selectedGoal = value),
          ),
          
          const SizedBox(height: 16),
          
          // 训练时长
          _buildPreferenceItem(
            '训练时长',
            _selectedDuration,
            ['30分钟', '45分钟', '60分钟', '90分钟'],
            (value) => setState(() => _selectedDuration = value),
          ),
          
          const SizedBox(height: 16),
          
          // 训练难度
          _buildPreferenceItem(
            '训练难度',
            _selectedDifficulty,
            ['初级', '中级', '高级'],
            (value) => setState(() => _selectedDifficulty = value),
          ),
          
          const SizedBox(height: 16),
          
          // 目标肌肉群
          _buildMuscleGroupSelector(),
          
          const SizedBox(height: 16),
          
          // 包含有氧运动
          _buildCardioOption(),
        ],
      ),
    );
  }

  /// 构建偏好项
  Widget _buildPreferenceItem(
    String title,
    String currentValue,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = option == currentValue;
            return GestureDetector(
              onTap: () => onChanged(option),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 构建肌肉群选择器
  Widget _buildMuscleGroupSelector() {
    final muscleGroups = [
      '全身', '胸肌', '背肌', '腿部', '肩部', '手臂', '核心', '臀部'
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '目标肌肉群',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: muscleGroups.map((muscle) {
            final isSelected = _selectedMuscleGroups.contains(muscle);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedMuscleGroups.remove(muscle);
                  } else {
                    _selectedMuscleGroups.add(muscle);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  muscle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 构建有氧运动选项
  Widget _buildCardioOption() {
    return Row(
      children: [
        Checkbox(
          value: _includeCardio,
          onChanged: (value) {
            setState(() {
              _includeCardio = value ?? false;
            });
          },
          activeColor: AppTheme.primary,
        ),
        const Text(
          '包含有氧运动',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(width: 8),
        Icon(
          MdiIcons.run,
          color: Colors.green,
          size: 16,
        ),
      ],
    );
  }

  /// 构建生成按钮
  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: widget.isGenerating ? null : widget.onGeneratePlan,
        icon: widget.isGenerating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(MdiIcons.robot, color: Colors.white),
        label: Text(
          widget.isGenerating ? 'AI正在生成中...' : '生成AI训练计划',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  /// 构建AI说明
  Widget _buildAIExplanation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(MdiIcons.information, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'AI生成说明',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• AI会根据您的身体数据、训练历史和偏好设置生成个性化训练计划\n'
            '• 计划包含具体的动作、组数、重量和休息时间\n'
            '• 支持动作视频指导和训练提醒\n'
            '• 可根据训练效果实时调整计划',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
