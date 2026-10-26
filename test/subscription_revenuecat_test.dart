import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Braintech/views/profile/widgets/profile_hero_card.dart';
import 'package:Braintech/views/subscription/models/subscription_plan_model.dart';
import 'package:Braintech/views/subscription/models/subscription_status_model.dart';
import 'package:Braintech/views/subscription/widgets/subscription_status_banner.dart';

void main() {
  group('SubscriptionPlanModel Tests', () {
    test('parses Endpoint A JSON from BACKEND_REVENUECAT_ISSUES.md accurately', () {
      final yearlyJson = {
        "id": "pro_yearly",
        "name": "Pro Yearly",
        "billing_period": "YEARLY",
        "price": 229.00,
        "currency": "USD",
        "revenuecat_product_id": "pro_yearly",
        "entitlement": "pro_access",
        "is_best_value": true,
        "trial_days": 0,
        "features": ["Unlimited projects", "Priority support"]
      };

      final plan = SubscriptionPlanModel.fromJson(yearlyJson);

      expect(plan.id, 'pro_yearly');
      expect(plan.name, 'Pro Yearly');
      expect(plan.billingPeriod, PlanBillingPeriod.yearly);
      expect(plan.price, 229.0);
      expect(plan.currency, 'USD');
      expect(plan.revenuecatProductId, 'pro_yearly');
      expect(plan.entitlement, 'pro_access');
      expect(plan.isBestValue, true);
      expect(plan.features.length, 2);
      expect(plan.badgeText, '-14%');
      expect(plan.mainPriceText, '229 \$');
      expect(plan.priceSuffix, '/yr');
      expect(plan.subPriceText, '19 \$/mo');
    });

    test('parses monthly plan JSON accurately', () {
      final monthlyJson = {
        "id": "pro_monthly",
        "name": "Pro Monthly",
        "billing_period": "MONTHLY",
        "price": 22.00,
        "currency": "USD",
        "revenuecat_product_id": "pro_monthly",
        "entitlement": "pro_access",
        "is_best_value": false,
        "trial_days": 0,
        "features": ["Unlimited projects"]
      };

      final plan = SubscriptionPlanModel.fromJson(monthlyJson);

      expect(plan.id, 'pro_monthly');
      expect(plan.billingPeriod, PlanBillingPeriod.monthly);
      expect(plan.price, 22.0);
      expect(plan.isBestValue, false);
      expect(plan.badgeText, isNull);
      expect(plan.mainPriceText, '22 \$');
      expect(plan.priceSuffix, '/mo');
      expect(plan.subPriceText, '264 \$/yr');
    });

    test('overrides price with RevenueCat store price string when available', () {
      final plan = SubscriptionPlanModel.defaultPlans.first.copyWith(
        storePriceString: '\$249.99',
      );
      expect(plan.mainPriceText, '\$249.99');
    });
  });

  group('SubscriptionStatusModel Tests', () {
    test('parses Endpoint B JSON from BACKEND_REVENUECAT_ISSUES.md accurately', () {
      final json = {
        "tier": "PRO",
        "status": "ACTIVE",
        "plan_id": "pro_yearly",
        "entitlement": "pro_access",
        "store": "APP_STORE",
        "is_trial": false,
        "will_renew": true,
        "current_period_start": "2026-10-01T00:00:00Z",
        "current_period_end": "2027-10-01T00:00:00Z",
        "cancelled_at": null,
        "billing_issue_detected_at": null,
        "management_url": "https://apps.apple.com/account/subscriptions"
      };

      final status = SubscriptionStatusModel.fromJson(json);

      expect(status.isPro, true);
      expect(status.isActive, true);
      expect(status.hasBillingIssue, false);
      expect(status.tier, 'PRO');
      expect(status.status, 'ACTIVE');
      expect(status.planId, 'pro_yearly');
      expect(status.entitlement, 'pro_access');
      expect(status.store, 'APP_STORE');
      expect(status.willRenew, true);
      expect(status.currentPeriodEnd, DateTime.parse("2027-10-01T00:00:00Z"));
      expect(status.managementUrl, 'https://apps.apple.com/account/subscriptions');
      expect(status.displayStatusLabel, 'Active (Auto-renews)');
    });

    test('handles Free user state correctly', () {
      final freeJson = {
        "tier": "FREE",
        "status": "NONE",
        "plan_id": null,
        "entitlement": null,
        "store": null,
        "is_trial": false,
        "will_renew": false,
        "current_period_start": null,
        "current_period_end": null,
        "cancelled_at": null,
        "billing_issue_detected_at": null,
        "management_url": null
      };

      final status = SubscriptionStatusModel.fromJson(freeJson);

      expect(status.isPro, false);
      expect(status.isActive, false);
      expect(status.displayStatusLabel, 'Free Plan');
    });

    test('detects billing issue status correctly', () {
      final issueJson = {
        "tier": "PRO",
        "status": "BILLING_ISSUE",
        "billing_issue_detected_at": "2026-10-25T12:00:00Z",
      };

      final status = SubscriptionStatusModel.fromJson(issueJson);

      expect(status.isPro, true);
      expect(status.hasBillingIssue, true);
      expect(status.displayStatusLabel, 'Billing Issue');
    });
  });

  group('Profile & Subscription Widget Tests', () {
    Widget buildTestWidget(Widget child) {
      return MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: ScreenUtilInit(
            designSize: const Size(390, 844),
            builder: (context, _) => Scaffold(body: SingleChildScrollView(child: child)),
          ),
        ),
      );
    }

    testWidgets('ProfileHeroCard shows Pro Member badge when subscriptionTier is PRO', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const ProfileHeroCard(
            name: 'Jane Doe',
            title: 'Angel Investor',
            investedAmount: '\$50,000',
            projectsCount: '5',
            subscriptionTier: 'PRO',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pro Member'), findsOneWidget);
      expect(find.text('Free Member'), findsNothing);
    });

    testWidgets('ProfileHeroCard shows Free Member badge when subscriptionTier is FREE', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const ProfileHeroCard(
            name: 'John Doe',
            title: 'Angel Investor',
            investedAmount: '\$0.00',
            projectsCount: '0',
            subscriptionTier: 'FREE',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Free Member'), findsOneWidget);
      expect(find.text('Pro Member'), findsNothing);
    });

    testWidgets('SubscriptionStatusBanner displays status and management url link', (tester) async {
      const status = SubscriptionStatusModel(
        tier: 'PRO',
        status: 'ACTIVE',
        willRenew: true,
        managementUrl: 'https://apps.apple.com/account/subscriptions',
      );

      await tester.pumpWidget(
        buildTestWidget(
          const SubscriptionStatusBanner(status: status),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Active (Auto-renews)'), findsOneWidget);
      expect(find.text('Manage Subscription'), findsOneWidget);
    });
  });
}
