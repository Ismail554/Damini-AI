import 'dart:convert';
import 'package:dio/dio.dart';

sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection. Please check your network.']);
}

class TimeoutException extends AppException {
  const TimeoutException([super.message = 'The request took too long. Please try again.']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Session expired. Please login again.']);
}

class ForbiddenException extends AppException {
  const ForbiddenException([super.message = 'You don\'t have permission to do this.']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Something went wrong on our end. Please try again.']);
}

class ParsingException extends AppException {
  const ParsingException([super.message = 'Unexpected data format.']);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class ApiException extends AppException {
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required String message,
    this.statusCode,
    this.data,
  }) : super(message);
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
          dynamic responseData = error.response?.data;

          if (responseData is String) {
            try {
              final decoded = jsonDecode(responseData);
              if (decoded is Map || decoded is List) {
                responseData = decoded;
              }
            } catch (_) {}
          }

          String message = "Something went wrong. Please try again.";

          if (responseData is Map) {
            if (responseData['errors'] is Map && (responseData['errors'] as Map).isNotEmpty) {
              final errorsMap = responseData['errors'] as Map;
              final List<String> msgs = [];
              errorsMap.forEach((key, val) {
                if (val is List && val.isNotEmpty) {
                  msgs.add(val.join(', '));
                } else if (val != null) {
                  msgs.add(val.toString());
                }
              });
              if (msgs.isNotEmpty) {
                message = msgs.join('\n');
              }
            } else if (responseData['errors'] is List && (responseData['errors'] as List).isNotEmpty) {
              message = (responseData['errors'] as List).first.toString();
            } else if (responseData['message'] != null &&
                responseData['message'].toString().toLowerCase() != 'validation failed.') {
              message = responseData['message'].toString();
            } else if (responseData['detail'] != null) {
              message = responseData['detail'].toString();
            } else if (responseData['error'] != null) {
              message = responseData['error'].toString();
            } else if (responseData['non_field_errors'] is List &&
                (responseData['non_field_errors'] as List).isNotEmpty) {
              message =
                  (responseData['non_field_errors'] as List).first.toString();
            } else if (responseData.isNotEmpty) {
              // Extract first error message from field errors map like {"email": ["..."]}
              final firstVal = responseData.values.first;
              if (firstVal is List && firstVal.isNotEmpty) {
                message = firstVal.first.toString();
              } else if (firstVal is String) {
                message = firstVal;
              }
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
