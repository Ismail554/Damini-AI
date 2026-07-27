import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/app_dimens.dart';
import '../../core/utils/app_theme_colors.dart';
import 'create_project/controllers/project_draft_provider.dart';
import 'widgets/sponsor_active_project_card.dart';
import 'widgets/sponsor_draft_card.dart';
import 'widgets/sponsor_metric_card.dart';
import 'widgets/sponsor_request_card.dart';

class SponsorDashboard extends StatelessWidget {
  const SponsorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final draftProvider = context.watch<ProjectDraftProvider>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.screenHorizontal,
        vertical: AppDimens.screenVertical,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreetingRow(context, tc),
          SizedBox(height: AppDimens.spaceXl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SponsorMetricCard(
                  label: "Total Raised",
                  value: "\$1.00M",
                  icon: Icons.monetization_on_outlined,
                ),
              ),
              SizedBox(width: AppDimens.spaceSm),
              Expanded(
                child: SponsorMetricCard(
                  label: "Active Investors",
                  value: "3",
                  icon: Icons.people_outline_rounded,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimens.spaceXl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "My Projects",
                style: GoogleFonts.outfit(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: tc.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/sponsor-projects'),
                child: Text(
                  "View All",
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    color: AppColors.accentOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimens.paddingMd),
          SponsorActiveProjectCard(
            title: "Downtown Tech Hub",
            description:
                "A premium tech incubation hub offering modern workspace, labs, and strategic funding.",
            badgeText: "Funding Active",
            raisedAmount: "\$1.00M",
            goalAmount: "\$5.00M",
            progress: 0.20,
            imageUrl:
                "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=600&auto=format&fit=crop",
            onTap: () => context.push('/sponsor-project-details'),
          ),
          SizedBox(height: AppDimens.spaceXl),
          Text(
            "Collaboration Requests",
            style: GoogleFonts.outfit(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
            ),
          ),
          SizedBox(height: AppDimens.paddingMd),
          SponsorRequestCard(
            name: "Sarah Jenkins",
            subtitle: "Interested in EcoTech Solar Farm",
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

          if (draftProvider.drafts.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Text(
                "No project drafts saved",
                style: GoogleFonts.outfit(
                  fontSize: 13.sp,
                  color: tc.textTertiary,
                ),
              ),
            )
          else
            ...draftProvider.drafts.map(
              (draft) => Padding(
                padding: EdgeInsets.only(bottom: AppDimens.paddingSm),
                child: SponsorDraftCard(
                  title: draft.title,
                  lastEdited: draft.lastEdited,
                  onTap: () => context.push('/create-project', extra: draft),
                ),
              ),
            ),
          SizedBox(height: 80.h),
        ],
      ),
    );
  }

  Widget _buildGreetingRow(BuildContext context, AppThemeColors tc) {
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
            GestureDetector(
              onTap: () => context.push('/notifications'),
              child: Stack(
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
            ),
            SizedBox(width: AppDimens.spaceMd),
            CircleAvatar(
              radius: AppDimens.avatarSm,
              backgroundImage: const NetworkImage(
                "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150&auto=format&fit=crop",
              ),
            ),
          ],
        ),
      ],
    );
  }
}
