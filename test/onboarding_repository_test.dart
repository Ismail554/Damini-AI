import 'package:Braintech/core/services/api_error_handler.dart';
import 'package:Braintech/core/services/api_service.dart';
import 'package:Braintech/views/role_selection/repositories/onboarding_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class MockOnboardingApiService extends ApiService {
  final List<String> pathsCalled = [];
  final List<dynamic> dataPayloads = [];
  final int statusCode;
  final dynamic Function(String path, dynamic data)? customHandler;

  MockOnboardingApiService({
    this.statusCode = 200,
    this.customHandler,
  });

  @override
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requireAuth = true,
  }) async {
    pathsCalled.add(path);
    dataPayloads.add(data);

    if (customHandler != null) {
      final res = customHandler!(path, data);
      if (res is Exception) {
        throw res;
      }
      return Response<T>(
        requestOptions: RequestOptions(path: path),
        data: res as T?,
        statusCode: statusCode,
      );
    }

    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: {'status': 'success'} as T?,
      statusCode: statusCode,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnboardingRepositoryImpl.updateProfileDetails tests', () {
    test('normalizes company_website without scheme to https://', () async {
      final mockApi = MockOnboardingApiService();
      final repo = OnboardingRepositoryImpl(mockApi);

      final success = await repo.updateProfileDetails(
        role: 'sponsor',
        fields: {
          'phone': '01619524736',
          'company_website': 'www.google.com',
          'legal_company_name': 'My Corp',
        },
      );

      expect(success, true);
      expect(mockApi.pathsCalled.length, 1);
      expect(mockApi.pathsCalled.first, '/api/v1/profiles/sponsor/onboarding/');

      final payload = mockApi.dataPayloads.first as Map<String, dynamic>;
      expect(payload['company_website'], 'https://www.google.com');
      expect(payload['phone'], '01619524736');
      expect(payload['legal_company_name'], 'My Corp');
    });

    test('preserves company_website that already starts with https:// or http://', () async {
      final mockApi = MockOnboardingApiService();
      final repo = OnboardingRepositoryImpl(mockApi);

      await repo.updateProfileDetails(
        role: 'sponsor',
        fields: {
          'company_website': 'https://google.com',
        },
      );

      final payload = mockApi.dataPayloads.first as Map<String, dynamic>;
      expect(payload['company_website'], 'https://google.com');
    });

    test('does NOT trigger fallback on 400 validation error', () async {
      final mockApi = MockOnboardingApiService(
        customHandler: (path, data) {
          throw const ApiException(
            message: 'Validation failed.',
            statusCode: 400,
          );
        },
      );
      final repo = OnboardingRepositoryImpl(mockApi);

      await expectLater(
        repo.updateProfileDetails(
          role: 'sponsor',
          fields: {'phone': '1234'},
        ),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 400)),
      );

      // Verify that it only called onboarding once and did not call fallback
      expect(mockApi.pathsCalled.length, 1);
      expect(mockApi.pathsCalled.first, '/api/v1/profiles/sponsor/onboarding/');
    });

    test('triggers fallback to profileByRole when onboarding endpoint is 404', () async {
      final mockApi = MockOnboardingApiService(
        customHandler: (path, data) {
          if (path.contains('/onboarding/')) {
            throw const ApiException(
              message: 'Not found',
              statusCode: 404,
            );
          }
          return {'status': 'success'};
        },
      );
      final repo = OnboardingRepositoryImpl(mockApi);

      final success = await repo.updateProfileDetails(
        role: 'sponsor',
        fields: {'phone': '1234'},
      );

      expect(success, true);
      expect(mockApi.pathsCalled.length, 2);
      expect(mockApi.pathsCalled[0], '/api/v1/profiles/sponsor/onboarding/');
      expect(mockApi.pathsCalled[1], '/api/v1/profiles/sponsor/');
    });
  });
}
