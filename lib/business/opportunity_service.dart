import '../data/models/opportunity_model.dart';
import '../data/repositories/opportunity_repository.dart';

class OpportunityService {
  final OpportunityRepository _repository;

  OpportunityService(this._repository);

  Future<List<OpportunityModel>> fetchAllOpportunities() async {
    return await _repository.getOpportunities();
  }

  List<OpportunityModel> filterByCategory(List<OpportunityModel> opportunities, String category) {
    if (category.toLowerCase() == 'all') {
      return opportunities;
    }
    return opportunities.where((op) => op.category.toLowerCase() == category.toLowerCase()).toList();
  }

  Future<void> toggleInterest(String id, bool currentStatus) async {
    await _repository.saveInterest(id, !currentStatus);
  }
}
