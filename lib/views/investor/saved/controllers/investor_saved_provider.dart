import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/investor_saved_item_model.dart';
import '../repositories/investor_saved_repository.dart';

class InvestorSavedState {
  final bool isLoading;
  final List<InvestorSavedItemModel> allItems;
  final String filterSelected;

  const InvestorSavedState({
    this.isLoading = false,
    required this.allItems,
    this.filterSelected = "Newest",
  });

  List<InvestorSavedItemModel> get items {
    List<InvestorSavedItemModel> list = List.from(allItems);

    switch (filterSelected) {
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
    final total = allItems.fold<double>(
      0.0,
      (sum, item) => sum + _parseAmount(item.invested),
    );
    return "\$${(total / 1000).toInt()}k";
  }

  int get activeProjectsCount => allItems.where((e) => e.isActive).length;
  int get pendingNdasCount => allItems.where((e) => !e.isActive).length;

  static double _parseAmount(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9.]'), '');
    final val = double.tryParse(cleaned) ?? 0.0;
    if (input.toLowerCase().contains('k')) {
      return val * 1000;
    } else if (input.toLowerCase().contains('m')) {
      return val * 1000000;
    }
    return val;
  }

  InvestorSavedState copyWith({
    bool? isLoading,
    List<InvestorSavedItemModel>? allItems,
    String? filterSelected,
  }) {
    return InvestorSavedState(
      isLoading: isLoading ?? this.isLoading,
      allItems: allItems ?? this.allItems,
      filterSelected: filterSelected ?? this.filterSelected,
    );
  }
}

class InvestorSavedNotifier extends Notifier<InvestorSavedState> {
  @override
  InvestorSavedState build() {
    loadSavedItems();
    return const InvestorSavedState(
      isLoading: true,
      allItems: [],
    );
  }

  Future<void> loadSavedItems() async {
    final repo = ref.read(investorSavedRepositoryProvider);
    final items = await repo.getSavedItems();
    state = state.copyWith(
      isLoading: false,
      allItems: items,
    );
  }

  void setFilter(String filter) {
    state = state.copyWith(filterSelected: filter);
  }
}

final investorSavedProvider =
    NotifierProvider.autoDispose<InvestorSavedNotifier, InvestorSavedState>(
  InvestorSavedNotifier.new,
);
