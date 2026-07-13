import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_provider.dart';
import '../../core/utils/app_colors.dart';
import '../../core/widgets/common_background.dart';
import '../../core/widgets/glass_card.dart';
import '../home/home_view.dart';
import '../role_selection/role_selection_view.dart';
import 'signup_view.dart';
import 'forgot_password_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    final auth = context.read<AuthProvider>();
    try {
      await auth.login(_emailCtrl.text, _passwordCtrl.text);
      if (mounted && auth.isAuthenticated) {
        final next = auth.userRole == null ? const RoleSelectionView() : const HomeView();
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => next));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login failed: ${e.toString()}")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return CommonBackground(
      showGrid: true,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),
              Text("Welcome Back", style: GoogleFonts.outfit(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 8.h),
              Text("Sign in to continue to Damini AI", style: GoogleFonts.outfit(fontSize: 15.sp, color: AppColors.grey)),
              SizedBox(height: 36.h),
              
              GlassCard(
                child: Column(
                  children: [
                    _buildTextField(_emailCtrl, "Email Address", Icons.email_outlined, false, (val) {
                      if (val == null || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) return "Enter valid email";
                      return null;
                    }),
                    SizedBox(height: 16.h),
                    _buildTextField(_passwordCtrl, "Password", Icons.lock_outline_rounded, _obscurePassword, (val) {
                      if (val == null || val.length < 6) return "Enter password (6+ chars)";
                      return null;
                    }, suffix: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.grey, size: 20.r),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    )),
                  ],
                ),
              ),
              
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordView())),
                  child: Text("Forgot Password?", style: GoogleFonts.outfit(color: AppColors.primaryColor, fontSize: 13.sp, fontWeight: FontWeight.w600)),
                ),
              ),
              SizedBox(height: 16.h),
              
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
                  ),
                  child: auth.isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text("Login", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 24.h),
              _buildSocialLoginSection(),
              SizedBox(height: 32.h),
              
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpView())),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.outfit(fontSize: 14.sp, color: Colors.white.withOpacity(0.7)),
                      children: const [
                        TextSpan(text: "Don't have an account? "),
                        TextSpan(text: "Sign Up", style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
                      ],
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

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, bool obscure, String? Function(String?)? validator, {Widget? suffix}) {
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
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24.r), borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24.r), borderSide: const BorderSide(color: AppColors.primaryColor)),
      ),
      validator: validator,
    );
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16.w), child: Text("OR", style: TextStyle(fontSize: 12.sp, color: AppColors.grey, fontWeight: FontWeight.bold))),
            Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
          ],
        ),
        SizedBox(height: 24.h),
        _buildSocialButton("Continue with Google", Icons.g_mobiledata),
        SizedBox(height: 12.h),
        _buildSocialButton("Continue with Apple", Icons.apple),
      ],
    );
  }

  Widget _buildSocialButton(String label, IconData icon) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26.r)),
          backgroundColor: Colors.white.withOpacity(0.02),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24.r),
            SizedBox(width: 12.w),
            Text(label, style: GoogleFonts.outfit(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
