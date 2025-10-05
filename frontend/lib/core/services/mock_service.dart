import 'dart:math';
import 'package:flutter/material.dart';

/// Mock 数据服务 - 用于前端自测
class MockService {
  static final Random _random = Random();
  
  /// 生成 Mock 用户数据
  static Map<String, dynamic> generateMockUser() {
    return {
      'id': 'user_${_random.nextInt(1000)}',
      'email': 'test@example.com',
      'name': '测试用户',
      'nickname': '健身达人${_random.nextInt(100)}',
      'avatar': 'https://via.placeholder.com/100',
      'createdAt': DateTime.now().subtract(Duration(days: _random.nextInt(365))),
      'lastLoginAt': DateTime.now(),
      'isVerified': _random.nextBool(),
      'followersCount': _random.nextInt(1000),
      'followingCount': _random.nextInt(500),
      'postsCount': _random.nextInt(100),
    };
  }
  
  /// 生成 Mock 训练计划
  static List<Map<String, dynamic>> generateMockTrainingPlans() {
    final exercises = [
      {'name': '平板卧推', 'muscle': '胸肌', 'sets': 3, 'reps': 12, 'weight': 60},
      {'name': '深蹲', 'muscle': '腿部', 'sets': 4, 'reps': 15, 'weight': 80},
      {'name': '引体向上', 'muscle': '背部', 'sets': 3, 'reps': 8, 'weight': 0},
      {'name': '硬拉', 'muscle': '背部', 'sets': 3, 'reps': 10, 'weight': 100},
      {'name': '肩推', 'muscle': '肩部', 'sets': 3, 'reps': 12, 'weight': 25},
    ];
    
    return List.generate(5, (index) {
      return {
        'id': 'plan_$index',
        'name': '训练计划 ${index + 1}',
        'description': '专注于${exercises[index]['muscle']}的力量训练',
        'difficulty': ['初级', '中级', '高级'][index % 3],
        'duration': 30 + (index * 15),
        'exercises': exercises.take(3).toList(),
        'createdAt': DateTime.now().subtract(Duration(days: index)),
        'isCompleted': index % 2 == 0,
        'progress': _random.nextInt(100),
      };
    });
  }
  
  /// 生成 Mock 社区帖子
  static List<Map<String, dynamic>> generateMockPosts() {
    final contents = [
      '今天完成了胸肌训练，感觉棒极了！💪',
      '坚持健身一个月，体重减了5kg，继续加油！',
      '分享一个超有效的腹肌训练动作',
      '健身房遇到了一位很棒的训练伙伴',
      '今天挑战了新的重量，突破了自己的极限！',
      '健身不仅改变了我的身材，更改变了我的心态',
      '推荐几个适合新手的训练动作',
      '坚持就是胜利，大家一起加油！',
    ];
    
    return List.generate(20, (index) {
      return {
        'id': 'post_$index',
        'content': contents[index % contents.length],
        'author': {
          'id': 'user_${_random.nextInt(100)}',
          'name': '用户${_random.nextInt(100)}',
          'avatar': 'https://via.placeholder.com/50',
          'isVerified': _random.nextBool(),
        },
        'images': _random.nextBool() ? [
          'https://via.placeholder.com/300x200',
          'https://via.placeholder.com/300x200',
        ] : [],
        'likesCount': _random.nextInt(100),
        'commentsCount': _random.nextInt(50),
        'sharesCount': _random.nextInt(20),
        'isLiked': _random.nextBool(),
        'isBookmarked': _random.nextBool(),
        'createdAt': DateTime.now().subtract(Duration(hours: _random.nextInt(72))),
        'tags': ['健身', '训练', '励志'][_random.nextInt(3)],
      };
    });
  }
  
  /// 生成 Mock 聊天消息
  static List<Map<String, dynamic>> generateMockChats() {
    return List.generate(10, (index) {
      return {
        'id': 'chat_$index',
        'name': '用户${index + 1}',
        'avatar': 'https://via.placeholder.com/40',
        'lastMessage': index % 3 == 0 
          ? '今天训练怎么样？' 
          : index % 3 == 1 
            ? '一起健身吧！' 
            : '加油！💪',
        'lastMessageTime': DateTime.now().subtract(Duration(hours: index)),
        'unreadCount': index % 4 == 0 ? 0 : index % 3,
        'isOnline': index % 2 == 0,
        'isPinned': index == 0,
        'isMuted': index == 1,
      };
    });
  }
  
  /// 生成 Mock 通知
  static List<Map<String, dynamic>> generateMockNotifications() {
    final types = ['like', 'comment', 'follow', 'workout', 'achievement'];
    final titles = [
      '有人点赞了你的帖子',
      '有人评论了你的帖子',
      '有人关注了你',
      '训练提醒',
      '获得新成就',
    ];
    
    return List.generate(15, (index) {
      return {
        'id': 'notification_$index',
        'title': titles[index % titles.length],
        'content': '用户${_random.nextInt(100)}${titles[index % titles.length]}',
        'type': types[index % types.length],
        'createdAt': DateTime.now().subtract(Duration(hours: index)),
        'isRead': index % 3 == 0,
        'avatar': 'https://via.placeholder.com/40',
      };
    });
  }
  
  /// 生成 Mock BMI 数据
  static Map<String, dynamic> generateMockBMIData() {
    final height = 170 + _random.nextInt(20); // 170-190cm
    final weight = 60 + _random.nextInt(30); // 60-90kg
    final bmi = weight / ((height / 100) * (height / 100));
    
    String category;
    if (bmi < 18.5) {
      category = '偏瘦';
    } else if (bmi < 24) {
      category = '正常';
    } else if (bmi < 28) {
      category = '偏胖';
    } else {
      category = '肥胖';
    }
    
    return {
      'height': height,
      'weight': weight,
      'bmi': double.parse(bmi.toStringAsFixed(1)),
      'category': category,
      'recommendation': _getBMIRecommendation(category),
      'lastUpdated': DateTime.now(),
    };
  }
  
  static String _getBMIRecommendation(String category) {
    switch (category) {
      case '偏瘦':
        return '建议增加营养摄入，进行力量训练增肌';
      case '正常':
        return '保持当前状态，继续规律运动';
      case '偏胖':
        return '建议控制饮食，增加有氧运动';
      case '肥胖':
        return '建议咨询专业医生，制定减重计划';
      default:
        return '请咨询专业医生';
    }
  }
  
  /// 生成 Mock 成就数据
  static List<Map<String, dynamic>> generateMockAchievements() {
    final achievements = [
      {'name': '初学者', 'description': '完成第一次训练', 'icon': '🏆', 'isUnlocked': true},
      {'name': '坚持者', 'description': '连续训练7天', 'icon': '🔥', 'isUnlocked': true},
      {'name': '力量王', 'description': '卧推重量达到100kg', 'icon': '💪', 'isUnlocked': false},
      {'name': '马拉松', 'description': '连续训练30天', 'icon': '🏃', 'isUnlocked': false},
      {'name': '社交达人', 'description': '获得100个赞', 'icon': '👍', 'isUnlocked': true},
      {'name': '导师', 'description': '帮助10个新手', 'icon': '👨‍🏫', 'isUnlocked': false},
    ];
    
    return achievements;
  }
  
  /// 模拟网络延迟
  static Future<void> simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));
  }
  
  /// 模拟 API 调用成功
  static Future<Map<String, dynamic>> mockApiCall(String endpoint) async {
    await simulateNetworkDelay();
    
    switch (endpoint) {
      case '/api/v1/user/profile':
        return {'statusCode': 200, 'data': generateMockUser()};
      case '/api/v1/training/plans':
        return {'statusCode': 200, 'data': generateMockTrainingPlans()};
      case '/api/v1/community/posts':
        return {'statusCode': 200, 'data': generateMockPosts()};
      case '/api/v1/messages/chats':
        return {'statusCode': 200, 'data': generateMockChats()};
      case '/api/v1/notifications':
        return {'statusCode': 200, 'data': generateMockNotifications()};
      case '/api/v1/bmi/calculate':
        return {'statusCode': 200, 'data': generateMockBMIData()};
      case '/api/v1/achievements':
        return {'statusCode': 200, 'data': generateMockAchievements()};
      default:
        return {'statusCode': 404, 'data': {}};
    }
  }
}

