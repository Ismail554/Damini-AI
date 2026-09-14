class ChangePasswordModel {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordModel({
    this.currentPassword = '',
    this.newPassword = '',
    this.confirmPassword = '',
  });

  ChangePasswordModel copyWith({
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
  }) {
    return ChangePasswordModel(
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }
}
