import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme_colors.dart';

enum ShimmerShape { card, listRow, detailBlock }

/// AppShimmer — reusable loading skeleton per Workflow 5.2
class AppShimmer extends StatefulWidget {
  final ShimmerShape shape;
  final double? width;
  final double? height;
  final double? borderRadius;

  const AppShimmer({
    super.key,
    this.shape = ShimmerShape.card,
    this.width,
    this.height,
    this.borderRadius,
  });

  const AppShimmer.card({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  }) : shape = ShimmerShape.card;

  const AppShimmer.listRow({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  }) : shape = ShimmerShape.listRow;

  const AppShimmer.detailBlock({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  }) : shape = ShimmerShape.detailBlock;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final baseColor = tc.cardHero;
    final highlightColor = tc.borderColor.withValues(alpha: 0.5);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width ?? _defaultWidth(widget.shape),
          height: widget.height ?? _defaultHeight(widget.shape),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? _defaultRadius(widget.shape),
            ),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, -0.3),
              end: Alignment(1.0 + 2.0 * _controller.value, 0.3),
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
            ),
            border: Border.all(color: tc.borderColor.withValues(alpha: 0.3)),
          ),
        );
      },
    );
  }

  double _defaultWidth(ShimmerShape shape) {
    switch (shape) {
      case ShimmerShape.card:
        return double.infinity;
      case ShimmerShape.listRow:
        return double.infinity;
      case ShimmerShape.detailBlock:
        return double.infinity;
    }
  }

  double _defaultHeight(ShimmerShape shape) {
    switch (shape) {
      case ShimmerShape.card:
        return 140.h;
      case ShimmerShape.listRow:
        return 68.h;
      case ShimmerShape.detailBlock:
        return 220.h;
    }
  }

  double _defaultRadius(ShimmerShape shape) {
    switch (shape) {
      case ShimmerShape.card:
        return 16.r;
      case ShimmerShape.listRow:
        return 12.r;
      case ShimmerShape.detailBlock:
        return 20.r;
    }
  }
}

/// AppErrorView — reusable error state widget with retry per Workflow 5.2
class AppErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 36.r,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "Unable to load data",
              style: GoogleFonts.outfit(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: tc.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              message,
              style: GoogleFonts.outfit(
                fontSize: 13.sp,
                color: tc.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 18.h),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh_rounded, size: 16.r, color: AppColors.primaryColor),
                label: Text(
                  "Try Again",
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// AppEmptyView — reusable empty state widget per Workflow 5.2
class AppEmptyView extends StatelessWidget {
  final String message;
  final IconData icon;

  const AppEmptyView({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: tc.borderColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: tc.textSecondary,
                size: 36.r,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              message,
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                color: tc.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
