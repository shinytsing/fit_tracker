import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/models.dart';
import '../providers/community_provider.dart';

class UserSearchBar extends ConsumerStatefulWidget {
  final Function(User)? onUserSelected;
  final String? hintText;
  final Function(String)? onSearch;
  
  const UserSearchBar({
    super.key,
    this.onUserSelected,
    this.hintText,
    this.onSearch,
  });

  @override
  ConsumerState<UserSearchBar> createState() => _UserSearchBarState();
}

class _UserSearchBarState extends ConsumerState<UserSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;
  List<User> _searchResults = [];
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query != _currentQuery) {
      _currentQuery = query;
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        setState(() {
          _isSearching = false;
          _searchResults.clear();
        });
      }
    }
  }

  void _performSearch(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      // TODO: 调用实际的搜索API
      await Future.delayed(const Duration(milliseconds: 500)); // 模拟网络延迟
      
      // 模拟搜索结果
      final mockResults = _generateMockSearchResults(query);
      
      if (mounted) {
        setState(() {
          _searchResults = mockResults;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults.clear();
        });
      }
    }
  }

  List<User> _generateMockSearchResults(String query) {
    // 模拟搜索结果
    return List.generate(5, (index) => User(
      id: 'user_${index + 1}',
      username: '${query}_user_${index + 1}',
      email: 'user${index + 1}@example.com',
      firstName: '用户',
      lastName: '${index + 1}',
      avatar: 'https://via.placeholder.com/100',
      bio: '这是用户${index + 1}的个人简介',
      fitnessTags: '健身, 跑步, 瑜伽',
      fitnessGoal: '减脂',
      location: '北京',
      isVerified: index % 3 == 0,
      followersCount: (index + 1) * 100,
      followingCount: (index + 1) * 50,
      totalWorkouts: (index + 1) * 20,
      totalCheckins: (index + 1) * 15,
      currentStreak: (index + 1) * 3,
      longestStreak: (index + 1) * 10,
      createdAt: DateTime.now().subtract(Duration(days: (index + 1) * 30)),
      updatedAt: DateTime.now(),
      nickname: '${query}_用户${index + 1}',
      isOnline: index % 2 == 0,
      likesCount: (index + 1) * 200,
      trainingDays: (index + 1) * 25,
      level: (index + 1) * 2,
      points: (index + 1) * 500,
      lastLoginAt: DateTime.now().subtract(Duration(hours: index)),
      totalTrainingMinutes: (index + 1) * 1000,
      completedWorkouts: (index + 1) * 30,
      achievementsCount: (index + 1) * 5,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 搜索输入框
        Container(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.hintText ?? '搜索用户...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _focusNode.unfocus();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                _performSearch(value.trim());
              }
            },
          ),
        ),
        
        // 搜索结果
        if (_currentQuery.isNotEmpty) ...[
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            child: _buildSearchResults(),
          ),
        ],
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '未找到相关用户',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '试试其他关键词',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _buildUserItem(user);
      },
    );
  }

  Widget _buildUserItem(User user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.avatar?.isNotEmpty == true
            ? NetworkImage(user.avatar!)
            : null,
        child: user.avatar?.isEmpty != false
            ? Text(
                user.nickname?.isNotEmpty == true 
                    ? user.nickname![0].toUpperCase()
                    : 'U',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              user.nickname ?? user.username,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (user.isVerified)
            Icon(
              Icons.verified,
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user.bio?.isNotEmpty == true)
            Text(
              user.bio!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600]),
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildStatChip('${user.followersCount} 粉丝'),
              const SizedBox(width: 8),
              _buildStatChip('${user.totalWorkouts} 训练'),
            ],
          ),
        ],
      ),
      trailing: ElevatedButton(
        onPressed: () {
          widget.onUserSelected?.call(user);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text('关注'),
      ),
      onTap: () {
        // TODO: 导航到用户详情页面
        Navigator.pushNamed(
          context,
          '/community/user-profile',
          arguments: {'userId': user.id},
        );
      },
    );
  }

  Widget _buildStatChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
