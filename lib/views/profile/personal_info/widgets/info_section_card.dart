import 'package:Braintech/core/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';

class InfoRowData {
  final String label;
  final String value;
  final bool? isMultiline;

  const InfoRowData(this.label, this.value, {this.isMultiline});
}

class InfoSectionCard extends StatelessWidget {
  final String title;
  final List<InfoRowData> rows;

  const InfoSectionCard({super.key, required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: tc.isDark ? const Color(0xFF091E36) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: tc.isDark
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: tc.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Divider(
            height: 1,
            color: tc.isDark
                ? Colors.white.withValues(alpha: 0.1)
                : const Color(0xFFE2E8F0),
          ),
          ...rows.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final rawValue = item.value.trim();
            final isEmpty = rawValue.isEmpty;
            final isLong = (item.isMultiline ?? false) ||
                (!isEmpty &&
                    (rawValue.length > 45 ||
                        rawValue.contains('\n') ||
                        item.label.toLowerCase() == 'bio' ||
                        item.label.toLowerCase() == 'about'));
            final displayValue = isEmpty ? 'Not set' : rawValue;

            return Column(
              children: [
                InkWell(
                  onLongPress: !isEmpty
                      ? () {
                          Clipboard.setData(ClipboardData(text: rawValue));
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('${item.label} copied to clipboard'),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      : null,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: isLong
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.label,
                                style: GoogleFonts.outfit(
                                  fontSize: 14.sp,
                                  color: tc.textTertiary,
                                ),
                              ),
                              AppSpacing.h6,
                              Text(
                                displayValue,
                                style: GoogleFonts.outfit(
                                  fontSize: 14.sp,
                                  fontWeight: isEmpty
                                      ? FontWeight.normal
                                      : FontWeight.w500,
                                  fontStyle: isEmpty
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                  color: isEmpty
                                      ? tc.textTertiary
                                      : tc.textPrimary,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.label,
                                style: GoogleFonts.outfit(
                                  fontSize: 14.sp,
                                  color: tc.textTertiary,
                                ),
                              ),
                              AppSpacing.w16, 
                              Expanded(
                                child: Text(
                                  displayValue,
                                  textAlign: TextAlign.end,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14.sp,
                                    fontWeight: isEmpty
                                        ? FontWeight.normal
                                        : FontWeight.w600,
                                    fontStyle: isEmpty
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                    color: isEmpty
                                        ? tc.textTertiary
                                        : tc.textPrimary,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                if (idx < rows.length - 1)
                  Divider(
                    height: 1,
                    color: tc.isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFF1F5F9),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
