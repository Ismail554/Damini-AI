import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../models/investment_record_model.dart';
import '../repositories/investment_history_repository.dart';

final investmentHistoryRepositoryProvider =
    Provider<InvestmentHistoryRepository>((ref) {
  return InvestmentHistoryRepositoryImpl(ref.watch(apiServiceProvider));
});

class InvestmentHistoryState {
  final bool isLoading;
  final String selectedFilter;
  final InvestmentPortfolioSummary summary;
  final List<InvestmentRecordModel> allRecords;

  const InvestmentHistoryState({
    this.isLoading = false,
    this.selectedFilter = "All",
    this.summary = const InvestmentPortfolioSummary(),
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
    InvestmentPortfolioSummary? summary,
    List<InvestmentRecordModel>? allRecords,
  }) {
    return InvestmentHistoryState(
      isLoading: isLoading ?? this.isLoading,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      summary: summary ?? this.summary,
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
    final result = await repo.getInvestmentHistory(status: state.selectedFilter);
    state = state.copyWith(
      isLoading: false,
      summary: result.summary,
      allRecords: result.records,
    );
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }
}
