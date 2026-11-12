import 'package:purchases_flutter/purchases_flutter.dart';

enum PlanBillingPeriod { yearly, monthly }

/// Purchasable plan supporting both RevenueCat [Package] and backend JSON.
class SubscriptionPlanModel {
  final String id;
  final String name;
  final PlanBillingPeriod billingPeriod;
  final double price;
  final String currency;
  final String priceString;
  final String? subPriceText;
  final String? badgeText;
  final Package? rcPackage;
  final String? entitlement;
  final List<String> features;
  final String? storePriceString;
  final String? _revenuecatProductId;

  const SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.billingPeriod,
    required this.price,
    required this.currency,
    required this.priceString,
    this.rcPackage,
    this.subPriceText,
    this.badgeText,
    this.entitlement,
    this.features = const [],
    this.storePriceString,
    String? revenuecatProductId,
  }) : _revenuecatProductId = revenuecatProductId;

  bool get isYearly => billingPeriod == PlanBillingPeriod.yearly;

  String get mainPriceText => storePriceString ?? priceString;

  String get priceSuffix => isYearly ? '/yr' : '/mo';

  bool get isBestValue => badgeText != null;

  String get revenuecatProductId =>
      rcPackage?.storeProduct.identifier ?? _revenuecatProductId ?? id;

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    final periodStr = (json['billing_period'] ?? '').toString().toUpperCase();
    final isYearly = periodStr == 'YEARLY';
    final period =
        isYearly ? PlanBillingPeriod.yearly : PlanBillingPeriod.monthly;
    final price = (json['price'] as num?)?.toDouble() ?? 0.0;
    final currency = json['currency']?.toString() ?? 'USD';
    final symbol = currency == 'USD' ? '\$' : currency;
    final priceFormatted =
        price == price.truncateToDouble() ? '${price.toInt()}' : '$price';

    String? subPrice;
    String? badge;
    if (isYearly) {
      final monthlyEquivalent = (price / 12).round();
      subPrice = '$monthlyEquivalent $symbol/mo';
      badge = '-14%';
    } else {
      final yearlyEquivalent = (price * 12).round();
      subPrice = '$yearlyEquivalent $symbol/yr';
    }

    final rawFeatures = json['features'];
    final features = rawFeatures is List
        ? rawFeatures.map((e) => e.toString()).toList()
        : <String>[];

    return SubscriptionPlanModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      billingPeriod: period,
      price: price,
      currency: currency,
      priceString: '$priceFormatted $symbol',
      subPriceText: subPrice,
      badgeText: isYearly ? badge : null,
      entitlement: json['entitlement']?.toString(),
      revenuecatProductId: json['revenuecat_product_id']?.toString(),
      features: features,
    );
  }

  SubscriptionPlanModel copyWith({
    String? id,
    String? name,
    PlanBillingPeriod? billingPeriod,
    double? price,
    String? currency,
    String? priceString,
    Package? rcPackage,
    String? subPriceText,
    String? badgeText,
    String? entitlement,
    List<String>? features,
    String? storePriceString,
    String? revenuecatProductId,
  }) {
    return SubscriptionPlanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      billingPeriod: billingPeriod ?? this.billingPeriod,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      priceString: priceString ?? this.priceString,
      rcPackage: rcPackage ?? this.rcPackage,
      subPriceText: subPriceText ?? this.subPriceText,
      badgeText: badgeText ?? this.badgeText,
      entitlement: entitlement ?? this.entitlement,
      features: features ?? this.features,
      storePriceString: storePriceString ?? this.storePriceString,
      revenuecatProductId: revenuecatProductId ?? _revenuecatProductId,
    );
  }

  static const List<SubscriptionPlanModel> defaultPlans = [
    SubscriptionPlanModel(
      id: 'pro_yearly',
      name: 'Pro Yearly',
      billingPeriod: PlanBillingPeriod.yearly,
      price: 229.0,
      currency: 'USD',
      priceString: '229 \$',
      subPriceText: '19 \$/mo',
      badgeText: '-14%',
      entitlement: 'pro_access',
      revenuecatProductId: 'pro_yearly',
      features: ['Unlimited projects', 'Priority support'],
    ),
    SubscriptionPlanModel(
      id: 'pro_monthly',
      name: 'Pro Monthly',
      billingPeriod: PlanBillingPeriod.monthly,
      price: 22.0,
      currency: 'USD',
      priceString: '22 \$',
      subPriceText: '264 \$/yr',
      entitlement: 'pro_access',
      revenuecatProductId: 'pro_monthly',
      features: ['Unlimited projects'],
    ),
  ];

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
          entitlement: 'pro_access',
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
          entitlement: 'pro_access',
        ),
      );
    }

    return plans;
  }
}
