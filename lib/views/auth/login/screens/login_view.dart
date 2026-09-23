import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../shared/global_key.dart';
import '../../widgets/labeled_text_field.dart';
import '../../widgets/social_auth_section.dart';
import '../models/login_request_model.dart';
import '../provider/login_provider.dart';
import '../provider/login_state.dart';
import '../widgets/login_header.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _rememberMe = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final request = LoginRequestModel(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    final success = await ref.read(loginProvider.notifier).login(request);
    if (!mounted) return;

    final loginAsync = ref.read(loginProvider);
    final message = loginAsync.value?.message;

    if (success) {
      if (message != null && message.isNotEmpty) {
        CustomSnackBar.show(context, message);
      }
      final rawRole = loginAsync.value?.role?.trim().toUpperCase();
      final normalizedRole = loginAsync.value?.role?.trim().toLowerCase();

      if (rawRole == 'NONE' || rawRole == null || !GlobalKeys.isValidRole(normalizedRole)) {
        context.go('/role-selection');
      } else {
        context.go('/home');
      }
    } else if (message != null && message.isNotEmpty) {
      CustomSnackBar.show(context, message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginAsync = ref.watch(loginProvider);
    final passwordToggleState = ref.watch(loginState);
    final colors = AppThemeColors.of(context);

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
                const LoginHeader(),
                SizedBox(height: 24.h),

                LabeledTextField(
                  label: "Email",
                  hint: "Enter email",
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.grey, size: 20),
                  validator: (v) {
                    if (v == null ||
                        !RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(v.trim())) {
                      return "Enter valid email";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                LabeledTextField(
                  label: "Password",
                  hint: "••••••••",
                  controller: _passwordCtrl,
                  obscureText: passwordToggleState.password,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.grey, size: 20),
                  validator: (v) => (v == null || v.length < 6)
                      ? "Enter password (6+ chars)"
                      : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      passwordToggleState.password
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.grey,
                      size: 20.r,
                    ),
                    onPressed: () =>
                        ref.read(loginState.notifier).passwordToggle(),
                  ),
                ),
                SizedBox(height: 12.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 24.r,
                          width: 24.r,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (val) =>
                                setState(() => _rememberMe = val ?? false),
                            activeColor: AppColors.primaryColor,
                            side: BorderSide(color: colors.textPrimary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "Remember me",
                          style: GoogleFonts.outfit(
                            fontSize: 14.sp,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => context.push('/forgot-password'),
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.outfit(
                          fontSize: 14.sp,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),

                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: loginAsync.isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.r),
                      ),
                    ),
                    child: loginAsync.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "Sign In",
                            style: GoogleFonts.outfit(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 24.h),
                const SocialAuthSection(),
                SizedBox(height: 32.h),

                Center(
                  child: GestureDetector(
                    onTap: () => context.push('/signup'),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.outfit(
                          fontSize: 14.sp,
                          color: colors.textSecondary,
                        ),
                        children: const [
                          TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: "Sign Up",
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
