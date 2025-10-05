import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_theme.dart';

/// 媒体选择器底部弹窗
/// 支持选择图片、视频、文件等媒体类型
class MediaPickerBottomSheet extends StatelessWidget {
  final Function(String)? onImageSelected;
  final Function(String)? onVideoSelected;
  final Function(String)? onFileSelected;

  const MediaPickerBottomSheet({
    super.key,
    this.onImageSelected,
    this.onVideoSelected,
    this.onFileSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部拖拽条
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // 标题
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '选择媒体',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 媒体选择选项
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMediaOption(
                    context,
                    '相册',
                    Icons.photo_library,
                    Colors.blue,
                    () => _selectFromGallery(context),
                  ),
                  _buildMediaOption(
                    context,
                    '拍照',
                    Icons.camera_alt,
                    Colors.green,
                    () => _takePhoto(context),
                  ),
                  _buildMediaOption(
                    context,
                    '视频',
                    Icons.videocam,
                    Colors.red,
                    () => _selectVideo(context),
                  ),
                  _buildMediaOption(
                    context,
                    '文件',
                    Icons.attach_file,
                    Colors.orange,
                    () => _selectFile(context),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaOption(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
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
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectFromGallery(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        onImageSelected?.call(image.path);
      }
    } catch (e) {
      _showErrorSnackBar(context, '选择图片失败: $e');
    }
  }

  Future<void> _takePhoto(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        onImageSelected?.call(image.path);
      }
    } catch (e) {
      _showErrorSnackBar(context, '拍照失败: $e');
    }
  }

  Future<void> _selectVideo(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      
      if (video != null) {
        onVideoSelected?.call(video.path);
      }
    } catch (e) {
      _showErrorSnackBar(context, '选择视频失败: $e');
    }
  }

  Future<void> _selectFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      
      if (result != null && result.files.single.path != null) {
        onFileSelected?.call(result.files.single.path!);
      }
    } catch (e) {
      _showErrorSnackBar(context, '选择文件失败: $e');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }
}
