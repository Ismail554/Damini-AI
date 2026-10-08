import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/change_password_model.dart';

abstract class ChangePasswordRepository {
  Future<bool> changePassword(ChangePasswordModel model);
}

class ChangePasswordRepositoryImpl implements ChangePasswordRepository {
  final ApiService _apiService;

  ChangePasswordRepositoryImpl(this._apiService);

  @override
  Future<bool> changePassword(ChangePasswordModel model) async {
    final response = await _apiService.post(
      ApiEndpoints.changePassword,
      data: {
        'current_password': model.currentPassword,
        'new_password': model.newPassword,
      },
      requireAuth: true,
    );

    return response.statusCode == 200 ||
        response.statusCode == 201 ||
        (response.data is Map &&
            (response.data['status'] == 'success' ||
                response.data['success'] == true));
  }
}
