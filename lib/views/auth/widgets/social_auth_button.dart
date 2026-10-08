import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:Braintech/core/utils/asset_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable social authentication button supporting Google, Apple, and custom providers.
///
/// Features:
/// - Factory constructors [SocialAuthButton.google] and [SocialAuthButton.apple].
/// - Configurable loading state ([isLoading]) with built-in indicator.
/// - Flexible icon placement ([iconTrailing], defaults to `true` to match app branding).
/// - Comprehensive style overrides (colors, sizing, border radius, typography).
/// - Proper disabled state handling when [onPressed] is null or [isLoading] is true.
class SocialAuthButton extends StatelessWidget {
  final String label;
  final Widget? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool iconTrailing;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? borderRadius;
  final TextStyle? textStyle;
  final double? iconGap;
  final Color? loadingIndicatorColor;

  const SocialAuthButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.iconTrailing = true,
    this.height,
    this.width,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderRadius,
    this.textStyle,
    this.iconGap,
    this.loadingIndicatorColor,
  });

  /// Factory constructor pre-configured for Google Sign-In with official SVG asset.
  factory SocialAuthButton.google({
    Key? key,
    String label = "Continue with Google",
    VoidCallback? onPressed,
    bool isLoading = false,
    bool iconTrailing = true,
    double? height,
    double? width,
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
    double? borderRadius,
    TextStyle? textStyle,
    double? iconGap,
    Color? loadingIndicatorColor,
    Widget? icon,
  }) {
    return SocialAuthButton(
      key: key,
      label: label,
      icon: icon ??
          SvgPicture.asset(
            SvgAssets.google,
            height: 18.r,
            width: 18.r,
          ),
      onPressed: onPressed,
      isLoading: isLoading,
      iconTrailing: iconTrailing,
      height: height,
      width: width,
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
      textStyle: textStyle,
      iconGap: iconGap,
      loadingIndicatorColor: loadingIndicatorColor,
    );
  }

  /// Factory constructor pre-configured for Apple Sign-In with theme-adaptive Apple logo.
  factory SocialAuthButton.apple({
    Key? key,
    String label = "Continue with Apple",
    VoidCallback? onPressed,
    bool isLoading = false,
    bool iconTrailing = true,
    double? height,
    double? width,
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
    double? borderRadius,
    TextStyle? textStyle,
    double? iconGap,
    Color? loadingIndicatorColor,
    Widget? icon,
  }) {
    return SocialAuthButton(
      key: key,
      label: label,
      icon: icon ??
          _AppleIcon(
            size: 22.r,
            color: textColor,
          ),
      onPressed: onPressed,
      isLoading: isLoading,
      iconTrailing: iconTrailing,
      height: height,
      width: width,
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
      textStyle: textStyle,
      iconGap: iconGap,
      loadingIndicatorColor: loadingIndicatorColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final effectiveTextColor = textColor ?? colors.textPrimary;
    final effectiveBackgroundColor = backgroundColor ?? colors.navBg;
    final effectiveBorderColor = borderColor ??
        (colors.isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.08));
    final effectiveHeight = height ?? 42.h;
    final effectiveRadius = borderRadius ?? 26.r;
    final isInteractive = onPressed != null && !isLoading;
    final showDisabledStyle = onPressed == null && !isLoading;

    return SizedBox(
      width: width ?? double.infinity,
      height: effectiveHeight,
      child: OutlinedButton(
        onPressed: isInteractive ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveTextColor,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          side: BorderSide(
            color: showDisabledStyle
                ? effectiveBorderColor.withValues(alpha: 0.5)
                : effectiveBorderColor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(effectiveRadius),
          ),
          backgroundColor: effectiveBackgroundColor,
          disabledBackgroundColor: isLoading
              ? effectiveBackgroundColor
              : effectiveBackgroundColor.withValues(alpha: 0.6),
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 20.r,
                  height: 20.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      loadingIndicatorColor ?? effectiveTextColor,
                    ),
                    semanticsLabel: '$label loading',
                  ),
                ),
              )
            : Opacity(
                opacity: showDisabledStyle ? 0.6 : 1.0,
                child: _buildContent(effectiveTextColor),
              ),
      ),
    );
  }

  Widget _buildContent(Color effectiveTextColor) {
    final effectiveTextStyle = textStyle ??
        GoogleFonts.outfit(
          fontSize: 14.sp,
          color: effectiveTextColor,
          fontWeight: FontWeight.w500,
        );

    final textWidget = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: effectiveTextStyle,
    );

    if (icon == null) {
      return textWidget;
    }

    final gap = SizedBox(width: iconGap ?? 8.w);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: iconTrailing
          ? [Flexible(child: textWidget), gap, icon!]
          : [icon!, gap, Flexible(child: textWidget)],
    );
  }
}

class _AppleIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const _AppleIcon({
    required this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Icon(
      Icons.apple,
      color: color ?? (colors.isDark ? Colors.white : colors.textPrimary),
      size: size,
    );
  }
}
