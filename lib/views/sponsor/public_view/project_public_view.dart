import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../controllers/auth_provider.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_theme_colors.dart';
import '../../../core/widgets/common_background.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../shared/global_key.dart';
import 'models/project_public_view_model.dart';
import 'widgets/project_public_compact_app_bar.dart';
import 'widgets/project_public_sheet_content.dart';
import 'widgets/public_view_image_header.dart';

class ProjectPublicView extends StatefulWidget {
  final ProjectPublicViewModel? project;

  const ProjectPublicView({super.key, this.project});

  @override
  State<ProjectPublicView> createState() => _ProjectPublicViewState();
}

class _ProjectPublicViewState extends State<ProjectPublicView> {
  // Sheet snap points (fractions of screen height)
  static const double _kCollapsed = 0.18;
  static const double _kRest = 0.54;
  static const double _kExpanded = 0.94;

  int _selectedTabIndex = 0;
  late final PageController _pageController;
  late final DraggableScrollableController _sheetController;

  late final ProjectPublicViewModel _project;

  /// Live sheet extent, used to drive header parallax / dimming / app bar fade.
  double _sheetExtent = _kRest;

  @override
  void initState() {
    super.initState();
    _project = widget.project ?? ProjectPublicViewModel.mockData();
    _pageController = PageController(initialPage: _selectedTabIndex);
    _sheetController = DraggableScrollableController()
      ..addListener(_onSheetMoved);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetMoved);
    _sheetController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  bool _isBookmarked = false;

  void _toggleBookmark() {
    HapticFeedback.lightImpact();
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    if (_isBookmarked) {
      CustomSnackBar.success(context, "Project added to your saved list!");
    } else {
      CustomSnackBar.info(context, "Project removed from your saved list.");
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
    final auth = Provider.of<AuthProvider>(context, listen: false);
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
                    imageUrls: _project.imageUrls,
                    isBookmarked: _isBookmarked,
                    onBookmarkTap: _toggleBookmark,
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
          ),

          // Request Collaboration Button (Investor Role)
          if (isInvestor)
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
                    onPressed: () =>
                        context.push('/request-collaboration', extra: _project),
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
