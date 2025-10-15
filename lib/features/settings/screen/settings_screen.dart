import 'package:dailypulse/core/providers/auth_provider.dart';
import 'package:dailypulse/core/providers/theme_provider.dart';
import 'package:dailypulse/core/utils/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/settings_card.dart';
import '../widgets/theme_selector.dart';
import '../widgets/user_profile_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isAppearanceExpanded = true;
  bool _isAccountExpanded = true;

  void _toggleAppearance() {
    setState(() {
      _isAppearanceExpanded = !_isAppearanceExpanded;
    });
  }

  void _toggleAccount() {
    setState(() {
      _isAccountExpanded = !_isAccountExpanded;
    });
  }

  Future<void> _handleSignOut(BuildContext context) async {
    final confirm = await DialogUtils.showConfirmDialog(
      context: context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
      isDanger: true,
    );

    if (confirm && context.mounted) {
      await context.read<AuthProvider>().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your account and preferences',
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),

              UserProfileCard(
                displayName: authProvider.user?.displayName,
                email: authProvider.user?.email,
              ),
              const SizedBox(height: 32),

              _buildExpandableSectionHeader(
                'Appearance',
                _isAppearanceExpanded,
                _toggleAppearance,
                isDark,
              ),
              const SizedBox(height: 16),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _isAppearanceExpanded
                    ? Column(
                        children: [
                          SettingsCard(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: ThemeSelector(
                                isLightMode: themeProvider.isLightMode,
                                isDarkMode: themeProvider.isDarkMode,
                                isSystemMode: themeProvider.isSystemMode,
                                onLightMode: themeProvider.setLightTheme,
                                onDarkMode: themeProvider.setDarkTheme,
                                onSystemMode: themeProvider.setSystemTheme,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      )
                    : const SizedBox(height: 32),
              ),

              _buildExpandableSectionHeader(
                'Account',
                _isAccountExpanded,
                _toggleAccount,
                isDark,
              ),
              const SizedBox(height: 16),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _isAccountExpanded
                    ? Column(
                        children: [
                          SettingsCard(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _handleSignOut(context),
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.logout,
                                          color: Colors.red.shade600,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Sign Out',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.red.shade600,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Sign out of your account',
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
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Colors.grey.shade400,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 32),

              Center(
                child: Column(
                  children: [
                    Text(
                      'DailyPulse',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableSectionHeader(
    String title,
    bool isExpanded,
    VoidCallback onToggle,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onToggle,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          AnimatedRotation(
            turns: isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 300),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
