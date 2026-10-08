import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../controllers/change_password_provider.dart';
import '../../widgets/labeled_text_field.dart';

class ChangePasswordView extends ConsumerWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);
    final provider = ref.watch(changePasswordProvider);

    return CommonBackground(
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
          child: SingleChildScrollView(
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
                _buildFormCard(context, tc, provider, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(
    BuildContext context,
    AppThemeColors tc,
    ChangePasswordState state,
    WidgetRef ref,
  ) {
    final notifier = ref.read(changePasswordProvider.notifier);
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
          LabeledTextField(
            label: "Current password",
            hint: "••••••••",
            controller: notifier.currentPasswordController,
            obscureText: state.obscureCurrent,
            textInputAction: TextInputAction.next,
            suffixIcon: IconButton(
              icon: Icon(
                state.obscureCurrent
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: tc.textSecondary,
                size: 20.r,
              ),
              onPressed: notifier.toggleObscureCurrent,
            ),
          ),
          SizedBox(height: 16.h),
          LabeledTextField(
            label: "New password",
            hint: "••••••••",
            controller: notifier.newPasswordController,
            obscureText: state.obscureNew,
            textInputAction: TextInputAction.next,
            suffixIcon: IconButton(
              icon: Icon(
                state.obscureNew
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: tc.textSecondary,
                size: 20.r,
              ),
              onPressed: notifier.toggleObscureNew,
            ),
          ),
          SizedBox(height: 16.h),
          LabeledTextField(
            label: "Confirm password",
            hint: "••••••••",
            controller: notifier.confirmPasswordController,
            obscureText: state.obscureConfirm,
            textInputAction: TextInputAction.done,
            suffixIcon: IconButton(
              icon: Icon(
                state.obscureConfirm
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: tc.textSecondary,
                size: 20.r,
              ),
              onPressed: notifier.toggleObscureConfirm,
            ),
          ),
          SizedBox(height: 28.h),
          _buildSubmitButton(context, state, ref),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    ChangePasswordState state,
    WidgetRef ref,
  ) {
    return GestureDetector(
      onTap: state.isLoading ? null : () => _handleSubmit(context, ref),
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
          child: state.isLoading
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
    WidgetRef ref,
  ) async {
    final notifier = ref.read(changePasswordProvider.notifier);
    final errorMsg = notifier.validateForm();
    if (errorMsg != null) {
      CustomSnackBar.error(context, errorMsg);
      return;
    }

    final success = await notifier.changePassword();
    if (!context.mounted) return;
    if (success) {
      CustomSnackBar.success(context, "Password updated successfully!");
      context.pop();
    } else {
      final error = ref.read(changePasswordProvider).errorMessage ??
          "Failed to update password";
      CustomSnackBar.error(context, error);
    }
  }
}
