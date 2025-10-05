import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:gymates_app/main.dart';
import 'package:gymates_app/providers/theme_provider.dart';
import 'package:gymates_app/providers/auth_provider.dart';

void main() {
  group('Gymates App Tests', () {
    testWidgets('App should start with login screen', (WidgetTester tester) async {
      await tester.pumpWidget(const GymatesApp());
      
      // Wait for the app to load
      await tester.pumpAndSettle();
      
      // Check if login screen is displayed
      expect(find.text('Gymates'), findsOneWidget);
      expect(find.text('寻找你的健身搭子'), findsOneWidget);
    });

    testWidgets('Theme provider should work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final themeProvider = Provider.of<ThemeProvider>(context);
                return Text('Theme: ${themeProvider.themeType}');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Check if theme provider is working
      expect(find.textContaining('Theme:'), findsOneWidget);
    });

    testWidgets('Auth provider should work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final authProvider = Provider.of<AuthProvider>(context);
                return Text('Auth State: ${authProvider.authState}');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Check if auth provider is working
      expect(find.textContaining('Auth State:'), findsOneWidget);
    });

    testWidgets('Custom button should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {},
              child: const Text('Test Button'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Check if button is rendered
      expect(find.text('Test Button'), findsOneWidget);
    });
  });
}
