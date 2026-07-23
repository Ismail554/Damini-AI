import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static SharedPreferences? _prefs;
  static const String _key = 'theme_mode_key';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String getThemeModeString() {
    return _prefs?.getString(_key) ?? 'system';
  }

  static Future<void> setThemeModeString(String mode) async {
    await _prefs?.setString(_key, mode);
  }
}
