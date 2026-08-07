import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Consistent dimension tokens used across the entire app.
/// All values are ScreenUtil-adapted for responsive scaling.
class AppDimens {
  AppDimens._();

  // ── Border Radius ──────────────────────────────────────────────
  static double radiusSm = 12.r;
  static double radiusMd = 16.r;
  static double radiusLg = 20.r;
  static double radiusXl = 24.r;
  static double radiusPill = 36.r;

  // ── Padding / Margin ───────────────────────────────────────────
  static double paddingSm = 8.r;
  static double paddingMd = 14.r;
  static double paddingLg = 20.r;
  static double paddingXl = 24.r;
  static double screenHorizontal = 20.w;
  static double screenVertical = 16.h;

  // ── Vertical Spacing ──────────────────────────────────────────
  static double spaceXxs = 2.h;
  static double spaceXs = 4.h;
  static double spaceSm = 6.h;
  static double spaceSmd = 8.h;
  static double spaceMd = 12.h;
  static double spaceLg = 16.h;
  static double spaceXl = 20.h;
  static double spaceXxl = 28.h;
  static double spaceSection = 40.h;

  // ── Icon Sizes ─────────────────────────────────────────────────
  static double iconSm = 16.r;
  static double iconMd = 20.r;
  static double iconLg = 22.r;
  static double iconXl = 28.r;

  // ── Avatar / Image ─────────────────────────────────────────────
  static double avatarSm = 22.r;
  static double avatarMd = 24.r;
  static double avatarLg = 36.r;

  // ── Bottom Nav Bar ─────────────────────────────────────────────
  static double navBarHeight = 72.h;
  static double navBarMarginH = 16.w;
  static double navBarMarginV = 12.h;

  // ── Button Heights ─────────────────────────────────────────────
  static double buttonSm = 36.h;
  static double buttonMd = 48.h;
  static double buttonLg = 46.h;
  static double buttonXl = 54.h;

  // ── Card border width ──────────────────────────────────────────
  static double borderThin = 1.w;
  static double borderMedium = 2.w;

  // ── FAB Bottom Offset ──────────────────────────────────────────
  static double fabBottomOffset = 100.h;
}
