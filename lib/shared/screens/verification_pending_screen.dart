import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/app_colors.dart';
import '../../views/auth/session/controllers/session_provider.dart';
import '../../views/home/controllers/home_provider.dart';
import '../../views/role_selection/provider/onboarding_provider.dart';

class VerificationPendingScreen extends ConsumerStatefulWidget {
  final String role;

  const VerificationPendingScreen({
    super.key,
    required this.role,
  });

  @override
  ConsumerState<VerificationPendingScreen> createState() => _VerificationPendingScreenState();
}

class _VerificationPendingScreenState extends ConsumerState<VerificationPendingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(onboardingProvider.notifier).checkVerificationStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);
    final statusModel = onboarding.verificationStatus;
    final status = statusModel?.status.toUpperCase() ?? 'PENDING';

    Color iconColor;
    Color bgColor;
    IconData icon;
    String title;
    String description;

    if (status == 'APPROVED') {
      iconColor = const Color(0xFF00C853);
      bgColor = iconColor.withValues(alpha: 0.12);
      icon = Icons.verified_rounded;
      title = "Verification Approved";
      description = "Your ${widget.role.toUpperCase()} account has been verified! You now have full access to Synvest.";
    } else if (status == 'REJECTED') {
      iconColor = const Color(0xFFFF5252);
      bgColor = iconColor.withValues(alpha: 0.12);
      icon = Icons.error_outline_rounded;
      title = "Verification Rejected";
      description = "Your submitted documents could not be verified. Please review your account details or contact support.";
    } else {
      iconColor = Colors.orangeAccent;
      bgColor = iconColor.withValues(alpha: 0.12);
      icon = Icons.hourglass_empty_rounded;
      title = "Verification Pending";
      description = "Our compliance team is currently reviewing your ${widget.role.toUpperCase()} details. You can explore the dashboard while verification is in progress.";
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 64.r),
          ),
          SizedBox(height: 28.h),
          Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: AppColors.grey,
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
          if (onboarding.isLoading) ...[
            SizedBox(height: 20.h),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: AppColors.primaryColor, strokeWidth: 2),
            ),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: () async {
                await ref.read(authProvider.notifier).setRole(widget.role);
                try {
                  await ref.read(authProvider.notifier).switchRole(widget.role);
                } catch (_) {}
                ref.read(homeProvider.notifier).setTabIndex(0);
                if (context.mounted) {
                  context.go('/home');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006EDB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27.r)),
              ),
              child: Text(
                status == 'APPROVED' ? "Go to Dashboard" : "Skip to Dashboard",
                style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
