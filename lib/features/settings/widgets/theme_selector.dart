import 'package:flutter/material.dart';

class ThemeSelector extends StatefulWidget {
  final bool isLightMode;
  final bool isDarkMode;
  final bool isSystemMode;
  final VoidCallback onLightMode;
  final VoidCallback onDarkMode;
  final VoidCallback onSystemMode;

  const ThemeSelector({
    super.key,
    required this.isLightMode,
    required this.isDarkMode,
    required this.isSystemMode,
    required this.onLightMode,
    required this.onDarkMode,
    required this.onSystemMode,
  });

  @override
  State<ThemeSelector> createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends State<ThemeSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown() {
    _animationController.forward();
  }

  void _onTapUp() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _buildThemeOption(
          icon: Icons.light_mode_outlined,
          title: 'Light',
          subtitle: 'Bright and clear',
          isSelected: widget.isLightMode,
          onTap: widget.onLightMode,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildThemeOption(
          icon: Icons.dark_mode_outlined,
          title: 'Dark',
          subtitle: 'Easy on the eyes',
          isSelected: widget.isDarkMode,
          onTap: widget.onDarkMode,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildThemeOption(
          icon: Icons.brightness_auto,
          title: 'System',
          subtitle: 'Match device settings',
          isSelected: widget.isSystemMode,
          onTap: widget.onSystemMode,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) => _onTapUp(),
      onTapCancel: _onTapUp,
      onTap: () {
        _onTapUp();
        onTap();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? Colors.blue.shade700.withValues(alpha: 0.3)
                    : Colors.blue.shade50)
                : (isDark
                    ? const Color(0xFF1E1E1E)
                    : Colors.blue.shade50.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? (isDark ? Colors.blue.shade300 : Colors.blue.shade200)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? Colors.blue.shade700 : Colors.blue.shade200)
                      : (isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.blue.shade700)
                      : Colors.grey.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: isDark ? Colors.blue.shade300 : Colors.blue.shade200,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
