import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../session/controllers/session_provider.dart';
import '../controllers/otp_provider.dart';
import '../models/otp_model.dart';
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
  ConsumerState<OtpVerificationView> createState() =>
      _OtpVerificationViewState();
}

class _OtpVerificationViewState extends ConsumerState<OtpVerificationView> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(otpTimerProvider.notifier).startTimer();
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
    final code = _controllers.map((c) => c.text.trim()).join();
    if (code.length < 6) return;

    final request = OtpVerificationRequestModel(
      email: widget.email,
      code: code,
      isRecovery: widget.isRecovery,
    );

    final success = await ref.read(otpProvider.notifier).verifyOtp(request);
    if (!mounted) return;

    final message = ref.read(otpProvider).value?.message;
    if (success) {
      ref.read(authProvider.notifier).updateSession(
        isAuthenticated: true,
        isApiConnected: true,
      );
      if (message != null) CustomSnackBar.show(context, message);
      context.go(widget.isRecovery ? '/reset-password' : '/success');
    } else if (message != null) {
      CustomSnackBar.show(context, message, isError: true);
    }
  }

  Future<void> _resendOtp() async {
    final success = await ref
        .read(resendOtpProvider.notifier)
        .resendOtp(widget.email);
    if (!mounted) return;

    final message = ref.read(resendOtpProvider).value?.message;
    if (message != null) {
      CustomSnackBar.show(context, message, isError: !success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpProvider);
    final resendState = ref.watch(resendOtpProvider);
    final secondsLeft = ref.watch(otpTimerProvider);

    return CommonBackground(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(
                    widget.isRecovery ? '/forgot-password' : '/signup',
                  );
                }
              },
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
              "Enter the 6-digit code sent to ${widget.email}",
              style: GoogleFonts.outfit(fontSize: 15.sp, color: AppColors.grey),
            ),
            SizedBox(height: 48.h),

            // 6 OTP Boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (index) => OtpFieldWidget(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  onChanged: (val) {
                    if (val.isNotEmpty && index < 5) {
                      _focusNodes[index + 1].requestFocus();
                    } else if (val.isEmpty && index > 0) {
                      _focusNodes[index - 1].requestFocus();
                    }
                    if (val.isNotEmpty && index == 5) {
                      FocusScope.of(context).unfocus();
                      _verifyOtp();
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
                    secondsLeft > 0
                        ? "Resend code in ${secondsLeft}s"
                        : "Didn't receive the code?",
                    style: GoogleFonts.outfit(
                      color: AppColors.grey,
                      fontSize: 14.sp,
                    ),
                  ),
                  if (secondsLeft == 0) ...[
                    SizedBox(height: 6.h),
                    TextButton(
                      onPressed: resendState.isLoading ? null : _resendOtp,
                      child: resendState.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: AppColors.primaryColor,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Resend Code",
                              style: GoogleFonts.outfit(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp,
                              ),
                            ),
                    ),
                  ],
                ],
              ),
            ),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: (otpState.isLoading || resendState.isLoading)
                    ? null
                    : _verifyOtp,
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
                        style: GoogleFonts.outfit(
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
