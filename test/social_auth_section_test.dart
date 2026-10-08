import 'package:Braintech/core/services/apple_auth_service.dart';
import 'package:Braintech/core/services/google_auth_service.dart';
import 'package:Braintech/core/theme/app_theme.dart';
import 'package:Braintech/views/auth/login/models/login_request_model.dart';
import 'package:Braintech/views/auth/login/provider/login_provider.dart';
import 'package:Braintech/views/auth/login/repositories/login_repository.dart';
import 'package:Braintech/views/auth/providers/social_auth_provider.dart';
import 'package:Braintech/views/auth/widgets/social_auth_button.dart';
import 'package:Braintech/views/auth/widgets/social_auth_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class FakeGoogleAuthService extends GoogleAuthService {
  final GoogleAuthResult? resultToReturn;
  final Exception? exceptionToThrow;
  bool signInCalled = false;

  FakeGoogleAuthService({this.resultToReturn, this.exceptionToThrow});

  @override
  Future<GoogleAuthResult?> signIn() async {
    signInCalled = true;
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return resultToReturn;
  }
}

class FakeAppleAuthService extends AppleAuthService {
  final AppleAuthResult? resultToReturn;
  final Exception? exceptionToThrow;
  bool signInCalled = false;

  FakeAppleAuthService({this.resultToReturn, this.exceptionToThrow});

  @override
  Future<AppleAuthResult?> signIn() async {
    signInCalled = true;
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return resultToReturn;
  }
}

class FakeLoginRepository implements LoginRepository {
  final LoginResponseModel responseToReturn;
  String? lastGoogleIdToken;
  String? lastAppleIdToken;

  FakeLoginRepository(this.responseToReturn);

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    return responseToReturn;
  }

  @override
  Future<LoginResponseModel> loginWithGoogle(String idToken) async {
    lastGoogleIdToken = idToken;
    return responseToReturn;
  }

  @override
  Future<LoginResponseModel> loginWithApple({
    required String idToken,
    String? firstName,
    String? lastName,
  }) async {
    lastAppleIdToken = idToken;
    return responseToReturn;
  }
}

Widget _wrapWithApp(
  Widget child, {
  FakeGoogleAuthService? fakeGoogle,
  FakeAppleAuthService? fakeApple,
  FakeLoginRepository? fakeRepo,
}) {
  return ProviderScope(
    overrides: [
      if (fakeGoogle != null)
        googleAuthServiceProvider.overrideWithValue(fakeGoogle),
      if (fakeApple != null)
        appleAuthServiceProvider.overrideWithValue(fakeApple),
      if (fakeRepo != null)
        loginRepositoryProvider.overrideWithValue(fakeRepo),
    ],
    child: ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}

Widget _wrapWithRouter(
  Widget child, {
  FakeGoogleAuthService? fakeGoogle,
  FakeAppleAuthService? fakeApple,
  FakeLoginRepository? fakeRepo,
}) {
  final router = GoRouter(
    initialLocation: '/test',
    routes: [
      GoRoute(
        path: '/test',
        builder: (context, state) => Scaffold(body: Center(child: child)),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('RoleSelectionScreen'))),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('HomeScreen'))),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      if (fakeGoogle != null)
        googleAuthServiceProvider.overrideWithValue(fakeGoogle),
      if (fakeApple != null)
        appleAuthServiceProvider.overrideWithValue(fakeApple),
      if (fakeRepo != null)
        loginRepositoryProvider.overrideWithValue(fakeRepo),
    ],
    child: ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp.router(
        theme: AppTheme.darkTheme,
        routerConfig: router,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SocialAuthSection Widget Tests', () {
    testWidgets('renders Google and Apple buttons and divider by default',
        (tester) async {
      await tester.pumpWidget(_wrapWithApp(const SocialAuthSection()));
      await tester.pumpAndSettle();

      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Apple'), findsOneWidget);
      expect(find.text('or continue with'), findsOneWidget);
      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('hides divider when showDivider is false', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(const SocialAuthSection(showDivider: false)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Apple'), findsOneWidget);
      expect(find.text('or continue with'), findsNothing);
      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('renders custom divider text when provided', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const SocialAuthSection(dividerText: 'or use your social account'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('or use your social account'), findsOneWidget);
    });

    testWidgets('renders divider above social buttons when dividerAtTop is true',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const SocialAuthSection(dividerAtTop: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('or continue with'), findsOneWidget);
      expect(find.byType(Divider), findsNWidgets(2));
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Apple'), findsOneWidget);

      final dividerTop = tester.getTopLeft(find.text('or continue with')).dy;
      final googleTop = tester.getTopLeft(find.text('Continue with Google')).dy;
      expect(dividerTop, lessThan(googleTop));
    });

    testWidgets('calls onGooglePressed when custom callback is supplied',
        (tester) async {
      var googleTapped = false;
      var appleTapped = false;

      await tester.pumpWidget(
        _wrapWithApp(
          SocialAuthSection(
            onGooglePressed: () => googleTapped = true,
            onApplePressed: () => appleTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();
      expect(googleTapped, isTrue);
      expect(appleTapped, isFalse);

      await tester.tap(find.text('Continue with Apple'));
      await tester.pumpAndSettle();
      expect(appleTapped, isTrue);
    });

    testWidgets(
        'isGoogleLoading=true shows spinner on Google button and disables Apple button',
        (tester) async {
      var appleTapped = false;

      await tester.pumpWidget(
        _wrapWithApp(
          SocialAuthSection(
            isGoogleLoading: true,
            onApplePressed: () => appleTapped = true,
          ),
        ),
      );
      await tester.pump();

      // CircularProgressIndicator should be visible for Google
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Apple button should be disabled because Google is loading
      await tester.tap(find.text('Continue with Apple'));
      await tester.pump();
      expect(appleTapped, isFalse);
    });

    testWidgets(
        'isAppleLoading=true shows spinner on Apple button and disables Google button',
        (tester) async {
      var googleTapped = false;

      await tester.pumpWidget(
        _wrapWithApp(
          SocialAuthSection(
            isAppleLoading: true,
            onGooglePressed: () => googleTapped = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Google button should be disabled because Apple is loading
      await tester.tap(find.text('Continue with Google'));
      await tester.pump();
      expect(googleTapped, isFalse);
    });

    testWidgets('enabled=false disables both buttons', (tester) async {
      var googleTapped = false;
      var appleTapped = false;

      await tester.pumpWidget(
        _wrapWithApp(
          SocialAuthSection(
            enabled: false,
            onGooglePressed: () => googleTapped = true,
            onApplePressed: () => appleTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue with Google'));
      await tester.pump();
      expect(googleTapped, isFalse);

      await tester.tap(find.text('Continue with Apple'));
      await tester.pump();
      expect(appleTapped, isFalse);
    });

    testWidgets(
        'invokes built-in Google sign-in and notifies onAuthSuccess callback',
        (tester) async {
      final fakeGoogle = FakeGoogleAuthService(
        resultToReturn: const GoogleAuthResult(
          idToken: 'valid_google_token',
          email: 'test@gmail.com',
          displayName: 'Test User',
        ),
      );

      final fakeRepo = FakeLoginRepository(
        const LoginResponseModel(
          success: true,
          token: 'token_123',
          role: 'NONE',
          message: 'Welcome back!',
        ),
      );

      LoginResponseModel? capturedSuccess;

      await tester.pumpWidget(
        _wrapWithApp(
          SocialAuthSection(
            onAuthSuccess: (resp) => capturedSuccess = resp,
          ),
          fakeGoogle: fakeGoogle,
          fakeRepo: fakeRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      expect(fakeGoogle.signInCalled, isTrue);
      expect(fakeRepo.lastGoogleIdToken, 'valid_google_token');
      expect(capturedSuccess, isNotNull);
      expect(capturedSuccess?.token, 'token_123');
      expect(capturedSuccess?.role, 'NONE');
    });

    testWidgets(
        'invokes built-in Apple sign-in and notifies onAuthSuccess callback',
        (tester) async {
      final fakeApple = FakeAppleAuthService(
        resultToReturn: const AppleAuthResult(
          idToken: 'valid_apple_token',
          firstName: 'John',
          lastName: 'Appleseed',
          email: 'john@privaterelay.appleid.com',
        ),
      );

      final fakeRepo = FakeLoginRepository(
        const LoginResponseModel(
          success: true,
          token: 'token_apple_123',
          role: 'INVESTOR',
          message: 'Welcome Apple User!',
        ),
      );

      LoginResponseModel? capturedSuccess;

      await tester.pumpWidget(
        _wrapWithApp(
          SocialAuthSection(
            onAuthSuccess: (resp) => capturedSuccess = resp,
          ),
          fakeApple: fakeApple,
          fakeRepo: fakeRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue with Apple'));
      await tester.pumpAndSettle();

      expect(fakeApple.signInCalled, isTrue);
      expect(fakeRepo.lastAppleIdToken, 'valid_apple_token');
      expect(capturedSuccess, isNotNull);
      expect(capturedSuccess?.token, 'token_apple_123');
      expect(capturedSuccess?.role, 'INVESTOR');
    });

    testWidgets(
        'invokes onAuthError when backend fails during social sign-in',
        (tester) async {
      final fakeGoogle = FakeGoogleAuthService(
        resultToReturn: const GoogleAuthResult(
          idToken: 'expired_google_token',
        ),
      );

      final fakeRepo = FakeLoginRepository(
        const LoginResponseModel(
          success: false,
          message: 'Token has expired on server.',
        ),
      );

      String? capturedError;

      await tester.pumpWidget(
        _wrapWithApp(
          SocialAuthSection(
            onAuthError: (err) => capturedError = err,
          ),
          fakeGoogle: fakeGoogle,
          fakeRepo: fakeRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      expect(fakeGoogle.signInCalled, isTrue);
      expect(capturedError, 'Token has expired on server.');
    });

    testWidgets('user cancellation does not trigger onAuthError or onAuthSuccess',
        (tester) async {
      // resultToReturn == null simulates user canceling the Google prompt
      final fakeGoogle = FakeGoogleAuthService(resultToReturn: null);
      final fakeRepo = FakeLoginRepository(
        const LoginResponseModel(success: true),
      );

      var successCalled = false;
      var errorCalled = false;

      await tester.pumpWidget(
        _wrapWithApp(
          SocialAuthSection(
            onAuthSuccess: (_) => successCalled = true,
            onAuthError: (_) => errorCalled = true,
          ),
          fakeGoogle: fakeGoogle,
          fakeRepo: fakeRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      expect(fakeGoogle.signInCalled, isTrue);
      expect(successCalled, isFalse);
      expect(errorCalled, isFalse);
      // Both buttons remain interactive afterwards
      expect(find.byType(SocialAuthButton), findsNWidgets(2));
    });

    testWidgets(
        'user cancellation displays cancellation SnackBar when callbacks are null (Google)',
        (tester) async {
      final fakeGoogle = FakeGoogleAuthService(resultToReturn: null);

      await tester.pumpWidget(
        _wrapWithApp(
          const SocialAuthSection(),
          fakeGoogle: fakeGoogle,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      expect(find.text('Google sign-in was cancelled.'), findsOneWidget);
    });

    testWidgets(
        'user cancellation displays cancellation SnackBar when callbacks are null (Apple)',
        (tester) async {
      final fakeApple = FakeAppleAuthService(resultToReturn: null);

      await tester.pumpWidget(
        _wrapWithApp(
          const SocialAuthSection(),
          fakeApple: fakeApple,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue with Apple'));
      await tester.pumpAndSettle();

      expect(find.text('Apple sign-in was cancelled.'), findsOneWidget);
    });

    testWidgets(
        'backend failure displays error SnackBar when onAuthError is null',
        (tester) async {
      final fakeGoogle = FakeGoogleAuthService(
        resultToReturn: const GoogleAuthResult(idToken: 'invalid_token'),
      );
      final fakeRepo = FakeLoginRepository(
        const LoginResponseModel(
          success: false,
          message: 'Invalid or expired social token.',
        ),
      );

      await tester.pumpWidget(
        _wrapWithApp(
          const SocialAuthSection(),
          fakeGoogle: fakeGoogle,
          fakeRepo: fakeRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid or expired social token.'), findsOneWidget);
    });

    testWidgets('routes to /role-selection when user role is NONE',
        (tester) async {
      final fakeGoogle = FakeGoogleAuthService(
        resultToReturn: const GoogleAuthResult(idToken: 'new_user_token'),
      );
      final fakeRepo = FakeLoginRepository(
        const LoginResponseModel(
          success: true,
          token: 'jwt_access',
          role: 'NONE',
          message: 'Login successful',
        ),
      );

      await tester.pumpWidget(
        _wrapWithRouter(
          const SocialAuthSection(),
          fakeGoogle: fakeGoogle,
          fakeRepo: fakeRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      expect(find.text('RoleSelectionScreen'), findsOneWidget);
    });

    testWidgets('routes to /home when user role is INVESTOR', (tester) async {
      final fakeGoogle = FakeGoogleAuthService(
        resultToReturn: const GoogleAuthResult(idToken: 'investor_token'),
      );
      final fakeRepo = FakeLoginRepository(
        const LoginResponseModel(
          success: true,
          token: 'jwt_access',
          role: 'INVESTOR',
          message: 'Welcome back!',
        ),
      );

      await tester.pumpWidget(
        _wrapWithRouter(
          const SocialAuthSection(),
          fakeGoogle: fakeGoogle,
          fakeRepo: fakeRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      expect(find.text('HomeScreen'), findsOneWidget);
    });

    testWidgets('routes to /home when user role is SPONSOR', (tester) async {
      final fakeApple = FakeAppleAuthService(
        resultToReturn: const AppleAuthResult(idToken: 'sponsor_apple_token'),
      );
      final fakeRepo = FakeLoginRepository(
        const LoginResponseModel(
          success: true,
          token: 'jwt_access',
          role: 'SPONSOR',
          message: 'Welcome back Sponsor!',
        ),
      );

      await tester.pumpWidget(
        _wrapWithRouter(
          const SocialAuthSection(),
          fakeApple: fakeApple,
          fakeRepo: fakeRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue with Apple'));
      await tester.pumpAndSettle();

      expect(find.text('HomeScreen'), findsOneWidget);
    });

    testWidgets('routes to /role-selection when user role is null or invalid',
        (tester) async {
      final fakeGoogle = FakeGoogleAuthService(
        resultToReturn: const GoogleAuthResult(idToken: 'unknown_role_token'),
      );
      final fakeRepo = FakeLoginRepository(
        const LoginResponseModel(
          success: true,
          token: 'jwt_access',
          role: null,
          message: 'Welcome!',
        ),
      );

      await tester.pumpWidget(
        _wrapWithRouter(
          const SocialAuthSection(),
          fakeGoogle: fakeGoogle,
          fakeRepo: fakeRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      expect(find.text('RoleSelectionScreen'), findsOneWidget);
    });
  });
}
