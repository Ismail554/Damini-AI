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

    test('loginWithGoogle success parses access, refresh and user', () async {
      final responsePayload = {
        "status": "success",
        "message": "Login successful",
        "access": "google_access_jwt_123",
        "refresh": "google_refresh_jwt_123",
        "role": "NONE",
        "user": {
          "id": 101,
          "first_name": "Google",
          "last_name": "User",
          "full_name": "Google User",
          "email": "user@gmail.com",
          "role": "NONE",
          "is_email_verified": true,
          "push_notifications_enabled": false,
          "subscription_tier": "FREE",
        },
      };

      final repo = LoginRepositoryImpl(
        MockLoginApiService(responseData: responsePayload),
      );

      final result = await repo.loginWithGoogle("fake_google_id_token");

      expect(result.success, true);
      expect(result.token, "google_access_jwt_123");
      expect(result.refreshToken, "google_refresh_jwt_123");
      expect(result.user?.email, "user@gmail.com");
      expect(result.role, "NONE");
    });

    test('loginWithGoogle success parses nested data object from backend', () async {
      final responsePayload = {
        "status": "success",
        "data": {
          "access": "google_nested_access_jwt",
          "refresh": "google_nested_refresh_jwt",
          "role": "NONE",
          "user": {
            "id": 37,
            "first_name": "Test",
            "last_name": "App",
            "full_name": "Test App",
            "email": "testappview4@gmail.com",
            "role": "NONE",
            "is_email_verified": true,
            "push_notifications_enabled": true,
            "subscription_tier": "FREE",
          },
        },
      };

      final repo = LoginRepositoryImpl(
        MockLoginApiService(responseData: responsePayload),
      );

      final result = await repo.loginWithGoogle("valid_google_id_token");

      expect(result.success, true);
      expect(result.token, "google_nested_access_jwt");
      expect(result.refreshToken, "google_nested_refresh_jwt");
      expect(result.user?.id, 37);
      expect(result.user?.email, "testappview4@gmail.com");
      expect(result.role, "NONE");
    });

    test('loginWithGoogle handles backend error response', () async {
      final responsePayload = {
        "status": "error",
        "message": "Invalid or expired social token.",
      };

      final repo = LoginRepositoryImpl(
        MockLoginApiService(responseData: responsePayload),
      );

      final result = await repo.loginWithGoogle("invalid_token");

      expect(result.success, false);
      expect(result.message, "Invalid or expired social token.");
    });

    test('loginWithApple success parses access, refresh and user', () async {
      final responsePayload = {
        "status": "success",
        "message": "Apple login successful",
        "access": "apple_access_jwt_456",
        "refresh": "apple_refresh_jwt_456",
        "role": "INVESTOR",
        "user": {
          "id": 102,
          "first_name": "Apple",
          "last_name": "Investor",
          "full_name": "Apple Investor",
          "email": "investor@appleid.com",
          "role": "INVESTOR",
          "is_email_verified": true,
          "push_notifications_enabled": false,
          "subscription_tier": "FREE",
        },
      };

      final repo = LoginRepositoryImpl(
        MockLoginApiService(responseData: responsePayload),
      );

      final result = await repo.loginWithApple(
        idToken: "fake_apple_id_token",
        firstName: "Apple",
        lastName: "Investor",
      );

      expect(result.success, true);
      expect(result.token, "apple_access_jwt_456");
      expect(result.role, "INVESTOR");
      expect(GlobalKeys.isValidRole(result.role?.toLowerCase()), true);
    });

    test('loginWithApple handles backend error response', () async {
      final responsePayload = {
        "status": "error",
        "message": "Apple token verification failed",
      };

      final repo = LoginRepositoryImpl(
        MockLoginApiService(responseData: responsePayload),
      );

      final result = await repo.loginWithApple(idToken: "bad_token");

      expect(result.success, false);
      expect(result.message, "Apple token verification failed");
    });

    test('loginWithGoogle prioritizes root role when user role is omitted or NONE', () async {
      final responsePayload = {
        "status": "success",
        "message": "Login successful",
        "access": "jwt_token_investor",
        "role": "INVESTOR",
        "user": {
          "id": 88,
          "first_name": "RootRole",
          "last_name": "Tester",
          "full_name": "RootRole Tester",
          "email": "root@gmail.com",
          "role": "NONE",
        },
      };

      final repo = LoginRepositoryImpl(
        MockLoginApiService(responseData: responsePayload),
      );

      final result = await repo.loginWithGoogle("valid_google_token");

      expect(result.success, true);
      expect(result.role, "INVESTOR");
      expect(GlobalKeys.isValidRole(result.role?.toLowerCase()), true);
    });

    test('loginWithApple respects user.role when root role is omitted', () async {
      final responsePayload = {
        "status": "success",
        "message": "Login successful",
        "access": "jwt_token_sponsor",
        "user": {
          "id": 89,
          "first_name": "Sponsor",
          "last_name": "User",
          "full_name": "Sponsor User",
          "email": "sponsor@appleid.com",
          "role": "SPONSOR",
        },
      };

      final repo = LoginRepositoryImpl(
        MockLoginApiService(responseData: responsePayload),
      );

      final result = await repo.loginWithApple(
        idToken: "apple_token",
        firstName: "Sponsor",
        lastName: "User",
      );

      expect(result.success, true);
      expect(result.role, "SPONSOR");
      expect(GlobalKeys.isValidRole(result.role?.toLowerCase()), true);
    });
  });
}
