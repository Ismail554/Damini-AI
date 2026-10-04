import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../../shared/screens/notifications/repositories/notification_repository.dart';
import '../api_error_handler.dart';
import '../api_service.dart';
import '../storage_service.dart';
import 'device_info_helper.dart';
import 'push_log.dart';
import 'push_payload.dart';

/// Owns FCM token lifecycle: fetch → validate → register (deduped) → delete.
class FcmTokenManager {
  FcmTokenManager._();

  static final NotificationRepository _repository =
      NotificationRepository(ApiService());

  static bool _isRegistering = false;

  static bool get isSupported => kIsWeb || Platform.isAndroid || Platform.isIOS;

  /// iOS: FCM token needs APNs token first. Poll briefly, don't block forever.
  static Future<bool> _ensureApnsToken() async {
    if (kIsWeb || !Platform.isIOS) return true;
    final messaging = FirebaseMessaging.instance;
    for (var i = 0; i < 5; i++) {
      final apns = await messaging.getAPNSToken();
      if (apns != null && apns.isNotEmpty) return true;
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    pushLog('APNs token unavailable (simulator or missing capability)');
    return false;
  }

  /// Fresh token from FCM, else cached. Returns null if invalid.
  static Future<String?> getToken() async {
    if (isSupported) {
      try {
        if (await _ensureApnsToken()) {
          final token = (await FirebaseMessaging.instance.getToken())?.trim();
          if (PushPayload.isValidFcmToken(token)) {
            await StorageService.saveDeviceToken(token!);
            return token;
          }
          pushLog('FCM returned invalid token');
        }
      } catch (e) {
        pushLog('getToken error: $e');
      }
    }
    final cached = await StorageService.getDeviceToken();
    return PushPayload.isValidFcmToken(cached) ? cached : null;
  }

  /// Validates auth + token, skips if backend already has same token.
  /// [force] → re-POST even if unchanged (use after login).
  static Future<bool> register({String? token, bool force = false}) async {
    if (_isRegistering) {
      pushLog('Register already in flight, skipped');
      return false;
    }
    _isRegistering = true;
    try {
      final authToken = await StorageService.getToken();
      if (authToken == null || authToken.isEmpty) {
        pushLog('Not authenticated → register deferred');
        return false;
      }

      final candidate = token?.trim();
      final fcmToken = PushPayload.isValidFcmToken(candidate)
          ? candidate!
          : await getToken();
      if (fcmToken == null) {
        pushLog('No valid FCM token → register skipped');
        return false;
      }

      if (!force) {
        final registered = await StorageService.getRegisteredDeviceToken();
        if (registered == fcmToken) {
          pushLog('Token already registered → skip');
          return true;
        }
      }

      final deviceName = await DeviceInfoHelper.getDeviceName();
      await _repository.registerDeviceToken(
        token: fcmToken,
        deviceName: deviceName,
      );
      pushLog('Token registered ($deviceName)');
      return true;
    } on AppException catch (e) {
      pushLog('Register failed: ${e.message}');
      return false;
    } catch (e) {
      pushLog('Register unexpected error: $e');
      return false;
    } finally {
      _isRegistering = false;
    }
  }

  /// Logout: invalidate token at FCM so old account stops receiving pushes.
  static Future<void> deleteToken() async {
    try {
      if (isSupported) await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      pushLog('deleteToken error: $e');
    } finally {
      await StorageService.clearPushData();
    }
  }
}
