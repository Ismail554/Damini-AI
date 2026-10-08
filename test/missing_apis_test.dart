import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:Braintech/core/services/api_service.dart';
import 'package:Braintech/views/auth/forgot_password/models/forgot_password_model.dart';
import 'package:Braintech/views/auth/forgot_password/repositories/forgot_password_repository.dart';
import 'package:Braintech/views/auth/reset_password/models/reset_password_model.dart';
import 'package:Braintech/views/auth/reset_password/repositories/reset_password_repository.dart';
import 'package:Braintech/views/auth/change_password/models/change_password_model.dart';
import 'package:Braintech/views/auth/change_password/repositories/change_password_repository.dart';
import 'package:Braintech/views/settings/repositories/settings_repository.dart';
import 'package:Braintech/views/sponsor/nda/repositories/nda_repository.dart';

class MockApiService extends ApiService {
  MockApiService() : super();

  String? lastPath;
  dynamic lastData;
  bool? lastRequireAuth;
  dynamic mockResponseData;
  int mockStatusCode = 200;

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requireAuth = false,
  }) async {
    lastPath = path;
    lastData = data;
    lastRequireAuth = requireAuth;
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: (mockResponseData ?? {'status': 'success', 'message': 'OK'}) as T,
      statusCode: mockStatusCode,
    );
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requireAuth = false,
  }) async {
    lastPath = path;
    lastRequireAuth = requireAuth;
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: mockResponseData as T,
      statusCode: mockStatusCode,
    );
  }

  @override
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requireAuth = false,
  }) async {
    lastPath = path;
    lastData = data;
    lastRequireAuth = requireAuth;
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: (mockResponseData ?? {'status': 'success', 'message': 'Deleted'}) as T,
      statusCode: mockStatusCode,
    );
  }
}

void main() {
  group('Missing APIs Unit Tests', () {
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
    });

    test('ForgotPasswordRepositoryImpl calls POST /api/v1/auth/forgot-password/', () async {
      mockApiService.mockResponseData = {
        'status': 'success',
        'message': 'Reset code sent.',
      };

      final repo = ForgotPasswordRepositoryImpl(mockApiService);
      final res = await repo.forgotPassword(
        const ForgotPasswordRequestModel(email: 'test@example.com'),
      );

      expect(mockApiService.lastPath, '/api/v1/auth/forgot-password/');
      expect(mockApiService.lastData, {'email': 'test@example.com'});
      expect(mockApiService.lastRequireAuth, false);
      expect(res.success, true);
      expect(res.message, 'Reset code sent.');
    });

    test('ResetPasswordRepositoryImpl calls POST /api/v1/auth/reset-password/', () async {
      mockApiService.mockResponseData = {
        'status': 'success',
        'message': 'Password reset successfully.',
      };

      final repo = ResetPasswordRepositoryImpl(mockApiService);
      final res = await repo.resetPassword(
        const ResetPasswordRequestModel(
          email: 'test@example.com',
          code: '123456',
          newPassword: 'NewPassword123!',
          confirmPassword: 'NewPassword123!',
        ),
      );

      expect(mockApiService.lastPath, '/api/v1/auth/reset-password/');
      expect(mockApiService.lastData, {
        'email': 'test@example.com',
        'code': '123456',
        'new_password': 'NewPassword123!',
        'confirm_password': 'NewPassword123!',
      });
      expect(mockApiService.lastRequireAuth, false);
      expect(res.success, true);
      expect(res.message, 'Password reset successfully.');
    });

    test('ChangePasswordRepositoryImpl calls POST /api/v1/users/change-password/', () async {
      mockApiService.mockResponseData = {
        'status': 'success',
        'message': 'Password changed successfully.',
      };

      final repo = ChangePasswordRepositoryImpl(mockApiService);
      final res = await repo.changePassword(
        const ChangePasswordModel(
          currentPassword: 'OldPassword123!',
          newPassword: 'NewPassword123!',
        ),
      );

      expect(mockApiService.lastPath, '/api/v1/users/change-password/');
      expect(mockApiService.lastData, {
        'current_password': 'OldPassword123!',
        'new_password': 'NewPassword123!',
      });
      expect(mockApiService.lastRequireAuth, true);
      expect(res, true);
    });

    test('SettingsRepositoryImpl.deleteAccount calls DELETE /api/v1/users/delete-account/', () async {
      mockApiService.mockResponseData = {
        'status': 'success',
        'message': 'Account deleted successfully.',
      };

      final repo = SettingsRepositoryImpl(mockApiService);
      final res = await repo.deleteAccount();

      expect(mockApiService.lastPath, '/api/v1/users/delete-account/');
      expect(mockApiService.lastRequireAuth, true);
      expect(res, true);
    });

    test('NdaRepository.fetchSponsorNda parses NDA payload from GET /api/v1/profiles/sponsor/nda/', () async {
      mockApiService.mockResponseData = {
        'status': 'success',
        'data': {
          'title': 'Non-Disclosure Agreement',
          'disclosing_party': 'Acme Capital',
          'effective_date': '2026-08-15',
          'confidentiality_terms': 'Terms here...',
          'pitch_deck_file': {
            'file_name': 'pitch_deck_v2.pdf',
            'file_url': 'https://example.com/media/nda/pitch_deck_v2.pdf',
            'file_size': '12.4 MB',
          },
          'custom_clauses': ['Clause 1: Non-compete'],
        }
      };

      final repo = NdaRepository(mockApiService);
      final res = await repo.fetchSponsorNda('Acme Capital');

      expect(mockApiService.lastPath, '/api/v1/profiles/sponsor/nda/');
      expect(mockApiService.lastRequireAuth, true);
      expect(res.disclosingParty, 'Acme Capital');
      expect(res.documentTitle, 'pitch_deck_v2.pdf');
      expect(res.fileSize, '12.4 MB');
      expect(res.customClauses.length, 1);
    });
  });
}
