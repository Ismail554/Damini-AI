import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../models/project_public_view_model.dart';

class DetailsTabContent extends StatelessWidget {
  final ProjectPublicViewModel project;

  const DetailsTabContent({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    final description = project.businessDescription.isNotEmpty
        ? project.businessDescription
        : "No detailed business description available for this project.";

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: AppDimens.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Business Description",
            style: GoogleFonts.outfit(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
            ),
          ),
          SizedBox(height: AppDimens.spaceMd),
          Text(
            description,
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              color: tc.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
