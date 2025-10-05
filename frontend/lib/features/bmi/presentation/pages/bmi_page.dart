/// BMI 页面
/// BMI 计算和记录界面

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_widgets.dart';
import '../../../../core/services/bmi_api_service.dart';

/// BMI 页面
class BMIPage extends ConsumerStatefulWidget {
  const BMIPage({super.key});

  @override
  ConsumerState<BMIPage> createState() => _BMIPageState();
}

class _BMIPageState extends ConsumerState<BMIPage> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  double? _bmi;
  String? _bmiCategory;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI 计算器'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BMI 计算器
            CustomCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BMI 计算器',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '身高 (cm)',
                        hintText: '请输入身高',
                        prefixIcon: Icon(Icons.height),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入身高';
                        }
                        final height = double.tryParse(value);
                        if (height == null || height <= 0) {
                          return '请输入有效的身高';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '体重 (kg)',
                        hintText: '请输入体重',
                        prefixIcon: Icon(Icons.monitor_weight),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入体重';
                        }
                        final weight = double.tryParse(value);
                        if (weight == null || weight <= 0) {
                          return '请输入有效的体重';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _calculateBMI,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('计算 BMI'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppTheme.errorColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: AppTheme.errorColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_bmi != null) ...[
              const SizedBox(height: 24),
              
              // BMI 结果显示
              CustomCard(
                child: Column(
                  children: [
                    Text(
                      '您的 BMI',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _bmi!.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getBMIColor(_bmi!),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTag(
                      text: _bmiCategory!,
                      backgroundColor: _getBMIColor(_bmi!).withValues(alpha: 0.1),
                      textColor: _getBMIColor(_bmi!),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // BMI 标准说明
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BMI 标准',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBMIRange('偏瘦', '< 18.5', AppTheme.infoColor),
                    _buildBMIRange('正常', '18.5 - 24.9', AppTheme.successColor),
                    _buildBMIRange('偏胖', '25.0 - 29.9', AppTheme.warningColor),
                    _buildBMIRange('肥胖', '≥ 30.0', AppTheme.errorColor),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _calculateBMI() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final height = double.parse(_heightController.text);
      final weight = double.parse(_weightController.text);
      
      // 调用真实 API 计算 BMI
      final response = await BMIApiService.calculateBMI(
        height: height,
        weight: weight,
        age: 25, // 默认年龄，实际应用中可以从用户资料获取
        gender: 'male', // 默认性别，实际应用中可以从用户资料获取
      );
      
      // 解析 API 响应
      final bmiData = response['data'] ?? response;
      _bmi = (bmiData['bmi'] as num).toDouble();
      _bmiCategory = bmiData['category'] ?? _getBMICategory(_bmi!);
      
      // 保存 BMI 记录到后端
      try {
        await BMIApiService.createBMIRecord(
          height: height,
          weight: weight,
          bmi: _bmi!,
          notes: '通过 BMI 计算器计算',
        );
      } catch (e) {
        // 记录保存失败不影响显示结果
        print('保存 BMI 记录失败: $e');
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'BMI 计算失败: ${e.toString()}';
      });
    }
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return '偏瘦';
    } else if (bmi < 25) {
      return '正常';
    } else if (bmi < 30) {
      return '偏胖';
    } else {
      return '肥胖';
    }
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) {
      return AppTheme.infoColor;
    } else if (bmi < 25) {
      return AppTheme.successColor;
    } else if (bmi < 30) {
      return AppTheme.warningColor;
    } else {
      return AppTheme.errorColor;
    }
  }

  Widget _buildBMIRange(String category, String range, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            range,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}