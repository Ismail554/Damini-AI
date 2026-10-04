import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../utils/app_colors.dart';
import 'push_log.dart';
import 'push_payload.dart';

/// Shows heads-up banners for FCM messages received while app in foreground
/// or background data messages. Configured for sound, vibration, and popup banner.
class LocalNotificationService {
  LocalNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'damini_alerts_v1';
  static const String oldChannelId = 'high_importance_channel';

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    channelId,
    'Alerts & Notifications',
    description: 'High priority alerts, chats, and project updates.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    enableLights: true,
  );

  static bool _initialized = false;

  static bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  static Future<void> init({
    required void Function(PushPayload payload) onTap,
  }) async {
    if (_initialized || !_isAndroid) return;
    try {
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_notification'),
      );
      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (response) {
          final payload = PushPayload.fromEncoded(response.payload);
          if (payload != null) onTap(payload);
        },
      );

      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // Purge old channel if present to overwrite stale sound/popup caches
      try {
        await androidPlugin?.deleteNotificationChannel(
          channelId: oldChannelId,
        );
      } catch (_) {}

      await androidPlugin?.createNotificationChannel(channel);
      _initialized = true;

      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        final payload =
            PushPayload.fromEncoded(launch?.notificationResponse?.payload);
        if (payload != null) onTap(payload);
      }
    } catch (e) {
      pushLog('Local notifications init failed: $e');
    }
  }

  /// Initialize for background isolate (handles data-only FCM messages)
  static Future<void> initInBackground() async {
    if (_initialized || !_isAndroid) return;
    try {
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_notification'),
      );
      await _plugin.initialize(settings: settings);
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(channel);
      _initialized = true;
    } catch (e) {
      pushLog('Background local notif init failed: $e');
    }
  }

  static Future<void> show(PushPayload payload) async {
    if (!_initialized || !payload.hasDisplayContent) return;
    try {
      final id = (payload.messageId ?? DateTime.now().toIso8601String())
              .hashCode &
          0x7fffffff;
      await _plugin.show(
        id: id,
        title: payload.title,
        body: payload.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
            enableVibration: true,
            enableLights: true,
            category: AndroidNotificationCategory.message,
            icon: '@drawable/ic_notification',
            color: AppColors.primaryColor,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload.encode(),
      );
    } catch (e) {
      pushLog('Local notification show failed: $e');
    }
  }
}
