import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Custom Dio Interceptor that prints every API call with only
/// endpoint, body payload, and response in a clean diagnostic box format.
class ApiLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['requestBody'] = options.data;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _printApiLog(
      method: response.requestOptions.method,
      endpoint: _extractPath(response.requestOptions.path),
      payload: response.requestOptions.extra['requestBody'] ??
          response.requestOptions.data,
      response: response.data,
      statusCode: response.statusCode,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _printApiLog(
      method: err.requestOptions.method,
      endpoint: _extractPath(err.requestOptions.path),
      payload: err.requestOptions.extra['requestBody'] ??
          err.requestOptions.data,
      response: err.response?.data ?? err.message ?? 'Unknown error',
      statusCode: err.response?.statusCode,
      isError: true,
    );
    handler.next(err);
  }

  static String _extractPath(String rawPath) {
    try {
      final uri = Uri.parse(rawPath);
      if (uri.hasScheme || uri.host.isNotEmpty) {
        return uri.path;
      }
    } catch (_) {}
    return rawPath;
  }

  static void _printApiLog({
    required String method,
    required String endpoint,
    required dynamic payload,
    required dynamic response,
    int? statusCode,
    bool isError = false,
  }) {
    if (!kDebugMode) return;

    final bodyPayload = _formatData(payload);
    final responseData = _formatData(response);

    debugPrint('╔═══════════════════════════════════════════════════════════');
    debugPrint('║ ${isError ? '❌ API ERROR' : '🌐 API CALL'}');
    debugPrint('╠═══════════════════════════════════════════════════════════');
    _printField('Endpoint', '$method $endpoint');
    _printField('Body Payload', bodyPayload);
    _printField('Status Code', '${statusCode ?? '-'}');
    _printField(isError ? 'Error' : 'Response', responseData);
    debugPrint('╚═══════════════════════════════════════════════════════════');
  }

  static void _printField(String label, String content) {
    final lines = content.split('\n');
    if (lines.isEmpty) {
      debugPrint('║ $label : ');
      return;
    }
    debugPrint('║ $label : ${lines.first}');
    final indent = '║ ${' ' * label.length}   ';
    for (int i = 1; i < lines.length; i++) {
      debugPrint('$indent${lines[i]}');
    }
  }

  static String _formatData(dynamic data) {
    if (data == null) return 'None';
    String str;
    if (data is String) {
      str = data;
    } else if (data is FormData) {
      final fields = Map.fromEntries(data.fields);
      final files = data.files.map((e) => '${e.key}: ${e.value.filename}').toList();
      str = '{fields: $fields, files: $files}';
    } else {
      try {
        if (data is Map) {
          final sanitized = Map<String, dynamic>.from(data);
          if (sanitized.containsKey('password')) {
            sanitized['password'] = '******';
          }
          if (sanitized.containsKey('access')) {
            sanitized['access'] = '******';
          }
          if (sanitized.containsKey('refresh')) {
            sanitized['refresh'] = '******';
          }
          str = jsonEncode(sanitized);
        } else {
          str = jsonEncode(data);
        }
      } catch (_) {
        str = data.toString();
      }
    }
    return str.length > 800 ? '${str.substring(0, 800)}…' : str;
  }
}
