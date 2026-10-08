import 'package:Braintech/core/services/api_error_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Result object holding Apple ID credentials.
class AppleAuthResult {
  final String idToken;
  final String? firstName;
  final String? lastName;
  final String? email;

  const AppleAuthResult({
    required this.idToken,
    this.firstName,
    this.lastName,
    this.email,
  });
}

/// Service wrapping Apple Sign-In SDK.
class AppleAuthService {
  /// Checks whether native Sign in with Apple is supported on this device.
  Future<bool> isAvailable() async {
    try {
      if (kIsWeb) return false;
      if (defaultTargetPlatform != TargetPlatform.iOS &&
          defaultTargetPlatform != TargetPlatform.macOS) {
        return false;
      }
      return await SignInWithApple.isAvailable();
    } catch (_) {
      return false;
    }
  }

  /// Triggers Sign in with Apple and returns [AppleAuthResult].
  /// Returns `null` if the user cancelled the dialog.
  Future<AppleAuthResult?> signIn() async {
    try {
      debugPrint("AppleAuthService: Checking Apple Sign-In availability...");
      final available = await isAvailable();
      if (!available) {
        throw const AppleSignInNotAvailableException(
          "Apple Sign-In is only available on iOS and macOS devices. Please use Google Sign-In or email.",
        );
      }

      debugPrint("AppleAuthService: Requesting Apple ID credential...");
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final String? idToken = credential.identityToken;
      if (idToken == null || idToken.isEmpty) {
        debugPrint("AppleAuthService Error: identityToken is null or empty");
        throw const ApiException(
          message: "Failed to obtain Apple identity token.",
        );
      }

      debugPrint("AppleAuthService: Successfully obtained Apple idToken");
      return AppleAuthResult(
        idToken: idToken,
        firstName: credential.givenName,
        lastName: credential.familyName,
        email: credential.email,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        debugPrint("AppleAuthService: Sign-in cancelled by user");
        return null;
      }
      debugPrint("AppleAuthService AuthorizationException: ${e.message}");
      throw ApiException(
        message: e.message.isNotEmpty
            ? e.message
            : "Apple sign-in failed. Please try again.",
      );
    } on SignInWithAppleNotSupportedException {
      throw const AppleSignInNotAvailableException(
        "Apple Sign-In is only available on iOS and macOS devices. Please use Google Sign-In or email.",
      );
    } catch (e, stack) {
      if (e is AppleSignInNotAvailableException || e is ApiException) {
        rethrow;
      }
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('cancel') || errorStr.contains('canceled')) {
        debugPrint("AppleAuthService: Sign-in cancelled by user");
        return null;
      }
      if (errorStr.contains('notsupported') ||
          errorStr.contains('missingpluginexception')) {
        throw const AppleSignInNotAvailableException(
          "Apple Sign-In is only available on iOS and macOS devices. Please use Google Sign-In or email.",
        );
      }
      debugPrint("AppleAuthService Exception: $e\n$stack");
      throw ApiException(message: e.toString());
    }
  }
}

/// Exception thrown when Apple Sign In is invoked on an unsupported device.
class AppleSignInNotAvailableException implements Exception {
  final String message;
  const AppleSignInNotAvailableException(this.message);

  @override
  String toString() => message;
}
