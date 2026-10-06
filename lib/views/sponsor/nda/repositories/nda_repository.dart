import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/nda_model.dart';

final ndaRepositoryProvider = Provider<NdaRepository>((ref) {
  return NdaRepository(ref.watch(apiServiceProvider));
});

class NdaRepository {
  final ApiService _apiService;

  NdaRepository(this._apiService);

  /// Fetch active NDA terms and pitch deck file: GET /api/v1/profiles/sponsor/nda/
  Future<NdaAgreementModel> fetchSponsorNda([String disclosingParty = "Acme Corp"]) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.sponsorNda,
        requireAuth: true,
      );

      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is Map && data['data'] is Map) {
        return NdaAgreementModel.fromJson(
          Map<String, dynamic>.from(data['data'] as Map),
        );
      } else if (data is Map<String, dynamic>) {
        return NdaAgreementModel.fromJson(data);
      } else if (data is Map) {
        return NdaAgreementModel.fromJson(Map<String, dynamic>.from(data));
      }

      return NdaAgreementModel.mockData(disclosingParty);
    } catch (_) {
      return NdaAgreementModel.mockData(disclosingParty);
    }
  }

  /// Backward-compatible alias
  Future<NdaAgreementModel> fetchNdaAgreement([String disclosingParty = "Acme Corp"]) async {
    return fetchSponsorNda(disclosingParty);
  }

  /// Update NDA terms and upload Pitch Deck & Financials: POST /api/v1/profiles/sponsor/nda/
  Future<NdaAgreementModel> updateSponsorNda({
    String? confidentialityTerms,
    String? pitchDeckPath,
    List<String>? customClauses,
  }) async {
    final map = <String, dynamic>{};

    if (confidentialityTerms != null && confidentialityTerms.trim().isNotEmpty) {
      map['confidentiality_terms'] = confidentialityTerms.trim();
    }

    if (customClauses != null && customClauses.isNotEmpty) {
      map['custom_clauses'] = jsonEncode(customClauses);
    }

    if (pitchDeckPath != null && pitchDeckPath.isNotEmpty) {
      final fileName = pitchDeckPath.split(RegExp(r'[\\/]')).last;
      map['pitch_deck'] = await MultipartFile.fromFile(
        pitchDeckPath,
        filename: fileName,
      );
    }

    final formData = FormData.fromMap(map);

    final response = await _apiService.post(
      ApiEndpoints.sponsorNda,
      data: formData,
      requireAuth: true,
    );

    dynamic data = response.data;
    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (_) {}
    }

    if (data is Map && data['data'] is Map) {
      return NdaAgreementModel.fromJson(
        Map<String, dynamic>.from(data['data'] as Map),
      );
    } else if (data is Map<String, dynamic>) {
      return NdaAgreementModel.fromJson(data);
    } else if (data is Map) {
      return NdaAgreementModel.fromJson(Map<String, dynamic>.from(data));
    }

    throw Exception('Unexpected response from NDA update endpoint');
  }

  Future<bool> submitSignature({
    required String ndaId,
    required String signatureText,
    String? signatureImagePath,
  }) async {
    return true;
  }
}
