import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../controllers/sponsor_project_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_theme_colors.dart';
import '../../../core/widgets/common_background.dart';
import 'widgets/investor_contribution_card.dart';
import 'widgets/sponsor_project_bottom_bar.dart';
import 'widgets/sponsor_project_header.dart';
import 'widgets/sponsor_project_stats_card.dart';

class SponsorProjectDetailsView extends StatefulWidget {
  const SponsorProjectDetailsView({super.key});

  @override
  State<SponsorProjectDetailsView> createState() =>
      _SponsorProjectDetailsViewState();
}

class _SponsorProjectDetailsViewState
    extends State<SponsorProjectDetailsView> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final project = context.watch<SponsorProjectProvider>().project;
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
                          SizedBox(height: AppDimens.spaceXxl),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Investor Contributions",
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
                                        () => _isExpanded = !_isExpanded);
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
                                        duration:
                                            const Duration(milliseconds: 250),
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
                          SizedBox(height: AppDimens.spaceMd),
                        ],
                      ),
                    ),
                  ),

                  // Sliver List of Contributor Cards with animated transition
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

            // Bottom Action Bar
            SponsorProjectBottomBar(
              onViewRequests: () => context.push('/collaboration-requests'),
              onPublicView: () => context.push('/public-view'),
              onGroupChatWithAi: () => context.push('/group-chat'),
            ),
          ],
        ),
      ),
    );
  }
}
