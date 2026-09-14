import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sponsor_saved_profile_model.dart';
import '../models/sponsor_saved_project_model.dart';

enum SavedTab { projects, profiles }

class SponsorSavedState {
  final SavedTab currentTab;
  final String selectedSort;
  final List<SponsorSavedProjectModel> projects;
  final List<SponsorSavedProfileModel> profiles;

  const SponsorSavedState({
    this.currentTab = SavedTab.projects,
    this.selectedSort = "Newest",
    required this.projects,
    required this.profiles,
  });

  int get resultsCount =>
      currentTab == SavedTab.projects ? projects.length : profiles.length;

  SponsorSavedState copyWith({
    SavedTab? currentTab,
    String? selectedSort,
    List<SponsorSavedProjectModel>? projects,
    List<SponsorSavedProfileModel>? profiles,
  }) {
    return SponsorSavedState(
      currentTab: currentTab ?? this.currentTab,
      selectedSort: selectedSort ?? this.selectedSort,
      projects: projects ?? this.projects,
      profiles: profiles ?? this.profiles,
    );
  }
}

class SponsorSavedNotifier extends Notifier<SponsorSavedState> {
  @override
  SponsorSavedState build() {
    return SponsorSavedState(
      projects: SponsorSavedProjectModel.mockList(),
      profiles: SponsorSavedProfileModel.mockList(),
    );
  }

  void selectTab(SavedTab tab) {
    state = state.copyWith(
      currentTab: tab,
      selectedSort: "Newest",
    );
    _applySort();
  }

  void setSortOption(String sort) {
    if (state.selectedSort == sort) return;
    state = state.copyWith(selectedSort: sort);
    _applySort();
  }

  void removeProject(String id) {
    state = state.copyWith(
      projects: state.projects.where((p) => p.id != id).toList(),
    );
  }

  void removeProfile(String id) {
    state = state.copyWith(
      profiles: state.profiles.where((p) => p.id != id).toList(),
    );
  }

  void _applySort() {
    if (state.currentTab == SavedTab.projects) {
      final sortedProjects = List<SponsorSavedProjectModel>.from(state.projects);
      if (state.selectedSort == 'Highest ROI') {
        sortedProjects.sort(
          (a, b) =>
              _parsePercent(b.targetRoi).compareTo(_parsePercent(a.targetRoi)),
        );
      } else if (state.selectedSort == 'Target Raise: High to Low') {
        sortedProjects.sort(
          (a, b) => _parseAmount(b.targetRaise)
              .compareTo(_parseAmount(a.targetRaise)),
        );
      } else if (state.selectedSort == 'Target Raise: Low to High') {
        sortedProjects.sort(
          (a, b) => _parseAmount(a.targetRaise)
              .compareTo(_parseAmount(b.targetRaise)),
        );
      } else if (state.selectedSort == 'Oldest') {
        sortedProjects.sort((a, b) => b.id.compareTo(a.id));
      } else {
        sortedProjects.sort((a, b) => a.id.compareTo(b.id)); // Newest
      }
      state = state.copyWith(projects: sortedProjects);
    } else {
      final sortedProfiles = List<SponsorSavedProfileModel>.from(state.profiles);
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

  static double _parseAmount(String val) {
    String clean = val.replaceAll('\$', '').replaceAll(',', '').trim();
    double multiplier = 1.0;
    if (clean.toLowerCase().endsWith('m')) {
      multiplier = 1000000.0;
      clean = clean.substring(0, clean.length - 1);
    } else if (clean.toLowerCase().endsWith('k')) {
      multiplier = 1000.0;
      clean = clean.substring(0, clean.length - 1);
    }
    return (double.tryParse(clean) ?? 0.0) * multiplier;
  }

  static double _parsePercent(String val) {
    String clean = val.replaceAll('%', '').trim();
    return double.tryParse(clean) ?? 0.0;
  }
}

final sponsorSavedProvider =
    NotifierProvider.autoDispose<SponsorSavedNotifier, SponsorSavedState>(
  SponsorSavedNotifier.new,
);
