import 'package:flutter/material.dart';
import '../../../../core/utils/app_dimens.dart';

/// Pinned header host for the tab bar so tabs remain reachable while the
/// sheet content scrolls.
class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Color backgroundColor;
  final Color dividerColor;
  final Widget child;

  StickyTabBarDelegate({
    required this.height,
    required this.backgroundColor,
    required this.dividerColor,
    required this.child,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final showDivider = shrinkOffset > 0 || overlapsContent;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: showDivider ? dividerColor : Colors.transparent,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  bool shouldRebuild(StickyTabBarDelegate oldDelegate) =>
      oldDelegate.height != height ||
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.dividerColor != dividerColor ||
      oldDelegate.child != child;
}
