import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_error_handler.dart';
import '../../../../core/services/api_service.dart';

final signNdaRepositoryProvider = Provider<SignNdaRepository>((ref) {
  return SignNdaRepository(ref.watch(apiServiceProvider));
});

class SignNdaResult {
  final bool isSuccess;
  final String message;
  final bool needsCollaborationRequest;

  const SignNdaResult({
    required this.isSuccess,
    required this.message,
    this.needsCollaborationRequest = false,
  });
}

class SignNdaRepository {
  final ApiService _apiService;

  SignNdaRepository(this._apiService);

  Future<SignNdaResult> signNda({
    required String projectId,
    required String digitalSignature,
    String? signatureImagePath,
  }) async {
    try {
      dynamic payload;
      if (signatureImagePath != null && signatureImagePath.isNotEmpty) {
        final fileName = signatureImagePath.split(RegExp(r'[/\\]')).last;
        payload = FormData.fromMap({
          'digital_signature': digitalSignature,
          'accepted_terms': true,
          'signature_image': await MultipartFile.fromFile(
            signatureImagePath,
            filename: fileName,
          ),
        });
      } else {
        payload = {
          'digital_signature': digitalSignature,
          'accepted_terms': true,
        };
      }

      final response = await _apiService.post(
        ApiEndpoints.signNda(projectId),
        data: payload,
      );

      String successMessage =
          'NDA signed successfully. You now have access to confidential documents.';
      if (response.data is Map && (response.data as Map)['message'] != null) {
        successMessage = (response.data as Map)['message'].toString();
      } else if (response.data is String &&
          (response.data as String).isNotEmpty) {
        successMessage = response.data as String;
      }

      return SignNdaResult(isSuccess: true, message: successMessage);
    } on ApiException catch (e) {
      final msg = e.message;
      final isCollabReqMissing =
          msg.toLowerCase().contains('collaboration request');
      return SignNdaResult(
        isSuccess: false,
        message: msg,
        needsCollaborationRequest: isCollabReqMissing,
      );
    } on AppException catch (e) {
      final msg = e.message;
      final isCollabReqMissing =
          msg.toLowerCase().contains('collaboration request');
      return SignNdaResult(
        isSuccess: false,
        message: msg,
        needsCollaborationRequest: isCollabReqMissing,
      );
    } catch (e) {
      return SignNdaResult(isSuccess: false, message: e.toString());
    }
  }
}
