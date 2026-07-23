import '../models/opportunity_model.dart';
import '../repositories/opportunity_repository.dart';

class OpportunityService {
  final OpportunityRepository _repository;

  OpportunityService(this._repository);

  Future<List<OpportunityModel>> fetchAllOpportunities() async {
    return await _repository.getOpportunities();
  }

  List<OpportunityModel> filterByCategory(
      List<OpportunityModel> list, String category) {
    if (category == 'All') return list;
    return list
        .where((op) => op.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  Future<void> toggleInterest(String id, bool currentInterest) async {
    await _repository.saveInterest(id, !currentInterest);
  }
}
