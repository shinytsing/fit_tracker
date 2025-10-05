import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';
import '../../widgets/custom_button.dart';

class AIPlanGenerator extends StatefulWidget {
  const AIPlanGenerator({super.key});

  @override
  State<AIPlanGenerator> createState() => _AIPlanGeneratorState();
}

class _AIPlanGeneratorState extends State<AIPlanGenerator> {
  bool _isGenerating = false;

  void _generatePlan() {
    setState(() {
      _isGenerating = true;
    });
    
    // Simulate AI generation
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isGenerating = false;
      });
      
      // Show generated plan
      _showGeneratedPlan();
    });
  }

  void _showGeneratedPlan() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI为你生成的训练计划',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '基于你的目标和经验，我们为你定制了以下训练计划：',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Generated Plan
                      ...List.generate(4, (index) {
                        final plans = [
                          {'name': '热身运动', 'duration': '10分钟', 'description': '动态拉伸和轻度有氧'},
                          {'name': '力量训练', 'duration': '45分钟', 'description': '复合动作和孤立训练'},
                          {'name': '有氧训练', 'duration': '20分钟', 'description': 'HIIT或稳态有氧'},
                          {'name': '拉伸放松', 'duration': '10分钟', 'description': '静态拉伸和放松'},
                        ];
                        
                        final plan = plans[index];
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: ThemeProvider.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.fitness_center,
                                  color: ThemeProvider.primaryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      plan['name']!,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      plan['description']!,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                plan['duration']!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: ThemeProvider.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      
                      const SizedBox(height: 24),
                      
                      CustomButton(
                        text: '应用此计划',
                        onPressed: () {
                          Navigator.pop(context);
                          // Apply the plan
                        },
                        isIOS: context.watch<ThemeProvider>().themeType == ThemeType.ios,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isIOS = themeProvider.themeType == ThemeType.ios;

    return CustomCard(
      isIOS: isIOS,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.purple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI训练计划生成器',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '基于你的目标生成个性化训练计划',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Features
          Row(
            children: [
              Expanded(
                child: _buildFeatureItem(
                  context,
                              Icons.flag,
                  '个性化',
                  '根据你的目标定制',
                ),
              ),
              Expanded(
                child: _buildFeatureItem(
                  context,
                  Icons.schedule,
                  '科学安排',
                  '合理的训练强度',
                ),
              ),
              Expanded(
                child: _buildFeatureItem(
                  context,
                  Icons.trending_up,
                  '持续优化',
                  '根据进度调整',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Generate Button
          CustomButton(
            text: _isGenerating ? '生成中...' : '生成训练计划',
            onPressed: _isGenerating ? () {} : _generatePlan,
            isIOS: isIOS,
            backgroundColor: Colors.purple,
          ),
          
          if (_isGenerating) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.purple,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
