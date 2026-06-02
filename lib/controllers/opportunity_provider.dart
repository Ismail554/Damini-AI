import 'package:flutter/material.dart';
import '../data/models/opportunity_model.dart';
import '../data/repositories/opportunity_repository.dart';
import '../business/opportunity_service.dart';

class OpportunityProvider extends ChangeNotifier {
  final OpportunityService _service = OpportunityService(OpportunityRepositoryImpl());

  List<OpportunityModel> _opportunities = [];
  List<OpportunityModel> get opportunities => _service.filterByCategory(_opportunities, _selectedCategory);

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadOpportunities() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _opportunities = await _service.fetchAllOpportunities();
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> toggleInterest(String id) async {
    final index = _opportunities.indexWhere((op) => op.id == id);
    if (index == -1) return;

    final originalOp = _opportunities[index];
    final originalInterest = originalOp.hasExpressedInterest;

    // Optimistic UI update
    _opportunities[index] = originalOp.copyWith(hasExpressedInterest: !originalInterest);
    notifyListeners();

    try {
      await _service.toggleInterest(id, originalInterest);
    } catch (e) {
      // Revert if API fails
      _opportunities[index] = originalOp;
      notifyListeners();
    }
  }
}
