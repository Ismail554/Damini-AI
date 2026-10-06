import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/sponsor_project_details_provider.dart';
import 'package:Braintech/core/utils/app_colors.dart';
import 'package:Braintech/core/utils/app_dimens.dart';
import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:Braintech/core/widgets/app_state_widgets.dart';
import 'package:Braintech/core/widgets/common_background.dart';
import 'package:Braintech/core/widgets/custom_snackbar.dart';
import '../../chat/repositories/chat_repository.dart';
import '../../all_projects/controllers/sponsor_projects_provider.dart';
import '../models/sponsor_project_details_model.dart';
import '../widgets/investor_contribution_card.dart';
import '../widgets/sponsor_project_bottom_bar.dart';
import '../widgets/sponsor_project_header.dart';
import '../widgets/sponsor_project_stats_card.dart';
import '../widgets/terminate_project_dialog.dart';

class SponsorProjectDetailsView extends ConsumerStatefulWidget {
  final String? projectId;
  final SponsorProjectDetailsModel? initialProject;

  const SponsorProjectDetailsView({
    super.key,
    this.projectId,
    this.initialProject,
  });

  @override
  ConsumerState<SponsorProjectDetailsView> createState() =>
      _SponsorProjectDetailsViewState();
}

class _SponsorProjectDetailsViewState
    extends ConsumerState<SponsorProjectDetailsView> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    final targetId = widget.projectId ?? widget.initialProject?.id;
    if (targetId != null && targetId.isNotEmpty) {
      Future.microtask(() {
        ref.read(sponsorProjectProvider.notifier).loadProject(targetId);
      });
    }
  }

  Future<void> _handleTerminateProject(
    SponsorProjectDetailsModel project,
  ) async {
    final reason = await TerminateProjectDialog.show(
      context,
      projectTitle: project.title,
    );
    if (reason == null || reason.isEmpty) return;

    if (!mounted) return;
    final success = await ref
        .read(sponsorProjectProvider.notifier)
        .terminateProject(project.id, reason);

    if (!mounted) return;
    if (success) {
      CustomSnackBar.success(
        context,
        "Project has been terminated successfully.",
      );
      ref.invalidate(sponsorProjectsProvider);
    } else {
      final error = ref.read(sponsorProjectProvider).error ??
          "Failed to terminate project.";
      CustomSnackBar.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final state = ref.watch(sponsorProjectProvider);
    final project = (widget.initialProject != null && state.project.id.isEmpty)
        ? widget.initialProject!
        : state.project;

    final effectiveId = widget.projectId ?? project.id;

    if (state.isLoading && project.title.isEmpty) {
      return CommonBackground(
        showGrid: false,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.screenHorizontal,
              vertical: AppDimens.screenVertical,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppShimmer.card(height: 50),
                SizedBox(height: AppDimens.spaceLg),
                const AppShimmer.card(height: 240),
                SizedBox(height: AppDimens.spaceLg),
                const AppShimmer.card(height: 120),
              ],
            ),
          ),
        ),
      );
    }

    if (state.error != null && project.title.isEmpty) {
      return CommonBackground(
        showGrid: false,
        child: SafeArea(
          child: AppErrorView(
            message: state.error!,
            onRetry: () => ref
                .read(sponsorProjectProvider.notifier)
                .loadProject(effectiveId),
          ),
        ),
      );
    }

    final contributions = project.contributions;
    final displayCount = _isExpanded
        ? contributions.length
        : min(2, contributions.length);

    return CommonBackground(
      showGrid: false,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref
                    .read(sponsorProjectProvider.notifier)
                    .loadProject(effectiveId, isRefresh: true),
                color: AppColors.primaryColor,
                backgroundColor: tc.cardBg,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimens.screenHorizontal,
                          vertical: AppDimens.screenVertical,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SponsorProjectHeader(
                              title: project.title,
                              location: project.location,
                              badgeText: project.badgeText,
                              isTerminated: project.badgeText.toLowerCase() == 'terminated',
                              onTerminate: () => _handleTerminateProject(project),
                            ),
                            if (project.badgeText.toLowerCase() == 'terminated' &&
                                project.terminationReason != null &&
                                project.terminationReason!.isNotEmpty) ...[
                              SizedBox(height: AppDimens.spaceMd),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(AppDimens.paddingMd),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                                  border: Border.all(
                                    color: const Color(0xFFDC2626).withValues(alpha: 0.3),
                                    width: AppDimens.borderThin,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      color: const Color(0xFFDC2626),
                                      size: 20.r,
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Project Terminated",
                                            style: GoogleFonts.outfit(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFFDC2626),
                                            ),
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            project.terminationReason!,
                                            style: GoogleFonts.outfit(
                                              fontSize: 12.sp,
                                              color: tc.textSecondary,
                                              height: 1.35,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            SizedBox(height: AppDimens.spaceLg),
                            SponsorProjectStatsCard(project: project),
                            SizedBox(height: AppDimens.spaceLg),

                            // 1. Investment Metrics Breakdown
                            _buildInvestmentMetricsCard(tc, project),
                            SizedBox(height: AppDimens.spaceLg),

                            // 2. Project Details (Long-form Text)
                            if (_hasDetailsContent(project)) ...[
                              _buildProjectDetailsCard(tc, project),
                              SizedBox(height: AppDimens.spaceLg),
                            ],

                            // 3. Documents Section
                            if (project.documents.isNotEmpty) ...[
                              _buildDocumentsSection(
                                context,
                                tc,
                                project.documents,
                              ),
                              SizedBox(height: AppDimens.spaceLg),
                            ],

                            // 4. NDA Signed Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "NDA Signed",
                                  style: GoogleFonts.outfit(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: tc.textPrimary,
                                  ),
                                ),
                                if (contributions.length > 2)
                                  GestureDetector(
                                    onTap: () {
                                      setState(
                                        () => _isExpanded = !_isExpanded,
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          _isExpanded ? "Show Less" : "View All",
                                          style: GoogleFonts.outfit(
                                            fontSize: 13.sp,
                                            color: AppColors.accentOrange,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(width: 2.w),
                                        AnimatedRotation(
                                          turns: _isExpanded ? 0.5 : 0.0,
                                          duration: const Duration(
                                            milliseconds: 250,
                                          ),
                                          child: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: AppColors.accentOrange,
                                            size: 18.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: AppDimens.spaceXs),
                          ],
                        ),
                      ),
                    ),

                    // Contributions or Empty State
                    if (contributions.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimens.screenHorizontal,
                            vertical: AppDimens.spaceMd,
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(AppDimens.paddingLg),
                            decoration: BoxDecoration(
                              color: tc.cardBg,
                              borderRadius:
                                  BorderRadius.circular(AppDimens.radiusMd),
                              border: Border.all(
                                color: tc.borderColor,
                                width: AppDimens.borderThin,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "No investor NDA signed yet",
                                style: GoogleFonts.outfit(
                                  fontSize: 13.sp,
                                  color: tc.textTertiary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimens.screenHorizontal,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = contributions[index];
                              return AnimatedOpacity(
                                duration: const Duration(milliseconds: 250),
                                opacity: 1.0,
                                child: InvestorContributionCard(
                                  contribution: item,
                                  onTap: () {},
                                ),
                              );
                            },
                            childCount: displayCount,
                          ),
                        ),
                      ),

                    SliverToBoxAdapter(
                      child: SizedBox(height: AppDimens.spaceLg),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            SponsorProjectBottomBar(
              onViewRequests: () => context.push(
                '/collaboration-requests',
                extra: {
                  'projectId': project.id,
                  'projectTitle': project.title,
                },
              ),
              onPublicView: () => context.push(
                '/public-view',
                extra: project.toPublicViewModel(),
              ),
              onGroupChatWithAi: () async {
                final projId = int.tryParse(project.id);
                try {
                  final chatRepo = ref.read(chatRepositoryProvider);
                  final conversation = await chatRepo.startConversation(
                    targetUserId: 0,
                    projectId: projId,
                  );
                  if (context.mounted) {
                    context.push(
                      '/group-chat',
                      extra: {
                        'title': conversation.name,
                        'conversationId': conversation.id,
                        'projectId': conversation.project,
                      },
                    );
                  }
                } catch (_) {
                  if (context.mounted) {
                    context.push(
                      '/group-chat',
                      extra: "${project.title} || Group Chat with Ai",
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── 1. Investment Metrics Breakdown ─────────────────────────────

  Widget _buildInvestmentMetricsCard(
    AppThemeColors tc,
    SponsorProjectDetailsModel project,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimens.paddingLg),
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(
          color: tc.borderColor,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: AppColors.accentOrange,
                size: 20.r,
              ),
              SizedBox(width: 8.w),
              Text(
                "Investment Metrics",
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: tc.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimens.spaceMd),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  tc,
                  "Skin in the Game",
                  project.skinInTheGame,
                  Icons.shield_outlined,
                ),
              ),
              SizedBox(width: AppDimens.spaceSm),
              Expanded(
                child: _buildMetricTile(
                  tc,
                  "Hold Period",
                  project.holdPeriodMonths != null
                      ? "${project.holdPeriodMonths} Mos"
                      : "N/A",
                  Icons.lock_clock_outlined,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimens.spaceSm),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  tc,
                  "To Operations",
                  project.timelineToOperationsMonths != null
                      ? "${project.timelineToOperationsMonths} Mos"
                      : "N/A",
                  Icons.schedule_outlined,
                ),
              ),
              SizedBox(width: AppDimens.spaceSm),
              Expanded(
                child: _buildMetricTile(
                  tc,
                  "Monthly Revenue",
                  project.potentialMonthlyRevenue ?? "N/A",
                  Icons.payments_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
    AppThemeColors tc,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: tc.cardInner,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.r, color: tc.textTertiary),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 11.sp,
                    color: tc.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── 2. Project Details (Long-form Text) ──────────────────────────

  bool _hasDetailsContent(SponsorProjectDetailsModel project) {
    return project.businessDescription.isNotEmpty ||
        project.currentStatus.isNotEmpty ||
        project.nextMilestones.isNotEmpty ||
        project.useOfFunds.isNotEmpty;
  }

  Widget _buildProjectDetailsCard(
    AppThemeColors tc,
    SponsorProjectDetailsModel project,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimens.paddingLg),
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(
          color: tc.borderColor,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.text_snippet_outlined,
                color: AppColors.accentOrange,
                size: 20.r,
              ),
              SizedBox(width: 8.w),
              Text(
                "Project Overview & Milestones",
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: tc.textPrimary,
                ),
              ),
            ],
          ),
          if (project.businessDescription.isNotEmpty) ...[
            SizedBox(height: AppDimens.spaceMd),
            _buildSectionBlock(
              tc,
              "Business Description",
              project.businessDescription,
            ),
          ],
          if (project.currentStatus.isNotEmpty) ...[
            SizedBox(height: AppDimens.spaceMd),
            _buildSectionBlock(
              tc,
              "Current Status",
              project.currentStatus,
            ),
          ],
          if (project.nextMilestones.isNotEmpty) ...[
            SizedBox(height: AppDimens.spaceMd),
            _buildSectionBlock(
              tc,
              "Next Milestones",
              project.nextMilestones,
            ),
          ],
          if (project.useOfFunds.isNotEmpty) ...[
            SizedBox(height: AppDimens.spaceMd),
            _buildSectionBlock(
              tc,
              "Use of Funds",
              project.useOfFunds,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionBlock(AppThemeColors tc, String title, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: tc.textSecondary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          body,
          style: GoogleFonts.outfit(
            fontSize: 13.sp,
            color: tc.textPrimary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ── 3. Documents Section ────────────────────────────────────────

  Widget _buildDocumentsSection(
    BuildContext context,
    AppThemeColors tc,
    List<ProjectDocumentModel> documents,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Documents",
          style: GoogleFonts.outfit(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: tc.textPrimary,
          ),
        ),
        SizedBox(height: AppDimens.spaceSm),
        ...documents.map((doc) => _buildDocumentCard(context, tc, doc)),
      ],
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    AppThemeColors tc,
    ProjectDocumentModel doc,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDimens.spaceSm),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.paddingMd,
        vertical: AppDimens.paddingSm + 2,
      ),
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: tc.borderColor,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: tc.cardInner,
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: Icon(
              Icons.description_outlined,
              color: AppColors.accentOrange,
              size: 20.r,
            ),
          ),
          SizedBox(width: AppDimens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.title,
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: tc.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (doc.isConfidential) ...[
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: tc.logoutBg,
                      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                    ),
                    child: Text(
                      "Confidential",
                      style: GoogleFonts.outfit(
                        fontSize: 10.sp,
                        color: AppColors.accentOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              CustomSnackBar.info(context, "Opening ${doc.title}");
            },
            icon: Icon(
              Icons.download_rounded,
              color: tc.textSecondary,
              size: 20.r,
            ),
          ),
        ],
      ),
    );
  }
}
