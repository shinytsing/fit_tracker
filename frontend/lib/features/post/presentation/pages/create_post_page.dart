import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../widgets/post_type_selector.dart';
import '../widgets/image_picker_widget.dart';
import '../providers/post_provider.dart';

class CreatePostPage extends ConsumerStatefulWidget {
  const CreatePostPage({super.key});

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  final TextEditingController _contentController = TextEditingController();
  PostType _selectedType = PostType.text;
  List<String> _selectedImages = [];
  String? _selectedLocation;
  WorkoutData? _workoutData;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          '发布动态',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(MdiIcons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final postState = ref.watch(postProvider);
              return TextButton(
                onPressed: postState.isPosting ? null : _publishPost,
                child: Text(
                  postState.isPosting ? '发布中...' : '发布',
                  style: TextStyle(
                    color: postState.isPosting 
                      ? Colors.grey 
                      : AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 内容输入
            _buildContentInput(),
            const SizedBox(height: 16),
            
            // 帖子类型选择
            PostTypeSelector(
              selectedType: _selectedType,
              onTypeChanged: (type) {
                setState(() {
                  _selectedType = type;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // 图片选择
            if (_selectedType == PostType.image || _selectedType == PostType.video)
              ImagePickerWidget(
                images: _selectedImages,
                onImagesChanged: (images) {
                  setState(() {
                    _selectedImages = images;
                  });
                },
              ),
            
            // 训练数据
            if (_selectedType == PostType.workout)
              _buildWorkoutData(),
            
            // 位置选择
            _buildLocationSelector(),
            
            // 标签输入
            _buildTagsInput(),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildContentInput() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: _contentController,
        maxLines: 6,
        decoration: InputDecoration(
          hintText: '分享你的健身心得...',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildWorkoutData() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                MdiIcons.dumbbell,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '训练记录',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildWorkoutField(
                  '训练名称',
                  _workoutData?.exerciseName ?? '',
                  (value) {
                    setState(() {
                      _workoutData = WorkoutData(
                        exerciseName: value,
                        duration: _workoutData?.duration ?? 0,
                        calories: _workoutData?.calories ?? 0,
                        exercises: _workoutData?.exercises ?? [],
                      );
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildWorkoutField(
                  '时长(分钟)',
                  _workoutData?.duration.toString() ?? '',
                  (value) {
                    setState(() {
                      _workoutData = WorkoutData(
                        exerciseName: _workoutData?.exerciseName ?? '',
                        duration: int.tryParse(value) ?? 0,
                        calories: _workoutData?.calories ?? 0,
                        exercises: _workoutData?.exercises ?? [],
                      );
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildWorkoutField(
            '消耗卡路里',
            _workoutData?.calories.toString() ?? '',
            (value) {
              setState(() {
                _workoutData = WorkoutData(
                  exerciseName: _workoutData?.exerciseName ?? '',
                  duration: _workoutData?.duration ?? 0,
                  calories: int.tryParse(value) ?? 0,
                  exercises: _workoutData?.exercises ?? [],
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutField(String label, String value, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSelector() {
    return ListTile(
      leading: Icon(
        MdiIcons.mapMarker,
        color: Colors.grey[600],
      ),
      title: Text(
        _selectedLocation ?? '添加位置',
        style: TextStyle(
          color: _selectedLocation != null 
            ? Theme.of(context).textTheme.bodyMedium?.color
            : Colors.grey[600],
        ),
      ),
      trailing: Icon(MdiIcons.chevronRight),
      onTap: () {
        // TODO: 打开位置选择页面
      },
    );
  }

  Widget _buildTagsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '添加标签',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTagChip('健身', true),
            _buildTagChip('训练', true),
            _buildTagChip('打卡', true),
            _buildTagChip('减脂', false),
            _buildTagChip('增肌', false),
            _buildTagChip('瑜伽', false),
          ],
        ),
      ],
    );
  }

  Widget _buildTagChip(String tag, bool isSelected) {
    return GestureDetector(
      onTap: () {
        // TODO: 切换标签选择状态
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
            ? AppTheme.primaryColor.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
              ? AppTheme.primaryColor.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          '#$tag',
          style: TextStyle(
            color: isSelected 
              ? AppTheme.primaryColor
              : Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _publishPost() {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入内容')),
      );
      return;
    }

    final postData = CreatePostRequest(
      content: _contentController.text.trim(),
      type: _selectedType.name,
      images: _selectedImages,
      location: _selectedLocation,
      workoutData: _workoutData,
    );

    ref.read(postProvider.notifier).createPost(postData).then((success) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('发布成功')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('发布失败，请重试')),
        );
      }
    });
  }
}
