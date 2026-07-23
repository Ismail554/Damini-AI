import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../models/project_public_view_model.dart';

class PublicViewStatsCard extends StatelessWidget {
  final ProjectPublicViewModel project;

  const PublicViewStatsCard({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    final title = project.title.isNotEmpty ? project.title : "Untitled Project";
    final location = project.location.isNotEmpty ? project.location : "Location N/A";
    final targetRaise = project.targetRaise.isNotEmpty ? project.targetRaise : "\$0";
    final targetRoi = project.targetRoi.isNotEmpty ? project.targetRoi : "0%";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pill Badges Row
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: tc.pillBg,
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              child: Text(
                project.category.isNotEmpty ? project.category : "Category",
                style: GoogleFonts.outfit(
                  fontSize: 11.sp,
                  color: tc.pillText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFF3B1E19).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              child: Text(
                project.stage.isNotEmpty ? project.stage : "Stage",
                style: GoogleFonts.outfit(
                  fontSize: 11.sp,
                  color: AppColors.accentOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimens.spaceMd),

        // Title and Location
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: tc.textPrimary,
          ),
        ),
        SizedBox(height: AppDimens.spaceXxs),
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: tc.textTertiary,
              size: 14.r,
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                location,
                style: GoogleFonts.outfit(
                  fontSize: 13.sp,
                  color: tc.textTertiary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimens.spaceLg),

        // 2 Side-by-Side Highlight Stat Boxes
        Row(
          children: [
            Expanded(
              child: _buildHighlightBox(
                tc: tc,
                label: "Target Raise",
                value: targetRaise,
                valueColor: tc.textPrimary,
              ),
            ),
            SizedBox(width: AppDimens.spaceMd),
            Expanded(
              child: _buildHighlightBox(
                tc: tc,
                label: "Target ROI",
                value: targetRoi,
                valueColor: AppColors.accentOrange,
                icon: Icons.trending_up_rounded,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimens.spaceLg),

        // Sponsor Profile Hero Card
        Container(
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
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
        ),
      ],
    );
  }

  Widget _buildHighlightBox({
    required AppThemeColors tc,
    required String label,
    required String value,
    required Color valueColor,
    IconData? icon,
  }) {
    return Container(
      padding: EdgeInsets.all(AppDimens.paddingMd),
      decoration: BoxDecoration(
        color: tc.cardInner,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: tc.borderColor, width: AppDimens.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11.sp,
              color: tc.textTertiary,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: valueColor, size: AppDimens.iconSm),
                SizedBox(width: 4.w),
              ],
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
