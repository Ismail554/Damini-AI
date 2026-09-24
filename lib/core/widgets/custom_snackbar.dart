import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';
import '../utils/app_theme_colors.dart';

enum SnackBarType { success, error, warning, info }

class CustomSnackBar {
  CustomSnackBar._();

  /// Primary show method supporting full config, backward compatible with existing calls
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    SnackBarType? type,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final effectiveType =
        type ?? (isError ? SnackBarType.error : SnackBarType.success);
    final tc = AppThemeColors.of(context);
    final config = _config(effectiveType, tc);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        backgroundColor: config.bgColor,
        margin: EdgeInsets.fromLTRB(
          AppDimens.screenHorizontal,
          0,
          AppDimens.screenHorizontal,
          AppDimens.screenVertical,
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          side: BorderSide(
            color: config.borderColor,
            width: AppDimens.borderThin,
          ),
        ),
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: config.iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                config.icon,
                color: config.iconColor,
                size: 18.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.outfit(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: tc.textPrimary,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onAction();
                },
                child: Text(
                  actionLabel,
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: config.iconColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Convenience shortcuts
  static void success(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) =>
      show(
        context,
        message,
        type: SnackBarType.success,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration,
      );

  static void error(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) =>
      show(
        context,
        message,
        type: SnackBarType.error,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration,
      );

  static void info(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) =>
      show(
        context,
        message,
        type: SnackBarType.info,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration,
      );

  static void warning(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) =>
      show(
        context,
        message,
        type: SnackBarType.warning,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration,
      );

  static _SnackBarConfig _config(SnackBarType type, AppThemeColors tc) {
    switch (type) {
      case SnackBarType.success:
        return _SnackBarConfig(
          bgColor: tc.isDark
              ? AppColors.darkGreenPill.withValues(alpha: 0.95)
              : tc.greenPillBg,
          borderColor: tc.greenPillText.withValues(alpha: 0.4),
          glowColor: tc.greenPillText,
          icon: Icons.check_circle_outline_rounded,
          iconColor: tc.greenPillText,
          iconBgColor: tc.greenPillText.withValues(alpha: 0.15),
        );
      case SnackBarType.error:
        return _SnackBarConfig(
          bgColor: tc.isDark
              ? AppColors.darkLogoutBg.withValues(alpha: 0.95)
              : tc.logoutBg,
          borderColor: AppColors.error.withValues(alpha: 0.4),
          glowColor: AppColors.error,
          icon: Icons.error_outline_rounded,
          iconColor: AppColors.error,
          iconBgColor: AppColors.error.withValues(alpha: 0.15),
        );
      case SnackBarType.warning:
        return _SnackBarConfig(
          bgColor: tc.isDark
              ? const Color(0xFF2B200E)
              : const Color(0xFFFFFBEB),
          borderColor: AppColors.warning.withValues(alpha: 0.4),
          glowColor: AppColors.warning,
          icon: Icons.warning_amber_rounded,
          iconColor: AppColors.warning,
          iconBgColor: AppColors.warning.withValues(alpha: 0.15),
        );
      case SnackBarType.info:
        return _SnackBarConfig(
          bgColor: tc.pillBg,
          borderColor: tc.pillText.withValues(alpha: 0.4),
          glowColor: tc.pillText,
          icon: Icons.info_outline_rounded,
          iconColor: tc.pillText,
          iconBgColor: tc.pillText.withValues(alpha: 0.15),
        );
    }
  }
}

class _SnackBarConfig {
  final Color bgColor;
  final Color borderColor;
  final Color glowColor;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const _SnackBarConfig({
    required this.bgColor,
    required this.borderColor,
    required this.glowColor,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });
}
