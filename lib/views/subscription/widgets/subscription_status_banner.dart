import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/utils/external_link_launcher.dart';
import '../models/subscription_status_model.dart';

class SubscriptionStatusBanner extends StatelessWidget {
  final SubscriptionStatusModel status;

  const SubscriptionStatusBanner({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final isBillingIssue = status.hasBillingIssue;

    final bgColor = isBillingIssue
        ? const Color(0xFFEF4444).withValues(alpha: 0.12)
        : (tc.isDark ? const Color(0xFF09284D) : const Color(0xFFEFF6FF));
    final borderColor = isBillingIssue
        ? const Color(0xFFEF4444)
        : const Color(0xFF2563EB);

    String? dateInfo;
    if (status.currentPeriodEnd != null) {
      final end = status.currentPeriodEnd!;
      final formatted = "${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}";
      dateInfo = status.willRenew
          ? "Renews on $formatted"
          : "Active until $formatted";
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor.withValues(alpha: 0.4), width: 1.5.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isBillingIssue
                    ? Icons.warning_amber_rounded
                    : Icons.verified_rounded,
                color: borderColor,
                size: 20.r,
              ),
              SizedBox(width: 8.w),
              Text(
                status.displayStatusLabel,
                style: GoogleFonts.outfit(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: tc.textPrimary,
                ),
              ),
            ],
          ),
          if (dateInfo != null) ...[
            SizedBox(height: 6.h),
            Text(
              dateInfo,
              style: GoogleFonts.outfit(
                fontSize: 13.sp,
                color: tc.textSecondary,
              ),
            ),
          ],
          if (isBillingIssue) ...[
            SizedBox(height: 8.h),
            Text(
              "A billing issue was detected with your subscription. Please update your payment method to maintain PRO access.",
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                color: const Color(0xFFEF4444),
                height: 1.3,
              ),
            ),
          ],
          if (status.managementUrl != null &&
              status.managementUrl!.trim().isNotEmpty) ...[
            SizedBox(height: 12.h),
            InkWell(
              onTap: () => ExternalLinkLauncher.openUrl(
                context,
                status.managementUrl,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Manage Subscription",
                    style: GoogleFonts.outfit(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2563EB),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 14.r,
                    color: const Color(0xFF2563EB),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
