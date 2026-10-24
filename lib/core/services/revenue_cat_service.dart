import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  RevenueCatService._();

  static bool _isConfigured = false;
  static bool get isConfigured => _isConfigured;

  /// Initialize RevenueCat with user identifier (typically user email)
  static Future<void> init([String? userEmail]) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      log('RevenueCat: Skipped on non-mobile platform.');
      return;
    }

    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      } else {
        await Purchases.setLogLevel(LogLevel.warn);
      }

      final googleKey =
          dotenv.env['REVENUECAT_GOOGLE_KEY'] ?? 'goog_demo_key_placeholder';
      final appleKey =
          dotenv.env['REVENUECAT_APPLE_KEY'] ?? 'appl_demo_key_placeholder';

      late PurchasesConfiguration configuration;
      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(googleKey);
      } else if (Platform.isIOS) {
        configuration = PurchasesConfiguration(appleKey);
      }

      if (userEmail != null && userEmail.trim().isNotEmpty) {
        configuration.appUserID = userEmail.trim();
      }

      await Purchases.configure(configuration);
      _isConfigured = true;
      log('RevenueCat: Successfully configured.');
    } catch (e) {
      log('RevenueCat: Configuration failed: $e');
    }
  }

  /// Check whether the current user has active PRO entitlement
  static Future<bool> isProUser() async {
    if (!_isConfigured) return false;
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all['pro_access']?.isActive == true;
    } catch (e) {
      log('RevenueCat: Failed to check customer info: $e');
      return false;
    }
  }

  /// Purchase an in-app subscription package
  static Future<bool> purchasePackage(Package package) async {
    if (!_isConfigured) return false;
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      return result.customerInfo.entitlements.all['pro_access']?.isActive == true;
    } catch (e) {
      log('RevenueCat: Purchase error: $e');
      rethrow;
    }
  }

  /// Update App User ID upon user login
  static Future<void> logIn(String userEmail) async {
    if (!_isConfigured) return;
    try {
      await Purchases.logIn(userEmail);
    } catch (e) {
      log('RevenueCat: logIn failed: $e');
    }
  }

  /// Reset App User ID upon logout
  static Future<void> logOut() async {
    if (!_isConfigured) return;
    try {
      await Purchases.logOut();
    } catch (e) {
      log('RevenueCat: logOut failed: $e');
    }
  }
}
