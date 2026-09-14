import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    await Future.delayed(const Duration(milliseconds: 1000));
    state = state.copyWith(isLoading: false);
    return true;
  }
}

final subscriptionProvider =
    NotifierProvider.autoDispose<SubscriptionNotifier, SubscriptionState>(
  SubscriptionNotifier.new,
);
