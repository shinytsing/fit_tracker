import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/models.dart';
import '../providers/training_provider.dart';

class ProgressChart extends ConsumerWidget {
  final UserStats? stats;
  final ChartData? chartData;
  final List<TrainingHistory>? history;
  final Function(String)? onChartTap;
  
  const ProgressChart({
    super.key,
    this.stats,
    this.chartData,
    this.history,
    this.onChartTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingState = ref.watch(trainingProvider);
    final statsToShow = stats ?? trainingState.stats;
    final chartDataToShow = chartData ?? trainingState.chartData;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '训练进度',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButton<String>(
                value: 'week',
                items: const [
                  DropdownMenuItem(value: 'week', child: Text('本周')),
                  DropdownMenuItem(value: 'month', child: Text('本月')),
                  DropdownMenuItem(value: 'year', child: Text('今年')),
                ],
                onChanged: (value) {
                  // TODO: 切换时间范围
                },
              ),
            ],
          ),
        ),
        if (trainingState.isLoading)
          const Center(child: CircularProgressIndicator())
        else
          _buildChart(context, trainingState),
      ],
    );
  }

  Widget _buildChart(BuildContext context, TrainingState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 图表标题和统计
          _buildChartHeader(context, state),
          const SizedBox(height: 24),
          
          // 主要图表
          _buildMainChart(context, state),
          const SizedBox(height: 24),
          
          // 详细统计
          _buildDetailedStats(context, state),
        ],
      ),
    );
  }

  Widget _buildChartHeader(BuildContext context, TrainingState state) {
    final totalWorkouts = state.history.length;
    final totalMinutes = state.history.fold<int>(
      0, 
      (sum, history) => sum + history.duration,
    );
    final totalCalories = state.history.fold<int>(
      0, 
      (sum, history) => sum + history.caloriesBurned,
    );

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            '总训练',
            '$totalWorkouts',
            '次',
            Icons.fitness_center,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            '总时长',
            '${(totalMinutes / 60).toStringAsFixed(1)}',
            '小时',
            Icons.timer,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            '总消耗',
            '$totalCalories',
            '卡路里',
            Icons.whatshot,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainChart(BuildContext context, TrainingState state) {
    // 生成最近7天的数据
    final chartData = _generateWeeklyData(state);
    
    return Column(
      children: [
        Text(
          '最近7天训练时长',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: CustomPaint(
            painter: LineChartPainter(chartData),
            child: Container(),
          ),
        ),
        const SizedBox(height: 16),
        _buildChartLegend(context, chartData),
      ],
    );
  }

  Widget _buildChartLegend(BuildContext context, List<ChartDataPoint> data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: data.map((point) {
        final dayNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
        final dayIndex = point.date.weekday - 1;
        return Column(
          children: [
            Text(
              dayNames[dayIndex],
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${point.value.toInt()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDetailedStats(BuildContext context, TrainingState state) {
    return Column(
      children: [
        Text(
          '详细统计',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildProgressBar(
                context,
                '平均训练时长',
                '${_calculateAverageDuration(state)}分钟',
                _calculateAverageDuration(state) / 60, // 假设最大1小时
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildProgressBar(
                context,
                '平均消耗卡路里',
                '${_calculateAverageCalories(state)}卡',
                _calculateAverageCalories(state) / 500, // 假设最大500卡
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    String title,
    String value,
    double progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  List<ChartDataPoint> _generateWeeklyData(TrainingState state) {
    final now = DateTime.now();
    final List<ChartDataPoint> data = [];
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayHistory = state.history.where((history) {
        final historyDate = DateTime(
          history.completedAt.year,
          history.completedAt.month,
          history.completedAt.day,
        );
        final targetDate = DateTime(date.year, date.month, date.day);
        return historyDate == targetDate;
      }).toList();
      
      final totalMinutes = dayHistory.fold<int>(
        0, 
        (sum, history) => sum + history.duration,
      );
      
      data.add(ChartDataPoint(
        date: date,
        value: totalMinutes.toDouble(),
        label: '${date.month}/${date.day}',
      ));
    }
    
    return data;
  }

  int _calculateAverageDuration(TrainingState state) {
    if (state.history.isEmpty) return 0;
    final totalDuration = state.history.fold<int>(
      0, 
      (sum, history) => sum + history.duration,
    );
    return (totalDuration / state.history.length).round();
  }

  int _calculateAverageCalories(TrainingState state) {
    if (state.history.isEmpty) return 0;
    final totalCalories = state.history.fold<int>(
      0, 
      (sum, history) => sum + history.caloriesBurned,
    );
    return (totalCalories / state.history.length).round();
  }
}

class LineChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  
  LineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    
    // 计算数据范围
    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final minValue = 0.0;
    final valueRange = maxValue - minValue;
    
    // 防止除零和NaN值
    if (valueRange == 0 || valueRange.isNaN || valueRange.isInfinite) {
      return;
    }
    
    // 绘制路径
    final path = Path();
    final fillPath = Path();
    
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i].value - minValue) / valueRange) * size.height;
      
      // 检查坐标是否为有效值
      if (x.isNaN || y.isNaN || x.isInfinite || y.isInfinite) {
        continue;
      }
      
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
      
      // 绘制数据点
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
    
    // 填充区域
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);
    
    // 绘制线条
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
