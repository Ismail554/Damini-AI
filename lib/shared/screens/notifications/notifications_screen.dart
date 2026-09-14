import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_dimens.dart';
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
              onMarkAllRead: () {
                ref.read(notificationProvider.notifier).markAllAsRead();
                CustomSnackBar.info(
                  context,
                  'All notifications marked as read',
                );
              },
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: state.notifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimens.screenHorizontal,
                        vertical: AppDimens.paddingSm,
                      ),
                      itemCount: state.notifications.length,
                      itemBuilder: (context, index) {
                        final item = state.notifications[index];
                        return NotificationItemCard(
                          item: item,
                          onTap: () {
                            ref
                                .read(notificationProvider.notifier)
                                .markAsRead(item.id);
                            if (item.route != null) {
                              context.push(item.route!);
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            color: const Color(0xFF6B8A9D),
            size: 48.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            'No notifications yet',
            style: GoogleFonts.outfit(
              color: const Color(0xFF6B8A9D),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}
