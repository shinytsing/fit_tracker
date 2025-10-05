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
/// 按照功能重排表实现：
/// - 动态流：关注流、推荐流、热门流
/// - 社交互动：点赞、评论、转发、收藏
/// - 用户关系：关注/取关、粉丝系统
/// - 话题系统：热门话题、标签分类
/// - 教练专区（扩展点）：教练主页/专栏、训练分享、经验文章、在线课程展示
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
    _tabController = TabController(length: 6, vsync: this); // 6个Tab，包含找搭子
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
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // 头部区域 - 完全按照 Figma 设计
            _buildHeader(),
            
            // Tab 切换器
            _buildTabSelector(),
            
            // 内容区域
            Expanded(
              child: IndexedStack(
                index: _currentTabIndex,
                children: [
                  _buildFollowingTab(communityState),
                  _buildRecommendedTab(communityState),
                  _buildTrendingTab(communityState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建头部区域 - 完全按照 Figma 设计
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '社区',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
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
              // 筛选按钮
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.inputBackground,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.tune,
                  color: AppTheme.textSecondary,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建 Tab 切换器 - 完全按照 Figma 设计
  Widget _buildTabSelector() {
    final tabs = [
      {'id': 'following', 'label': '关注'},
      {'id': 'recommended', 'label': '推荐'},
      {'id': 'trending', 'label': '热门'},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTheme.inputBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = _currentTabIndex == index;
            
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _currentTabIndex = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.card : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    boxShadow: isSelected ? AppTheme.cardShadow : null,
                  ),
                  child: Text(
                    tab['label']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 构建关注 Tab
  Widget _buildFollowingTab(CommunityState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 快速操作按钮
          _buildQuickActions(),
          
          const SizedBox(height: 24),
          
          // 挑战卡片
          _buildChallengeCards(),
          
          const SizedBox(height: 24),
          
          // 最新动态
          _buildLatestFeed(state),
        ],
      ),
    );
  }

  /// 构建推荐 Tab
  Widget _buildRecommendedTab(CommunityState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 推荐内容
          _buildRecommendedContent(state),
        ],
      ),
    );
  }

  /// 构建热门 Tab
  Widget _buildTrendingTab(CommunityState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 热门内容
          _buildTrendingContent(state),
        ],
      ),
    );
  }

  /// 构建快速操作按钮 - 完全按照 Figma 设计
  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.trending_up, 'label': '挑战', 'color': const Color(0xFF3B82F6)},
      {'icon': Icons.search, 'label': '找搭子', 'color': const Color(0xFF10B981)},
      {'icon': Icons.tune, 'label': '健身房', 'color': const Color(0xFF8B5CF6)},
    ];

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (action['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    action['icon'] as IconData,
                    color: action['color'] as Color,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  action['label'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 构建挑战卡片
  Widget _buildChallengeCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '热门挑战',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 150,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 挑战图片
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.fitness_center,
                          size: 40,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                    // 挑战信息
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '挑战${index + 1}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '30天健身挑战',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '参与',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6366F1),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 构建最新动态
  Widget _buildLatestFeed(CommunityState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '最新动态',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        
        if (state.followingPosts.isEmpty)
          _buildEmptyFeed()
        else
          ...state.followingPosts.take(3).map((post) => _buildFeedItem(post)),
      ],
    );
  }

  /// 构建空动态状态
  Widget _buildEmptyFeed() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
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
              Icons.people,
              color: Color(0xFF9CA3AF),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无动态',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '关注更多用户查看他们的动态',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建动态项
  Widget _buildFeedItem(dynamic post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
                child: const Icon(
                  Icons.person,
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
                      post.userName ?? '用户',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      _formatTime(post.createdAt ?? DateTime.now()),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 动态内容
          Text(
            post.content ?? '分享了一个动态',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          // 互动按钮
          Row(
            children: [
              _buildActionButton(Icons.favorite_border, '${post.likes ?? 0}'),
              const SizedBox(width: 16),
              _buildActionButton(Icons.chat_bubble_outline, '${post.comments ?? 0}'),
              const SizedBox(width: 16),
              _buildActionButton(Icons.share, '分享'),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF6B7280),
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  /// 构建推荐内容
  Widget _buildRecommendedContent(CommunityState state) {
    return Column(
      children: [
        const Text(
          '推荐内容',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        // TODO: 实现推荐内容
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: const Center(
            child: Text(
              '推荐内容开发中...',
              style: TextStyle(
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建热门内容
  Widget _buildTrendingContent(CommunityState state) {
    return Column(
      children: [
        const Text(
          '热门内容',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        // TODO: 实现热门内容
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: const Center(
            child: Text(
              '热门内容开发中...',
              style: TextStyle(
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 格式化时间
  String _formatTime(DateTime dateTime) {
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

  /// 构建热门流Tab - 热门话题与趋势
  Widget _buildTrendingFeed(CommunityState state) {
    if (state.isLoading && state.trendingPosts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.trendingPosts.isEmpty) {
      return _buildErrorWidget(state.error!);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(communityProvider.notifier).refreshTrendingPosts();
      },
      child: FeedList(
        posts: state.trendingPosts,
        isLoading: state.isLoading,
        hasMore: state.hasMoreTrending,
        onLoadMore: () {
          ref.read(communityProvider.notifier).loadMoreTrendingPosts();
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

  /// 构建教练专区Tab - 教练主页/专栏、训练分享、经验文章、在线课程展示
  Widget _buildCoachZoneTab(CommunityState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 推荐教练
          _buildSectionTitle('推荐教练'),
          const SizedBox(height: 12),
          _buildRecommendedCoaches(),
          
          const SizedBox(height: 24),
          
          // 训练分享
          _buildSectionTitle('训练分享'),
          const SizedBox(height: 12),
          _buildTrainingShares(),
          
          const SizedBox(height: 24),
          
          // 经验文章
          _buildSectionTitle('经验文章'),
          const SizedBox(height: 12),
          _buildExperienceArticles(),
          
          const SizedBox(height: 24),
          
          // 在线课程
          _buildSectionTitle('在线课程'),
          const SizedBox(height: 12),
          _buildOnlineCourses(),
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

  /// 构建推荐教练
  Widget _buildRecommendedCoaches() {
    // TODO: 实现推荐教练列表
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  child: Icon(
                    MdiIcons.account,
                    color: AppTheme.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '教练${index + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 构建训练分享
  Widget _buildTrainingShares() {
    // TODO: 实现训练分享列表
    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: const Center(
                    child: Icon(Icons.fitness_center, size: 40, color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '训练分享${index + 1}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '专业训练指导',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 构建经验文章
  Widget _buildExperienceArticles() {
    // TODO: 实现经验文章列表
    return Column(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.article, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '健身经验文章${index + 1}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '专业健身指导与经验分享',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// 构建在线课程
  Widget _buildOnlineCourses() {
    // TODO: 实现在线课程列表
    return Column(
      children: List.generate(2, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.play_circle_outline, color: Colors.grey, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '在线课程${index + 1}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '专业健身课程指导',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: 实现课程报名
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('报名', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        );
      }),
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

  /// 构建找搭子Tab
  Widget _buildGymBuddyTab(CommunityState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 搜索健身房
          _buildGymSearchSection(),
          
          const SizedBox(height: 20),
          
          // 附近健身房
          _buildSectionTitle('附近健身房'),
          const SizedBox(height: 12),
          _buildNearbyGyms(),
          
          const SizedBox(height: 20),
          
          // 热门健身房
          _buildSectionTitle('热门健身房'),
          const SizedBox(height: 12),
          _buildPopularGyms(),
          
          const SizedBox(height: 20),
          
          // 我的搭子
          _buildSectionTitle('我的搭子'),
          const SizedBox(height: 12),
          _buildMyBuddies(),
        ],
      ),
    );
  }

  /// 构建健身房搜索区域
  Widget _buildGymSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          // 搜索框
          TextField(
            decoration: InputDecoration(
              hintText: '搜索健身房...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            onSubmitted: (value) {
              _navigateToGymSearch(value);
            },
          ),
          
          const SizedBox(height: 12),
          
          // 快速筛选按钮
          Row(
            children: [
              Expanded(
                child: _buildFilterButton(
                  icon: Icons.location_on,
                  label: '附近',
                  onTap: () => _showNearbyGyms(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterButton(
                  icon: Icons.star,
                  label: '评分',
                  onTap: () => _showTopRatedGyms(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterButton(
                  icon: Icons.group,
                  label: '搭子多',
                  onTap: () => _showPopularGyms(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建筛选按钮
  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primary, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建附近健身房
  Widget _buildNearbyGyms() {
    // TODO: 从API获取附近健身房数据
    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            child: _buildGymCard(
              name: '超级健身房${index + 1}',
              address: '距离${(index + 1) * 500}米',
              rating: 4.5 - (index * 0.1),
              buddyCount: 8 + index,
              discount: '3人9折',
            ),
          );
        },
      ),
    );
  }

  /// 构建热门健身房
  Widget _buildPopularGyms() {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: _buildGymListItem(
            name: '热门健身房${index + 1}',
            address: '北京市朝阳区',
            rating: 4.8 - (index * 0.1),
            buddyCount: 15 + index * 2,
            discount: '5人85折',
            isPopular: true,
          ),
        );
      }),
    );
  }

  /// 构建我的搭子
  Widget _buildMyBuddies() {
    return Column(
      children: List.generate(2, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                child: Text(
                  '搭${index + 1}',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '搭子组${index + 1}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '超级健身房 - 增肌训练',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '明天 19:00-21:00',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    '${3 + index}人',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '已组队',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  /// 构建健身房卡片
  Widget _buildGymCard({
    required String name,
    required String address,
    required double rating,
    required int buddyCount,
    required String discount,
  }) {
    return GestureDetector(
      onTap: () => _navigateToGymDetail(name),
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
            // 健身房图片
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.fitness_center, size: 40, color: Colors.grey),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // 健身房名称
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 4),
            
            // 地址
            Text(
              address,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            const Spacer(),
            
            // 底部信息
            Row(
              children: [
                Icon(Icons.star, size: 12, color: Colors.amber[600]),
                const SizedBox(width: 2),
                Text(
                  rating.toString(),
                  style: const TextStyle(fontSize: 12),
                ),
                const Spacer(),
                Text(
                  '$buddyCount人',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // 折扣信息
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(
                discount,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建健身房列表项
  Widget _buildGymListItem({
    required String name,
    required String address,
    required double rating,
    required int buddyCount,
    required String discount,
    bool isPopular = false,
  }) {
    return GestureDetector(
      onTap: () => _navigateToGymDetail(name),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            // 健身房图片
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.fitness_center, size: 30, color: Colors.grey),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // 健身房信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Text(
                            '热门',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber[600]),
                      const SizedBox(width: 2),
                      Text(
                        rating.toString(),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.group, size: 14, color: AppTheme.primary),
                      const SizedBox(width: 2),
                      Text(
                        '$buddyCount人搭子',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 折扣和加入按钮
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    discount,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _joinGymBuddy(name),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  child: const Text(
                    '加入',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 找搭子相关事件处理
  void _navigateToGymSearch(String query) {
    Navigator.pushNamed(
      context,
      '/community/gym-search',
      arguments: {'query': query},
    );
  }

  void _showNearbyGyms() {
    Navigator.pushNamed(context, '/community/nearby-gyms');
  }

  void _showTopRatedGyms() {
    Navigator.pushNamed(context, '/community/top-rated-gyms');
  }

  void _showPopularGyms() {
    Navigator.pushNamed(context, '/community/popular-gyms');
  }

  void _navigateToGymDetail(String gymName) {
    Navigator.pushNamed(
      context,
      '/community/gym-detail',
      arguments: {'name': gymName},
    );
  }

  void _joinGymBuddy(String gymName) {
    Navigator.pushNamed(
      context,
      '/community/join-gym-buddy',
      arguments: {'name': gymName},
    );
  }
}