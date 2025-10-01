import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/models.dart';
import '../providers/community_provider.dart';

/// 动态卡片组件
/// 显示用户发布的动态，支持点赞、评论、分享、关注等操作
class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;
  final Function(String postId)? onLike;
  final Function(String postId)? onComment;
  final Function(String postId)? onShare;
  final Function(String userId)? onFollow;
  final Function(String userId)? onUserTap;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onFollow,
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息头部
          _buildUserHeader(),
          
          // 动态内容
          _buildPostContent(),
          
          // 话题标签
          if ((post.topics?.isNotEmpty ?? false)) _buildTopicTags(),
          
          // 互动操作栏
          _buildInteractionBar(),
          
          // 评论预览
          if ((post.comments?.isNotEmpty ?? false)) _buildCommentsPreview(),
        ],
      ),
    );
  }

  /// 构建用户信息头部
  Widget _buildUserHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 用户头像
          GestureDetector(
            onTap: () => onUserTap?.call(post.userId),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: post.userAvatar != null 
                  ? NetworkImage(post.userAvatar!) 
                  : null,
              child: post.userAvatar == null 
                  ? Text(
                      (post.userName?.isNotEmpty ?? false) ? post.userName![0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: Colors.white,
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
                GestureDetector(
                  onTap: () => onUserTap?.call(post.userId),
                  child: Text(
                    post.userName ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      _formatTimeAgo(post.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (post.location != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        MdiIcons.mapMarker,
                        size: 12,
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
              ],
            ),
          ),
          
          // 关注按钮
          if (post.userId != 'current_user') // 不是当前用户
            _buildFollowButton(),
          
          // 更多操作
          PopupMenuButton<String>(
            onSelected: (value) {
              _handleMenuAction(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.report, size: 16),
                    SizedBox(width: 8),
                    Text('举报'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block, size: 16),
                    SizedBox(width: 8),
                    Text('屏蔽'),
                  ],
                ),
              ),
            ],
            child: Icon(
              Icons.more_vert,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建关注按钮
  Widget _buildFollowButton() {
    return GestureDetector(
      onTap: () => onFollow?.call(post.userId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: post.isFollowing ? Colors.grey[200] : AppTheme.primary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: post.isFollowing ? Colors.grey[400]! : AppTheme.primary,
          ),
        ),
        child: Text(
          post.isFollowing ? '已关注' : '关注',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: post.isFollowing ? Colors.grey[600] : Colors.white,
          ),
        ),
      ),
    );
  }

  /// 构建动态内容
  Widget _buildPostContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 文字内容
          if (post.content.isNotEmpty)
            Text(
              post.content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          
          const SizedBox(height: 12),
          
          // 图片/视频内容
                if ((post.media?.isNotEmpty ?? false)) _buildMediaContent(),
          
          // 训练记录
          if (post.workoutData != null) _buildWorkoutData(),
          
          // 打卡信息
          if (post.checkInData != null) _buildCheckInData(),
        ],
      ),
    );
  }

  /// 构建媒体内容
  Widget _buildMediaContent() {
    if ((post.media?.length ?? 0) == 1) {
      // 单张图片/视频
      return _buildSingleMedia(post.media![0]);
    } else {
      // 多张图片/视频
      return _buildMultipleMedia();
    }
  }

  /// 构建单个媒体
  Widget _buildSingleMedia(MediaItem media) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: media.type == MediaType.image
            ? Image.network(
                media.url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error, color: Colors.grey),
                  );
                },
              )
            : _buildVideoPlayer(media),
      ),
    );
  }

  /// 构建多个媒体
  Widget _buildMultipleMedia() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: (post.media?.length ?? 0) > 4 ? 4 : (post.media?.length ?? 0),
      itemBuilder: (context, index) {
        final media = post.media![index];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey[200],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: media.type == MediaType.image
                ? Image.network(
                    media.url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error, color: Colors.grey),
                      );
                    },
                  )
                : _buildVideoPlayer(media),
          ),
        );
      },
    );
  }

  /// 构建视频播放器
  Widget _buildVideoPlayer(MediaItem media) {
    return Stack(
      children: [
        Container(
          color: Colors.black,
          child: const Center(
            child: Icon(
              Icons.play_circle_filled,
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${media.duration ?? 0}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建训练记录
  Widget _buildWorkoutData() {
    final workout = post.workoutData!;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                MdiIcons.dumbbell,
                color: AppTheme.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '训练记录',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            workout.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildWorkoutStat('时长', '${workout.duration}分钟'),
              const SizedBox(width: 16),
              _buildWorkoutStat('消耗', '${workout.calories}卡'),
              const SizedBox(width: 16),
              _buildWorkoutStat('动作', '${workout.exerciseCount}个'),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建训练统计项
  Widget _buildWorkoutStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// 构建打卡信息
  Widget _buildCheckInData() {
    final checkIn = post.checkInData!;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                MdiIcons.checkCircle,
                color: Colors.green,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '打卡记录',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            checkIn.description ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          if (checkIn.mood != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '心情: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                _buildMoodIcon(checkIn.mood!),
                const SizedBox(width: 4),
                Text(
                  checkIn.mood!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 构建心情图标
  Widget _buildMoodIcon(String mood) {
    IconData icon;
    Color color;
    
    switch (mood) {
      case 'excellent':
        icon = MdiIcons.emoticonHappy;
        color = Colors.green;
        break;
      case 'good':
        icon = MdiIcons.emoticonNeutral;
        color = Colors.blue;
        break;
      case 'normal':
        icon = MdiIcons.emoticonNeutral;
        color = Colors.grey;
        break;
      case 'bad':
        icon = MdiIcons.emoticonSad;
        color = Colors.orange;
        break;
      case 'terrible':
        icon = MdiIcons.emoticonSad;
        color = Colors.red;
        break;
      default:
        icon = MdiIcons.emoticonNeutral;
        color = Colors.grey;
    }
    
    return Icon(icon, size: 16, color: color);
  }

  /// 构建话题标签
  Widget _buildTopicTags() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: (post.topics?.map((topic) {
          return GestureDetector(
            onTap: () {
              // TODO: 导航到话题页面
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: Text(
                '#$topic',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList() ?? []),
      ),
    );
  }

  /// 构建互动操作栏
  Widget _buildInteractionBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 点赞按钮
          _buildInteractionButton(
            icon: post.isLiked ? MdiIcons.heart : MdiIcons.heartOutline,
            label: post.likeCount.toString(),
            isActive: post.isLiked,
            onTap: () => onLike?.call(post.id),
          ),
          
          const SizedBox(width: 24),
          
          // 评论按钮
          _buildInteractionButton(
            icon: MdiIcons.commentOutline,
            label: post.commentCount.toString(),
            onTap: () => onComment?.call(post.id),
          ),
          
          const SizedBox(width: 24),
          
          // 分享按钮
          _buildInteractionButton(
            icon: MdiIcons.shareOutline,
            label: post.shareCount.toString(),
            onTap: () => onShare?.call(post.id),
          ),
          
          const Spacer(),
          
          // 收藏按钮
          IconButton(
            onPressed: () {
              // TODO: 实现收藏功能
            },
            icon: Icon(
              post.isFavorited ? MdiIcons.bookmark : MdiIcons.bookmarkOutline,
              color: post.isFavorited ? Colors.orange : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建互动按钮
  Widget _buildInteractionButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? Colors.red : Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isActive ? Colors.red : Colors.grey[600],
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建评论预览
  Widget _buildCommentsPreview() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          // 显示前2条评论
          if (post.comments != null) ...post.comments!.take(2).map((comment) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: comment.userAvatar != null 
                        ? NetworkImage(comment.userAvatar!) 
                        : null,
                    child: comment.userAvatar == null 
                        ? Text(
                            (comment.userName?.isNotEmpty ?? false) ? comment.userName![0].toUpperCase() : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${comment.userName ?? 'Unknown'} ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          TextSpan(
                            text: comment.content,
                            style: const TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          
          // 查看更多评论按钮
          if ((post.comments?.length ?? 0) > 2)
            GestureDetector(
              onTap: () => onComment?.call(post.id),
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '查看全部${post.comments?.length ?? 0}条评论',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 处理菜单操作
  void _handleMenuAction(String action) {
    switch (action) {
      case 'report':
        // TODO: 实现举报功能
        break;
      case 'block':
        // TODO: 实现屏蔽功能
        break;
    }
  }

  /// 格式化时间
  String _formatTimeAgo(DateTime dateTime) {
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
}