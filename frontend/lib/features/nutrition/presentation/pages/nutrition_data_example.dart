/// 营养数据加载示例
/// 展示如何在页面中使用错误处理

import 'package:flutter/material.dart';
import '../../../../core/services/error_handler.dart';
import '../../../../core/services/api_services.dart';

class NutritionDataExample extends StatefulWidget {
  const NutritionDataExample({super.key});

  @override
  State<NutritionDataExample> createState() => _NutritionDataExampleState();
}

class _NutritionDataExampleState extends State<NutritionDataExample> {
  final NutritionApiService _nutritionApiService = NutritionApiService();
  Map<String, dynamic>? _nutritionData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNutritionData();
  }

  /// 加载营养数据，展示错误处理的使用
  Future<void> _loadNutritionData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _nutritionApiService.getDailyIntake();
      setState(() {
        _nutritionData = data;
        _isLoading = false;
      });
      
      // 显示成功消息
      ErrorHandler.showSuccess(context, '营养数据加载成功');
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      
      // 使用全局错误处理
      ErrorHandler.handleError(context, error);
    }
  }

  /// 计算营养信息，展示错误处理的使用
  Future<void> _calculateNutrition() async {
    try {
      final result = await _nutritionApiService.calculateNutrition(
        foodName: '苹果',
        quantity: 100,
        unit: 'g',
      );
      
      // 显示成功消息
      ErrorHandler.showSuccess(context, '营养计算完成');
      
      // 处理结果...
      print('Nutrition calculation result: $result');
    } catch (error) {
      // 使用全局错误处理
      ErrorHandler.handleError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('营养数据示例'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNutritionData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _nutritionData == null
              ? const Center(
                  child: Text('暂无数据'),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '今日营养摄入',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      
                      // 显示营养数据
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildNutritionItem('卡路里', '${_nutritionData!['calories'] ?? 0}', 'kcal'),
                              _buildNutritionItem('蛋白质', '${_nutritionData!['protein'] ?? 0}', 'g'),
                              _buildNutritionItem('碳水化合物', '${_nutritionData!['carbs'] ?? 0}', 'g'),
                              _buildNutritionItem('脂肪', '${_nutritionData!['fat'] ?? 0}', 'g'),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // 操作按钮
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _calculateNutrition,
                              child: const Text('计算营养'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _loadNutritionData,
                              child: const Text('刷新数据'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildNutritionItem(String label, String value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text('$value $unit'),
        ],
      ),
    );
  }
}
