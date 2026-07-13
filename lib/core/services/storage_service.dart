import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();
  static Future<void> init() async {}
  static Future<void> saveToken(String token) async => _storage.write(key: 'auth_token', value: token);
  static Future<String?> getToken() async => _storage.read(key: 'auth_token');
  static Future<void> saveUuid(String uuid) async => _storage.write(key: 'uuid', value: uuid);
  static Future<String?> getUuid() async => _storage.read(key: 'uuid');
  static Future<void> saveRole(String role) async => _storage.write(key: 'user_role', value: role);
  static Future<String?> getRole() async => _storage.read(key: 'user_role');
  static Future<void> clearAll() async => _storage.deleteAll();
}

