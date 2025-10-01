import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/models.dart';
import '../../../../shared/widgets/custom_widgets.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/stats_grid.dart';
import '../widgets/achievement_list.dart';
import '../widgets/data_charts.dart';
import '../widgets/settings_list.dart';

/// Tab5 - 我（个人中心）页面
/// 包含个人资料、训练数据、成就系统、设置等功能
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    
    // 加载初始数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          '我',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        actions: [
          // 设置按钮
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/profile/settings');
            },
          ),
          // 更多操作
          PopupMenuButton<String>(
            onSelected: (value) {
              _handleMenuAction(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit_profile',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('编辑资料'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share_profile',
                child: Row(
                  children: [
                    Icon(Icons.share, size: 16),
                    SizedBox(width: 8),
                    Text('分享主页'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'privacy_settings',
                child: Row(
                  children: [
                    Icon(Icons.privacy_tip, size: 16),
                    SizedBox(width: 8),
                    Text('隐私设置'),
                  ],
                ),
              ),
            ],
            child: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: '数据', icon: Icon(Icons.analytics)),
            Tab(text: '成就', icon: Icon(Icons.emoji_events)),
            Tab(text: '计划', icon: Icon(Icons.calendar_today)),
            Tab(text: '设置', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: Column(
        children: [
          // 个人资料头部
          if (profileState.user != null)
            ProfileHeader(
              user: profileState.user!,
              onEditProfile: () {
                Navigator.pushNamed(context, '/profile/edit');
              },
              onViewFollowers: () {
                Navigator.pushNamed(context, '/profile/followers');
              },
              onViewFollowing: () {
                Navigator.pushNamed(context, '/profile/following');
              },
            ),
          
          // Tab内容区域
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: 数据统计
                _buildDataTab(profileState),
                
                // Tab 2: 成就系统
                _buildAchievementTab(profileState),
                
                // Tab 3: 训练计划
                _buildPlanTab(profileState),
                
                // Tab 4: 设置
                _buildSettingsTab(profileState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建数据统计Tab
  Widget _buildDataTab(ProfileState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 数据统计网格
          if (state.userStats != null)
            StatsGrid(
              stats: state.userStats!,
              onStatTap: (statType) {
                _navigateToStatDetail(statType);
              },
            ),
          
          const SizedBox(height: 24),
          
          // 数据图表
          if (state.chartData != null)
            DataCharts(
              chartData: state.chartData!,
              onChartTap: (chartType) {
                _navigateToChartDetail(chartType);
              },
            ),
          
          const SizedBox(height: 24),
          
          // 最近活动
          _buildRecentActivity(state.recentActivity),
        ],
      ),
    );
  }

  /// 构建成就系统Tab
  Widget _buildAchievementTab(ProfileState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 成就概览
          _buildAchievementOverview(state.achievements),
          
          const SizedBox(height: 24),
          
          // 成就列表
          AchievementList(
            achievements: state.achievements,
            onAchievementTap: (achievement) {
              _navigateToAchievementDetail(achievement);
            },
            onClaimReward: (achievementId) {
              ref.read(profileProvider.notifier).claimAchievementReward(achievementId);
            },
          ),
        ],
      ),
    );
  }

  /// 构建训练计划Tab
  Widget _buildPlanTab(ProfileState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 当前计划
          _buildCurrentPlan(state.currentPlan),
          
          const SizedBox(height: 24),
          
          // 计划历史
          _buildPlanHistory(state.planHistory),
          
          const SizedBox(height: 24),
          
          // 营养计划
          _buildNutritionPlan(state.nutritionPlan),
        ],
      ),
    );
  }

  /// 构建设置Tab
  Widget _buildSettingsTab(ProfileState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 设置列表
          SettingsList(
            settings: state.settings,
            onSettingTap: (setting) {
              _navigateToSetting(setting);
            },
          ),
          
          const SizedBox(height: 24),
          
          // 其他选项
          _buildOtherOptions(),
        ],
      ),
    );
  }

  /// 构建成就概览
  Widget _buildAchievementOverview(List<Achievement> achievements) {
    final completedCount = achievements.where((a) => a.isCompleted).length;
    final totalCount = achievements.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    
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
                MdiIcons.trophy,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '成就进度',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      '$completedCount / $totalCount',
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
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 进度条
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  /// 构建当前计划
  Widget _buildCurrentPlan(TrainingPlan? plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '当前训练计划',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profile/plans');
              },
              child: const Text('查看全部'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (plan != null)
          Container(
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
                Text(
                  plan.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  plan.description ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildPlanStat('时长', '${plan.duration}分钟'),
                    const SizedBox(width: 16),
                    _buildPlanStat('动作', '${plan.exercises?.length ?? 0}个'),
                    const SizedBox(width: 16),
                    _buildPlanStat('消耗', '${plan.calories}卡'),
                  ],
                ),
              ],
            ),
          )
        else
          Container(
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
                  '暂无训练计划',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/training/create-plan');
                  },
                  child: const Text('创建计划'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 构建计划统计项
  Widget _buildPlanStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// 构建计划历史
  Widget _buildPlanHistory(List<TrainingPlan> history) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '计划历史',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/training/history');
              },
              child: const Text('查看全部'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (history.isNotEmpty)
          ...history.take(3).map((plan) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    MdiIcons.dumbbell,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${plan.duration}分钟 • ${plan.calories}卡',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatDate(plan.date ?? DateTime.now()),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }).toList()
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '暂无计划历史',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  /// 构建营养计划
  Widget _buildNutritionPlan(NutritionPlan? plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '营养计划',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/nutrition/plan');
              },
              child: const Text('管理'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (plan != null)
          Container(
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
                Text(
                  plan.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  plan.description ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildNutritionStat('卡路里', '${plan.targetCalories}卡'),
                    const SizedBox(width: 16),
                    _buildNutritionStat('蛋白质', '${plan.targetProtein}g'),
                    const SizedBox(width: 16),
                    _buildNutritionStat('碳水', '${plan.targetCarbs}g'),
                  ],
                ),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '暂无营养计划',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  /// 构建营养统计项
  Widget _buildNutritionStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// 构建最近活动
  Widget _buildRecentActivity(List<Activity> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '最近活动',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profile/activity');
              },
              child: const Text('查看全部'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (activities.isNotEmpty)
          ...activities.take(5).map((activity) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    _getActivityIcon(activity.type),
                    color: _getActivityColor(activity.type),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          activity.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatTimeAgo(activity.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }).toList()
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '暂无最近活动',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  /// 构建其他选项
  Widget _buildOtherOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '其他',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
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
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('帮助中心'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, '/profile/help');
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('关于我们'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, '/profile/about');
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: const Text('意见反馈'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, '/profile/feedback');
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('退出登录', style: TextStyle(color: Colors.red)),
                onTap: () {
                  _showLogoutDialog();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 事件处理方法
  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit_profile':
        Navigator.pushNamed(context, '/profile/edit');
        break;
      case 'share_profile':
        _shareProfile();
        break;
      case 'privacy_settings':
        Navigator.pushNamed(context, '/profile/privacy');
        break;
    }
  }

  void _navigateToStatDetail(String statType) {
    Navigator.pushNamed(context, '/profile/stats', arguments: statType);
  }

  void _navigateToChartDetail(String chartType) {
    Navigator.pushNamed(context, '/profile/charts', arguments: chartType);
  }

  void _navigateToAchievementDetail(Achievement achievement) {
    Navigator.pushNamed(context, '/profile/achievement', arguments: achievement);
  }

  void _navigateToSetting(Setting setting) {
    Navigator.pushNamed(context, setting.route ?? '/settings');
  }

  void _shareProfile() {
    // TODO: 实现分享功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('分享功能开发中')),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(profileProvider.notifier).logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  // 辅助方法
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

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'workout':
        return MdiIcons.dumbbell;
      case 'checkin':
        return MdiIcons.checkCircle;
      case 'achievement':
        return MdiIcons.trophy;
      case 'post':
        return MdiIcons.post;
      default:
        return MdiIcons.dumbbell;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'workout':
        return Colors.orange;
      case 'checkin':
        return Colors.green;
      case 'achievement':
        return Colors.purple;
      case 'post':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}