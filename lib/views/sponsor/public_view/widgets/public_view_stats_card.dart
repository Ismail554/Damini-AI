import 'package:Braintech/core/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../models/project_public_view_model.dart';
import 'sponsor_profile_card.dart';

class PublicViewStatsCard extends StatelessWidget {
  final ProjectPublicViewModel project;

  const PublicViewStatsCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    final title = project.title.isNotEmpty ? project.title : "Untitled Project";
    final location = project.location.isNotEmpty
        ? project.location
        : "Location N/A";
    final targetRaise = project.targetRaise.isNotEmpty
        ? project.targetRaise
        : "\$0";
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.accentOrange.withValues(alpha: 0.15)
                    : AppColors.accentOrange.withValues(alpha: 0.12),
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
              size: 14.sp,
            ),
            AppSpacing.w4,
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
        SponsorProfileCard(project: project),
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
            style: GoogleFonts.outfit(fontSize: 11.sp, color: tc.textTertiary),
          ),
          AppSpacing.h4,
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: valueColor, size: AppDimens.iconSm),
                AppSpacing.w4,
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
