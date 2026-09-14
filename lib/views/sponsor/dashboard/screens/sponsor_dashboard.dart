import 'package:Braintech/core/utils/app_spacing.dart';
import 'package:Braintech/core/utils/asset_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Braintech/core/utils/app_colors.dart';
import 'package:Braintech/core/utils/app_dimens.dart';
import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:Braintech/core/widgets/custom_snackbar.dart';
import '../../create_project/controllers/project_draft_provider.dart';
import '../controllers/sponsor_dashboard_provider.dart';
import '../widgets/sponsor_active_project_card.dart';
import '../widgets/sponsor_draft_card.dart';
import '../widgets/sponsor_metric_card.dart';
import '../../../profile/widgets/profile_quick_view_sheet.dart';
import '../widgets/sponsor_request_card.dart';

class SponsorDashboard extends ConsumerWidget {
  const SponsorDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);
    final dashboardState = ref.watch(sponsorDashboardProvider);
    final draftProvider = ref.watch(projectDraftProvider);

    final metrics = dashboardState.metrics;
    final activeProject = dashboardState.activeProject;
    final requests = dashboardState.requests;

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
          if (metrics.length >= 2)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SponsorMetricCard(
                    label: metrics[0].label,
                    value: metrics[0].value,
                    icon: metrics[0].icon,
                  ),
                ),
                SizedBox(width: AppDimens.spaceSm),
                Expanded(
                  child: SponsorMetricCard(
                    label: metrics[1].label,
                    value: metrics[1].value,
                    icon: metrics[1].icon,
                  ),
                ),
              ],
            )
          else
            const SizedBox.shrink(),
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
          if (activeProject != null)
            SponsorActiveProjectCard(
              title: activeProject.title,
              description: activeProject.description,
              badgeText: activeProject.badgeText,
              raisedAmount: activeProject.raisedAmount,
              goalAmount: activeProject.goalAmount,
              progress: activeProject.progress,
              imageUrl: activeProject.imageUrl,
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
          if (requests.isNotEmpty)
            ...requests.map(
              (req) => SponsorRequestCard(
                name: req.name,
                subtitle: req.subtitle,
                avatarUrl: req.avatarUrl,
                onReview: () => context.push('/collaboration-requests'),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Text(
                "No pending requests",
                style: GoogleFonts.outfit(
                  fontSize: 13.sp,
                  color: tc.textTertiary,
                ),
              ),
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
                  dismissKey: ValueKey(draft.id),
                  title: draft.title,
                  lastEdited: draft.lastEdited,
                  onTap: () => context.push('/create-project', extra: draft),
                  onDelete: () async {
                    await ref
                        .read(projectDraftProvider.notifier)
                        .deleteDraft(draft.id);
                    if (context.mounted) {
                      CustomSnackBar.success(context, "Draft deleted");
                    }
                  },
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
        Row(
          children: [
            Image.asset(IconAssets.rawLogo, height: 46.h, width: 36.w),
            AppSpacing.w6,
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
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => context.push('/notifications'),
              child: Stack(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.h,
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
                      width: 8.w,
                      height: 8.h,
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
            GestureDetector(
              onTap: () => ProfileQuickViewSheet.show(context),
              child: CircleAvatar(
                radius: AppDimens.avatarSm,
                backgroundImage: const NetworkImage(
                  "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150&auto=format&fit=crop",
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
