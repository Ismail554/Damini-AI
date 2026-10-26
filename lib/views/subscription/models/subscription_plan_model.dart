import 'package:purchases_flutter/purchases_flutter.dart';

enum PlanBillingPeriod { yearly, monthly }

/// A purchasable plan built entirely from a RevenueCat [Package].
/// No prices or copy are hardcoded; everything comes from the store.
class SubscriptionPlanModel {
  final String id;
  final String name;
  final PlanBillingPeriod billingPeriod;
  final double price;
  final String currency;
  final String priceString;
  final String? subPriceText;
  final String? badgeText;
  final Package rcPackage;

  const SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.billingPeriod,
    required this.price,
    required this.currency,
    required this.priceString,
    required this.rcPackage,
    this.subPriceText,
    this.badgeText,
  });

  bool get isYearly => billingPeriod == PlanBillingPeriod.yearly;

  String get mainPriceText => priceString;

  String get priceSuffix => isYearly ? '/yr' : '/mo';

  bool get isBestValue => badgeText != null;

  String get revenuecatProductId => rcPackage.storeProduct.identifier;

  /// Builds a pair of plans, deriving the equivalent price text and the
  /// yearly savings badge from the real store prices.
  static List<SubscriptionPlanModel> fromPackages({
    Package? yearly,
    Package? monthly,
  }) {
    final plans = <SubscriptionPlanModel>[];

    String money(String currency, double value) =>
        '$currency ${value.toStringAsFixed(2)}';

    if (yearly != null) {
      final p = yearly.storeProduct;
      String? badge;
      if (monthly != null && monthly.storeProduct.price > 0) {
        final full = monthly.storeProduct.price * 12;
        final pct = ((1 - p.price / full) * 100).round();
        if (pct > 0) badge = '-$pct%';
      }
      plans.add(
        SubscriptionPlanModel(
          id: p.identifier,
          name: p.title,
          billingPeriod: PlanBillingPeriod.yearly,
          price: p.price,
          currency: p.currencyCode,
          priceString: p.priceString,
          subPriceText: '${money(p.currencyCode, p.price / 12)}/mo',
          badgeText: badge,
          rcPackage: yearly,
        ),
      );
    }

    if (monthly != null) {
      final p = monthly.storeProduct;
      plans.add(
        SubscriptionPlanModel(
          id: p.identifier,
          name: p.title,
          billingPeriod: PlanBillingPeriod.monthly,
          price: p.price,
          currency: p.currencyCode,
          priceString: p.priceString,
          subPriceText: '${money(p.currencyCode, p.price * 12)}/yr',
          rcPackage: monthly,
        ),
      );
    }

    return plans;
  }
}
