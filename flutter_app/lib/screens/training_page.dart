import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../core/theme/app_theme.dart';
import '../providers/providers.dart';

/// 基于Figma设计的现代化训练页面
/// 完全按照Gymates Fitness Social App设计规范实现
class TrainingPage extends ConsumerStatefulWidget {
  const TrainingPage({super.key});

  @override
  ConsumerState<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends ConsumerState<TrainingPage> {
  final bool isIOS = Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isIOS ? const Color(0xFFF9FAFB) : AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 头部区域
            _buildHeader(),
            
            // 内容区域
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 今日计划卡片
                    _buildTodayPlanCard(),
                    
                    const SizedBox(height: 24),
                    
                    // AI 计划生成器
                    _buildAIPlanGenerator(),
                    
                    const SizedBox(height: 24),
                    
                    // 训练历史列表
                    _buildTrainingHistoryList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建头部区域 - 基于Figma设计
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        children: [
          // 标题和操作按钮
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '训练',
                      style: TextStyle(
                        fontSize: isIOS ? 28 : 24,
                        fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '让我们开始今天的训练吧！',
                      style: TextStyle(
                        fontSize: isIOS ? 16 : 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  // 搜索按钮
                  _buildHeaderButton(
                    icon: Icons.search_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(width: 12),
                  // 通知按钮
                  _buildHeaderButton(
                    icon: Icons.notifications_outlined,
                    onTap: () {},
                    hasNotification: true,
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 进度统计卡片
          Row(
            children: [
              Expanded(
                child: _buildStatCard('12', '本周训练'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('2.3k', '消耗卡路里'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('85%', '目标完成'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建头部按钮
  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
    bool hasNotification = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                icon,
                color: const Color(0xFF6B7280),
                size: 20,
              ),
            ),
            if (hasNotification)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建统计卡片 - 基于Figma设计
  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isIOS ? const Color(0xFFF9FAFB) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(isIOS ? 16 : 12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: isIOS ? 24 : 20,
              fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isIOS ? 12 : 10,
              color: const Color(0xFF6B7280),
              fontWeight: isIOS ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建今日计划卡片 - 基于Figma设计
  Widget _buildTodayPlanCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: isIOS ? 20 : 12,
            offset: Offset(0, isIOS ? 10 : 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '今日训练计划',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '上肢力量训练',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              _buildPlanInfo(Icons.access_time_rounded, '45分钟'),
              const SizedBox(width: 24),
              _buildPlanInfo(Icons.track_changes_rounded, '5个动作'),
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
                  borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
                ),
                child: const Text(
                  '开始训练',
                  style: TextStyle(
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
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
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 构建 AI 计划生成器 - 基于Figma设计
  Widget _buildAIPlanGenerator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isIOS ? 0.1 : 0.12),
            blurRadius: isIOS ? 20 : 4,
            offset: Offset(0, isIOS ? 10 : 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
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
                      'AI 智能推荐',
                      style: TextStyle(
                        fontSize: isIOS ? 16 : 14,
                        fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '根据您的数据生成个性化训练计划',
                      style: TextStyle(
                        fontSize: isIOS ? 12 : 10,
                        color: const Color(0xFF6B7280),
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
                  borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
                ),
                elevation: 0,
              ),
              child: Text(
                '生成训练计划',
                style: TextStyle(
                  fontSize: isIOS ? 14 : 12,
                  fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建训练历史列表
  Widget _buildTrainingHistoryList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isIOS ? 0.1 : 0.12),
            blurRadius: isIOS ? 20 : 4,
            offset: Offset(0, isIOS ? 10 : 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '训练历史',
            style: TextStyle(
              fontSize: isIOS ? 16 : 14,
              fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          
          // 空状态
          Center(
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: Color(0xFF9CA3AF),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '暂无训练记录',
                  style: TextStyle(
                    fontSize: isIOS ? 14 : 12,
                    fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '开始您的第一次训练吧！',
                  style: TextStyle(
                    fontSize: isIOS ? 12 : 10,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        ),
        title: const Text('AI训练推荐'),
        content: const Text('AI推荐功能开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}