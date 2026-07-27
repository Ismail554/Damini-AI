import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../models/notification_model.dart';

class NotificationItemCard extends StatelessWidget {
  final NotificationModel item;
  final VoidCallback onTap;

  const NotificationItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: const Color(0xFF0C1C30),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: item.isUnread
                    ? AppColors.activeBlue.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.08),
                width: item.isUnread ? 1.2 : 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Row(
                      children: [
                        Text(
                          item.timeAgo,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF6B8A9D),
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        if (item.isUnread) ...[
                          SizedBox(width: 6.w),
                          Container(
                            width: 8.r,
                            height: 8.r,
                            decoration: const BoxDecoration(
                              color: AppColors.activeBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  item.description,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF94A3B8),
                    fontSize: 13.sp,
                    height: 1.35,
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
