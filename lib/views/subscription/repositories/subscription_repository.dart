import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/revenue_cat_service.dart';
import '../../../../core/services/storage_service.dart';
import '../models/subscription_plan_model.dart';
import '../models/subscription_status_model.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepositoryImpl(ref.watch(apiServiceProvider));
});

abstract class SubscriptionRepository {
  Future<List<SubscriptionPlanModel>> getPlans();
  Future<SubscriptionStatusModel> getMySubscription();
  Future<SubscriptionStatusModel?> syncSubscription({required String source});
  Future<String?> ensureRevenueCatUserLoggedIn();
}

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final ApiService _apiService;

  SubscriptionRepositoryImpl(this._apiService);

  @override
  Future<List<SubscriptionPlanModel>> getPlans() async {
    if (!RevenueCatService.isConfigured) {
      throw Exception('Purchases are unavailable right now.');
    }
    final offerings = await RevenueCatService.getOfferings();
    if (offerings == null) {
      throw Exception('Could not load plans. Check your connection.');
    }
    final yearly = RevenueCatService.findPackage(
      offerings: offerings,
      isYearly: true,
      preferredProductId: RevenueCatService.yearlyProductId,
    );
    final monthly = RevenueCatService.findPackage(
      offerings: offerings,
      isYearly: false,
      preferredProductId: RevenueCatService.monthlyProductId,
    );
    final plans = SubscriptionPlanModel.fromPackages(
      yearly: yearly,
      monthly: monthly,
    );
    if (plans.isEmpty) {
      throw Exception('No subscription plans are available yet.');
    }
    return plans;
  }

  @override
  Future<SubscriptionStatusModel> getMySubscription() async {
    try {
      final res = await _apiService.get(
        ApiEndpoints.subscriptionMe,
        requireAuth: true,
      );
      dynamic data = res.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }
      if (data is Map<String, dynamic>) {
        return SubscriptionStatusModel.fromJson(data);
      } else if (data is Map) {
        return SubscriptionStatusModel.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (_) {
      // Fallback: check /users/me/ subscription_tier + RevenueCat state
    }

    try {
      final userRes = await _apiService.get(
        ApiEndpoints.currentUser,
        requireAuth: true,
      );
      final raw = userRes.data is Map
          ? (userRes.data['data'] is Map ? userRes.data['data'] : userRes.data)
          : null;
      final tier = raw?['subscription_tier']?.toString().toUpperCase() ?? 'FREE';
      final isRcPro = await RevenueCatService.isProUser();
      final effectiveTier = isRcPro ? 'PRO' : tier;
      return SubscriptionStatusModel(
        tier: effectiveTier,
        status: effectiveTier == 'PRO' ? 'ACTIVE' : 'NONE',
      );
    } catch (_) {
      return SubscriptionStatusModel.free();
    }
  }

  @override
  Future<SubscriptionStatusModel?> syncSubscription({
    required String source,
  }) async {
    try {
      final res = await _apiService.post(
        ApiEndpoints.subscriptionSync,
        data: {'source': source},
        requireAuth: true,
      );
      dynamic data = res.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }
      if (data is Map<String, dynamic>) {
        return SubscriptionStatusModel.fromJson(data);
      } else if (data is Map) {
        return SubscriptionStatusModel.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      log('SubscriptionRepository: Sync endpoint failed: $e');
    }
    return await getMySubscription();
  }

  @override
  Future<String?> ensureRevenueCatUserLoggedIn() async {
    String? email = await StorageService.getUserEmail();
    if (email != null && email.isNotEmpty) {
      await RevenueCatService.logIn(email);
      return email;
    }

    try {
      final res = await _apiService.get(
        ApiEndpoints.currentUser,
        requireAuth: true,
      );
      dynamic data = res.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }
      final payload = data is Map
          ? (data['data'] is Map ? data['data'] : data)
          : null;
      final userEmail = payload?['email']?.toString().trim();
      if (userEmail != null && userEmail.isNotEmpty) {
        await StorageService.saveUserEmail(userEmail);
        await RevenueCatService.logIn(userEmail);
        return userEmail;
      }
    } catch (e) {
      log('SubscriptionRepository: Failed to load user email for RevenueCat: $e');
    }
    return null;
  }
}
