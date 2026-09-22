import 'dart:convert';
import 'package:Braintech/core/services/api_error_handler.dart';
import 'package:Braintech/core/services/api_service.dart';
import 'package:Braintech/views/auth/signup/models/signup_request_model.dart';
import 'package:Braintech/views/auth/signup/repositories/signup_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class MockErrorApiService extends ApiService {
  final dynamic errorData;
  final int statusCode;

  MockErrorApiService({required this.errorData, this.statusCode = 400});

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requireAuth = true,
  }) async {
    final response = Response(
      requestOptions: RequestOptions(path: path),
      data: errorData,
      statusCode: statusCode,
    );
    throw ApiErrorHandler.handle(
      DioException(
        requestOptions: RequestOptions(path: path),
        response: response,
        type: DioExceptionType.badResponse,
      ),
    );
  }
}

class MockSuccessWithStatusErrorApiService extends ApiService {
  final dynamic responseData;

  MockSuccessWithStatusErrorApiService({required this.responseData});

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requireAuth = true,
  }) async {
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: responseData as T,
      statusCode: 200,
    );
  }
}

void main() {
  group('Signup Validation API Response Tests', () {
    const rawJsonString =
        '{"status":"error","message":"Validation failed.","errors":{"email":["user with this email address already exists."]}}';
    final mapData = jsonDecode(rawJsonString) as Map<String, dynamic>;

    test('ApiErrorHandler extracts field error message from Map payload', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/register/'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/auth/register/'),
          statusCode: 400,
          data: mapData,
        ),
        type: DioExceptionType.badResponse,
      );

      final apiException = ApiErrorHandler.handle(dioException);
      expect(apiException.message, 'user with this email address already exists.');
      expect(apiException.statusCode, 400);
      expect(apiException.data, isA<Map>());
    });

    test('ApiErrorHandler decodes and extracts field error from JSON String payload', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/register/'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/auth/register/'),
          statusCode: 400,
          data: rawJsonString,
        ),
        type: DioExceptionType.badResponse,
      );

      final apiException = ApiErrorHandler.handle(dioException);
      expect(apiException.message, 'user with this email address already exists.');
      expect(apiException.data, isA<Map>());
    });

    test('SignupRepositoryImpl handles 400 badResponse with email error', () async {
      final repo = SignupRepositoryImpl(MockErrorApiService(errorData: mapData));
      final result = await repo.signUp(
        const SignupRequestModel(
          firstName: 'John',
          lastName: 'Doe',
          email: 'test@example.com',
          password: 'Password123!',
        ),
      );

      expect(result.success, false);
      expect(result.errors, isNotNull);
      expect(result.errors!['email'], 'user with this email address already exists.');
      expect(result.message, 'user with this email address already exists.');
    });

    test('SignupRepositoryImpl handles 200 OK returning error status', () async {
      final repo = SignupRepositoryImpl(
        MockSuccessWithStatusErrorApiService(responseData: mapData),
      );
      final result = await repo.signUp(
        const SignupRequestModel(
          firstName: 'John',
          lastName: 'Doe',
          email: 'test@example.com',
          password: 'Password123!',
        ),
      );

      expect(result.success, false);
      expect(result.errors, isNotNull);
      expect(result.errors!['email'], 'user with this email address already exists.');
      expect(result.message, 'user with this email address already exists.');
    });
  });
}
