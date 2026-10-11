import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_error_handler.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/push/push_payload.dart';
import '../../../../core/services/storage_service.dart';
import '../models/notification_model.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(apiServiceProvider));
});

class NotificationRepository {
  final ApiService? _apiService;

  NotificationRepository([this._apiService]);

  ApiService get _api => _apiService ?? ApiService();

  static String getDefaultDeviceName() {
    if (Platform.isAndroid) return 'Android Device';
    if (Platform.isIOS) return 'iPhone';
    if (Platform.isMacOS) return 'Mac';
    if (Platform.isWindows) return 'Windows PC';
    if (Platform.isLinux) return 'Linux Device';
    return 'Mobile Device';
  }

  /// POST /api/v1/notifications/device-token/
  /// Payload: { "token": "xyz...", "device_name": "iPhone 14 Pro" }
  /// Throws [ValidationException] for bad input, [AppException] for API errors.
  Future<bool> registerDeviceToken({
    required String token,
    String? deviceName,
  }) async {
    final cleanToken = token.trim();
    if (!PushPayload.isValidFcmToken(cleanToken)) {
      throw const ValidationException('Invalid FCM device token.');
    }
    final name = (deviceName != null && deviceName.trim().isNotEmpty)
        ? deviceName.trim()
        : getDefaultDeviceName();

    final deviceType = Platform.isIOS
        ? 'ios'
        : (Platform.isAndroid ? 'android' : 'web');

    await _api.post(
      ApiEndpoints.deviceToken,
      data: {
        'token': cleanToken,
        'device_type': deviceType,
        'device_name': name,
      },
      requireAuth: true,
    );

    await StorageService.saveDeviceToken(cleanToken);
    await StorageService.saveRegisteredDeviceToken(cleanToken);
    await StorageService.saveDeviceName(name);
    return true;
  }

  /// GET /api/v1/notifications/
  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final response = await _api.get(
        ApiEndpoints.getNotifications,
        requireAuth: true,
      );

      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      List rawList = [];
      if (data is Map && data['data'] is List) {
        rawList = data['data'] as List;
      } else if (data is List) {
        rawList = data;
      } else if (data is Map && data['results'] is List) {
        rawList = data['results'] as List;
      }

      final list = <NotificationModel>[];
      for (final item in rawList.whereType<Map>()) {
        try {
          list.add(NotificationModel.fromJson(Map<String, dynamic>.from(item)));
        } catch (_) {}
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  /// POST /api/v1/notifications/{id}/read/
  Future<bool> markAsRead(String id) async {
    try {
      await _api.post(
        ApiEndpoints.markRead(id),
        data: {},
        requireAuth: true,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// POST /api/v1/notifications/mark-all-read/
  Future<bool> markAllAsRead() async {
    try {
      await _api.post(
        ApiEndpoints.markAllRead,
        data: {},
        requireAuth: true,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// DELETE /api/v1/notifications/{id}/
  Future<bool> deleteNotification(String id) async {
    try {
      await _api.delete(
        ApiEndpoints.deleteNotification(id),
        requireAuth: true,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Clear all notifications: DELETE or POST /api/v1/notifications/clear-all/
  Future<bool> clearAllNotifications() async {
    try {
      try {
        await _api.delete(
          ApiEndpoints.clearAllNotifications,
          requireAuth: true,
        );
      } catch (_) {
        await _api.post(
          ApiEndpoints.clearAllNotifications,
          data: {},
          requireAuth: true,
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
