import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Braintech/views/auth/session/controllers/session_provider.dart';
import 'package:Braintech/core/theme/theme_provider.dart';
import 'package:Braintech/core/utils/app_theme_colors.dart';
import 'package:Braintech/core/widgets/common_background.dart';
import 'package:Braintech/core/widgets/logout_dialog.dart';
import '../controllers/settings_provider.dart';
import '../widgets/delete_account_dialog.dart';
import '../widgets/settings_item_tile.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);
    final provider = ref.watch(settingsProvider);
    final theme = ref.watch(themeProvider);

    return CommonBackground(
      showGrid: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: tc.textPrimary,
              size: 22.r,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            "Settings",
            style: GoogleFonts.outfit(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 16.h,
            ),
            child: Column(
              children: [
                _buildSettingsCard(context, tc, provider, theme, ref),
                SizedBox(height: 24.h),
                _buildDeleteAccountButton(context, tc, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context,
    AppThemeColors tc,
    SettingsState provider,
    ThemeMode theme,
    WidgetRef ref,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: tc.isDark ? const Color(0xFF091E36) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: tc.isDark
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          SettingsItemTile(
            icon: Icons.person_outline_rounded,
            title: "Personal Information",
            onTap: () => context.push('/personal-info'),
          ),
          _divider(tc),
          SettingsItemTile(
            icon: Icons.verified_user_outlined,
            title: "Company Verification",
            onTap: () => context.push('/company-verification'),
          ),
          _divider(tc),
          SettingsItemTile(
            icon: Icons.assignment_outlined,
            title: "Non-Disclosure Agreement",
            onTap: () => context.push('/nda'),
          ),
          _divider(tc),
          SettingsItemTile(
            icon: Icons.notifications_none_rounded,
            title: "Notifications",
            trailing: Transform.scale(
              scale: 0.75,
              alignment: Alignment.centerRight,
              child: CupertinoSwitch(
                value: provider.notificationsEnabled,
                activeTrackColor: const Color(0xFF2563EB),
                onChanged: (val) => ref
                    .read(settingsProvider.notifier)
                    .toggleNotifications(val),
              ),
            ),
          ),
          _divider(tc),
          SettingsItemTile(
            icon: Icons.auto_awesome_outlined,
            title: "Subscription Plan",
            onTap: () => context.push('/subscription'),
          ),
          _divider(tc),
          SettingsItemTile(
            icon: Icons.lock_outline_rounded,
            title: "Change Password",
            onTap: () => context.push('/change-password'),
          ),
          _divider(tc),
          SettingsItemTile(
            icon: theme == ThemeMode.dark
                ? Icons.dark_mode_outlined
                : Icons.wb_sunny_outlined,
            title: "Dark Mode",
            trailing: Transform.scale(
              scale: 0.75,
              alignment: Alignment.centerRight,
              child: CupertinoSwitch(
                value: theme == ThemeMode.dark,
                activeTrackColor: const Color(0xFF2563EB),
                onChanged: (bool isDark) {
                  ref.read(themeProvider.notifier).setThemeMode(
                    isDark ? ThemeMode.dark : ThemeMode.light,
                  );
                },
              ),
            ),
            onTap: () {
              final nextMode = theme == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
              ref.read(themeProvider.notifier).setThemeMode(nextMode);
            },
          ),
          _divider(tc),
          SettingsItemTile(
            icon: Icons.shield_outlined,
            title: "Privacy Policy",
            onTap: () {},
          ),
          _divider(tc),
          SettingsItemTile(
            icon: Icons.description_outlined,
            title: "Terms & Conditions",
            onTap: () {},
          ),
          _divider(tc),
          SettingsItemTile(
            icon: Icons.logout_rounded,
            title: "Log Out",
            textColor: const Color(0xFFEF4444),
            iconColor: const Color(0xFFEF4444),
            iconBgColor: tc.isDark
                ? const Color(0xFF4A151B).withValues(alpha: 0.5)
                : const Color(0xFFFEE2E2),
            trailing: const SizedBox.shrink(),
            onTap: () async {
              final confirmed = await LogoutDialog.show(context);
              if (confirmed == true && context.mounted) {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _divider(AppThemeColors tc) {
    return Divider(
      height: 1,
      thickness: 1,
      color: tc.isDark
          ? Colors.white.withValues(alpha: 0.08)
          : const Color(0xFFF1F5F9),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context, AppThemeColors tc, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final confirmed = await DeleteAccountDialog.show(context);
        if (confirmed == true && context.mounted) {
          await ref.read(authProvider.notifier).logout();
          if (context.mounted) {
            context.go('/login');
          }
        }
      },
      child: Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          color: tc.isDark ? const Color(0xFF4A151B) : const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(26.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: const Color(0xFFEF4444),
              size: 20.r,
            ),
            SizedBox(width: 8.w),
            Text(
              "Delete Account",
              style: GoogleFonts.outfit(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
