import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';

class NdaAgreementCard extends StatelessWidget {
  const NdaAgreementCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Container(
      padding: EdgeInsets.all(AppDimens.paddingLg),
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.25),
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            tc: tc,
            title: "1. Confidential Information.",
            body:
                "The term \"Confidential Information\" includes all information, whether written or oral, disclosed by the Disclosing Party to the Receiving Party that is designated as confidential or that reasonably should be understood to be confidential given the nature of the information and the circumstances of disclosure.",
          ),
          SizedBox(height: AppDimens.spaceLg),
          _buildSection(
            tc: tc,
            title: "2. Obligations.",
            body:
                "The Receiving Party agrees to: (a) hold the Confidential Information in strict confidence; (b) not disclose the Confidential Information to any third party; and (c) not use the Confidential Information for any purpose other than evaluating a potential business relationship with the Disclosing Party.",
          ),
          SizedBox(height: AppDimens.spaceLg),
          _buildSection(
            tc: tc,
            title: "3. Exclusions.",
            body:
                "Confidential Information does not include information that: (a) is or becomes publicly known through no fault of the Receiving Party; (b) was rightfully known by the Receiving Party prior to disclosure; or (c) is independently developed by the Receiving Party without use of the Confidential Information.",
          ),
          SizedBox(height: AppDimens.spaceLg),
          _buildSection(
            tc: tc,
            title: "4. Term.",
            body:
                "The obligations under this Agreement shall survive for a period of three (3) years from the date of disclosure.",
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required AppThemeColors tc,
    required String title,
    required String body,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: tc.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          body,
          style: GoogleFonts.outfit(
            fontSize: 12.sp,
            color: tc.textSecondary.withValues(alpha: 0.85),
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
