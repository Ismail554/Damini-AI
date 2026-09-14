import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/investor_dashboard_models.dart';
import '../repositories/investor_dashboard_repository.dart';

final investorDashboardRepositoryProvider =
    Provider<InvestorDashboardRepository>((ref) {
  return InvestorDashboardRepositoryImpl();
});

class InvestorDashboardState {
  final bool isLoading;
  final int selectedCategoryIndex;
  final String searchQuery;
  final List<DashboardCategoryModel> categories;
  final List<InvestorBannerModel> banners;
  final List<FeaturedOpportunityModel> featuredOpportunities;
  final List<TrendingProjectModel> trendingProjects;

  const InvestorDashboardState({
    this.isLoading = false,
    this.selectedCategoryIndex = 0,
    this.searchQuery = '',
    this.categories = const [],
    this.banners = const [],
    this.featuredOpportunities = const [],
    this.trendingProjects = const [],
  });

  String get selectedCategoryLabel {
    if (categories.isEmpty || selectedCategoryIndex >= categories.length) {
      return "All";
    }
    return categories[selectedCategoryIndex].label;
  }

  List<FeaturedOpportunityModel> get filteredFeatured {
    final cat = selectedCategoryLabel;
    return featuredOpportunities.where((item) {
      final matchesCategory = cat == "All" || item.category == cat;
      final matchesSearch = searchQuery.isEmpty ||
          item.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.location.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<TrendingProjectModel> get filteredTrending {
    final cat = selectedCategoryLabel;
    return trendingProjects.where((item) {
      final matchesCategory = cat == "All" || item.category == cat;
      final matchesSearch = searchQuery.isEmpty ||
          item.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.location.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  InvestorDashboardState copyWith({
    bool? isLoading,
    int? selectedCategoryIndex,
    String? searchQuery,
    List<DashboardCategoryModel>? categories,
    List<InvestorBannerModel>? banners,
    List<FeaturedOpportunityModel>? featuredOpportunities,
    List<TrendingProjectModel>? trendingProjects,
  }) {
    return InvestorDashboardState(
      isLoading: isLoading ?? this.isLoading,
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      categories: categories ?? this.categories,
      banners: banners ?? this.banners,
      featuredOpportunities: featuredOpportunities ?? this.featuredOpportunities,
      trendingProjects: trendingProjects ?? this.trendingProjects,
    );
  }
}

final investorDashboardProvider =
    NotifierProvider<InvestorDashboardNotifier, InvestorDashboardState>(
  InvestorDashboardNotifier.new,
);

class InvestorDashboardNotifier extends Notifier<InvestorDashboardState> {
  @override
  InvestorDashboardState build() {
    loadDashboardData();
    return const InvestorDashboardState(isLoading: true);
  }

  Future<void> loadDashboardData() async {
    final repo = ref.read(investorDashboardRepositoryProvider);
    final categories = await repo.getCategories();
    final banners = await repo.getBanners();
    final featured = await repo.getFeaturedOpportunities();
    final trending = await repo.getTrendingProjects();

    state = state.copyWith(
      isLoading: false,
      categories: categories,
      banners: banners,
      featuredOpportunities: featured,
      trendingProjects: trending,
    );
  }

  void selectCategory(int index) {
    state = state.copyWith(selectedCategoryIndex: index);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}
