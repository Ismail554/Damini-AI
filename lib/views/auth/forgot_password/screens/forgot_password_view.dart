import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/common_background.dart';
import '../../widgets/labeled_text_field.dart';
import '../controllers/forgot_password_provider.dart';

class ForgotPasswordView extends ConsumerStatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  ConsumerState<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends ConsumerState<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordRecovery() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final success = await ref
          .read(forgotPasswordProvider.notifier)
          .sendRecoveryEmail(_emailCtrl.text.trim());
      final state = ref.read(forgotPasswordProvider);

      if (mounted && success) {
        context.push(
          '/otp',
          extra: {'email': _emailCtrl.text.trim(), 'isRecovery': true},
        );
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
    final state = ref.watch(forgotPasswordProvider);

    return CommonBackground(
      child: Padding(
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
                "Recover Password",
                style: GoogleFonts.outfit(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Enter your email to receive a recovery code.",
                style: GoogleFonts.outfit(
                  fontSize: 15.sp,
                  color: AppColors.grey,
                ),
              ),
              SizedBox(height: 48.h),

              LabeledTextField(
                label: "Email",
                hint: "Enter your email",
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
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
              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _handlePasswordRecovery,
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
                          "Send Recovery Code",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 16.h),

              Center(
                child: GestureDetector(
                  onTap: () => context.go('/login'),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.outfit(
                        fontSize: 14.sp,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      children: const [
                        TextSpan(text: "Remember your password? "),
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
            ],
          ),
        ),
      ),
    );
  }
}
