import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../providers/theme_provider.dart';
import '../../widgets/custom_button.dart';

class FeedList extends StatelessWidget {
  const FeedList({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isIOS = themeProvider.themeType == ThemeType.ios;

    final posts = [
      {
        'user': {
          'name': '健身达人小王',
          'avatar': 'https://images.unsplash.com/photo-1607286908165-b8b6a2874fc4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwcG9ydHJhaXQlMjBhdGhsZXRlJTIwd29ya291dHxlbnwxfHx8fDE3NTk1MzA5MTV8MA&ixlib=rb-4.1.0&q=80&w=400',
          'verified': true,
        },
        'content': '今天完成了胸肌训练，感觉状态很好！坚持就是胜利💪',
        'image': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxneW0lMjB3b3Jrb3V0JTIwZXhlcmNpc2V8ZW58MXx8fHwxNzU5NTMwOTA5fDA&ixlib=rb-4.1.0&q=80&w=400',
        'time': '2小时前',
        'likes': 128,
        'comments': 23,
        'isLiked': true,
      },
      {
        'user': {
          'name': '瑜伽小姐姐',
          'avatar': 'https://images.unsplash.com/photo-1669989179336-b2234d2878df?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwZ3ltJTIwd29ya291dCUyMG1vdGl2YXRpb258ZW58MXx8fHwxNzU5NTMwOTA5fDA&ixlib=rb-4.1.0&q=80&w=400',
          'verified': false,
        },
        'content': '清晨的瑜伽练习，让身心都得到了放松。新的一天，新的开始！',
        'image': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b2dhJTIwd29tYW4lMjBleGVyY2lzZXxlbnwxfHx8fDE3NTk1MzA5MTJ8MA&ixlib=rb-4.1.0&q=80&w=400',
        'time': '4小时前',
        'likes': 89,
        'comments': 15,
        'isLiked': false,
      },
      {
        'user': {
          'name': '跑步爱好者',
          'avatar': 'https://images.unsplash.com/photo-1541338784564-51087dabc0de?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwd29tYW4lMjB0cmFpbmluZyUyMGV4ZXJjaXNlfGVufDF8fHx8MTc1OTUzMDkxMnww&ixlib=rb-4.1.0&q=80&w=400',
          'verified': true,
        },
        'content': '完成了10公里跑步，虽然很累但是很有成就感！',
        'image': 'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxydW5uaW5nJTIwdHJhaW5pbmclMjBleGVyY2lzZXxlbnwxfHx8fDE3NTk1MzA5MTJ8MA&ixlib=rb-4.1.0&q=80&w=400',
        'time': '6小时前',
        'likes': 156,
        'comments': 31,
        'isLiked': true,
      },
    ];

    return Column(
      children: posts.asMap().entries.map((entry) {
        final index = entry.key;
        final post = entry.value;
        final user = post['user'] as Map<String, dynamic>;
        final isLiked = post['isLiked'] as bool;
        
        return Container(
          margin: EdgeInsets.only(bottom: index < posts.length - 1 ? 16 : 0),
          child: CustomCard(
            isIOS: isIOS,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: CachedNetworkImageProvider(user['avatar']),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                        Text(
                          user['name'] as String,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                              if (user['verified'])
                                const SizedBox(width: 4),
                              if (user['verified'])
                                Icon(
                                  Icons.verified,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            post['time'] as String,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.more_horiz,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Content
                  Text(
                    post['content'] as String,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                
                const SizedBox(height: 12),
                
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: post['image'] as String,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Actions
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Toggle like
                      },
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post['likes']}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () {
                        // Open comments
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post['comments']}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () {
                        // Share
                      },
                      child: Icon(
                        Icons.share_outlined,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
