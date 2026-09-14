import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/investment_record_model.dart';
import '../repositories/investment_history_repository.dart';

final investmentHistoryRepositoryProvider =
    Provider<InvestmentHistoryRepository>((ref) {
  return InvestmentHistoryRepositoryImpl();
});

class InvestmentHistoryState {
  final bool isLoading;
  final String selectedFilter;
  final List<InvestmentRecordModel> allRecords;

  const InvestmentHistoryState({
    this.isLoading = false,
    this.selectedFilter = "All",
    this.allRecords = const [],
  });

  List<InvestmentRecordModel> get filteredRecords {
    if (selectedFilter == "All") return allRecords;
    return allRecords
        .where(
          (item) => item.status.toLowerCase() == selectedFilter.toLowerCase(),
        )
        .toList();
  }

  InvestmentHistoryState copyWith({
    bool? isLoading,
    String? selectedFilter,
    List<InvestmentRecordModel>? allRecords,
  }) {
    return InvestmentHistoryState(
      isLoading: isLoading ?? this.isLoading,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      allRecords: allRecords ?? this.allRecords,
    );
  }
}

final investmentHistoryProvider = NotifierProvider<InvestmentHistoryNotifier,
    InvestmentHistoryState>(InvestmentHistoryNotifier.new);

class InvestmentHistoryNotifier extends Notifier<InvestmentHistoryState> {
  @override
  InvestmentHistoryState build() {
    loadRecords();
    return const InvestmentHistoryState(isLoading: true);
  }

  Future<void> loadRecords() async {
    final repo = ref.read(investmentHistoryRepositoryProvider);
    final records = await repo.getInvestmentRecords();
    state = state.copyWith(isLoading: false, allRecords: records);
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }
}
