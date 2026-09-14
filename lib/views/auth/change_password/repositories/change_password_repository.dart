import '../models/change_password_model.dart';

abstract class ChangePasswordRepository {
  Future<bool> changePassword(ChangePasswordModel model);
}

class ChangePasswordRepositoryImpl implements ChangePasswordRepository {
  @override
  Future<bool> changePassword(ChangePasswordModel model) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return true;
  }
}
