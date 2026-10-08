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

/// AppEmptyView — reusable, aesthetic empty & null state widget per Workflow 5.2
class AppEmptyView extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? message;
  final IconData? icon;
  final Widget? customIllustration;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final EdgeInsetsGeometry? padding;
  final bool isCompact;

  const AppEmptyView({
    super.key,
    this.title,
    this.subtitle,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.customIllustration,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.padding,
    this.isCompact = false,
  });

  /// Factory for saved items empty state
  factory AppEmptyView.saved({
    Key? key,
    String? title,
    String? subtitle,
    String? actionLabel = "Discover Deals",
    VoidCallback? onAction,
    bool isCompact = false,
  }) {
    return AppEmptyView(
      key: key,
      title: title ?? "No Saved Items Yet",
      subtitle: subtitle ??
          "You haven't bookmarked any opportunities or profiles yet. Discover and save items to quickly track them here.",
      icon: Icons.bookmark_border_rounded,
      actionLabel: actionLabel,
      actionIcon: Icons.explore_outlined,
      onAction: onAction,
      isCompact: isCompact,
    );
  }

  /// Factory for search results empty state
  factory AppEmptyView.search({
    Key? key,
    required String query,
    VoidCallback? onClear,
    bool isCompact = false,
  }) {
    return AppEmptyView(
      key: key,
      title: "No Results Found",
      subtitle:
          'We couldn\'t find anything matching "$query". Try checking for spelling errors or adjusting your search filters.',
      icon: Icons.search_off_rounded,
      actionLabel: onClear != null ? "Clear Search" : null,
      actionIcon: Icons.close_rounded,
      onAction: onClear,
      isCompact: isCompact,
    );
  }

  /// Factory for investment history / portfolio empty state
  factory AppEmptyView.investments({
    Key? key,
    String? title,
    String? subtitle,
    String? actionLabel = "Explore Deals",
    VoidCallback? onAction,
    bool isCompact = false,
  }) {
    return AppEmptyView(
      key: key,
      title: title ?? "No Investment Records",
      subtitle: subtitle ??
          "You haven't committed to any deals yet. Browse active investment opportunities to start building your portfolio.",
      icon: Icons.account_balance_wallet_outlined,
      actionLabel: actionLabel,
      actionIcon: Icons.trending_up_rounded,
      onAction: onAction,
      isCompact: isCompact,
    );
  }

  /// Factory for messages / conversations empty state
  factory AppEmptyView.messages({
    Key? key,
    String? title,
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
    bool isCompact = false,
  }) {
    return AppEmptyView(
      key: key,
      title: title ?? "No Messages Yet",
      subtitle: subtitle ??
          "You don't have any active conversations. Connect with project sponsors or investors to start collaborating.",
      icon: Icons.chat_bubble_outline_rounded,
      actionLabel: actionLabel,
      actionIcon: Icons.add_comment_outlined,
      onAction: onAction,
      isCompact: isCompact,
    );
  }

  /// Factory for projects list empty state
  factory AppEmptyView.projects({
    Key? key,
    String? title,
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
    bool isCompact = false,
  }) {
    return AppEmptyView(
      key: key,
      title: title ?? "No Projects Found",
      subtitle: subtitle ??
          "There are currently no projects matching this criteria.",
      icon: Icons.folder_open_rounded,
      actionLabel: actionLabel,
      actionIcon: Icons.add_rounded,
      onAction: onAction,
      isCompact: isCompact,
    );
  }

  /// Factory for collaboration requests empty state
  factory AppEmptyView.requests({
    Key? key,
    String? title,
    String? subtitle,
    bool isCompact = false,
  }) {
    return AppEmptyView(
      key: key,
      title: title ?? "No Collaboration Requests",
      subtitle: subtitle ??
          "Incoming investment proposals and collaboration requests will appear here.",
      icon: Icons.handshake_outlined,
      isCompact: isCompact,
    );
  }

  /// Factory for null / unselected state
  factory AppEmptyView.nullState({
    Key? key,
    String title = "Nothing Selected",
    String subtitle = "Select an item from the list to view its complete details.",
    IconData icon = Icons.touch_app_outlined,
    String? actionLabel,
    VoidCallback? onAction,
    bool isCompact = false,
  }) {
    return AppEmptyView(
      key: key,
      title: title,
      subtitle: subtitle,
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
      isCompact: isCompact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final isDark = tc.isDark;

    final effectiveTitle = title ?? (subtitle != null ? null : message) ?? "No data available";
    final effectiveSubtitle = subtitle ?? (title != null ? message : null);

    final double iconOuterSize = isCompact ? 56.r : 76.r;
    final double iconInnerSize = isCompact ? 44.r : 58.r;
    final double iconGlyphSize = isCompact ? 22.r : 30.r;

    return Center(
      child: Padding(
        padding: padding ??
            EdgeInsets.symmetric(
              horizontal: isCompact ? 16.w : 24.w,
              vertical: isCompact ? 20.h : 36.h,
            ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Glowing circular illustration container
            if (customIllustration != null)
              customIllustration!
            else
              Container(
                width: iconOuterSize,
                height: iconOuterSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? const Color(0xFF0066FF).withValues(alpha: 0.08)
                      : const Color(0xFF0066FF).withValues(alpha: 0.05),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF0066FF).withValues(alpha: 0.20)
                        : const Color(0xFF0066FF).withValues(alpha: 0.12),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: iconInnerSize,
                    height: iconInnerSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                const Color(0xFF0E2A52),
                                const Color(0xFF091E3B),
                              ]
                            : [
                                Colors.white,
                                const Color(0xFFEFF6FF),
                              ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.35)
                              : const Color(0xFF0066FF).withValues(alpha: 0.10),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon ?? Icons.inbox_outlined,
                      color: isDark
                          ? const Color(0xFF60A5FA)
                          : const Color(0xFF0066FF),
                      size: iconGlyphSize,
                    ),
                  ),
                ),
              ),

            SizedBox(height: isCompact ? 12.h : 18.h),

            // Title
            if (effectiveTitle.isNotEmpty)
              Text(
                effectiveTitle,
                style: GoogleFonts.outfit(
                  fontSize: isCompact ? 15.sp : 17.sp,
                  fontWeight: FontWeight.bold,
                  color: tc.textPrimary,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),

            // Subtitle / message
            if (effectiveSubtitle != null && effectiveSubtitle.isNotEmpty) ...[
              SizedBox(height: isCompact ? 4.h : 6.h),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 320.w),
                child: Text(
                  effectiveSubtitle,
                  style: GoogleFonts.outfit(
                    fontSize: isCompact ? 12.sp : 13.5.sp,
                    color: tc.textSecondary,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            // Action button
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: isCompact ? 14.h : 20.h),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 16.w : 22.w,
                    vertical: isCompact ? 8.h : 10.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0066FF), Color(0xFF0052CC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0066FF).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (actionIcon != null) ...[
                        Icon(
                          actionIcon,
                          color: Colors.white,
                          size: isCompact ? 14.r : 16.r,
                        ),
                        SizedBox(width: 6.w),
                      ],
                      Text(
                        actionLabel!,
                        style: GoogleFonts.outfit(
                          fontSize: isCompact ? 12.sp : 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Secondary action button
            if (secondaryActionLabel != null && onSecondaryAction != null) ...[
              SizedBox(height: 8.h),
              TextButton(
                onPressed: onSecondaryAction,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(
                  secondaryActionLabel!,
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    color: tc.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

