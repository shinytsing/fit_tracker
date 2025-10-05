import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/rest_provider.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import 'rest_post_card.dart';

class RestFeedWidget extends ConsumerStatefulWidget {
  final RestFeed? restFeed;
  final bool isLoading;
  final VoidCallback onRefresh;
  final Function(int postId) onLike;
  final Function(int postId, String content) onComment;

  const RestFeedWidget({
    super.key,
    this.restFeed,
    required this.isLoading,
    required this.onRefresh,
    required this.onLike,
    required this.onComment,
  });

  @override
  ConsumerState<RestFeedWidget> createState() => _RestFeedWidgetState();
}

class _RestFeedWidgetState extends ConsumerState<RestFeedWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // 加载更多
      ref.read(restProvider.notifier).loadRestFeed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final restState = ref.watch(restProvider);
    
    if (widget.isLoading && widget.restFeed == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (restState.error != null && widget.restFeed == null) {
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
              '加载失败',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              restState.error!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(restProvider.notifier).clearError();
                widget.onRefresh();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    final feed = widget.restFeed;
    if (feed == null) {
      return const Center(
        child: Text('暂无动态'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        widget.onRefresh();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _getItemCount(feed, restState),
        itemBuilder: (context, index) {
          return _buildFeedItem(feed, index);
        },
      ),
    );
  }

  int _getItemCount(RestFeed feed, RestState restState) {
    int count = feed.posts.length;
    
    // 添加段子
    if (feed.jokes.isNotEmpty) {
      count += 1; // 段子标题
      count += feed.jokes.length;
    }
    
    // 添加知识卡片
    if (feed.knowledge.isNotEmpty) {
      count += 1; // 知识卡片标题
      count += feed.knowledge.length;
    }
    
    // 添加加载更多指示器
    if (restState.hasMore) {
      count += 1;
    }
    
    return count;
  }

  Widget _buildFeedItem(RestFeed feed, int index) {
    int currentIndex = 0;
    
    // 用户动态
    if (index < feed.posts.length) {
      return RestPostCard(
        post: feed.posts[index],
        onLike: () => widget.onLike(feed.posts[index].id),
        onComment: (content) => widget.onComment(feed.posts[index].id, content),
      );
    }
    currentIndex += feed.posts.length;
    
    // 段子标题
    if (feed.jokes.isNotEmpty) {
      if (index == currentIndex) {
        return _buildSectionTitle('😄 健身段子');
      }
      currentIndex += 1;
      
      // 段子内容
      if (index < currentIndex + feed.jokes.length) {
        final jokeIndex = index - currentIndex;
        return RestPostCard(
          post: feed.jokes[jokeIndex],
          onLike: () => widget.onLike(feed.jokes[jokeIndex].id),
          onComment: (content) => widget.onComment(feed.jokes[jokeIndex].id, content),
        );
      }
      currentIndex += feed.jokes.length;
    }
    
    // 知识卡片标题
    if (feed.knowledge.isNotEmpty) {
      if (index == currentIndex) {
        return _buildSectionTitle('💡 健身知识');
      }
      currentIndex += 1;
      
      // 知识卡片内容
      if (index < currentIndex + feed.knowledge.length) {
        final knowledgeIndex = index - currentIndex;
        return RestPostCard(
          post: feed.knowledge[knowledgeIndex],
          onLike: () => widget.onLike(feed.knowledge[knowledgeIndex].id),
          onComment: (content) => widget.onComment(feed.knowledge[knowledgeIndex].id, content),
        );
      }
      currentIndex += feed.knowledge.length;
    }
    
    // 加载更多指示器
    if (ref.watch(restProvider).hasMore && index == currentIndex) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Colors.grey[300],
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: Colors.grey[300],
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
