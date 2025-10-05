import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../providers/theme_provider.dart';
import '../../widgets/custom_button.dart';

class MatesScreen extends StatefulWidget {
  const MatesScreen({super.key});

  @override
  State<MatesScreen> createState() => _MatesScreenState();
}

class _MatesScreenState extends State<MatesScreen> {
  int _currentCardIndex = 0;
  String _swipeDirection = '';

  final List<Map<String, dynamic>> _mates = [
    {
      'id': 1,
      'name': '陈雨晨',
      'age': 25,
      'avatar': 'https://images.unsplash.com/photo-1541338784564-51087dabc0de?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwd29tYW4lMjB0cmFpbmluZyUyMGV4ZXJjaXNlfGVufDF8fHx8MTc1OTUzMDkxMnww&ixlib=rb-4.1.0&q=80&w=400',
      'distance': '2.5km',
      'matchRate': 92,
      'workoutTime': '晚上 7-9点',
      'preferences': ['力量训练', '瑜伽', '跑步'],
      'goal': '减脂塑形',
      'experience': '中级',
      'bio': '热爱运动的设计师，希望找到一起坚持健身的伙伴！每周至少4次训练，追求健康生活方式。',
      'rating': 4.8,
      'workouts': 156,
    },
    {
      'id': 2,
      'name': '张健康',
      'age': 28,
      'avatar': 'https://images.unsplash.com/photo-1607286908165-b8b6a2874fc4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwcG9ydHJhaXQlMjBhdGhsZXRlJTIwd29ya291dHxlbnwxfHx8fDE3NTk1MzA5MTV8MA&ixlib=rb-4.1.0&q=80&w=400',
      'distance': '1.8km',
      'matchRate': 85,
      'workoutTime': '早上 6-8点',
      'preferences': ['力量训练', 'CrossFit', '游泳'],
      'goal': '增肌',
      'experience': '高级',
      'bio': '健身教练，专注力量训练5年+。喜欢挑战自己，也乐于帮助健身新手。',
      'rating': 4.9,
      'workouts': 324,
    },
    {
      'id': 3,
      'name': '李小雅',
      'age': 23,
      'avatar': 'https://images.unsplash.com/photo-1669989179336-b2234d2878df?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwZ3ltJTIwd29ya291dCUyMG1vdGl2YXRpb258ZW58MXx8fHwxNzU5NTMwOTA5fDA&ixlib=rb-4.1.0&q=80&w=400',
      'distance': '3.2km',
      'matchRate': 78,
      'workoutTime': '下午 2-4点',
      'preferences': ['瑜伽', '普拉提', '舞蹈'],
      'goal': '塑形',
      'experience': '初级',
      'bio': '刚开始健身的大学生，希望找到耐心的健身伙伴一起进步。',
      'rating': 4.6,
      'workouts': 42,
    },
  ];

  void _handleSwipe(String direction) {
    setState(() {
      _swipeDirection = direction;
    });
    
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _currentCardIndex = (_currentCardIndex + 1) % _mates.length;
        _swipeDirection = '';
      });
    });
  }

  void _showMateDetails(Map<String, dynamic> mate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
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
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundImage: CachedNetworkImageProvider(mate['avatar']),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${mate['name']}, ${mate['age']}',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      mate['distance'],
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${mate['rating']}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Match Rate
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '匹配度',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.green[800],
                                  ),
                                ),
                                Text(
                                  '${mate['matchRate']}%',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.green[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: mate['matchRate'] / 100,
                              backgroundColor: Colors.green[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                              minHeight: 6,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Bio
                      Text(
                        '个人介绍',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mate['bio'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Workout Info
                      Text(
                        '健身信息',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              context,
                              Icons.flag,
                              '目标',
                              mate['goal'],
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              context,
                              Icons.star,
                              '经验',
                              mate['experience'],
                              Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              context,
                              Icons.access_time,
                              '时间',
                              mate['workoutTime'],
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              context,
                              Icons.fitness_center,
                              '训练',
                              '${mate['workouts']}次',
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Preferences
                      Text(
                        '运动偏好',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (mate['preferences'] as List<String>).map((pref) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              pref,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.green[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Action Button
                      CustomButton(
                        text: '发起搭子邀请',
                        onPressed: () {
                          Navigator.pop(context);
                          // Send invitation
                        },
                        isIOS: context.watch<ThemeProvider>().themeType == ThemeType.ios,
                        backgroundColor: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isIOS = themeProvider.themeType == ThemeType.ios;

    if (_mates.isEmpty) return const SizedBox();

    final currentMate = _mates[_currentCardIndex];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[200]!,
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '搭子',
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: isIOS ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '滑动卡片寻找你的健身伙伴',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          CustomIconButton(
                            icon: Icons.person_add,
                            onPressed: () {},
                            isIOS: isIOS,
                          ),
                          const SizedBox(width: 12),
                          Stack(
                            children: [
                              CustomIconButton(
                                icon: Icons.message,
                                onPressed: () {},
                                isIOS: isIOS,
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tabs
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'AI推荐',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '搭子',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Card Stack
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    // Background Card
                    if (_currentCardIndex < _mates.length - 1)
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.only(top: 8, left: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Main Card
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      top: _swipeDirection == 'left' ? 0 : 0,
                      left: _swipeDirection == 'left' ? -300 : (_swipeDirection == 'right' ? 300 : 0),
                      right: _swipeDirection == 'right' ? -300 : (_swipeDirection == 'left' ? 300 : 0),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _swipeDirection.isEmpty ? 1.0 : 0.0,
                        child: GestureDetector(
                          onTap: () => _showMateDetails(currentMate),
                          child: Container(
                            height: 500,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  // Background Image
                                  Positioned.fill(
                                    child: CachedNetworkImage(
                                      imageUrl: currentMate['avatar'],
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  // Gradient Overlay
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.6),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  // Content
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${currentMate['name']}, ${currentMate['age']}',
                                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: Text(
                                                  '${currentMate['matchRate']}%',
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          
                                          const SizedBox(height: 12),
                                          
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                color: Colors.white.withOpacity(0.8),
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                currentMate['distance'],
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: Colors.white.withOpacity(0.8),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Icon(
                                                Icons.access_time,
                                                color: Colors.white.withOpacity(0.8),
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                currentMate['workoutTime'],
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: Colors.white.withOpacity(0.8),
                                                ),
                                              ),
                                            ],
                                          ),
                                          
                                          const SizedBox(height: 12),
                                          
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: (currentMate['preferences'] as List<String>).take(3).map((pref) {
                                              return Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Colors.white.withOpacity(0.3),
                                                  ),
                                                ),
                                                child: Text(
                                                  pref,
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                          
                                          const SizedBox(height: 12),
                                          
                                          Text(
                                            currentMate['bio'],
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.white.withOpacity(0.9),
                                              height: 1.4,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  // Detail Button
                                  Positioned(
                                    top: 16,
                                    right: 16,
                                    child: GestureDetector(
                                      onTap: () => _showMateDetails(currentMate),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Icon(
                                          Icons.info_outline,
                                          color: Colors.grey[700],
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _handleSwipe('left'),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[300]!, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.grey[600],
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () => _handleSwipe('right'),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
