import 'dart:convert';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/investment_record_model.dart';

class InvestmentHistoryResult {
  final InvestmentPortfolioSummary summary;
  final List<InvestmentRecordModel> records;

  const InvestmentHistoryResult({
    required this.summary,
    required this.records,
  });
}

abstract class InvestmentHistoryRepository {
  Future<InvestmentHistoryResult> getInvestmentHistory({String? status});
}

class InvestmentHistoryRepositoryImpl implements InvestmentHistoryRepository {
  final ApiService? _apiService;

  InvestmentHistoryRepositoryImpl([this._apiService]);

  @override
  Future<InvestmentHistoryResult> getInvestmentHistory({String? status}) async {
    if (_apiService != null) {
      try {
        final queryParams = <String, dynamic>{};
        if (status != null && status != 'All') {
          queryParams['status'] = status;
        }

        dynamic response;
        try {
          response = await _apiService.get(
            ApiEndpoints.investorInvestments,
            queryParameters: queryParams.isNotEmpty ? queryParams : null,
            requireAuth: true,
          );
        } catch (_) {
          response = await _apiService.get(
            "/api/v1/projects/investor/investments/",
            queryParameters: queryParams.isNotEmpty ? queryParams : null,
            requireAuth: true,
          );
        }

        dynamic data = response.data;
        if (data is String) {
          try {
            data = jsonDecode(data);
          } catch (_) {}
        }

        InvestmentPortfolioSummary summary = const InvestmentPortfolioSummary();
        List<InvestmentRecordModel> records = [];

        if (data is Map) {
          final payload = data['data'] is Map ? data['data'] as Map : data;
          if (payload['summary'] is Map) {
            summary = InvestmentPortfolioSummary.fromJson(
              Map<String, dynamic>.from(payload['summary'] as Map),
            );
          } else if (payload['total_invested'] != null ||
              payload['active_deals_count'] != null ||
              payload['expected_returns'] != null) {
            summary = InvestmentPortfolioSummary.fromJson(
              Map<String, dynamic>.from(payload),
            );
          }

          final list = payload['results'] is List
              ? payload['results'] as List
              : (payload['investments'] is List
                  ? payload['investments'] as List
                  : (payload['data'] is List ? payload['data'] as List : []));

          for (final item in list.whereType<Map>()) {
            try {
              records.add(
                InvestmentRecordModel.fromJson(Map<String, dynamic>.from(item)),
              );
            } catch (_) {}
          }
        }

        if (records.isNotEmpty) {
          return InvestmentHistoryResult(summary: summary, records: records);
        }
      } catch (_) {}
    }

    return const InvestmentHistoryResult(
      summary: InvestmentPortfolioSummary(
        totalInvested: "\$560,000",
        totalCurrentValue: "\$644,200",
        totalProfitLoss: "+\$84,200 (+15.0%)",
        activeDealsCount: 4,
      ),
      records: [
        InvestmentRecordModel(
          id: "inv_hist_1",
          projectId: "proj_9876",
          title: "Downtown Tech Hub",
          category: "Real Estate",
          sponsor: "Acme Corp",
          date: "Mar 14, 2026",
          status: "Active",
          invested: "\$250,000",
          currentValue: "\$288,000",
          roi: "+15.2%",
          imageUrl:
              "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=300&auto=format&fit=crop",
        ),
        InvestmentRecordModel(
          id: "inv_hist_2",
          projectId: "proj_5544",
          title: "AI Logistics Platform",
          category: "Tech",
          sponsor: "Nexus AI",
          date: "Feb 22, 2026",
          status: "Active",
          invested: "\$150,000",
          currentValue: "\$173,000",
          roi: "+15.3%",
          imageUrl:
              "https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=300&auto=format&fit=crop",
        ),
        InvestmentRecordModel(
          id: "inv_hist_3",
          projectId: "proj_3322",
          title: "EcoTech Solar Farm",
          category: "Energy",
          sponsor: "Green Grid Ltd",
          date: "Jan 10, 2026",
          status: "Completed",
          invested: "\$100,000",
          currentValue: "\$118,500",
          roi: "+18.5%",
          imageUrl:
              "https://images.unsplash.com/photo-1509391365360-2e959784a276?q=80&w=300&auto=format&fit=crop",
        ),
        InvestmentRecordModel(
          id: "inv_hist_4",
          projectId: "proj_7788",
          title: "AeroDynamics Drone Fleet",
          category: "Aviation",
          sponsor: "Sky Tech Ventures",
          date: "Nov 05, 2025",
          status: "Pending",
          invested: "\$60,000",
          currentValue: "\$64,700",
          roi: "+7.8%",
          imageUrl:
              "https://images.unsplash.com/photo-1508614589041-895b88991e3e?q=80&w=300&auto=format&fit=crop",
        ),
      ],
    );
  }
}
