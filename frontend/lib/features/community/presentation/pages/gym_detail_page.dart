import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/models.dart';

/// 健身房详情页面
class GymDetailPage extends StatefulWidget {
  final Gym? gym;
  final String? gymName;

  const GymDetailPage({
    super.key,
    this.gym,
    this.gymName,
  });

  @override
  State<GymDetailPage> createState() => _GymDetailPageState();
}

class _GymDetailPageState extends State<GymDetailPage> {
  Gym? _gym;
  List<GymBuddyMember> _buddies = [];
  List<GymDiscount> _discounts = [];
  bool _isLoading = true;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _loadGymDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _gym == null
              ? _buildErrorState()
              : _buildGymDetail(),
    );
  }

  /// 构建错误状态
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '健身房不存在',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('返回'),
          ),
        ],
      ),
    );
  }

  /// 构建健身房详情
  Widget _buildGymDetail() {
    return CustomScrollView(
      slivers: [
        // 顶部图片和基本信息
        _buildGymHeader(),
        
        // 健身房信息
        _buildGymInfo(),
        
        // 搭子信息
        _buildBuddiesSection(),
        
        // 优惠信息
        _buildDiscountsSection(),
        
        // 评价信息
        _buildReviewsSection(),
        
        // 底部操作按钮
        _buildBottomActions(),
      ],
    );
  }

  /// 构建健身房头部
  Widget _buildGymHeader() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primary.withOpacity(0.8),
                AppTheme.primary.withOpacity(0.6),
              ],
            ),
          ),
          child: Stack(
            children: [
              // 背景图片
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                ),
                child: const Center(
                  child: Icon(
                    Icons.fitness_center,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
              ),
              
              // 渐变遮罩
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
              
              // 健身房名称
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _gym!.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _gym!.address ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: _shareGym,
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.white),
          onPressed: _toggleFavorite,
        ),
      ],
    );
  }

  /// 构建健身房信息
  Widget _buildGymInfo() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '健身房信息',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // 基本信息
            _buildInfoRow(Icons.location_on, '地址', _gym!.address ?? ''),
            _buildInfoRow(Icons.access_time, '营业时间', '06:00 - 22:00'),
            _buildInfoRow(Icons.phone, '联系电话', '400-123-4567'),
            _buildInfoRow(Icons.star, '评分', '4.5分 (128条评价)'),
            
            const SizedBox(height: 12),
            
            // 设施信息
            const Text(
              '设施设备',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFacilityChip('器械区'),
                _buildFacilityChip('有氧区'),
                _buildFacilityChip('自由重量区'),
                _buildFacilityChip('团操房'),
                _buildFacilityChip('更衣室'),
                _buildFacilityChip('淋浴间'),
                _buildFacilityChip('停车位'),
                _buildFacilityChip('WiFi'),
              ],
            ),
            
            if (_gym!.description != null) ...[
              const SizedBox(height: 12),
              const Text(
                '简介',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _gym!.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建搭子信息
  Widget _buildBuddiesSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '当前搭子',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_gym!.currentBuddiesCount ?? 0}人',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (_buddies.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.group_add,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '还没有搭子，快来加入吧！',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: _buddies.take(3).map((buddy) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppTheme.primary.withOpacity(0.1),
                          child: Text(
                            buddy.userName?.substring(0, 1) ?? 'U',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                buddy.userName ?? '匿名用户',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                buddy.goal ?? '健身目标未设置',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          buddy.timeSlot != null
                              ? '${buddy.timeSlot!.hour}:${buddy.timeSlot!.minute.toString().padLeft(2, '0')}'
                              : '时间待定',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            
            if (_buddies.length > 3) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _showAllBuddies,
                  child: Text(
                    '查看全部${_buddies.length}个搭子',
                    style: TextStyle(color: AppTheme.primary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建优惠信息
  Widget _buildDiscountsSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '优惠活动',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            if (_discounts.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.local_offer,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '暂无优惠活动',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: _discounts.map((discount) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_offer,
                          color: Colors.red[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${discount.minGroupSize}人团购优惠',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[600],
                                ),
                              ),
                              Text(
                                '享受${discount.discountPercent}折优惠',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${discount.discountPercent}折',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建评价信息
  Widget _buildReviewsSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '用户评价',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _showAllReviews,
                  child: const Text('查看全部'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 评分统计
            Row(
              children: [
                Text(
                  '4.5',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < 4 ? Icons.star : Icons.star_border,
                          size: 16,
                          color: Colors.amber[600],
                        );
                      }),
                    ),
                    Text(
                      '128条评价',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 评价列表
            Column(
              children: List.generate(2, (index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppTheme.primary.withOpacity(0.1),
                            child: Text(
                              'U${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '用户${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Row(
                                  children: List.generate(5, (starIndex) {
                                    return Icon(
                                      starIndex < 4 ? Icons.star : Icons.star_border,
                                      size: 12,
                                      color: Colors.amber[600],
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '2天前',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '环境很好，设备齐全，教练专业。推荐！',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建底部操作按钮
  Widget _buildBottomActions() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isJoining ? null : _joinGymBuddy,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isJoining
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        '加入搭子',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _contactGym,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '联系健身房',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建设施标签
  Widget _buildFacilityChip(String facility) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Text(
        facility,
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 加载健身房详情
  void _loadGymDetail() async {
    try {
      // TODO: 调用API获取健身房详情
      await Future.delayed(const Duration(seconds: 1)); // 模拟网络请求
      
      // 模拟数据
      _gym = Gym(
        id: '1',
        name: widget.gymName ?? '超级健身房',
        address: '北京市朝阳区某某街道123号',
        lat: 39.9042,
        lng: 116.4074,
        description: '专业的健身环境，设备齐全，教练专业。提供器械区、有氧区、自由重量区、团操房等多种训练区域。',
        ownerUserId: null,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        currentBuddiesCount: 8,
        applicableDiscount: GymDiscount(
          id: '1',
          gymId: '1',
          minGroupSize: 3,
          discountPercent: 10,
          active: true,
          createdAt: DateTime.now(),
        ),
      );
      
      // 模拟搭子数据
      _buddies = List.generate(5, (index) => GymBuddyMember(
        id: (index + 1).toString(),
        groupId: '1',
        userId: (index + 1).toString(),
        userName: '用户${index + 1}',
        goal: ['增肌', '减脂', '塑形'][index % 3],
        timeSlot: DateTime.now().add(Duration(hours: index + 1)),
        status: 'active',
        joinedAt: DateTime.now().subtract(Duration(days: index)),
      ));
      
      // 模拟优惠数据
      _discounts = [
        GymDiscount(
          id: '1',
          gymId: '1',
          minGroupSize: 3,
          discountPercent: 10,
          active: true,
          createdAt: DateTime.now(),
        ),
        GymDiscount(
          id: '2',
          gymId: '1',
          minGroupSize: 5,
          discountPercent: 15,
          active: true,
          createdAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 分享健身房
  void _shareGym() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('分享功能待实现')),
    );
  }

  /// 切换收藏状态
  void _toggleFavorite() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('收藏功能待实现')),
    );
  }

  /// 显示所有搭子
  void _showAllBuddies() {
    Navigator.pushNamed(
      context,
      '/community/gym-buddies',
      arguments: _gym,
    );
  }

  /// 显示所有评价
  void _showAllReviews() {
    Navigator.pushNamed(
      context,
      '/community/gym-reviews',
      arguments: _gym,
    );
  }

  /// 加入搭子
  void _joinGymBuddy() async {
    setState(() {
      _isJoining = true;
    });

    try {
      // TODO: 调用API加入搭子
      await Future.delayed(const Duration(seconds: 2)); // 模拟网络请求
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('加入成功！')),
      );
      
      // 刷新数据
      _loadGymDetail();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加入失败: $e')),
      );
    } finally {
      setState(() {
        _isJoining = false;
      });
    }
  }

  /// 联系健身房
  void _contactGym() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('联系功能待实现')),
    );
  }
}
