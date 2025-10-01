import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/training/presentation/providers/training_provider.dart';

void main() {
  runApp(const ProviderScope(child: TestApp()));
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitTracker Test',
      theme: AppTheme.lightTheme,
      home: const TestHomePage(),
    );
  }
}

class TestHomePage extends ConsumerWidget {
  const TestHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingState = ref.watch(trainingProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitTracker Test'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'FitTracker 测试应用',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              '训练计划数量: ${trainingState.plans.length}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              '当前连胜: ${trainingState.currentStreak}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ref.read(trainingProvider.notifier).generateAiPlan();
              },
              child: Text(
                trainingState.isGeneratingAi ? '生成中...' : '生成AI训练计划',
              ),
            ),
            const SizedBox(height: 20),
            if (trainingState.error != null)
              Text(
                '错误: ${trainingState.error}',
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
