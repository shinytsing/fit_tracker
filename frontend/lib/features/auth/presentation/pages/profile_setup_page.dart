import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/common_widgets.dart';

/// 个人数据填写页面
/// 用于注册后填写个人身体数据和健身目标
class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _exerciseYearsController = TextEditingController();
  
  bool _isLoading = false;
  String _selectedGoal = '增肌'; // 默认选择增肌
  
  final List<String> _fitnessGoals = [
    '增肌',
    '减脂',
    '塑形',
    '力量',
    '有氧',
    '康复',
  ];

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _exerciseYearsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          '完善个人资料',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        automaticallyImplyLeading: false, // 隐藏返回按钮
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 欢迎标题
              const SizedBox(height: 20),
              const Text(
                '完善个人资料',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                '这些信息将帮助AI为您生成个性化训练计划',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // 身高输入
              _buildHeightField(),
              const SizedBox(height: 16),

              // 体重输入
              _buildWeightField(),
              const SizedBox(height: 16),

              // 运动年限输入
              _buildExerciseYearsField(),
              const SizedBox(height: 16),

              // 健身目标选择
              _buildFitnessGoalSelector(),
              const SizedBox(height: 24),

              // BMI显示
              _buildBMIDisplay(),
              const SizedBox(height: 24),

              // 保存按钮
              _buildSaveButton(),
              const SizedBox(height: 16),

              // 跳过按钮
              _buildSkipButton(),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建身高输入框
  Widget _buildHeightField() {
    return CustomTextField(
      controller: _heightController,
      labelText: '身高 (cm)',
      hintText: '请输入身高',
      prefixIcon: Icons.height,
      keyboardType: TextInputType.number,
      onChanged: (_) => setState(() {}), // 触发BMI计算
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入身高';
        }
        final height = double.tryParse(value);
        if (height == null) {
          return '请输入有效的身高';
        }
        if (height < 100 || height > 250) {
          return '身高应在100-250cm之间';
        }
        return null;
      },
    );
  }

  /// 构建体重输入框
  Widget _buildWeightField() {
    return CustomTextField(
      controller: _weightController,
      labelText: '体重 (kg)',
      hintText: '请输入体重',
      prefixIcon: Icons.monitor_weight,
      keyboardType: TextInputType.number,
      onChanged: (_) => setState(() {}), // 触发BMI计算
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入体重';
        }
        final weight = double.tryParse(value);
        if (weight == null) {
          return '请输入有效的体重';
        }
        if (weight < 30 || weight > 300) {
          return '体重应在30-300kg之间';
        }
        return null;
      },
    );
  }

  /// 构建运动年限输入框
  Widget _buildExerciseYearsField() {
    return CustomTextField(
      controller: _exerciseYearsController,
      labelText: '运动年限 (年)',
      hintText: '请输入运动年限',
      prefixIcon: Icons.fitness_center,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入运动年限';
        }
        final years = int.tryParse(value);
        if (years == null) {
          return '请输入有效的运动年限';
        }
        if (years < 0 || years > 50) {
          return '运动年限应在0-50年之间';
        }
        return null;
      },
    );
  }

  /// 构建健身目标选择器
  Widget _buildFitnessGoalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '健身目标',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _fitnessGoals.map((goal) {
            final isSelected = _selectedGoal == goal;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedGoal = goal;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Text(
                  goal,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 构建BMI显示
  Widget _buildBMIDisplay() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    
    if (height != null && weight != null && height > 0 && weight > 0) {
      final bmi = weight / ((height / 100) * (height / 100));
      final bmiCategory = _getBMICategory(bmi);
      
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BMI指数: ${bmi.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  Text(
                    bmiCategory,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  /// 获取BMI分类
  String _getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return '偏瘦';
    } else if (bmi < 24) {
      return '正常';
    } else if (bmi < 28) {
      return '偏胖';
    } else {
      return '肥胖';
    }
  }

  /// 构建保存按钮
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleSave,
      child: _isLoading 
        ? const CircularProgressIndicator() 
        : const Text('保存并继续'),
    );
  }

  /// 构建跳过按钮
  Widget _buildSkipButton() {
    return TextButton(
      onPressed: _isLoading ? null : _handleSkip,
      child: const Text(
        '暂时跳过',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
      ),
    );
  }

  /// 处理保存
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 调用保存个人资料API
      final response = await ref.read(apiServiceProvider).createUserProfile(
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        exerciseYears: int.parse(_exerciseYearsController.text),
        fitnessGoal: _selectedGoal,
      );

      // 显示成功消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? '个人资料保存成功'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // 延迟跳转到首页
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 处理跳过
  Future<void> _handleSkip() async {
    // 直接跳转到首页
    if (mounted) {
      context.go('/');
    }
  }
}
