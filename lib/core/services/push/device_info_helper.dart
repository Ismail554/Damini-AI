import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import '../../../shared/screens/notifications/repositories/notification_repository.dart';
import 'push_log.dart';

class DeviceInfoHelper {
  DeviceInfoHelper._();

  /// Human-readable device name (e.g. "iPhone 14 Pro", "Google Pixel 7").
  static Future<String> getDeviceName() async {
    try {
      final info = DeviceInfoPlugin();
      if (kIsWeb) {
        final web = await info.webBrowserInfo;
        return '${web.browserName.name} (${web.platform ?? ''})'.trim();
      }
      if (Platform.isIOS) {
        final ios = await info.iosInfo;
        return ios.name.isNotEmpty ? ios.name : ios.utsname.machine;
      }
      if (Platform.isAndroid) {
        final a = await info.androidInfo;
        if (a.model.toLowerCase().startsWith(a.manufacturer.toLowerCase())) {
          return a.model;
        }
        return '${a.manufacturer} ${a.model}'.trim();
      }
    } catch (e) {
      pushLog('Device name resolve failed: $e');
    }
    return NotificationRepository.getDefaultDeviceName();
  }
}
