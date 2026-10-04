import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/group_chat_model.dart';

class GroupChatAiSuggestions extends StatelessWidget {
  final List<AiSuggestion> suggestions;
  final ValueChanged<AiSuggestion> onSelect;

  const GroupChatAiSuggestions({
    super.key,
    required this.suggestions,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      color: const Color(0xFF061427),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: const Color(0xFFA855F7),
                  size: 14.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  'AI is suggesting next steps',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF6B8A9D),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 6.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: suggestions.map((item) {
                return _buildSuggestionPill(item);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionPill(AiSuggestion item) {
    final isGreen = item.isCompleted;
    final bg = isGreen ? const Color(0xFF0D3326) : const Color(0xFF0F2238);
    final border = isGreen ? const Color(0xFF10B981) : const Color(0xFF1E334D);
    final textColor =
        isGreen ? const Color(0xFF10B981) : const Color(0xFF94A3B8);

    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: InkWell(
        onTap: () => onSelect(item),
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: border, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.icon,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: textColor,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                item.title,
                style: GoogleFonts.outfit(
                  color: textColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (item.isCompleted) ...[
                SizedBox(width: 6.w),
                Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: textColor, width: 1),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check_rounded,
                      size: 10.sp,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
