import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/providers.dart';
import '../../../core/router/app_router.dart';
import 'package:go_router/go_router.dart';

class TestApiPage extends ConsumerStatefulWidget {
  const TestApiPage({super.key});

  @override
  ConsumerState<TestApiPage> createState() => _TestApiPageState();
}

class _TestApiPageState extends ConsumerState<TestApiPage> {
  @override
  void initState() {
    super.initState();
    // 页面加载时获取数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workoutProvider.notifier).loadWorkouts();
      ref.read(communityProvider.notifier).loadPosts();
      ref.read(checkinProvider.notifier).loadCheckins();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final workoutState = ref.watch(workoutProvider);
    final communityState = ref.watch(communityProvider);
    final checkinState = ref.watch(checkinProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('API 测试页面'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '用户信息',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (authState.user != null) ...[
                      Text('用户名: ${authState.user!.username}'),
                      Text('邮箱: ${authState.user!.email}'),
                      Text('总训练次数: ${authState.user!.totalWorkouts}'),
                      Text('总签到次数: ${authState.user!.totalCheckins}'),
                      Text('当前连续签到: ${authState.user!.currentStreak}天'),
                    ] else
                      const Text('未登录'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 训练记录卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '训练记录',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ref.read(workoutProvider.notifier).loadWorkouts();
                          },
                          child: const Text('刷新'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (workoutState.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (workoutState.error != null)
                      Text(
                        '错误: ${workoutState.error}',
                        style: const TextStyle(color: Colors.red),
                      )
                    else if (workoutState.workouts.isEmpty)
                      const Text('暂无训练记录')
                    else
                      ...workoutState.workouts.take(3).map((workout) => ListTile(
                            title: Text(workout.name),
                            subtitle: Text('${workout.type} - ${workout.duration}分钟'),
                            trailing: Text('${workout.calories}卡路里'),
                          )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 社区动态卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '社区动态',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ref.read(communityProvider.notifier).loadPosts();
                          },
                          child: const Text('刷新'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (communityState.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (communityState.error != null)
                      Text(
                        '错误: ${communityState.error}',
                        style: const TextStyle(color: Colors.red),
                      )
                    else if (communityState.posts.isEmpty)
                      const Text('暂无动态')
                    else
                      ...communityState.posts.take(3).map((post) => ListTile(
                            title: Text(post.content.length > 50 
                                ? '${post.content.substring(0, 50)}...' 
                                : post.content),
                            subtitle: Text('${post.likesCount} 赞 ${post.commentsCount} 评论'),
                            trailing: Text(post.user?.username ?? '未知用户'),
                          )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 签到记录卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '签到记录',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ref.read(checkinProvider.notifier).loadCheckins();
                          },
                          child: const Text('刷新'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (checkinState.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (checkinState.error != null)
                      Text(
                        '错误: ${checkinState.error}',
                        style: const TextStyle(color: Colors.red),
                      )
                    else if (checkinState.checkins.isEmpty)
                      const Text('暂无签到记录')
                    else
                      ...checkinState.checkins.take(3).map((checkin) => ListTile(
                            title: Text(checkin.type),
                            subtitle: Text(checkin.notes ?? '无备注'),
                            trailing: Text('${checkin.energy}/10 精力'),
                          )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 测试按钮
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API 测试',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final success = await ref
                                  .read(workoutProvider.notifier)
                                  .createWorkout(
                                    name: '测试训练',
                                    type: '力量训练',
                                    duration: 30,
                                    calories: 200,
                                    difficulty: '初级',
                                    notes: 'API测试训练',
                                  );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success ? '训练记录创建成功' : '创建失败'),
                                    backgroundColor: success ? Colors.green : Colors.red,
                                  ),
                                );
                              }
                            },
                            child: const Text('创建训练'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final success = await ref
                                  .read(checkinProvider.notifier)
                                  .createCheckin(
                                    type: '训练',
                                    notes: 'API测试签到',
                                    energy: 8,
                                    motivation: 9,
                                  );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success ? '签到成功' : '签到失败'),
                                    backgroundColor: success ? Colors.green : Colors.red,
                                  ),
                                );
                              }
                            },
                            child: const Text('创建签到'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
