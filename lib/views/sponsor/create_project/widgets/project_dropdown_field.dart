import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';

class ProjectDropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const ProjectDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    // Deduplicate items while preserving order
    final seen = <String>{};
    final effectiveItems = <String>[];
    for (final item in items) {
      final trimmed = item.trim();
      if (trimmed.isNotEmpty && seen.add(trimmed.toLowerCase())) {
        effectiveItems.add(trimmed);
      }
    }

    String? effectiveValue = (value != null && value!.trim().isNotEmpty)
        ? value!.trim()
        : null;

    if (effectiveValue != null) {
      final exactMatch = effectiveItems.contains(effectiveValue);
      if (!exactMatch) {
        // Try case-insensitive matching
        final caseMatch = effectiveItems.firstWhere(
          (i) => i.toLowerCase() == effectiveValue!.toLowerCase(),
          orElse: () => '',
        );
        if (caseMatch.isNotEmpty) {
          effectiveValue = caseMatch;
        } else {
          // If value is not in items, insert it so DropdownButton never asserts
          effectiveItems.insert(0, effectiveValue);
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: tc.textPrimary,
          ),
        ),
        SizedBox(height: AppDimens.spaceXxs),
        DropdownButtonFormField<String>(
          value: effectiveValue,
          onChanged: onChanged,
          dropdownColor: tc.cardBg,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: tc.textSecondary,
          ),
          style: GoogleFonts.outfit(
            fontSize: 14.sp,
            color: tc.textPrimary,
          ),
          hint: Text(
            hint,
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              color: tc.textTertiary,
            ),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: tc.cardInner,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
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
          ),
          items: effectiveItems.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.outfit(
                  fontSize: 13.sp,
                  color: tc.textPrimary,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
