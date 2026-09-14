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
import 'package:Braintech/core/widgets/common_background.dart';
import '../models/sponsor_project_details_model.dart';
import '../widgets/investor_contribution_card.dart';
import '../widgets/sponsor_project_bottom_bar.dart';
import '../widgets/sponsor_project_header.dart';
import '../widgets/sponsor_project_stats_card.dart';

class SponsorProjectDetailsView extends ConsumerStatefulWidget {
  final SponsorProjectDetailsModel? initialProject;

  const SponsorProjectDetailsView({super.key, this.initialProject});

  @override
  ConsumerState<SponsorProjectDetailsView> createState() =>
      _SponsorProjectDetailsViewState();
}

class _SponsorProjectDetailsViewState extends ConsumerState<SponsorProjectDetailsView> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final fallbackProject = ref.watch(sponsorProjectProvider).project;
    final project = widget.initialProject ?? fallbackProject;
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
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
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
                          SizedBox(height: AppDimens.spaceSmd),
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
                                    setState(() => _isExpanded = !_isExpanded);
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
                          SizedBox(height: AppDimens.spaceXxs),
                        ],
                      ),
                    ),
                  ),

                  // Sliver List of Contributor Cards
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimens.screenHorizontal,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = contributions[index];
                        return AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity: 1.0,
                          child: InvestorContributionCard(
                            contribution: item,
                            onTap: () {},
                          ),
                        );
                      }, childCount: displayCount),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: SizedBox(height: AppDimens.spaceLg),
                  ),
                ],
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
}
