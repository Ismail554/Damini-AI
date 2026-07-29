import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';

class InvestorSavedStatsHeader extends StatelessWidget {
  final String totalCommitted;
  final int activeProjects;
  final int pendingNdas;

  const InvestorSavedStatsHeader({
    super.key,
    required this.totalCommitted,
    required this.activeProjects,
    required this.pendingNdas,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            tc,
            icon: Icons.account_balance_wallet_outlined,
            value: totalCommitted,
            label: "Total committed",
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildStatCard(
            tc,
            icon: Icons.pie_chart_outline_rounded,
            value: "$activeProjects",
            label: "Active projects",
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildStatCard(
            tc,
            icon: Icons.shield_outlined,
            value: "$pendingNdas",
            label: "Pending NDA's",
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    AppThemeColors tc, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: tc.isDark ? const Color(0xFF092444) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: tc.isDark
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: tc.textPrimary,
            size: 20.r,
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11.sp,
              color: tc.textTertiary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
