import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../core/theme/app_theme.dart';
import '../widgets/figma/custom_button.dart';
import '../services/api_service.dart';

/// 基于Figma设计的搭子页面
/// 完全按照Gymates Fitness Social App设计规范实现
class MatesPage extends ConsumerStatefulWidget {
  const MatesPage({super.key});

  @override
  ConsumerState<MatesPage> createState() => _MatesPageState();
}

class _MatesPageState extends ConsumerState<MatesPage> {
  final bool isIOS = Platform.isIOS;
  final ApiService _apiService = ApiService();
  String _selectedTab = '推荐';
  final List<Map<String, dynamic>> _recommendedMates = [];
  final List<Map<String, dynamic>> _nearbyMates = [];
  final List<Map<String, dynamic>> _similarMates = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _apiService.init();
    _loadRecommendedMates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isIOS ? const Color(0xFFF9FAFB) : AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '健身搭子',
            style: TextStyle(
              fontSize: isIOS ? 28 : 24,
              fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
          ),
          Row(
            children: [
              _buildHeaderButton(Icons.search, _showSearch),
              const SizedBox(width: 12),
              _buildHeaderButton(Icons.filter_list, _showFilter),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: const Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ['推荐', '附近', '同好'];
    
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _selectedTab == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = tab;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isIOS ? 16 : 14,
                    fontWeight: isSelected 
                        ? (isIOS ? FontWeight.w600 : FontWeight.w500)
                        : FontWeight.w400,
                    color: isSelected 
                        ? const Color(0xFF6366F1) 
                        : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case '推荐':
        return _buildRecommendContent();
      case '附近':
        return _buildNearbyContent();
      case '同好':
        return _buildSimilarContent();
      default:
        return _buildRecommendContent();
    }
  }

  Widget _buildRecommendContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildMatesList(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isIOS ? 0.1 : 0.12),
            blurRadius: isIOS ? 20 : 4,
            offset: Offset(0, isIOS ? 10 : 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '快速找搭子',
            style: TextStyle(
              fontSize: isIOS ? 18 : 16,
              fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  '健身房找搭子',
                  Icons.fitness_center,
                  const Color(0xFF6366F1),
                  _showGymFinder,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  '户外运动',
                  Icons.park,
                  const Color(0xFF10B981),
                  _showOutdoorFinder,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  '瑜伽搭子',
                  Icons.self_improvement,
                  const Color(0xFFF59E0B),
                  _showYogaFinder,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  '跑步伙伴',
                  Icons.directions_run,
                  const Color(0xFFEF4444),
                  _showRunningFinder,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: isIOS ? 12 : 10,
                fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                color: const Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatesList() {
    final mates = _getCurrentMatesList();
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
        ),
      );
    }

    if (mates.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_getTabTitle()}搭子',
              style: TextStyle(
                fontSize: isIOS ? 18 : 16,
                fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                color: const Color(0xFF1F2937),
              ),
            ),
            TextButton(
              onPressed: _refreshMates,
              child: Text(
                '刷新',
                style: TextStyle(
                  color: const Color(0xFF6366F1),
                  fontSize: isIOS ? 14 : 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...mates.map((mate) => _buildMateCard(mate)).toList(),
      ],
    );
  }

  List<Map<String, dynamic>> _getCurrentMatesList() {
    switch (_selectedTab) {
      case '推荐':
        return _recommendedMates;
      case '附近':
        return _nearbyMates;
      case '同好':
        return _similarMates;
      default:
        return _recommendedMates;
    }
  }

  String _getTabTitle() {
    switch (_selectedTab) {
      case '推荐':
        return '推荐';
      case '附近':
        return '附近';
      case '同好':
        return '同好';
      default:
        return '推荐';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.people_outline,
              color: Color(0xFF9CA3AF),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无${_getTabTitle()}搭子',
            style: TextStyle(
              fontSize: isIOS ? 16 : 14,
              fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '尝试调整筛选条件或稍后再试',
            style: TextStyle(
              fontSize: isIOS ? 14 : 12,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: '刷新',
            onPressed: _refreshMates,
            isIOS: isIOS,
            backgroundColor: const Color(0xFF6366F1),
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildMateCard(Map<String, dynamic> mate) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isIOS ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isIOS ? 0.1 : 0.12),
            blurRadius: isIOS ? 20 : 4,
            offset: Offset(0, isIOS ? 10 : 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        mate['avatar'] ?? '👤',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  if (mate['online'] == true)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          mate['name'] ?? '未知用户',
                          style: TextStyle(
                            fontSize: isIOS ? 16 : 14,
                            fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            mate['level'] ?? '初级',
                            style: TextStyle(
                              fontSize: isIOS ? 10 : 8,
                              color: const Color(0xFF6366F1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${mate['age'] ?? '未知'}岁 • ${mate['distance'] ?? '未知距离'}',
                      style: TextStyle(
                        fontSize: isIOS ? 12 : 10,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: (mate['interests'] as List<String>? ?? []).map((interest) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            interest,
                            style: TextStyle(
                              fontSize: isIOS ? 10 : 8,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // 匹配度显示
          if (mate['matchScore'] != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '匹配度',
                  style: TextStyle(
                    fontSize: isIOS ? 12 : 10,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (mate['matchScore'] as int) / 100,
                    backgroundColor: const Color(0xFFF3F4F6),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${mate['matchScore']}%',
                  style: TextStyle(
                    fontSize: isIOS ? 12 : 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 16),
          
          // 操作按钮
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: '申请搭子',
                  onPressed: () => _requestBuddy(mate),
                  isIOS: isIOS,
                  backgroundColor: const Color(0xFF6366F1),
                  textColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: '发送消息',
                  onPressed: () => _sendMessage(mate['name'] ?? '未知用户'),
                  isIOS: isIOS,
                  backgroundColor: Colors.white,
                  textColor: const Color(0xFF6366F1),
                  borderColor: const Color(0xFF6366F1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyContent() {
    if (_nearbyMates.isEmpty && !_isLoading) {
      _loadNearbyMates();
    }
    return _buildMatesList();
  }

  Widget _buildSimilarContent() {
    if (_similarMates.isEmpty && !_isLoading) {
      _loadSimilarMates();
    }
    return _buildMatesList();
  }

  // 数据加载方法
  void _loadRecommendedMates() {
    setState(() {
      _isLoading = true;
    });
    
    // 模拟API调用
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _recommendedMates.clear();
        _recommendedMates.addAll([
          {
            'id': '1',
            'name': '健身达人小李',
            'age': 25,
            'distance': '1.2km',
            'level': '中级',
            'interests': ['力量训练', '跑步'],
            'avatar': '👨‍💼',
            'online': true,
            'matchScore': 85,
            'matchReasons': ['相同的健身目标', '相近的训练时间'],
          },
          {
            'id': '2',
            'name': '瑜伽小仙女',
            'age': 23,
            'distance': '0.8km',
            'level': '高级',
            'interests': ['瑜伽', '普拉提'],
            'avatar': '👩‍🦰',
            'online': true,
            'matchScore': 92,
            'matchReasons': ['相同的运动爱好', '相近的地理位置'],
          },
          {
            'id': '3',
            'name': '跑步爱好者',
            'age': 28,
            'distance': '2.1km',
            'level': '中级',
            'interests': ['跑步', '骑行'],
            'avatar': '👨‍🏃',
            'online': false,
            'matchScore': 78,
            'matchReasons': ['相同的运动类型', '相近的年龄'],
          },
        ]);
        _isLoading = false;
      });
    });
  }

  void _loadNearbyMates() {
    setState(() {
      _isLoading = true;
    });
    
    // 模拟API调用
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _nearbyMates.clear();
        _nearbyMates.addAll([
          {
            'id': '4',
            'name': '附近健身者',
            'age': 26,
            'distance': '0.5km',
            'level': '初级',
            'interests': ['力量训练', '游泳'],
            'avatar': '👨‍💪',
            'online': true,
            'matchScore': 65,
          },
          {
            'id': '5',
            'name': '邻居小王',
            'age': 24,
            'distance': '0.3km',
            'level': '中级',
            'interests': ['有氧运动', '瑜伽'],
            'avatar': '👩‍🦱',
            'online': false,
            'matchScore': 70,
          },
        ]);
        _isLoading = false;
      });
    });
  }

  void _loadSimilarMates() {
    setState(() {
      _isLoading = true;
    });
    
    // 模拟API调用
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _similarMates.clear();
        _similarMates.addAll([
          {
            'id': '6',
            'name': '同好健身者',
            'age': 27,
            'distance': '3.2km',
            'level': '高级',
            'interests': ['力量训练', '跑步'],
            'avatar': '👨‍🏋️',
            'online': true,
            'matchScore': 88,
          },
          {
            'id': '7',
            'name': '健身伙伴',
            'age': 25,
            'distance': '4.1km',
            'level': '中级',
            'interests': ['力量训练', '有氧运动'],
            'avatar': '👩‍💪',
            'online': true,
            'matchScore': 82,
          },
        ]);
        _isLoading = false;
      });
    });
  }

  void _refreshMates() {
    switch (_selectedTab) {
      case '推荐':
        _loadRecommendedMates();
        break;
      case '附近':
        _loadNearbyMates();
        break;
      case '同好':
        _loadSimilarMates();
        break;
    }
  }

  void _requestBuddy(Map<String, dynamic> mate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BuddyRequestBottomSheet(mate: mate),
    );
  }

  void _showSearch() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        ),
        title: const Text('搜索搭子'),
        content: const Text('搜索功能开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        ),
        title: const Text('筛选条件'),
        content: const Text('筛选功能开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showGymFinder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        ),
        title: const Text('健身房找搭子'),
        content: const Text('健身房搭子功能开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showOutdoorFinder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        ),
        title: const Text('户外运动'),
        content: const Text('户外运动搭子功能开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showYogaFinder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        ),
        title: const Text('瑜伽搭子'),
        content: const Text('瑜伽搭子功能开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showRunningFinder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 20 : 16),
        ),
        title: const Text('跑步伙伴'),
        content: const Text('跑步伙伴功能开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('给$name发送消息功能开发中'),
        backgroundColor: const Color(0xFF6366F1),
      ),
    );
  }

  void _addFriend(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('添加$name为好友功能开发中'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }
}

/// 搭子申请底部弹窗
class BuddyRequestBottomSheet extends StatefulWidget {
  final Map<String, dynamic> mate;
  
  const BuddyRequestBottomSheet({super.key, required this.mate});

  @override
  State<BuddyRequestBottomSheet> createState() => _BuddyRequestBottomSheetState();
}

class _BuddyRequestBottomSheetState extends State<BuddyRequestBottomSheet> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _selectedPreferences = [];
  String _selectedTime = '晚上7-9点';
  String _selectedLocation = '健身房';

  @override
  void initState() {
    super.initState();
    _messageController.text = '你好，我想和你一起健身！';
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;
    final mate = widget.mate;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isIOS ? 20 : 16),
          topRight: Radius.circular(isIOS ? 20 : 16),
        ),
      ),
      child: Column(
        children: [
          // 头部
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  '申请搭子',
                  style: TextStyle(
                    fontSize: isIOS ? 18 : 16,
                    fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // 内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 搭子信息
                  _buildMateInfo(),
                  
                  const SizedBox(height: 24),
                  
                  // 申请消息
                  _buildMessageSection(),
                  
                  const SizedBox(height: 24),
                  
                  // 训练偏好
                  _buildPreferencesSection(),
                  
                  const SizedBox(height: 24),
                  
                  // 时间和地点
                  _buildTimeLocationSection(),
                ],
              ),
            ),
          ),
          
          // 底部按钮
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey[200]!,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: '取消',
                    onPressed: () => Navigator.of(context).pop(),
                    isIOS: isIOS,
                    backgroundColor: Colors.white,
                    textColor: const Color(0xFF6B7280),
                    borderColor: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: '发送申请',
                    onPressed: _sendRequest,
                    isIOS: isIOS,
                    backgroundColor: const Color(0xFF6366F1),
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMateInfo() {
    final isIOS = Platform.isIOS;
    final mate = widget.mate;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                mate['avatar'] ?? '👤',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mate['name'] ?? '未知用户',
                  style: TextStyle(
                    fontSize: isIOS ? 16 : 14,
                    fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${mate['age'] ?? '未知'}岁 • ${mate['distance'] ?? '未知距离'} • ${mate['level'] ?? '初级'}',
                  style: TextStyle(
                    fontSize: isIOS ? 12 : 10,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                if (mate['matchScore'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '匹配度: ${mate['matchScore']}%',
                    style: TextStyle(
                      fontSize: isIOS ? 12 : 10,
                      color: const Color(0xFF6366F1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageSection() {
    final isIOS = Platform.isIOS;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '申请消息',
          style: TextStyle(
            fontSize: isIOS ? 16 : 14,
            fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _messageController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: '写一段自我介绍，让对方了解你...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    final isIOS = Platform.isIOS;
    final preferences = ['力量训练', '有氧运动', '瑜伽', '游泳', '跑步', '骑行'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '训练偏好',
          style: TextStyle(
            fontSize: isIOS ? 16 : 14,
            fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: preferences.map((preference) {
            final isSelected = _selectedPreferences.contains(preference);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedPreferences.remove(preference);
                  } else {
                    _selectedPreferences.add(preference);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
                ),
                child: Text(
                  preference,
                  style: TextStyle(
                    fontSize: isIOS ? 12 : 10,
                    color: isSelected 
                        ? Colors.white
                        : const Color(0xFF6B7280),
                    fontWeight: isIOS ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeLocationSection() {
    final isIOS = Platform.isIOS;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '训练安排',
          style: TextStyle(
            fontSize: isIOS ? 16 : 14,
            fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        
        // 时间选择
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '训练时间',
                    style: TextStyle(
                      fontSize: isIOS ? 14 : 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedTime,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: '早上6-8点', child: Text('早上6-8点')),
                      DropdownMenuItem(value: '上午9-11点', child: Text('上午9-11点')),
                      DropdownMenuItem(value: '下午2-4点', child: Text('下午2-4点')),
                      DropdownMenuItem(value: '晚上7-9点', child: Text('晚上7-9点')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedTime = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '训练地点',
                    style: TextStyle(
                      fontSize: isIOS ? 14 : 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedLocation,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: '健身房', child: Text('健身房')),
                      DropdownMenuItem(value: '公园', child: Text('公园')),
                      DropdownMenuItem(value: '家里', child: Text('家里')),
                      DropdownMenuItem(value: '户外', child: Text('户外')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedLocation = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _sendRequest() {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入申请消息')),
      );
      return;
    }
    
    // TODO: 调用API发送搭子申请
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已向${widget.mate['name']}发送搭子申请'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }
}
