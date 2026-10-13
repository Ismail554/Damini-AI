import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';

class ProjectFormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autovalidateMode;
  final InputCounterWidgetBuilder? buildCounter;
  final void Function(String)? onChanged;
  final double? labelHeight;

  const ProjectFormField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.prefixIcon,
    this.validator,
    this.maxLength,
    this.inputFormatters,
    this.autovalidateMode,
    this.buildCounter,
    this.onChanged,
    this.labelHeight,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelHeight != null)
          Container(
            height: labelHeight,
            alignment: Alignment.topLeft,
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: tc.textPrimary,
              ),
            ),
          )
        else
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: tc.textPrimary,
            ),
          ),
        SizedBox(height: AppDimens.spaceSm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction ?? TextInputAction.next,
          maxLines: maxLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          autovalidateMode: autovalidateMode,
          buildCounter: buildCounter,
          onChanged: onChanged,
          style: GoogleFonts.outfit(fontSize: 14.sp, color: tc.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(
              fontSize: 13.sp,
              color: tc.textTertiary,
            ),
            counterStyle: GoogleFonts.outfit(
              fontSize: 11.sp,
              color: tc.textTertiary,
            ),
            filled: true,
            fillColor: tc.cardInner,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: maxLines > 1 ? 14.h : 12.h,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: tc.textTertiary,
                    size: AppDimens.iconSm,
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              borderSide: BorderSide(
                color: tc.borderColor,
                width: AppDimens.borderThin,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              borderSide: const BorderSide(color: AppColors.accentRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              borderSide: const BorderSide(
                color: AppColors.accentRed,
                width: 1.5,
              ),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
