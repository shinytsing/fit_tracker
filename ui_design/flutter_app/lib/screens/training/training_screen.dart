import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/stats_card.dart';
import '../../widgets/today_plan_card.dart';
import '../../widgets/ai_plan_generator.dart';
import '../../widgets/training_history_list.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isIOS = themeProvider.themeType == ThemeType.ios;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[200]!,
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '训练',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '让我们开始今天的训练吧！',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          CustomIconButton(
                            icon: Icons.search,
                            onPressed: () {},
                            isIOS: isIOS,
                          ),
                          const SizedBox(width: 12),
                          Stack(
                            children: [
                              CustomIconButton(
                                icon: Icons.notifications_outlined,
                                onPressed: () {},
                                isIOS: isIOS,
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Progress Stats
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          value: '12',
                          label: '本周训练',
                          isIOS: isIOS,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          value: '2.3k',
                          label: '消耗卡路里',
                          isIOS: isIOS,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          value: '85%',
                          label: '目标完成',
                          isIOS: isIOS,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
            // Today's Plan
            const TodayPlanCard(),
            
            const SizedBox(height: 16),
            
            // AI Plan Generator
            const AIPlanGenerator(),
            
            const SizedBox(height: 16),
            
            // Training History
            const TrainingHistoryList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
