import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Braintech/core/utils/app_colors.dart';
import 'package:Braintech/core/utils/app_dimens.dart';
import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:Braintech/core/widgets/app_state_widgets.dart';
import 'package:Braintech/core/widgets/common_background.dart';
import 'package:Braintech/core/widgets/custom_snackbar.dart';
import '../controllers/collaboration_requests_provider.dart';
import '../widgets/collaboration_card.dart';
import '../widgets/collaboration_confirmation_card.dart';
import '../widgets/collaboration_requests_header.dart';

class CollaborationRequestsView extends ConsumerStatefulWidget {
  final String? projectId;
  final String? projectTitle;

  const CollaborationRequestsView({
    super.key,
    this.projectId,
    this.projectTitle,
  });

  @override
  ConsumerState<CollaborationRequestsView> createState() =>
      _CollaborationRequestsViewState();
}

class _CollaborationRequestsViewState
    extends ConsumerState<CollaborationRequestsView> {
  int _selectedTabIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedTabIndex);
    Future.microtask(() {
      ref
          .read(collaborationRequestsProvider.notifier)
          .init(projectId: widget.projectId);
    });
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
    final state = ref.watch(collaborationRequestsProvider);

    return CommonBackground(
      showGrid: false,
      child: SafeArea(
        child: Column(
          children: [
            CollaborationRequestsHeader(
              selectedTabIndex: _selectedTabIndex,
              onTabSelected: _onTabSelected,
              projectTitle: widget.projectTitle,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _selectedTabIndex = index);
                },
                children: [
                  _buildPendingListView(state),
                  _buildApprovedListView(state),
                  _buildConfirmationListView(state),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingListView(CollaborationRequestsState state) {
    final tc = AppThemeColors.of(context);

    if (state.isLoading && state.pendingList.isEmpty) {
      return _buildShimmerList();
    }

    if (state.error != null && state.pendingList.isEmpty) {
      return AppErrorView(
        message: state.error!,
        onRetry: () =>
            ref.read(collaborationRequestsProvider.notifier).refresh(),
      );
    }

    final list = state.pendingList;
    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: () =>
            ref.read(collaborationRequestsProvider.notifier).refresh(),
        color: AppColors.primaryColor,
        backgroundColor: tc.cardBg,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            SizedBox(height: 120.h),
            _buildEmptyState("No pending requests"),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(collaborationRequestsProvider.notifier).refresh(),
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
          return CollaborationCard(
            item: item,
            onLeftAction: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: tc.cardBg,
                  title: Text(
                    "Reject Request",
                    style: GoogleFonts.outfit(
                      color: tc.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    "Are you sure you want to reject the request from ${item.investorName}?",
                    style: GoogleFonts.outfit(color: tc.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.outfit(color: tc.textTertiary),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(
                        "Reject",
                        style: GoogleFonts.outfit(
                          color: AppColors.accentRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                final success = await ref
                    .read(collaborationRequestsProvider.notifier)
                    .rejectPendingRequest(item.id);
                if (context.mounted) {
                  if (success) {
                    CustomSnackBar.info(context, "Request rejected");
                  } else {
                    CustomSnackBar.error(
                      context,
                      "Failed to reject request. Please try again.",
                    );
                  }
                }
              }
            },
            onRightAction: () async {
              final success = await ref
                  .read(collaborationRequestsProvider.notifier)
                  .approvePendingRequest(item);
              if (context.mounted) {
                if (success) {
                  CustomSnackBar.success(
                    context,
                    "Approved request from ${item.investorName}!",
                  );
                } else {
                  CustomSnackBar.error(
                    context,
                    "Failed to approve request. Please try again.",
                  );
                }
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildApprovedListView(CollaborationRequestsState state) {
    final tc = AppThemeColors.of(context);

    if (state.isLoading && state.approvedList.isEmpty) {
      return _buildShimmerList();
    }

    final list = state.approvedList;
    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: () =>
            ref.read(collaborationRequestsProvider.notifier).refresh(),
        color: AppColors.primaryColor,
        backgroundColor: tc.cardBg,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            SizedBox(height: 120.h),
            _buildEmptyState("No approved requests"),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(collaborationRequestsProvider.notifier).refresh(),
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
          return CollaborationCard(
            item: item,
            onLeftAction: () => ref
                .read(collaborationRequestsProvider.notifier)
                .removeApprovedRequest(item.id),
            onRightAction: () => context.push('/group-chat'),
          );
        },
      ),
    );
  }

  Widget _buildConfirmationListView(CollaborationRequestsState state) {
    final tc = AppThemeColors.of(context);

    if (state.isLoading && state.confirmationList.isEmpty) {
      return _buildShimmerList();
    }

    final list = state.confirmationList;
    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: () =>
            ref.read(collaborationRequestsProvider.notifier).refresh(),
        color: AppColors.primaryColor,
        backgroundColor: tc.cardBg,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            SizedBox(height: 120.h),
            _buildEmptyState("No confirmations found"),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(collaborationRequestsProvider.notifier).refresh(),
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
          return CollaborationConfirmationCard(
            item: item,
            onFundReceived: () async {
              final success = await ref
                  .read(collaborationRequestsProvider.notifier)
                  .markFundReceived(item.id);
              if (context.mounted) {
                if (success) {
                  CustomSnackBar.success(
                    context,
                    "Fund received marked for ${item.investorName}!",
                  );
                } else {
                  CustomSnackBar.error(
                    context,
                    "Failed to mark fund received. Please try again.",
                  );
                }
              }
            },
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
        child: const AppShimmer.card(height: 200),
      ),
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
