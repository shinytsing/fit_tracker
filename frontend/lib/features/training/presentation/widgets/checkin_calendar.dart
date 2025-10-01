import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/models.dart';
import '../providers/training_provider.dart';

class CheckInCalendar extends ConsumerWidget {
  final List<CheckIn>? checkIns;
  final int? currentStreak;
  final Function(CheckInType, String, List<String>, String?)? onCheckIn;
  
  const CheckInCalendar({
    super.key,
    this.checkIns,
    this.currentStreak,
    this.onCheckIn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingState = ref.watch(trainingProvider);
    final checkInsToShow = checkIns ?? trainingState.checkIns;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '签到日历',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: 导航到完整日历页面
                },
                child: const Text('查看全部'),
              ),
            ],
          ),
        ),
        if (trainingState.isLoading)
          const Center(child: CircularProgressIndicator())
        else
          _buildCalendar(context, trainingState.checkIns),
      ],
    );
  }

  Widget _buildCalendar(BuildContext context, List<CheckIn> checkIns) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final firstDayOfMonth = currentMonth;
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    
    // 创建签到日期集合
    final checkInDates = checkIns.map((checkIn) => 
        DateTime(checkIn.checkInTime.year, checkIn.checkInTime.month, checkIn.checkInTime.day)
    ).toSet();

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
          // 月份标题
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${now.year}年${now.month}月',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // TODO: 切换到上个月
                    },
                    icon: const Icon(Icons.chevron_left),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: 切换到下个月
                    },
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 星期标题
          Row(
            children: ['一', '二', '三', '四', '五', '六', '日']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          
          // 日历网格
          _buildCalendarGrid(context, firstWeekday, lastDayOfMonth.day, checkInDates),
          
          const SizedBox(height: 16),
          
          // 签到统计
          _buildCheckInStats(context, checkIns),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context, int firstWeekday, int daysInMonth, Set<DateTime> checkInDates) {
    final List<Widget> calendarDays = [];
    
    // 添加空白日期（月初）
    for (int i = 1; i < firstWeekday; i++) {
      calendarDays.add(const SizedBox());
    }
    
    // 添加月份中的日期
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(DateTime.now().year, DateTime.now().month, day);
      final isToday = date.day == DateTime.now().day && 
                     date.month == DateTime.now().month && 
                     date.year == DateTime.now().year;
      final hasCheckIn = checkInDates.contains(date);
      
      calendarDays.add(
        GestureDetector(
          onTap: () {
            if (!hasCheckIn) {
              _showCheckInDialog(context, date);
            }
          },
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: hasCheckIn 
                  ? Theme.of(context).primaryColor
                  : isToday 
                      ? Theme.of(context).primaryColor.withOpacity(0.2)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: isToday 
                  ? Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    )
                  : null,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: hasCheckIn 
                      ? Colors.white
                      : isToday 
                          ? Theme.of(context).primaryColor
                          : Colors.black87,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    return Wrap(
      children: calendarDays.map((day) => 
          SizedBox(
            width: MediaQuery.of(context).size.width / 7 - 8,
            child: day,
          )
      ).toList(),
    );
  }

  Widget _buildCheckInStats(BuildContext context, List<CheckIn> checkIns) {
    final now = DateTime.now();
    final currentMonthCheckIns = checkIns.where((checkIn) => 
        checkIn.checkInTime.year == now.year && 
        checkIn.checkInTime.month == now.month
    ).length;
    
    final currentStreak = _calculateCurrentStreak(checkIns);
    final longestStreak = _calculateLongestStreak(checkIns);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(context, '本月签到', '$currentMonthCheckIns天', Icons.calendar_month),
        _buildStatItem(context, '当前连击', '${currentStreak}天', Icons.local_fire_department),
        _buildStatItem(context, '最长连击', '${longestStreak}天', Icons.emoji_events),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  int _calculateCurrentStreak(List<CheckIn> checkIns) {
    if (checkIns.isEmpty) return 0;
    
    final sortedCheckIns = checkIns.toList()
      ..sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
    
    int streak = 0;
    DateTime currentDate = DateTime.now();
    
    for (final checkIn in sortedCheckIns) {
      final checkInDate = DateTime(
        checkIn.checkInTime.year,
        checkIn.checkInTime.month,
        checkIn.checkInTime.day,
      );
      final expectedDate = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );
      
      if (checkInDate == expectedDate) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    return streak;
  }

  int _calculateLongestStreak(List<CheckIn> checkIns) {
    if (checkIns.isEmpty) return 0;
    
    final sortedCheckIns = checkIns.toList()
      ..sort((a, b) => a.checkInTime.compareTo(b.checkInTime));
    
    int maxStreak = 0;
    int currentStreak = 1;
    
    for (int i = 1; i < sortedCheckIns.length; i++) {
      final prevDate = DateTime(
        sortedCheckIns[i - 1].checkInTime.year,
        sortedCheckIns[i - 1].checkInTime.month,
        sortedCheckIns[i - 1].checkInTime.day,
      );
      final currentDate = DateTime(
        sortedCheckIns[i].checkInTime.year,
        sortedCheckIns[i].checkInTime.month,
        sortedCheckIns[i].checkInTime.day,
      );
      
      if (currentDate.difference(prevDate).inDays == 1) {
        currentStreak++;
      } else {
        maxStreak = maxStreak > currentStreak ? maxStreak : currentStreak;
        currentStreak = 1;
      }
    }
    
    return maxStreak > currentStreak ? maxStreak : currentStreak;
  }

  void _showCheckInDialog(BuildContext context, DateTime date) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('签到'),
        content: Text('确定要在 ${date.month}月${date.day}日 签到吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 执行签到操作
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('签到成功！')),
              );
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}
