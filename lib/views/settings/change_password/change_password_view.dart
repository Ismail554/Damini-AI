import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import 'controllers/change_password_provider.dart';
import 'widgets/password_input_field.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return ChangeNotifierProvider(
      create: (_) => ChangePasswordProvider(),
      child: CommonBackground(
        showGrid: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: tc.textPrimary,
                size: 22.r,
              ),
              onPressed: () => context.pop(),
            ),
            title: Text(
              "Change Password",
              style: GoogleFonts.outfit(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: tc.textPrimary,
              ),
            ),
          ),
          body: SafeArea(
            child: Consumer<ChangePasswordProvider>(
              builder: (context, provider, _) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Security Details",
                        style: GoogleFonts.outfit(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: tc.textPrimary,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildFormCard(context, tc, provider),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(
    BuildContext context,
    AppThemeColors tc,
    ChangePasswordProvider provider,
  ) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: tc.isDark ? const Color(0xFF091E36) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: tc.isDark
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PasswordInputField(
            label: "Current password",
            controller: provider.currentPasswordController,
            obscureText: provider.obscureCurrent,
          ),
          SizedBox(height: 20.h),
          PasswordInputField(
            label: "New password",
            controller: provider.newPasswordController,
            obscureText: provider.obscureNew,
            onToggleObscure: provider.toggleObscureNew,
          ),
          SizedBox(height: 20.h),
          PasswordInputField(
            label: "Confirm password",
            controller: provider.confirmPasswordController,
            obscureText: provider.obscureConfirm,
            onToggleObscure: provider.toggleObscureConfirm,
          ),
          SizedBox(height: 28.h),
          _buildSubmitButton(context, provider),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    ChangePasswordProvider provider,
  ) {
    return GestureDetector(
      onTap: provider.isLoading ? null : () => _handleSubmit(context, provider),
      child: Container(
        width: double.infinity,
        height: 50.h,
        decoration: BoxDecoration(
          color: const Color(0xFF006EDB),
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF006EDB).withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: provider.isLoading
              ? SizedBox(
                  width: 22.r,
                  height: 22.r,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  "Change Password",
                  style: GoogleFonts.outfit(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  void _handleSubmit(
    BuildContext context,
    ChangePasswordProvider provider,
  ) async {
    final errorMsg = provider.validateForm();
    if (errorMsg != null) {
      CustomSnackBar.error(context, errorMsg);
      return;
    }

    final success = await provider.changePassword();
    if (success && context.mounted) {
      CustomSnackBar.success(context, "Password updated successfully!");
      context.pop();
    }
  }
}
