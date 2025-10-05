import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import 'custom_button.dart';

class TrainingHistoryList extends StatelessWidget {
  const TrainingHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isIOS = themeProvider.isIOS;

    final trainingHistory = [
      {
        'date': '2024-01-15',
        'workout': '胸部训练',
        'duration': '45分钟',
        'calories': '320',
        'completed': true,
      },
      {
        'date': '2024-01-14',
        'workout': '腿部训练',
        'duration': '50分钟',
        'calories': '380',
        'completed': true,
      },
      {
        'date': '2024-01-13',
        'workout': '肩部训练',
        'duration': '40分钟',
        'calories': '280',
        'completed': true,
      },
      {
        'date': '2024-01-12',
        'workout': '背部训练',
        'duration': '55分钟',
        'calories': '420',
        'completed': true,
      },
      {
        'date': '2024-01-11',
        'workout': '有氧运动',
        'duration': '30分钟',
        'calories': '250',
        'completed': false,
      },
    ];

    return CustomCard(
      isIOS: isIOS,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '训练历史',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full history
                },
                child: Text(
                  '查看全部',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // History List
          ...trainingHistory.asMap().entries.map((entry) {
            final index = entry.key;
            final workout = entry.value;
            final isCompleted = workout['completed'] as bool;
            
            return Container(
              margin: EdgeInsets.only(bottom: index < trainingHistory.length - 1 ? 12 : 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCompleted 
                    ? Colors.green.withOpacity(0.05)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCompleted 
                      ? Colors.green.withOpacity(0.2)
                      : Colors.grey[200]!,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? Colors.green
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : Icons.schedule,
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
                          workout['workout'] as String,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isCompleted ? Colors.green[700] : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              workout['date'] as String,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              workout['duration'] as String,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${workout['calories']} 卡',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.orange[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isCompleted ? '已完成' : '未完成',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isCompleted ? Colors.green[600] : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
          
          const SizedBox(height: 16),
          
          // View More Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Navigate to full history
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                '查看更多历史记录',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
