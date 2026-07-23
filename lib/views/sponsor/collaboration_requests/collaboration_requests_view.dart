import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/widgets/common_background.dart';
import 'models/collaboration_request_model.dart';
import 'widgets/collaboration_card.dart';
import 'widgets/collaboration_tab_bar.dart';

class CollaborationRequestsView extends StatefulWidget {
  const CollaborationRequestsView({super.key});

  @override
  State<CollaborationRequestsView> createState() =>
      _CollaborationRequestsViewState();
}

class _CollaborationRequestsViewState
    extends State<CollaborationRequestsView> {
  int _selectedTabIndex = 0;
  late final PageController _pageController;

  final List<CollaborationRequestModel> _pendingList =
      CollaborationRequestModel.mockPendingList();
  final List<CollaborationRequestModel> _historyList =
      CollaborationRequestModel.mockHistoryList();

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

    return CommonBackground(
      showGrid: false,
      child: SafeArea(
        child: Column(
          children: [
            // Top Bar & Tab Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimens.screenHorizontal,
                vertical: AppDimens.screenVertical,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusPill),
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
                        "Collaboration Requests",
                        style: GoogleFonts.outfit(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: tc.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimens.spaceLg),

                  // Tab Bar Switcher
                  CollaborationTabBar(
                    selectedIndex: _selectedTabIndex,
                    onTabSelected: _onTabSelected,
                  ),
                ],
              ),
            ),

            // Swipeable PageView Body Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _selectedTabIndex = index);
                },
                children: [
                  _buildListView(_pendingList),
                  _buildListView(_historyList),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<CollaborationRequestModel> list) {
    if (list.isEmpty) {
      final tc = AppThemeColors.of(context);
      return Center(
        child: Text(
          "No requests found",
          style: GoogleFonts.outfit(
            fontSize: 14.sp,
            color: tc.textTertiary,
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.screenHorizontal,
        vertical: AppDimens.paddingSm,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return CollaborationCard(
          item: item,
          onLeftAction: () {
            setState(() {
              list.removeAt(index);
            });
          },
          onRightAction: () {},
        );
      },
    );
  }
}
