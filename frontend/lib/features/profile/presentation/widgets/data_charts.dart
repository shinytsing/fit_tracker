import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';

/// 数据图表组件
/// 显示用户训练数据的各种图表
class DataCharts extends StatelessWidget {
  final ChartData chartData;
  final Function(String) onChartTap;

  const DataCharts({
    super.key,
    required this.chartData,
    required this.onChartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '数据趋势',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // BMI趋势图
        _buildChartCard(
          'BMI趋势',
          '体重指数变化',
          MdiIcons.chartLine,
          Colors.blue,
          'bmi_trend',
          _buildBMITrendChart(),
        ),
        
        const SizedBox(height: 16),
        
        // 训练时长趋势
        _buildChartCard(
          '训练时长',
          '每日训练时长',
          MdiIcons.clockOutline,
          Colors.orange,
          'training_duration',
          _buildTrainingDurationChart(),
        ),
        
        const SizedBox(height: 16),
        
        // 卡路里消耗趋势
        _buildChartCard(
          '卡路里消耗',
          '每日消耗卡路里',
          MdiIcons.fire,
          Colors.red,
          'calories_burned',
          _buildCaloriesChart(),
        ),
        
        const SizedBox(height: 16),
        
        // 训练频率统计
        _buildChartCard(
          '训练频率',
          '每周训练次数',
          MdiIcons.calendarWeek,
          Colors.green,
          'workout_frequency',
          _buildWorkoutFrequencyChart(),
        ),
        
        const SizedBox(height: 16),
        
        // 动作类型分布
        _buildChartCard(
          '动作分布',
          '训练动作类型分布',
          MdiIcons.chartPie,
          Colors.purple,
          'exercise_distribution',
          _buildExerciseDistributionChart(),
        ),
      ],
    );
  }

  /// 构建图表卡片
  Widget _buildChartCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String chartType,
    Widget chartWidget,
  ) {
    return GestureDetector(
      onTap: () => onChartTap(chartType),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图表标题
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 图表内容
            SizedBox(
              height: 200,
              child: chartWidget,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建BMI趋势图
  Widget _buildBMITrendChart() {
    if (chartData.bmiData.isEmpty) {
      return _buildEmptyChart('暂无BMI数据');
    }
    
    return CustomPaint(
      painter: BMITrendPainter(chartData.bmiData),
      child: Container(),
    );
  }

  /// 构建训练时长图表
  Widget _buildTrainingDurationChart() {
    if (chartData.trainingDurationData.isEmpty) {
      return _buildEmptyChart('暂无训练时长数据');
    }
    
    return CustomPaint(
      painter: TrainingDurationPainter(chartData.trainingDurationData),
      child: Container(),
    );
  }

  /// 构建卡路里图表
  Widget _buildCaloriesChart() {
    if (chartData.caloriesData.isEmpty) {
      return _buildEmptyChart('暂无卡路里数据');
    }
    
    return CustomPaint(
      painter: CaloriesPainter(chartData.caloriesData),
      child: Container(),
    );
  }

  /// 构建训练频率图表
  Widget _buildWorkoutFrequencyChart() {
    if (chartData.workoutFrequencyData.isEmpty) {
      return _buildEmptyChart('暂无训练频率数据');
    }
    
    return CustomPaint(
      painter: WorkoutFrequencyPainter(chartData.workoutFrequencyData),
      child: Container(),
    );
  }

  /// 构建动作分布图表
  Widget _buildExerciseDistributionChart() {
    if (chartData.exerciseDistributionData.isEmpty) {
      return _buildEmptyChart('暂无动作分布数据');
    }
    
    return CustomPaint(
      painter: ExerciseDistributionPainter(chartData.exerciseDistributionData),
      child: Container(),
    );
  }

  /// 构建空图表
  Widget _buildEmptyChart(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            MdiIcons.chartLine,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

/// BMI趋势图绘制器
class BMITrendPainter extends CustomPainter {
  final List<ChartDataPoint> data;

  BMITrendPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    // 计算坐标
    final minValue = data.map((d) => d.value).reduce((a, b) => a < b ? a : b);
    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final valueRange = maxValue - minValue;
    final padding = 20.0;

    for (int i = 0; i < data.length; i++) {
      final x = padding + (size.width - 2 * padding) * i / (data.length - 1);
      final y = size.height - padding - (data[i].value - minValue) / valueRange * (size.height - 2 * padding);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      
      // 绘制数据点
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 训练时长图表绘制器
class TrainingDurationPainter extends CustomPainter {
  final List<ChartDataPoint> data;

  TrainingDurationPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.orange.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // 计算坐标
    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final padding = 20.0;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = padding + (size.width - 2 * padding) * i / (data.length - 1);
      final y = size.height - padding - data[i].value / maxValue * (size.height - 2 * padding);
      
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height - padding);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width - padding, size.height - padding);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 卡路里图表绘制器
class CaloriesPainter extends CustomPainter {
  final List<ChartDataPoint> data;

  CaloriesPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.red.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // 计算坐标
    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final padding = 20.0;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = padding + (size.width - 2 * padding) * i / (data.length - 1);
      final y = size.height - padding - data[i].value / maxValue * (size.height - 2 * padding);
      
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height - padding);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width - padding, size.height - padding);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 训练频率图表绘制器
class WorkoutFrequencyPainter extends CustomPainter {
  final List<ChartDataPoint> data;

  WorkoutFrequencyPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.green.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // 计算坐标
    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final padding = 20.0;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = padding + (size.width - 2 * padding) * i / (data.length - 1);
      final y = size.height - padding - data[i].value / maxValue * (size.height - 2 * padding);
      
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height - padding);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width - padding, size.height - padding);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 动作分布图表绘制器
class ExerciseDistributionPainter extends CustomPainter {
  final List<ChartDataPoint> data;

  ExerciseDistributionPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width < size.height ? size.width : size.height) / 2 - 20;
    
    final total = data.map((d) => d.value).reduce((a, b) => a + b);
    double startAngle = -90 * (3.14159 / 180); // 从顶部开始

    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i].value / total) * 2 * 3.14159;
      
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
