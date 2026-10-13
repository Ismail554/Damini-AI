import 'package:Braintech/core/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DaminiInteractiveChips extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onSelect;

  const DaminiInteractiveChips({
    super.key,
    required this.suggestions,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
            child: Row(
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: 13.r,
                  color: const Color(0xFFC026D3),
                ),
                SizedBox(width: 4.w),
                Text(
                  "SUGGESTED OPTIONS",
                  style: GoogleFonts.outfit(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFC026D3),
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: suggestions.map((s) {
                return _InteractiveChipItem(
                  text: s,
                  onTap: () => onSelect(s),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractiveChipItem extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _InteractiveChipItem({
    required this.text,
    required this.onTap,
  });

  @override
  State<_InteractiveChipItem> createState() => _InteractiveChipItemState();
}

class _InteractiveChipItemState extends State<_InteractiveChipItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isApply = widget.text == "Apply to Project";

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          margin: EdgeInsets.only(right: 8.w),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: isApply
                ? const LinearGradient(
                    colors: [Color(0xFF006EDB), Color(0xFF9333EA)],
                  )
                : LinearGradient(
                    colors: [
                      const Color(0xFF9333EA).withValues(alpha: 0.15),
                      const Color(0xFFC026D3).withValues(alpha: 0.08),
                    ],
                  ),
            border: Border.all(
              color: isApply
                  ? const Color(0xFFC026D3)
                  : const Color(0xFF9333EA).withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: isApply
                ? [
                    BoxShadow(
                      color: const Color(0xFF9333EA).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isApply ? Icons.bolt_rounded : Icons.auto_awesome_rounded,
                size: 14.sp,
                color: isApply ? Colors.white : const Color(0xFFC026D3),
              ),
              AppSpacing.w6,
              Text(
                widget.text,
                style: GoogleFonts.outfit(
                  fontSize: 12.5.sp,
                  fontWeight: isApply ? FontWeight.bold : FontWeight.w600,
                  color: isApply ? Colors.white : const Color(0xFFC026D3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
