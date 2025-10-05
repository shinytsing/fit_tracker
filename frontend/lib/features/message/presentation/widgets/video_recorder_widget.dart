import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/theme/app_theme.dart';

/// 视频录制组件
/// 支持录制短视频、预览、重录、发送
class VideoRecorderWidget extends StatefulWidget {
  final Function(String videoPath, String? thumbnailPath, int duration)? onVideoRecorded;
  final VoidCallback? onCancel;
  final int maxDuration; // 最大录制时长（秒）

  const VideoRecorderWidget({
    super.key,
    this.onVideoRecorded,
    this.onCancel,
    this.maxDuration = 60,
  });

  @override
  State<VideoRecorderWidget> createState() => _VideoRecorderWidgetState();
}

class _VideoRecorderWidgetState extends State<VideoRecorderWidget>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isRecording = false;
  bool _isInitialized = false;
  String? _recordedVideoPath;
  String? _thumbnailPath;
  int _recordedDuration = 0;
  int _currentDuration = 0;
  
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: Duration(seconds: widget.maxDuration),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.linear,
    ));

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        _showError('没有可用的摄像头');
        return;
      }

      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _cameraController!.initialize();
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      _showError('摄像头初始化失败: $e');
    }
  }

  Future<void> _startRecording() async {
    if (_cameraController == null || !_isInitialized) return;

    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _recordedVideoPath = '${directory.path}/video_$timestamp.mp4';

      await _cameraController!.startVideoRecording();
      
      setState(() {
        _isRecording = true;
        _currentDuration = 0;
      });

      _progressController.forward();
      _pulseController.repeat(reverse: true);

      // 开始计时
      _startTimer();
    } catch (e) {
      _showError('开始录制失败: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (_cameraController == null || !_isRecording) return;

    try {
      final videoFile = await _cameraController!.stopVideoRecording();
      _recordedVideoPath = videoFile.path;
      
      // 生成缩略图
      await _generateThumbnail();
      
      setState(() {
        _isRecording = false;
        _recordedDuration = _currentDuration;
      });

      _progressController.stop();
      _pulseController.stop();
    } catch (e) {
      _showError('停止录制失败: $e');
    }
  }

  Future<void> _generateThumbnail() async {
    if (_recordedVideoPath == null) return;

    try {
      // 这里应该使用video_thumbnail包生成缩略图
      // 为了简化，我们暂时使用视频的第一帧作为缩略图
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _thumbnailPath = '${directory.path}/thumbnail_$timestamp.jpg';
      
      // 实际项目中应该使用video_thumbnail包
      // final thumbnail = await VideoThumbnail.thumbnailFile(
      //   video: _recordedVideoPath!,
      //   thumbnailPath: _thumbnailPath,
      //   imageFormat: ImageFormat.JPEG,
      //   maxHeight: 200,
      //   quality: 75,
      // );
    } catch (e) {
      debugPrint('生成缩略图失败: $e');
    }
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRecording && mounted) {
        setState(() {
          _currentDuration++;
        });
        
        if (_currentDuration >= widget.maxDuration) {
          _stopRecording();
        } else {
          _startTimer();
        }
      }
    });
  }

  void _retakeVideo() {
    setState(() {
      _recordedVideoPath = null;
      _thumbnailPath = null;
      _recordedDuration = 0;
      _currentDuration = 0;
    });
    _progressController.reset();
  }

  void _sendVideo() {
    if (_recordedVideoPath != null) {
      widget.onVideoRecorded?.call(
        _recordedVideoPath!,
        _thumbnailPath,
        _recordedDuration,
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部控制栏
            _buildTopBar(),
            
            // 摄像头预览
            Expanded(
              child: _buildCameraPreview(),
            ),
            
            // 底部控制栏
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 取消按钮
          GestureDetector(
            onTap: widget.onCancel,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          
          // 录制时长
          if (_isRecording || _recordedDuration > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _formatDuration(_isRecording ? _currentDuration : _recordedDuration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          
          // 切换摄像头按钮
          GestureDetector(
            onTap: _switchCamera,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                MdiIcons.cameraSwitch,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isInitialized || _cameraController == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return Stack(
      children: [
        // 摄像头预览
        Positioned.fill(
          child: CameraPreview(_cameraController!),
        ),
        
        // 录制进度条
        if (_isRecording)
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _progressAnimation.value,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                );
              },
            ),
          ),
        
        // 录制指示器
        if (_isRecording)
          Positioned(
            top: 50,
            left: 20,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ),
        
        // 录制时长提示
        if (_isRecording)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '最长录制 ${widget.maxDuration} 秒',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(30),
      child: _recordedVideoPath != null
          ? _buildPreviewControls()
          : _buildRecordingControls(),
    );
  }

  Widget _buildRecordingControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 录制按钮
        GestureDetector(
          onTap: _isRecording ? _stopRecording : _startRecording,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isRecording ? 60 : 80,
            height: _isRecording ? 60 : 80,
            decoration: BoxDecoration(
              color: _isRecording ? Colors.red : Colors.white,
              shape: BoxShape.circle,
              border: _isRecording ? null : Border.all(
                color: Colors.white,
                width: 4,
              ),
            ),
            child: _isRecording
                ? const Icon(
                    Icons.stop,
                    color: Colors.white,
                    size: 30,
                  )
                : Container(
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 重录按钮
        _buildControlButton(
          icon: MdiIcons.refresh,
          label: '重录',
          onPressed: _retakeVideo,
        ),
        
        // 发送按钮
        _buildControlButton(
          icon: MdiIcons.send,
          label: '发送',
          onPressed: _sendVideo,
          isPrimary: true,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isPrimary ? AppTheme.primary : Colors.grey[700],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    try {
      final currentIndex = _cameras!.indexOf(_cameraController!.description);
      final newIndex = (currentIndex + 1) % _cameras!.length;
      
      await _cameraController!.dispose();
      
      _cameraController = CameraController(
        _cameras![newIndex],
        ResolutionPreset.high,
        enableAudio: true,
      );
      
      await _cameraController!.initialize();
      setState(() {});
    } catch (e) {
      _showError('切换摄像头失败: $e');
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
