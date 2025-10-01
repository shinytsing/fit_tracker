import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/models.dart';
import '../providers/community_provider.dart';

/// 发布动态底部弹窗
/// 支持文字、图片、视频、打卡、训练记录等多种内容类型
class CreatePostBottomSheet extends StatefulWidget {
  final Function(Post)? onPostCreated;

  const CreatePostBottomSheet({
    super.key,
    this.onPostCreated,
  });

  @override
  State<CreatePostBottomSheet> createState() => _CreatePostBottomSheetState();
}

class _CreatePostBottomSheetState extends State<CreatePostBottomSheet> {
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();
  
  PostType _selectedPostType = PostType.text;
  List<MediaItem> _selectedMedia = [];
  String? _selectedLocation;
  WorkoutData? _selectedWorkout;
  CheckInData? _selectedCheckIn;
  List<String> _selectedTopics = [];
  bool _isAnonymous = false;
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    // 延迟显示键盘
    Future.delayed(const Duration(milliseconds: 300), () {
      _contentFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // 顶部拖拽条和标题
          _buildHeader(),
          
          // 内容区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 发布类型选择
                  _buildPostTypeSelector(),
                  
                  const SizedBox(height: 16),
                  
                  // 内容输入区域
                  _buildContentInput(),
                  
                  const SizedBox(height: 16),
                  
                  // 媒体内容
                  if (_selectedMedia.isNotEmpty) _buildMediaPreview(),
                  
                  // 训练记录
                  if (_selectedWorkout != null) _buildWorkoutPreview(),
                  
                  // 打卡信息
                  if (_selectedCheckIn != null) _buildCheckInPreview(),
                  
                  const SizedBox(height: 16),
                  
                  // 话题标签
                  _buildTopicSelector(),
                  
                  const SizedBox(height: 16),
                  
                  // 位置信息
                  _buildLocationSelector(),
                  
                  const SizedBox(height: 16),
                  
                  // 匿名选项
                  _buildAnonymousOption(),
                  
                  const SizedBox(height: 100), // 底部留白
                ],
              ),
            ),
          ),
          
          // 底部操作栏
          _buildBottomBar(),
        ],
      ),
    );
  }

  /// 构建顶部头部
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 拖拽条
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 标题和关闭按钮
          Row(
            children: [
              const Text(
                '发布动态',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建发布类型选择器
  Widget _buildPostTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '发布类型',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPostTypeButton(
                icon: MdiIcons.text,
                label: '文字',
                type: PostType.text,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPostTypeButton(
                icon: MdiIcons.camera,
                label: '图片',
                type: PostType.image,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPostTypeButton(
                icon: MdiIcons.video,
                label: '视频',
                type: PostType.video,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPostTypeButton(
                icon: MdiIcons.checkCircle,
                label: '打卡',
                type: PostType.checkin,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建发布类型按钮
  Widget _buildPostTypeButton({
    required IconData icon,
    required String label,
    required PostType type,
  }) {
    final isSelected = _selectedPostType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPostType = type;
        });
        
        // 根据类型执行相应操作
        switch (type) {
          case PostType.image:
            _selectImages();
            break;
          case PostType.video:
            _selectVideo();
            break;
          case PostType.checkin:
            _selectCheckIn();
            break;
          default:
            break;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.grey[200]!,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primary : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppTheme.primary : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建内容输入区域
  Widget _buildContentInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '分享你的想法',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _contentController,
            focusNode: _contentFocusNode,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: '分享你的健身心得、训练感受...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建媒体预览
  Widget _buildMediaPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '媒体内容',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMedia.clear();
                });
              },
              child: Text(
                '删除',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red[400],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_selectedMedia.length == 1)
          _buildSingleMediaPreview(_selectedMedia[0])
        else
          _buildMultipleMediaPreview(),
      ],
    );
  }

  /// 构建单个媒体预览
  Widget _buildSingleMediaPreview(MediaItem media) {
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
            : _buildVideoPreview(media),
      ),
    );
  }

  /// 构建多个媒体预览
  Widget _buildMultipleMediaPreview() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _selectedMedia.length,
      itemBuilder: (context, index) {
        final media = _selectedMedia[index];
        return Container(
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
                : _buildVideoPreview(media),
          ),
        );
      },
    );
  }

  /// 构建视频预览
  Widget _buildVideoPreview(MediaItem media) {
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

  /// 构建训练记录预览
  Widget _buildWorkoutPreview() {
    final workout = _selectedWorkout!;
    return Container(
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
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedWorkout = null;
                  });
                },
                child: Icon(
                  Icons.close,
                  color: Colors.grey[600],
                  size: 16,
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

  /// 构建打卡信息预览
  Widget _buildCheckInPreview() {
    final checkIn = _selectedCheckIn!;
    return Container(
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
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCheckIn = null;
                  });
                },
                child: Icon(
                  Icons.close,
                  color: Colors.grey[600],
                  size: 16,
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

  /// 构建话题选择器
  Widget _buildTopicSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '话题标签',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _showTopicSelector,
              child: Text(
                '添加话题',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_selectedTopics.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '添加话题标签，让更多人看到你的动态',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedTopics.map((topic) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '#$topic',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTopics.remove(topic);
                        });
                      },
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  /// 构建位置选择器
  Widget _buildLocationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '位置信息',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _selectLocation,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  MdiIcons.mapMarker,
                  color: Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedLocation ?? '添加位置信息',
                    style: TextStyle(
                      fontSize: 14,
                      color: _selectedLocation != null ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                ),
                if (_selectedLocation != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedLocation = null;
                      });
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.grey[600],
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建匿名选项
  Widget _buildAnonymousOption() {
    return Row(
      children: [
        Checkbox(
          value: _isAnonymous,
          onChanged: (value) {
            setState(() {
              _isAnonymous = value ?? false;
            });
          },
          activeColor: AppTheme.primary,
        ),
        const Text(
          '匿名发布',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(width: 8),
        Icon(
          MdiIcons.incognito,
          color: Colors.grey[600],
          size: 16,
        ),
      ],
    );
  }

  /// 构建底部操作栏
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 字数统计
          Text(
            '${_contentController.text.length}/500',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          
          const Spacer(),
          
          // 发布按钮
          ElevatedButton(
            onPressed: _isPublishing ? null : _publishPost,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: _isPublishing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    '发布',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // 事件处理方法
  void _selectImages() {
    // TODO: 实现图片选择
    setState(() {
      _selectedMedia = [
        MediaItem(
          id: '1',
          type: MediaType.image,
          url: 'https://example.com/image.jpg',
        ),
      ];
    });
  }

  void _selectVideo() {
    // TODO: 实现视频选择
    setState(() {
      _selectedMedia = [
        MediaItem(
          id: '1',
          type: MediaType.video,
          url: 'https://example.com/video.mp4',
          duration: 90,
        ),
      ];
    });
  }

  void _selectCheckIn() {
    // TODO: 实现打卡选择
    setState(() {
      _selectedCheckIn = CheckInData(
        id: '1',
        userId: 'current_user_id', // TODO: 获取当前用户ID
        location: '健身房',
        checkInTime: DateTime.now(),
        createdAt: DateTime.now(),
        description: '今天完成了胸肌训练，感觉很棒！',
        mood: 'excellent',
      );
    });
  }

  void _showTopicSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '选择话题',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // TODO: 实现话题选择列表
            Text('话题选择功能待实现'),
          ],
        ),
      ),
    );
  }

  void _selectLocation() {
    // TODO: 实现位置选择
    setState(() {
      _selectedLocation = '北京市朝阳区';
    });
  }

  void _publishPost() async {
    if (_contentController.text.trim().isEmpty && 
        _selectedMedia.isEmpty && 
        _selectedWorkout == null && 
        _selectedCheckIn == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入内容或添加媒体')),
      );
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    try {
      // TODO: 调用API发布动态
      await Future.delayed(const Duration(seconds: 2)); // 模拟网络请求
      
      final post = Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user',
        content: _contentController.text,
        isPublic: true,
        isFeatured: false,
        viewCount: 0,
        shareCount: 0,
        likesCount: 0,
        commentsCount: 0,
        sharesCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userName: '当前用户',
        userAvatar: null,
        likeCount: 0,
        commentCount: 0,
        isLiked: false,
        isFollowed: false,
        authorId: 'current_user',
        authorName: '当前用户',
        authorAvatar: null,
      );

      widget.onPostCreated?.call(post);
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('发布成功！')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发布失败: $e')),
      );
    } finally {
      setState(() {
        _isPublishing = false;
      });
    }
  }
}
