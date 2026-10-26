class SubscriptionStatusModel {
  final String tier;
  final String status;
  final String? planId;
  final String? entitlement;
  final String? store;
  final bool isTrial;
  final bool willRenew;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final DateTime? cancelledAt;
  final DateTime? billingIssueDetectedAt;
  final String? managementUrl;

  const SubscriptionStatusModel({
    this.tier = 'FREE',
    this.status = 'NONE',
    this.planId,
    this.entitlement,
    this.store,
    this.isTrial = false,
    this.willRenew = false,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.cancelledAt,
    this.billingIssueDetectedAt,
    this.managementUrl,
  });

  bool get isPro => tier.toUpperCase() == 'PRO';

  bool get isActive {
    final s = status.toUpperCase();
    return isPro && (s == 'ACTIVE' || s == 'GRACE_PERIOD' || s == 'CANCELLED');
  }

  bool get hasBillingIssue =>
      status.toUpperCase() == 'BILLING_ISSUE' || billingIssueDetectedAt != null;

  String get displayStatusLabel {
    if (!isPro) return 'Free Plan';
    final s = status.toUpperCase();
    switch (s) {
      case 'ACTIVE':
        return willRenew ? 'Active (Auto-renews)' : 'Active (Expires soon)';
      case 'CANCELLED':
        return 'Cancelled (Active until end of period)';
      case 'GRACE_PERIOD':
        return 'Grace Period';
      case 'BILLING_ISSUE':
        return 'Billing Issue';
      case 'EXPIRED':
        return 'Expired';
      default:
        return 'Pro Plan';
    }
  }

  factory SubscriptionStatusModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return SubscriptionStatusModel(
      tier: (data['tier'] ?? data['subscription_tier'] ?? 'FREE')
          .toString()
          .toUpperCase(),
      status: (data['status'] ?? 'NONE').toString().toUpperCase(),
      planId: data['plan_id']?.toString(),
      entitlement: data['entitlement']?.toString(),
      store: data['store']?.toString(),
      isTrial: data['is_trial'] == true,
      willRenew: data['will_renew'] == true,
      currentPeriodStart: parseDate(data['current_period_start']),
      currentPeriodEnd: parseDate(data['current_period_end']),
      cancelledAt: parseDate(data['cancelled_at']),
      billingIssueDetectedAt: parseDate(data['billing_issue_detected_at']),
      managementUrl: data['management_url']?.toString(),
    );
  }

  factory SubscriptionStatusModel.free() => const SubscriptionStatusModel();
}
