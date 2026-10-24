import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Braintech/views/auth/session/controllers/session_provider.dart';
import 'package:Braintech/core/utils/app_dimens.dart';
import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:Braintech/core/widgets/common_background.dart';
import 'package:Braintech/core/widgets/custom_snackbar.dart';
import 'package:Braintech/shared/global_key.dart';
import '../../project_details/controllers/sponsor_project_details_provider.dart';
import '../../project_details/repositories/sponsor_project_details_repository.dart';
import '../../../../core/services/api_error_handler.dart';
import '../models/project_public_view_model.dart';
import '../repositories/project_public_repository.dart';
import '../../saved/controllers/sponsor_saved_provider.dart';
import '../widgets/project_public_compact_app_bar.dart';
import '../widgets/project_public_sheet_content.dart';
import '../widgets/public_view_image_header.dart';
import '../../../../shared/widgets/app_report_bottom_sheet.dart';

class ProjectPublicView extends ConsumerStatefulWidget {
  final String? projectId;
  final ProjectPublicViewModel? project;

  const ProjectPublicView({
    super.key,
    this.projectId,
    this.project,
  });

  @override
  ConsumerState<ProjectPublicView> createState() => _ProjectPublicViewState();
}

class _ProjectPublicViewState extends ConsumerState<ProjectPublicView> {
  // Sheet snap points (fractions of screen height)
  static const double _kCollapsed = 0.18;
  static const double _kRest = 0.54;
  static const double _kExpanded = 0.94;

  int _selectedTabIndex = 0;
  late final PageController _pageController;
  late final DraggableScrollableController _sheetController;

  late ProjectPublicViewModel _project;

  /// Live sheet extent, used to drive header parallax / dimming / app bar fade.
  double _sheetExtent = _kRest;

  @override
  void initState() {
    super.initState();
    final activeProject = ref.read(sponsorProjectProvider).project;
    if (widget.project != null) {
      _project = widget.project!;
    } else if (activeProject.id.isNotEmpty &&
        (widget.projectId == null || widget.projectId == activeProject.id)) {
      _project = activeProject.toPublicViewModel();
    } else {
      _project = ProjectPublicViewModel.mockData();
    }
    _isBookmarked = _project.isSaved;

    final targetId = widget.projectId ??
        (widget.project?.id.isNotEmpty == true ? widget.project!.id : null);
    final isRealId = targetId != null &&
        targetId.isNotEmpty &&
        !targetId.startsWith('pub_') &&
        !targetId.startsWith('draft_');
    if (isRealId) {
      _loadProjectDetails(targetId);
    }

    _pageController = PageController(initialPage: _selectedTabIndex);
    _sheetController = DraggableScrollableController()
      ..addListener(_onSheetMoved);
  }

  bool _isRefreshingDocs = false;

  Future<void> _handleSignNda() async {
    final signed = await context.push<bool>(
      '/sign-nda',
      extra: {
        'projectId': _project.id,
        'disclosingParty': _project.sponsorName,
        'project': _project,
      },
    );

    if (signed == true && mounted) {
      setState(() => _isRefreshingDocs = true);
      await _loadProjectDetails(_project.id);
      if (mounted) {
        setState(() => _isRefreshingDocs = false);
      }
    }
  }

  Future<void> _loadProjectDetails(String id) async {
    try {
      final repo = ref.read(sponsorProjectDetailsRepositoryProvider);
      final details = await repo.fetchProjectDetails(id);
      if (mounted) {
        setState(() {
          _project = details.toPublicViewModel();
          _isBookmarked = _project.isSaved;
        });
      }
    } catch (_) {}
  }

  void _handleReportListing() {
    final intId = int.tryParse(_project.id);
    AppReportBottomSheet.show(
      context,
      title: "Report Listing",
      reportedProjectId: intId,
    );
  }

  @override
  void didUpdateWidget(covariant ProjectPublicView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.project != null && widget.project != oldWidget.project) {
      setState(() {
        _project = widget.project!;
        _isBookmarked = _project.isSaved;
      });
    }
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetMoved);
    _sheetController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  bool _isBookmarked = false;
  bool _isSavingBookmark = false;

  Future<void> _toggleBookmark() async {
    final projectId = _project.id;
    if (projectId.isEmpty || _isSavingBookmark) return;

    HapticFeedback.lightImpact();
    final prev = _isBookmarked;
    setState(() {
      _isBookmarked = !prev;
      _isSavingBookmark = true;
    });

    try {
      final repo = ref.read(projectPublicRepositoryProvider);
      final res = await repo.toggleSaveProject(projectId);
      final isNowSaved = res ?? !prev;

      // Notify SponsorSavedView and provider to update /api/v1/projects/saved/
      ref.read(sponsorSavedProvider.notifier).onProjectBookmarkToggled(
        projectId: projectId,
        isSaved: isNowSaved,
      );

      if (mounted) {
        setState(() {
          _isBookmarked = isNowSaved;
        });
        if (isNowSaved) {
          CustomSnackBar.success(context, "Project added to your saved list!");
        } else {
          CustomSnackBar.info(context, "Project removed from your saved list.");
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBookmarked = prev;
        });
        CustomSnackBar.error(
          context,
          e is AppException ? e.message : "Failed to update saved status: $e",
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingBookmark = false;
        });
      }
    }
  }

  void _onSheetMoved() {
    if (!_sheetController.isAttached) return;
    final next = _sheetController.size;
    if ((next - _sheetExtent).abs() < 0.002) return;
    setState(() => _sheetExtent = next);
  }

  void _onTabSelected(int index) {
    if (index == _selectedTabIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedTabIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  /// Tapping the drag pill toggles between the resting and expanded states.
  void _toggleSheet() {
    if (!_sheetController.isAttached) return;
    final target = _sheetExtent >= (_kExpanded - 0.02) ? _kRest : _kExpanded;
    HapticFeedback.lightImpact();
    _sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  /// 0 -> sheet at rest or below, 1 -> sheet fully expanded.
  double get _expandProgress =>
      ((_sheetExtent - _kRest) / (_kExpanded - _kRest)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    final expand = _expandProgress;
    final headerDim = 0.60 * expand;
    final appBarOpacity = ((expand - 0.72) / 0.28).clamp(0.0, 1.0);

    final isDark = tc.isDark;
    final auth = ref.watch(authProvider);
    final userRole = auth.userRole;
    final isInvestor =
        userRole == GlobalKeys.investorRole ||
        (userRole != GlobalKeys.sponsorRole);

    final sheetGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F2238), Color(0xFF0C1B2C), Color(0xFF081422)],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
          );
    final sheetSolidBg = isDark ? const Color(0xFF0F2238) : Colors.white;

    return CommonBackground(
      showGrid: false,
      topSafeArea: false,
      child: Stack(
        children: [
          // Dynamic image header (scales & stays centered in space above sheet)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: (screenHeight * _sheetExtent) - 24.h,
            child: IgnorePointer(
              ignoring: expand > 0.85,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PublicViewImageHeader(
                    projectId: _project.id,
                    imageUrls: _project.imageUrls,
                    isBookmarked: _isBookmarked,
                    onBookmarkTap: _toggleBookmark,
                    onReportTap: _handleReportListing,
                  ),
                  if (headerDim > 0)
                    IgnorePointer(
                      child: ColoredBox(
                        color: Colors.black.withValues(alpha: headerDim),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Interactive draggable detail sheet
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: _kRest,
            minChildSize: _kCollapsed,
            maxChildSize: _kExpanded,
            snap: true,
            snapSizes: const [_kCollapsed, _kRest, _kExpanded],
            builder: (context, scrollController) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppDimens.radiusXl),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: tc.shadowColor,
                      blurRadius: 28,
                      spreadRadius: 2,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppDimens.radiusXl),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: sheetGradient,
                      border: Border(
                        top: BorderSide(
                          color: tc.borderColor,
                          width: AppDimens.borderThin,
                        ),
                      ),
                    ),
                    child: ProjectPublicSheetContent(
                      project: _project,
                      scrollController: scrollController,
                      expand: expand,
                      selectedTabIndex: _selectedTabIndex,
                      pageController: _pageController,
                      onToggleSheet: _toggleSheet,
                      onTabSelected: _onTabSelected,
                      sheetSolidBg: sheetSolidBg,
                      isInvestor: isInvestor,
                      isRefreshingDocs: _isRefreshingDocs,
                      onSignNda: _handleSignNda,
                      onRefreshDocs: () => _loadProjectDetails(_project.id),
                    ),
                  ),
                ),
              );
            },
          ),

          // Compact top app bar
          ProjectPublicCompactAppBar(
            title: _project.title,
            appBarOpacity: appBarOpacity,
            statusBarHeight: statusBarHeight,
            backgroundColor: sheetSolidBg,
            isBookmarked: _isBookmarked,
            onBackTap: () => Navigator.of(context).maybePop(),
            onBookmarkTap: _toggleBookmark,
            onReportTap: _handleReportListing,
          ),

          // Request Collaboration Button (Investor Role)
          if (isInvestor && !_project.stage.toLowerCase().contains('terminated'))
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.only(
                  left: AppDimens.screenHorizontal,
                  right: AppDimens.screenHorizontal,
                  top: 12.h,
                  bottom: bottomInset > 0 ? bottomInset + 8.h : 16.h,
                ),
                decoration: BoxDecoration(
                  color: sheetSolidBg,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                  border: Border(
                    top: BorderSide(
                      color: tc.borderColor,
                      width: AppDimens.borderThin,
                    ),
                  ),
                ),
                child: SizedBox(
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () async {
                      final submitted = await context.push<bool>(
                        '/request-collaboration',
                        extra: _project,
                      );
                      if (submitted == true && mounted) {
                        _loadProjectDetails(_project.id);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                    ),
                    child: Text(
                      "Request Collaboration",
                      style: GoogleFonts.outfit(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
