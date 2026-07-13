import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_provider.dart';
import '../../core/utils/app_colors.dart';
import '../../core/widgets/common_background.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordRecovery() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    try {
      await auth.forgotPassword(_emailCtrl.text);
      if (mounted) {
        context.go(
          '/otp',
          extra: {'email': _emailCtrl.text, 'isRecovery': true},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return CommonBackground(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), onPressed: () => context.pop()),
              SizedBox(height: 10.h),
              Text("Recover Password", style: GoogleFonts.outfit(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 8.h),
              Text("Enter your email address to recover your account credentials.", style: GoogleFonts.outfit(fontSize: 15.sp, color: AppColors.grey)),
              SizedBox(height: 48.h),
              
              TextFormField(
                controller: _emailCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Email Address",
                  hintStyle: GoogleFonts.outfit(color: AppColors.grey, fontSize: 14.sp),
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.grey, size: 20.r),
                  filled: true,
                  fillColor: const Color(0xFF0F1E2E).withOpacity(0.6),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24.r), borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24.r), borderSide: const BorderSide(color: AppColors.primaryColor)),
                ),
                validator: (val) {
                  if (val == null || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) return "Enter valid email";
                  return null;
                },
              ),
              const Spacer(),
              
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _handlePasswordRecovery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
                  ),
                  child: auth.isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text("Send Verification OTP", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
