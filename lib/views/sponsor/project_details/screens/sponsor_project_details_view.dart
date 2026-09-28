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
import '../models/sponsor_project_details_model.dart';
import '../widgets/investor_contribution_card.dart';
import '../widgets/sponsor_project_bottom_bar.dart';
import '../widgets/sponsor_project_header.dart';
import '../widgets/sponsor_project_stats_card.dart';

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
                            ),
                            SizedBox(height: AppDimens.spaceLg),
                            SponsorProjectStatsCard(project: project),
                            if (project.documents.isNotEmpty)
                              _buildDocumentsSection(
                                context,
                                tc,
                                project.documents,
                              ),
                            SizedBox(height: AppDimens.spaceLg),
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
              onViewRequests: () => context.push('/collaboration-requests'),
              onPublicView: () => context.push('/public-view'),
              onGroupChatWithAi: () => context.push(
                '/group-chat',
                extra: "${project.title} || Group Chat with Ai",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsSection(
    BuildContext context,
    AppThemeColors tc,
    List<ProjectDocumentModel> documents,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppDimens.spaceLg),
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
