import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shared page builder used by every route.
///
/// - iOS: native Cupertino transition (keeps the swipe-back gesture).
/// - Others: smooth shared-axis style slide + fade, with a subtle parallax on
///   the page underneath. Pages are isolated in a [RepaintBoundary] so the
///   transition animates a cached layer instead of repainting the screen.
Page<T> buildNativePage<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
  if (isIOS) {
    return CupertinoPage<T>(
      key: state.pageKey,
      child: RepaintBoundary(child: child),
    );
  }

  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: RepaintBoundary(child: child),
    transitionDuration: const Duration(milliseconds: 340),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final enter = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final exit = CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return SlideTransition(
        // Underlying page drifts left slightly (parallax).
        position: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.08, 0),
        ).animate(exit),
        child: FadeTransition(
          opacity: Tween<double>(begin: 1, end: 0.9).animate(exit),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.12, 0),
              end: Offset.zero,
            ).animate(enter),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
                ),
              ),
              child: child,
            ),
          ),
        ),
      );
    },
  );
}
