import 'package:dailypulse/core/app_theme/theme.dart';
import 'package:dailypulse/core/providers/auth_provider.dart';
import 'package:dailypulse/core/providers/mood_provider.dart';
import 'package:dailypulse/core/providers/theme_provider.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'data/local/hive_service.dart';
import 'data/repo/mood_repository.dart';
import 'features/auth/widgets/auth_wrapper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await HiveService.init();
  
  
  final moodRepo = MoodRepository();
  moodRepo.startBackgroundSync();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'DailyPulse',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: theme.themeMode,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}
