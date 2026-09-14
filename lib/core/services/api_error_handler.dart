import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => message;
}

class ApiErrorHandler {
  static ApiException handle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const ApiException(
            message: "Connection timed out. Please check your internet connection.",
          );

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;

          String message = "Something went wrong. Please try again.";

          if (responseData is Map) {
            if (responseData['message'] != null) {
              message = responseData['message'].toString();
            } else if (responseData['detail'] != null) {
              message = responseData['detail'].toString();
            } else if (responseData['error'] != null) {
              message = responseData['error'].toString();
            } else if (responseData['non_field_errors'] is List &&
                (responseData['non_field_errors'] as List).isNotEmpty) {
              message =
                  (responseData['non_field_errors'] as List).first.toString();
            }
          } else if (responseData is String && responseData.isNotEmpty) {
            message = responseData;
          }

          return ApiException(
            message: message,
            statusCode: statusCode,
            data: responseData,
          );

        case DioExceptionType.cancel:
          return const ApiException(message: "Request was cancelled.");

        case DioExceptionType.connectionError:
          return const ApiException(
            message:
                "No internet connection. Please verify your network and try again.",
          );

        case DioExceptionType.badCertificate:
          return const ApiException(
            message: "Security certificate validation failed.",
          );

        case DioExceptionType.unknown:
          return ApiException(
            message:
                error.message ?? "An unexpected error occurred. Please try again.",
          );
      }
    }

    return ApiException(message: error.toString());
  }
}
