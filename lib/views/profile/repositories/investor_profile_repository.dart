import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/investor_profile_model.dart';

final investorProfileRepositoryProvider =
    Provider<InvestorProfileRepository>((ref) {
  return InvestorProfileRepositoryImpl(ref.watch(apiServiceProvider));
});

abstract class InvestorProfileRepository {
  Future<InvestorProfileModel> getProfile();
}

class InvestorProfileRepositoryImpl implements InvestorProfileRepository {
  final ApiService _apiService;

  InvestorProfileRepositoryImpl(this._apiService);

  @override
  Future<InvestorProfileModel> getProfile() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.currentUser,
        requireAuth: true,
      );

      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is Map<String, dynamic>) {
        return InvestorProfileModel.fromJson(data);
      } else if (data is Map) {
        return InvestorProfileModel.fromJson(Map<String, dynamic>.from(data));
      }
      return const InvestorProfileModel();
    } catch (_) {
      return const InvestorProfileModel();
    }
  }
}
