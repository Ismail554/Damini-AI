import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/app_colors.dart';

class VerificationPendingScreen extends StatelessWidget {
  final String role;

  const VerificationPendingScreen({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hourglass_empty_rounded,
              color: Colors.orangeAccent,
              size: 64.r,
            ),
          ),
          SizedBox(height: 28.h),
          Text(
            "Verification Pending",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "Our compliance team is currently reviewing your ${role.toUpperCase()} documents. You can skip to the dashboard while verification is in progress.",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: AppColors.grey,
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
          SizedBox(height: 40.h),

          // Skip to Dashboard Button
          SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006EDB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27.r),
                ),
              ),
              child: Text(
                "Skip to Dashboard",
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
