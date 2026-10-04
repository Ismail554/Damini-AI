import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/widgets/app_state_widgets.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import 'controllers/notification_provider.dart';
import 'widgets/notification_item_card.dart';
import 'widgets/notifications_app_bar.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationProvider);

    return CommonBackground(
      showGrid: false,
      child: SafeArea(
        child: Column(
          children: [
            NotificationsAppBar(
              hasNotifications: state.notifications.isNotEmpty,
              onMarkAllRead: () {
                ref.read(notificationProvider.notifier).markAllAsRead();
                CustomSnackBar.info(
                  context,
                  'All notifications marked as read',
                );
              },
              onClearAll: () async {
                final confirm = await _showClearAllDialog(context);
                if (confirm == true) {
                  final success = await ref
                      .read(notificationProvider.notifier)
                      .clearAllNotifications();
                  if (context.mounted) {
                    if (success) {
                      CustomSnackBar.info(
                        context,
                        'All notifications cleared',
                      );
                    } else {
                      CustomSnackBar.error(
                        context,
                        'Failed to clear notifications',
                      );
                    }
                  }
                }
              },
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: state.isLoading && state.notifications.isEmpty
                  ? _buildLoadingShimmer()
                  : state.notifications.isEmpty
                      ? RefreshIndicator(
                          color: AppColors.primaryColor,
                          onRefresh: () =>
                              ref.read(notificationProvider.notifier).refresh(),
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: 120.h),
                              const AppEmptyView(
                                message: 'No notifications yet',
                                icon: Icons.notifications_off_outlined,
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: AppColors.primaryColor,
                          onRefresh: () =>
                              ref.read(notificationProvider.notifier).refresh(),
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimens.screenHorizontal,
                              vertical: AppDimens.paddingSm,
                            ),
                            itemCount: state.notifications.length,
                            itemBuilder: (context, index) {
                              final item = state.notifications[index];
                              return Dismissible(
                                key: ValueKey(
                                  item.id.isNotEmpty
                                      ? item.id
                                      : 'notif_$index',
                                ),
                                direction: DismissDirection.endToStart,
                                background: const SizedBox.shrink(),
                                secondaryBackground: Container(
                                  margin: EdgeInsets.only(bottom: 12.h),
                                  alignment: Alignment.centerRight,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 20.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.error
                                        .withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Delete',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 6.w),
                                      Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.white,
                                        size: 20.r,
                                      ),
                                    ],
                                  ),
                                ),
                                onDismissed: (_) async {
                                  final notifId = item.id;
                                  final success = await ref
                                      .read(notificationProvider.notifier)
                                      .deleteNotification(notifId);
                                  if (context.mounted && !success) {
                                    CustomSnackBar.error(
                                      context,
                                      'Failed to delete notification',
                                    );
                                  }
                                },
                                child: NotificationItemCard(
                                  item: item,
                                  onTap: () {
                                    ref
                                        .read(notificationProvider.notifier)
                                        .markAsRead(item.id);
                                    if (item.route != null &&
                                        item.route!.isNotEmpty) {
                                      context.push(item.route!);
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showClearAllDialog(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tc.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Clear all notifications?',
          style: GoogleFonts.outfit(
            color: tc.textPrimary,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will permanently delete all notifications from your account.',
          style: GoogleFonts.outfit(
            color: tc.textSecondary,
            fontSize: 13.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(
                color: tc.textSecondary,
                fontSize: 13.sp,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Clear All',
              style: GoogleFonts.outfit(
                color: AppColors.error,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.screenHorizontal,
        vertical: AppDimens.paddingSm,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: AppShimmer.card(height: 80.h, borderRadius: 16.r),
      ),
    );
  }
}
