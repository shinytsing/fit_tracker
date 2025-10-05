import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/models.dart';

/// 加入搭子页面
class JoinGymBuddyPage extends StatefulWidget {
  final Gym? gym;
  final String? gymName;

  const JoinGymBuddyPage({
    super.key,
    this.gym,
    this.gymName,
  });

  @override
  State<JoinGymBuddyPage> createState() => _JoinGymBuddyPageState();
}

class _JoinGymBuddyPageState extends State<JoinGymBuddyPage> {
  final _formKey = GlobalKey<FormState>();
  final _goalController = TextEditingController();
  final _noteController = TextEditingController();
  
  String _selectedGoal = '';
  DateTime? _selectedTimeSlot;
  bool _isSubmitting = false;

  final List<String> _goals = [
    '增肌',
    '减脂',
    '塑形',
    '力量训练',
    '有氧运动',
    '柔韧性训练',
    '康复训练',
    '其他',
  ];

  @override
  void initState() {
    super.initState();
    _selectedGoal = _goals.first;
  }

  @override
  void dispose() {
    _goalController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('加入搭子'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 健身房信息卡片
              _buildGymInfoCard(),
              
              const SizedBox(height: 24),
              
              // 健身目标选择
              _buildGoalSelector(),
              
              const SizedBox(height: 24),
              
              // 时间段选择
              _buildTimeSlotSelector(),
              
              const SizedBox(height: 24),
              
              // 备注信息
              _buildNoteInput(),
              
              const SizedBox(height: 24),
              
              // 搭子规则说明
              _buildRulesCard(),
              
              const SizedBox(height: 32),
              
              // 提交按钮
              _buildSubmitButton(),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建健身房信息卡片
  Widget _buildGymInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 健身房图片
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.fitness_center, size: 30, color: Colors.grey),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 健身房信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.gymName ?? '超级健身房',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '北京市朝阳区某某街道123号',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.group, size: 14, color: AppTheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      '8人搭子',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.local_offer, size: 14, color: Colors.red[600]),
                    const SizedBox(width: 4),
                    Text(
                      '3人9折',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建健身目标选择器
  Widget _buildGoalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '健身目标',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _goals.map((goal) {
            final isSelected = _selectedGoal == goal;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedGoal = goal;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  goal,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        
        // 自定义目标输入
        if (_selectedGoal == '其他') ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _goalController,
            decoration: InputDecoration(
              hintText: '请输入你的健身目标',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.primary),
              ),
            ),
            validator: (value) {
              if (_selectedGoal == '其他' && (value == null || value.trim().isEmpty)) {
                return '请输入健身目标';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  /// 构建时间段选择器
  Widget _buildTimeSlotSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '训练时间',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // 时间选择按钮
        GestureDetector(
          onTap: _selectTimeSlot,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedTimeSlot != null
                        ? '${_selectedTimeSlot!.hour.toString().padLeft(2, '0')}:${_selectedTimeSlot!.minute.toString().padLeft(2, '0')}'
                        : '选择训练时间',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedTimeSlot != null ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // 快速时间选择
        const Text(
          '常用时间段',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickTimeButton('06:00', '早练'),
            _buildQuickTimeButton('07:00', '晨练'),
            _buildQuickTimeButton('12:00', '午练'),
            _buildQuickTimeButton('18:00', '晚练'),
            _buildQuickTimeButton('19:00', '夜练'),
            _buildQuickTimeButton('20:00', '晚练'),
          ],
        ),
      ],
    );
  }

  /// 构建快速时间按钮
  Widget _buildQuickTimeButton(String time, String label) {
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final timeSlot = DateTime(2024, 1, 1, hour, minute);
    final isSelected = _selectedTimeSlot != null &&
        _selectedTimeSlot!.hour == hour &&
        _selectedTimeSlot!.minute == minute;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeSlot = timeSlot;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.grey[300]!,
          ),
        ),
        child: Text(
          '$time $label',
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// 构建备注输入
  Widget _buildNoteInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '备注信息',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _noteController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: '介绍一下自己，或者对搭子的期望...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.primary),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建规则说明卡片
  Widget _buildRulesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '搭子规则',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• 加入搭子后，请按时参加训练\n'
            '• 如有特殊情况无法参加，请提前告知\n'
            '• 保持健身房环境整洁，爱护设备\n'
            '• 尊重其他搭子，营造良好的训练氛围',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建提交按钮
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitJoinRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '申请加入搭子',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  /// 选择时间段
  void _selectTimeSlot() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTimeSlot != null
          ? TimeOfDay.fromDateTime(_selectedTimeSlot!)
          : const TimeOfDay(hour: 19, minute: 0),
    );
    
    if (picked != null) {
      setState(() {
        _selectedTimeSlot = DateTime(2024, 1, 1, picked.hour, picked.minute);
      });
    }
  }

  /// 提交加入申请
  void _submitJoinRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择训练时间')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: 调用API提交加入申请
      await Future.delayed(const Duration(seconds: 2)); // 模拟网络请求
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('申请提交成功！')),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('申请提交失败: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}
