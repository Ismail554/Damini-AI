import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../shared/global_key.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> init() async {}

  static Future<void> saveToken(String token) async =>
      _storage.write(key: GlobalKeys.authTokenKey, value: token);

  static Future<String?> getToken() async =>
      _storage.read(key: GlobalKeys.authTokenKey);

  static Future<void> saveUuid(String uuid) async =>
      _storage.write(key: GlobalKeys.uuidKey, value: uuid);

  static Future<String?> getUuid() async =>
      _storage.read(key: GlobalKeys.uuidKey);

  static Future<void> saveRole(String role) async {
    await _storage.write(key: GlobalKeys.userRoleKey, value: role);
    await _storage.write(key: GlobalKeys.isRoleSelectedKey, value: 'true');
  }

  static Future<String?> getRole() async =>
      _storage.read(key: GlobalKeys.userRoleKey);

  static Future<bool> isRoleSelected() async {
    final val = await _storage.read(key: GlobalKeys.isRoleSelectedKey);
    return val == 'true';
  }

  static Future<void> saveIsApiConnected(bool isConnected) async =>
      _storage.write(key: GlobalKeys.isApiConnectedKey, value: isConnected.toString());

  static Future<bool> getIsApiConnected() async {
    final val = await _storage.read(key: GlobalKeys.isApiConnectedKey);
    return val == 'true';
  }

  static Future<void> clearAll() async => _storage.deleteAll();
}
