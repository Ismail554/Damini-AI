import 'package:Braintech/core/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_provider.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/asset_manager.dart';
import '../../core/widgets/common_background.dart';
import 'widgets/labeled_text_field.dart';
import 'widgets/social_auth_section.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    final fullName =
        "${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}";
    final auth = context.read<AuthProvider>();
    try {
      await auth.signUp(fullName, _emailCtrl.text.trim(), _passwordCtrl.text);
      if (mounted) {
        context.go(
          '/otp',
          extra: {'email': _emailCtrl.text.trim(), 'isRecovery': false},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup failed: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return CommonBackground(
      showGrid: false,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(IconAssets.rawLogo, height: 60.h, width: 60.w),
                AppSpacing.h8,
                Text(
                  "Create Account",
                  style: GoogleFonts.outfit(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                AppSpacing.h8,
                Text(
                  "Join Nexus to start collaborating.",
                  style: GoogleFonts.outfit(
                    fontSize: 15.sp,
                    color: AppColors.grey,
                  ),
                ),
                AppSpacing.h14,
                const SocialAuthSection(),
                AppSpacing.h12,

                Row(
                  children: [
                    Expanded(
                      child: LabeledTextField(
                        textInputAction: TextInputAction.next,
                        label: "First Name",
                        hint: "Enter name",
                        controller: _firstNameCtrl,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Enter first name"
                            : null,
                      ),
                    ),
                    AppSpacing.w12,
                    Expanded(
                      child: LabeledTextField(
                        textInputAction: TextInputAction.next,
                        label: "Last Name",
                        hint: "Enter name",
                        controller: _lastNameCtrl,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Enter last name"
                            : null,
                      ),
                    ),
                  ],
                ),
                AppSpacing.h14,
                LabeledTextField(
                  textInputAction: TextInputAction.next,
                  label: "Email",
                  hint: "Enter email",
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null ||
                        !RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(v.trim())) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),
                AppSpacing.h14,

                LabeledTextField(
                  textInputAction: TextInputAction.next,
                  label: "Password",
                  hint: "••••••••",
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  validator: (v) => (v == null || v.length < 6)
                      ? "Password must be 6+ characters"
                      : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.grey,
                      size: 20.sp,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                AppSpacing.h14,

                LabeledTextField(
                  textInputAction: TextInputAction.done,
                  label: "Confirm Password",
                  hint: "••••••••",
                  controller: _confirmPasswordCtrl,
                  obscureText: _obscureConfirmPassword,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Confirm your password";
                    if (v != _passwordCtrl.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.grey,
                      size: 20.r,
                    ),
                    onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                  ),
                ),
                AppSpacing.h24,

                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.r),
                      ),
                    ),
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "Create Account",
                            style: GoogleFonts.outfit(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                AppSpacing.h22,

                Center(
                  child: GestureDetector(
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        context.pop();
                      } else {
                        context.go('/login');
                      }
                    },
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.outfit(
                          fontSize: 14.sp,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        children: const [
                          TextSpan(text: "Already have an account? "),
                          TextSpan(
                            text: "Sign In",
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
