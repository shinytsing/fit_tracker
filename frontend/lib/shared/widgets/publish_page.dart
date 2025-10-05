import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../core/theme/app_theme.dart';

class PublishPage extends StatefulWidget {
  const PublishPage({super.key});

  @override
  State<PublishPage> createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage> {
  String selectedType = 'training';
  final TextEditingController _contentController = TextEditingController();

  final publishTypes = [
    _PublishType(
      id: 'training',
      title: '发布训练',
      subtitle: '分享你的训练计划',
      icon: MdiIcons.dumbbell,
      color: const Color(0xFF3B82F6), // blue-500
    ),
    _PublishType(
      id: 'nutrition',
      title: '发布饮食',
      subtitle: '记录你的健康饮食',
      icon: MdiIcons.apple,
      color: const Color(0xFF10B981), // green-500
    ),
    _PublishType(
      id: 'moment',
      title: '发布动态',
      subtitle: '分享你的健身心得',
      icon: MdiIcons.pen,
      color: const Color(0xFF8B5CF6), // purple-500
    ),
  ];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.card,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.foreground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '发布内容',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.foreground,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: 发布内容
            },
            child: Text(
              '发布',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 发布类型选择
            _buildPublishTypeSelector(),
            
            const SizedBox(height: 24),
            
            // 内容输入
            _buildContentInput(),
            
            const SizedBox(height: 24),
            
            // 图片上传
            _buildImageUpload(),
            
            const SizedBox(height: 24),
            
            // 标签选择
            _buildTagSelector(),
            
            const SizedBox(height: 24),
            
            // 位置信息
            _buildLocationInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildPublishTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '选择发布类型',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.foreground,
          ),
        ),
        const SizedBox(height: 16),
        ...publishTypes.map((type) => _buildPublishTypeCard(type)).toList(),
      ],
    );
  }

  Widget _buildPublishTypeCard(_PublishType type) {
    final isSelected = selectedType == type.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              selectedType = type.id;
            });
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : AppTheme.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: type.color,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    type.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.foreground,
                        ),
                      ),
                      Text(
                        type.subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '分享内容',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.foreground,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppTheme.border),
          ),
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _contentController,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: '分享你的健身心得、训练计划或饮食记录...',
              hintStyle: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 16,
              ),
              border: InputBorder.none,
            ),
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.foreground,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '添加图片',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.foreground,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppTheme.border),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.inputBackground,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(
                    color: AppTheme.border,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      MdiIcons.imagePlus,
                      color: AppTheme.textSecondaryColor,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '点击添加图片',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: 从相册选择
                      },
                      icon: const Icon(Icons.photo_library, size: 18),
                      label: const Text('相册'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.inputBackground,
                        foregroundColor: AppTheme.textSecondaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: 拍照
                      },
                      icon: const Icon(Icons.camera_alt, size: 18),
                      label: const Text('拍照'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.inputBackground,
                        foregroundColor: AppTheme.textSecondaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagSelector() {
    final tags = ['#力量训练', '#有氧运动', '#瑜伽', '#跑步', '#健身', '#健康饮食'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '添加标签',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.foreground,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) {
            return GestureDetector(
              onTap: () {
                // TODO: 选择标签
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.inputBackground,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '位置信息',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.foreground,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppTheme.border),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                MdiIcons.mapMarker,
                color: AppTheme.textSecondaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '添加位置信息',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ),
              Icon(
                MdiIcons.chevronRight,
                color: AppTheme.textSecondaryColor,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PublishType {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  _PublishType({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
