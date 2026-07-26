import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/app_dimens.dart';
import '../../core/utils/app_theme_colors.dart';
import 'widgets/sponsor_active_project_card.dart';
import 'widgets/sponsor_draft_card.dart';
import 'widgets/sponsor_metric_card.dart';
import 'widgets/sponsor_request_card.dart';

class SponsorDashboard extends StatelessWidget {
  const SponsorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.screenHorizontal,
        vertical: AppDimens.screenVertical,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreetingRow(tc),
          SizedBox(height: AppDimens.spaceXl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SponsorMetricCard(
                label: "Total Views",
                value: "1,248",
                icon: Icons.remove_red_eye_outlined,
              ),
              SponsorMetricCard(
                label: "Active Projects",
                value: "2",
                icon: Icons.layers_outlined,
              ),
              SponsorMetricCard(
                label: "Requests",
                value: "2",
                icon: Icons.group_outlined,
              ),
            ],
          ),
          SizedBox(height: AppDimens.spaceXxl),
          _buildSectionHeader(
            context,
            tc,
            "Active Projects",
            onTapViewAll: () => context.push('/sponsor-projects'),
          ),
          SizedBox(height: AppDimens.paddingMd),
          const SponsorActiveProjectCard(
            title: "Downtown Tech Hub",
            description:
                "A state-of-the-art technology hub located in the heart of downtown Austin.",
            badgeText: "Funding Active",
            raisedAmount: "1.2M",
            goalAmount: "5.0M",
            progress: 0.24,
          ),
          SizedBox(height: AppDimens.spaceXxl),
          _buildSectionHeader(
            context,
            tc,
            "Recent Requests",
            onTapViewAll: () => context.push('/collaboration-requests'),
          ),
          SizedBox(height: AppDimens.paddingMd),
          SponsorRequestCard(
            name: "Venture Partners LLC",
            subtitle: "Requested NDA access for Downtown Tech Hub",
            avatarUrl:
                "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=150&auto=format&fit=crop",
            onReview: () => context.push('/collaboration-requests'),
          ),
          SponsorRequestCard(
            name: "Sarah Jenkins",
            subtitle: "Interested in the EcoTech Solar Farm",
            avatarUrl:
                "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150&auto=format&fit=crop",
            onReview: () => context.push('/collaboration-requests'),
          ),
          SizedBox(height: AppDimens.spaceXl),
          Text(
            "Drafts",
            style: GoogleFonts.outfit(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
            ),
          ),
          SizedBox(height: AppDimens.paddingMd),
          const SponsorDraftCard(
            title: "Urban Logistics Hub",
            lastEdited: "Last edited 2 days ago",
          ),
          SizedBox(height: 80.h),
        ],
      ),
    );
  }

  Widget _buildGreetingRow(AppThemeColors tc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome back",
              style: GoogleFonts.outfit(
                fontSize: 13.sp,
                color: tc.textTertiary,
              ),
            ),
            SizedBox(height: AppDimens.spaceXxs),
            Text(
              "Shawn Blake",
              style: GoogleFonts.outfit(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: tc.textPrimary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: tc.buttonSecondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: tc.borderColor),
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: tc.textPrimary,
                    size: AppDimens.iconLg,
                  ),
                ),
                Positioned(
                  top: 10.h,
                  right: 12.w,
                  child: Container(
                    width: 8.r,
                    height: 8.r,
                    decoration: const BoxDecoration(
                      color: AppColors.accentRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: AppDimens.spaceMd),
            CircleAvatar(
              radius: AppDimens.avatarSm,
              backgroundImage: const NetworkImage(
                "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=150&auto=format&fit=crop",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    AppThemeColors tc,
    String title, {
    VoidCallback? onTapViewAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: tc.textPrimary,
          ),
        ),
        GestureDetector(
          onTap: onTapViewAll,
          child: Text(
            "View All",
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              color: AppColors.accentRed,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
