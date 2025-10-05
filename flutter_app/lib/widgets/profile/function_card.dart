import 'package:flutter/material.dart';

class FunctionCard extends StatelessWidget {
  const FunctionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '功能设置',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(6, (index) => _buildFunctionItem(index)),
        ],
      ),
    );
  }

  Widget _buildFunctionItem(int index) {
    final functions = [
      {
        'icon': Icons.person_outline,
        'title': '个人资料',
        'subtitle': '编辑个人信息',
        'color': const Color(0xFF3B82F6),
      },
      {
        'icon': Icons.notifications_outlined,
        'title': '通知设置',
        'subtitle': '管理推送通知',
        'color': const Color(0xFF10B981),
      },
      {
        'icon': Icons.security_outlined,
        'title': '隐私设置',
        'subtitle': '保护你的隐私',
        'color': const Color(0xFFF59E0B),
      },
      {
        'icon': Icons.help_outline,
        'title': '帮助中心',
        'subtitle': '常见问题解答',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'icon': Icons.info_outline,
        'title': '关于我们',
        'subtitle': '版本信息',
        'color': const Color(0xFF6B7280),
      },
      {
        'icon': Icons.logout,
        'title': '退出登录',
        'subtitle': '安全退出账户',
        'color': const Color(0xFFEF4444),
      },
    ];

    final function = functions[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (function['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  function['icon'] as IconData,
                  color: function['color'] as Color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      function['title'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      function['subtitle'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF6B7280),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
