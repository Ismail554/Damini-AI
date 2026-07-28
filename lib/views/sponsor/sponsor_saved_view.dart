import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/utils/app_theme_colors.dart';
import '../../core/widgets/common_background.dart';
import 'saved/controllers/sponsor_saved_provider.dart';
import 'saved/widgets/sponsor_saved_profile_card.dart';
import 'saved/widgets/sponsor_saved_project_card.dart';

class SponsorSavedView extends StatelessWidget {
  const SponsorSavedView({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return ChangeNotifierProvider(
      create: (_) => SponsorSavedProvider(),
      child: CommonBackground(
        showGrid: false,
        child: SafeArea(
          child: Consumer<SponsorSavedProvider>(
            builder: (context, provider, _) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 16.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Saved",
                      style: GoogleFonts.outfit(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: tc.textPrimary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildTabPills(provider),
                    SizedBox(height: 20.h),
                    _buildSortRow(context, tc, provider),
                    SizedBox(height: 16.h),
                    _buildContentList(provider),
                    SizedBox(height: 80.h),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabPills(SponsorSavedProvider provider) {
    final isProjects = provider.currentTab == SavedTab.projects;

    return Row(
      children: [
        GestureDetector(
          onTap: () => provider.selectTab(SavedTab.projects),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isProjects
                  ? const Color(0xFF006EDB)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(22.r),
              border: isProjects
                  ? null
                  : Border.all(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.6),
                      width: 1.5.w,
                    ),
            ),
            child: Text(
              "Saved Projects",
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                fontWeight: isProjects ? FontWeight.bold : FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: () => provider.selectTab(SavedTab.profiles),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: !isProjects
                  ? const Color(0xFF006EDB)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(22.r),
              border: !isProjects
                  ? null
                  : Border.all(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.6),
                      width: 1.5.w,
                    ),
            ),
            child: Text(
              "Saved Profile",
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                fontWeight: !isProjects ? FontWeight.bold : FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSortRow(
    BuildContext context,
    AppThemeColors tc,
    SponsorSavedProvider provider,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${provider.resultsCount} results",
          style: GoogleFonts.outfit(
            fontSize: 14.sp,
            color: tc.textSecondary,
          ),
        ),
        PopupMenuButton<String>(
          initialValue: provider.selectedSort,
          onSelected: provider.setSortOption,
          color: tc.isDark ? const Color(0xFF091E36) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          itemBuilder: (context) => const [
            PopupMenuItem(value: "Newest", child: Text("Sort by: Newest")),
            PopupMenuItem(value: "Oldest", child: Text("Sort by: Oldest")),
            PopupMenuItem(
              value: "Highest ROI",
              child: Text("Sort by: Highest ROI"),
            ),
          ],
          child: Row(
            children: [
              Text(
                "Sort by: ${provider.selectedSort}",
                style: GoogleFonts.outfit(
                  fontSize: 14.sp,
                  color: tc.textSecondary,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: tc.textSecondary,
                size: 20.r,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentList(SponsorSavedProvider provider) {
    if (provider.currentTab == SavedTab.projects) {
      if (provider.projects.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Center(
            child: Text(
              "No saved projects",
              style: GoogleFonts.outfit(fontSize: 14.sp, color: Colors.grey),
            ),
          ),
        );
      }
      return Column(
        children: provider.projects.map((item) {
          return SponsorSavedProjectCard(
            item: item,
            onBookmarkTap: () => provider.removeProject(item.id),
          );
        }).toList(),
      );
    } else {
      if (provider.profiles.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Center(
            child: Text(
              "No saved profiles",
              style: GoogleFonts.outfit(fontSize: 14.sp, color: Colors.grey),
            ),
          ),
        );
      }
      return Column(
        children: provider.profiles.map((item) {
          return SponsorSavedProfileCard(
            item: item,
            onBookmarkTap: () => provider.removeProfile(item.id),
          );
        }).toList(),
      );
    }
  }
}
