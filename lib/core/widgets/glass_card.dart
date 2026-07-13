import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double borderOpacity;
  final double backgroundOpacity;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 24.0,
    this.borderOpacity = 0.08,
    this.backgroundOpacity = 0.04,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding ?? EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius.r),
            color: Colors.white.withOpacity(backgroundOpacity),
            border: Border.all(
              color: Colors.white.withOpacity(borderOpacity),
              width: 1.5.w,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
