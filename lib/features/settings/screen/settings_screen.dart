import 'package:dailypulse/core/providers/auth_provider.dart';
import 'package:dailypulse/core/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 32),

              // Account Section
              _buildSectionTitle('Account', isDark),
              const SizedBox(height: 16),
              _buildCard(
                isDark: isDark,
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isDark
                            ? Colors.blue.shade700
                            : Colors.blue.shade100,
                        child: Icon(
                          Icons.person,
                          color: isDark ? Colors.white : Colors.blue.shade700,
                        ),
                      ),
                      title: Text(
                        authProvider.user?.displayName ?? 'User',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        authProvider.user?.email ?? '',
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Theme Section
              _buildSectionTitle('Appearance', isDark),
              const SizedBox(height: 16),
              _buildCard(
                isDark: isDark,
                child: Column(
                  children: [
                    _buildThemeOption(
                      context: context,
                      title: 'Light Mode',
                      icon: Icons.light_mode,
                      isSelected: themeProvider.isLightMode,
                      onTap: () => themeProvider.setLightTheme(),
                      isDark: isDark,
                    ),
                    Divider(
                      height: 1,
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                    ),
                    _buildThemeOption(
                      context: context,
                      title: 'Dark Mode',
                      icon: Icons.dark_mode,
                      isSelected: themeProvider.isDarkMode,
                      onTap: () => themeProvider.setDarkTheme(),
                      isDark: isDark,
                    ),
                    Divider(
                      height: 1,
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                    ),
                    _buildThemeOption(
                      context: context,
                      title: 'System Default',
                      icon: Icons.brightness_auto,
                      isSelected: themeProvider.isSystemMode,
                      onTap: () => themeProvider.setSystemTheme(),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Actions Section
              _buildSectionTitle('Actions', isDark),
              const SizedBox(height: 16),
              _buildCard(
                isDark: isDark,
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red.shade400),
                  title: Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign Out'),
                        content: const Text(
                          'Are you sure you want to sign out?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      await context.read<AuthProvider>().signOut();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
      ),
    );
  }

  Widget _buildCard({required bool isDark, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? (isDark ? Colors.blue.shade300 : Colors.blue.shade700)
            : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
            )
          : null,
      onTap: onTap,
    );
  }
}
