import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  void toggleTheme(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      final brightness = MediaQuery.platformBrightnessOf(context);
      setThemeMode(
        brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
      );
    } else {
      setThemeMode(
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
      );
    }
  }

  void setLightTheme() {
    setThemeMode(ThemeMode.light);
  }

  void setDarkTheme() {
    setThemeMode(ThemeMode.dark);
  }

  void setSystemTheme() {
    setThemeMode(ThemeMode.system);
  }
}
