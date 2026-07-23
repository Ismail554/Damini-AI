import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';

enum CustomButtonVariant { primary, secondary, outlined, destructive, gradient }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final CustomButtonVariant variant;
  final double? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height,
    this.width,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.variant = CustomButtonVariant.primary,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? AppDimens.buttonLg;
    final effectiveRadius = borderRadius ?? AppDimens.radiusPill;

    if (variant == CustomButtonVariant.gradient || variant == CustomButtonVariant.primary) {
      return SizedBox(
        width: width ?? double.infinity,
        height: effectiveHeight,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                backgroundColor ?? AppColors.primaryColor,
                backgroundColor ?? const Color(0xFF0052CC),
              ],
            ),
            borderRadius: BorderRadius.circular(effectiveRadius),
            boxShadow: [
              BoxShadow(
                color: (backgroundColor ?? AppColors.primaryColor).withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(effectiveRadius),
              ),
            ),
            child: _buildChild(),
          ),
        ),
      );
    }

    if (variant == CustomButtonVariant.outlined || variant == CustomButtonVariant.destructive) {
      final isDestructive = variant == CustomButtonVariant.destructive;
      final borderC = borderColor ?? (isDestructive ? AppColors.accentRed.withValues(alpha: 0.4) : const Color(0xFF1E334D));
      final textC = textColor ?? (isDestructive ? AppColors.accentRed : Colors.white);
      final bgC = backgroundColor ?? (isDestructive ? AppColors.accentRed.withValues(alpha: 0.1) : Colors.transparent);

      return SizedBox(
        width: width ?? double.infinity,
        height: effectiveHeight,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: bgC,
            side: BorderSide(color: borderC, width: AppDimens.borderThin),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(effectiveRadius),
            ),
          ),
          child: _buildChild(color: textC),
        ),
      );
    }

    // Default / Secondary Variant
    return SizedBox(
      width: width ?? double.infinity,
      height: effectiveHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? const Color(0xFF132B47),
          foregroundColor: textColor ?? Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(effectiveRadius),
          ),
        ),
        child: _buildChild(color: textColor ?? Colors.white),
      ),
    );
  }

  Widget _buildChild({Color? color}) {
    if (isLoading) {
      return SizedBox(
        width: 20.r,
        height: 20.r,
        child: CircularProgressIndicator(
          color: color ?? Colors.white,
          strokeWidth: 2,
        ),
      );
    }

    final style = GoogleFonts.outfit(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      color: color ?? textColor ?? Colors.white,
    );

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color ?? textColor ?? Colors.white, size: AppDimens.iconSm),
          SizedBox(width: 6.w),
          Text(text, style: style),
        ],
      );
    }

    return Text(text, style: style);
  }
}
