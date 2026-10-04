import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routing/app_router.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme_colors.dart';

class PushNotificationToast {
  PushNotificationToast._();

  /// Displays a floating, toast-style rounded snackbar with notification title and body.
  static void show({
    BuildContext? context,
    required String title,
    required String message,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
    final scaffoldContext =
        context ?? AppRouter.navigatorKey.currentContext;

    final tc = scaffoldContext != null
        ? AppThemeColors.of(scaffoldContext)
        : null;

    final isDark = tc?.isDark ?? true;
    final bgColor = isDark
        ? const Color(0xFF141926).withValues(alpha: 0.96)
        : const Color(0xFFFFFFFF).withValues(alpha: 0.98);

    final borderColor = isDark
        ? AppColors.primaryColor.withValues(alpha: 0.4)
        : AppColors.primaryColor.withValues(alpha: 0.25);

    final textPrimary = tc?.textPrimary ?? Colors.white;
    final textSecondary = tc?.textSecondary ?? Colors.white70;

    final snackBar = SnackBar(
      duration: duration,
      behavior: SnackBarBehavior.floating,
      elevation: 8,
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      content: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: borderColor, width: 1.2.w),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.15),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24.r),
            onTap: () {
              AppRouter.scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
              onTap?.call();
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Rounded Bell Badge
                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryColor.withValues(alpha: 0.15),
                    border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.45),
                      width: 1.w,
                    ),
                  ),
                  child: Icon(
                    Icons.notifications_active_rounded,
                    color: AppColors.primaryColor,
                    size: 18.r,
                  ),
                ),
                SizedBox(width: 12.w),
                // Title and Body
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.isNotEmpty ? title : 'New Notification',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        message.isNotEmpty ? message : 'Tap to view details',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w400,
                          color: textSecondary,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 9.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: AppColors.primaryColor.withValues(alpha: 0.3),
                        width: 0.8.w,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View',
                          style: GoogleFonts.outfit(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 9.r,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    final messengerState = AppRouter.scaffoldMessengerKey.currentState ??
        (scaffoldContext != null ? ScaffoldMessenger.maybeOf(scaffoldContext) : null);

    if (messengerState != null) {
      messengerState.hideCurrentSnackBar();
      messengerState.showSnackBar(snackBar);
    }
  }
}
