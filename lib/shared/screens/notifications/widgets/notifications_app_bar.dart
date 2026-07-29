import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';

class NotificationsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onMarkAllRead;

  const NotificationsAppBar({super.key, required this.onMarkAllRead});

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: tc.textPrimary,
                    size: 22.sp,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                SizedBox(width: 14.w),
                Text(
                  'Notifications',
                  style: GoogleFonts.outfit(
                    color: tc.textPrimary,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: onMarkAllRead,
              child: Text(
                'Mark all read',
                style: GoogleFonts.outfit(
                  color: AppColors.accentOrange,
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
