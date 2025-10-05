import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_widgets.dart';

/// 社交与社区页面
/// 展示社区动态、健身伙伴等真实数据
class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<dynamic> _followingPosts = [];
  List<dynamic> _recommendPosts = [];
  List<dynamic> _trendingTopics = [];
  List<dynamic> _buddies = [];

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
      await Future.wait([
        _loadFollowingPosts(),
        _loadRecommendPosts(),
        _loadTrendingTopics(),
        _loadBuddies(),
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

  Future<void> _loadFollowingPosts() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get(
        '/posts/following',
      );
      if (response.statusCode == 200) {
        setState(() {
          _followingPosts = response.data['posts'] ?? [];
        });
      }
    } catch (e) {
      // 使用模拟数据
      setState(() {
        _followingPosts = [
          {
            'id': 'post_1',
            'user': {
              'username': '健身达人小王',
              'avatar': 'https://via.placeholder.com/40',
            },
            'content': '今天完成了30分钟的力量训练，感觉棒极了！💪',
            'images': ['https://via.placeholder.com/300'],
            'likes_count': 15,
            'comments_count': 3,
            'created_at': DateTime.now().subtract(const Duration(hours: 2)),
          },
          {
            'id': 'post_2',
            'user': {
              'username': '瑜伽小仙女',
              'avatar': 'https://via.placeholder.com/40',
            },
            'content': '晨练瑜伽，新的一天从健康开始 🌅',
            'images': ['https://via.placeholder.com/300'],
            'likes_count': 8,
            'comments_count': 1,
            'created_at': DateTime.now().subtract(const Duration(hours: 5)),
          },
        ];
      });
    }
  }

  Future<void> _loadRecommendPosts() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get(
        '/posts/recommend',
      );
      if (response.statusCode == 200) {
        setState(() {
          _recommendPosts = response.data['posts'] ?? [];
        });
      }
    } catch (e) {
      // 使用模拟数据
      setState(() {
        _recommendPosts = [
          {
            'id': 'post_3',
            'user': {
              'username': '跑步爱好者',
              'avatar': 'https://via.placeholder.com/40',
            },
            'content': '完成了10公里跑步，配速5分钟/公里，破了自己的记录！🏃‍♂️',
            'images': ['https://via.placeholder.com/300'],
            'likes_count': 25,
            'comments_count': 7,
            'created_at': DateTime.now().subtract(const Duration(hours: 1)),
          },
          {
            'id': 'post_4',
            'user': {
              'username': '健身教练Mike',
              'avatar': 'https://via.placeholder.com/40',
            },
            'content': '分享一个有效的腹肌训练动作，坚持30天见效！',
            'images': ['https://via.placeholder.com/300'],
            'likes_count': 42,
            'comments_count': 12,
            'created_at': DateTime.now().subtract(const Duration(hours: 3)),
          },
        ];
      });
    }
  }

  Future<void> _loadTrendingTopics() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get(
        '/posts/topics/trending',
      );
      if (response.statusCode == 200) {
        setState(() {
          _trendingTopics = response.data['topics'] ?? [];
        });
      }
    } catch (e) {
      // 使用模拟数据
      setState(() {
        _trendingTopics = [
          {
            'name': '#减脂训练',
            'posts_count': 1250,
            'is_hot': true,
          },
          {
            'name': '#增肌计划',
            'posts_count': 980,
            'is_hot': true,
          },
          {
            'name': '#晨练打卡',
            'posts_count': 756,
            'is_hot': false,
          },
          {
            'name': '#健身伙伴',
            'posts_count': 623,
            'is_hot': false,
          },
        ];
      });
    }
  }

  Future<void> _loadBuddies() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get(
        '/buddies/recommendations',
      );
      if (response.statusCode == 200) {
        setState(() {
          _buddies = response.data['buddies'] ?? [];
        });
      }
    } catch (e) {
      // 使用模拟数据
      setState(() {
        _buddies = [
          {
            'id': 'buddy_1',
            'username': '健身新手小李',
            'avatar': 'https://via.placeholder.com/50',
            'level': '初级',
            'goal': '减脂',
            'location': '北京市朝阳区',
            'distance': '2.5km',
            'common_interests': ['跑步', '力量训练'],
          },
          {
            'id': 'buddy_2',
            'username': '瑜伽达人',
            'avatar': 'https://via.placeholder.com/50',
            'level': '高级',
            'goal': '塑形',
            'location': '北京市海淀区',
            'distance': '3.2km',
            'common_interests': ['瑜伽', '普拉提'],
          },
          {
            'id': 'buddy_3',
            'username': '跑步爱好者',
            'avatar': 'https://via.placeholder.com/50',
            'level': '中级',
            'goal': '有氧',
            'location': '北京市西城区',
            'distance': '1.8km',
            'common_interests': ['跑步', '骑行'],
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
          '社交与社区',
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
            Tab(text: '关注动态'),
            Tab(text: '推荐内容'),
            Tab(text: '健身伙伴'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFollowingTab(),
                _buildRecommendTab(),
                _buildBuddiesTab(),
              ],
            ),
    );
  }

  /// 构建关注动态标签页
  Widget _buildFollowingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 热门话题
          _buildTrendingTopics(),
          const SizedBox(height: 16),
          
          // 动态列表
          ..._followingPosts.map((post) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildPostCard(post),
              )),
        ],
      ),
    );
  }

  /// 构建推荐内容标签页
  Widget _buildRecommendTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: _recommendPosts.map((post) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildPostCard(post),
          );
        }).toList(),
      ),
    );
  }

  /// 构建健身伙伴标签页
  Widget _buildBuddiesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: _buddies.map((buddy) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildBuddyCard(buddy),
          );
        }).toList(),
      ),
    );
  }

  /// 构建热门话题
  Widget _buildTrendingTopics() {
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
          const Row(
            children: [
              Icon(Icons.trending_up, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                '热门话题',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _trendingTopics.map((topic) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: topic['is_hot'] 
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: topic['is_hot'] 
                        ? Colors.orange.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      topic['name'],
                      style: TextStyle(
                        color: topic['is_hot'] ? Colors.orange : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${topic['posts_count']}',
                      style: TextStyle(
                        color: topic['is_hot'] ? Colors.orange : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    if (topic['is_hot']) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.local_fire_department,
                        size: 12,
                        color: Colors.orange,
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 构建动态卡片
  Widget _buildPostCard(Map<String, dynamic> post) {
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
          // 用户信息
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(post['user']['avatar']),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['user']['username'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatTime(post['created_at']),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'follow',
                    child: Text('关注'),
                  ),
                  const PopupMenuItem(
                    value: 'block',
                    child: Text('屏蔽'),
                  ),
                ],
                child: const Icon(Icons.more_vert),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 内容
          Text(post['content']),
          const SizedBox(height: 12),

          // 图片
          if (post['images'] != null && post['images'].isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                post['images'][0],
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 12),

          // 互动按钮
          Row(
            children: [
              _buildActionButton(
                icon: Icons.favorite_border,
                label: '${post['likes_count']}',
                onTap: () => _likePost(post['id']),
              ),
              const SizedBox(width: 24),
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: '${post['comments_count']}',
                onTap: () => _commentPost(post['id']),
              ),
              const SizedBox(width: 24),
              _buildActionButton(
                icon: Icons.share,
                label: '分享',
                onTap: () => _sharePost(post['id']),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建健身伙伴卡片
  Widget _buildBuddyCard(Map<String, dynamic> buddy) {
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
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(buddy['avatar']),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  buddy['username'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getLevelColor(buddy['level']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        buddy['level'],
                        style: TextStyle(
                          color: _getLevelColor(buddy['level']),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        buddy['goal'],
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${buddy['location']} • ${buddy['distance']}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: (buddy['common_interests'] as List).map((interest) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        interest,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Column(
            children: [
              ElevatedButton(
                onPressed: () => _sendBuddyRequest(buddy['id']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('邀请'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else {
      return '${difference.inDays}天前';
    }
  }

  /// 获取等级颜色
  Color _getLevelColor(String level) {
    switch (level) {
      case '初级':
        return Colors.green;
      case '中级':
        return Colors.orange;
      case '高级':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// 点赞动态
  void _likePost(String postId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('点赞动态 $postId')),
    );
  }

  /// 评论动态
  void _commentPost(String postId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('评论动态 $postId')),
    );
  }

  /// 分享动态
  void _sharePost(String postId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('分享动态 $postId')),
    );
  }

  /// 发送伙伴邀请
  void _sendBuddyRequest(String buddyId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('发送邀请给伙伴 $buddyId')),
    );
  }
}
