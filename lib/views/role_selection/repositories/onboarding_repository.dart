import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/onboarding_models.dart';

abstract class OnboardingRepository {
  Future<bool> setRole(String role);
  Future<bool> setAccountType({required String role, required String accountType});
  Future<bool> updateProfileDetails({
    required String role,
    required Map<String, dynamic> fields,
    String? photoPath,
  });
  Future<List<IndustryModel>> fetchIndustries();
  Future<bool> setInterests({required String role, required List<int> industryIds});
  Future<bool> uploadVerificationDocument({
    required String documentType,
    required String filePath,
  });
  Future<VerificationStatusModel> getVerificationStatus();
}

class OnboardingRepositoryImpl implements OnboardingRepository {
  final ApiService apiService;

  OnboardingRepositoryImpl(this.apiService);

  @override
  Future<bool> setRole(String role) async {
    final payload = {'role': role.toUpperCase()};
    final response = await apiService.post(
      ApiEndpoints.setRole,
      data: payload,
      requireAuth: true,
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<bool> setAccountType({
    required String role,
    required String accountType,
  }) async {
    final typeKey = role.toLowerCase() == 'sponsor' ? 'sponsor_type' : 'investor_type';
    final payload = {typeKey: accountType.toUpperCase()};
    final response = await apiService.patch(
      ApiEndpoints.onboarding(role),
      data: payload,
      requireAuth: true,
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<bool> updateProfileDetails({
    required String role,
    required Map<String, dynamic> fields,
    String? photoPath,
  }) async {
    dynamic data;
    if (photoPath != null && photoPath.isNotEmpty) {
      final fileName = photoPath.split(RegExp(r'[\\/]')).last;
      final map = Map<String, dynamic>.from(fields);
      map['profile_photo'] = await MultipartFile.fromFile(
        photoPath,
        filename: fileName,
      );
      data = FormData.fromMap(map);
    } else {
      data = fields;
    }

    final response = await apiService.patch(
      ApiEndpoints.onboarding(role),
      data: data,
      requireAuth: true,
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<List<IndustryModel>> fetchIndustries() async {
    final response = await apiService.get(
      ApiEndpoints.industries,
      requireAuth: true,
    );
    final data = response.data;
    List<dynamic> list = [];
    if (data is List) {
      list = data;
    } else if (data is Map && data['data'] is List) {
      list = data['data'] as List;
    } else if (data is Map && data['results'] is List) {
      list = data['results'] as List;
    }
    return list.map((item) => IndustryModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<bool> setInterests({
    required String role,
    required List<int> industryIds,
  }) async {
    final response = await apiService.patch(
      ApiEndpoints.onboarding(role),
      data: {'industries': industryIds},
      requireAuth: true,
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<bool> uploadVerificationDocument({
    required String documentType,
    required String filePath,
  }) async {
    final fileName = filePath.split(RegExp(r'[\\/]')).last;
    final formData = FormData.fromMap({
      'document_type': documentType,
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await apiService.post(
      ApiEndpoints.verificationDocuments,
      data: formData,
      requireAuth: true,
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<VerificationStatusModel> getVerificationStatus() async {
    final response = await apiService.get(
      ApiEndpoints.verificationStatus,
      requireAuth: true,
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return VerificationStatusModel.fromJson(data);
    }
    return const VerificationStatusModel(status: 'PENDING');
  }
}
