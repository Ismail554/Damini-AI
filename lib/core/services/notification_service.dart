import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../firebase_options.dart';
import '../routing/app_router.dart';
import '../widgets/push_notification_toast.dart';
import 'push/device_info_helper.dart';
import 'push/fcm_token_manager.dart';
import 'push/local_notification_service.dart';
import 'push/push_log.dart';
import 'push/push_payload.dart';
import 'storage_service.dart';

/// Background isolate entry. Must re-init Firebase (separate isolate).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    logFcmPayload(message, source: 'Background');
    pushLog('Background message handled: ${message.messageId}');

    // If backend sends data-only message (message.notification is null),
    // Android OS doesn't automatically show heads-up banner on its own.
    // Display local notification so sound, vibration, and popup trigger!
    if (message.notification == null) {
      final payload = PushPayload.fromRemoteMessage(message);
      if (payload.hasDisplayContent) {
        await LocalNotificationService.initInBackground();
        await LocalNotificationService.show(payload);
      }
    }
  } catch (e) {
    pushLog('Background handler error: $e');
  }
}

/// Orchestrates FCM: permissions, listeners, foreground display, tap routing.
class NotificationService {
  NotificationService._();

  static bool _initialized = false;
  static bool _permissionDenied = false;
  static String? _pendingRoute;
  static final List<StreamSubscription<dynamic>> _subs = [];
  static final StreamController<PushPayload> _foreground =
      StreamController<PushPayload>.broadcast();

  /// Fires on every foreground push → screens can refresh (e.g. inbox list).
  static Stream<PushPayload> get onForegroundMessage => _foreground.stream;

  /// Call once, after Firebase.initializeApp, before runApp.
  static Future<void> init() async {
    if (_initialized || !FcmTokenManager.isSupported) return;
    try {
      final messaging = FirebaseMessaging.instance;
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        criticalAlert: true,
        provisional: false,
      );
      _permissionDenied =
          settings.authorizationStatus == AuthorizationStatus.denied;
      pushLog('Permission: ${settings.authorizationStatus}');

      // iOS: let FCM render banner while app open (no duplicate local one).
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      await LocalNotificationService.init(onTap: _handleTap);

      _subs
        ..add(messaging.onTokenRefresh.listen((token) {
          pushLog('Token refreshed');
          FcmTokenManager.register(token: token);
        }))
        ..add(FirebaseMessaging.onMessage.listen(_onForegroundMessage))
        ..add(FirebaseMessaging.onMessageOpenedApp.listen((m) {
          logFcmPayload(m, source: 'Opened from Background / Tray');
          _handleTap(PushPayload.fromRemoteMessage(m));
        }));

      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        logFcmPayload(initial, source: 'Initial Launch');
        await _handleTap(PushPayload.fromRemoteMessage(initial));
      }
      _initialized = true;
    } catch (e) {
      pushLog('Init failed: $e');
    }
  }

  static void _onForegroundMessage(RemoteMessage message) {
    logFcmPayload(message, source: 'Foreground');
    final payload = PushPayload.fromRemoteMessage(message);
    _foreground.add(payload);

    // 1. Android system notification bar
    LocalNotificationService.show(payload);

    // 2. In-app toast style rounded snack bar with title
    PushNotificationToast.show(
      title: payload.title.isNotEmpty ? payload.title : 'New Notification',
      message: payload.body.isNotEmpty ? payload.body : 'Tap to view details',
      onTap: () => _handleTap(payload),
    );
  }

  static Future<void> _handleTap(PushPayload payload) async {
    try {
      final authToken = await StorageService.getToken();
      if (authToken == null || authToken.isEmpty) {
        pushLog('Tap ignored: not authenticated');
        return;
      }
      final route = payload.resolveRoute(await StorageService.getRole());
      final current =
          AppRouter.router.routerDelegate.currentConfiguration.uri.path;

      // App still on splash (cold start) → defer until home is ready.
      if (current.isEmpty || current == '/') {
        _pendingRoute = route;
        return;
      }
      _navigate(route, current);
    } catch (e) {
      pushLog('Tap handling failed: $e');
    }
  }

  static void _navigate(String route, String current) {
    if (route == current) return;
    if (route == '/home') {
      AppRouter.router.go(route);
    } else {
      AppRouter.router.push(route);
    }
  }

  /// Splash calls this after landing on /home.
  static void consumePendingRoute() {
    final route = _pendingRoute;
    _pendingRoute = null;
    if (route == null) return;
    try {
      _navigate(route, '/home');
    } catch (e) {
      pushLog('Pending route navigation failed: $e');
    }
  }

  /// Validates auth + permission + token, then registers with backend.
  static Future<bool> validateAndRegisterDeviceToken({
    String? customToken,
    bool force = false,
  }) async {
    if (!FcmTokenManager.isSupported) return false;
    if (_permissionDenied) {
      pushLog('Permission denied → register skipped');
      return false;
    }
    return FcmTokenManager.register(token: customToken, force: force);
  }

  /// Startup sync: only POSTs if token changed since last registration.
  static Future<bool> syncPendingDeviceToken() =>
      validateAndRegisterDeviceToken();

  static Future<String?> getOrFetchFcmToken() => FcmTokenManager.getToken();

  static Future<String> getDeviceName() => DeviceInfoHelper.getDeviceName();

  /// Logout: drop FCM token so this device stops getting old user's pushes.
  static Future<void> onLogout() async {
    _pendingRoute = null;
    await FcmTokenManager.deleteToken();
  }
}
