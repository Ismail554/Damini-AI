import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_provider.dart';
import '../../core/utils/app_colors.dart';
import '../../core/widgets/common_background.dart';

class OtpVerificationView extends StatefulWidget {
  final String email;
  final bool isRecovery;
  const OtpVerificationView({super.key, required this.email, required this.isRecovery});

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  
  int _secondsLeft = 59;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = 59;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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

    final auth = context.read<AuthProvider>();
    try {
      await auth.verifyOtp(code);
      if (mounted) {
        if (widget.isRecovery) {
          context.go('/reset-password');
        } else {
          context.go('/success');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("OTP failed: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return CommonBackground(

      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), onPressed: () => context.pop()),
            SizedBox(height: 10.h),
            Text("Verification Code", style: GoogleFonts.outfit(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 8.h),
            Text("Enter the 4-digit code sent to ${widget.email}", style: GoogleFonts.outfit(fontSize: 15.sp, color: AppColors.grey)),
            SizedBox(height: 48.h),
            
            // 4 OTP Boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) => _buildOtpField(index)),
            ),
            SizedBox(height: 40.h),

            // Timer & Resend
            Center(
              child: Column(
                children: [
                  Text("Resend code in ${_secondsLeft}s", style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 14.sp)),
                  if (_secondsLeft == 0)
                    TextButton(
                      onPressed: _startTimer,
                      child: Text("Resend Code", style: GoogleFonts.outfit(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: auth.isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
                ),
                child: auth.isLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text("Verify & Proceed", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 64.w,
      height: 64.h,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [LengthLimitingTextInputFormatter(1), FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF0F1E2E).withOpacity(0.6),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: const BorderSide(color: AppColors.primaryColor, width: 2.0)),
        ),
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
    );
  }
}
