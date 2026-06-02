class CacheService {
  static final Map<String, dynamic> _memoryCache = {};
  static Future<void> init() async {}
  static void set(String key, dynamic value) => _memoryCache[key] = value;
  static dynamic get(String key) => _memoryCache[key];
  static void clear() => _memoryCache.clear();
}
