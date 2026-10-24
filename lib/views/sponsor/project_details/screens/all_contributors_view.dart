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
import '../widgets/investor_contribution_card.dart';

class AllContributorsView extends ConsumerWidget {
  const AllContributorsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);
    final project = ref.watch(sponsorProjectProvider).project;
    final contributions = project.contributions;

    return CommonBackground(
      showGrid: false,
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Sliver App Bar with stats summary
            SliverAppBar(
              pinned: true,
              expandedHeight: 120.h,
              backgroundColor: const Color(0xFF07192F),
              elevation: 0,
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: tc.textPrimary,
                  size: 22.sp,
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(left: 56.w, bottom: 14.h),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "All Contributors",
                      style: GoogleFonts.outfit(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "${contributions.length} Investors • ${project.raisedAmount} Committed",
                      style: GoogleFonts.outfit(
                        fontSize: 10.5.sp,
                        color: const Color(0xFF6B8A9D),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top Spacing & Summary Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppDimens.screenHorizontal,
                  16.h,
                  AppDimens.screenHorizontal,
                  12.h,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Contributor List",
                      style: GoogleFonts.outfit(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: tc.textPrimary,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.primaryColor),
                      ),
                      child: Text(
                        "Goal: ${project.goalAmount}",
                        style: GoogleFonts.outfit(
                          fontSize: 11.5.sp,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sliver List of Contributor Cards
            contributions.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Text(
                        "No contributors found",
                        style: GoogleFonts.outfit(
                          fontSize: 14.sp,
                          color: tc.textTertiary,
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimens.screenHorizontal,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = contributions[index];
                          return InvestorContributionCard(
                            contribution: item,
                            onTap: () {},
                          );
                        },
                        childCount: contributions.length,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
