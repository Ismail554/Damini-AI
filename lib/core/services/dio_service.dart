import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import 'storage_service.dart';

class DioService {
  static final Dio _dio = Dio(
    BaseOptions(baseUrl: ApiEndpoints.baseUrl, connectTimeout: const Duration(seconds: 15), receiveTimeout: const Duration(seconds: 15)),
  );

  static Dio get client {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getToken();
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
    ));
    return _dio;
  }
}
