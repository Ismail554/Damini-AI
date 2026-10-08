import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Braintech/core/utils/app_colors.dart';
import 'package:Braintech/core/utils/app_dimens.dart';
import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:Braintech/core/widgets/app_state_widgets.dart';
import 'package:Braintech/core/widgets/common_background.dart';
import '../../dashboard/widgets/sponsor_active_project_card.dart';
import '../controllers/sponsor_projects_provider.dart';
import '../models/sponsor_project_model.dart';
import '../widgets/projects_tab_bar.dart';

class SponsorProjectsView extends ConsumerStatefulWidget {
  const SponsorProjectsView({super.key});

  @override
  ConsumerState<SponsorProjectsView> createState() =>
      _SponsorProjectsViewState();
}

class _SponsorProjectsViewState extends ConsumerState<SponsorProjectsView> {
  int _selectedTabIndex = 0;
  late final PageController _pageController;

  static const _tabs = [
    "All Projects",
    "Active Projects",
    "Completed",
    "Terminated",
  ];

  @override
  void initState() {
    super.initState();
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
    final projectsState = ref.watch(sponsorProjectsProvider);

    return CommonBackground(
      showGrid: false,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimens.screenHorizontal,
                vertical: AppDimens.paddingSm,
              ),
              child: _buildHeader(context, tc),
            ),
            SizedBox(height: 8.h),
            ProjectsTabBar(
              selectedIndex: _selectedTabIndex,
              onTabSelected: _onTabSelected,
              tabs: _tabs,
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _selectedTabIndex = index);
                },
                children: [
                  _buildTabContent(projectsState, projectsState.allProjects,
                      "No projects found"),
                  _buildTabContent(projectsState, projectsState.activeProjects,
                      "No active projects found"),
                  _buildTabContent(
                      projectsState,
                      projectsState.completedProjects,
                      "No completed projects found"),
                  _buildTabContent(
                      projectsState,
                      projectsState.terminatedProjects,
                      "No terminated projects found"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppThemeColors tc) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: tc.buttonSecondary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: tc.borderColor,
                    width: AppDimens.borderThin,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: tc.textPrimary,
                  size: AppDimens.iconMd,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: AppDimens.spaceMd),
        Text(
          "Projects",
          style: GoogleFonts.outfit(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: tc.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(
    SponsorProjectsState state,
    List<SponsorProjectModel> list,
    String emptyMessage,
  ) {
    final tc = AppThemeColors.of(context);

    if (state.isLoading && state.allProjects.isEmpty) {
      return _buildShimmerList();
    }

    if (state.error != null && state.allProjects.isEmpty) {
      return AppErrorView(
        message: state.error!,
        onRetry: () => ref.read(sponsorProjectsProvider.notifier).refresh(),
      );
    }

    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.read(sponsorProjectsProvider.notifier).refresh(),
        color: AppColors.primaryColor,
        backgroundColor: tc.cardBg,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            SizedBox(height: 60.h),
            AppEmptyView.projects(
              title: emptyMessage,
              subtitle: "Start funding your dream by launching and showcasing your project to verified investors.",
              actionLabel: "Create Project",
              onAction: () => context.push('/create-project'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(sponsorProjectsProvider.notifier).refresh(),
      color: AppColors.primaryColor,
      backgroundColor: tc.cardBg,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.screenHorizontal,
          vertical: AppDimens.paddingSm,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 250 + (index * 60)),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, (1 - value) * 16),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(bottom: AppDimens.spaceLg),
              child: SponsorActiveProjectCard(
                id: item.id,
                title: item.title,
                description: item.description,
                badgeText: item.badgeText,
                raisedAmount: item.raisedAmount,
                goalAmount: item.goalAmount,
                progress: item.progress,
                imageUrl: item.imageUrl,
                category: item.category,
                onTap: () => context.push(
                  '/sponsor-project-details',
                  extra: item.id,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.screenHorizontal,
        vertical: AppDimens.paddingSm,
      ),
      itemCount: 3,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: AppDimens.spaceLg),
        child: const AppShimmer.card(height: 180),
      ),
    );
  }
}