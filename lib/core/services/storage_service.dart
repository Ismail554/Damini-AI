import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../shared/global_key.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> init() async {}

  static Future<void> saveToken(String token) async {
    try {
      final trimmed = token.trim();
      if (trimmed.isNotEmpty) {
        await _storage.write(key: GlobalKeys.access, value: trimmed);
      }
    } catch (_) {}
  }

  static Future<String?> getToken() async {
    try {
      final val = await _storage.read(key: GlobalKeys.access);
      if (val == null || val.trim().isEmpty) return null;
      return val.trim();
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveRefreshToken(String token) async {
    try {
      final trimmed = token.trim();
      if (trimmed.isNotEmpty) {
        await _storage.write(key: GlobalKeys.refresh, value: trimmed);
      }
    } catch (_) {}
  }

  static Future<String?> getRefreshToken() async {
    try {
      final val = await _storage.read(key: GlobalKeys.refresh);
      if (val == null || val.trim().isEmpty) return null;
      return val.trim();
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
      final trimmed = role.trim();
      await _storage.write(key: GlobalKeys.userRole, value: trimmed);
      await _storage.write(key: GlobalKeys.isRoleSelected, value: 'true');
    } catch (_) {}
  }

  static Future<String?> getRole() async {
    try {
      final val = await _storage.read(key: GlobalKeys.userRole);
      if (val == null || val.trim().isEmpty) return null;
      return val.trim();
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

  static Future<void> clearRole() async {
    try {
      await _storage.delete(key: GlobalKeys.userRole);
      await _storage.delete(key: GlobalKeys.isRoleSelected);
    } catch (_) {}
  }

  static Future<void> clearAuthData() async {
    try {
      await _storage.delete(key: GlobalKeys.access);
      await _storage.delete(key: GlobalKeys.refresh);
    } catch (_) {}
  }

  static Future<void> saveDeviceToken(String token) async {
    try {
      final trimmed = token.trim();
      if (trimmed.isNotEmpty) {
        await _storage.write(key: GlobalKeys.deviceToken, value: trimmed);
      }
    } catch (_) {}
  }

  static Future<String?> getDeviceToken() async {
    try {
      final val = await _storage.read(key: GlobalKeys.deviceToken);
      if (val == null || val.trim().isEmpty) return null;
      return val.trim();
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveDeviceName(String name) async {
    try {
      final trimmed = name.trim();
      if (trimmed.isNotEmpty) {
        await _storage.write(key: GlobalKeys.deviceName, value: trimmed);
      }
    } catch (_) {}
  }

  static Future<String?> getDeviceName() async {
    try {
      final val = await _storage.read(key: GlobalKeys.deviceName);
      if (val == null || val.trim().isEmpty) return null;
      return val.trim();
    } catch (_) {
      return null;
    }
  }

  /// Token last confirmed by backend (POST device-token succeeded).
  static Future<void> saveRegisteredDeviceToken(String token) async {
    try {
      final trimmed = token.trim();
      if (trimmed.isNotEmpty) {
        await _storage.write(
          key: GlobalKeys.registeredDeviceToken,
          value: trimmed,
        );
      }
    } catch (_) {}
  }

  static Future<String?> getRegisteredDeviceToken() async {
    try {
      final val = await _storage.read(key: GlobalKeys.registeredDeviceToken);
      if (val == null || val.trim().isEmpty) return null;
      return val.trim();
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearPushData() async {
    try {
      await _storage.delete(key: GlobalKeys.deviceToken);
      await _storage.delete(key: GlobalKeys.registeredDeviceToken);
    } catch (_) {}
  }

  static Future<void> clearAll() async {
    try {
      await _storage.delete(key: GlobalKeys.access);
      await _storage.delete(key: GlobalKeys.refresh);
      await _storage.delete(key: GlobalKeys.uuid);
      await _storage.delete(key: GlobalKeys.userRole);
      await _storage.delete(key: GlobalKeys.isRoleSelected);
      await _storage.delete(key: GlobalKeys.registeredDeviceToken);
    } catch (_) {}
  }
}
