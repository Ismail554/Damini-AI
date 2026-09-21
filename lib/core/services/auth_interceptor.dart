import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import 'storage_service.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;

  // Dedicated clean Dio instance for token refresh (lazy singleton: allocated only once)
  late final Dio _refreshDio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        'User-Agent': 'Braintech-Mobile-App/1.0',
      },
    ),
  );

  // Lock to handle concurrent 401 errors so only 1 refresh API call is triggered
  Completer<bool>? _refreshCompleter;

  AuthInterceptor(this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 1. Fast O(1) check: if the request explicitly opts out of authentication
    if (options.extra['requiresAuth'] == false) {
      return handler.next(options);
    }

    // 2. Skip storage lookup if authorization header is already supplied
    if (options.headers.containsKey('Authorization')) {
      return handler.next(options);
    }

    // 3. Attach access token to request headers if available
    final accessToken = await StorageService.getToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Fast exit: if not 401, immediately pass the error
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Fast exit: do not refresh if this was already a retry (prevents infinite loop)
    if (err.requestOptions.extra['isRetry'] == true) {
      return handler.next(err);
    }

    // Fast exit: do not refresh if the request did not require auth
    if (err.requestOptions.extra['requiresAuth'] == false) {
      return handler.next(err);
    }

    log('401 Unauthorized detected for [${err.requestOptions.path}]. Handling token refresh...');

    bool refreshSuccess = false;

    // Concurrency Lock: If a refresh is already in progress, wait for it
    if (_refreshCompleter != null) {
      refreshSuccess = await _refreshCompleter!.future;
    } else {
      _refreshCompleter = Completer<bool>();
      refreshSuccess = await _refreshToken();
      _refreshCompleter!.complete(refreshSuccess);
      _refreshCompleter = null;
    }

    if (refreshSuccess) {
      try {
        final requestOptions = err.requestOptions;
        final newToken = await StorageService.getToken();

        requestOptions.headers['Authorization'] = 'Bearer $newToken';
        requestOptions.extra['isRetry'] = true;

        final response = await _dio.fetch(requestOptions);
        return handler.resolve(response);
      } catch (e) {
        log('Request retry failed after token refresh: $e');
        return handler.next(err);
      }
    } else {
      log('Token refresh failed. Clearing auth credentials...');
      await StorageService.clearAuthData();
      return handler.next(err);
    }
  }

  /// Refresh the access token using the stored refresh token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        log('No refresh token available in storage.');
        return false;
      }

      final response = await _refreshDio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map) {
          final newAccessToken =
              data['access'] ?? data['token'] ?? data['accessToken'];
          final newRefreshToken = data['refresh'] ?? data['refreshToken'];

          if (newAccessToken != null) {
            await StorageService.saveToken(newAccessToken.toString());
          }
          if (newRefreshToken != null) {
            await StorageService.saveRefreshToken(newRefreshToken.toString());
          }

          log('Access token successfully refreshed.');
          return true;
        }
      }

      return false;
    } catch (e) {
      log('Token refresh error: $e');
      return false;
    }
  }
}
