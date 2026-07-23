import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Theme-aware color helper.
/// Use `AppThemeColors.of(context)` to get colors that adapt to light/dark mode.
class AppThemeColors {
  final bool isDark;

  AppThemeColors._(this.isDark);

  factory AppThemeColors.of(BuildContext context) {
    return AppThemeColors._(Theme.of(context).brightness == Brightness.dark);
  }

  // ── Text Colors ────────────────────────────────────────────────
  Color get textPrimary =>
      isDark ? Colors.white : const Color(0xFF0F172A);

  Color get textSecondary =>
      isDark ? const Color(0xFF6B8A9D) : const Color(0xFF475569);

  Color get textTertiary =>
      isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF64748B);

  Color get textInverse =>
      isDark ? const Color(0xFF0F172A) : Colors.white;

  // ── Card Surfaces ──────────────────────────────────────────────
  Color get cardBg =>
      isDark ? AppColors.darkCardBg.withValues(alpha: 0.9) : const Color(0xFFFFFFFF);

  Color get cardHero =>
      isDark ? AppColors.darkCardHero.withValues(alpha: 0.9) : const Color(0xFFF8FAFC);

  Color get cardInner =>
      isDark ? AppColors.darkCardInner : const Color(0xFFF1F5F9);

  Color get cardHeader =>
      isDark ? AppColors.darkCardHeader : const Color(0xFFE2E8F0);

  // ── Borders ────────────────────────────────────────────────────
  Color get borderColor =>
      isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0);

  Color get borderSubtle =>
      isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9);

  // ── Button Surfaces ────────────────────────────────────────────
  Color get buttonPrimary => AppColors.primaryColor;

  Color get buttonSecondary =>
      isDark ? const Color(0xFF163456) : const Color(0xFFEFF6FF);

  Color get buttonSecondaryText =>
      isDark ? Colors.white : AppColors.primaryColor;

  Color get logoutBg =>
      isDark ? AppColors.darkLogoutBg : const Color(0xFFFEF2F2);

  Color get logoutText => AppColors.accentRed;

  // ── Pill / Badge ───────────────────────────────────────────────
  Color get pillBg =>
      isDark ? const Color(0xFF132B47) : const Color(0xFFEFF6FF);

  Color get pillText =>
      isDark ? AppColors.primaryColor : const Color(0xFF1D4ED8);

  Color get greenPillBg =>
      isDark ? AppColors.darkGreenPill : const Color(0xFFECFDF5);

  Color get greenPillText => AppColors.successGreen;

  // ── Nav Bar ────────────────────────────────────────────────────
  Color get navBg =>
      isDark
          ? AppColors.darkNavBg.withValues(alpha: 0.8)
          : Colors.white.withValues(alpha: 0.9);

  Color get navBorder =>
      isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8F0);

  Color get navSelectedPill =>
      isDark ? AppColors.darkPillBg : const Color(0xFFEFF6FF);

  Color get navIcon =>
      isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF94A3B8);

  Color get navSelectedIcon =>
      isDark ? Colors.white : AppColors.primaryColor;

  Color get navSelectedText =>
      isDark ? Colors.white : AppColors.primaryColor;

  // ── Chat / Avatar ──────────────────────────────────────────────
  Color get chatAvatarBg =>
      isDark ? const Color(0xFF1E2D3D) : const Color(0xFFE2E8F0);

  Color get unreadBadge => AppColors.primaryColor;

  // ── Progress Bars ──────────────────────────────────────────────
  Color get progressBg =>
      isDark ? const Color(0xFF1E334D) : const Color(0xFFE2E8F0);

  Color get progressFill => AppColors.accentRed;

  // ── Shadow ─────────────────────────────────────────────────────
  Color get shadowColor =>
      isDark
          ? Colors.black.withValues(alpha: 0.35)
          : Colors.black.withValues(alpha: 0.08);

  // ── Modal / Sheet ──────────────────────────────────────────────
  Color get sheetBg =>
      isDark ? AppColors.darkCardHero : Colors.white;
}
