import 'package:flutter/material.dart';
import '../core/services/theme_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  ThemeProvider() { _loadTheme(); }
  void _loadTheme() { _themeMode = ThemeService.isDarkMode() ? ThemeMode.dark : ThemeMode.light; notifyListeners(); }
  Future<void> toggleTheme(bool isDark) async { await ThemeService.setDarkMode(isDark); _themeMode = isDark ? ThemeMode.dark : ThemeMode.light; notifyListeners(); }
}
