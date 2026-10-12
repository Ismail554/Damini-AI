import 'package:Braintech/core/services/api_error_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Result object holding Google authentication credentials.
class GoogleAuthResult {
  final String idToken;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  const GoogleAuthResult({
    required this.idToken,
    this.email,
    this.displayName,
    this.photoUrl,
  });
}

/// Service wrapping Google Sign-In SDK (v7.x).
class GoogleAuthService {
  final GoogleSignIn _googleSignIn;
  final String? _serverClientIdOverride;
  static bool _isGoogleSignInInitialized = false;
  static String? _lastInitializedClientId;

  GoogleAuthService({GoogleSignIn? googleSignIn, String? serverClientId})
      : _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
        _serverClientIdOverride = serverClientId;

  @visibleForTesting
  static void resetInitializationForTesting() {
    _isGoogleSignInInitialized = false;
    _lastInitializedClientId = null;
  }

  /// Checks whether Google Sign-In is supported on the current platform.
  bool get isSupported {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Checks whether the provided client ID is a placeholder rather than a valid OAuth client ID.
  static bool isPlaceholderClientId(String? clientId) {
    if (clientId == null || clientId.trim().isEmpty) return false;
    final lower = clientId.trim().toLowerCase();
    return lower.contains('webclient') ||
        lower.contains('placeholder') ||
        lower.contains('your_') ||
        lower.contains('your-') ||
        lower.contains('example') ||
        lower.contains('xxxx') ||
        lower.contains('<') ||
        lower.contains('>');
  }

  /// Validates whether the given client ID matches a valid Google OAuth Web Client ID structure.
  /// A valid client ID ends with `.apps.googleusercontent.com` and has the format
  /// `PROJECT_NUMBER-HASH.apps.googleusercontent.com`.
  static bool isValidServerClientId(String? clientId) {
    if (clientId == null || clientId.trim().isEmpty) return false;
    final trimmed = clientId.trim();
    if (isPlaceholderClientId(trimmed)) return false;
    final regex = RegExp(r'^\d+-[a-zA-Z0-9_\-]+\.apps\.googleusercontent\.com$');
    return regex.hasMatch(trimmed);
  }

  /// Validates the server client ID, returning an error message if invalid, or null if valid.
  static String? validateServerClientId(String? clientId) {
    if (clientId == null || clientId.trim().isEmpty) {
      return "GOOGLE_SERVER_CLIENT_ID is missing or empty in .env. "
          "Please obtain your OAuth 2.0 Web Client ID from Firebase Console (Authentication > Sign-in method > Google) "
          "and add it to your .env file.";
    }
    final trimmed = clientId.trim();
    if (isPlaceholderClientId(trimmed)) {
      return "GOOGLE_SERVER_CLIENT_ID in .env is set to a placeholder ('$trimmed'). "
          "Please obtain your actual OAuth 2.0 Web Client ID from Firebase Console (Authentication > Sign-in method > Google) "
          "or Google Cloud Credentials, and update .env.";
    }
    if (!isValidServerClientId(trimmed)) {
      return "GOOGLE_SERVER_CLIENT_ID in .env ('$trimmed') has an invalid format. "
          "A valid OAuth 2.0 Web Client ID must end with '.apps.googleusercontent.com' "
          "(e.g. 1003008036989-<hash>.apps.googleusercontent.com).";
    }
    return null;
  }

  String? _resolveServerClientId() {
    final override = _serverClientIdOverride;
    if (override != null && override.trim().isNotEmpty) {
      return override.trim();
    }
    if (dotenv.isInitialized) {
      try {
        final envVal = dotenv.env['GOOGLE_SERVER_CLIENT_ID'];
        if (envVal != null && envVal.trim().isNotEmpty) {
          return envVal.trim();
        }
      } catch (_) {}
    }
    return null;
  }

  String? _resolveIosClientId() {
    if (dotenv.isInitialized) {
      try {
        final envVal = dotenv.env['GOOGLE_IOS_CLIENT_ID'];
        if (envVal != null && envVal.trim().isNotEmpty) {
          return envVal.trim();
        }
      } catch (_) {}
    }
    return null;
  }

  Future<void> _ensureInitialized([String? explicitClientId]) async {
    final targetServerClientId = explicitClientId ?? _resolveServerClientId();
    final targetIosClientId = _resolveIosClientId();

    final isServerPlaceholder = isPlaceholderClientId(targetServerClientId);
    if (isServerPlaceholder) {
      debugPrint(
        "GoogleAuthService WARNING: GOOGLE_SERVER_CLIENT_ID appears to be a placeholder ('$targetServerClientId'). "
        "It will not be passed to GoogleSignIn SDK to prevent Credential Manager failures. "
        "Obtain the actual Web Client ID from Firebase Console / Google Cloud Credentials.",
      );
    }

    final effectiveServerClientId = (!isServerPlaceholder) ? targetServerClientId : null;
    final effectiveIosClientId = (!isPlaceholderClientId(targetIosClientId)) ? targetIosClientId : null;
    final initKey = '${effectiveServerClientId}_$effectiveIosClientId';

    if (_isGoogleSignInInitialized && _lastInitializedClientId == initKey) {
      return;
    }

    try {
      await _googleSignIn.initialize(
        clientId: (defaultTargetPlatform == TargetPlatform.iOS) ? effectiveIosClientId : null,
        serverClientId: effectiveServerClientId,
      );
      _isGoogleSignInInitialized = true;
      _lastInitializedClientId = initKey;
    } catch (e) {
      debugPrint("GoogleAuthService: initialize warning: $e");
    }
  }

  @visibleForTesting
  Future<void> ensureInitializedForTesting([String? clientId]) async {
    await _ensureInitialized(clientId);
  }

  /// Triggers Google Sign-In and returns the [GoogleAuthResult].
  /// Returns `null` if the user cancelled the sign-in prompt.
  Future<GoogleAuthResult?> signIn() async {
    try {
      if (!isSupported) {
        throw const ApiException(
          message:
              "Google Sign-In is only available on Android, iOS, and Web. Please use email sign-in on this device.",
        );
      }

      final cleanClientId = _resolveServerClientId();

      // Fail-fast if GOOGLE_SERVER_CLIENT_ID is configured with a placeholder or invalid format.
      if (cleanClientId != null) {
        final validationError = validateServerClientId(cleanClientId);
        if (validationError != null) {
          debugPrint("GoogleAuthService Error: $validationError");
          throw ApiException(message: "Google Sign-In configuration error: $validationError");
        }
      } else {
        debugPrint(
          "GoogleAuthService WARNING: GOOGLE_SERVER_CLIENT_ID is not configured in .env. "
          "ID token may not be returned on Android without a server client ID.",
        );
      }

      debugPrint("GoogleAuthService: Initializing GoogleSignIn...");
      await _ensureInitialized(cleanClientId);

      debugPrint("GoogleAuthService: Authenticating user...");
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
        scopeHint: const ['email', 'profile'],
      );

      debugPrint("GoogleAuthService: Obtaining tokens for ${googleUser.email}...");
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        debugPrint("GoogleAuthService Error: idToken is null or empty");
        throw const ApiException(
          message:
              "Failed to obtain Google ID token. Please verify your Google OAuth configuration (ensure Web Client ID and SHA-1 fingerprint are configured).",
        );
      }

      debugPrint("GoogleAuthService: Successfully obtained idToken");
      return GoogleAuthResult(
        idToken: idToken,
        email: googleUser.email,
        displayName: googleUser.displayName,
        photoUrl: googleUser.photoUrl,
      );
    } on GoogleSignInException catch (e) {
      debugPrint(
        "GoogleAuthService GoogleSignInException: code=${e.code}, description=${e.description}, details=${e.details}",
      );

      final combinedError = "${e.description ?? ''} ${e.details ?? ''}".toLowerCase();

      if (e.code == GoogleSignInExceptionCode.clientConfigurationError) {
        throw ApiException(
          message:
              "Google Sign-In configuration error: ${e.description ?? 'Missing or invalid client configuration'}. "
              "Ensure GOOGLE_SERVER_CLIENT_ID in .env is set to your OAuth Web Client ID and matches Firebase Console.",
        );
      }

      if (e.code == GoogleSignInExceptionCode.providerConfigurationError) {
        throw ApiException(
          message:
              "Google Sign-In provider configuration issue: ${e.description ?? 'Credential Manager error'}. "
              "Please check Google Play Services on this device.",
        );
      }

      if (e.code == GoogleSignInExceptionCode.uiUnavailable) {
        throw ApiException(
          message:
              "Google Sign-In UI is currently unavailable (${e.description ?? 'no activity'}). Please try again.",
        );
      }

      if (e.code == GoogleSignInExceptionCode.interrupted) {
        throw ApiException(
          message:
              "Google Sign-In was interrupted (${e.description ?? 'interrupted'}). Please try again.",
        );
      }

      if (e.code == GoogleSignInExceptionCode.canceled) {
        // Android Credential Manager throws GetCredentialCancellationException when the provider
        // (Google Play Services) cancels the flow due to SHA-1 mismatch, invalid client ID, etc.
        // The default message is: "The user canceled the credential request, or the provider canceled it."
        // We must NEVER classify provider cancellations as user cancellations!
        if (combinedError.contains('provider') ||
            combinedError.contains('credential request') ||
            combinedError.contains('developer_error') ||
            combinedError.contains('10') ||
            combinedError.contains('12500') ||
            combinedError.contains('16')) {
          final detailMsg = e.description ?? (e.details?.toString() ?? 'provider canceled');
          debugPrint(
            "GoogleAuthService Error: Google Sign-In provider canceled authentication: $detailMsg. "
            "This indicates a configuration failure: SHA-1 fingerprint mismatch in Firebase Console, "
            "invalid GOOGLE_SERVER_CLIENT_ID, or missing OAuth client.",
          );
          throw ApiException(
            message:
                "Google Sign-In failed: The authentication provider canceled the request. "
                "This usually indicates that your debug SHA-1 fingerprint is missing in Firebase Console "
                "or GOOGLE_SERVER_CLIENT_ID does not match your project. (Details: $detailMsg)",
          );
        }

        // Clean user cancellation (e.g. tapped outside sheet, tapped back button)
        debugPrint("GoogleAuthService: Sign-in cancelled by user");
        return null;
      }

      final errorDetails = e.description ?? (e.details?.toString() ?? 'Unknown error (${e.code.name})');
      throw ApiException(
        message: "Google sign-in failed: $errorDetails",
      );
    } catch (e, stack) {
      if (e is ApiException) rethrow;

      final errorStr = e.toString().toLowerCase();
      debugPrint("GoogleAuthService Exception: $e\n$stack");

      // Check for known actionable errors first before any cancellation checks
      if (errorStr.contains('channel-error') ||
          errorStr.contains('missingpluginexception') ||
          errorStr.contains('unable to establish connection on channel')) {
        throw const ApiException(
          message:
              "Google Sign-In native channel error: Newly added native plugins require a full app rebuild. "
              "Please stop the app and run 'flutter clean && flutter run'. Hot reload/restart cannot register new native plugins.",
        );
      }

      if (errorStr.contains('apiexception: 10') ||
          errorStr.contains('developer_error') ||
          errorStr.contains(': 10:') ||
          errorStr.contains(': 10,') ||
          errorStr.contains('code: 10')) {
        throw const ApiException(
          message:
              "Google Sign-In configuration error (Developer Error 10: SHA-1 fingerprint mismatch or invalid OAuth client ID). "
              "Please verify your SHA-1 fingerprint in Firebase Console.",
        );
      }

      if (errorStr.contains('12500')) {
        throw const ApiException(
          message:
              "Google Sign-In failed (Code 12500). Please check your Google account and try again.",
        );
      }

      if (errorStr.contains('nocredential') ||
          errorStr.contains('no credential available')) {
        throw const ApiException(
          message:
              "No Google credentials available on device. Please sign in to a Google account in device Settings and try again.",
        );
      }

      if (errorStr.contains('network_error') ||
          errorStr.contains('socketexception') ||
          errorStr.contains('failed host lookup')) {
        throw const ApiException(
          message:
              "Network error during Google Sign-In. Please check your internet connection.",
        );
      }

      // Check if Android Credential Manager or Google Identity canceled due to provider failure
      if (errorStr.contains('provider canceled') ||
          errorStr.contains('the provider canceled it') ||
          errorStr.contains('credential request') ||
          (errorStr.contains('getcredentialcancellationexception') &&
              errorStr.contains('provider'))) {
        throw ApiException(
          message:
              "Google Sign-In failed: The authentication provider canceled the request. "
              "Please verify that your debug SHA-1 fingerprint is added in Firebase Console and "
              "GOOGLE_SERVER_CLIENT_ID in .env matches the Web Client ID. ($e)",
        );
      }

      // Check for genuine user cancellation ONLY after ruling out provider/configuration failures
      if (errorStr.contains('activity is cancelled by the user') ||
          errorStr.contains('user cancelled') ||
          errorStr.contains('user canceled') ||
          errorStr.contains('sign_in_canceled') ||
          errorStr.contains('sign-in canceled') ||
          errorStr.contains('sign in was cancelled') ||
          (errorStr.contains('canceled') &&
              !errorStr.contains('provider') &&
              !errorStr.contains('credential request'))) {
        debugPrint("GoogleAuthService: Sign-in cancelled by user");
        return null;
      }

      throw ApiException(message: "Google sign-in failed: $e");
    }
  }

  /// Signs the user out of Google.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint("GoogleAuthService signOut error: $e");
    }
  }
}
