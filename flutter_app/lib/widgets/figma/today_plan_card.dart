import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import 'custom_button.dart';

class TodayPlanCard extends StatelessWidget {
  const TodayPlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isIOS = themeProvider.isIOS;

    return CustomCard(
      isIOS: isIOS,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '今日计划',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '进行中',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Workout List
          ...List.generate(3, (index) {
            final workouts = [
              {'name': '胸部训练', 'sets': '4组', 'reps': '12-15次', 'time': '45分钟'},
              {'name': '肩部训练', 'sets': '3组', 'reps': '10-12次', 'time': '30分钟'},
              {'name': '有氧运动', 'sets': '1组', 'reps': '30分钟', 'time': '30分钟'},
            ];
            
            final workout = workouts[index];
            final isCompleted = index == 0; // First workout completed
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? Colors.green
                          : AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : Icons.fitness_center,
                      color: isCompleted ? Colors.white : AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout['name']!,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isCompleted ? Colors.green[700] : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              workout['sets']!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              workout['reps']!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              workout['time']!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  if (!isCompleted)
                    Icon(
                      Icons.play_circle_outline,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                ],
              ),
            );
          }),
          
          const SizedBox(height: 16),
          
          // Action Button
          CustomButton(
            text: '开始训练',
            onPressed: () {
              // Navigate to workout screen
            },
            isIOS: isIOS,
          ),
        ],
      ),
    );
  }
}
