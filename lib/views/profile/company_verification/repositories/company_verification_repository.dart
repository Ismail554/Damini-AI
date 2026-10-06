import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/company_verification_model.dart';

final companyVerificationRepositoryProvider =
    Provider<CompanyVerificationRepository>((ref) {
  return CompanyVerificationRepositoryImpl(ref.watch(apiServiceProvider));
});

abstract class CompanyVerificationRepository {
  Future<CompanyVerificationModel> getVerificationStatus();
  Future<bool> uploadDocument({
    required String documentType,
    required String filePath,
  });
  Future<bool> submitVerification(CompanyVerificationModel verification);
}

class CompanyVerificationRepositoryImpl
    implements CompanyVerificationRepository {
  final ApiService _apiService;

  CompanyVerificationRepositoryImpl(this._apiService);

  @override
  Future<CompanyVerificationModel> getVerificationStatus() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.verificationStatus,
        requireAuth: true,
      );

      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is Map && data['data'] is Map) {
        return CompanyVerificationModel.fromJson(
          Map<String, dynamic>.from(data['data'] as Map),
        );
      } else if (data is Map<String, dynamic>) {
        return CompanyVerificationModel.fromJson(data);
      } else if (data is Map) {
        return CompanyVerificationModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      return const CompanyVerificationModel();
    } catch (_) {
      return const CompanyVerificationModel();
    }
  }

  @override
  Future<bool> uploadDocument({
    required String documentType,
    required String filePath,
  }) async {
    try {
      final fileName = filePath.split(RegExp(r'[\\/]')).last;
      final formData = FormData.fromMap({
        'document_type': documentType,
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _apiService.post(
        ApiEndpoints.verificationDocuments,
        data: formData,
        requireAuth: true,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> submitVerification(CompanyVerificationModel verification) async {
    bool hasUploaded = false;

    if (verification.businessLicensePath != null &&
        verification.businessLicensePath!.isNotEmpty &&
        !verification.businessLicensePath!.startsWith('http') &&
        (verification.businessLicensePath!.contains('/') ||
            verification.businessLicensePath!.contains('\\'))) {
      await uploadDocument(
        documentType: 'BUSINESS_REGISTRATION',
        filePath: verification.businessLicensePath!,
      );
      hasUploaded = true;
    }

    if (verification.taxDocumentPath != null &&
        verification.taxDocumentPath!.isNotEmpty &&
        !verification.taxDocumentPath!.startsWith('http') &&
        (verification.taxDocumentPath!.contains('/') ||
            verification.taxDocumentPath!.contains('\\'))) {
      await uploadDocument(
        documentType: 'TAX_DOCUMENT',
        filePath: verification.taxDocumentPath!,
      );
      hasUploaded = true;
    }

    return hasUploaded;
  }
}
