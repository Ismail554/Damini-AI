import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../models/notification_model.dart';

class NotificationItemCard extends StatefulWidget {
  final NotificationModel item;
  final VoidCallback onTap;

  const NotificationItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  State<NotificationItemCard> createState() => _NotificationItemCardState();
}

class _NotificationItemCardState extends State<NotificationItemCard> {
  bool _isExpanded = false;

  IconData _getIcon(NotificationModel item) {
    final lower = '${item.title} ${item.route ?? ''}'.toLowerCase();
    if (lower.contains('chat') || lower.contains('message')) {
      return Icons.chat_bubble_outline_rounded;
    } else if (lower.contains('request') || lower.contains('collab')) {
      return Icons.handshake_outlined;
    } else if (lower.contains('nda')) {
      return Icons.description_outlined;
    } else if (lower.contains('project')) {
      return Icons.business_center_outlined;
    }
    return Icons.notifications_none_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final item = widget.item;
    final isLong =
        item.description.length > 75 || item.description.contains('\n');

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: tc.cardBg,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: item.isUnread
                    ? AppColors.primaryColor.withValues(alpha: 0.45)
                    : tc.borderColor.withValues(alpha: 0.12),
                width: item.isUnread ? 1.2.w : 1.0.w,
              ),
              boxShadow: item.isUnread
                  ? [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Icon Badge
                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.isUnread
                        ? AppColors.primaryColor.withValues(alpha: 0.15)
                        : tc.borderColor.withValues(alpha: 0.15),
                    border: Border.all(
                      color: item.isUnread
                          ? AppColors.primaryColor.withValues(alpha: 0.35)
                          : tc.borderColor.withValues(alpha: 0.2),
                      width: 1.w,
                    ),
                  ),
                  child: Icon(
                    _getIcon(item),
                    color: item.isUnread
                        ? AppColors.primaryColor
                        : tc.textSecondary,
                    size: 18.r,
                  ),
                ),
                SizedBox(width: 12.w),
                // Details column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                color: tc.textPrimary,
                                fontSize: 14.sp,
                                fontWeight: item.isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            item.timeAgo,
                            style: GoogleFonts.outfit(
                              color: tc.textSecondary,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          if (item.isUnread) ...[
                            SizedBox(width: 6.w),
                            Container(
                              width: 8.r,
                              height: 8.r,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 6.h),
                      // Message text with tap-to-expand
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: isLong
                            ? () {
                                setState(() {
                                  _isExpanded = !_isExpanded;
                                });
                              }
                            : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedSize(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              alignment: Alignment.topLeft,
                              child: Text(
                                item.description,
                                maxLines: _isExpanded ? null : 2,
                                overflow: _isExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  color: tc.textSecondary,
                                  fontSize: 12.5.sp,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            if (isLong) ...[
                              SizedBox(height: 4.h),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _isExpanded ? 'Show less' : 'Read more',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11.5.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  Icon(
                                    _isExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    size: 14.r,
                                    color: AppColors.primaryColor,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
