import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/discover_deal_model.dart';
import '../repositories/discover_repository.dart';

final discoverRepositoryProvider = Provider<DiscoverRepository>((ref) {
  return DiscoverRepositoryImpl();
});

class DiscoverState {
  final bool isLoading;
  final int selectedCategoryIndex;
  final String selectedSort;
  final String searchQuery;
  final Set<String> bookmarkedIds;
  final List<String> categories;
  final List<DiscoverDealItem> allDeals;

  const DiscoverState({
    this.isLoading = false,
    this.selectedCategoryIndex = 0,
    this.selectedSort = "Newest",
    this.searchQuery = '',
    this.bookmarkedIds = const {},
    this.categories = const [],
    this.allDeals = const [],
  });

  String get selectedCategory {
    if (categories.isEmpty || selectedCategoryIndex >= categories.length) {
      return "All";
    }
    return categories[selectedCategoryIndex];
  }

  List<DiscoverDealItem> get filteredAndSortedDeals {
    final cat = selectedCategory;

    var deals = allDeals.where((deal) {
      final matchesCat = cat == "All" || deal.category == cat;
      final q = searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          deal.title.toLowerCase().contains(q) ||
          deal.location.toLowerCase().contains(q) ||
          deal.category.toLowerCase().contains(q);
      return matchesCat && matchesSearch;
    }).toList();

    if (selectedSort == "Highest ROI") {
      deals.sort((a, b) => b.roiValue.compareTo(a.roiValue));
    } else if (selectedSort == "Target Raise") {
      deals.sort((a, b) => b.raiseValue.compareTo(a.raiseValue));
    } else {
      deals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return deals;
  }

  DiscoverState copyWith({
    bool? isLoading,
    int? selectedCategoryIndex,
    String? selectedSort,
    String? searchQuery,
    Set<String>? bookmarkedIds,
    List<String>? categories,
    List<DiscoverDealItem>? allDeals,
  }) {
    return DiscoverState(
      isLoading: isLoading ?? this.isLoading,
      selectedCategoryIndex:
          selectedCategoryIndex ?? this.selectedCategoryIndex,
      selectedSort: selectedSort ?? this.selectedSort,
      searchQuery: searchQuery ?? this.searchQuery,
      bookmarkedIds: bookmarkedIds ?? this.bookmarkedIds,
      categories: categories ?? this.categories,
      allDeals: allDeals ?? this.allDeals,
    );
  }
}

final discoverProvider =
    NotifierProvider<DiscoverNotifier, DiscoverState>(DiscoverNotifier.new);

class DiscoverNotifier extends Notifier<DiscoverState> {
  @override
  DiscoverState build() {
    loadDeals();
    return const DiscoverState(isLoading: true);
  }

  Future<void> loadDeals() async {
    final repo = ref.read(discoverRepositoryProvider);
    final categories = await repo.getCategories();
    final deals = await repo.getDiscoverDeals();

    state = state.copyWith(
      isLoading: false,
      categories: categories,
      allDeals: deals,
    );
  }

  void selectCategory(int index) {
    state = state.copyWith(selectedCategoryIndex: index);
  }

  void selectSort(String sort) {
    state = state.copyWith(selectedSort: sort);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleBookmark(String id) {
    final newSet = Set<String>.from(state.bookmarkedIds);
    if (newSet.contains(id)) {
      newSet.remove(id);
    } else {
      newSet.add(id);
    }
    state = state.copyWith(bookmarkedIds: newSet);
  }
}
