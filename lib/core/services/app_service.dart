import 'cache_service.dart';
import 'storage_service.dart';
import 'theme_service.dart';

class AppService {
  static Future<void> init() async {
    await StorageService.init();
    await CacheService.init();
    await ThemeService.init();
  }
}
