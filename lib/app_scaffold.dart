import 'package:dailypulse/core/providers/auth_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/log/screen/log_mood_screen.dart';
import 'features/history/screen/history_screen.dart';
import 'features/insights/screen/insights_screen.dart';
import 'features/settings/screen/settings_screen.dart';
import 'core/widgets/nav_bar_item.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _screens = const [
    LogMoodScreen(),
    HistoryScreen(),
    InsightsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    if (index != _currentIndex) {
      _animationController.reset();
      setState(() => _currentIndex = index);
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
              : [
                  Colors.blue.shade200,
                  Colors.blue.shade100,
                  Colors.blue.shade50,
                ],
        ),
      ),

      child: SafeArea(
        bottom: false,
        child: Scaffold(
          appBar: _currentIndex == 3
              ? null
              : AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    authProvider.user?.displayName != null
                        ? 'Hello, ${authProvider.user!.displayName}'
                        : 'DailyPulse',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.blue.shade900,
                    ),
                  ),
                ),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: _screens[_currentIndex],
          ),
          bottomNavigationBar: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
              borderRadius: BorderRadius.circular(30),
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
              //     blurRadius: 20,
              //     offset: const Offset(0, 4),
              //   ),
              // ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NavBarItem(
                  icon: CupertinoIcons.smiley,
                  selectedIcon: CupertinoIcons.smiley_fill,
                  label: 'Log',
                  isSelected: _currentIndex == 0,
                  onTap: () => _onTabChanged(0),
                  isDark: isDark,
                ),
                NavBarItem(
                  icon: CupertinoIcons.clock,
                  selectedIcon: CupertinoIcons.clock_fill,
                  label: 'History',
                  isSelected: _currentIndex == 1,
                  onTap: () => _onTabChanged(1),
                  isDark: isDark,
                ),
                NavBarItem(
                  icon: CupertinoIcons.chart_bar,
                  selectedIcon: CupertinoIcons.chart_bar_fill,
                  label: 'Insights',
                  isSelected: _currentIndex == 2,
                  onTap: () => _onTabChanged(2),
                  isDark: isDark,
                ),
                NavBarItem(
                  icon: CupertinoIcons.settings,
                  selectedIcon: CupertinoIcons.settings_solid,
                  label: 'Settings',
                  isSelected: _currentIndex == 3,
                  onTap: () => _onTabChanged(3),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
