import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/models.dart';

/// 健身房搜索页面
class GymSearchPage extends StatefulWidget {
  final String? initialQuery;

  const GymSearchPage({
    super.key,
    this.initialQuery,
  });

  @override
  State<GymSearchPage> createState() => _GymSearchPageState();
}

class _GymSearchPageState extends State<GymSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  List<Gym> _gyms = [];
  bool _isLoading = false;
  String _selectedFilter = 'all';
  String _selectedSort = 'distance';

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery ?? '';
    _loadGyms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('搜索健身房'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 搜索栏
          _buildSearchBar(),
          
          // 筛选和排序
          _buildFilterBar(),
          
          // 健身房列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _gyms.isEmpty
                    ? _buildEmptyState()
                    : _buildGymList(),
          ),
        ],
      ),
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: '搜索健身房名称、地址...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchGyms();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.primary),
                ),
              ),
              onSubmitted: (value) => _searchGyms(),
              onChanged: (value) => setState(() {}),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _searchGyms,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text('搜索'),
          ),
        ],
      ),
    );
  }

  /// 构建筛选栏
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          // 筛选按钮
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('全部', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('附近', 'nearby'),
                  const SizedBox(width: 8),
                  _buildFilterChip('评分高', 'rating'),
                  const SizedBox(width: 8),
                  _buildFilterChip('搭子多', 'buddies'),
                  const SizedBox(width: 8),
                  _buildFilterChip('有优惠', 'discount'),
                ],
              ),
            ),
          ),
          
          // 排序按钮
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedSort = value;
              });
              _loadGyms();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'distance',
                child: Text('距离最近'),
              ),
              const PopupMenuItem(
                value: 'rating',
                child: Text('评分最高'),
              ),
              const PopupMenuItem(
                value: 'buddies',
                child: Text('搭子最多'),
              ),
              const PopupMenuItem(
                value: 'name',
                child: Text('名称排序'),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sort, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _getSortLabel(_selectedSort),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建筛选标签
  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
        _loadGyms();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '没有找到相关健身房',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '试试其他关键词或筛选条件',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建健身房列表
  Widget _buildGymList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _gyms.length,
      itemBuilder: (context, index) {
        final gym = _gyms[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: _buildGymCard(gym),
        );
      },
    );
  }

  /// 构建健身房卡片
  Widget _buildGymCard(Gym gym) {
    return GestureDetector(
      onTap: () => _navigateToGymDetail(gym),
      child: Container(
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
            // 顶部信息
            Row(
              children: [
                // 健身房图片
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.fitness_center, size: 30, color: Colors.grey),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // 健身房信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gym.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        gym.address ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber[600]),
                          const SizedBox(width: 2),
                          Text(
                            '4.5', // TODO: 从API获取评分
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.group, size: 14, color: AppTheme.primary),
                          const SizedBox(width: 2),
                          Text(
                            '${gym.currentBuddiesCount ?? 0}人搭子',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 距离和优惠
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '500m', // TODO: 计算实际距离
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (gym.applicableDiscount != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Text(
                          '${gym.applicableDiscount!.minGroupSize}人${gym.applicableDiscount!.discountPercent}折',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 底部操作
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _joinGymBuddy(gym),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('加入搭子'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _navigateToGymDetail(gym),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('查看详情'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 获取排序标签
  String _getSortLabel(String sort) {
    switch (sort) {
      case 'distance':
        return '距离';
      case 'rating':
        return '评分';
      case 'buddies':
        return '搭子';
      case 'name':
        return '名称';
      default:
        return '距离';
    }
  }

  /// 加载健身房数据
  void _loadGyms() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 调用API获取健身房列表
      await Future.delayed(const Duration(seconds: 1)); // 模拟网络请求
      
      // 模拟数据
      _gyms = List.generate(10, (index) => Gym(
        id: (index + 1).toString(),
        name: '超级健身房${index + 1}',
        address: '北京市朝阳区某某街道${index + 1}号',
        lat: 39.9042 + (index * 0.01),
        lng: 116.4074 + (index * 0.01),
        description: '专业的健身环境，设备齐全',
        ownerUserId: null,
        createdAt: DateTime.now().subtract(Duration(days: index)),
        updatedAt: DateTime.now(),
        currentBuddiesCount: 5 + index,
        applicableDiscount: index >= 2 ? GymDiscount(
          id: index.toString(),
          gymId: (index + 1).toString(),
          minGroupSize: 3,
          discountPercent: 10,
          active: true,
          createdAt: DateTime.now(),
        ) : null,
      ));
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

  /// 搜索健身房
  void _searchGyms() {
    _loadGyms();
  }

  /// 导航到健身房详情
  void _navigateToGymDetail(Gym gym) {
    Navigator.pushNamed(
      context,
      '/community/gym-detail',
      arguments: gym,
    );
  }

  /// 加入搭子
  void _joinGymBuddy(Gym gym) {
    Navigator.pushNamed(
      context,
      '/community/join-gym-buddy',
      arguments: gym,
    );
  }
}
