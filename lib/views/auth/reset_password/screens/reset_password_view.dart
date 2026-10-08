import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/common_background.dart';
import '../controllers/reset_password_provider.dart';

class ResetPasswordView extends ConsumerStatefulWidget {
  final String? email;
  final String? code;

  const ResetPasswordView({
    super.key,
    this.email,
    this.code,
  });

  @override
  ConsumerState<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends ConsumerState<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailCtrl;
  late final TextEditingController _codeCtrl;
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.email ?? '');
    _codeCtrl = TextEditingController(text: widget.code ?? '');
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final email = widget.email?.isNotEmpty == true
        ? widget.email!
        : _emailCtrl.text.trim();
    final code = widget.code?.isNotEmpty == true
        ? widget.code!
        : _codeCtrl.text.trim();

    if (email.isEmpty || code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and reset code are required.")),
      );
      return;
    }

    try {
      final success = await ref
          .read(resetPasswordProvider.notifier)
          .resetPassword(
            email: email,
            code: code,
            newPassword: _passwordCtrl.text,
            confirmPassword: _confirmPasswordCtrl.text,
          );
      final state = ref.read(resetPasswordProvider);

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password successfully reset! Sign in with your new credentials."),
          ),
        );
        context.go('/login');
      } else if (mounted && state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resetPasswordProvider);

    return CommonBackground(
      showGrid: false,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () => context.canPop() ? context.pop() : context.go('/login'),
                ),
                SizedBox(height: 10.h),
                Text(
                  "Reset Password",
                  style: GoogleFonts.outfit(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  widget.email?.isNotEmpty == true
                      ? "Resetting password for ${widget.email}"
                      : "Set a strong password for your recovered account credentials.",
                  style: GoogleFonts.outfit(
                    fontSize: 15.sp,
                    color: AppColors.grey,
                  ),
                ),
                SizedBox(height: 32.h),

                if (widget.email == null || widget.email!.isEmpty) ...[
                  _buildTextField(
                    _emailCtrl,
                    "Email Address",
                    false,
                    (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "Enter email";
                      }
                      return null;
                    },
                    prefixIcon: Icons.email_outlined,
                  ),
                  SizedBox(height: 16.h),
                ],

                if (widget.code == null || widget.code!.isEmpty) ...[
                  _buildTextField(
                    _codeCtrl,
                    "6-Digit Reset Code",
                    false,
                    (val) {
                      if (val == null || val.trim().length < 6) {
                        return "Enter 6-digit code";
                      }
                      return null;
                    },
                    prefixIcon: Icons.pin_outlined,
                  ),
                  SizedBox(height: 16.h),
                ],

                _buildTextField(
                  _passwordCtrl,
                  "New Password",
                  _obscurePassword,
                  (val) {
                    if (val == null || val.length < 6) {
                      return "Password must be 6+ characters";
                    }
                    return null;
                  },
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.grey,
                      size: 20.r,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                SizedBox(height: 20.h),

                _buildTextField(
                  _confirmPasswordCtrl,
                  "Confirm New Password",
                  _obscureConfirm,
                  (val) {
                    if (val != _passwordCtrl.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                  suffix: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.grey,
                      size: 20.r,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                SizedBox(height: 40.h),

                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _handleResetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.r),
                      ),
                    ),
                    child: state.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "Save & Return to Sign In",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    bool obscure,
    String? Function(String?)? validator, {
    Widget? suffix,
    IconData prefixIcon = Icons.lock_outline_rounded,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(color: AppColors.grey, fontSize: 14.sp),
        prefixIcon:
            Icon(prefixIcon, color: AppColors.grey, size: 20.r),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFF0F1E2E).withValues(alpha: 0.6),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.r),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.r),
          borderSide: const BorderSide(color: AppColors.primaryColor),
        ),
      ),
      validator: validator,
    );
  }
}
