/// 社区页面
/// 社区互动和社交功能界面

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_widgets.dart';

/// 社区页面
class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('社区'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 实现搜索功能
            },
          ),
        ],
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
                  child: _buildTabButton('动态', 0),
                ),
                Expanded(
                  child: _buildTabButton('挑战', 1),
                ),
                Expanded(
                  child: _buildTabButton('排行榜', 2),
                ),
              ],
            ),
          ),
          
          // 内容区域
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildFeedTab(),
                _buildChallengeTab(),
                _buildLeaderboardTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 实现发布动态功能
        },
        child: const Icon(Icons.add),
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

  Widget _buildFeedTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 热门话题
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '热门话题',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  CustomTag(text: '#健身打卡', backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1), textColor: AppTheme.primaryColor),
                  CustomTag(text: '#减脂日记', backgroundColor: AppTheme.successColor.withValues(alpha: 0.1), textColor: AppTheme.successColor),
                  CustomTag(text: '#增肌计划', backgroundColor: AppTheme.warningColor.withValues(alpha: 0.1), textColor: AppTheme.warningColor),
                  CustomTag(text: '#健康饮食', backgroundColor: AppTheme.infoColor.withValues(alpha: 0.1), textColor: AppTheme.infoColor),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 动态列表
        _buildPostItem(
          '健身达人小王',
          '2小时前',
          '今天完成了30分钟的力量训练，感觉棒棒的！💪',
          'assets/images/workout.jpg',
          128,
          32,
          true,
        ),
        
        const SizedBox(height: 16),
        
        _buildPostItem(
          '营养师小李',
          '4小时前',
          '分享一个健康的早餐搭配：燕麦+蓝莓+坚果，营养又美味！',
          null,
          89,
          15,
          false,
        ),
        
        const SizedBox(height: 16),
        
        _buildPostItem(
          '跑步爱好者',
          '6小时前',
          '晨跑5公里完成！坚持就是胜利 🏃‍♂️',
          'assets/images/running.jpg',
          156,
          28,
          true,
        ),
      ],
    );
  }

  Widget _buildChallengeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 进行中的挑战
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '进行中的挑战',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildChallengeItem(
                  '30天健身挑战',
                  '连续30天完成每日训练',
                  '15/30天',
                  '50%',
                  AppTheme.primaryColor,
                  true,
                ),
                
                const Divider(),
                
                _buildChallengeItem(
                  '减脂挑战',
                  '30天减重5kg',
                  '8/30天',
                  '27%',
                  AppTheme.successColor,
                  true,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 推荐挑战
          Text(
            '推荐挑战',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildChallengeCard(
            '新手入门挑战',
            '适合健身新手的7天入门挑战',
            '7天',
            '100人参与',
            AppTheme.primaryColor,
          ),
          
          const SizedBox(height: 12),
          
          _buildChallengeCard(
            '腹肌训练挑战',
            '21天练出马甲线',
            '21天',
            '256人参与',
            AppTheme.warningColor,
          ),
          
          const SizedBox(height: 12),
          
          _buildChallengeCard(
            '有氧运动挑战',
            '30天有氧运动挑战',
            '30天',
            '189人参与',
            AppTheme.successColor,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 本周排行榜
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '本周排行榜',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildRankItem('健身达人小王', '1,250', '分钟', 1, AppTheme.warningColor),
                _buildRankItem('跑步爱好者', '1,180', '分钟', 2, AppTheme.textSecondaryColor),
                _buildRankItem('力量训练师', '1,120', '分钟', 3, AppTheme.errorColor),
                _buildRankItem('瑜伽达人', '980', '分钟', 4, AppTheme.textSecondaryColor),
                _buildRankItem('游泳健将', '920', '分钟', 5, AppTheme.textSecondaryColor),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 我的排名
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '我的排名',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildMyRankItem('训练时长', '15', '小时', '第128名'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMyRankItem('卡路里', '8,500', 'kcal', '第95名'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildMyRankItem('连续天数', '12', '天', '第67名'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMyRankItem('挑战完成', '3', '个', '第45名'),
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

  Widget _buildPostItem(String username, String time, String content, String? imageUrl, int likes, int comments, bool isLiked) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomAvatar(
                initials: username.substring(0, 1),
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      time,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // TODO: 实现更多操作
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (imageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? AppTheme.errorColor : AppTheme.textSecondaryColor,
                ),
                onPressed: () {
                  // TODO: 实现点赞功能
                },
              ),
              Text(
                likes.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.comment_outlined),
                onPressed: () {
                  // TODO: 实现评论功能
                },
              ),
              Text(
                comments.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // TODO: 实现分享功能
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeItem(String title, String description, String progress, String percentage, Color color, bool isActive) {
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
                  title,
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
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      progress,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: double.parse(percentage.replaceAll('%', '')) / 100,
                        backgroundColor: color.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      percentage,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          CustomTag(
            text: isActive ? '进行中' : '已完成',
            backgroundColor: color.withValues(alpha: 0.1),
            textColor: color,
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(String title, String description, String duration, String participants, Color color) {
    return CustomCard(
      onTap: () {
        // TODO: 实现挑战详情
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CustomTag(
                text: '热门',
                backgroundColor: AppTheme.errorColor.withValues(alpha: 0.1),
                textColor: AppTheme.errorColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: AppTheme.textSecondaryColor),
              const SizedBox(width: 4),
              Text(
                duration,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.people, size: 16, color: AppTheme.textSecondaryColor),
              const SizedBox(width: 4),
              Text(
                participants,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankItem(String username, String value, String unit, int rank, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CustomAvatar(
            initials: username.substring(0, 1),
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              username,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$value $unit',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyRankItem(String category, String value, String unit, String rank) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$value $unit',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          rank,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}