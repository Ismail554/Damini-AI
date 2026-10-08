import 'package:Braintech/core/services/apple_auth_service.dart';
import 'package:Braintech/core/services/google_auth_service.dart';
import 'package:Braintech/core/theme/app_theme.dart';
import 'package:Braintech/views/auth/login/models/login_request_model.dart';
import 'package:Braintech/views/auth/login/provider/login_provider.dart';
import 'package:Braintech/views/auth/login/repositories/login_repository.dart';
import 'package:Braintech/views/auth/login/screens/login_view.dart';
import 'package:Braintech/views/auth/providers/social_auth_provider.dart';
import 'package:Braintech/views/auth/signup/screens/signup_view.dart';
import 'package:Braintech/views/auth/widgets/social_auth_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class FakeGoogleService extends GoogleAuthService {
  final GoogleAuthResult? resultToReturn;
  bool signInCalled = false;

  FakeGoogleService({this.resultToReturn});

  @override
  Future<GoogleAuthResult?> signIn() async {
    signInCalled = true;
    return resultToReturn;
  }
}

class FakeAppleService extends AppleAuthService {
  final AppleAuthResult? resultToReturn;
  bool signInCalled = false;

  FakeAppleService({this.resultToReturn});

  @override
  Future<AppleAuthResult?> signIn() async {
    signInCalled = true;
    return resultToReturn;
  }
}

class FakeLoginRepo implements LoginRepository {
  final LoginResponseModel responseToReturn;
  String? lastGoogleIdToken;
  String? lastAppleIdToken;

  FakeLoginRepo(this.responseToReturn);

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

Widget _wrapViewWithRouter(
  Widget child, {
  FakeGoogleService? fakeGoogle,
  FakeAppleService? fakeApple,
  FakeLoginRepo? fakeRepo,
}) {
  final router = GoRouter(
    initialLocation: '/test',
    routes: [
      GoRoute(
        path: '/test',
        builder: (context, state) => child,
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
      GoRoute(
        path: '/signup',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('SignUpScreen'))),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('LoginScreen'))),
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

  group('LoginView and SignUpView Social Auth Integration', () {
    testWidgets('LoginView renders SocialAuthSection and buttons',
        (tester) async {
      await tester.pumpWidget(_wrapViewWithRouter(const LoginView()));
      await tester.pumpAndSettle();

      expect(find.byType(SocialAuthSection), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Apple'), findsOneWidget);
    });

    testWidgets('SignUpView renders SocialAuthSection and buttons',
        (tester) async {
      await tester.pumpWidget(_wrapViewWithRouter(const SignUpView()));
      await tester.pumpAndSettle();

      expect(find.byType(SocialAuthSection), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Apple'), findsOneWidget);
    });

    testWidgets('LoginView navigates to /role-selection on Google sign-in with NONE role',
        (tester) async {
      final fakeGoogle = FakeGoogleService(
        resultToReturn: const GoogleAuthResult(
          idToken: 'google_token_new',
          email: 'newuser@gmail.com',
        ),
      );
      final fakeRepo = FakeLoginRepo(
        const LoginResponseModel(
          success: true,
          token: 'token_abc',
          role: 'NONE',
          message: 'Welcome new user!',
        ),
      );

      await tester.pumpWidget(
        _wrapViewWithRouter(
          const LoginView(),
          fakeGoogle: fakeGoogle,
          fakeRepo: fakeRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Continue with Google'));
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      expect(fakeGoogle.signInCalled, isTrue);
      expect(fakeRepo.lastGoogleIdToken, 'google_token_new');
      expect(find.text('RoleSelectionScreen'), findsOneWidget);
    });

    testWidgets('SignUpView navigates to /home on Apple sign-in with INVESTOR role',
        (tester) async {
      final fakeApple = FakeAppleService(
        resultToReturn: const AppleAuthResult(
          idToken: 'apple_token_returning',
          firstName: 'Jane',
          lastName: 'Doe',
        ),
      );
      final fakeRepo = FakeLoginRepo(
        const LoginResponseModel(
          success: true,
          token: 'token_xyz',
          role: 'INVESTOR',
          message: 'Welcome back!',
        ),
      );

      await tester.pumpWidget(
        _wrapViewWithRouter(
          const SignUpView(),
          fakeApple: fakeApple,
          fakeRepo: fakeRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue with Apple'));
      await tester.pumpAndSettle();

      expect(fakeApple.signInCalled, isTrue);
      expect(fakeRepo.lastAppleIdToken, 'apple_token_returning');
      expect(find.text('HomeScreen'), findsOneWidget);
    });

    testWidgets('LoginView shows SnackBar on user cancellation',
        (tester) async {
      final fakeGoogle = FakeGoogleService(resultToReturn: null);

      await tester.pumpWidget(
        _wrapViewWithRouter(
          const LoginView(),
          fakeGoogle: fakeGoogle,
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Continue with Google'));
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      expect(find.text('Google sign-in was cancelled.'), findsOneWidget);
    });

    testWidgets('SignUpView shows SnackBar on user cancellation',
        (tester) async {
      final fakeApple = FakeAppleService(resultToReturn: null);

      await tester.pumpWidget(
        _wrapViewWithRouter(
          const SignUpView(),
          fakeApple: fakeApple,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue with Apple'));
      await tester.pumpAndSettle();

      expect(find.text('Apple sign-in was cancelled.'), findsOneWidget);
    });
  });
}
