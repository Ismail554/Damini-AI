import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import 'project_form_field.dart';

class ProjectDetailsSection extends StatelessWidget {
  final TextEditingController statusController;
  final TextEditingController milestonesController;
  final TextEditingController useOfFundsController;
  final TextEditingController sponsorInvestmentController;
  final String? Function(String?)? sponsorInvestmentValidator;

  const ProjectDetailsSection({
    super.key,
    required this.statusController,
    required this.milestonesController,
    required this.useOfFundsController,
    required this.sponsorInvestmentController,
    this.sponsorInvestmentValidator,
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
            "PROJECT DETAILS",
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: AppDimens.spaceMd),
          ProjectFormField(
            label: "What's happening now? (current status)",
            hint: 'e.g. "Permits secured", "Construction started"',
            controller: statusController,
          ),
          SizedBox(height: AppDimens.spaceMd),
          ProjectFormField(
            label: "Next milestones",
            hint: "Upcoming milestones over the next 6-12 months",
            controller: milestonesController,
          ),
          SizedBox(height: AppDimens.spaceMd),
          ProjectFormField(
            label: "Use of funds",
            hint: "How will the requested capital be deployed?",
            controller: useOfFundsController,
          ),
          SizedBox(height: AppDimens.spaceMd),
          ProjectFormField(
            label: "Skin in the game (sponsor investment)",
            hint: "e.g. \$250,000",
            controller: sponsorInvestmentController,
            keyboardType: TextInputType.number,
            validator: sponsorInvestmentValidator,
          ),
        ],
      ),
    );
  }
}
