import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_theme_colors.dart';
import '../../../core/widgets/common_background.dart';
import 'models/project_public_view_model.dart';
import 'widgets/details_tab_content.dart';
import 'widgets/documents_tab_content.dart';
import 'widgets/overview_tab_content.dart';
import 'widgets/public_view_image_header.dart';
import 'widgets/public_view_stats_card.dart';
import 'widgets/public_view_tab_bar.dart';

class ProjectPublicView extends StatefulWidget {
  final ProjectPublicViewModel? project;

  const ProjectPublicView({
    super.key,
    this.project,
  });

  @override
  State<ProjectPublicView> createState() => _ProjectPublicViewState();
}

class _ProjectPublicViewState extends State<ProjectPublicView> {
  int _selectedTabIndex = 0;
  late final PageController _pageController;

  late final ProjectPublicViewModel _project;

  @override
  void initState() {
    super.initState();
    _project = widget.project ?? ProjectPublicViewModel.mockData();
    _pageController = PageController(initialPage: _selectedTabIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() => _selectedTabIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return CommonBackground(
      showGrid: false,
      child: SafeArea(
        child: Column(
          children: [
            // Image Header Banner
            PublicViewImageHeader(imageUrls: _project.imageUrls),

            // Scrollable Content Overlapping Image
            Expanded(
              child: Container(
                transform: Matrix4.translationValues(0, -20.h, 0),
                decoration: BoxDecoration(
                  color: tc.cardBg,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppDimens.radiusXl),
                  ),
                  border: Border.all(
                    color: tc.borderColor,
                    width: AppDimens.borderThin,
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.screenHorizontal,
                  vertical: AppDimens.screenVertical,
                ),
                child: Column(
                  children: [
                    // Stats Card Header
                    PublicViewStatsCard(project: _project),
                    SizedBox(height: AppDimens.spaceLg),

                    // 3 Tab Switcher
                    PublicViewTabBar(
                      selectedIndex: _selectedTabIndex,
                      onTabSelected: _onTabSelected,
                    ),

                    // Swipeable Tab View
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const BouncingScrollPhysics(),
                        onPageChanged: (index) {
                          setState(() => _selectedTabIndex = index);
                        },
                        children: [
                          OverviewTabContent(project: _project),
                          DetailsTabContent(project: _project),
                          DocumentsTabContent(project: _project),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
