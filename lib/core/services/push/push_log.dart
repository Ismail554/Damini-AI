import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Debug-only logger for push pipeline. Never prints in release.
void pushLog(String message) {
  if (kDebugMode) debugPrint('[Push] $message');
}

/// Print formatted FCM payload box with all fields.
void logFcmPayload(RemoteMessage message, {String source = 'Foreground'}) {
  if (!kDebugMode) return;
  final n = message.notification;
  final buffer = StringBuffer()
    ..writeln('╔══════════════════════════════════════════════════════════════════')
    ..writeln('║ 🔔 [FCM PAYLOAD RECEIVED] — $source')
    ..writeln('║ Message ID   : ${message.messageId ?? "N/A"}')
    ..writeln('║ From         : ${message.from ?? "N/A"}')
    ..writeln('║ Collapse Key : ${message.collapseKey ?? "N/A"}')
    ..writeln('║ Sent Time    : ${message.sentTime?.toIso8601String() ?? "N/A"}');

  if (n != null) {
    buffer
      ..writeln('╟──────────────────────────────────────────────────────────────────')
      ..writeln('║ 📋 Notification Details:')
      ..writeln('║   Title: ${n.title ?? ""}')
      ..writeln('║   Body : ${n.body ?? ""}')
      ..writeln('║   Android Channel : ${n.android?.channelId ?? "N/A"}')
      ..writeln('║   Apple Subtitle  : ${n.apple?.subtitle ?? "N/A"}');
  }

  buffer
    ..writeln('╟──────────────────────────────────────────────────────────────────')
    ..writeln('║ 📦 Data Payload (${message.data.length} keys):');

  if (message.data.isEmpty) {
    buffer.writeln('║   <empty>');
  } else {
    message.data.forEach((key, value) {
      buffer.writeln('║   $key: $value');
    });
  }

  buffer.writeln('╚══════════════════════════════════════════════════════════════════');
  debugPrint(buffer.toString());
}
