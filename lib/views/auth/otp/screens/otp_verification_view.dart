import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/common_background.dart';
import '../controllers/otp_provider.dart';
import '../widgets/otp_field_widget.dart';

class OtpVerificationView extends ConsumerStatefulWidget {
  final String email;
  final bool isRecovery;
  const OtpVerificationView({
    super.key,
    required this.email,
    required this.isRecovery,
  });

  @override
  ConsumerState<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends ConsumerState<OtpVerificationView> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(otpProvider.notifier).startTimer();
    });
  }

  @override
  void dispose() {
    for (var ctrl in _controllers) {
      ctrl.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 4) return;

    try {
      final success = await ref.read(otpProvider.notifier).verifyOtp(
            email: widget.email,
            code: code,
            isRecovery: widget.isRecovery,
          );
      final otpState = ref.read(otpProvider);

      if (mounted && success) {
        if (widget.isRecovery) {
          context.go('/reset-password');
        } else {
          context.go('/success');
        }
      } else if (mounted && otpState.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(otpState.errorMessage!)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OTP failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpProvider);

    return CommonBackground(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
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
              "Verification Code",
              style: GoogleFonts.outfit(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Enter the 4-digit code sent to ${widget.email}",
              style: GoogleFonts.outfit(
                fontSize: 15.sp,
                color: AppColors.grey,
              ),
            ),
            SizedBox(height: 48.h),

            // 4 OTP Boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                4,
                (index) => OtpFieldWidget(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  onChanged: (val) {
                    if (val.isNotEmpty && index < 3) {
                      _focusNodes[index + 1].requestFocus();
                    } else if (val.isEmpty && index > 0) {
                      _focusNodes[index - 1].requestFocus();
                    }
                    if (val.isNotEmpty && index == 3) {
                      FocusScope.of(context).unfocus();
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 40.h),

            // Timer & Resend
            Center(
              child: Column(
                children: [
                  Text(
                    "Resend code in ${otpState.secondsLeft}s",
                    style: GoogleFonts.outfit(
                      color: AppColors.grey,
                      fontSize: 14.sp,
                    ),
                  ),
                  if (otpState.canResend)
                    TextButton(
                      onPressed: otpState.isResending
                          ? null
                          : () => ref.read(otpProvider.notifier).resendOtp(widget.email),
                      child: otpState.isResending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              "Resend Code",
                              style: GoogleFonts.outfit(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                ],
              ),
            ),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: otpState.isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                ),
                child: otpState.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Verify & Proceed",
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
    );
  }
}
