import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/models.dart';
import '../providers/community_provider.dart';
import '../widgets/post_card.dart';

class FeedList extends ConsumerWidget {
  final List<Post>? posts;
  final String? filter;
  final String? topicId;
  final bool? isLoading;
  final bool? hasMore;
  final VoidCallback? onLoadMore;
  final Function(Post)? onPostTap;
  final Function(String)? onLikePost;
  final Function(String)? onCommentPost;
  final Function(String)? onSharePost;
  final Function(String)? onFollowUser;
  
  const FeedList({
    super.key,
    this.posts,
    this.filter,
    this.topicId,
    this.isLoading,
    this.hasMore,
    this.onLoadMore,
    this.onPostTap,
    this.onLikePost,
    this.onCommentPost,
    this.onSharePost,
    this.onFollowUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsToShow = posts ?? ref.watch(communityProvider).posts;
    
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(communityProvider.notifier).refreshPosts();
      },
      child: _buildFeedContent(context, ref, postsToShow),
    );
  }

  Widget _buildFeedContent(BuildContext context, WidgetRef ref, List<Post> posts) {
    if (posts.isEmpty) {
      return _buildEmptyState(context);
    }
    
    final filteredPosts = _filterPosts(posts, filter, topicId);
    
    return ListView.builder(
      itemCount: filteredPosts.length,
      itemBuilder: (context, index) {
        final post = filteredPosts[index];
        return PostCard(
          post: post,
          onLike: (postId) => _handleLike(ref, post),
          onComment: (postId) => _handleComment(context, post),
          onShare: (postId) => _handleShare(context, post),
          onFollow: (userId) => _handleFollow(ref, post),
          onTap: () => _handlePostTap(context, post),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.feed_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无动态',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '快来发布第一条动态吧！',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: 导航到发布页面
            },
            icon: const Icon(Icons.add),
            label: const Text('发布动态'),
          ),
        ],
      ),
    );
  }

  List<Post> _filterPosts(List<Post> posts, String? filter, String? topicId) {
    List<Post> filtered = posts;
    
    // 按话题过滤
    if (topicId != null) {
      filtered = filtered.where((post) => 
          post.topics?.any((topic) => topic.id == topicId) ?? false
      ).toList();
    }
    
    // 按类型过滤
    if (filter != null) {
      switch (filter) {
        case 'following':
          filtered = filtered.where((post) => post.isFollowing).toList();
          break;
        case 'recommended':
          filtered = filtered.where((post) => post.isFeatured).toList();
          break;
        case 'workout':
          filtered = filtered.where((post) => 
              post.type == 'workout' || post.workoutData != null
          ).toList();
          break;
        case 'checkin':
          filtered = filtered.where((post) => 
              post.type == 'checkin' || post.checkInData != null
          ).toList();
          break;
      }
    }
    
    return filtered;
  }

  void _handleLike(WidgetRef ref, Post post) {
    ref.read(communityProvider.notifier).toggleLike(post.id);
  }

  void _handleComment(BuildContext context, Post post) {
    // TODO: 导航到评论页面
    Navigator.pushNamed(
      context,
      '/community/post-detail',
      arguments: {'postId': post.id, 'showComments': true},
    );
  }

  void _handleShare(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildShareBottomSheet(context, post),
    );
  }

  void _handleFollow(WidgetRef ref, Post post) {
    if (post.authorId != null) {
      ref.read(communityProvider.notifier).toggleFollow(post.authorId!);
    }
  }

  void _handlePostTap(BuildContext context, Post post) {
    Navigator.pushNamed(
      context,
      '/community/post-detail',
      arguments: {'postId': post.id},
    );
  }

  Widget _buildShareBottomSheet(BuildContext context, Post post) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '分享动态',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShareOption(
                context,
                '微信',
                Icons.wechat,
                Colors.green,
                () => _shareToWechat(post),
              ),
              _buildShareOption(
                context,
                '微博',
                Icons.share,
                Colors.orange,
                () => _shareToWeibo(post),
              ),
              _buildShareOption(
                context,
                '复制链接',
                Icons.link,
                Colors.blue,
                () => _copyLink(post),
              ),
              _buildShareOption(
                context,
                '保存图片',
                Icons.save_alt,
                Colors.purple,
                () => _saveImage(post),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _shareToWechat(Post post) {
    // TODO: 实现微信分享
  }

  void _shareToWeibo(Post post) {
    // TODO: 实现微博分享
  }

  void _copyLink(Post post) {
    // TODO: 复制链接到剪贴板
  }

  void _saveImage(Post post) {
    // TODO: 保存图片到相册
  }
}
