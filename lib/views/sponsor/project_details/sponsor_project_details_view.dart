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

class SponsorProjectDetailsView extends StatelessWidget {
  const SponsorProjectDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final project = context.watch<SponsorProjectProvider>().project;

    return CommonBackground(
      showGrid: false,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
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

                    // Section Header: Investor Contributions
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
                        Text(
                          "View All",
                          style: GoogleFonts.outfit(
                            fontSize: 13.sp,
                            color: AppColors.accentOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimens.spaceMd),

                    // Investor List Items
                    ...project.contributions.map(
                      (item) => InvestorContributionCard(
                        contribution: item,
                        onTap: () {},
                      ),
                    ),
                    SizedBox(height: AppDimens.spaceLg),
                  ],
                ),
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
