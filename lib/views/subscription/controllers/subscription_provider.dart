import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/revenue_cat_service.dart';
import '../../investor/dashboard/controllers/investor_dashboard_provider.dart';
import '../../profile/controllers/investor_profile_provider.dart';
import '../../profile/personal_info/controllers/personal_info_provider.dart';
import '../../settings/controllers/settings_provider.dart';
import '../../sponsor/profile/controllers/sponsor_profile_provider.dart';
import '../models/subscription_feature_model.dart';
import '../models/subscription_plan_model.dart';
import '../models/subscription_status_model.dart';
import '../repositories/subscription_repository.dart';

enum BillingCycle { yearly, monthly }

class SubscriptionState {
  final BillingCycle selectedCycle;
  final bool isLoading;
  final List<SubscriptionFeatureModel> features;
  final List<SubscriptionPlanModel> plans;
  final SubscriptionStatusModel status;

  const SubscriptionState({
    this.selectedCycle = BillingCycle.yearly,
    this.isLoading = false,
    this.features = const [
      SubscriptionFeatureModel(title: "Basic search", isFree: true, isPro: true),
      SubscriptionFeatureModel(
        title: "Access to top AI models",
        isFree: false,
        isPro: true,
      ),
      SubscriptionFeatureModel(
        title: "Access to Computer",
        isFree: false,
        isPro: true,
      ),
      SubscriptionFeatureModel(
        title: "Access to deep research",
        isFree: false,
        isPro: true,
      ),
      SubscriptionFeatureModel(
        title: "Premium app connectors",
        isFree: false,
        isPro: true,
      ),
      SubscriptionFeatureModel(
        title: "More usage and memory",
        isFree: false,
        isPro: true,
      ),
    ],
    this.plans = const [],
    this.plansLoading = true,
    this.plansError,
    this.status = const SubscriptionStatusModel(),
  });

  final bool plansLoading;
  final String? plansError;

  bool get hasPlans => plans.isNotEmpty;

  SubscriptionPlanModel? get yearlyPlan =>
      plans.where((p) => p.isYearly).firstOrNull;

  SubscriptionPlanModel? get monthlyPlan =>
      plans.where((p) => !p.isYearly).firstOrNull;

  SubscriptionPlanModel? get selectedPlan {
    final preferred =
        selectedCycle == BillingCycle.yearly ? yearlyPlan : monthlyPlan;
    return preferred ?? plans.firstOrNull;
  }

  SubscriptionState copyWith({
    BillingCycle? selectedCycle,
    bool? isLoading,
    List<SubscriptionFeatureModel>? features,
    List<SubscriptionPlanModel>? plans,
    SubscriptionStatusModel? status,
    bool? plansLoading,
    Object? plansError = _keep,
  }) {
    return SubscriptionState(
      selectedCycle: selectedCycle ?? this.selectedCycle,
      isLoading: isLoading ?? this.isLoading,
      features: features ?? this.features,
      plans: plans ?? this.plans,
      plansLoading: plansLoading ?? this.plansLoading,
      plansError:
          identical(plansError, _keep) ? this.plansError : plansError as String?,
      status: status ?? this.status,
    );
  }
}

const Object _keep = Object();

class SubscriptionNotifier extends Notifier<SubscriptionState> {
  late final SubscriptionRepository _repository;

  @override
  SubscriptionState build() {
    _repository = ref.watch(subscriptionRepositoryProvider);
    Future.microtask(_init);
    return const SubscriptionState();
  }

  Future<void> _init() async {
    await Future.wait([loadPlans(), _loadStatus()]);
  }

  Future<void> _loadStatus() async {
    try {
      final status = await _repository.getMySubscription();
      state = state.copyWith(status: status);
    } catch (_) {}
  }

  /// Loads plans from RevenueCat offerings (also used for retry).
  Future<void> loadPlans() async {
    state = state.copyWith(plansLoading: true, plansError: null);
    try {
      await _repository.ensureRevenueCatUserLoggedIn();
      final plans = await _repository.getPlans();
      state = state.copyWith(plans: plans, plansLoading: false);
    } catch (e) {
      state = state.copyWith(
        plansLoading: false,
        plansError: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void selectCycle(BillingCycle cycle) {
    state = state.copyWith(selectedCycle: cycle);
  }

  Future<bool> subscribe() async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.ensureRevenueCatUserLoggedIn();
      if (!RevenueCatService.isConfigured) {
        throw Exception('Purchases are unavailable right now. Please try again later.');
      }

      final package = state.selectedPlan?.rcPackage;
      if (package == null) {
        throw Exception('The selected subscription package is not available in the store.');
      }

      final outcome = await RevenueCatService.purchasePackage(package);
      if (outcome.isCancelled) {
        state = state.copyWith(isLoading: false);
        return false;
      }
      if (!outcome.isSuccess) {
        throw Exception(outcome.errorMessage ?? 'Purchase could not be completed.');
      }

      final updatedStatus =
          await _repository.syncSubscription(source: 'purchase');
      _refreshRelatedProviders();
      state = state.copyWith(
        isLoading: false,
        status: updatedStatus ?? state.status,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<bool> restore() async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.ensureRevenueCatUserLoggedIn();
      final outcome = await RevenueCatService.restore();
      if (!outcome.isSuccess) {
        throw Exception(outcome.errorMessage ?? 'Could not restore purchases.');
      }

      if (outcome.hasActiveSubscription) {
        await _repository.syncSubscription(source: 'restore');
        _refreshRelatedProviders();
      }
      final status = await _repository.getMySubscription();
      state = state.copyWith(isLoading: false, status: status);
      return outcome.hasActiveSubscription || status.isPro;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// Called after a purchase made via the RevenueCat Paywall UI.
  Future<void> refreshAfterExternalPurchase() async {
    try {
      final updated = await _repository.syncSubscription(source: 'purchase');
      _refreshRelatedProviders();
      state = state.copyWith(
        status: updated ?? await _repository.getMySubscription(),
      );
    } catch (_) {}
  }

  void _refreshRelatedProviders() {
    ref.invalidate(settingsProvider);
    ref.invalidate(personalInfoProvider);
    ref.invalidate(investorProfileProvider);
    ref.invalidate(sponsorProfileProvider);
    ref.invalidate(investorDashboardProvider);
  }
}

final subscriptionProvider =
    NotifierProvider.autoDispose<SubscriptionNotifier, SubscriptionState>(
  SubscriptionNotifier.new,
);
