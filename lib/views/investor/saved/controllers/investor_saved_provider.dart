import 'package:flutter/material.dart';
import '../models/investor_saved_item_model.dart';

class InvestorSavedProvider extends ChangeNotifier {
  final List<InvestorSavedItemModel> _items = const [
    InvestorSavedItemModel(
      id: "inv_saved_1",
      title: "Downtown Tech Hub",
      category: "Real Estate",
      date: "Mar 14, 2026",
      status: "Active",
      invested: "\$250k",
      value: "\$288k",
      targetRoi: "+15.0%",
      fundingProgress: 0.24,
      imageUrl:
          "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=300&auto=format&fit=crop",
    ),
    InvestorSavedItemModel(
      id: "inv_saved_2",
      title: "AI Logistics Platform",
      category: "Tech",
      date: "Feb 22, 2026",
      status: "Active",
      invested: "\$150k",
      value: "\$173k",
      targetRoi: "+15.0%",
      fundingProgress: 0.67,
      imageUrl:
          "https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=300&auto=format&fit=crop",
    ),
    InvestorSavedItemModel(
      id: "inv_saved_3",
      title: "EcoTech Solar Farm",
      category: "Energy",
      date: "Feb 22, 2026",
      status: "Pending",
      invested: "\$100k",
      value: "\$100k",
      targetRoi: "+15.0%",
      fundingProgress: 0.44,
      imageUrl:
          "https://images.unsplash.com/photo-1509391365360-2e959784a276?q=80&w=300&auto=format&fit=crop",
    ),
  ];

  String _filterSelected = "All";

  List<InvestorSavedItemModel> get items => _items;
  String get filterSelected => _filterSelected;

  String get totalCommitted => "\$560k";
  int get activeProjectsCount => 2;
  int get pendingNdasCount => 1;

  void setFilter(String filter) {
    _filterSelected = filter;
    notifyListeners();
  }
}
