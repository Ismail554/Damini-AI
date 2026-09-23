import 'package:Braintech/core/services/api_service.dart';
import 'package:Braintech/shared/global_key.dart';
import 'package:Braintech/views/auth/login/models/login_request_model.dart';
import 'package:Braintech/views/auth/login/repositories/login_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class MockLoginApiService extends ApiService {
  final dynamic responseData;
  final int statusCode;

  MockLoginApiService({required this.responseData, this.statusCode = 200});

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
      statusCode: statusCode,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserModel parsing tests', () {
    test('parses full user JSON correctly with NONE role', () {
      final userJson = {
        "id": 28,
        "first_name": "ismail",
        "last_name": "hosen",
        "full_name": "ismail hosen",
        "email": "ismailshuvo555@gmail.com",
        "role": "NONE",
        "is_email_verified": true,
        "push_notifications_enabled": true,
        "subscription_tier": "FREE",
      };

      final user = UserModel.fromJson(userJson);
      expect(user.id, 28);
      expect(user.firstName, "ismail");
      expect(user.lastName, "hosen");
      expect(user.fullName, "ismail hosen");
      expect(user.email, "ismailshuvo555@gmail.com");
      expect(user.role, "NONE");
      expect(user.isEmailVerified, true);
      expect(user.pushNotificationsEnabled, true);
      expect(user.subscriptionTier, "FREE");
    });
  });

  group('LoginRepositoryImpl tests', () {
    test('login with role NONE parses user and identifies unselected role', () async {
      final responsePayload = {
        "access": "access_token_123",
        "refresh": "refresh_token_123",
        "user": {
          "id": 28,
          "first_name": "ismail",
          "last_name": "hosen",
          "full_name": "ismail hosen",
          "email": "ismailshuvo555@gmail.com",
          "role": "NONE",
          "is_email_verified": true,
          "push_notifications_enabled": true,
          "subscription_tier": "FREE",
        },
      };

      final repo = LoginRepositoryImpl(
        MockLoginApiService(responseData: responsePayload),
      );

      final result = await repo.login(
        const LoginRequestModel(
          email: "ismailshuvo555@gmail.com",
          password: "password123",
        ),
      );

      expect(result.success, true);
      expect(result.token, "access_token_123");
      expect(result.refreshToken, "refresh_token_123");
      expect(result.user, isNotNull);
      expect(result.user?.id, 28);
      expect(result.role, "NONE");
      expect(GlobalKeys.isValidRole(result.role?.toLowerCase()), false);
    });

    test('login with role Investor identifies valid role', () async {
      final responsePayload = {
        "access": "access_token_123",
        "refresh": "refresh_token_123",
        "user": {
          "id": 29,
          "first_name": "Jane",
          "last_name": "Doe",
          "full_name": "Jane Doe",
          "email": "jane@example.com",
          "role": "Investor",
          "is_email_verified": true,
          "push_notifications_enabled": true,
          "subscription_tier": "FREE",
        },
      };

      final repo = LoginRepositoryImpl(
        MockLoginApiService(responseData: responsePayload),
      );

      final result = await repo.login(
        const LoginRequestModel(
          email: "jane@example.com",
          password: "password123",
        ),
      );

      expect(result.success, true);
      expect(result.role, "Investor");
      expect(GlobalKeys.isValidRole(result.role?.toLowerCase()), true);
    });

    test('login with role Sponsor identifies valid role', () async {
      final responsePayload = {
        "access": "access_token_123",
        "refresh": "refresh_token_123",
        "user": {
          "id": 30,
          "first_name": "Sam",
          "last_name": "Sponsor",
          "full_name": "Sam Sponsor",
          "email": "sam@example.com",
          "role": "Sponsor",
          "is_email_verified": true,
          "push_notifications_enabled": true,
          "subscription_tier": "PRO",
        },
      };

      final repo = LoginRepositoryImpl(
        MockLoginApiService(responseData: responsePayload),
      );

      final result = await repo.login(
        const LoginRequestModel(
          email: "sam@example.com",
          password: "password123",
        ),
      );

      expect(result.success, true);
      expect(result.role, "Sponsor");
      expect(GlobalKeys.isValidRole(result.role?.toLowerCase()), true);
    });
  });
}
