import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../shared/global_key.dart';

/// Null-safe view over an FCM [RemoteMessage]. Never throws on bad data.
class PushPayload {
  const PushPayload({
    required this.title,
    required this.body,
    required this.data,
    this.messageId,
  });

  final String title;
  final String body;
  final Map<String, String> data;
  final String? messageId;

  static const String fallbackRoute = '/notifications';

  static const Set<String> _sharedRoutes = {
    '/notifications',
    '/home',
    '/settings',
    '/subscription',
  };
  static const Set<String> _sponsorRoutes = {
    '/collaboration-requests',
    '/sponsor-projects',
  };
  static const Set<String> _investorRoutes = {
    '/discover',
    '/investment-history',
  };

  static final RegExp _tokenPattern = RegExp(r'^[A-Za-z0-9_\-:]+$');

  /// FCM tokens: URL-safe chars, realistic length bounds.
  static bool isValidFcmToken(String? token) {
    final t = token?.trim() ?? '';
    return t.length >= 32 && t.length <= 4096 && _tokenPattern.hasMatch(t);
  }

  factory PushPayload.fromRemoteMessage(RemoteMessage message) {
    final data = <String, String>{};
    message.data.forEach((key, value) {
      if (value != null) data[key] = value.toString();
    });
    final n = message.notification;
    return PushPayload(
      title: _clean(n?.title) ?? _clean(data['title']) ?? '',
      body: _clean(n?.body) ?? _clean(data['body'] ?? data['message']) ?? '',
      data: data,
      messageId: message.messageId,
    );
  }

  /// Restores payload from local-notification tap string.
  static PushPayload? fromEncoded(String? encoded) {
    if (encoded == null || encoded.isEmpty) return null;
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map) return null;
      final data = <String, String>{};
      decoded.forEach((k, v) {
        if (k != null && v != null) data[k.toString()] = v.toString();
      });
      return PushPayload(title: '', body: '', data: data);
    } catch (_) {
      return null;
    }
  }

  String encode() => jsonEncode(data);

  bool get hasDisplayContent => title.isNotEmpty || body.isNotEmpty;

  /// Validated, role-scoped route. Unknown / cross-role → [fallbackRoute].
  String resolveRoute(String? role) {
    final raw = _clean(data['route'] ?? data['target_url']);
    if (raw == null) return fallbackRoute;
    final path = Uri.tryParse(raw)?.path ?? '';
    if (!path.startsWith('/')) return fallbackRoute;
    if (_sharedRoutes.contains(path)) return path;
    final r = role?.toLowerCase();
    if (r == GlobalKeys.sponsorRole && _sponsorRoutes.contains(path)) {
      return path;
    }
    if (r == GlobalKeys.investorRole && _investorRoutes.contains(path)) {
      return path;
    }
    return fallbackRoute;
  }

  static String? _clean(String? v) {
    final t = v?.trim() ?? '';
    return t.isEmpty ? null : t;
  }
}
