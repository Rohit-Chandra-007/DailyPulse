import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'features/log/log_mood_screen.dart';
import 'features/history/history_screen.dart';
import 'features/insights/insights_screen.dart';
import 'features/widgets/nav_bar_item.dart';

class AppScaffold extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const AppScaffold({super.key, required this.onThemeToggle});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _currentIndex = 0;

  final _screens = const [LogMoodScreen(), HistoryScreen(), InsightsScreen()];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          body: _screens[_currentIndex],
          floatingActionButton: FloatingActionButton(
            onPressed: widget.onThemeToggle,
            tooltip: isDark ? 'Light mode' : 'Dark mode',
            elevation: 4,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return RotationTransition(
                  turns: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                key: ValueKey(isDark),
              ),
            ),
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
                  onTap: () => setState(() => _currentIndex = 0),
                  isDark: isDark,
                ),
                NavBarItem(
                  icon: CupertinoIcons.clock,
                  selectedIcon: CupertinoIcons.clock_fill,
                  label: 'History',
                  isSelected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                  isDark: isDark,
                ),
                NavBarItem(
                  icon: CupertinoIcons.chart_bar,
                  selectedIcon: CupertinoIcons.chart_bar_fill,
                  label: 'Insights',
                  isSelected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
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
