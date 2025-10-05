import 'package:flutter/material.dart';

class ChallengeCards extends StatelessWidget {
  const ChallengeCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '热门挑战',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: _getChallengeColor(index).withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _getChallengeIcon(index),
                          size: 32,
                          color: _getChallengeColor(index),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getChallengeTitle(index),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Text(
                                _getChallengeDescription(index),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.people,
                                  size: 12,
                                  color: const Color(0xFF6B7280),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getChallengeParticipants(index),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
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
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getChallengeIcon(int index) {
    switch (index) {
      case 0:
        return Icons.fitness_center;
      case 1:
        return Icons.directions_run;
      case 2:
        return Icons.water_drop;
      default:
        return Icons.fitness_center;
    }
  }

  Color _getChallengeColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFF3B82F6);
      case 1:
        return const Color(0xFF10B981);
      case 2:
        return const Color(0xFF06B6D4);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  String _getChallengeTitle(int index) {
    switch (index) {
      case 0:
        return '30天俯卧撑';
      case 1:
        return '5公里跑步';
      case 2:
        return '每日饮水';
      default:
        return '挑战';
    }
  }

  String _getChallengeDescription(int index) {
    switch (index) {
      case 0:
        return '每天坚持做俯卧撑，30天挑战你的极限';
      case 1:
        return '每周至少完成一次5公里跑步';
      case 2:
        return '每天喝够8杯水，保持身体健康';
      default:
        return '挑战描述';
    }
  }

  String _getChallengeParticipants(int index) {
    switch (index) {
      case 0:
        return '1.2k人参与';
      case 1:
        return '856人参与';
      case 2:
        return '2.1k人参与';
      default:
        return '0人参与';
    }
  }
}
