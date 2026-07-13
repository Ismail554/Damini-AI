import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_provider.dart';
import '../../core/utils/app_colors.dart';
import '../../core/widgets/common_background.dart';
import '../../core/widgets/glass_card.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  
  bool _obscurePassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please accept the terms & conditions")),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    try {
      await auth.signUp(_nameCtrl.text, _emailCtrl.text, _passwordCtrl.text);
      if (mounted) {
        context.go(
          '/otp',
          extra: {'email': _emailCtrl.text, 'isRecovery': false},
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
                onPressed: () => context.pop(),
              ),
              SizedBox(height: 10.h),
              Text(
                "Create Account",
                style: GoogleFonts.outfit(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Register to start networking with sponsors and investors.",
                style: GoogleFonts.outfit(
                  fontSize: 15.sp,
                  color: AppColors.grey,
                ),
              ),
              SizedBox(height: 36.h),

              GlassCard(
                child: Column(
                  children: [
                    // Name Field
                    _buildTextField(_nameCtrl, "Full Name", Icons.person_outline, false, (val) {
                      if (val == null || val.trim().isEmpty) return "Please enter your name";
                      return null;
                    }),
                    SizedBox(height: 16.h),

                    // Email Field
                    _buildTextField(_emailCtrl, "Email Address", Icons.email_outlined, false, (val) {
                      if (val == null || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                        return "Please enter a valid email";
                      }
                      return null;
                    }),
                    SizedBox(height: 16.h),

                    // Password Field
                    _buildTextField(
                      _passwordCtrl,
                      "Password",
                      Icons.lock_outline_rounded,
                      _obscurePassword,
                      (val) {
                        if (val == null || val.length < 6) return "Password must be 6+ characters";
                        return null;
                      },
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.grey,
                          size: 20.r,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Accept Terms checkbox
              Row(
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (val) => setState(() => _acceptTerms = val ?? false),
                    activeColor: AppColors.primaryColor,
                    side: const BorderSide(color: AppColors.grey),
                  ),
                  Expanded(
                    child: Text(
                      "I accept the terms & privacy policies.",
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // SignUp CTA
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
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          "Sign Up",
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
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    IconData icon,
    bool obscure,
    String? Function(String?)? validator, {
    Widget? suffix,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(color: AppColors.grey, fontSize: 14.sp),
        prefixIcon: Icon(icon, color: AppColors.grey, size: 20.r),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFF0F1E2E).withOpacity(0.6),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.r),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
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
