import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/bottom_navigation.dart';
import 'shared/widgets/floating_action_menu.dart';
import 'shared/widgets/training_page.dart';
import 'shared/widgets/community_page.dart';
import 'shared/widgets/messages_page.dart';
import 'shared/widgets/profile_page.dart';
import 'shared/widgets/publish_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: GymatesApp(),
    ),
  );
}

class GymatesApp extends StatelessWidget {
  const GymatesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gymates - 热血健身打卡社交应用',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainApp(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String activeTab = 'training';
  bool showFloatingMenu = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // 主要内容区域
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 400 
                ? (MediaQuery.of(context).size.width - 400) / 2 
                : 0,
            ),
            child: _buildCurrentPage(),
          ),
          
          // 底部导航栏
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavigation(
              activeTab: activeTab,
              onTabChange: (tab) {
                setState(() {
                  activeTab = tab;
                });
              },
              onFloatingButtonClick: () {
                setState(() {
                  showFloatingMenu = true;
                });
              },
            ),
          ),
          
          // 浮动操作菜单
          if (showFloatingMenu)
            FloatingActionMenu(
              isOpen: showFloatingMenu,
              onClose: () {
                setState(() {
                  showFloatingMenu = false;
                });
              },
              onItemTap: (type) {
                setState(() {
                  showFloatingMenu = false;
                });
                _showPublishPage(context, type);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (activeTab) {
      case 'training':
        return const TrainingPage();
      case 'community':
        return const CommunityPage();
      case 'messages':
        return const MessagesPage();
      case 'profile':
        return const ProfilePage();
      default:
        return const TrainingPage();
    }
  }

  void _showPublishPage(BuildContext context, String type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PublishPage(),
        fullscreenDialog: true,
      ),
    );
  }
}
