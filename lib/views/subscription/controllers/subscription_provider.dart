import 'package:flutter/material.dart';
import '../models/subscription_feature_model.dart';

enum BillingCycle { yearly, monthly }

class SubscriptionProvider extends ChangeNotifier {
  BillingCycle _selectedCycle = BillingCycle.yearly;
  bool _isLoading = false;

  BillingCycle get selectedCycle => _selectedCycle;
  bool get isLoading => _isLoading;

  final List<SubscriptionFeatureModel> features = const [
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
  ];

  void selectCycle(BillingCycle cycle) {
    _selectedCycle = cycle;
    notifyListeners();
  }

  Future<bool> subscribe() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));

    _isLoading = false;
    notifyListeners();
    return true;
  }
}
