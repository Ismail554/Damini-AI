import 'package:Braintech/core/services/api_error_handler.dart';
import 'package:Braintech/core/services/google_auth_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MockGoogleSignIn extends Fake implements GoogleSignIn {
  bool initializeCalled = false;
  String? passedServerClientId;
  Object? errorToThrowOnAuthenticate;
  GoogleSignInAccount? accountToReturn;
  bool signOutCalled = false;

  @override
  Future<void> initialize({
    String? clientId,
    String? serverClientId,
    String? nonce,
    String? hostedDomain,
  }) async {
    initializeCalled = true;
    passedServerClientId = serverClientId;
  }

  @override
  Future<GoogleSignInAccount> authenticate({
    List<String>? scopeHint,
  }) async {
    if (errorToThrowOnAuthenticate != null) {
      throw errorToThrowOnAuthenticate!;
    }
    if (accountToReturn != null) {
      return accountToReturn!;
    }
    throw PlatformException(
      code: 'channel-error',
      message:
          'Unable to establish connection on channel: "dev.flutter.pigeon.google_sign_in_android.GoogleSignInApi.getCredential".',
    );
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }
}

class FakeGoogleSignInAuthentication extends Fake
    implements GoogleSignInAuthentication {
  @override
  final String? idToken;

  FakeGoogleSignInAuthentication({this.idToken});
}

class FakeGoogleSignInAccount extends Fake implements GoogleSignInAccount {
  @override
  final String email;
  @override
  final String? displayName;
  @override
  final String? photoUrl;
  final GoogleSignInAuthentication _auth;

  FakeGoogleSignInAccount({
    required this.email,
    this.displayName,
    this.photoUrl,
    required GoogleSignInAuthentication authentication,
  }) : _auth = authentication;

  @override
  GoogleSignInAuthentication get authentication => _auth;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GoogleAuthService.resetInitializationForTesting();
    dotenv.clean();
  });

  tearDown(() {
    GoogleAuthService.resetInitializationForTesting();
    dotenv.clean();
  });

  group('GoogleAuthService Unit Tests', () {
    test('isSupported returns true on supported platforms', () {
      final service = GoogleAuthService(googleSignIn: MockGoogleSignIn());
      expect(service.isSupported, isTrue);
    });

    test('translates channel-error into actionable rebuild instructions',
        () async {
      final mock = MockGoogleSignIn();
      mock.errorToThrowOnAuthenticate = PlatformException(
        code: 'channel-error',
        message:
            'Unable to establish connection on channel: "dev.flutter.pigeon.google_sign_in_android.GoogleSignInApi.getCredential".',
      );

      final service = GoogleAuthService(googleSignIn: mock);

      try {
        await service.signIn();
        fail('Should have thrown ApiException');
      } on ApiException catch (e) {
        expect(e.message, contains('flutter clean && flutter run'));
        expect(e.message, contains('Newly added native plugins require a full app rebuild'));
      }
    });

    test('translates Developer Error 10 into configuration instructions',
        () async {
      final mock = MockGoogleSignIn();
      mock.errorToThrowOnAuthenticate = PlatformException(
        code: '10',
        message:
            'com.google.android.gms.common.api.ApiException: 10: Developer error',
      );

      final service = GoogleAuthService(googleSignIn: mock);

      try {
        await service.signIn();
        fail('Should have thrown ApiException');
      } on ApiException catch (e) {
        expect(e.message, contains('Developer Error 10'));
        expect(e.message, contains('SHA-1 fingerprint mismatch'));
      }
    });

    test('translates Code 12500 error properly', () async {
      final mock = MockGoogleSignIn();
      mock.errorToThrowOnAuthenticate = PlatformException(
        code: '12500',
        message: 'Sign in failed: 12500',
      );

      final service = GoogleAuthService(googleSignIn: mock);

      try {
        await service.signIn();
        fail('Should have thrown ApiException');
      } on ApiException catch (e) {
        expect(e.message, contains('Code 12500'));
      }
    });

    test('translates no credential available error properly', () async {
      final mock = MockGoogleSignIn();
      mock.errorToThrowOnAuthenticate = PlatformException(
        code: 'no_credential',
        message: 'No credential available on this device',
      );

      final service = GoogleAuthService(googleSignIn: mock);

      try {
        await service.signIn();
        fail('Should have thrown ApiException');
      } on ApiException catch (e) {
        expect(e.message, contains('No Google credentials available on device'));
      }
    });

    test('returns null when user cancels sign in via PlatformException',
        () async {
      final mock = MockGoogleSignIn();
      mock.errorToThrowOnAuthenticate = PlatformException(
        code: 'canceled',
        message: 'User cancelled the sign in prompt',
      );

      final service = GoogleAuthService(googleSignIn: mock);
      final result = await service.signIn();

      expect(result, isNull);
    });

    test('returns null when user cancels sign in via sign_in_canceled code',
        () async {
      final mock = MockGoogleSignIn();
      mock.errorToThrowOnAuthenticate = PlatformException(
        code: 'sign_in_canceled',
        message: 'Sign-in canceled',
      );

      final service = GoogleAuthService(googleSignIn: mock);
      final result = await service.signIn();

      expect(result, isNull);
    });

    test('returns GoogleAuthResult when authentication succeeds with valid idToken',
        () async {
      final mock = MockGoogleSignIn();
      final auth = FakeGoogleSignInAuthentication(idToken: 'mock-valid-id-token');
      mock.accountToReturn = FakeGoogleSignInAccount(
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: 'https://example.com/photo.png',
        authentication: auth,
      );

      final service = GoogleAuthService(googleSignIn: mock);
      final result = await service.signIn();

      expect(result, isNotNull);
      expect(result!.idToken, equals('mock-valid-id-token'));
      expect(result.email, equals('test@example.com'));
      expect(result.displayName, equals('Test User'));
      expect(result.photoUrl, equals('https://example.com/photo.png'));
    });

    test('throws ApiException when idToken is null', () async {
      final mock = MockGoogleSignIn();
      final auth = FakeGoogleSignInAuthentication(idToken: null);
      mock.accountToReturn = FakeGoogleSignInAccount(
        email: 'test@example.com',
        authentication: auth,
      );

      final service = GoogleAuthService(googleSignIn: mock);

      try {
        await service.signIn();
        fail('Should have thrown ApiException');
      } on ApiException catch (e) {
        expect(e.message, contains('Failed to obtain Google ID token'));
      }
    });

    test(
        'throws ApiException when GoogleSignInException has canceled code with provider description',
        () async {
      final mock = MockGoogleSignIn();
      mock.errorToThrowOnAuthenticate = const GoogleSignInException(
        code: GoogleSignInExceptionCode.canceled,
        description:
            'The user canceled the credential request, or the provider canceled it.',
      );

      final service = GoogleAuthService(googleSignIn: mock);

      try {
        await service.signIn();
        fail('Should have thrown ApiException');
      } on ApiException catch (e) {
        expect(e.message, contains('provider canceled'));
        expect(e.message, contains('SHA-1 fingerprint'));
      }
    });

    test(
        'throws ApiException when PlatformException indicates provider cancellation',
        () async {
      final mock = MockGoogleSignIn();
      mock.errorToThrowOnAuthenticate = PlatformException(
        code: 'canceled',
        message:
            'androidx.credentials.exceptions.GetCredentialCancellationException: The user canceled the credential request, or the provider canceled it.',
      );

      final service = GoogleAuthService(googleSignIn: mock);

      try {
        await service.signIn();
        fail('Should have thrown ApiException');
      } on ApiException catch (e) {
        expect(e.message, contains('provider canceled'));
        expect(e.message, contains('SHA-1 fingerprint'));
      }
    });

    test(
        'returns null when GoogleSignInException is clean user cancellation',
        () async {
      final mock = MockGoogleSignIn();
      mock.errorToThrowOnAuthenticate = const GoogleSignInException(
        code: GoogleSignInExceptionCode.canceled,
        description: 'activity is cancelled by the user.',
      );

      final service = GoogleAuthService(googleSignIn: mock);
      final result = await service.signIn();

      expect(result, isNull);
    });

    test(
        'throws ApiException on clientConfigurationError with actionable guidance',
        () async {
      final mock = MockGoogleSignIn();
      mock.errorToThrowOnAuthenticate = const GoogleSignInException(
        code: GoogleSignInExceptionCode.clientConfigurationError,
        description: 'serverClientId must be provided on Android',
      );

      final service = GoogleAuthService(googleSignIn: mock);

      try {
        await service.signIn();
        fail('Should have thrown ApiException');
      } on ApiException catch (e) {
        expect(e.message, contains('configuration error'));
        expect(e.message, contains('GOOGLE_SERVER_CLIENT_ID'));
      }
    });

    test('throws ApiException on providerConfigurationError', () async {
      final mock = MockGoogleSignIn();
      mock.errorToThrowOnAuthenticate = const GoogleSignInException(
        code: GoogleSignInExceptionCode.providerConfigurationError,
        description: 'Credential Manager not supported.',
      );

      final service = GoogleAuthService(googleSignIn: mock);

      try {
        await service.signIn();
        fail('Should have thrown ApiException');
      } on ApiException catch (e) {
        expect(e.message, contains('provider configuration issue'));
      }
    });

    test('throws ApiException on uiUnavailable', () async {
      final mock = MockGoogleSignIn();
      mock.errorToThrowOnAuthenticate = const GoogleSignInException(
        code: GoogleSignInExceptionCode.uiUnavailable,
        description: 'No activity available',
      );

      final service = GoogleAuthService(googleSignIn: mock);

      try {
        await service.signIn();
        fail('Should have thrown ApiException');
      } on ApiException catch (e) {
        expect(e.message, contains('UI is currently unavailable'));
      }
    });

    test('throws ApiException on interrupted', () async {
      final mock = MockGoogleSignIn();
      mock.errorToThrowOnAuthenticate = const GoogleSignInException(
        code: GoogleSignInExceptionCode.interrupted,
        description: 'Interrupted by incoming call',
      );

      final service = GoogleAuthService(googleSignIn: mock);

      try {
        await service.signIn();
        fail('Should have thrown ApiException');
      } on ApiException catch (e) {
        expect(e.message, contains('was interrupted'));
      }
    });

    test(
        'throws ApiException before authenticate when GOOGLE_SERVER_CLIENT_ID is a placeholder',
        () async {
      dotenv.loadFromString(
        envString:
            'GOOGLE_SERVER_CLIENT_ID=1003008036989-webclient.apps.googleusercontent.com',
      );

      final mock = MockGoogleSignIn();
      final service = GoogleAuthService(googleSignIn: mock);

      try {
        await service.signIn();
        fail('Should have thrown ApiException');
      } on ApiException catch (e) {
        expect(e.message, contains('placeholder'));
        expect(e.message, contains('GOOGLE_SERVER_CLIENT_ID'));
      }
    });

    test(
        'does not pass placeholder client ID to GoogleSignIn.initialize when initialized directly',
        () async {
      final mock = MockGoogleSignIn();
      final service = GoogleAuthService(googleSignIn: mock);
      await service.ensureInitializedForTesting(
          '1003008036989-webclient.apps.googleusercontent.com');

      expect(mock.initializeCalled, isTrue);
      expect(mock.passedServerClientId, isNull);
    });

    test('passes genuine server client ID to GoogleSignIn.initialize', () async {
      final mock = MockGoogleSignIn();
      final service = GoogleAuthService(googleSignIn: mock);
      await service.ensureInitializedForTesting(
          '641571105178-r41vi2rtd4furjp43b12b1b22a9571sl.apps.googleusercontent.com');

      expect(mock.initializeCalled, isTrue);
      expect(
        mock.passedServerClientId,
        equals(
            '641571105178-r41vi2rtd4furjp43b12b1b22a9571sl.apps.googleusercontent.com'),
      );
    });

    test('serverClientId constructor override is prioritized over .env',
        () async {
      dotenv.loadFromString(
        envString:
            'GOOGLE_SERVER_CLIENT_ID=1003008036989-webclient.apps.googleusercontent.com',
      );

      final mock = MockGoogleSignIn();
      final auth = FakeGoogleSignInAuthentication(idToken: 'override-id-token');
      mock.accountToReturn = FakeGoogleSignInAccount(
        email: 'test@example.com',
        authentication: auth,
      );

      final service = GoogleAuthService(
        googleSignIn: mock,
        serverClientId:
            '641571105178-r41vi2rtd4furjp43b12b1b22a9571sl.apps.googleusercontent.com',
      );

      final result = await service.signIn();
      expect(result, isNotNull);
      expect(mock.passedServerClientId,
          '641571105178-r41vi2rtd4furjp43b12b1b22a9571sl.apps.googleusercontent.com');
    });

    test('throws ApiException when GOOGLE_SERVER_CLIENT_ID has invalid format',
        () async {
      dotenv.loadFromString(
        envString: 'GOOGLE_SERVER_CLIENT_ID=invalid_client_format',
      );

      final mock = MockGoogleSignIn();
      final service = GoogleAuthService(googleSignIn: mock);

      try {
        await service.signIn();
        fail('Should have thrown ApiException');
      } on ApiException catch (e) {
        expect(e.message, contains('invalid format'));
        expect(e.message, contains('GOOGLE_SERVER_CLIENT_ID'));
      }
    });

    test('isPlaceholderClientId detects known placeholder patterns correctly',
        () {
      expect(
        GoogleAuthService.isPlaceholderClientId(
            '1003008036989-webclient.apps.googleusercontent.com'),
        isTrue,
      );
      expect(
        GoogleAuthService.isPlaceholderClientId('YOUR_CLIENT_ID.apps.googleusercontent.com'),
        isTrue,
      );
      expect(
        GoogleAuthService.isPlaceholderClientId('1003008036989-xxxx.apps.googleusercontent.com'),
        isTrue,
      );
      expect(
        GoogleAuthService.isPlaceholderClientId('<CLIENT_ID>'),
        isTrue,
      );
      expect(
        GoogleAuthService.isPlaceholderClientId(
            '641571105178-r41vi2rtd4furjp43b12b1b22a9571sl.apps.googleusercontent.com'),
        isFalse,
      );
      expect(GoogleAuthService.isPlaceholderClientId(null), isFalse);
      expect(GoogleAuthService.isPlaceholderClientId(''), isFalse);
    });

    test('isValidServerClientId validates structure correctly', () {
      expect(
        GoogleAuthService.isValidServerClientId(
            '641571105178-r41vi2rtd4furjp43b12b1b22a9571sl.apps.googleusercontent.com'),
        isTrue,
      );
      expect(
        GoogleAuthService.isValidServerClientId(
            '1003008036989-webclient.apps.googleusercontent.com'),
        isFalse,
      );
      expect(GoogleAuthService.isValidServerClientId('dummy_id'), isFalse);
      expect(GoogleAuthService.isValidServerClientId(null), isFalse);
      expect(GoogleAuthService.isValidServerClientId(''), isFalse);
    });

    test('validateServerClientId returns descriptive error messages', () {
      expect(
        GoogleAuthService.validateServerClientId(null),
        contains('missing or empty'),
      );
      expect(
        GoogleAuthService.validateServerClientId(''),
        contains('missing or empty'),
      );
      expect(
        GoogleAuthService.validateServerClientId(
            '1003008036989-webclient.apps.googleusercontent.com'),
        contains('placeholder'),
      );
      expect(
        GoogleAuthService.validateServerClientId('malformed_client_id'),
        contains('invalid format'),
      );
      expect(
        GoogleAuthService.validateServerClientId(
            '641571105178-r41vi2rtd4furjp43b12b1b22a9571sl.apps.googleusercontent.com'),
        isNull,
      );
    });

    test(
        'throws ApiException with details when GoogleSignInException details contain provider cancellation',
        () async {
      final mock = MockGoogleSignIn();
      mock.errorToThrowOnAuthenticate = const GoogleSignInException(
        code: GoogleSignInExceptionCode.canceled,
        description: null,
        details: 'The user canceled the credential request, or the provider canceled it.',
      );

      final service = GoogleAuthService(googleSignIn: mock);

      try {
        await service.signIn();
        fail('Should have thrown ApiException');
      } on ApiException catch (e) {
        expect(e.message, contains('provider canceled'));
        expect(e.message, contains('SHA-1 fingerprint'));
      }
    });

    test(
        'throws ApiException with details on fallback GoogleSignInExceptionCode',
        () async {
      final mock = MockGoogleSignIn();
      mock.errorToThrowOnAuthenticate = GoogleSignInException(
        code: GoogleSignInExceptionCode.values.first,
        description: 'Native execution failed',
        details: 'ErrCode 500',
      );

      final service = GoogleAuthService(googleSignIn: mock);

      try {
        await service.signIn();
        fail('Should have thrown ApiException');
      } on ApiException catch (e) {
        expect(e.message, contains('Native execution failed'));
      }
    });

    test('signOut calls _googleSignIn.signOut', () async {
      final mock = MockGoogleSignIn();
      final service = GoogleAuthService(googleSignIn: mock);

      await service.signOut();
      expect(mock.signOutCalled, isTrue);
    });
  });
}
