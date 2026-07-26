import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../models/project_public_view_model.dart';

/// Reusable card displaying sponsor profile info and verification badge.
class SponsorProfileCard extends StatelessWidget {
  final ProjectPublicViewModel project;

  const SponsorProfileCard({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Container(
      padding: EdgeInsets.all(AppDimens.paddingMd),
      decoration: BoxDecoration(
        color: tc.cardInner,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: tc.borderColor,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: AppDimens.avatarSm + 2,
            backgroundImage: project.sponsorAvatarUrl != null
                ? NetworkImage(project.sponsorAvatarUrl!)
                : null,
            child: project.sponsorAvatarUrl == null
                ? Icon(Icons.person, color: tc.textPrimary)
                : null,
          ),
          SizedBox(width: AppDimens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.sponsorName.isNotEmpty
                      ? project.sponsorName
                      : "Sponsor",
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: tc.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  project.sponsorTagline,
                  style: GoogleFonts.outfit(
                    fontSize: 11.sp,
                    color: tc.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (project.isVerifiedSponsor) ...[
            SizedBox(width: 6.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: tc.greenPillBg,
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              child: Text(
                "VERIFIED SPONSOR",
                style: GoogleFonts.outfit(
                  fontSize: 9.sp,
                  color: AppColors.successGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
