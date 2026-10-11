import 'dart:convert';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/discover_deal_model.dart';

abstract class DiscoverRepository {
  Future<List<DiscoverDealItem>> getDiscoverDeals();
  Future<List<String>> getCategories();
}

class DiscoverRepositoryImpl implements DiscoverRepository {
  final ApiService? _apiService;

  DiscoverRepositoryImpl([this._apiService]);

  @override
  Future<List<String>> getCategories() async {
    if (_apiService != null) {
      try {
        final response = await _apiService.get(
          ApiEndpoints.industries,
          requireAuth: true,
        );

        dynamic data = response.data;
        if (data is String) {
          try {
            data = jsonDecode(data);
          } catch (_) {}
        }

        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data is Map && data['data'] is List) {
          list = data['data'] as List;
        } else if (data is Map && data['results'] is List) {
          list = data['results'] as List;
        }

        if (list.isNotEmpty) {
          final categories = <String>["All"];
          for (final item in list) {
            final name = (item is Map ? item['name']?.toString() : null) ?? '';
            if (name.isNotEmpty && !categories.contains(name)) {
              categories.add(name);
            }
          }
          return categories;
        }
      } catch (_) {}
    }

    return const [
      "All",
      "Real Estate",
      "Tech",
      "Health",
      "Energy",
    ];
  }

  @override
  Future<List<DiscoverDealItem>> getDiscoverDeals() async {
    if (_apiService != null) {
      try {
        dynamic response;
        try {
          response = await _apiService.get(
            ApiEndpoints.discoverProjects,
            requireAuth: true,
          );
        } catch (_) {
          response = await _apiService.get(
            ApiEndpoints.projects,
            requireAuth: true,
          );
        }

        dynamic data = response.data;
        if (data is String) {
          try {
            data = jsonDecode(data);
          } catch (_) {}
        }

        List list = [];
        if (data is List) {
          list = data;
        } else if (data is Map) {
          if (data['data'] is Map && (data['data'] as Map)['results'] is List) {
            list = (data['data'] as Map)['results'] as List;
          } else if (data['data'] is List) {
            list = data['data'] as List;
          } else if (data['results'] is List) {
            list = data['results'] as List;
          }
        }

        if (list.isNotEmpty) {
          final deals = <DiscoverDealItem>[];
          for (final item in list.whereType<Map>()) {
            try {
              deals.add(
                DiscoverDealItem.fromJson(Map<String, dynamic>.from(item)),
              );
            } catch (_) {
              continue;
            }
          }
          if (deals.isNotEmpty) {
            return deals;
          }
        }
      } catch (_) {}
    }

    return [
      DiscoverDealItem(
        id: "deal_trending_1",
        title: "BioTech Diagnostics Gene Test",
        location: "Switzerland",
        category: "Health",
        imageUrl:
            "https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?q=80&w=600&auto=format&fit=crop",
        targetRaise: "\$3.2M",
        minInvestment: "\$10,000",
        targetRoi: "~ 26%",
        roiValue: 26.0,
        raiseValue: 3200000,
        fundedPercent: 0.82,
        daysLeft: 5,
        isTrending: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      DiscoverDealItem(
        id: "deal_trending_2",
        title: "Decentralized GPU Compute Farm",
        location: "Singapore",
        category: "Tech",
        imageUrl:
            "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?q=80&w=600&auto=format&fit=crop",
        targetRaise: "\$4.8M",
        minInvestment: "\$5,000",
        targetRoi: "~ 28%",
        roiValue: 28.0,
        raiseValue: 4800000,
        fundedPercent: 0.94,
        daysLeft: 2,
        isTrending: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      DiscoverDealItem(
        id: "deal_trending_3",
        title: "Urban Eco Apartments",
        location: "Canada",
        category: "Real Estate",
        imageUrl:
            "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?q=80&w=600&auto=format&fit=crop",
        targetRaise: "\$8.5M",
        minInvestment: "\$25,000",
        targetRoi: "~ 17%",
        roiValue: 17.0,
        raiseValue: 8500000,
        fundedPercent: 0.65,
        daysLeft: 12,
        isTrending: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      DiscoverDealItem(
        id: "deal_1",
        title: "Downtown Tech Hub",
        location: "United States",
        category: "Real Estate",
        imageUrl:
            "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=600&auto=format&fit=crop",
        targetRaise: "\$5.0M",
        minInvestment: "\$1,000",
        targetRoi: "~ 18%",
        roiValue: 18.0,
        raiseValue: 5000000,
        fundedPercent: 0.72,
        daysLeft: 18,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      DiscoverDealItem(
        id: "deal_2",
        title: "AI Logistics Platform",
        location: "United Kingdom",
        category: "Tech",
        imageUrl:
            "https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=600&auto=format&fit=crop",
        targetRaise: "\$1.2M",
        minInvestment: "\$1,000",
        targetRoi: "~ 25%",
        roiValue: 25.0,
        raiseValue: 1200000,
        fundedPercent: 0.88,
        daysLeft: 9,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      DiscoverDealItem(
        id: "deal_3",
        title: "EcoTech Solar Farm",
        location: "Australia",
        category: "Energy",
        imageUrl:
            "https://images.unsplash.com/photo-1509391365360-2e959784a276?q=80&w=600&auto=format&fit=crop",
        targetRaise: "\$2.5M",
        minInvestment: "\$1,000",
        targetRoi: "~ 12%",
        roiValue: 12.0,
        raiseValue: 2500000,
        fundedPercent: 0.54,
        daysLeft: 22,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      DiscoverDealItem(
        id: "deal_4",
        title: "Genomic Care Center",
        location: "Switzerland",
        category: "Health",
        imageUrl:
            "https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?q=80&w=600&auto=format&fit=crop",
        targetRaise: "\$6.5M",
        minInvestment: "\$2,500",
        targetRoi: "~ 21%",
        roiValue: 21.0,
        raiseValue: 6500000,
        fundedPercent: 0.68,
        daysLeft: 14,
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
      DiscoverDealItem(
        id: "deal_5",
        title: "Skyline Luxury Towers",
        location: "United States",
        category: "Real Estate",
        imageUrl:
            "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?q=80&w=600&auto=format&fit=crop",
        targetRaise: "\$20.0M",
        minInvestment: "\$5,000",
        targetRoi: "~ 16%",
        roiValue: 16.0,
        raiseValue: 20000000,
        fundedPercent: 0.45,
        daysLeft: 30,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }
}
