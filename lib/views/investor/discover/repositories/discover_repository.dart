import '../models/discover_deal_model.dart';

abstract class DiscoverRepository {
  Future<List<DiscoverDealItem>> getDiscoverDeals();
  Future<List<String>> getCategories();
}

class DiscoverRepositoryImpl implements DiscoverRepository {
  @override
  Future<List<String>> getCategories() async {
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
    return [
      DiscoverDealItem(
        id: "deal_1",
        title: "Downtown Tech Hub",
        location: "United States",
        category: "Real Estate",
        imageUrl:
            "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=600&auto=format&fit=crop",
        targetRaise: "\$5.0M",
        minInvestment: "\$1000",
        targetRoi: "~ 18%",
        roiValue: 18.0,
        raiseValue: 5000000,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      DiscoverDealItem(
        id: "deal_2",
        title: "AI Logistics Platform",
        location: "United Kingdom",
        category: "Tech",
        imageUrl:
            "https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=600&auto=format&fit=crop",
        targetRaise: "\$1.2M",
        minInvestment: "\$1000",
        targetRoi: "~ 25%",
        roiValue: 25.0,
        raiseValue: 1200000,
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
        minInvestment: "\$1000",
        targetRoi: "~ 12%",
        roiValue: 12.0,
        raiseValue: 2500000,
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
        minInvestment: "\$2500",
        targetRoi: "~ 21%",
        roiValue: 21.0,
        raiseValue: 6500000,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      DiscoverDealItem(
        id: "deal_5",
        title: "Skyline Luxury Towers",
        location: "United States",
        category: "Real Estate",
        imageUrl:
            "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?q=80&w=600&auto=format&fit=crop",
        targetRaise: "\$20.0M",
        minInvestment: "\$5000",
        targetRoi: "~ 16%",
        roiValue: 16.0,
        raiseValue: 20000000,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];
  }
}
