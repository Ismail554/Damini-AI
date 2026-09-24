import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/investor_dashboard_models.dart';
import '../repositories/investor_dashboard_repository.dart';

class InvestorDashboardState {
  final bool isLoading;
  final bool isRefreshing;
  final InvestorUserProfile? userProfile;
  final int selectedCategoryIndex;
  final String searchQuery;
  final List<DashboardCategoryModel> categories;
  final List<InvestorBannerModel> banners;
  final List<FeaturedOpportunityModel> featuredOpportunities;
  final List<TrendingProjectModel> trendingProjects;

  const InvestorDashboardState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.userProfile,
    this.selectedCategoryIndex = 0,
    this.searchQuery = '',
    this.categories = const [],
    this.banners = const [],
    this.featuredOpportunities = const [],
    this.trendingProjects = const [],
  });

  String get greetingName {
    if (userProfile != null && userProfile!.fullName.isNotEmpty) {
      return userProfile!.fullName;
    }
    return 'Investor';
  }

  String? get profilePhoto => userProfile?.profilePhoto;

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
    bool? isRefreshing,
    InvestorUserProfile? userProfile,
    int? selectedCategoryIndex,
    String? searchQuery,
    List<DashboardCategoryModel>? categories,
    List<InvestorBannerModel>? banners,
    List<FeaturedOpportunityModel>? featuredOpportunities,
    List<TrendingProjectModel>? trendingProjects,
  }) {
    return InvestorDashboardState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      userProfile: userProfile ?? this.userProfile,
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
  late final InvestorDashboardRepository _repository;

  @override
  InvestorDashboardState build() {
    _repository = ref.watch(investorDashboardRepositoryProvider);
    Future.microtask(() => loadDashboardData());
    return const InvestorDashboardState(isLoading: true);
  }

  Future<void> loadDashboardData({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(isRefreshing: true);
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final results = await Future.wait([
        _repository.getUserProfile(),
        _repository.getCategories(),
        _repository.getBanners(),
        _repository.getFeaturedOpportunities(),
        _repository.getTrendingProjects(),
      ]);

      final profile = results[0] as InvestorUserProfile;
      final categories = results[1] as List<DashboardCategoryModel>;
      final banners = results[2] as List<InvestorBannerModel>;
      final featured = results[3] as List<FeaturedOpportunityModel>;
      final trending = results[4] as List<TrendingProjectModel>;

      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        userProfile: profile,
        categories: categories,
        banners: banners,
        featuredOpportunities: featured,
        trendingProjects: trending,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, isRefreshing: false);
    }
  }

  Future<void> refresh() async {
    await loadDashboardData(isRefresh: true);
  }

  void selectCategory(int index) {
    state = state.copyWith(selectedCategoryIndex: index);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}
