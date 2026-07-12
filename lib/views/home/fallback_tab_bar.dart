import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:Braintech/data/models/nav_tab.dart';

/// Flutter-rendered tab bar for platforms where cupertino_native is
/// unavailable (Android, web, desktop). Mirrors the floating pill look of
/// the native CNTabBar, including dragging the selection capsule along the
/// bar with your finger.
class FallbackTabBar extends StatefulWidget {
  const FallbackTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    this.tint = const Color(0xFF00FFC2), // matching DiasporaVest premium primary color
  });

  final List<NavTab> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color tint;

  @override
  State<FallbackTabBar> createState() => _FallbackTabBarState();
}

class _FallbackTabBarState extends State<FallbackTabBar> {
  static const double _capsuleMargin = 6;

  /// Finger x-position within the bar while dragging, null otherwise.
  double? _dragX;

  int _indexAt(double x, double barWidth) {
    final itemWidth = barWidth / widget.tabs.length;
    return (x ~/ itemWidth).clamp(0, widget.tabs.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, bottomInset + 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xB30D1F30), // premium dark background of DiasporaVest
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: const Color(0x26FFFFFF), width: 0.5),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final barWidth = constraints.maxWidth;
                final itemWidth = barWidth / widget.tabs.length;
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
                  onTapUp: (details) =>
                      widget.onTap(_indexAt(details.localPosition.dx, barWidth)),
                  onHorizontalDragStart: (details) =>
                      setState(() => _dragX = details.localPosition.dx),
                  onHorizontalDragUpdate: (details) => setState(() =>
                      _dragX = details.localPosition.dx.clamp(0.0, barWidth)),
                  onHorizontalDragEnd: (_) {
                    final index = _indexAt(_dragX!, barWidth);
                    setState(() => _dragX = null);
                    widget.onTap(index);
                  },
                  onHorizontalDragCancel: () => setState(() => _dragX = null),
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: dragging
                            ? Duration.zero
                            : const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        left: capsuleLeft + _capsuleMargin,
                        top: _capsuleMargin,
                        bottom: _capsuleMargin,
                        width: itemWidth - _capsuleMargin * 2,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: widget.tint.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          for (var i = 0; i < widget.tabs.length; i++)
                            Expanded(
                              child: _TabItem(
                                tab: widget.tabs[i],
                                selected: i == activeIndex,
                                tint: widget.tint,
                              ),
                            ),
                        ],
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
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.tab,
    required this.selected,
    required this.tint,
  });

  final NavTab tab;
  final bool selected;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final color = selected ? tint : CupertinoColors.white;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(tab.fallbackIcon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          tab.label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}
