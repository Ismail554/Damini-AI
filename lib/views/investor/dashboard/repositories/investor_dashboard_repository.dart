import 'package:flutter/material.dart';
import '../models/investor_dashboard_models.dart';

abstract class InvestorDashboardRepository {
  Future<List<DashboardCategoryModel>> getCategories();
  Future<List<InvestorBannerModel>> getBanners();
  Future<List<FeaturedOpportunityModel>> getFeaturedOpportunities();
  Future<List<TrendingProjectModel>> getTrendingProjects();
}

class InvestorDashboardRepositoryImpl implements InvestorDashboardRepository {
  @override
  Future<List<DashboardCategoryModel>> getCategories() async {
    return const [
      DashboardCategoryModel(label: "All", icon: Icons.grid_view_rounded),
      DashboardCategoryModel(label: "Tech", icon: Icons.memory_rounded),
      DashboardCategoryModel(label: "Real Estate", icon: Icons.home_work_outlined),
      DashboardCategoryModel(label: "Health", icon: Icons.favorite_outline_rounded),
      DashboardCategoryModel(label: "Energy", icon: Icons.bolt_rounded),
    ];
  }

  @override
  Future<List<InvestorBannerModel>> getBanners() async {
    return const [
      InvestorBannerModel(
        title: "Exclusive Tech Seed Rounds",
        subtitle: "Direct co-investment opportunities with verified lead syndicates.",
        tag: "High Yield",
        bgGradient: [Color(0xFF0F1E2E), Color(0xFF162A3D)],
        actionText: "Explore Rounds",
      ),
      InvestorBannerModel(
        title: "Prime Commercial Real Estate",
        subtitle: "Institutional grade assets structured for steady dividend yields.",
        tag: "Featured",
        bgGradient: [Color(0xFF1E162D), Color(0xFF2A1C3D)],
        actionText: "View Assets",
      ),
      InvestorBannerModel(
        title: "Clean Energy Infrastructure",
        subtitle: "Tax-advantaged sustainable utilities investments across Europe.",
        tag: "ESG Impact",
        bgGradient: [Color(0xFF13281E), Color(0xFF1B3D2B)],
        actionText: "Learn More",
      ),
    ];
  }

  @override
  Future<List<FeaturedOpportunityModel>> getFeaturedOpportunities() async {
    return const [
      FeaturedOpportunityModel(
        title: "Downtown Tech Hub",
        location: "United States",
        category: "Real Estate",
        imageUrl:
            "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=400&auto=format&fit=crop",
        targetRaise: "\$5.0M",
        targetRoi: "~ 18%",
      ),
      FeaturedOpportunityModel(
        title: "AI Logistics Platform",
        location: "United Kingdom",
        category: "Tech",
        imageUrl:
            "https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=400&auto=format&fit=crop",
        targetRaise: "\$1.2M",
        targetRoi: "~ 24%",
      ),
      FeaturedOpportunityModel(
        title: "Cyber Security Infra",
        location: "United States",
        category: "Tech",
        imageUrl:
            "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?q=80&w=400&auto=format&fit=crop",
        targetRaise: "\$3.5M",
        targetRoi: "~ 22%",
      ),
      FeaturedOpportunityModel(
        title: "Solar Grid Phase II",
        location: "Germany",
        category: "Energy",
        imageUrl:
            "https://images.unsplash.com/photo-1509391365360-2e959784a276?q=80&w=400&auto=format&fit=crop",
        targetRaise: "\$8.0M",
        targetRoi: "~ 14%",
      ),
    ];
  }

  @override
  Future<List<TrendingProjectModel>> getTrendingProjects() async {
    return const [
      TrendingProjectModel(
        title: "BioTech Diagnostics Gene Test",
        location: "Switzerland",
        category: "Health",
        imageUrl:
            "https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?q=80&w=400&auto=format&fit=crop",
        fundedPercent: 0.82,
        minInvestment: "\$10,000",
        daysLeft: 5,
      ),
      TrendingProjectModel(
        title: "Urban Eco Apartments",
        location: "Canada",
        category: "Real Estate",
        imageUrl:
            "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?q=80&w=400&auto=format&fit=crop",
        fundedPercent: 0.65,
        minInvestment: "\$25,000",
        daysLeft: 12,
      ),
      TrendingProjectModel(
        title: "Decentralized GPU Compute Farm",
        location: "Singapore",
        category: "Tech",
        imageUrl:
            "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?q=80&w=400&auto=format&fit=crop",
        fundedPercent: 0.94,
        minInvestment: "\$5,000",
        daysLeft: 2,
      ),
    ];
  }
}
