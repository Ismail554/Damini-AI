import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../models/project_public_view_model.dart';

class OverviewTabContent extends StatelessWidget {
  final ProjectPublicViewModel project;

  const OverviewTabContent({
    super.key,
    required this.project,
  });

  static const _avatarColors = [
    Color(0xFF3B82F6), // Blue
    Color(0xFFEC4899), // Pink
    Color(0xFF2563EB), // Royal Blue
    Color(0xFF10B981), // Emerald
  ];

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    final overviewText = project.overviewText.isNotEmpty
        ? project.overviewText
        : "No overview description provided.";
    final timeline = project.timeline.isNotEmpty ? project.timeline : "N/A";
    final teamSize = project.teamSize.isNotEmpty ? project.teamSize : "N/A";

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: AppDimens.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Overview Paragraph
          Text(
            overviewText,
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              color: tc.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: AppDimens.spaceLg),

          // 2 Quick Info Cards (Timeline & Team Size)
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  tc: tc,
                  icon: Icons.calendar_today_outlined,
                  label: "Timeline",
                  value: timeline,
                ),
              ),
              SizedBox(width: AppDimens.spaceMd),
              Expanded(
                child: _buildInfoCard(
                  tc: tc,
                  icon: Icons.people_outline_rounded,
                  label: "Team Size",
                  value: teamSize,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimens.spaceXxl),

          // Overview Team Section
          Text(
            "Overview",
            style: GoogleFonts.outfit(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
            ),
          ),
          SizedBox(height: AppDimens.spaceMd),

          if (project.teamMembers.isEmpty)
            Text(
              "No team member information available.",
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                color: tc.textTertiary,
              ),
            )
          else
            ...List.generate(project.teamMembers.length, (index) {
              final member = project.teamMembers[index];
              final avatarColor = _avatarColors[index % _avatarColors.length];

              return Container(
                margin: EdgeInsets.only(bottom: AppDimens.spaceMd),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18.r,
                      backgroundColor: avatarColor,
                      child: Text(
                        member.initials,
                        style: GoogleFonts.outfit(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: AppDimens.spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
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
                            member.role,
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
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required AppThemeColors tc,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(AppDimens.paddingMd),
      decoration: BoxDecoration(
        color: tc.cardInner,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: tc.borderColor, width: AppDimens.borderThin),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: tc.cardHeader,
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: Icon(icon, color: tc.textPrimary, size: AppDimens.iconSm),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 10.sp,
                    color: tc.textTertiary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: tc.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
