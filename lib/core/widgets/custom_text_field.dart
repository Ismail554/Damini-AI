import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final int maxLines;
  final bool isDropdown;
  final List<String>? dropdownItems;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onToggleObscure;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
    this.isDropdown = false,
    this.dropdownItems,
    this.obscureText = false,
    this.readOnly = false,
    this.onToggleObscure,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final hasItems = dropdownItems != null && dropdownItems!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: tc.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            height: maxLines > 1 ? null : 56.h,
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: maxLines > 1 ? 8.h : 0,
            ),
            decoration: BoxDecoration(
              color: tc.isDark
                  ? const Color(0xFF07172A)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: tc.isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : const Color(0xFFCBD5E1),
              ),
            ),
            child: isDropdown && hasItems
                ? DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: dropdownItems!.contains(controller.text)
                          ? controller.text
                          : null,
                      hint: Text(
                        hint,
                        style: GoogleFonts.outfit(
                          fontSize: 14.sp,
                          color: tc.textTertiary,
                        ),
                      ),
                      isExpanded: true,
                      dropdownColor: tc.isDark
                          ? const Color(0xFF091E36)
                          : Colors.white,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: tc.textTertiary,
                        size: 22.r,
                      ),
                      items: dropdownItems!.map((item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: GoogleFonts.outfit(
                              fontSize: 14.sp,
                              color: tc.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          controller.text = val;
                          onChanged?.call(val);
                        }
                      },
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: TextField(
                          textInputAction: textInputAction,
                          keyboardType: keyboardType,
                          controller: controller,
                          maxLines: maxLines,
                          obscureText: obscureText,
                          readOnly: readOnly || isDropdown,
                          onTap: onTap,
                          onChanged: onChanged,
                          style: GoogleFonts.outfit(
                            fontSize: 14.sp,
                            color: tc.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: hint,
                            hintStyle: GoogleFonts.outfit(
                              fontSize: 14.sp,
                              color: tc.textTertiary,
                            ),
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                        ),
                      ),
                      if (isDropdown)
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: tc.textTertiary,
                          size: 22.r,
                        ),
                      if (onToggleObscure != null)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            obscureText
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: tc.textTertiary,
                            size: 18.r,
                          ),
                          onPressed: onToggleObscure,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
