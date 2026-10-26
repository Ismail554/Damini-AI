import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../firebase_options.dart';
import 'cache_service.dart';
import 'notification_service.dart';
import 'revenue_cat_service.dart';
import 'storage_service.dart';
import 'theme_service.dart';

class AppService {
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      log('Dotenv load error: $e');
    }
    await StorageService.init();
    await CacheService.init();
    await ThemeService.init();

    try {
      if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ).timeout(const Duration(seconds: 4));

        // Push notifications & permission requests run asynchronously
        // so they never block runApp() or freeze on the native splash.
        unawaited(_initPushNotifications());
      }
    } catch (e) {
      log('Firebase initialization error: $e');
    }

    try {
      final savedEmail = await StorageService.getUserEmail();
      await RevenueCatService.init(savedEmail);
    } catch (e) {
      log('RevenueCat initialization error: $e');
    }
  }

  static Future<void> _initPushNotifications() async {
    try {
      await NotificationService.init();
      await NotificationService.syncPendingDeviceToken();
    } catch (e) {
      log('Push notification init error: $e');
    }
  }
}
