import 'package:flutter/material.dart';
import '../models/sponsor_saved_profile_model.dart';
import '../models/sponsor_saved_project_model.dart';

enum SavedTab { projects, profiles }

class SponsorSavedProvider extends ChangeNotifier {
  SavedTab _currentTab = SavedTab.projects;
  String _selectedSort = "Newest";

  List<SponsorSavedProjectModel> _projects = SponsorSavedProjectModel.mockList();
  List<SponsorSavedProfileModel> _profiles = SponsorSavedProfileModel.mockList();

  SavedTab get currentTab => _currentTab;
  String get selectedSort => _selectedSort;
  List<SponsorSavedProjectModel> get projects => _projects;
  List<SponsorSavedProfileModel> get profiles => _profiles;

  int get resultsCount =>
      _currentTab == SavedTab.projects ? _projects.length : _profiles.length;

  void selectTab(SavedTab tab) {
    _currentTab = tab;
    notifyListeners();
  }

  void setSortOption(String sort) {
    _selectedSort = sort;
    notifyListeners();
  }

  void removeProject(String id) {
    _projects = _projects.where((p) => p.id != id).toList();
    notifyListeners();
  }

  void removeProfile(String id) {
    _profiles = _profiles.where((p) => p.id != id).toList();
    notifyListeners();
  }
}
