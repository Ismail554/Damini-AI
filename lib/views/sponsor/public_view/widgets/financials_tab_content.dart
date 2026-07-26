import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../models/project_public_view_model.dart';

class FinancialsTabContent extends StatelessWidget {
  final ProjectPublicViewModel project;

  const FinancialsTabContent({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: AppDimens.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            "FINANCIALS DETAILS",
            style: GoogleFonts.outfit(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: AppDimens.spaceLg),

          // Row 1: Min contribution & Expected ROI
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildFinancialMetric(
                  tc: tc,
                  label: "Min. contribution",
                  value: project.minContribution,
                ),
              ),
              SizedBox(width: AppDimens.spaceLg),
              Expanded(
                child: _buildFinancialMetric(
                  tc: tc,
                  label: "Expected ROI (%/yr)",
                  value: project.expectedRoi,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimens.spaceXl),

          // Row 2: Potential monthly revenue & Hold period
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildFinancialMetric(
                  tc: tc,
                  label: "Potential monthly revenue",
                  value: project.monthlyRevenue,
                ),
              ),
              SizedBox(width: AppDimens.spaceLg),
              Expanded(
                child: _buildFinancialMetric(
                  tc: tc,
                  label: "Hold period",
                  value: project.holdPeriod,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimens.spaceXl),

          // Row 3: Timeline to operations
          _buildFinancialMetric(
            tc: tc,
            label: "Timeline to operations",
            value: project.timelineToOperations,
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialMetric({
    required AppThemeColors tc,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13.sp,
            color: tc.textSecondary,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: tc.textPrimary,
          ),
        ),
      ],
    );
  }
}
