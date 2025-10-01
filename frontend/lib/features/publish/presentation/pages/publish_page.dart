import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_widgets.dart';
import '../providers/publish_provider.dart';
import '../widgets/publish_option_card.dart';
import '../widgets/recent_posts_preview.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/publish_history_list.dart';

/// Tab3 - 加号（发布入口）页面
/// 包含发布动态、打卡、训练记录、查看历史等功能
class PublishPage extends ConsumerStatefulWidget {
  const PublishPage({super.key});

  @override
  ConsumerState<PublishPage> createState() => _PublishPageState();
}

class _PublishPageState extends ConsumerState<PublishPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    
    // 加载初始数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(publishProvider.notifier).loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final publishState = ref.watch(publishProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          '发布',
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
              _showPublishSettings(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: '发布', icon: Icon(Icons.add_circle)),
            Tab(text: '历史', icon: Icon(Icons.history)),
            Tab(text: '收藏', icon: Icon(Icons.bookmark)),
          ],
        ),
      ),
      body: Column(
        children: [
          // 顶部快速操作区域
          _buildQuickActionsSection(publishState),
          
          // Tab内容区域
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: 发布选项
                _buildPublishTab(publishState),
                
                // Tab 2: 发布历史
                _buildHistoryTab(publishState),
                
                // Tab 3: 收藏内容
                _buildFavoritesTab(publishState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建快速操作区域
  Widget _buildQuickActionsSection(PublishState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 今日统计
          _buildTodayStats(state),
          
          const SizedBox(height: 16),
          
          // 快速操作网格
          QuickActionsGrid(
            onActionTap: (action) {
              _handleQuickAction(action);
            },
          ),
        ],
      ),
    );
  }

  /// 构建今日统计
  Widget _buildTodayStats(PublishState state) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: MdiIcons.camera,
            label: '今日发布',
            value: '${state.todayPostsCount}',
            color: Colors.blue,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            icon: MdiIcons.checkCircle,
            label: '今日打卡',
            value: '${state.todayCheckinsCount}',
            color: Colors.green,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            icon: MdiIcons.dumbbell,
            label: '训练记录',
            value: '${state.todayWorkoutsCount}',
            color: Colors.orange,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            icon: MdiIcons.star,
            label: '获得点赞',
            value: '${state.todayLikesReceived}',
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  /// 构建统计项
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
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
      ),
    );
  }

  /// 构建发布Tab
  Widget _buildPublishTab(PublishState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 发布选项卡片
          _buildPublishOptions(),
          
          const SizedBox(height: 24),
          
          // 最近发布预览
          RecentPostsPreview(
            recentPosts: state.recentPosts,
            onPostTap: (post) {
              _navigateToPostDetail(post);
            },
            onRepost: (post) {
              _repostContent(post);
            },
          ),
          
          const SizedBox(height: 24),
          
          // 推荐内容
          _buildRecommendedContent(state),
        ],
      ),
    );
  }

  /// 构建发布选项
  Widget _buildPublishOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '发布内容',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            PublishOptionCard(
              icon: MdiIcons.text,
              title: '文字动态',
              subtitle: '分享你的想法',
              color: Colors.blue,
              onTap: () => _navigateToCreatePost('text'),
            ),
            PublishOptionCard(
              icon: MdiIcons.camera,
              title: '拍照打卡',
              subtitle: '记录美好瞬间',
              color: Colors.green,
              onTap: () => _navigateToCreatePost('photo'),
            ),
            PublishOptionCard(
              icon: MdiIcons.video,
              title: '视频分享',
              subtitle: '分享精彩视频',
              color: Colors.red,
              onTap: () => _navigateToCreatePost('video'),
            ),
            PublishOptionCard(
              icon: MdiIcons.dumbbell,
              title: '训练记录',
              subtitle: '记录训练成果',
              color: Colors.orange,
              onTap: () => _navigateToCreatePost('workout'),
            ),
            PublishOptionCard(
              icon: MdiIcons.checkCircle,
              title: '日常打卡',
              subtitle: '记录日常生活',
              color: Colors.purple,
              onTap: () => _navigateToCreatePost('checkin'),
            ),
            PublishOptionCard(
              icon: MdiIcons.food,
              title: '营养记录',
              subtitle: '记录饮食营养',
              color: Colors.teal,
              onTap: () => _navigateToCreatePost('nutrition'),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建推荐内容
  Widget _buildRecommendedContent(PublishState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '推荐内容',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                _refreshRecommendedContent();
              },
              child: const Text('刷新'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 推荐话题
        _buildRecommendedTopics(state.recommendedTopics),
        
        const SizedBox(height: 16),
        
        // 推荐挑战
        _buildRecommendedChallenges(state.recommendedChallenges),
      ],
    );
  }

  /// 构建推荐话题
  Widget _buildRecommendedTopics(List<Topic> topics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '热门话题',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => _navigateToTopicPosts(topic),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                    ),
                    child: Text(
                      '#${topic.name}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 构建推荐挑战
  Widget _buildRecommendedChallenges(List<Challenge> challenges) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '推荐挑战',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              final challenge = challenges[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => _navigateToChallengeDetail(challenge),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          challenge.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              MdiIcons.accountGroup,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${challenge.currentParticipants}人参与',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                challenge.difficulty,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 构建历史Tab
  Widget _buildHistoryTab(PublishState state) {
    return PublishHistoryList(
      historyPosts: state.historyPosts,
      isLoading: state.isLoading,
      onLoadMore: () {
        ref.read(publishProvider.notifier).loadMoreHistory();
      },
      onPostTap: (post) {
        _navigateToPostDetail(post);
      },
      onRepost: (post) {
        _repostContent(post);
      },
      onDelete: (post) {
        _deletePost(post);
      },
    );
  }

  /// 构建收藏Tab
  Widget _buildFavoritesTab(PublishState state) {
    return PublishHistoryList(
      historyPosts: state.favoritePosts,
      isLoading: state.isLoading,
      onLoadMore: () {
        ref.read(publishProvider.notifier).loadMoreFavorites();
      },
      onPostTap: (post) {
        _navigateToPostDetail(post);
      },
      onRepost: (post) {
        _repostContent(post);
      },
      onDelete: (post) {
        _removeFavorite(post);
      },
    );
  }

  // 事件处理方法
  void _handleQuickAction(String action) {
    switch (action) {
      case 'camera':
        _navigateToCreatePost('photo');
        break;
      case 'video':
        _navigateToCreatePost('video');
        break;
      case 'workout':
        _navigateToCreatePost('workout');
        break;
      case 'checkin':
        _navigateToCreatePost('checkin');
        break;
    }
  }

  void _navigateToCreatePost(String type) {
    Navigator.pushNamed(context, '/publish/create', arguments: type);
  }

  void _navigateToPostDetail(Post post) {
    Navigator.pushNamed(context, '/community/post-detail', arguments: post);
  }

  void _navigateToTopicPosts(Topic topic) {
    Navigator.pushNamed(context, '/community/topic-posts', arguments: topic);
  }

  void _navigateToChallengeDetail(Challenge challenge) {
    Navigator.pushNamed(context, '/community/challenge-detail', arguments: challenge);
  }

  void _repostContent(Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('转发内容'),
        content: Text('确定要转发 "${post.content}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实现转发功能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('转发成功！')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _deletePost(Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除动态'),
        content: const Text('确定要删除这条动态吗？删除后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(publishProvider.notifier).deletePost(post.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('删除成功！')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _removeFavorite(Post post) {
    ref.read(publishProvider.notifier).removeFavorite(post.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已取消收藏')),
    );
  }

  void _refreshRecommendedContent() {
    ref.read(publishProvider.notifier).refreshRecommendedContent();
  }

  void _showPublishSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('发布提醒'),
              trailing: Switch(value: true, onChanged: (value) {}),
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('自动添加位置'),
              trailing: Switch(value: false, onChanged: (value) {}),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('默认隐私设置'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                _showPrivacySettings();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacySettings() {
    // TODO: 显示隐私设置页面
    Navigator.pushNamed(context, '/publish/privacy-settings');
  }
}
