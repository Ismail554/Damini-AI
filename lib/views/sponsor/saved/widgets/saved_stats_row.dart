import 'package:Braintech/core/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SavedStatsRow extends StatelessWidget {
  const SavedStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.account_balance_wallet_outlined,
            value: "\$560k",
            label: "Total committed",
          ),
        ),
        AppSpacing.w8,
        Expanded(
          child: _buildStatCard(
            icon: Icons.pie_chart_outline_rounded,
            value: "2",
            label: "Active projects",
          ),
        ),
        AppSpacing.w8,
        Expanded(
          child: _buildStatCard(
            icon: Icons.shield_outlined,
            value: "1",
            label: "Pending NDA's",
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0D223F),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20.sp,
          ),
          AppSpacing.h8,
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.h2,
          Text(
            label,
            style: GoogleFonts.outfit(
              color: const Color(0xFF8DA3B5),
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
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
