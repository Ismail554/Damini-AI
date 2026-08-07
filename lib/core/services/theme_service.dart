import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static SharedPreferences? _prefs;
  static const String _key = 'theme_mode_key';

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {}
  }

  static String getThemeModeString() {
    return _prefs?.getString(_key) ?? 'dark';
  }

  static Future<void> setThemeModeString(String mode) async {
    try {
      await _prefs?.setString(_key, mode);
    } catch (_) {}
  }
}
