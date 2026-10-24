import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../core/services/revenue_cat_service.dart';
import '../models/subscription_feature_model.dart';

enum BillingCycle { yearly, monthly }

class SubscriptionState {
  final BillingCycle selectedCycle;
  final bool isLoading;
  final List<SubscriptionFeatureModel> features;

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
  });

  SubscriptionState copyWith({
    BillingCycle? selectedCycle,
    bool? isLoading,
    List<SubscriptionFeatureModel>? features,
  }) {
    return SubscriptionState(
      selectedCycle: selectedCycle ?? this.selectedCycle,
      isLoading: isLoading ?? this.isLoading,
      features: features ?? this.features,
    );
  }
}

class SubscriptionNotifier extends Notifier<SubscriptionState> {
  @override
  SubscriptionState build() => const SubscriptionState();

  void selectCycle(BillingCycle cycle) {
    state = state.copyWith(selectedCycle: cycle);
  }

  Future<bool> subscribe() async {
    state = state.copyWith(isLoading: true);
    try {
      if (RevenueCatService.isConfigured) {
        final offerings = await Purchases.getOfferings();
        final current = offerings.current;
        final package = state.selectedCycle == BillingCycle.yearly
            ? (current?.annual ?? current?.availablePackages.firstOrNull)
            : (current?.monthly ?? current?.availablePackages.firstOrNull);

        if (package != null) {
          final isPro = await RevenueCatService.purchasePackage(package);
          state = state.copyWith(isLoading: false);
          return isPro;
        }
      }
      // Fallback simulation when StoreKit / Play Billing sandbox offerings are not yet published
      await Future.delayed(const Duration(milliseconds: 1000));
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}

final subscriptionProvider =
    NotifierProvider.autoDispose<SubscriptionNotifier, SubscriptionState>(
  SubscriptionNotifier.new,
);
