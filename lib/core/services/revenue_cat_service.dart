import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class PurchaseOutcome {
  final bool isSuccess;
  final bool isCancelled;
  final String? errorMessage;
  final CustomerInfo? customerInfo;

  const PurchaseOutcome({
    required this.isSuccess,
    this.isCancelled = false,
    this.errorMessage,
    this.customerInfo,
  });
}

class RestoreOutcome {
  final bool isSuccess;
  final bool hasActiveSubscription;
  final String? errorMessage;

  const RestoreOutcome({
    required this.isSuccess,
    required this.hasActiveSubscription,
    this.errorMessage,
  });
}

class RevenueCatService {
  RevenueCatService._();

  static const String entitlementId = 'damani_ai_pro';

  /// Store product identifiers configured in RevenueCat.
  static const String lifetimeProductId = 'lifetime';
  static const String yearlyProductId = 'yearly';
  static const String monthlyProductId = 'monthly';

  /// Live pro status. UI can listen to this instead of polling.
  static final ValueNotifier<bool> isProNotifier = ValueNotifier<bool>(false);
  static bool _listenerAttached = false;

  static void _onCustomerInfo(CustomerInfo info) {
    isProNotifier.value =
        info.entitlements.all[entitlementId]?.isActive == true;
  }
  static bool _isConfigured = false;
  static bool get isConfigured => _isConfigured;
  static String? _currentAppUserId;
  static String? get currentAppUserId => _currentAppUserId;

  static bool _isPlaceholderKey(String? key) {
    if (key == null) return true;
    final lower = key.trim().toLowerCase();
    return lower.isEmpty ||
        lower.contains('placeholder') ||
        lower.contains('demo') ||
        lower.contains('your_public');
  }

  /// Initialize RevenueCat with user identifier (typically user email)
  static Future<void> init([String? userEmail]) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      log('RevenueCat: Skipped on non-mobile platform.');
      return;
    }

    try {
      await Purchases.setLogLevel(
          kDebugMode ? LogLevel.debug : LogLevel.warn);

      final googleKey = dotenv.env['REVENUECAT_GOOGLE_KEY'];
      final appleKey = dotenv.env['REVENUECAT_APPLE_KEY'];
      final activeKey = Platform.isAndroid ? googleKey : appleKey;

      if (_isPlaceholderKey(activeKey)) {
        log('RevenueCat: Public SDK key is placeholder or unset.');
        _isConfigured = false;
        return;
      }

      final configuration = PurchasesConfiguration(activeKey!.trim());
      if (userEmail != null && userEmail.trim().isNotEmpty) {
        final email = userEmail.trim();
        configuration.appUserID = email;
        _currentAppUserId = email;
      }

      await Purchases.configure(configuration);
      _isConfigured = true;

      if (!_listenerAttached) {
        Purchases.addCustomerInfoUpdateListener(_onCustomerInfo);
        _listenerAttached = true;
      }
      try {
        _onCustomerInfo(await Purchases.getCustomerInfo());
      } catch (_) {}

      if (userEmail != null && userEmail.trim().isNotEmpty) {
        try {
          await Purchases.setEmail(userEmail.trim());
        } catch (_) {}
      }
      log('RevenueCat: Successfully configured.');
    } catch (e) {
      _isConfigured = false;
      log('RevenueCat: Configuration failed: $e');
    }
  }

  static Future<bool> isProUser() async {
    if (!_isConfigured) return false;
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[entitlementId]?.isActive == true;
    } catch (e) {
      log('RevenueCat: Failed to check customer info: $e');
      return false;
    }
  }

  static Future<Offerings?> getOfferings() async {
    if (!_isConfigured) return null;
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      log('RevenueCat: Failed to get offerings: $e');
      return null;
    }
  }

  /// Lifetime (one-time) package from the current offering, if any.
  static Package? findLifetimePackage(Offerings offerings) {
    final current = offerings.current;
    if (current == null) return null;
    if (current.lifetime != null) return current.lifetime;
    for (final p in current.availablePackages) {
      if (p.storeProduct.identifier == lifetimeProductId ||
          p.packageType == PackageType.lifetime) {
        return p;
      }
    }
    return null;
  }

  /// Presents the RevenueCat Paywall (configured in the dashboard).
  /// Returns true if the user ends up with the pro entitlement.
  static Future<bool> presentPaywall({bool onlyIfNeeded = false}) async {
    if (!_isConfigured) return false;
    try {
      final result = onlyIfNeeded
          ? await RevenueCatUI.presentPaywallIfNeeded(entitlementId)
          : await RevenueCatUI.presentPaywall();
      return result == PaywallResult.purchased ||
          result == PaywallResult.restored;
    } catch (e) {
      log('RevenueCat: Paywall failed: $e');
      return false;
    }
  }

  /// Opens Customer Center (manage / cancel / restore).
  static Future<void> presentCustomerCenter() async {
    if (!_isConfigured) return;
    try {
      await RevenueCatUI.presentCustomerCenter();
    } catch (e) {
      log('RevenueCat: Customer Center failed: $e');
    }
  }

  static Package? findPackage({
    required Offerings offerings,
    required bool isYearly,
    String? preferredProductId,
  }) {
    final current = offerings.current;
    if (current == null) return null;

    if (preferredProductId != null && preferredProductId.isNotEmpty) {
      for (final p in current.availablePackages) {
        if (p.storeProduct.identifier == preferredProductId ||
            p.identifier == preferredProductId) {
          return p;
        }
      }
    }

    if (isYearly) {
      if (current.annual != null) return current.annual;
      for (final p in current.availablePackages) {
        if (p.packageType == PackageType.annual) return p;
      }
    } else {
      if (current.monthly != null) return current.monthly;
      for (final p in current.availablePackages) {
        if (p.packageType == PackageType.monthly) return p;
      }
    }
    return null;
  }

  static Future<PurchaseOutcome> purchasePackage(Package package) async {
    if (!_isConfigured) {
      return const PurchaseOutcome(
        isSuccess: false,
        errorMessage: 'Purchases are currently unavailable.',
      );
    }
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      final isPro =
          result.customerInfo.entitlements.all[entitlementId]?.isActive == true;
      return PurchaseOutcome(
        isSuccess: isPro,
        customerInfo: result.customerInfo,
      );
    } on PlatformException catch (e) {
      final isCancelled =
          PurchasesErrorHelper.getErrorCode(e) == PurchasesErrorCode.purchaseCancelledError;
      return PurchaseOutcome(
        isSuccess: false,
        isCancelled: isCancelled,
        errorMessage: isCancelled ? null : (e.message ?? 'Purchase failed.'),
      );
    } catch (e) {
      return PurchaseOutcome(isSuccess: false, errorMessage: e.toString());
    }
  }

  static Future<RestoreOutcome> restore() async {
    if (!_isConfigured) {
      return const RestoreOutcome(
        isSuccess: false,
        hasActiveSubscription: false,
        errorMessage: 'Purchases are currently unavailable.',
      );
    }
    try {
      final info = await Purchases.restorePurchases();
      final isPro = info.entitlements.all[entitlementId]?.isActive == true;
      return RestoreOutcome(isSuccess: true, hasActiveSubscription: isPro);
    } catch (e) {
      return RestoreOutcome(
        isSuccess: false,
        hasActiveSubscription: false,
        errorMessage: e.toString(),
      );
    }
  }

  static Future<void> logIn(String userEmail) async {
    if (!_isConfigured) return;
    final email = userEmail.trim();
    if (email.isEmpty || _currentAppUserId == email) return;
    try {
      await Purchases.logIn(email);
      _currentAppUserId = email;
      try {
        await Purchases.setEmail(email);
      } catch (_) {}
    } catch (e) {
      log('RevenueCat: logIn failed: $e');
    }
  }

  static Future<void> logOut() async {
    if (!_isConfigured) return;
    try {
      await Purchases.logOut();
      _currentAppUserId = null;
      isProNotifier.value = false;
    } catch (e) {
      log('RevenueCat: logOut failed: $e');
    }
  }
}
