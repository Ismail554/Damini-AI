import 'package:Braintech/views/auth/signup/provider/signup_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../providers/social_auth_provider.dart';
import '../../widgets/labeled_text_field.dart';
import '../../widgets/social_auth_section.dart';
import '../models/signup_request_model.dart';
import '../provider/signup_provider.dart';
import '../widgets/signup_header.dart';

class SignUpView extends ConsumerStatefulWidget {
  const SignUpView({super.key});

  @override
  ConsumerState<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends ConsumerState<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  String? _emailServerError;
  String? _passwordServerError;
  String? _firstNameServerError;
  String? _lastNameServerError;

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(() {
      if (_emailServerError != null) setState(() => _emailServerError = null);
    });
    _passwordCtrl.addListener(() {
      if (_passwordServerError != null) setState(() => _passwordServerError = null);
    });
    _firstNameCtrl.addListener(() {
      if (_firstNameServerError != null) setState(() => _firstNameServerError = null);
    });
    _lastNameCtrl.addListener(() {
      if (_lastNameServerError != null) setState(() => _lastNameServerError = null);
    });
  }

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
    setState(() {
      _emailServerError = null;
      _passwordServerError = null;
      _firstNameServerError = null;
      _lastNameServerError = null;
    });

    if (!_formKey.currentState!.validate()) return;
    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      CustomSnackBar.show(context, "Passwords do not match", isError: true);
      return;
    }

    final request = SignupRequestModel(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    try {
      final success = await ref.read(signupProvider.notifier).signUp(request);

      if (!mounted) return;

      final signupState = ref.read(signupProvider);

      if (success) {
        CustomSnackBar.show(
          context,
          signupState.value?.message ?? "Account created successfully!",
        );
        context.push(
          '/otp',
          extra: {'email': _emailCtrl.text.trim(), 'isRecovery': false},
        );
      } else {
        final errors = signupState.value?.errors;
        if (errors != null && errors.isNotEmpty) {
          setState(() {
            if (errors.containsKey('email')) _emailServerError = errors['email'];
            if (errors.containsKey('password')) _passwordServerError = errors['password'];
            if (errors.containsKey('first_name')) {
              _firstNameServerError = errors['first_name'];
            } else if (errors.containsKey('firstName')) {
              _firstNameServerError = errors['firstName'];
            }
            if (errors.containsKey('last_name')) {
              _lastNameServerError = errors['last_name'];
            } else if (errors.containsKey('lastName')) {
              _lastNameServerError = errors['lastName'];
            }
          });
          _formKey.currentState?.validate();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _formKey.currentState?.validate();
          });
        }

        final errorMsg =
            signupState.value?.message ??
            signupState.error?.toString() ??
            "Registration failed. Please try again.";
        CustomSnackBar.show(context, errorMsg, isError: true);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context,
          "Signup failed: ${e.toString()}",
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(signupProvider);
    final socialState = ref.watch(socialAuthProvider);
    final state = ref.watch(signupStateProvider);
    final stateProvider = ref.read(signupStateProvider.notifier);
    final isAnyLoading = signupState.isLoading || socialState.isLoading;

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
                const SignupHeader(),
                AppSpacing.h14,
                SocialAuthSection(
                  enabled: !isAnyLoading,
                ),
                AppSpacing.h12,

                Row(
                  children: [
                    Expanded(
                      child: LabeledTextField(
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.name,
                        label: "First Name",
                        hint: "John",
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.grey, size: 20),
                        controller: _firstNameCtrl,
                        validator: (v) {
                          if (_firstNameServerError != null) return _firstNameServerError;
                          return (v == null || v.trim().isEmpty)
                              ? "Enter first name"
                              : null;
                        },
                      ),
                    ),
                    AppSpacing.w12,
                    Expanded(
                      child: LabeledTextField(
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.name,
                        label: "Last Name",
                        hint: "Doe",
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.grey, size: 20),
                        controller: _lastNameCtrl,
                        validator: (v) {
                          if (_lastNameServerError != null) return _lastNameServerError;
                          return (v == null || v.trim().isEmpty)
                              ? "Enter last name"
                              : null;
                        },
                      ),
                    ),
                  ],
                ),
                AppSpacing.h14,
                LabeledTextField(
                  textInputAction: TextInputAction.next,
                  label: "Email",
                  hint: "john@example.com",
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.grey, size: 20),
                  validator: (v) {
                    if (_emailServerError != null) return _emailServerError;
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
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.grey, size: 20),
                  obscureText: state.password,
                  validator: (v) {
                    if (_passwordServerError != null) return _passwordServerError;
                    return (v == null || v.length < 6)
                        ? "Password must be 6+ characters"
                        : null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      state.password
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.grey,
                      size: 20.sp,
                    ),
                    onPressed: () => stateProvider.passwordToggle(),
                  ),
                ),
                AppSpacing.h14,

                LabeledTextField(
                  textInputAction: TextInputAction.done,
                  label: "Confirm Password",
                  hint: "••••••••",
                  controller: _confirmPasswordCtrl,
                  prefixIcon: const Icon(Icons.lock_reset_rounded, color: AppColors.grey, size: 20),
                  obscureText: state.confirmPassword,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Confirm your password";
                    if (v != _passwordCtrl.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      state.confirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.grey,
                      size: 20.r,
                    ),
                    onPressed: () => stateProvider.confirmPasswordToggle(),
                  ),
                ),
                AppSpacing.h24,
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: isAnyLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.r),
                      ),
                    ),
                    child: signupState.isLoading
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
