import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_endpoints.dart';
import 'auth_interceptor.dart';

class DioService {
  // 1. Client with AuthInterceptor (For protected APIs: Profile, Dashboard, etc.)
  static final Dio client = _createAuthDio();

  // 2. Client without AuthInterceptor (For public APIs: Login, Signup, OTP, etc.)
  static final Dio noAuthClient = _createNoAuthDio();

  static Dio _createAuthDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(AuthInterceptor(dio));

    if (kDebugMode) {
      dio.interceptors.add(_loggingInterceptor);
    }

    return dio;
  }

  static Dio _createNoAuthDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(_loggingInterceptor);
    }

    return dio;
  }

  static final LogInterceptor _loggingInterceptor = LogInterceptor(
    requestHeader: true,
    requestBody: true,
    responseBody: true,
    responseHeader: false,
    error: true,
  );

  /// Close connections when resetting the app session if needed
  static void reset() {
    client.close();
    noAuthClient.close();
  }
}
