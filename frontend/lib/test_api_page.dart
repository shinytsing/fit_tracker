import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/network/api_service.dart';

class TestApiPage extends ConsumerStatefulWidget {
  const TestApiPage({super.key});

  @override
  ConsumerState<TestApiPage> createState() => _TestApiPageState();
}

class _TestApiPageState extends ConsumerState<TestApiPage> {
  String _result = '点击按钮测试API';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API测试页面'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // AI推荐训练计划按钮
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testAIRecommendation,
              icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.psychology),
              label: Text(_isLoading ? 'AI生成中...' : 'AI推荐训练计划'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 获取训练计划列表按钮
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testGetTrainingPlans,
              icon: const Icon(Icons.list),
              label: const Text('获取训练计划列表'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 获取搭子团队列表按钮
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testGetTeams,
              icon: const Icon(Icons.group),
              label: const Text('获取搭子团队列表'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 获取聊天列表按钮
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testGetChats,
              icon: const Icon(Icons.chat),
              label: const Text('获取聊天列表'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 结果显示区域
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _result,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testAIRecommendation() async {
    setState(() {
      _isLoading = true;
      _result = '正在调用AI推荐API...';
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.post('/training/ai-generate', data: {
        'goal': '减脂塑形',
        'duration': 30,
        'difficulty': '中级',
        'equipment': ['哑铃', '杠铃', '跑步机'],
        'focus_areas': ['全身', '核心']
      });

      setState(() {
        _result = 'AI推荐API调用成功！\n\n响应数据:\n${response.data}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result = 'AI推荐API调用失败:\n$e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testGetTrainingPlans() async {
    setState(() {
      _isLoading = true;
      _result = '正在获取训练计划列表...';
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/training/plans');

      setState(() {
        _result = '获取训练计划列表成功！\n\n响应数据:\n${response.data}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result = '获取训练计划列表失败:\n$e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testGetTeams() async {
    setState(() {
      _isLoading = true;
      _result = '正在获取搭子团队列表...';
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/teams');

      setState(() {
        _result = '获取搭子团队列表成功！\n\n响应数据:\n${response.data}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result = '获取搭子团队列表失败:\n$e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testGetChats() async {
    setState(() {
      _isLoading = true;
      _result = '正在获取聊天列表...';
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/messages/chats');

      setState(() {
        _result = '获取聊天列表成功！\n\n响应数据:\n${response.data}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result = '获取聊天列表失败:\n$e';
        _isLoading = false;
      });
    }
  }
}
