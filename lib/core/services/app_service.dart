import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../firebase_options.dart';
import 'cache_service.dart';
import 'notification_service.dart';
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
        );
        await NotificationService.init();
        // Fire-and-forget: never block app start on network.
        unawaited(NotificationService.syncPendingDeviceToken());
      }
    } catch (e) {
      log('Firebase initialization error: $e');
    }
  }
}
