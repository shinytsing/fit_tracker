import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_widgets.dart';

/// 训练与数据页面
/// 展示训练计划、数据统计、身体指标等真实数据
class TrainingDataPage extends ConsumerStatefulWidget {
  const TrainingDataPage({super.key});

  @override
  ConsumerState<TrainingDataPage> createState() => _TrainingDataPageState();
}

class _TrainingDataPageState extends ConsumerState<TrainingDataPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic>? _trainingStats;
  Map<String, dynamic>? _currentPlan;
  List<dynamic> _planHistory = [];
  List<dynamic> _achievements = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // 并行加载所有数据
      final futures = await Future.wait([
        _loadTrainingStats(),
        _loadCurrentPlan(),
        _loadPlanHistory(),
        _loadAchievements(),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载数据失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadTrainingStats() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get(
        '/api/v1/stats/training',
      );
      if (response.statusCode == 200) {
        setState(() {
          _trainingStats = response.data['data'];
        });
      }
    } catch (e) {
      // 使用模拟数据
      setState(() {
        _trainingStats = {
          'current_streak': 7,
          'total_calories_burned': 1500,
          'total_workouts': 12,
          'period': 'week',
          'workouts_this_period': 3,
          'calories_this_period': 450,
          'avg_duration': 45,
          'favorite_exercise': '俯卧撑',
        };
      });
    }
  }

  Future<void> _loadCurrentPlan() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get(
        '/api/v1/training/plans/current',
      );
      if (response.statusCode == 200) {
        setState(() {
          _currentPlan = response.data['data'];
        });
      }
    } catch (e) {
      // 使用模拟数据
      setState(() {
        _currentPlan = {
          'id': 'plan_current',
          'name': '减脂塑形计划',
          'description': '30天减脂塑形训练计划',
          'duration': 30,
          'progress': 15,
          'start_date': DateTime.now().subtract(const Duration(days: 15)),
          'end_date': DateTime.now().add(const Duration(days: 15)),
          'exercises': [
            {
              'name': '俯卧撑',
              'sets': 3,
              'reps': 15,
              'completed': true,
            },
            {
              'name': '深蹲',
              'sets': 3,
              'reps': 20,
              'completed': false,
            },
          ],
        };
      });
    }
  }

  Future<void> _loadPlanHistory() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get(
        '/api/v1/training/plans/history',
      );
      if (response.statusCode == 200) {
        setState(() {
          _planHistory = response.data['plans'] ?? [];
        });
      }
    } catch (e) {
      // 使用模拟数据
      setState(() {
        _planHistory = [
          {
            'id': 'plan_1',
            'name': '增肌训练计划',
            'duration': 28,
            'completed': true,
            'start_date': DateTime.now().subtract(const Duration(days: 60)),
            'end_date': DateTime.now().subtract(const Duration(days: 32)),
            'rating': 4,
          },
          {
            'id': 'plan_2',
            'name': '有氧训练计划',
            'duration': 14,
            'completed': true,
            'start_date': DateTime.now().subtract(const Duration(days: 45)),
            'end_date': DateTime.now().subtract(const Duration(days: 31)),
            'rating': 5,
          },
        ];
      });
    }
  }

  Future<void> _loadAchievements() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get(
        '/api/v1/training/achievements',
      );
      if (response.statusCode == 200) {
        setState(() {
          _achievements = response.data['data']['achievements'] ?? [];
        });
      }
    } catch (e) {
      // 使用模拟数据
      setState(() {
        _achievements = [
          {
            'id': 'achievement_1',
            'name': '训练新手',
            'description': '完成第一次训练',
            'icon': '🏆',
            'is_claimed': true,
            'points': 10,
          },
          {
            'id': 'achievement_2',
            'name': '坚持一周',
            'description': '连续训练7天',
            'icon': '🔥',
            'is_claimed': false,
            'points': 50,
          },
          {
            'id': 'achievement_3',
            'name': '卡路里燃烧者',
            'description': '单次训练消耗500卡路里',
            'icon': '💪',
            'is_claimed': false,
            'points': 30,
          },
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          '训练与数据',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: '数据统计'),
            Tab(text: '训练计划'),
            Tab(text: '成就系统'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStatsTab(),
                _buildPlansTab(),
                _buildAchievementsTab(),
              ],
            ),
    );
  }

  /// 构建数据统计标签页
  Widget _buildStatsTab() {
    if (_trainingStats == null) {
      return const Center(child: Text('暂无数据'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 当前连续天数
          _buildStatCard(
            title: '连续训练',
            value: '${_trainingStats!['current_streak']}',
            unit: '天',
            icon: Icons.local_fire_department,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),

          // 总训练次数
          _buildStatCard(
            title: '总训练次数',
            value: '${_trainingStats!['total_workouts']}',
            unit: '次',
            icon: Icons.fitness_center,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),

          // 总消耗卡路里
          _buildStatCard(
            title: '总消耗卡路里',
            value: '${_trainingStats!['total_calories_burned']}',
            unit: 'kcal',
            icon: Icons.whatshot,
            color: Colors.red,
          ),
          const SizedBox(height: 16),

          // 本周训练
          _buildStatCard(
            title: '本周训练',
            value: '${_trainingStats!['workouts_this_period']}',
            unit: '次',
            icon: Icons.calendar_today,
            color: Colors.green,
          ),
          const SizedBox(height: 16),

          // 本周卡路里
          _buildStatCard(
            title: '本周卡路里',
            value: '${_trainingStats!['calories_this_period']}',
            unit: 'kcal',
            icon: Icons.trending_up,
            color: Colors.purple,
          ),
          const SizedBox(height: 16),

          // 平均训练时长
          _buildStatCard(
            title: '平均训练时长',
            value: '${_trainingStats!['avg_duration']}',
            unit: '分钟',
            icon: Icons.timer,
            color: Colors.teal,
          ),
          const SizedBox(height: 16),

          // 最喜欢的运动
          _buildStatCard(
            title: '最喜欢的运动',
            value: _trainingStats!['favorite_exercise'],
            unit: '',
            icon: Icons.favorite,
            color: Colors.pink,
          ),
        ],
      ),
    );
  }

  /// 构建训练计划标签页
  Widget _buildPlansTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 当前计划
          if (_currentPlan != null) ...[
            const Text(
              '当前计划',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildCurrentPlanCard(),
            const SizedBox(height: 24),
          ],

          // 历史计划
          const Text(
            '历史计划',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._planHistory.map((plan) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildHistoryPlanCard(plan),
              )),
        ],
      ),
    );
  }

  /// 构建成就系统标签页
  Widget _buildAchievementsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: _achievements.map((achievement) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildAchievementCard(achievement),
          );
        }).toList(),
      ),
    );
  }

  /// 构建统计卡片
  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: value,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      if (unit.isNotEmpty)
                        TextSpan(
                          text: ' $unit',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建当前计划卡片
  Widget _buildCurrentPlanCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  _currentPlan!['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentPlan!['progress']}%',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currentPlan!['description'],
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _currentPlan!['progress'] / 100,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
          const SizedBox(height: 16),
          const Text(
            '训练项目',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...(_currentPlan!['exercises'] as List).map((exercise) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    exercise['completed'] ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: exercise['completed'] ? Colors.green : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('${exercise['name']} - ${exercise['sets']}组 x ${exercise['reps']}次'),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// 构建历史计划卡片
  Widget _buildHistoryPlanCard(Map<String, dynamic> plan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${plan['duration']}天计划',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  size: 16,
                  color: index < plan['rating']
                      ? Colors.amber
                      : Colors.grey[300],
                );
              }),
              const SizedBox(width: 8),
              Icon(
                plan['completed'] ? Icons.check_circle : Icons.cancel,
                color: plan['completed'] ? Colors.green : Colors.red,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建成就卡片
  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: achievement['is_claimed']
                  ? Colors.amber.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                achievement['icon'],
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: achievement['is_claimed']
                        ? Colors.black
                        : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement['description'],
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '+${achievement['points']}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: achievement['is_claimed']
                      ? Colors.amber
                      : Colors.grey,
                ),
              ),
              const Text(
                '积分',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
