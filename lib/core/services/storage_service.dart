import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../shared/global_key.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> init() async {}

  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: GlobalKeys.access, value: token);
    } catch (_) {}
  }

  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: GlobalKeys.access);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: GlobalKeys.refresh, value: token);
    } catch (_) {}
  }

  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: GlobalKeys.refresh);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveUuid(String uuid) async {
    try {
      await _storage.write(key: GlobalKeys.uuid, value: uuid);
    } catch (_) {}
  }

  static Future<String?> getUuid() async {
    try {
      return await _storage.read(key: GlobalKeys.uuid);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveRole(String role) async {
    try {
      await _storage.write(key: GlobalKeys.userRole, value: role);
      await _storage.write(key: GlobalKeys.isRoleSelected, value: 'true');
    } catch (_) {}
  }

  static Future<String?> getRole() async {
    try {
      return await _storage.read(key: GlobalKeys.userRole);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> isRoleSelected() async {
    try {
      final val = await _storage.read(key: GlobalKeys.isRoleSelected);
      return val == 'true';
    } catch (_) {
      return false;
    }
  }

  static Future<void> saveIsApiConnected(bool isConnected) async {
    try {
      await _storage.write(
        key: GlobalKeys.isApiConnected,
        value: isConnected.toString(),
      );
    } catch (_) {}
  }

  static Future<bool> getIsApiConnected() async {
    try {
      final val = await _storage.read(key: GlobalKeys.isApiConnected);
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
      await _storage.delete(key: GlobalKeys.access);
      await _storage.delete(key: GlobalKeys.refresh);
    } catch (_) {}
  }

  static Future<void> clearAll() async => clearAuthData();
}
