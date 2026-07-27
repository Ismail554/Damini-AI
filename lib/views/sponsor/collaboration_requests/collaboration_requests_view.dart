import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/sponsor_project_provider.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import 'widgets/collaboration_card.dart';
import 'widgets/collaboration_confirmation_card.dart';
import 'widgets/collaboration_requests_header.dart';

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
    final provider = context.watch<SponsorProjectProvider>();

    return CommonBackground(
      showGrid: false,
      child: SafeArea(
        child: Column(
          children: [
            CollaborationRequestsHeader(
              selectedTabIndex: _selectedTabIndex,
              onTabSelected: _onTabSelected,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _selectedTabIndex = index);
                },
                children: [
                  _buildPendingListView(provider),
                  _buildApprovedListView(provider),
                  _buildConfirmationListView(provider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingListView(SponsorProjectProvider provider) {
    final list = provider.pendingList;
    if (list.isEmpty) return _buildEmptyState("No pending requests");

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
          onLeftAction: () => provider.rejectPendingRequest(item.id),
          onRightAction: () {
            provider.approvePendingRequest(item);
            CustomSnackBar.success(
              context,
              "Approved request from ${item.investorName}!",
            );
          },
        );
      },
    );
  }

  Widget _buildApprovedListView(SponsorProjectProvider provider) {
    final list = provider.approvedList;
    if (list.isEmpty) return _buildEmptyState("No approved requests");

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
          onLeftAction: () {},
          onRightAction: () => context.push('/group-chat'),
        );
      },
    );
  }

  Widget _buildConfirmationListView(SponsorProjectProvider provider) {
    final list = provider.confirmationList;
    if (list.isEmpty) return _buildEmptyState("No confirmations found");

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.screenHorizontal,
        vertical: AppDimens.paddingSm,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return CollaborationConfirmationCard(
          item: item,
          onFundReceived: () {
            provider.markFundReceived(item.id);
            CustomSnackBar.success(
              context,
              "Fund received marked for ${item.investorName}!",
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    final tc = AppThemeColors.of(context);
    return Center(
      child: Text(
        message,
        style: GoogleFonts.outfit(
          fontSize: 14.sp,
          color: tc.textTertiary,
        ),
      ),
    );
  }
}
