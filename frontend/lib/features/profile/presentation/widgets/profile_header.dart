import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/models.dart';
import '../../../../shared/widgets/custom_widgets.dart';
import '../providers/profile_provider.dart';

/// 个人资料头部组件
/// 显示用户头像、昵称、简介、粉丝关注数等信息
class ProfileHeader extends StatelessWidget {
  final User user;
  final VoidCallback onEditProfile;
  final VoidCallback onViewFollowers;
  final VoidCallback onViewFollowing;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.onEditProfile,
    required this.onViewFollowers,
    required this.onViewFollowing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 头像和基本信息
          Row(
            children: [
              // 头像
              GestureDetector(
                onTap: () {
                  _showAvatarDialog(context);
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 38,
                        backgroundImage: (user.avatar?.isNotEmpty ?? false)
                            ? NetworkImage(user.avatar!)
                            : null,
                        child: (user.avatar?.isEmpty ?? true)
                            ? Icon(
                                MdiIcons.account,
                                size: 40,
                                color: AppTheme.primary,
                              )
                            : null,
                      ),
                    ),
                    // 在线状态指示器
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: user.isOnline ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // 基本信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(
                        user.nickname ?? user.username,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '@${user.username}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (user.bio?.isNotEmpty == true)
                      Text(
                        user.bio ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              
              // 编辑按钮
              IconButton(
                onPressed: onEditProfile,
                icon: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  shape: const CircleBorder(),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 统计信息
          Row(
            children: [
              // 粉丝数
              Expanded(
                child: GestureDetector(
                  onTap: onViewFollowers,
                  child: _buildStatItem(
                    '粉丝',
                    user.followersCount.toString(),
                    MdiIcons.accountHeart,
                  ),
                ),
              ),
              
              // 关注数
              Expanded(
                child: GestureDetector(
                  onTap: onViewFollowing,
                  child: _buildStatItem(
                    '关注',
                    user.followingCount.toString(),
                    MdiIcons.accountPlus,
                  ),
                ),
              ),
              
              // 获赞数
              Expanded(
                child: _buildStatItem(
                  '获赞',
                  user.likesCount.toString(),
                  MdiIcons.heart,
                ),
              ),
              
              // 训练天数
              Expanded(
                child: _buildStatItem(
                  '训练',
                  user.trainingDays.toString(),
                  MdiIcons.dumbbell,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 等级和积分
          Row(
            children: [
              // 等级
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      MdiIcons.star,
                      color: Colors.yellow[300],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Lv.${user.level}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 12),
              
              // 积分
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: Colors.yellow[300],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${user.points}积分',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // 更多信息按钮
              IconButton(
                onPressed: () {
                  _showMoreInfoDialog(context);
                },
                icon: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  shape: const CircleBorder(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  /// 显示头像对话框
  void _showAvatarDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    '头像',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // 当前头像
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: (user.avatar?.isNotEmpty ?? false)
                          ? NetworkImage(user.avatar!)
                          : null,
                      child: (user.avatar?.isEmpty ?? true)
                          ? Icon(
                              MdiIcons.account,
                              size: 50,
                              color: Colors.grey[400],
                            )
                          : null,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 操作按钮
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _pickAvatarFromCamera(context);
                          },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('拍照'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _pickAvatarFromGallery(context);
                          },
                          icon: const Icon(Icons.photo_library),
                          label: const Text('相册'),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  if (user.avatar?.isNotEmpty ?? false)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _removeAvatar(context);
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('删除头像', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示更多信息对话框
  void _showMoreInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.nickname} 的详细信息'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('用户名', '@${user.username}'),
            _buildInfoRow('邮箱', user.email),
            _buildInfoRow('注册时间', _formatDate(user.createdAt)),
            _buildInfoRow('最后登录', _formatDate(user.lastLoginAt ?? DateTime.now())),
            _buildInfoRow('训练天数', '${user.trainingDays}天'),
            _buildInfoRow('总训练时长', '${user.totalTrainingMinutes}分钟'),
            _buildInfoRow('完成训练', '${user.completedWorkouts}次'),
            _buildInfoRow('当前等级', 'Lv.${user.level}'),
            _buildInfoRow('总积分', '${user.points}分'),
            _buildInfoRow('成就数量', '${user.achievementsCount}个'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 从相机选择头像
  void _pickAvatarFromCamera(BuildContext context) {
    // TODO: 实现相机拍照功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('相机功能开发中')),
    );
  }

  /// 从相册选择头像
  void _pickAvatarFromGallery(BuildContext context) {
    // TODO: 实现相册选择功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('相册功能开发中')),
    );
  }

  /// 删除头像
  void _removeAvatar(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除头像'),
        content: const Text('确定要删除当前头像吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实现删除头像功能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('头像删除功能开发中')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
