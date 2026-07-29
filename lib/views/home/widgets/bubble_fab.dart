import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class BubbleMenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const BubbleMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class BubbleFab extends StatefulWidget {
  final List<BubbleMenuItem> items;

  const BubbleFab({
    super.key,
    required this.items,
  });

  @override
  State<BubbleFab> createState() => _BubbleFabState();
}

class _BubbleFabState extends State<BubbleFab> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    if (_isOpen) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() => _isOpen = !_isOpen);
  }

  void _close() {
    if (_isOpen) {
      _controller.reverse();
      setState(() => _isOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_isOpen)
          ...List.generate(widget.items.length, (index) {
            final item = widget.items[index];
            return _buildHorizontalBubbleItem(item, index);
          }),
        SizedBox(width: 6.w),
        _buildMainFab(),
      ],
    );
  }

  Widget _buildHorizontalBubbleItem(BubbleMenuItem item, int index) {
    final count = widget.items.length;
    final reverseIndex = count - 1 - index;
    final step = 1.0 / count;
    final start = reverseIndex * step * 0.3;
    final end = (start + 0.7).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutBack),
    );

    return ScaleTransition(
      scale: animation,
      child: FadeTransition(
        opacity: animation,
        child: Padding(
          padding: EdgeInsets.only(right: 8.w),
          child: GestureDetector(
            onTap: () {
              _close();
              item.onTap();
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: item.color.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.icon, color: Colors.white, size: 18.r),
                      SizedBox(width: 6.w),
                      Text(
                        item.label,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainFab() {
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        width: 52.r,
        height: 52.r,
        decoration: BoxDecoration(
          color: const Color(0xFF006EDB),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF006EDB).withValues(alpha: 0.45),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: RotationTransition(
          turns: _rotationAnimation,
          child: Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 28.r,
          ),
        ),
      ),
    );
  }
}
