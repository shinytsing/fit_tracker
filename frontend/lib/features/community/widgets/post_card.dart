import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/models/models.dart';
import '../../core/providers/community_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/custom_widgets.dart';

/// 动态卡片组件
class PostCard extends ConsumerWidget {
  final Post post;
  final VoidCallback? onTap;
  final VoidCallback? onUserTap;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communityNotifier = ref.read(communityNotifierProvider.notifier);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 用户信息
              _buildUserHeader(context),
              const SizedBox(height: 12),
              
              // 动态内容
              _buildContent(context),
              
              // 图片/视频
              if (post.imageList.isNotEmpty || post.videoUrl != null)
                _buildMedia(context),
              
              // 标签
              if (post.tagList.isNotEmpty)
                _buildTags(context),
              
              const SizedBox(height: 12),
              
              // 互动按钮
              _buildActionButtons(context, communityNotifier),
              
              // 统计信息
              _buildStats(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return Row(
      children: [
        // 头像
        GestureDetector(
          onTap: onUserTap,
          child: CircleAvatar(
            radius: 20,
            backgroundImage: post.user?.avatar != null
                ? CachedNetworkImageProvider(post.user!.avatar!)
                : null,
            child: post.user?.avatar == null
                ? Text(
                    post.user?.username.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 12),
        
        // 用户信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    post.user?.username ?? '未知用户',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (post.user?.isVerified == true) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.verified,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ],
              ),
              Text(
                _formatTime(post.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        
        // 更多按钮
        IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: () {
            _showMoreOptions(context);
          },
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Text(
      post.content,
      style: const TextStyle(
        fontSize: 16,
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMedia(BuildContext context) {
    if (post.videoUrl != null) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
        ),
        child: Stack(
          children: [
            // 视频缩略图或播放器
            Center(
              child: Icon(
                Icons.play_circle_outline,
                size: 60,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            // 播放按钮
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    if (post.imageList.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        child: _buildImageGrid(),
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildImageGrid() {
    final images = post.imageList;
    
    if (images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: images[0],
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 200,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: 200,
            color: Colors.grey[200],
            child: const Icon(Icons.error),
          ),
        ),
      );
    }
    
    if (images.length == 2) {
      return Row(
        children: images.map((image) => Expanded(
          child: Container(
            height: 150,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: image,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
          ),
        )).toList(),
      );
    }
    
    // 3张或更多图片
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: images.length > 9 ? 9 : images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        final isLast = index == 8 && images.length > 9;
        
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: image,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                ),
              ),
              if (isLast)
                Container(
                  color: Colors.black.withOpacity(0.6),
                  child: Center(
                    child: Text(
                      '+${images.length - 9}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTags(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: post.tagList.map((tag) => CustomTag(
          text: '#$tag',
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          textColor: AppTheme.primaryColor,
        )).toList(),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, CommunityNotifier notifier) {
    return Row(
      children: [
        // 点赞按钮
        _buildActionButton(
          icon: Icons.favorite_border,
          activeIcon: Icons.favorite,
          label: post.likesCount.toString(),
          onTap: () => notifier.likePost(post.id),
          isActive: false, // TODO: 检查是否已点赞
        ),
        const SizedBox(width: 24),
        
        // 评论按钮
        _buildActionButton(
          icon: Icons.comment_outlined,
          label: post.commentsCount.toString(),
          onTap: () {
            // TODO: 打开评论页面
          },
        ),
        const SizedBox(width: 24),
        
        // 收藏按钮
        _buildActionButton(
          icon: Icons.bookmark_border,
          activeIcon: Icons.bookmark,
          onTap: () => notifier.favoritePost(post.id),
          isActive: false, // TODO: 检查是否已收藏
        ),
        const SizedBox(width: 24),
        
        // 分享按钮
        _buildActionButton(
          icon: Icons.share,
          onTap: () {
            // TODO: 分享功能
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    IconData? activeIcon,
    String? label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? (activeIcon ?? icon) : icon,
              size: 20,
              color: isActive ? AppTheme.primaryColor : Colors.grey[600],
            ),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          if (post.viewCount > 0) ...[
            Icon(
              Icons.visibility,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              '${post.viewCount}次浏览',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
          if (post.location != null) ...[
            const SizedBox(width: 16),
            Icon(
              Icons.location_on,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              post.location!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return DateFormat('MM-dd HH:mm').format(time);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('举报'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 举报功能
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('屏蔽用户'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 屏蔽功能
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('复制链接'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 复制链接功能
              },
            ),
          ],
        ),
      ),
    );
  }
}
