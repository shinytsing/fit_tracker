import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/models.dart';
import '../../../../shared/widgets/custom_widgets.dart';
import '../providers/community_provider.dart';
import '../widgets/feed_list.dart';
import '../widgets/post_card.dart';
import '../widgets/create_post_bottom_sheet.dart';
import '../widgets/topic_tags.dart';
import '../widgets/challenge_cards.dart';
import '../widgets/user_search_bar.dart';

/// Tab2 - 社区页面
/// 包含关注流、推荐流、话题、挑战、搜索等功能
class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    
    // 监听滚动事件
    _scrollController.addListener(_onScroll);
    
    // 加载初始数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(communityProvider.notifier).loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      // 接近底部时加载更多
      ref.read(communityProvider.notifier).loadMorePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final communityState = ref.watch(communityProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          '社区',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        actions: [
          // 搜索按钮
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
          // 消息按钮
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              _showNotifications(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: '关注', icon: Icon(Icons.people)),
            Tab(text: '推荐', icon: Icon(Icons.explore)),
            Tab(text: '话题', icon: Icon(Icons.tag)),
            Tab(text: '挑战', icon: Icon(Icons.emoji_events)),
          ],
        ),
      ),
      body: Column(
        children: [
          // 顶部功能区域
          _buildTopSection(communityState),
          
          // Tab内容区域
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: 关注流
                _buildFollowingFeed(communityState),
                
                // Tab 2: 推荐流
                _buildRecommendFeed(communityState),
                
                // Tab 3: 话题
                _buildTopicsTab(communityState),
                
                // Tab 4: 挑战
                _buildChallengesTab(communityState),
              ],
            ),
          ),
        ],
      ),
      // 浮动操作按钮 - 发布动态
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreatePostBottomSheet(context);
        },
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          '发布',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  /// 构建顶部功能区域
  Widget _buildTopSection(CommunityState state) {
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
        children: [
          // 热门话题标签
          TopicTags(
            topics: state.hotTopics,
            onTopicTap: (topicId) {
              final topic = state.hotTopics.firstWhere((t) => t.id == topicId);
              _navigateToTopicPosts(topic);
            },
          ),
          
          const SizedBox(height: 12),
          
          // 快速操作按钮
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: MdiIcons.camera,
                  label: '拍照打卡',
                  onTap: () => _showCameraDialog(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  icon: MdiIcons.video,
                  label: '视频分享',
                  onTap: () => _showVideoDialog(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  icon: MdiIcons.mapMarker,
                  label: '位置分享',
                  onTap: () => _showLocationDialog(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建快速操作按钮
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建关注流Tab
  Widget _buildFollowingFeed(CommunityState state) {
    if (state.isLoading && state.followingPosts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.followingPosts.isEmpty) {
      return _buildErrorWidget(state.error!);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(communityProvider.notifier).refreshFollowingPosts();
      },
      child: FeedList(
        posts: state.followingPosts,
        isLoading: state.isLoading,
        hasMore: state.hasMoreFollowing,
        onLoadMore: () {
          ref.read(communityProvider.notifier).loadMoreFollowingPosts();
        },
        onPostTap: (post) {
          _navigateToPostDetail(post);
        },
        onLikePost: (postId) {
          ref.read(communityProvider.notifier).likePost(postId);
        },
        onCommentPost: (postId) {
          _navigateToPostComments(postId);
        },
        onSharePost: (postId) {
          _sharePost(postId);
        },
        onFollowUser: (userId) {
          ref.read(communityProvider.notifier).followUser(userId);
        },
      ),
    );
  }

  /// 构建推荐流Tab
  Widget _buildRecommendFeed(CommunityState state) {
    if (state.isLoading && state.recommendPosts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.recommendPosts.isEmpty) {
      return _buildErrorWidget(state.error!);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(communityProvider.notifier).refreshRecommendPosts();
      },
      child: FeedList(
        posts: state.recommendPosts,
        isLoading: state.isLoading,
        hasMore: state.hasMoreRecommend,
        onLoadMore: () {
          ref.read(communityProvider.notifier).loadMoreRecommendPosts();
        },
        onPostTap: (post) {
          _navigateToPostDetail(post);
        },
        onLikePost: (postId) {
          ref.read(communityProvider.notifier).likePost(postId);
        },
        onCommentPost: (postId) {
          _navigateToPostComments(postId);
        },
        onSharePost: (postId) {
          _sharePost(postId);
        },
        onFollowUser: (userId) {
          ref.read(communityProvider.notifier).followUser(userId);
        },
      ),
    );
  }

  /// 构建话题Tab
  Widget _buildTopicsTab(CommunityState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 热门话题
          _buildSectionTitle('热门话题'),
          const SizedBox(height: 12),
          _buildHotTopicsGrid(state.hotTopics),
          
          const SizedBox(height: 24),
          
          // 推荐话题
          _buildSectionTitle('推荐话题'),
          const SizedBox(height: 12),
          _buildRecommendedTopics(state.recommendedTopics),
          
          const SizedBox(height: 24),
          
          // 话题分类
          _buildSectionTitle('话题分类'),
          const SizedBox(height: 12),
          _buildTopicCategories(),
        ],
      ),
    );
  }

  /// 构建挑战Tab
  Widget _buildChallengesTab(CommunityState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 进行中的挑战
          _buildSectionTitle('进行中的挑战'),
          const SizedBox(height: 12),
          ChallengeCards(
            challenges: state.activeChallenges,
            onJoinChallenge: (challengeId) {
              _joinChallenge(challengeId);
            },
            onViewChallenge: (challengeId) {
              _navigateToChallengeDetail(challengeId);
            },
          ),
          
          const SizedBox(height: 24),
          
          // 热门挑战
          _buildSectionTitle('热门挑战'),
          const SizedBox(height: 12),
          ChallengeCards(
            challenges: state.popularChallenges,
            onJoinChallenge: (challengeId) {
              _joinChallenge(challengeId);
            },
            onViewChallenge: (challengeId) {
              _navigateToChallengeDetail(challengeId);
            },
          ),
          
          const SizedBox(height: 24),
          
          // 挑战分类
          _buildSectionTitle('挑战分类'),
          const SizedBox(height: 12),
          _buildChallengeCategories(),
        ],
      ),
    );
  }

  /// 构建章节标题
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  /// 构建热门话题网格
  Widget _buildHotTopicsGrid(List<Topic> topics) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        return _buildTopicCard(topic);
      },
    );
  }

  /// 构建话题卡片
  Widget _buildTopicCard(Topic topic) {
    return GestureDetector(
      onTap: () => _navigateToTopicPosts(topic),
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
              '#${topic.name}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${topic.postCount}条动态',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  MdiIcons.trendingUp,
                  size: 12,
                  color: Colors.red[400],
                ),
                const SizedBox(width: 4),
                Text(
                  '${topic.trend}%',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.red[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建推荐话题列表
  Widget _buildRecommendedTopics(List<Topic> topics) {
    return Column(
      children: topics.map((topic) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primary.withOpacity(0.1),
              child: Text(
                '#',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              topic.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('${topic.postCount}条动态'),
            trailing: Text(
              '${topic.trend}%',
              style: TextStyle(
                color: Colors.red[400],
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () => _navigateToTopicPosts(topic),
          ),
        );
      }).toList(),
    );
  }

  /// 构建话题分类
  Widget _buildTopicCategories() {
    final categories = [
      {'name': '健身训练', 'icon': MdiIcons.dumbbell, 'color': Colors.blue},
      {'name': '营养饮食', 'icon': MdiIcons.food, 'color': Colors.green},
      {'name': '减脂塑形', 'icon': MdiIcons.fire, 'color': Colors.orange},
      {'name': '增肌增重', 'icon': MdiIcons.trendingUp, 'color': Colors.purple},
      {'name': '瑜伽冥想', 'icon': MdiIcons.yoga, 'color': Colors.pink},
      {'name': '跑步有氧', 'icon': MdiIcons.run, 'color': Colors.red},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () => _navigateToCategoryPosts(category['name'] as String),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category['icon'] as IconData,
                  color: category['color'] as Color,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  category['name'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建挑战分类
  Widget _buildChallengeCategories() {
    final categories = [
      {'name': '30天挑战', 'icon': MdiIcons.calendar, 'color': Colors.blue},
      {'name': '力量挑战', 'icon': MdiIcons.dumbbell, 'color': Colors.red},
      {'name': '有氧挑战', 'icon': MdiIcons.run, 'color': Colors.green},
      {'name': '团队挑战', 'icon': MdiIcons.accountGroup, 'color': Colors.purple},
    ];

    return Row(
      children: categories.map((category) {
        return Expanded(
          child: GestureDetector(
            onTap: () => _navigateToChallengeCategory(category['name'] as String),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Icon(
                    category['icon'] as IconData,
                    color: category['color'] as Color,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category['name'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 构建错误组件
  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text('加载失败: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(communityProvider.notifier).loadInitialData();
            },
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  // 事件处理方法
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索'),
        content: UserSearchBar(
          onSearch: (query) {
            Navigator.pop(context);
            _navigateToSearchResults(query);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    // TODO: 显示通知列表
    Navigator.pushNamed(context, '/community/notifications');
  }

  void _showCreatePostBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreatePostBottomSheet(
        onPostCreated: (post) {
          // 刷新动态列表
          ref.read(communityProvider.notifier).refreshFollowingPosts();
        },
      ),
    );
  }

  void _showCameraDialog() {
    // TODO: 显示相机拍照界面
    Navigator.pushNamed(context, '/community/camera');
  }

  void _showVideoDialog() {
    // TODO: 显示视频录制界面
    Navigator.pushNamed(context, '/community/video');
  }

  void _showLocationDialog() {
    // TODO: 显示位置选择界面
    Navigator.pushNamed(context, '/community/location');
  }

  void _navigateToPostDetail(Post post) {
    Navigator.pushNamed(context, '/community/post-detail', arguments: post);
  }

  void _navigateToPostComments(String postId) {
    Navigator.pushNamed(context, '/community/post-comments', arguments: postId);
  }

  void _navigateToTopicPosts(Topic topic) {
    Navigator.pushNamed(context, '/community/topic-posts', arguments: topic);
  }

  void _navigateToCategoryPosts(String category) {
    Navigator.pushNamed(context, '/community/category-posts', arguments: category);
  }

  void _navigateToChallengeDetail(String challengeId) {
    Navigator.pushNamed(context, '/community/challenge-detail', arguments: challengeId);
  }

  void _navigateToChallengeCategory(String category) {
    Navigator.pushNamed(context, '/community/challenge-category', arguments: category);
  }

  void _navigateToSearchResults(String query) {
    Navigator.pushNamed(context, '/community/search-results', arguments: query);
  }

  void _joinChallenge(String challengeId) {
    ref.read(communityProvider.notifier).joinChallenge(challengeId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('挑战加入成功！')),
    );
  }

  void _sharePost(String postId) {
    // TODO: 实现分享功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('分享成功！')),
    );
  }
}