import 'package:flutter/material.dart';

class AppTheme {
  // Figma设计系统颜色 - 基于Gymates Fitness Social App设计
  static const Color primaryColor = Color(0xFF6366F1); // 主色调 - Indigo
  static const Color secondaryColor = Color(0xFF8B5CF6); // 次要色 - Purple
  static const Color accentColor = Color(0xFF06B6D4); // 强调色 - Cyan
  static const Color errorColor = Color(0xFFEF4444); // 错误色 - Red
  static const Color successColor = Color(0xFF10B981); // 成功色 - Emerald
  static const Color warningColor = Color(0xFFF59E0B); // 警告色 - Amber
  
  // Figma设计系统背景和前景色
  static const Color primary = primaryColor;
  static const Color background = Color(0xFFF9FAFB); // 背景色 - Gray-50
  static const Color foreground = Color(0xFF1F2937); // 前景色 - Gray-900
  static const Color card = Color(0xFFFFFFFF); // 卡片色 - White
  static const Color cardForeground = Color(0xFF1F2937); // 卡片前景色
  
  // 文本颜色
  static const Color textPrimary = Color(0xFF1F2937); // 主要文本 - Gray-900
  static const Color textSecondary = Color(0xFF6B7280); // 次要文本 - Gray-500
  static const Color textHint = Color(0xFF9CA3AF); // 提示文本 - Gray-400
  static const Color textMuted = Color(0xFF717182); // 静音文本
  
  // 其他颜色
  static const Color infoColor = Color(0xFF3B82F6); // 信息色 - Blue
  static const Color surfaceColor = Color(0xFFFFFFFF); // 表面色
  static const Color onSurfaceColor = Color(0xFF1F2937); // 表面上的颜色
  static const Color backgroundColor = background;
  static const Color textColor = textPrimary;
  
  // 边框和输入框颜色
  static const Color border = Color(0xFFE5E7EB); // 边框色 - Gray-200
  static const Color inputBackground = Color(0xFFF3F4F6); // 输入框背景 - Gray-100
  
  // Figma设计系统圆角
  static const double radius = 12.0; // 基础圆角
  static const double radiusSm = 6.0; // 小圆角
  static const double radiusMd = 8.0; // 中圆角
  static const double radiusLg = 12.0; // 大圆角
  static const double radiusXl = 16.0; // 超大圆角
  
  // 渐变 - 基于Figma设计
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Figma设计系统阴影
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get floatingShadow => [
    BoxShadow(
      color: primaryColor.withOpacity(0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        background: background,
        surface: card,
        onBackground: foreground,
        onSurface: cardForeground,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: foreground,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}