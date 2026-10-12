import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_theme_colors.dart';
import '../../../core/utils/platform_utils.dart';

class CustomNavItemData {
  final String label;
  final IconData icon;
  final IconData? activeIcon;

  const CustomNavItemData({
    required this.label,
    required this.icon,
    this.activeIcon,
  });
}

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<CustomNavItemData> items;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  double? _dragX;
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnimation;
  double _currentPosition = 0;

  @override
  void initState() {
    super.initState();
    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _currentPosition = widget.currentIndex.toDouble();
    _indicatorAnimation = AlwaysStoppedAnimation(_currentPosition);
  }

  @override
  void didUpdateWidget(covariant CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animateToIndex(widget.currentIndex);
    }
  }

  void _animateToIndex(int index) {
    _indicatorAnimation = Tween<double>(
      begin: _currentPosition,
      end: index.toDouble(),
    ).animate(CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.easeOutCubic,
    ));
    _indicatorController.forward(from: 0).then((_) {
      _currentPosition = index.toDouble();
    });
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    super.dispose();
  }

  int _indexAt(double x, double barWidth) {
    final itemWidth = barWidth / widget.items.length;
    return (x ~/ itemWidth).clamp(0, widget.items.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAndroid = PlatformUtils.isAndroid;

    if (isAndroid) {
      return _buildAndroidNavBar(context, tc, isDark);
    }
    return _buildIOSNavBar(context, tc, isDark);
  }

  // ── iOS: Liquid glass nav bar ───────────────────────────────────
  Widget _buildIOSNavBar(BuildContext context, AppThemeColors tc, bool isDark) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final bottomMargin = bottomInset > 0 ? (bottomInset + 4.h) : 14.h;

    return Container(
      margin: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        bottom: bottomMargin,
        top: 4.h,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
            blurRadius: 28,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: isDark ? 0.20 : 0.08),
            blurRadius: 20,
            spreadRadius: -4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            height: AppDimens.navBarHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF132B45).withValues(alpha: 0.70),
                        const Color(0xFF091624).withValues(alpha: 0.82),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.85),
                        const Color(0xFFF1F5F9).withValues(alpha: 0.72),
                      ],
              ),
              borderRadius: BorderRadius.circular(AppDimens.radiusPill),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.20)
                    : Colors.white.withValues(alpha: 0.85),
                width: 1.2,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final barWidth = constraints.maxWidth;
                final itemWidth = barWidth / widget.items.length;
                final dragging = _dragX != null;
                final activeIndex = dragging
                    ? _indexAt(_dragX!, barWidth)
                    : widget.currentIndex;
                final capsuleLeft = dragging
                    ? (_dragX! - itemWidth / 2)
                        .clamp(0.0, barWidth - itemWidth)
                    : widget.currentIndex * itemWidth;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (d) =>
                      widget.onTap(_indexAt(d.localPosition.dx, barWidth)),
                  onHorizontalDragStart: (d) =>
                      setState(() => _dragX = d.localPosition.dx),
                  onHorizontalDragUpdate: (d) => setState(
                    () => _dragX = d.localPosition.dx.clamp(0.0, barWidth),
                  ),
                  onHorizontalDragEnd: (_) {
                    final idx = _indexAt(_dragX!, barWidth);
                    setState(() => _dragX = null);
                    widget.onTap(idx);
                  },
                  onHorizontalDragCancel: () =>
                      setState(() => _dragX = null),
                  child: Stack(
                    children: [
                      // Smooth fluid liquid glass capsule indicator slider
                      AnimatedPositioned(
                        duration: dragging
                            ? Duration.zero
                            : const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        left: capsuleLeft + 4.w,
                        top: 6.h,
                        bottom: 6.h,
                        width: itemWidth - 8.w,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isDark
                                  ? [
                                      AppColors.primaryColor
                                          .withValues(alpha: 0.32),
                                      AppColors.primaryDark
                                          .withValues(alpha: 0.22),
                                    ]
                                  : [
                                      AppColors.primaryColor
                                          .withValues(alpha: 0.16),
                                      AppColors.primaryColor
                                          .withValues(alpha: 0.08),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(
                              color: AppColors.primaryColor.withValues(
                                alpha: isDark ? 0.45 : 0.30,
                              ),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryColor.withValues(
                                  alpha: isDark ? 0.25 : 0.10,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: List.generate(
                          widget.items.length,
                          (i) => _buildIOSItem(
                            tc,
                            isDark,
                            widget.items[i],
                            i == activeIndex,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIOSItem(
    AppThemeColors tc,
    bool isDark,
    CustomNavItemData item,
    bool sel,
  ) {
    final iconData =
        (sel && item.activeIcon != null) ? item.activeIcon! : item.icon;
    final activeColor =
        isDark ? AppColors.activeBlue : AppColors.primaryColor;
    final inactiveColor =
        isDark ? Colors.white.withValues(alpha: 0.50) : const Color(0xFF64748B);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            scale: sel ? 1.15 : 1.0,
            child: Icon(
              iconData,
              color: sel ? activeColor : inactiveColor,
              size: 22.r,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            item.label,
            style: GoogleFonts.outfit(
              fontSize: 10.sp,
              color: sel ? activeColor : inactiveColor,
              fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Android: Material 3 floating nav bar ───────────────────────
  Widget _buildAndroidNavBar(BuildContext context, AppThemeColors tc, bool isDark) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final bottomMargin = bottomInset > 0 ? (bottomInset + 4.h) : 14.h;
    final surfaceColor = isDark
        ? const Color(0xFF0F1E2F)
        : Colors.white;

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE2E8F0);

    return Container(
      margin: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        bottom: bottomMargin,
        top: 4.h,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.50)
                : Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          if (!isDark)
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.06),
              blurRadius: 30,
              spreadRadius: -4,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: SizedBox(
          height: 64.h,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth;
              final itemWidth = barWidth / widget.items.length;

              return AnimatedBuilder(
                animation: _indicatorAnimation,
                builder: (context, _) {
                  final dragging = _dragX != null;
                  final activeIndex = dragging
                      ? _indexAt(_dragX!, barWidth)
                      : widget.currentIndex;

                  final indicatorPos = dragging
                      ? (_dragX! / itemWidth - 0.5)
                          .clamp(0.0, widget.items.length - 1.0)
                      : _indicatorAnimation.value;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (d) =>
                        widget.onTap(_indexAt(d.localPosition.dx, barWidth)),
                    onHorizontalDragStart: (d) =>
                        setState(() => _dragX = d.localPosition.dx),
                    onHorizontalDragUpdate: (d) => setState(
                      () => _dragX =
                          d.localPosition.dx.clamp(0.0, barWidth),
                    ),
                    onHorizontalDragEnd: (_) {
                      final idx = _indexAt(_dragX!, barWidth);
                      setState(() => _dragX = null);
                      widget.onTap(idx);
                    },
                    onHorizontalDragCancel: () =>
                        setState(() => _dragX = null),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // ── Animated indicator pill ──
                        Positioned(
                          left: indicatorPos * itemWidth +
                              (itemWidth - 48.w) / 2,
                          top: 8.h,
                          child: Container(
                            width: 48.w,
                            height: 32.h,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.primaryColor
                                      .withValues(alpha: 0.20)
                                  : AppColors.primaryColor
                                      .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                        ),
                        // ── Nav items row ──
                        Row(
                          children: List.generate(
                            widget.items.length,
                            (i) => _buildAndroidItem(
                              tc,
                              isDark,
                              widget.items[i],
                              i == activeIndex,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAndroidItem(
    AppThemeColors tc,
    bool isDark,
    CustomNavItemData item,
    bool sel,
  ) {
    final iconData =
        (sel && item.activeIcon != null) ? item.activeIcon! : item.icon;

    final activeColor = isDark
        ? AppColors.activeBlue
        : AppColors.primaryColor;

    final inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : const Color(0xFF94A3B8);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 32.h,
            child: Center(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                scale: sel ? 1.12 : 1.0,
                child: Icon(
                  iconData,
                  color: sel ? activeColor : inactiveColor,
                  size: 22.sp,
                ),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.outfit(
              fontSize: sel ? 10.sp : 10.sp,
              color: sel ? activeColor : inactiveColor,
              fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
              height: 1.2,
            ),
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
