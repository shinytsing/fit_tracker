import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../core/theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/figma/custom_button.dart';
import '../widgets/common/limited_scroll_controller.dart';

/// 基于Figma设计的现代化社区页面
/// 实现动态发布、点赞、评论等社交功能
class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage> {
  final bool isIOS = Platform.isIOS;
  final ApiService _apiService = ApiService();
  int _selectedTabIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _apiService.init();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isIOS ? const Color(0xFFF9FAFB) : AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 头部区域
            _buildHeader(),
            
            // 标签栏
            _buildTabBar(),
            
            // 内容区域
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
                children: const [
                  FeedTab(),
                  TrendingTab(),
                  CoachesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  /// 构建头部区域
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '社区',
                style: TextStyle(
                  fontSize: isIOS ? 28 : 24,
                  fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                  color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '发现更多健身伙伴',
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
                  _buildHeaderButton(
                    icon: Icons.search_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(width: 12),
                  _buildHeaderButton(
                    icon: Icons.notifications_outlined,
                    onTap: () {},
                    hasNotification: true,
                  ),
                ],
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

  /// 构建标签栏
  Widget _buildTabBar() {
    final tabs = ['推荐', '热门', '教练'];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = _selectedTabIndex == index;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Text(
                      tab,
                  style: TextStyle(
                        fontSize: isIOS ? 16 : 14,
                        fontWeight: isSelected 
                        ? (isIOS ? FontWeight.w600 : FontWeight.w500)
                            : FontWeight.w400,
                        color: isSelected 
                        ? const Color(0xFF6366F1) 
                        : const Color(0xFF6B7280),
                  ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFF6366F1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 显示创建动态弹窗
  void _showCreatePostDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreatePostBottomSheet(),
    );
  }
}

/// 推荐动态标签页
class FeedTab extends StatelessWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LimitedListViewBuilder(
      padding: const EdgeInsets.all(16),
      itemCount: 10, // 模拟数据
      itemBuilder: (context, index) {
        return PostCard(
          post: _generateMockPost(index),
        );
      },
    );
  }

  Map<String, dynamic> _generateMockPost(int index) {
    final posts = [
      {
        'id': '1',
        'user': {
          'id': '1',
          'nickname': '健身达人',
          'avatar': 'https://via.placeholder.com/40',
          'isVerified': true,
        },
        'content': '今天完成了45分钟的力量训练！感觉状态很好，继续加油💪',
        'images': [
          'https://via.placeholder.com/300x200',
          'https://via.placeholder.com/300x200',
        ],
        'type': 'workout',
        'tags': ['力量训练', '健身打卡'],
        'location': '健身房',
        'workoutData': {
          'duration': 45,
          'calories': 350,
          'exercises': ['深蹲', '卧推', '硬拉'],
        },
        'likesCount': 12,
        'commentsCount': 5,
        'isLiked': false,
        'createdAt': '2小时前',
      },
      {
        'id': '2',
        'user': {
          'id': '2',
          'nickname': '营养师小王',
          'avatar': 'https://via.placeholder.com/40',
          'isVerified': true,
        },
        'content': '分享一个简单的减脂餐搭配，蛋白质+蔬菜+少量碳水，营养均衡又美味！',
        'images': [
          'https://via.placeholder.com/300x200',
        ],
        'type': 'nutrition',
        'tags': ['减脂餐', '营养搭配'],
        'likesCount': 28,
        'commentsCount': 12,
        'isLiked': true,
        'createdAt': '4小时前',
      },
    ];
    
    return posts[index % posts.length];
  }
}

/// 热门动态标签页
class TrendingTab extends StatelessWidget {
  const TrendingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LimitedListViewBuilder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) {
        return PostCard(
          post: _generateMockTrendingPost(index),
        );
      },
    );
  }

  Map<String, dynamic> _generateMockTrendingPost(int index) {
    final posts = [
      {
        'id': '3',
        'user': {
          'id': '3',
          'nickname': '健身教练',
          'avatar': 'https://via.placeholder.com/40',
          'isVerified': true,
        },
        'content': '🔥 热门话题：如何正确进行深蹲？这个动作你做对了吗？',
        'images': [
          'https://via.placeholder.com/300x200',
        ],
        'type': 'education',
        'tags': ['深蹲', '动作教学'],
        'likesCount': 156,
        'commentsCount': 45,
        'isLiked': false,
        'createdAt': '6小时前',
        'isTrending': true,
      },
    ];
    
    return posts[index % posts.length];
  }
}

/// 教练动态标签页
class CoachesTab extends StatelessWidget {
  const CoachesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LimitedListViewBuilder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return CoachCard(
          coach: _generateMockCoach(index),
        );
      },
    );
  }

  Map<String, dynamic> _generateMockCoach(int index) {
    final coaches = [
      {
        'id': '4',
        'user': {
          'id': '4',
          'nickname': '专业教练',
          'avatar': 'https://via.placeholder.com/40',
          'isVerified': true,
        },
        'specialty': ['力量训练', '减脂塑形'],
        'experience': 5,
        'rating': 4.8,
        'studentsCount': 120,
        'hourlyRate': 300,
        'isAvailable': true,
        'introduction': '专业的力量训练和减脂塑形教练，帮助您实现健身目标',
      },
    ];
    
    return coaches[index % coaches.length];
  }
}

/// 动态卡片组件
class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isLiked = false;
  int _likesCount = 0;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post['isLiked'] ?? false;
    _likesCount = widget.post['likesCount'] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;
    final post = widget.post;
    final user = post['user'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isIOS ? 16 : 12),
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
          // 用户信息
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(user['avatar']),
        ),
        const SizedBox(width: 12),
        Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user['nickname'],
                            style: TextStyle(
                              fontSize: isIOS ? 16 : 14,
                              fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          if (user['isVerified'] == true) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.verified,
                              size: 16,
                              color: const Color(0xFF6366F1),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        post['createdAt'],
                        style: TextStyle(
                          fontSize: isIOS ? 12 : 10,
                          color: const Color(0xFF6B7280),
          ),
        ),
      ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.more_horiz,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          
          // 内容
          if (post['content'] != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                post['content'],
                style: TextStyle(
                  fontSize: isIOS ? 16 : 14,
                  color: const Color(0xFF1F2937),
                  height: 1.5,
                ),
              ),
            ),
          
          // 图片
          if (post['images'] != null && post['images'].isNotEmpty)
            Container(
              height: 200,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: post['images'].length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 200,
                    margin: EdgeInsets.only(right: index < post['images'].length - 1 ? 8 : 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
                      image: DecorationImage(
                        image: NetworkImage(post['images'][index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          
          // 标签
          if (post['tags'] != null && post['tags'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: post['tags'].map<Widget>((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: isIOS ? 12 : 10,
                        color: const Color(0xFF6366F1),
                        fontWeight: isIOS ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          
          // 操作按钮
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _buildActionButton(
                  icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                  label: _likesCount.toString(),
                  isActive: _isLiked,
                  onTap: _toggleLike,
                ),
                const SizedBox(width: 24),
                _buildActionButton(
                  icon: Icons.comment_outlined,
                  label: post['commentsCount'].toString(),
                  onTap: () => _showComments(post['id']),
                ),
                const SizedBox(width: 24),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: '分享',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    final isIOS = Platform.isIOS;
    
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isActive 
                ? const Color(0xFFEF4444)
                : const Color(0xFF6B7280),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isIOS ? 14 : 12,
              color: isActive 
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF6B7280),
              fontWeight: isIOS ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
  }

  void _showComments(String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsBottomSheet(postId: postId),
    );
  }
}

/// 教练卡片组件
class CoachCard extends StatelessWidget {
  final Map<String, dynamic> coach;
  
  const CoachCard({super.key, required this.coach});

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;
    final user = coach['user'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isIOS ? 16 : 12),
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
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(user['avatar']),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user['nickname'],
                          style: TextStyle(
                            fontSize: isIOS ? 18 : 16,
                            fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        if (user['isVerified'] == true) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified,
                            size: 18,
                            color: const Color(0xFF6366F1),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      coach['introduction'],
                      style: TextStyle(
                        fontSize: isIOS ? 14 : 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 专业标签
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: coach['specialty'].map<Widget>((specialty) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
              ),
                child: Text(
                  specialty,
                  style: TextStyle(
                    fontSize: isIOS ? 12 : 10,
                    color: const Color(0xFF6366F1),
                    fontWeight: isIOS ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // 教练信息
          Row(
            children: [
              _buildCoachInfo(Icons.star, '${coach['rating']}'),
              const SizedBox(width: 16),
              _buildCoachInfo(Icons.people, '${coach['studentsCount']}学员'),
              const SizedBox(width: 16),
              _buildCoachInfo(Icons.access_time, '${coach['experience']}年经验'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 价格和按钮
          Row(
            children: [
            Text(
                '¥${coach['hourlyRate']}/小时',
                style: TextStyle(
                  fontSize: isIOS ? 18 : 16,
                  fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                  color: const Color(0xFFEF4444),
                ),
              ),
              const Spacer(),
              CustomButton(
                text: '预约',
                onPressed: () {},
                isIOS: isIOS,
                backgroundColor: const Color(0xFF6366F1),
                textColor: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoachInfo(IconData icon, String text) {
    final isIOS = Platform.isIOS;
    
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF6B7280),
        ),
        const SizedBox(width: 4),
        Text(
          text,
              style: TextStyle(
                fontSize: isIOS ? 12 : 10,
            color: const Color(0xFF6B7280),
            fontWeight: isIOS ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

/// 创建动态底部弹窗
class CreatePostBottomSheet extends StatefulWidget {
  const CreatePostBottomSheet({super.key});

  @override
  State<CreatePostBottomSheet> createState() => _CreatePostBottomSheetState();
}

class _CreatePostBottomSheetState extends State<CreatePostBottomSheet> {
  final TextEditingController _contentController = TextEditingController();
  final List<String> _selectedImages = [];
  String _selectedType = 'general';
  final List<String> _selectedTags = [];

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isIOS ? 20 : 16),
          topRight: Radius.circular(isIOS ? 20 : 16),
        ),
      ),
      child: Column(
        children: [
          // 头部
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                const Spacer(),
                Text(
                  '发布动态',
                  style: TextStyle(
                    fontSize: isIOS ? 18 : 16,
                fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                color: const Color(0xFF1F2937),
              ),
            ),
                const Spacer(),
                TextButton(
                  onPressed: _publishPost,
                  child: const Text(
                    '发布',
                    style: TextStyle(
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 内容区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 动态类型选择
                  _buildTypeSelector(),
                  
                  const SizedBox(height: 16),
                  
                  // 内容输入
                  TextField(
                    controller: _contentController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: '分享你的健身心得...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
                        borderSide: const BorderSide(color: Color(0xFF6366F1)),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 图片选择
                  _buildImageSelector(),
                  
                  const SizedBox(height: 16),
                  
                  // 标签选择
                  _buildTagSelector(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    final isIOS = Platform.isIOS;
    final types = [
      {'value': 'general', 'label': '日常分享'},
      {'value': 'workout', 'label': '训练打卡'},
      {'value': 'nutrition', 'label': '营养分享'},
      {'value': 'education', 'label': '知识分享'},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '动态类型',
          style: TextStyle(
            fontSize: isIOS ? 16 : 14,
            fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: types.map((type) {
            final isSelected = _selectedType == type['value'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = type['value']!;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
                ),
                child: Text(
                  type['label']!,
                  style: TextStyle(
                    fontSize: isIOS ? 14 : 12,
                    color: isSelected 
                        ? Colors.white
                        : const Color(0xFF6B7280),
                    fontWeight: isIOS ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImageSelector() {
    final isIOS = Platform.isIOS;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '添加图片',
          style: TextStyle(
            fontSize: isIOS ? 16 : 14,
            fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length + 1,
            itemBuilder: (context, index) {
              if (index == _selectedImages.length) {
                return GestureDetector(
                  onTap: _selectImages,
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Color(0xFF6B7280),
                      size: 32,
                    ),
      ),
    );
  }

              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
                  image: DecorationImage(
                    image: NetworkImage(_selectedImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImages.removeAt(index);
                          });
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
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

  Widget _buildTagSelector() {
    final isIOS = Platform.isIOS;
    final popularTags = ['健身打卡', '减脂', '增肌', '有氧', '力量训练', '瑜伽', '跑步', '游泳'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '添加标签',
          style: TextStyle(
            fontSize: isIOS ? 16 : 14,
            fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: popularTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedTags.remove(tag);
                  } else {
                    _selectedTags.add(tag);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyle(
                    fontSize: isIOS ? 12 : 10,
                    color: isSelected 
                        ? Colors.white
                        : const Color(0xFF6B7280),
                    fontWeight: isIOS ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _selectImages() {
    // TODO: 实现图片选择功能
    setState(() {
      _selectedImages.add('https://via.placeholder.com/300x200');
    });
  }

  void _publishPost() {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入动态内容')),
      );
      return;
    }
    
    // TODO: 调用API发布动态
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('动态发布成功！')),
    );
  }
}

/// 评论底部弹窗
class CommentsBottomSheet extends StatefulWidget {
  final String postId;
  
  const CommentsBottomSheet({super.key, required this.postId});

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, dynamic>> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() {
    // 模拟评论数据
    setState(() {
      _comments.addAll([
        {
          'id': '1',
          'user': {
            'id': '1',
            'nickname': '健身爱好者',
            'avatar': 'https://via.placeholder.com/32',
          },
          'content': '太棒了！我也在练这个动作',
          'likesCount': 3,
          'isLiked': false,
          'createdAt': '1小时前',
        },
        {
          'id': '2',
          'user': {
            'id': '2',
            'nickname': '新手小白',
            'avatar': 'https://via.placeholder.com/32',
          },
          'content': '请问这个动作有什么注意事项吗？',
          'likesCount': 1,
          'isLiked': true,
          'createdAt': '2小时前',
        },
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isIOS ? 20 : 16),
          topRight: Radius.circular(isIOS ? 20 : 16),
        ),
      ),
      child: Column(
        children: [
          // 头部
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  '评论',
                  style: TextStyle(
                    fontSize: isIOS ? 18 : 16,
                    fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // 评论列表
          Expanded(
            child: LimitedListViewBuilder(
              padding: const EdgeInsets.all(16),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                return CommentItem(
                  comment: _comments[index],
                );
              },
            ),
          ),
          
          // 输入框
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey[200]!,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: '写下你的评论...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
                        borderSide: const BorderSide(color: Color(0xFF6366F1)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CustomButton(
                  text: '发送',
                  onPressed: _sendComment,
                  isIOS: isIOS,
                  backgroundColor: const Color(0xFF6366F1),
                  textColor: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendComment() {
    if (_commentController.text.trim().isEmpty) return;
    
    setState(() {
      _comments.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'user': {
          'id': 'current_user',
          'nickname': '我',
          'avatar': 'https://via.placeholder.com/32',
        },
        'content': _commentController.text.trim(),
        'likesCount': 0,
        'isLiked': false,
        'createdAt': '刚刚',
      });
    });
    
    _commentController.clear();
  }
}

/// 评论项组件
class CommentItem extends StatefulWidget {
  final Map<String, dynamic> comment;
  
  const CommentItem({super.key, required this.comment});

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool _isLiked = false;
  int _likesCount = 0;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.comment['isLiked'] ?? false;
    _likesCount = widget.comment['likesCount'] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;
    final comment = widget.comment;
    final user = comment['user'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(user['avatar']),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user['nickname'],
                      style: TextStyle(
                        fontSize: isIOS ? 14 : 12,
                        fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment['createdAt'],
                      style: TextStyle(
                        fontSize: isIOS ? 12 : 10,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment['content'],
                  style: TextStyle(
                    fontSize: isIOS ? 14 : 12,
                    color: const Color(0xFF1F2937),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _toggleLike,
                      child: Row(
                        children: [
                          Icon(
                            _isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: _isLiked 
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _likesCount.toString(),
                            style: TextStyle(
                              fontSize: isIOS ? 12 : 10,
                              color: _isLiked 
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        '回复',
                        style: TextStyle(
                          fontSize: isIOS ? 12 : 10,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
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

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
  }
                  }
