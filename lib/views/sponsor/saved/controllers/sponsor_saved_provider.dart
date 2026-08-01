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
    _selectedSort = "Newest"; // Reset sort when tab changes
    _applySort();
  }

  void setSortOption(String sort) {
    if (_selectedSort == sort) return;
    _selectedSort = sort;
    _applySort();
  }

  void removeProject(String id) {
    _projects = _projects.where((p) => p.id != id).toList();
    notifyListeners();
  }

  void removeProfile(String id) {
    _profiles = _profiles.where((p) => p.id != id).toList();
    notifyListeners();
  }

  void _applySort() {
    if (_currentTab == SavedTab.projects) {
      if (_selectedSort == 'Highest ROI') {
        _projects.sort((a, b) => _parsePercent(b.targetRoi).compareTo(_parsePercent(a.targetRoi)));
      } else if (_selectedSort == 'Target Raise: High to Low') {
        _projects.sort((a, b) => _parseAmount(b.targetRaise).compareTo(_parseAmount(a.targetRaise)));
      } else if (_selectedSort == 'Target Raise: Low to High') {
        _projects.sort((a, b) => _parseAmount(a.targetRaise).compareTo(_parseAmount(b.targetRaise)));
      } else if (_selectedSort == 'Oldest') {
        _projects.sort((a, b) => b.id.compareTo(a.id)); // Using ID as mock date proxy
      } else {
        _projects.sort((a, b) => a.id.compareTo(b.id)); // Newest
      }
    } else {
      if (_selectedSort == 'Name: A to Z') {
        _profiles.sort((a, b) => a.name.compareTo(b.name));
      } else if (_selectedSort == 'Name: Z to A') {
        _profiles.sort((a, b) => b.name.compareTo(a.name));
      } else if (_selectedSort == 'Oldest') {
        _profiles.sort((a, b) => b.id.compareTo(a.id));
      } else {
        _profiles.sort((a, b) => a.id.compareTo(b.id)); // Newest
      }
    }
    notifyListeners();
  }

  double _parseAmount(String val) {
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

  double _parsePercent(String val) {
    String clean = val.replaceAll('%', '').trim();
    return double.tryParse(clean) ?? 0.0;
  }
}
