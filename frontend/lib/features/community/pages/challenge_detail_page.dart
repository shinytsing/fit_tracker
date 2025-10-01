import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/models/models.dart';
import '../../core/providers/community_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/custom_widgets.dart';

/// 挑战赛详情页面
class ChallengeDetailPage extends ConsumerStatefulWidget {
  final Challenge challenge;

  const ChallengeDetailPage({
    super.key,
    required this.challenge,
  });

  @override
  ConsumerState<ChallengeDetailPage> createState() => _ChallengeDetailPageState();
}

class _ChallengeDetailPageState extends ConsumerState<ChallengeDetailPage> {
  int _selectedTabIndex = 0;
  bool _isParticipating = false;
  ChallengeParticipant? _participant;

  @override
  void initState() {
    super.initState();
    // 检查是否已参与
    _checkParticipation();
  }

  void _checkParticipation() {
    // TODO: 检查用户是否已参与此挑战赛
    setState(() {
      _isParticipating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.challenge.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: 分享挑战赛
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 挑战赛信息卡片
          _buildChallengeInfoCard(),
          
          // 标签页
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('详情', 0),
                ),
                Expanded(
                  child: _buildTabButton('排行榜', 1),
                ),
                Expanded(
                  child: _buildTabButton('打卡记录', 2),
                ),
              ],
            ),
          ),
          
          // 内容区域
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildDetailTab(),
                _buildLeaderboardTab(),
                _buildCheckinsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildChallengeInfoCard() {
    final now = DateTime.now();
    final isActive = widget.challenge.startDate.isBefore(now) && 
                    widget.challenge.endDate.isAfter(now);
    final isUpcoming = widget.challenge.startDate.isAfter(now);
    final isEnded = widget.challenge.endDate.isBefore(now);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和状态
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.challenge.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(isActive, isUpcoming, isEnded),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getStatusText(isActive, isUpcoming, isEnded),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 描述
            if (widget.challenge.description != null)
              Text(
                widget.challenge.description!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            
            const SizedBox(height: 16),
            
            // 挑战赛信息
            _buildChallengeInfo(),
            
            const SizedBox(height: 16),
            
            // 进度条（如果已参与）
            if (_isParticipating && _participant != null)
              _buildProgressBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeInfo() {
    return Column(
      children: [
        _buildInfoRow(
          Icons.schedule,
          '挑战时间',
          '${DateFormat('MM-dd').format(widget.challenge.startDate)} - ${DateFormat('MM-dd').format(widget.challenge.endDate)}',
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          Icons.people,
          '参与人数',
          '${widget.challenge.participantsCount}人',
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          Icons.local_fire_department,
          '难度等级',
          widget.challenge.difficulty,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          Icons.category,
          '挑战类型',
          widget.challenge.type,
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '我的进度',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_participant!.progress}%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _participant!.progress / 100,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '打卡次数: ${_participant!.checkinCount}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '消耗卡路里: ${_participant!.totalCalories}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDetailTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 挑战规则
          if (widget.challenge.rules != null) ...[
            Text(
              '挑战规则',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.challenge.rules!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
          ],
          
          // 奖励说明
          if (widget.challenge.rewards != null) ...[
            Text(
              '奖励说明',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.challenge.rewards!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
          ],
          
          // 参与须知
          Text(
            '参与须知',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '• 请确保在挑战期间内完成相应的运动目标\n'
            '• 每次运动后请及时打卡记录\n'
            '• 保持诚实，不要虚假打卡\n'
            '• 如有疑问请联系客服',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    return FutureBuilder<List<ChallengeParticipant>>(
      future: _loadLeaderboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  '加载失败',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }
        
        final participants = snapshot.data ?? [];
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: participants.length,
          itemBuilder: (context, index) {
            final participant = participants[index];
            return _buildLeaderboardItem(participant, index + 1);
          },
        );
      },
    );
  }

  Widget _buildLeaderboardItem(ChallengeParticipant participant, int rank) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRankColor(rank),
          child: Text(
            '$rank',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(participant.user?.username ?? '未知用户'),
        subtitle: Text('打卡${participant.checkinCount}次'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${participant.totalCalories}卡',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            Text(
              '${participant.progress}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckinsTab() {
    return FutureBuilder<List<ChallengeCheckin>>(
      future: _loadCheckins(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  '加载失败',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }
        
        final checkins = snapshot.data ?? [];
        
        if (checkins.isEmpty) {
          return const Center(
            child: Text('暂无打卡记录'),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: checkins.length,
          itemBuilder: (context, index) {
            final checkin = checkins[index];
            return _buildCheckinItem(checkin);
          },
        );
      },
    );
  }

  Widget _buildCheckinItem(ChallengeCheckin checkin) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: checkin.user?.avatar != null
                      ? NetworkImage(checkin.user!.avatar!)
                      : null,
                  child: checkin.user?.avatar == null
                      ? Text(
                          checkin.user?.username.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(fontSize: 12),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        checkin.user?.username ?? '未知用户',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        DateFormat('MM-dd HH:mm').format(checkin.checkinDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (checkin.calories > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${checkin.calories}卡',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            if (checkin.content != null) ...[
              const SizedBox(height: 8),
              Text(
                checkin.content!,
                style: const TextStyle(fontSize: 14),
              ),
            ],
            if (checkin.imageList.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: checkin.imageList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(checkin.imageList[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final now = DateTime.now();
    final isActive = widget.challenge.startDate.isBefore(now) && 
                    widget.challenge.endDate.isAfter(now);
    final isUpcoming = widget.challenge.startDate.isAfter(now);

    if (!isActive && !isUpcoming) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_isParticipating && isActive) ...[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showCheckinDialog();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('打卡'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ] else if (!_isParticipating && (isActive || isUpcoming)) ...[
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _joinChallenge();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(isUpcoming ? '预约参与' : '立即参与'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(bool isActive, bool isUpcoming, bool isEnded) {
    if (isActive) return Colors.green;
    if (isUpcoming) return Colors.orange;
    if (isEnded) return Colors.grey;
    return Colors.grey;
  }

  String _getStatusText(bool isActive, bool isUpcoming, bool isEnded) {
    if (isActive) return '进行中';
    if (isUpcoming) return '即将开始';
    if (isEnded) return '已结束';
    return '未知';
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[400]!;
      default:
        return AppTheme.primaryColor;
    }
  }

  Future<List<ChallengeParticipant>> _loadLeaderboard() async {
    // TODO: 实现排行榜数据加载
    return [];
  }

  Future<List<ChallengeCheckin>> _loadCheckins() async {
    // TODO: 实现打卡记录数据加载
    return [];
  }

  void _joinChallenge() async {
    final communityNotifier = ref.read(communityNotifierProvider.notifier);
    final success = await communityNotifier.joinChallenge(widget.challenge.id);
    
    if (success) {
      setState(() {
        _isParticipating = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('参与成功！')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('参与失败，请重试')),
      );
    }
  }

  void _showCheckinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('挑战赛打卡'),
        content: const Text('打卡功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
