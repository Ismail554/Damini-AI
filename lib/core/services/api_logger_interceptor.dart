import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Custom Dio Interceptor that prints every API call with only
/// endpoint, body payload, and response in a clean diagnostic box format.
class ApiLoggerInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _printApiLog(
      method: response.requestOptions.method,
      uri: response.requestOptions.uri,
      payload: response.requestOptions.data,
      response: response.data,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _printApiLog(
      method: err.requestOptions.method,
      uri: err.requestOptions.uri,
      payload: err.requestOptions.data,
      response: err.response?.data ?? err.message ?? 'Unknown error',
      isError: true,
    );
    handler.next(err);
  }

  static void _printApiLog({
    required String method,
    required Uri uri,
    required dynamic payload,
    required dynamic response,
    bool isError = false,
  }) {
    final endpoint = '$method $uri';
    final bodyPayload = _formatData(payload);
    final responseData = _formatData(response);

    debugPrint('╔═══════════════════════════════════════════════════════════');
    debugPrint('║ 🌐 API CALL${isError ? ' (ERROR)' : ''}');
    debugPrint('╠═══════════════════════════════════════════════════════════');
    _printField('Endpoint', endpoint);
    _printField('Body Payload', bodyPayload);
    _printField('Response', responseData);
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
    if (data is String) return data;
    if (data is FormData) {
      final fields = Map.fromEntries(data.fields);
      final files = data.files.map((e) => '${e.key}: ${e.value.filename}').toList();
      return '{fields: $fields, files: $files}';
    }
    try {
      return jsonEncode(data);
    } catch (_) {
      return data.toString();
    }
  }
}
