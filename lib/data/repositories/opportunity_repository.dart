import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/connectivity_service.dart';
import '../models/opportunity_model.dart';

abstract class OpportunityRepository {
  Future<List<OpportunityModel>> getOpportunities();
  Future<void> saveInterest(String id, bool hasInterest);
}

class OpportunityRepositoryImpl implements OpportunityRepository {
  static const String _interestsKey = 'expressed_interests';

  final List<OpportunityModel> _mockOpportunities = [
    OpportunityModel(
      id: "1",
      title: "Lagos Mixed-Use Devel...",
      location: "Lagos, Nigeria",
      logoText: "N",
      badgeText: "Hot",
      minEntry: 2500,
      targetReturn: "22% p.a.",
      durationMonths: 36,
      fundedPercentage: 68.0,
      hasExpressedInterest: false,
      category: "Real Estate",
    ),
    OpportunityModel(
      id: "2",
      title: "Nairobi Fintech Seed Round",
      location: "Nairobi, Kenya",
      logoText: "a",
      badgeText: "New",
      minEntry: 1000,
      targetReturn: "35% p.a.",
      durationMonths: 24,
      fundedPercentage: 30.0,
      hasExpressedInterest: false,
      category: "Tech",
    ),
    OpportunityModel(
      id: "3",
      title: "Cocoa Farm Aggregator",
      location: "Kumasi, Ghana",
      logoText: "c",
      badgeText: "Stable",
      minEntry: 500,
      targetReturn: "18% p.a.",
      durationMonths: 12,
      fundedPercentage: 85.0,
      hasExpressedInterest: false,
      category: "Agri",
    ),
    OpportunityModel(
      id: "4",
      title: "Greenhouse Tech Hub",
      location: "Kigali, Rwanda",
      logoText: "g",
      badgeText: "Hot",
      minEntry: 1500,
      targetReturn: "20% p.a.",
      durationMonths: 18,
      fundedPercentage: 45.0,
      hasExpressedInterest: false,
      category: "Agri",
    ),
  ];

  @override
  Future<List<OpportunityModel>> getOpportunities() async {
    // Connectivity Check
    final isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw Exception("No internet connection");
    }

    // Mock API Delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Load persisted interest settings
    final prefs = await SharedPreferences.getInstance();
    final List<String> interestedIds = prefs.getStringList(_interestsKey) ?? [];

    return _mockOpportunities.map((op) {
      return op.copyWith(
        hasExpressedInterest: interestedIds.contains(op.id),
      );
    }).toList();
  }

  @override
  Future<void> saveInterest(String id, bool hasInterest) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> interestedIds = prefs.getStringList(_interestsKey) ?? [];

    if (hasInterest) {
      if (!interestedIds.contains(id)) {
        interestedIds.add(id);
      }
    } else {
      interestedIds.remove(id);
    }

    await prefs.setStringList(_interestsKey, interestedIds);
  }
}
