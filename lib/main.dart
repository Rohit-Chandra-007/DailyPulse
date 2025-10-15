import 'package:flutter/material.dart';
import 'data/local/hive_service.dart';
import 'core/theme.dart';
import 'app_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme(BuildContext context) {
    setState(() {
      if (_themeMode == ThemeMode.system) {
        // If currently using system theme, switch based on current brightness
        final brightness = MediaQuery.platformBrightnessOf(context);
        _themeMode = brightness == Brightness.dark
            ? ThemeMode.light
            : ThemeMode.dark;
      } else {
        // Toggle between light and dark
        _themeMode = _themeMode == ThemeMode.light
            ? ThemeMode.dark
            : ThemeMode.light;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DailyPulse',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: Builder(
        builder: (context) =>
            AppScaffold(onThemeToggle: () => _toggleTheme(context)),
      ),
    );
  }
}
