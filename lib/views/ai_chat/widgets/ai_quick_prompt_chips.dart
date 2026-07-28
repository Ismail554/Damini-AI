import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';

class AiQuickPromptChips extends StatelessWidget {
  final List<String> prompts;
  final Function(String) onPromptTap;

  const AiQuickPromptChips({
    super.key,
    required this.prompts,
    required this.onPromptTap,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: prompts.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final prompt = prompts[index];
          return ActionChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: const Color(0xFFD34E27),
                  size: 14.r,
                ),
                SizedBox(width: 6.w),
                Text(
                  prompt,
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: tc.textPrimary,
                  ),
                ),
              ],
            ),
            backgroundColor: tc.isDark
                ? const Color(0xFF092444)
                : const Color(0xFFF1F5F9),
            side: BorderSide(
              color: tc.isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : const Color(0xFFE2E8F0),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            onPressed: () => onPromptTap(prompt),
          );
        },
      ),
    );
  }
}
