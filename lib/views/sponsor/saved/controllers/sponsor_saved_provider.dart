import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_error_handler.dart';
import '../models/sponsor_saved_profile_model.dart';
import '../models/sponsor_saved_project_model.dart';
import '../repositories/sponsor_saved_repository.dart';

enum SavedTab { projects, profiles }

class SponsorSavedState {
  final SavedTab currentTab;
  final String selectedSort;
  final String selectedFilter;
  final String searchQuery;
  final bool isLoadingProjects;
  final bool isRefreshingProjects;
  final String? projectsError;
  final int totalProjectsCount;
  final List<SponsorSavedProjectModel> rawProjects;
  final List<SponsorSavedProjectModel> projects;
  final List<SponsorSavedProfileModel> profiles;

  const SponsorSavedState({
    this.currentTab = SavedTab.projects,
    this.selectedSort = "Newest",
    this.selectedFilter = "All",
    this.searchQuery = "",
    this.isLoadingProjects = false,
    this.isRefreshingProjects = false,
    this.projectsError,
    this.totalProjectsCount = 0,
    this.rawProjects = const [],
    required this.projects,
    required this.profiles,
  });

  int get resultsCount {
    if (currentTab == SavedTab.projects) {
      final isFiltered =
          (selectedFilter.toLowerCase() != 'all') || searchQuery.isNotEmpty;
      if (isFiltered) {
        return projects.length;
      }
      return totalProjectsCount > 0 ? totalProjectsCount : projects.length;
    } else {
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        return profiles
            .where(
              (p) =>
                  p.name.toLowerCase().contains(q) ||
                  p.title.toLowerCase().contains(q) ||
                  p.company.toLowerCase().contains(q),
            )
            .length;
      }
      return profiles.length;
    }
  }

  SponsorSavedState copyWith({
    SavedTab? currentTab,
    String? selectedSort,
    String? selectedFilter,
    String? searchQuery,
    bool? isLoadingProjects,
    bool? isRefreshingProjects,
    String? projectsError,
    bool clearProjectsError = false,
    int? totalProjectsCount,
    List<SponsorSavedProjectModel>? rawProjects,
    List<SponsorSavedProjectModel>? projects,
    List<SponsorSavedProfileModel>? profiles,
  }) {
    return SponsorSavedState(
      currentTab: currentTab ?? this.currentTab,
      selectedSort: selectedSort ?? this.selectedSort,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingProjects: isLoadingProjects ?? this.isLoadingProjects,
      isRefreshingProjects: isRefreshingProjects ?? this.isRefreshingProjects,
      projectsError:
          clearProjectsError ? null : (projectsError ?? this.projectsError),
      totalProjectsCount: totalProjectsCount ?? this.totalProjectsCount,
      rawProjects: rawProjects ?? this.rawProjects,
      projects: projects ?? this.projects,
      profiles: profiles ?? this.profiles,
    );
  }
}

class SponsorSavedNotifier extends Notifier<SponsorSavedState> {
  late final SponsorSavedRepository _repository;
  Timer? _debounceTimer;

  @override
  SponsorSavedState build() {
    _repository = ref.watch(sponsorSavedRepositoryProvider);

    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    // Initial fetch of saved projects
    Future.microtask(() => loadSavedProjects());

    return SponsorSavedState(
      isLoadingProjects: true,
      rawProjects: const [],
      projects: const [],
      profiles: SponsorSavedProfileModel.mockList(),
    );
  }

  void selectTab(SavedTab tab) {
    state = state.copyWith(
      currentTab: tab,
      selectedSort: "Newest",
      selectedFilter: "All",
    );
    _applyFilterAndSort();
  }

  void setFilter(String filter) {
    if (state.selectedFilter == filter) return;
    state = state.copyWith(selectedFilter: filter);
    _applyFilterAndSort();
    if (state.currentTab == SavedTab.projects) {
      loadSavedProjects(status: filter);
    }
  }

  void setSortOption(String sort) {
    if (state.selectedSort == sort) return;
    state = state.copyWith(selectedSort: sort);
    _applyFilterAndSort();
    if (state.currentTab == SavedTab.projects) {
      loadSavedProjects(ordering: _getBackendOrdering(sort));
    }
  }

  /// Debounced search trigger (450ms)
  void onSearchChanged(String query) {
    state = state.copyWith(searchQuery: query);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 450), () {
      loadSavedProjects(search: query);
    });
  }

  /// Clear search immediately without waiting for debouncer
  void clearSearch() {
    _debounceTimer?.cancel();
    state = state.copyWith(searchQuery: '');
    loadSavedProjects(search: '');
  }

  /// Load saved projects from backend API
  Future<void> loadSavedProjects({
    String? search,
    String? ordering,
    String? status,
    bool isRefresh = false,
  }) async {
    final query = search ?? state.searchQuery;
    final order = ordering ?? _getBackendOrdering(state.selectedSort);
    final stat = status ?? _getBackendStatus(state.selectedFilter);

    if (isRefresh) {
      state = state.copyWith(
        isRefreshingProjects: true,
        clearProjectsError: true,
      );
    } else if (state.rawProjects.isEmpty) {
      state = state.copyWith(
        isLoadingProjects: true,
        clearProjectsError: true,
      );
    }

    try {
      final response = await _repository.fetchSavedProjects(
        search: query,
        ordering: order,
        status: stat,
      );
      state = state.copyWith(
        isLoadingProjects: false,
        isRefreshingProjects: false,
        rawProjects: response.results,
        totalProjectsCount: response.count,
        clearProjectsError: true,
      );
      _applyFilterAndSort();
    } catch (e) {
      final errorMessage = e is AppException
          ? e.message
          : 'Unable to load saved projects. Please try again.';

      state = state.copyWith(
        isLoadingProjects: false,
        isRefreshingProjects: false,
        projectsError: state.rawProjects.isEmpty ? errorMessage : null,
      );
    }
  }

  Future<void> refresh() async {
    await loadSavedProjects(isRefresh: true);
  }

  /// Notification hook called when any project bookmark changes across the app
  Future<void> onProjectBookmarkToggled({
    required String projectId,
    required bool isSaved,
  }) async {
    // If it was removed, optimistically filter it out immediately
    if (!isSaved) {
      final updatedRaw =
          state.rawProjects.where((p) => p.id != projectId).toList();
      state = state.copyWith(
        rawProjects: updatedRaw,
        totalProjectsCount: state.totalProjectsCount > 0
            ? state.totalProjectsCount - 1
            : updatedRaw.length,
      );
      _applyFilterAndSort();
    }
    // Re-sync with backend GET /api/v1/projects/saved/
    await refresh();
  }

  Future<void> removeProject(String id) async {
    final prevRaw = state.rawProjects;
    final prevProjects = state.projects;
    final prevCount = state.totalProjectsCount;

    // Optimistically remove from state
    final updatedRaw = prevRaw.where((p) => p.id != id).toList();
    state = state.copyWith(
      rawProjects: updatedRaw,
      totalProjectsCount:
          prevCount > 0 ? prevCount - 1 : updatedRaw.length,
    );
    _applyFilterAndSort();

    try {
      await _repository.toggleSaveProject(id);
    } catch (e) {
      // Revert state on failure
      state = state.copyWith(
        rawProjects: prevRaw,
        projects: prevProjects,
        totalProjectsCount: prevCount,
      );
      rethrow;
    }
  }

  void removeProfile(String id) {
    state = state.copyWith(
      profiles: state.profiles.where((p) => p.id != id).toList(),
    );
  }

  void _applyFilterAndSort() {
    if (state.currentTab == SavedTab.projects) {
      // 1. Filter by status
      List<SponsorSavedProjectModel> filtered =
          List<SponsorSavedProjectModel>.from(state.rawProjects);

      final filter = state.selectedFilter.toLowerCase();
      if (filter != 'all' && filter.isNotEmpty) {
        filtered = filtered.where((p) {
          final s = p.status.toUpperCase();
          if (filter == 'active') {
            return s == 'ACTIVE' || s == 'IN_PROGRESS';
          } else if (filter == 'completed') {
            return s == 'COMPLETED';
          } else if (filter == 'terminated') {
            return s == 'TERMINATED' || s == 'CANCELLED';
          }
          return s.toLowerCase() == filter;
        }).toList();
      }

      // 2. Sort projects
      if (state.selectedSort == 'Highest ROI') {
        filtered.sort(
          (a, b) =>
              _parsePercent(b.targetRoi).compareTo(_parsePercent(a.targetRoi)),
        );
      } else if (state.selectedSort == 'Target Raise: High to Low') {
        filtered.sort(
          (a, b) => _parseAmount(b.targetRaise, b.fundingGoal)
              .compareTo(_parseAmount(a.targetRaise, a.fundingGoal)),
        );
      } else if (state.selectedSort == 'Target Raise: Low to High') {
        filtered.sort(
          (a, b) => _parseAmount(a.targetRaise, a.fundingGoal)
              .compareTo(_parseAmount(b.targetRaise, b.fundingGoal)),
        );
      } else if (state.selectedSort == 'Oldest') {
        filtered.sort((a, b) {
          if (a.createdAt != null && b.createdAt != null) {
            return a.createdAt!.compareTo(b.createdAt!);
          }
          final aId = int.tryParse(a.id) ?? 0;
          final bId = int.tryParse(b.id) ?? 0;
          if (aId > 0 && bId > 0) return aId.compareTo(bId);
          return a.id.compareTo(b.id);
        });
      } else {
        // Newest
        filtered.sort((a, b) {
          if (a.createdAt != null && b.createdAt != null) {
            return b.createdAt!.compareTo(a.createdAt!);
          }
          final aId = int.tryParse(a.id) ?? 0;
          final bId = int.tryParse(b.id) ?? 0;
          if (aId > 0 && bId > 0) return bId.compareTo(aId);
          return b.id.compareTo(a.id);
        });
      }
      state = state.copyWith(projects: filtered);
    } else {
      final sortedProfiles =
          List<SponsorSavedProfileModel>.from(state.profiles);
      if (state.selectedSort == 'Name: A to Z') {
        sortedProfiles.sort((a, b) => a.name.compareTo(b.name));
      } else if (state.selectedSort == 'Name: Z to A') {
        sortedProfiles.sort((a, b) => b.name.compareTo(a.name));
      } else if (state.selectedSort == 'Oldest') {
        sortedProfiles.sort((a, b) => b.id.compareTo(a.id));
      } else {
        sortedProfiles.sort((a, b) => a.id.compareTo(b.id)); // Newest
      }
      state = state.copyWith(profiles: sortedProfiles);
    }
  }

  String? _getBackendOrdering(String sort) {
    switch (sort) {
      case 'Oldest':
        return 'created_at';
      case 'Highest ROI':
        return '-target_roi';
      case 'Target Raise: High to Low':
        return '-funding_goal';
      case 'Target Raise: Low to High':
        return 'funding_goal';
      case 'Newest':
      default:
        return '-created_at';
    }
  }

  String? _getBackendStatus(String filter) {
    if (filter.isEmpty || filter.toLowerCase() == 'all') return null;
    return filter.toUpperCase();
  }

  static double _parseAmount(String val, [String? rawFallback]) {
    if (rawFallback != null && rawFallback.isNotEmpty) {
      final numVal = double.tryParse(rawFallback);
      if (numVal != null && numVal > 0) return numVal;
    }
    String clean = val.replaceAll('\$', '').replaceAll(',', '').trim();
    double multiplier = 1.0;
    if (clean.toLowerCase().endsWith('b')) {
      multiplier = 1000000000.0;
      clean = clean.substring(0, clean.length - 1);
    } else if (clean.toLowerCase().endsWith('m')) {
      multiplier = 1000000.0;
      clean = clean.substring(0, clean.length - 1);
    } else if (clean.toLowerCase().endsWith('k')) {
      multiplier = 1000.0;
      clean = clean.substring(0, clean.length - 1);
    }
    return (double.tryParse(clean) ?? 0.0) * multiplier;
  }

  static double _parsePercent(String val) {
    String clean = val.replaceAll('%', '').replaceAll('+', '').trim();
    return double.tryParse(clean) ?? 0.0;
  }
}

final sponsorSavedProvider =
    NotifierProvider<SponsorSavedNotifier, SponsorSavedState>(
  SponsorSavedNotifier.new,
);
