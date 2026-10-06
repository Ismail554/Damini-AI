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
import 'package:Braintech/core/widgets/custom_snackbar.dart';
import 'package:Braintech/core/widgets/logout_dialog.dart';
import '../../profile/personal_info/controllers/personal_info_provider.dart';
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
          child: RefreshIndicator(
            onRefresh: () => ref.read(settingsProvider.notifier).refresh(),
            color: const Color(0xFF2563EB),
            backgroundColor: tc.cardBg,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 16.h,
              ),
              child: Column(
                children: [
                  _buildProfileHeaderCard(context, tc, provider),
                  SizedBox(height: 16.h),
                  _buildSettingsCard(context, tc, provider, theme, ref),
                  SizedBox(height: 24.h),
                  _buildDeleteAccountButton(context, tc, ref),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard(
    BuildContext context,
    AppThemeColors tc,
    SettingsState state,
  ) {
    final initials = state.displayName.isNotEmpty
        ? state.displayName
            .split(' ')
            .where((w) => w.isNotEmpty)
            .map((e) => e[0])
            .take(2)
            .join()
        : 'U';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: tc.isDark ? const Color(0xFF091E36) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: tc.isDark
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26.r,
            backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.15),
            backgroundImage: (state.profilePhoto != null &&
                    state.profilePhoto!.isNotEmpty)
                ? NetworkImage(state.profilePhoto!)
                : null,
            child: (state.profilePhoto == null || state.profilePhoto!.isEmpty)
                ? Text(
                    initials.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2563EB),
                    ),
                  )
                : null,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        state.displayName,
                        style: GoogleFonts.outfit(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color: tc.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (state.role.isNotEmpty) ...[
                      SizedBox(width: 8.w),
                      _buildRoleBadge(state.role),
                    ],
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  state.email.isNotEmpty ? state.email : "Loading profile...",
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    color: tc.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: const Color(0xFF2563EB).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        role.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF38BDF8),
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
    final verificationStatus = provider.verificationStatus.toUpperCase();
    final personalInfo = ref.watch(personalInfoProvider).info;
    final isApproved = verificationStatus == 'APPROVED';
    final isPending = verificationStatus == 'PENDING';
    final statusColor = isApproved
        ? const Color(0xFF10B981)
        : isPending
            ? const Color(0xFFF59E0B)
            : const Color(0xFF64748B);

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
            subtitle: provider.email.isNotEmpty ? provider.email : null,
            onTap: () => context.push('/personal-info'),
          ),
          if (personalInfo.isCompany) ...[
            _divider(tc),
            SettingsItemTile(
              icon: Icons.verified_user_outlined,
              title: "Company Verification",
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      verificationStatus,
                      style: GoogleFonts.outfit(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: tc.textTertiary,
                    size: 22.r,
                  ),
                ],
              ),
              onTap: () => context.push('/company-verification'),
            ),
          ],
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    provider.subscriptionTier,
                    style: GoogleFonts.outfit(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF38BDF8),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.chevron_right_rounded,
                  color: tc.textTertiary,
                  size: 22.r,
                ),
              ],
            ),
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
        final password = await DeleteAccountDialog.show(context);
        if (password != null && password.isNotEmpty && context.mounted) {
          try {
            await ref.read(settingsProvider.notifier).deleteAccount(password);
            if (context.mounted) {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                CustomSnackBar.success(
                  context,
                  "Your account has been deleted successfully.",
                );
                context.go('/login');
              }
            }
          } catch (e) {
            if (context.mounted) {
              CustomSnackBar.error(
                context,
                "Failed to delete account. Please verify your password.",
              );
            }
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
