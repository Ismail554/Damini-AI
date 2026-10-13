import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import 'project_form_field.dart';

class FinancialsSection extends StatelessWidget {
  final TextEditingController minContributionController;
  final TextEditingController expectedRoiController;
  final TextEditingController monthlyRevenueController;
  final TextEditingController holdPeriodController;
  final TextEditingController timelineOpsController;
  final String? Function(String?)? minContributionValidator;
  final String? Function(String?)? expectedRoiValidator;
  final String? Function(String?)? monthlyRevenueValidator;
  final String? Function(String?)? holdPeriodValidator;
  final String? Function(String?)? timelineOpsValidator;

  const FinancialsSection({
    super.key,
    required this.minContributionController,
    required this.expectedRoiController,
    required this.monthlyRevenueController,
    required this.holdPeriodController,
    required this.timelineOpsController,
    this.minContributionValidator,
    this.expectedRoiValidator,
    this.monthlyRevenueValidator,
    this.holdPeriodValidator,
    this.timelineOpsValidator,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimens.paddingMd),
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
          color: tc.borderColor,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "FINANCIALS (NDA-LOCKED FOR INVESTORS)",
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: AppDimens.spaceMd),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ProjectFormField(
                  label: "Min. contribution",
                  hint: "e.g. \$50,000",
                  controller: minContributionController,
                  keyboardType: TextInputType.number,
                  validator: minContributionValidator,
                  labelHeight: 20.h,
                ),
              ),
              SizedBox(width: AppDimens.spaceSm),
              Expanded(
                child: ProjectFormField(
                  label: "Expected ROI (%/yr)",
                  hint: "e.g. 18%",
                  controller: expectedRoiController,
                  keyboardType: TextInputType.number,
                  validator: expectedRoiValidator,
                  labelHeight: 20.h,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimens.spaceMd),
          ProjectFormField(
            label: "Potential monthly revenue",
            hint: "e.g. \$100,000",
            controller: monthlyRevenueController,
            keyboardType: TextInputType.number,
            validator: monthlyRevenueValidator,
          ),
          SizedBox(height: AppDimens.spaceMd),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ProjectFormField(
                  label: "Hold period",
                  hint: "e.g. 36 months",
                  controller: holdPeriodController,
                  validator: holdPeriodValidator,
                  labelHeight: 20.h,
                ),
              ),
              SizedBox(width: AppDimens.spaceSm),
              Expanded(
                child: ProjectFormField(
                  label: "Timeline to operations",
                  hint: "e.g. 6 months",
                  controller: timelineOpsController,
                  validator: timelineOpsValidator,
                  labelHeight: 20.h,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
