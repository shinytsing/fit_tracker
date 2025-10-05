import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/models.dart';
import '../../../../core/network/api_service.dart';
import '../../../../shared/widgets/custom_widgets.dart';
import '../providers/training_provider.dart';
import '../widgets/today_plan_card.dart';
import '../widgets/ai_plan_generator.dart';
import '../widgets/training_history_list.dart';
import '../widgets/achievement_grid.dart';
import '../widgets/checkin_calendar.dart';
import '../widgets/progress_chart.dart';
import '../../../rest/widgets/rest_timer_widget.dart';
import '../../../rest/widgets/rest_input_widget.dart';
import '../../../rest/widgets/rest_feed_widget.dart';
import '../../../../core/providers/rest_provider.dart';
import '../../../../shared/widgets/feature_migration_banner.dart';

/// Tab1 - 训练页面
/// 按照功能重排表实现：
/// - 今日训练计划：展示当日安排，一键开始
/// - 训练执行：动作分解、完成进度、计时/计数
/// - AI推荐训练：个性化训练计划、智能动作推荐
/// - 训练历史：历史记录、趋势图、对比数据
/// - 打卡签到：每日打卡、连续天数统计
/// - 休息模式：休息时间管理、恢复建议
/// - 数据统计：训练时长、消耗卡路里、训练强度
/// - 身体指标：BMI、体脂率、肌肉量计算
/// - 营养管理：饮食记录、饮水追踪、营养建议
/// - AI助手入口：训练/营养/健康问答
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
    _tabController = TabController(length: 2, vsync: this); // 简化为2个Tab
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    
    // 加载初始数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(trainingProvider.notifier).loadInitialData();
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
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // 头部区域 - 完全按照 Figma 设计
            _buildHeader(trainingState),
            
            // 内容区域
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 今日计划卡片
                    _buildTodayPlanCard(trainingState),
                    
                    const SizedBox(height: 24),
                    
                    // AI 计划生成器
                    _buildAIPlanGenerator(),
                    
                    const SizedBox(height: 24),
                    
                    // 训练历史列表
                    _buildTrainingHistoryList(trainingState),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建头部区域 - 完全按照 Figma 设计
  Widget _buildHeader(TrainingState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 标题和操作按钮
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '训练',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '让我们开始今天的训练吧！',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  // 搜索按钮
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.inputBackground,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: AppTheme.textSecondary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 通知按钮
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.inputBackground,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(
                            Icons.notifications_outlined,
                            color: AppTheme.textSecondary,
                            size: 22,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.errorColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 进度统计卡片
          Row(
            children: [
              Expanded(
                child: _buildStatCard('12', '本周训练'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('2.3k', '消耗卡路里'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('85%', '目标完成'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建统计卡片 - 基于Figma设计
  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  /// 构建今日计划卡片 - 完全按照 Figma 设计
  Widget _buildTodayPlanCard(TrainingState state) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.floatingShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '今日训练计划',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '上肢力量训练',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              _buildPlanInfo(Icons.access_time, '45分钟'),
              const SizedBox(width: 24),
              _buildPlanInfo(Icons.track_changes, '5个动作'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              // 进度指示器
              Row(
                children: List.generate(5, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.only(right: index < 4 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: index == 0 
                          ? Colors.white 
                          : Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
              const Spacer(),
              // 开始训练按钮
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '开始训练',
                  style: TextStyle(
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建计划信息
  Widget _buildPlanInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  /// 构建 AI 计划生成器 - 基于Figma设计
  Widget _buildAIPlanGenerator() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Color(0xFF6366F1),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI 智能推荐',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '根据您的数据生成个性化训练计划',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showAIRecommendationDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '生成训练计划',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建训练历史列表
  Widget _buildTrainingHistoryList(TrainingState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '训练历史',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          
          if (state.history.isEmpty)
            _buildEmptyHistory()
          else
            ...state.history.take(3).map((history) => _buildHistoryItem(history)),
          
          if (state.history.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Center(
                child: TextButton(
                  onPressed: () => _viewAllHistory(),
                  child: const Text(
                    '查看全部',
                    style: TextStyle(
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建空历史状态
  Widget _buildEmptyHistory() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Color(0xFF9CA3AF),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无训练记录',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '开始您的第一次训练吧！',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建历史记录项
  Widget _buildHistoryItem(dynamic history) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Color(0xFF6366F1),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.planName ?? '训练计划',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${history.duration ?? 0}分钟 • ${history.caloriesBurned ?? 0}卡路里',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatDate(history.completedAt ?? DateTime.now()),
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  // 辅助方法
  void _viewAllHistory() {
    // TODO: 导航到完整历史页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('查看全部训练历史功能开发中...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// 构建身体指标Tab
  Widget _buildBodyMetricsTab(TrainingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BMI计算器
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BMI计算器',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                Text('BMI计算器功能开发中...'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建营养管理Tab
  Widget _buildNutritionTab(TrainingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 营养概览
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '营养管理',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                Text('营养管理功能开发中...'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建AI助手Tab
  Widget _buildAIAssistantTab(TrainingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI助手入口
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI助手',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                Text('AI助手功能开发中...'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 显示AI推荐弹窗
  void _showAIRecommendationDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // AI图标和标题
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.psychology,
                  size: 48,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'AI训练推荐',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '选择您的训练目标，AI将为您生成个性化训练计划',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              
              // 推荐选项
              _buildRecommendationOption(
                '增肌训练',
                '适合想要增加肌肉量的用户',
                MdiIcons.dumbbell,
                Colors.blue,
                () {},
              ),
              
              const SizedBox(height: 12),
              
              _buildRecommendationOption(
                '减脂训练',
                '适合想要燃烧脂肪的用户',
                MdiIcons.fire,
                Colors.red,
                () {},
              ),
              
              const SizedBox(height: 12),
              
              _buildRecommendationOption(
                '全身训练',
                '适合想要全面提升的用户',
                MdiIcons.account,
                Colors.green,
                () {},
              ),
              
              const SizedBox(height: 24),
              
              // 关闭按钮
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  '取消',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建推荐选项
  Widget _buildRecommendationOption(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: color.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建快速操作按钮
  Widget _buildQuickActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.fitness_center),
            label: const Text('开始训练'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.analytics),
            label: const Text('查看数据'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建今日计划Tab
  Widget _buildTodayPlanTab(TrainingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          _buildQuickActionButtons(),
          
          const SizedBox(height: 20),
          
        ],
      ),
    );
  }




  /// 构建数据统计Tab - 包含训练统计、训练历史、打卡签到、数据图表
  Widget _buildDataStatsTab(TrainingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 训练统计概览
          _buildTrainingStatsOverview(state),
          
          const SizedBox(height: 20),
          
          // 训练历史
          _buildTrainingHistorySection(state),
          
          const SizedBox(height: 20),
          
          // 打卡签到
          _buildCheckInSection(state),
          
          const SizedBox(height: 20),
          
          // 数据图表
          _buildDataCharts(state),
        ],
      ),
    );
  }





  /// 构建训练统计概览
  Widget _buildTrainingStatsOverview(TrainingState state) {
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
                      '训练数据统计',
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
                    _showAIRecommendationDialog(); // 显示AI推荐弹窗
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
    Navigator.pushNamed(context, '/training/export-data');
  }

  void _viewHistoryDetails(history) {
    Navigator.pushNamed(context, '/training/history-details', arguments: history);
  }

  /// 构建训练历史部分
  Widget _buildTrainingHistorySection(TrainingState state) {
    return Container(
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
              Icon(
                MdiIcons.history,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
        const Text(
                '训练历史',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (state.history.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
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
                    '暂无训练记录',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '开始您的第一次训练吧！',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
              ),
            ),
          ],
        ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.history.take(5).length,
              itemBuilder: (context, index) {
                final history = state.history[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Icon(
                      MdiIcons.dumbbell,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    history.planName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    '${history.duration}分钟 • ${history.caloriesBurned}卡路里',
                  ),
                  trailing: Text(
                    _formatDate(history.completedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  onTap: () => _viewHistoryDetails(history),
                );
              },
            ),
        ],
      ),
    );
  }

  /// 构建打卡签到部分
  Widget _buildCheckInSection(TrainingState state) {
    return Container(
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
              Icon(
                MdiIcons.checkCircle,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '打卡签到',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
              ),
            ),
          ],
        ),
          const SizedBox(height: 16),
          
          // 连续打卡天数
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.1),
                  AppTheme.primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
            ),
            child: Row(
          children: [
                Icon(
                  MdiIcons.fire,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 16),
            Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '连续打卡 ${state.currentStreak} 天',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Text(
                        '保持这个节奏，继续加油！',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryColor.withOpacity(0.7),
              ),
            ),
          ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _performCheckIn(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('立即打卡'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 打卡日历
          CheckInCalendar(
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
          ),
        ],
      ),
    );
  }

  /// 构建数据图表部分
  Widget _buildDataCharts(TrainingState state) {
    return Container(
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
              Icon(
                MdiIcons.chartLine,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '数据图表',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
            ),
          ],
        ),
          const SizedBox(height: 16),
          
          ProgressChart(
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
          ),
        ],
      ),
    );
  }

  /// 执行打卡
  void _performCheckIn() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('打卡成功'),
        content: const Text('恭喜您完成今日打卡！继续保持这个好习惯。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return '今天';
    } else if (difference == 1) {
      return '昨天';
    } else if (difference < 7) {
      return '$difference天前';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  /// 构建AI推荐按钮
  Widget _buildAIRecommendationButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _handleAIRecommendation,
        icon: Icon(
          MdiIcons.robot,
          color: Colors.white,
        ),
        label: const Text(
          'AI智能推荐训练计划',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  /// 处理AI推荐
  Future<void> _handleAIRecommendation() async {
    try {
      // 显示加载对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('AI正在生成训练计划...'),
            ],
          ),
        ),
      );

      // 调用AI推荐API
      final response = await ref.read(apiServiceProvider).post('/training/ai-generate', data: {
        'goal': '减脂塑形',
        'duration': 30,
        'difficulty': '中级',
        'equipment': ['哑铃', '杠铃', '跑步机'],
        'focus_areas': ['全身', '核心']
      });
      
      // 关闭加载对话框
      if (mounted) {
        Navigator.of(context).pop();
        
        // 显示AI生成的训练计划
        _showAITrainingPlan(response.data['plan']);
      }
    } catch (e) {
      // 关闭加载对话框
      if (mounted) {
        Navigator.of(context).pop();
        
        // 显示错误信息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI推荐失败: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 显示AI训练计划
  void _showAITrainingPlan(dynamic planData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(planData['name'] ?? 'AI训练计划'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                planData['description'] ?? '根据您的个人数据生成的个性化训练计划',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              
              // 训练计划详情
              if (planData['exercises'] != null) ...[
                const Text(
                  '训练动作:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                
                ...((planData['exercises'] as List).map((exercise) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise['name'] ?? '未知动作',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (exercise['sets'] != null && (exercise['sets'] as List).isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${(exercise['sets'] as List).length}组 × ${(exercise['sets'] as List).first['reps']}次',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                )).toList()),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 这里可以添加保存训练计划的逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('训练计划已保存'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('保存计划'),
          ),
        ],
      ),
    );
  }
}
