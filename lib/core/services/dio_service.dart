import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_endpoints.dart';
import 'auth_interceptor.dart';

class DioService {
  // 1. Client with AuthInterceptor (For protected APIs: Profile, Dashboard, etc.)
  static final Dio client = _createAuthDio();

  // 2. Client without AuthInterceptor (For public APIs: Login, Signup, OTP, etc.)
  static final Dio noAuthClient = _createNoAuthDio();

  static BaseOptions _createBaseOptions() {
    return BaseOptions(
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
    );
  }

  static void _configureHttpClient(Dio dio) {
    if (!kIsWeb) {
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.idleTimeout = const Duration(seconds: 15);
          client.connectionTimeout = const Duration(seconds: 30);
          client.badCertificateCallback = (cert, host, port) => true;
          return client;
        },
      );
    }
  }

  static Dio _createAuthDio() {
    final dio = Dio(_createBaseOptions());
    _configureHttpClient(dio);
    dio.interceptors.add(AuthInterceptor(dio));

    if (kDebugMode) {
      dio.interceptors.add(_loggingInterceptor);
    }

    return dio;
  }

  static Dio _createNoAuthDio() {
    final dio = Dio(_createBaseOptions());
    _configureHttpClient(dio);

    if (kDebugMode) {
      dio.interceptors.add(_loggingInterceptor);
    }

    return dio;
  }

  static final LogInterceptor _loggingInterceptor = LogInterceptor(
    requestHeader: false,
    requestBody: true,
    responseBody: true,
    responseHeader: false,
    error: true,
    logPrint: (o) => debugPrint(o.toString()),
  );

  /// Close connections when resetting the app session if needed
  static void reset() {
    client.close();
    noAuthClient.close();
  }
}
