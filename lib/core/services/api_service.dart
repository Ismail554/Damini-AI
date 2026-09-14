import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_error_handler.dart';
import 'dio_service.dart';

/// Riverpod provider for ApiService
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class ApiService {
  Dio _getDio(bool requireAuth) {
    return requireAuth ? DioService.client : DioService.noAuthClient;
  }

  /// GET Request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requireAuth = true,
  }) async {
    try {
      return await _getDio(requireAuth).get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (error) {
      throw ApiErrorHandler.handle(error);
    }
  }

  /// POST Request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requireAuth = true,
  }) async {
    try {
      return await _getDio(requireAuth).post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (error) {
      throw ApiErrorHandler.handle(error);
    }
  }

  /// PUT Request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requireAuth = true,
  }) async {
    try {
      return await _getDio(requireAuth).put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (error) {
      throw ApiErrorHandler.handle(error);
    }
  }

  /// PATCH Request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requireAuth = true,
  }) async {
    try {
      return await _getDio(requireAuth).patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (error) {
      throw ApiErrorHandler.handle(error);
    }
  }

  /// DELETE Request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requireAuth = true,
  }) async {
    try {
      return await _getDio(requireAuth).delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (error) {
      throw ApiErrorHandler.handle(error);
    }
  }
}
