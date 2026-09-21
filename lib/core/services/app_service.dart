import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'cache_service.dart';
import 'storage_service.dart';
import 'theme_service.dart';

class AppService {
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      log('Dotenv load error: $e');
    }
    await StorageService.init();
    await CacheService.init();
    await ThemeService.init();
  }
}
