import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static SharedPreferences? _prefs;
  static Future<void> init() async => _prefs = await SharedPreferences.getInstance();
  static bool isDarkMode() => _prefs?.getBool('is_dark') ?? false;
  static Future<void> setDarkMode(bool isDark) async => _prefs?.setBool('is_dark', isDark);
}
