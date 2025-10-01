/// 营养页面
/// 营养计算和饮食记录界面

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_widgets.dart';

/// 营养页面
class NutritionPage extends ConsumerStatefulWidget {
  const NutritionPage({super.key});

  @override
  ConsumerState<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends ConsumerState<NutritionPage> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('营养管理'),
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
                  child: _buildTabButton('卡路里', 0),
                ),
                Expanded(
                  child: _buildTabButton('营养素', 1),
                ),
                Expanded(
                  child: _buildTabButton('饮食计划', 2),
                ),
              ],
            ),
          ),
          
          // 内容区域
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildCalorieTab(),
                _buildNutrientTab(),
                _buildDietPlanTab(),
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

  Widget _buildCalorieTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 今日卡路里
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '今日卡路里',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildCalorieItem('已摄入', '1,200', 'kcal', AppTheme.primaryColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCalorieItem('已消耗', '800', 'kcal', AppTheme.warningColor),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildCalorieItem('剩余', '400', 'kcal', AppTheme.successColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCalorieItem('目标', '2,000', 'kcal', AppTheme.textSecondaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 快速记录
          Text(
            '快速记录',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildQuickRecordButton('早餐', Icons.wb_sunny, AppTheme.warningColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickRecordButton('午餐', Icons.wb_sunny_outlined, AppTheme.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickRecordButton('晚餐', Icons.nights_stay, AppTheme.infoColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 营养素摄入
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '营养素摄入',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildNutrientItem('蛋白质', 60, 120, 'g', AppTheme.primaryColor),
                _buildNutrientItem('碳水化合物', 200, 300, 'g', AppTheme.warningColor),
                _buildNutrientItem('脂肪', 40, 80, 'g', AppTheme.errorColor),
                _buildNutrientItem('纤维', 15, 25, 'g', AppTheme.successColor),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 维生素和矿物质
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '维生素和矿物质',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildVitaminItem('维生素C', '85%', AppTheme.successColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildVitaminItem('维生素D', '60%', AppTheme.warningColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildVitaminItem('钙', '70%', AppTheme.infoColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildVitaminItem('铁', '45%', AppTheme.errorColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietPlanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI 饮食建议
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'AI 饮食建议',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Text(
                  '根据您的健身目标和身体状况，建议您：',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                
                _buildSuggestionItem('增加蛋白质摄入，建议每餐包含优质蛋白'),
                _buildSuggestionItem('控制碳水化合物摄入，选择复合碳水'),
                _buildSuggestionItem('多食用新鲜蔬菜，补充维生素和矿物质'),
                _buildSuggestionItem('保持充足水分，每日饮水 2-3 升'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 推荐食物
          Text(
            '推荐食物',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          CustomCard(
            child: Column(
              children: [
                _buildFoodItem('鸡胸肉', '高蛋白，低脂肪', '100g', AppTheme.primaryColor),
                const Divider(),
                _buildFoodItem('燕麦', '复合碳水化合物', '50g', AppTheme.warningColor),
                const Divider(),
                _buildFoodItem('西兰花', '富含维生素C', '200g', AppTheme.successColor),
                const Divider(),
                _buildFoodItem('牛油果', '健康脂肪', '半个', AppTheme.errorColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieItem(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          '$label ($unit)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickRecordButton(String title, IconData icon, Color color) {
    return CustomCard(
      onTap: () {
        // TODO: 实现快速记录功能
      },
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientItem(String name, int current, int target, String unit, Color color) {
    final percentage = (current / target * 100).clamp(0, 100);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
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
            value: percentage / 100,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildVitaminItem(String name, String percentage, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            percentage,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            name,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
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

  Widget _buildFoodItem(String name, String description, String amount, Color color) {
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
                  name,
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
            amount,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}