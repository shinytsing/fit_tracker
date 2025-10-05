import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/rest_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/rest_timer_widget.dart';
import '../widgets/rest_feed_widget.dart';
import '../widgets/rest_input_widget.dart';

class RestModePage extends ConsumerStatefulWidget {
  const RestModePage({super.key});

  @override
  ConsumerState<RestModePage> createState() => _RestModePageState();
}

class _RestModePageState extends ConsumerState<RestModePage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // 加载组间动态流
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(restProvider.notifier).loadRestFeed();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          '组间休息',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: '休息计时'),
            Tab(text: '动态流'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          RestTimerTab(),
          RestFeedTab(),
        ],
      ),
    );
  }
}

class RestTimerTab extends ConsumerWidget {
  const RestTimerTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          RestTimerWidget(
            countdownSeconds: ref.watch(restProvider).remainingSeconds,
            isResting: ref.watch(restProvider).isResting,
            onStartRest: () => ref.read(restProvider.notifier).startRest(duration: 90),
            onCompleteRest: () => ref.read(restProvider.notifier).completeRest(),
          ),
          const SizedBox(height: 20),
          RestInputWidget(
            onPost: (content, imageUrl, type) {
              ref.read(restProvider.notifier).createRestPost(
                content: content,
                imageUrl: imageUrl,
                type: type,
              );
            },
            isLoading: ref.watch(restProvider).isLoading,
          ),
        ],
      ),
    );
  }
}

class RestFeedTab extends ConsumerWidget {
  const RestFeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RestFeedWidget(
      restFeed: ref.watch(restProvider).restFeed,
      isLoading: ref.watch(restProvider).isLoading,
      onRefresh: () => ref.read(restProvider.notifier).loadRestFeed(refresh: true),
      onLike: ref.read(restProvider.notifier).likeRestPost,
      onComment: (postId, content) => ref.read(restProvider.notifier).commentRestPost(postId: postId, content: content),
    );
  }
}
