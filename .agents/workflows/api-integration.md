---
description: Workflow 1 — Dio Client & Styled Debug Logging & Workflow 4 — API Wiring Protocol (with Field Validation Check-in)
---

Scope: Moving the app from static demo data to a fully wired backend, for both the Investor and Sponsor roles, without breaking UI stability or leaving loose ends in state management.

This is written as seven standalone workflows. Each one can be handed to a teammate (or pasted into a Claude Code session) on its own — you don't need the whole document loaded to work on just the caching piece, for example.

Guiding Principles

These apply across every workflow below. If a PR violates one of these, it's not done yet, regardless of whether it "works."

Endpoint-only logging, always. No baseUrl ever hits the console.
Every card/list/project screen owns three states — Loading, Data, Error/Empty. A screen with only a happy path is incomplete.
Text-only fields don't get the three-state treatment. A label, a counter, a balance — update the value directly, don't shimmer the whole screen for it.
Investor and Sponsor are separate concerns, not an if (role == ...) scattered through shared widgets.
Before wiring any endpoint that sends a payload, the API contract gets checked against the UI form — mismatches get flagged before code gets written, not discovered in QA.
Null safety is non-negotiable — no !, no unguarded [0], no trusting a JSON key exists because the Postman response had it once.
Perceived speed matters as much as real speed — prefetch, cache, and never make the user stare at a spinner for data you already had five seconds ago.
Workflow 1 — Dio Client & Styled Debug Logging

Goal: every network call — request and response — prints to the debug console in a consistent, scannable box, with the endpoint only (never the full URL) and the raw body/payload.

1.1 Logger utility

Put this in core/network/api_logger.dart. It's a pure formatting utility — no Dio dependency required, so it can also be used from anywhere else you need to print structured debug output.

dart
import 'package:flutter/foundation.dart';

class ApiLogger {
  ApiLogger._();

  static const _line =
      '═══════════════════════════════════════════════════════════';

  static void call({
    required String method,
    required String endpoint, // path only, e.g. /api/v1/projects/sponsor/
    Object? body,
    Object? response,
    int? statusCode,
  }) {
    if (!kDebugMode) return;

    final buffer = StringBuffer()
      ..writeln('╔$_line')
      ..writeln('║ 🌐 API CALL')
      ..writeln('╠$_line')
      ..writeln('║ Endpoint      : $method $endpoint')
      ..writeln('║ Body Payload  : ${_format(body)}')
      ..writeln('║ Status Code   : ${statusCode ?? '-'}')
      ..writeln('║ Response      : ${_format(response)}')
      ..write('╚$_line');

    debugPrint(buffer.toString());
  }

  static void error({
    required String method,
    required String endpoint,
    Object? body,
    required Object error,
    int? statusCode,
  }) {
    if (!kDebugMode) return;

    final buffer = StringBuffer()
      ..writeln('╔$_line')
      ..writeln('║ ❌ API ERROR')
      ..writeln('╠$_line')
      ..writeln('║ Endpoint      : $method $endpoint')
      ..writeln('║ Body Payload  : ${_format(body)}')
      ..writeln('║ Status Code   : ${statusCode ?? '-'}')
      ..writeln('║ Error         : $error')
      ..write('╚$_line');

    debugPrint(buffer.toString());
  }

  static String _format(Object? data) {
    if (data == null) return 'None';
    final str = data.toString();
    return str.length > 800 ? '${str.substring(0, 800)}…' : str;
  }
}

debugPrint (not print) — it throttles output so long boxes don't get truncated by the Android log buffer, which print() is prone to on large payloads.

1.2 Wiring it into the Dio interceptor

Endpoint-only means: strip everything before the path when logging, but still use the full URL (with baseUrl) for the actual request — the rule is about what's printed, not how Dio is configured.

dart
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['requestBody'] = options.data;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    ApiLogger.call(
      method: response.requestOptions.method,
      endpoint: response.requestOptions.path, // path only — no baseUrl
      body: response.requestOptions.extra['requestBody'],
      response: response.data,
      statusCode: response.statusCode,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    ApiLogger.error(
      method: err.requestOptions.method,
      endpoint: err.requestOptions.path,
      body: err.requestOptions.extra['requestBody'],
      error: err.response?.data ?? err.message ?? 'Unknown error',
      statusCode: err.response?.statusCode,
    );
    handler.next(err);
  }
}

Register once in the Dio factory (core/network/dio_client.dart):

dart
final dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl))
  ..interceptors.addAll([
    AuthInterceptor(),
    LoggingInterceptor(),
  ]);
1.3 Rules for this workflow
endpoint is always requestOptions.path, never requestOptions.uri. path is the route as declared (/api/v1/projects/sponsor/); uri includes the scheme and host, which is exactly what we're hiding.
This interceptor only runs in debug — wrap the whole LoggingInterceptor registration in if (kDebugMode) at the composition point too, as a second guard, so it can never ship active in release by accident.
Never log Authorization headers or tokens, even in debug — add a redaction step if you ever need header visibility: headers.map((k, v) => k == 'Authorization' ? '***' : v).
For file uploads (FormData), don't dump the raw bytes — log the field names and file sizes instead (_format already truncates at 800 chars, but binary data should never reach the formatter to begin with).
Goal: a repeatable sequence for turning "here's an endpoint" into wired, validated, null-safe code — and a hard checkpoint before writing any payload-carrying endpoint.

4.1 The wiring sequence

For every endpoint, in this order:

Model — fromJson/toJson only, no logic. Every field nullable unless the backend contract guarantees it.
Repository method — calls the ApiClient, validates the raw response shape, maps errors to typed exceptions, returns a Result<T>.
Service/Controller — only if there's real business logic (combining two repositories, computing a derived value). Skip this layer for a straight pass-through.
Provider — exposes load()/refresh()/submit(), owns ListState/ FeatureState, never touches Dio or raw JSON.
Screen — renders the three states (Workflow 2), calls provider intent methods only.
4.2 Field validation check-in — mandatory before payload endpoints

Before implementing any endpoint that sends a body (POST/PUT/PATCH), stop and run this comparison before writing the model or the form-submit code:

UI form fields  vs.  API request schema  vs.  API response schema

Then flag, explicitly, before proceeding:

Missing from the API — a field the UI collects (or needs to display) that the request/response schema doesn't have a slot for.
Extra in the API — a field the request/response includes that the UI has no form control or display slot for.
Type or shape mismatches — e.g., UI collects a date picker value but the API expects a Unix timestamp string; UI treats a field as required but the schema marks it optional (or vice versa).

Ask a question shaped like this rather than guessing silently:

"The create_project payload doesn't include a currency field, but the form has a currency selector — should that be dropped, hardcoded, or is the field named differently on the backend? Also, the response includes sponsor_verified_badge, which isn't shown anywhere yet — is that meant to render on the card?"

This check-in happens once per endpoint, before coding, not as a running commentary during implementation. Silence after this checkpoint means the contract is confirmed — proceed to modeling.

4.3 Repository-level validation

Treat null, [], "", and missing keys as empty, never as an error. Reserve error states for real failures.

dart
Future<Result<List<Project>>> getSponsorProjects() async {
  if (!await _connectivity.isConnected) {
    return const Result.failure('No internet connection.');
  }

  try {
    final response = await _apiClient.get('/api/v1/projects/sponsor/');
    final data = response.data;

    if (data is! Map<String, dynamic>) {
      return const Result.success([]); // malformed but non-fatal → empty
    }

    final list = data['data'];
    if (list is! List || list.isEmpty) {
      return const Result.success([]);
    }

    final projects = list
        .whereType<Map<String, dynamic>>()
        .map(Project.fromJson)
        .toList();

    return Result.success(projects);
  } on DioException catch (e) {
    return Result.failure(_mapDioError(e));
  } catch (e) {
    return const Result.failure('Something went wrong. Please try again.');
  }
}

Skip or safely drop a single malformed list item rather than letting one bad record crash the whole list:

dart
final projects = <Project>[];
for (final item in list.whereType<Map<String, dynamic>>()) {
  try {
    projects.add(Project.fromJson(item));
  } catch (_) {
    continue; // one bad record shouldn't take down the list
  }
}