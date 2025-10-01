import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitTracker API Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ApiTestPage(),
    );
  }
}

class ApiTestPage extends StatefulWidget {
  @override
  _ApiTestPageState createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final Dio _dio = Dio();
  String _status = '未测试';
  List<Map<String, dynamic>> _posts = [];
  Map<String, dynamic>? _trainingPlan;

  @override
  void initState() {
    super.initState();
    _testApi();
  }

  Future<void> _testApi() async {
    try {
      setState(() {
        _status = '测试中...';
      });

      // 测试健康检查
      final healthResponse = await _dio.get('http://localhost:8080/health');
      print('健康检查: ${healthResponse.data}');

      // 测试社区帖子API
      final postsResponse = await _dio.get('http://localhost:8080/api/v1/community/posts');
      print('社区帖子: ${postsResponse.data}');
      
      setState(() {
        _posts = List<Map<String, dynamic>>.from(postsResponse.data['posts'] ?? []);
      });

      // 测试AI训练计划生成
      final trainingResponse = await _dio.post(
        'http://localhost:8080/api/v1/ai/training-plan',
        data: {
          'goal': '增肌',
          'duration': 30,
          'difficulty': '中级',
          'equipment': ['哑铃', '杠铃'],
          'time_per_day': 60,
          'preferences': '力量训练'
        },
      );
      print('AI训练计划: ${trainingResponse.data}');
      
      setState(() {
        _trainingPlan = trainingResponse.data;
        _status = '测试成功！';
      });

    } catch (e) {
      print('API测试失败: $e');
      setState(() {
        _status = '测试失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FitTracker API 测试'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API 状态',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(_status),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _testApi,
                      child: Text('重新测试'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            if (_posts.isNotEmpty) ...[
              Text(
                '社区帖子 (${_posts.length}条)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    return Card(
                      child: ListTile(
                        title: Text(post['content'] ?? '无内容'),
                        subtitle: Text('作者: ${post['author_name'] ?? '未知'}'),
                        trailing: Text('${post['like_count'] ?? 0} 赞'),
                      ),
                    );
                  },
                ),
              ),
            ],
            if (_trainingPlan != null) ...[
              SizedBox(height: 16),
              Text(
                'AI训练计划',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('目标: ${_trainingPlan!['goal'] ?? '未知'}'),
                      Text('时长: ${_trainingPlan!['duration'] ?? '未知'}天'),
                      Text('难度: ${_trainingPlan!['difficulty'] ?? '未知'}'),
                      if (_trainingPlan!['exercises'] != null) ...[
                        SizedBox(height: 8),
                        Text('训练动作:'),
                        ...(_trainingPlan!['exercises'] as List).map((exercise) => 
                          Text('  - ${exercise['name'] ?? '未知动作'}')).toList(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}