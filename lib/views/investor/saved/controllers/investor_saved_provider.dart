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
    InvestorSavedItemModel(
      id: "inv_saved_4",
      title: "BioMed Research Lab",
      category: "Healthcare",
      date: "Jan 10, 2026",
      status: "Active",
      invested: "\$400k",
      value: "\$520k",
      targetRoi: "+18.5%",
      fundingProgress: 0.85,
      imageUrl:
          "https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?q=80&w=300&auto=format&fit=crop",
    ),
  ];

  String _filterSelected = "Newest";

  String get filterSelected => _filterSelected;

  List<InvestorSavedItemModel> get items {
    List<InvestorSavedItemModel> list = List.from(_items);

    switch (_filterSelected) {
      case 'Value: Low to High':
        list.sort(
          (a, b) => _parseAmount(a.value).compareTo(_parseAmount(b.value)),
        );
        break;
      case 'Value: High to Low':
        list.sort(
          (a, b) => _parseAmount(b.value).compareTo(_parseAmount(a.value)),
        );
        break;
      case 'Invested: Low to High':
        list.sort(
          (a, b) =>
              _parseAmount(a.invested).compareTo(_parseAmount(b.invested)),
        );
        break;
      case 'Invested: High to Low':
        list.sort(
          (a, b) =>
              _parseAmount(b.invested).compareTo(_parseAmount(a.invested)),
        );
        break;
      case 'Active Only':
        list = list.where((e) => e.isActive).toList();
        break;
      case 'Pending Only':
        list = list.where((e) => !e.isActive).toList();
        break;
      case 'Newest':
      default:
        break;
    }

    return list;
  }

  String get totalCommitted {
    final total = _items.fold<double>(
      0.0,
      (sum, item) => sum + _parseAmount(item.invested),
    );
    return "\$${(total / 1000).toInt()}k";
  }

  int get activeProjectsCount => _items.where((e) => e.isActive).length;
  int get pendingNdasCount => _items.where((e) => !e.isActive).length;

  void setFilter(String filter) {
    _filterSelected = filter;
    notifyListeners();
  }

  double _parseAmount(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9.]'), '');
    final val = double.tryParse(cleaned) ?? 0.0;
    if (input.toLowerCase().contains('k')) {
      return val * 1000;
    } else if (input.toLowerCase().contains('m')) {
      return val * 1000000;
    }
    return val;
  }
}
