import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../shared/global_key.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> init() async {}

  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: GlobalKeys.authTokenKey, value: token);
    } catch (_) {}
  }

  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: GlobalKeys.authTokenKey);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveUuid(String uuid) async {
    try {
      await _storage.write(key: GlobalKeys.uuidKey, value: uuid);
    } catch (_) {}
  }

  static Future<String?> getUuid() async {
    try {
      return await _storage.read(key: GlobalKeys.uuidKey);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveRole(String role) async {
    try {
      await _storage.write(key: GlobalKeys.userRoleKey, value: role);
      await _storage.write(key: GlobalKeys.isRoleSelectedKey, value: 'true');
    } catch (_) {}
  }

  static Future<String?> getRole() async {
    try {
      return await _storage.read(key: GlobalKeys.userRoleKey);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> isRoleSelected() async {
    try {
      final val = await _storage.read(key: GlobalKeys.isRoleSelectedKey);
      return val == 'true';
    } catch (_) {
      return false;
    }
  }

  static Future<void> saveIsApiConnected(bool isConnected) async {
    try {
      await _storage.write(
          key: GlobalKeys.isApiConnectedKey, value: isConnected.toString());
    } catch (_) {}
  }

  static Future<bool> getIsApiConnected() async {
    try {
      final val = await _storage.read(key: GlobalKeys.isApiConnectedKey);
      return val == 'true';
    } catch (_) {
      return false;
    }
  }

  static Future<void> saveHasSeenOnboarding() async {
    try {
      await _storage.write(key: GlobalKeys.hasSeenOnboardingKey, value: 'true');
    } catch (_) {}
  }

  static Future<bool> hasSeenOnboarding() async {
    try {
      final val = await _storage.read(key: GlobalKeys.hasSeenOnboardingKey);
      return val == 'true';
    } catch (_) {
      return false;
    }
  }

  static Future<void> clearAuthData() async {
    try {
      await _storage.delete(key: GlobalKeys.authTokenKey);
      await _storage.delete(key: GlobalKeys.uuidKey);
      await _storage.delete(key: GlobalKeys.userRoleKey);
      await _storage.delete(key: GlobalKeys.isRoleSelectedKey);
      await _storage.delete(key: GlobalKeys.isApiConnectedKey);
    } catch (_) {}
  }

  static Future<void> clearAll() async => clearAuthData();
}
