import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/models.dart';
import '../../../../shared/widgets/custom_widgets.dart';
import '../providers/training_provider.dart';
import '../widgets/today_plan_card.dart';
import '../widgets/ai_plan_generator.dart';
import '../widgets/training_history_list.dart';
import '../widgets/achievement_grid.dart';
import '../widgets/checkin_calendar.dart';
import '../widgets/progress_chart.dart';

/// Tab1 - 训练页面
/// 包含今日计划、训练历史、AI训练计划、打卡签到、成就系统、进度趋势
class TrainingPage extends ConsumerStatefulWidget {
  const TrainingPage({super.key});

  @override
  ConsumerState<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends ConsumerState<TrainingPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trainingState = ref.watch(trainingProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          '训练',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        actions: [
          // 刷新按钮
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              ref.read(trainingProvider.notifier).loadInitialData();
            },
          ),
          // 更多操作
          PopupMenuButton<String>(
            onSelected: (value) {
              _handleMenuAction(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'create_plan',
                child: Row(
                  children: [
                    Icon(Icons.add, size: 16),
                    SizedBox(width: 8),
                    Text('创建计划'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import_template',
                child: Row(
                  children: [
                    Icon(Icons.file_download, size: 16),
                    SizedBox(width: 8),
                    Text('导入模板'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_data',
                child: Row(
                  children: [
                    Icon(Icons.file_upload, size: 16),
                    SizedBox(width: 8),
                    Text('导出数据'),
                  ],
                ),
              ),
            ],
            child: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: '今日计划', icon: Icon(Icons.today)),
            Tab(text: '训练历史', icon: Icon(Icons.history)),
            Tab(text: 'AI训练计划', icon: Icon(Icons.psychology)),
            Tab(text: '打卡签到', icon: Icon(Icons.check_circle)),
            Tab(text: '成就系统', icon: Icon(Icons.emoji_events)),
            Tab(text: '进度趋势', icon: Icon(Icons.trending_up)),
          ],
        ),
      ),
      body: Column(
        children: [
          // 错误提示
          if (trainingState.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.red[50],
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      trainingState.error!,
                      style: TextStyle(color: Colors.red[600]),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      ref.read(trainingProvider.notifier).clearError();
                    },
                  ),
                ],
              ),
            ),
          
          // Tab内容区域
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: 今日计划
                _buildTodayPlanTab(trainingState),
                
                // Tab 2: 训练历史
                _buildHistoryTab(trainingState),
                
                // Tab 3: AI训练计划
                _buildAIPlanTab(trainingState),
                
                // Tab 4: 打卡签到
                _buildCheckInTab(trainingState),
                
                // Tab 5: 成就系统
                _buildAchievementTab(trainingState),
                
                // Tab 6: 进度趋势
                _buildProgressTab(trainingState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建今日计划Tab
  Widget _buildTodayPlanTab(TrainingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 统计概览
          _buildStatsOverview(state),
          
          const SizedBox(height: 20),
          
          // 今日计划
          if (state.todayPlan != null)
            TodayPlanCard(
              plan: state.todayPlan!,
              onStartWorkout: () {
                _startWorkout(state.todayPlan!.id);
              },
              onViewDetails: () {
                _viewPlanDetails(state.todayPlan!);
              },
            )
          else
            _buildNoPlanCard(),
          
          const SizedBox(height: 20),
          
          // 快速操作
          _buildQuickActions(),
        ],
      ),
    );
  }

  /// 构建训练历史Tab
  Widget _buildHistoryTab(TrainingState state) {
    return TrainingHistoryList(
      history: state.history,
      isLoading: state.isLoading,
      onHistoryTap: (history) {
        _viewHistoryDetails(history);
      },
      onRefresh: () {
        ref.read(trainingProvider.notifier).loadInitialData();
      },
    );
  }

  /// 构建AI训练计划Tab
  Widget _buildAIPlanTab(TrainingState state) {
    return AIPlanGenerator(
      isGenerating: state.isGeneratingPlan,
      onGeneratePlan: () {
        ref.read(trainingProvider.notifier).generateAIPlan(
          goal: '增肌',
          duration: 30,
          difficulty: TrainingDifficulty.intermediate,
          preferences: <String>[],
          availableEquipment: [],
        );
      },
      onPlanGenerated: (plan) {
        _viewPlanDetails(plan);
      },
      userProfile: {
        'age': 25,
        'weight': 70,
        'height': 175,
        'fitnessLevel': '中级',
        'goals': ['增肌', '减脂'],
      },
    );
  }

  /// 构建打卡签到Tab
  Widget _buildCheckInTab(TrainingState state) {
    return CheckInCalendar(
      checkIns: state.checkIns,
      currentStreak: state.currentStreak,
      onCheckIn: (type, content, images, location) {
        ref.read(trainingProvider.notifier).checkIn(
          type: type,
          content: content,
          images: images,
          location: location,
        );
      },
    );
  }

  /// 构建成就系统Tab
  Widget _buildAchievementTab(TrainingState state) {
    return AchievementGrid(
      achievements: state.achievements,
      onAchievementTap: (achievement) {
        _viewAchievementDetails(achievement);
      },
      onClaimReward: (achievementId) {
        ref.read(trainingProvider.notifier).claimAchievementReward(achievementId);
      },
    );
  }

  /// 构建进度趋势Tab
  Widget _buildProgressTab(TrainingState state) {
    return ProgressChart(
      stats: UserStats(
        totalWorkouts: state.totalWorkouts,
        totalMinutes: 0, // 从历史数据计算
        totalCaloriesBurned: state.totalCaloriesBurned,
        currentStreak: state.currentStreak,
        maxStreak: state.currentStreak,
        averageWorkoutDuration: 0,
        workoutFrequency: 0,
        maxWeightLifted: 0,
        totalDistanceCovered: 0,
      ),
      history: state.history,
      onChartTap: (chartType) {
        _viewChartDetails(chartType);
      },
    );
  }

  /// 构建统计概览
  Widget _buildStatsOverview(TrainingState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
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
          Row(
            children: [
              Icon(
                MdiIcons.dumbbell,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '训练统计',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      '${state.totalWorkouts}次训练',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${state.currentStreak}天',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '消耗卡路里',
                  '${state.totalCaloriesBurned}卡',
                  MdiIcons.fire,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '连续打卡',
                  '${state.currentStreak}天',
                  MdiIcons.calendarCheck,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  /// 构建无计划卡片
  Widget _buildNoPlanCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            MdiIcons.dumbbell,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            '今日暂无训练计划',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '创建或生成一个训练计划开始今天的训练吧！',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _tabController.animateTo(2); // 切换到AI训练计划Tab
                  },
                  icon: const Icon(Icons.psychology),
                  label: const Text('AI生成'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _createCustomPlan();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('创建计划'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建快速操作
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '快速操作',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                '开始训练',
                MdiIcons.play,
                Colors.green,
                () {
                  if (ref.read(trainingProvider).todayPlan != null) {
                    _startWorkout(ref.read(trainingProvider).todayPlan!.id);
                  } else {
                    _tabController.animateTo(2); // 切换到AI训练计划Tab
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                '打卡签到',
                MdiIcons.checkCircle,
                Colors.blue,
                () {
                  _tabController.animateTo(3); // 切换到打卡签到Tab
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                '查看成就',
                MdiIcons.trophy,
                Colors.orange,
                () {
                  _tabController.animateTo(4); // 切换到成就系统Tab
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                '进度分析',
                MdiIcons.chartLine,
                Colors.purple,
                () {
                  _tabController.animateTo(5); // 切换到进度趋势Tab
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建快速操作卡片
  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 事件处理方法
  void _handleMenuAction(String action) {
    switch (action) {
      case 'create_plan':
        _createCustomPlan();
        break;
      case 'import_template':
        _importTemplate();
        break;
      case 'export_data':
        _exportData();
        break;
    }
  }

  void _startWorkout(String planId) {
    ref.read(trainingProvider.notifier).startWorkout(planId);
    // 导航到训练页面
    Navigator.pushNamed(context, '/training/workout', arguments: planId);
  }

  void _viewPlanDetails(plan) {
    Navigator.pushNamed(context, '/training/plan-details', arguments: plan);
  }

  void _viewHistoryDetails(history) {
    Navigator.pushNamed(context, '/training/history-details', arguments: history);
  }

  void _viewAchievementDetails(achievement) {
    Navigator.pushNamed(context, '/training/achievement-details', arguments: achievement);
  }

  void _viewChartDetails(String chartType) {
    Navigator.pushNamed(context, '/training/chart-details', arguments: chartType);
  }

  void _createCustomPlan() {
    Navigator.pushNamed(context, '/training/create-plan');
  }

  void _importTemplate() {
    Navigator.pushNamed(context, '/training/import-template');
  }

  void _exportData() {
    // TODO: 实现数据导出功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('数据导出功能开发中')),
    );
  }
}