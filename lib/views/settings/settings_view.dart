import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_provider.dart';
import '../../controllers/theme_provider.dart';
import '../../core/utils/app_theme_colors.dart';
import '../../core/widgets/common_background.dart';
import 'controllers/settings_provider.dart';
import 'widgets/delete_account_dialog.dart';
import 'widgets/settings_item_tile.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: CommonBackground(
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
            child: Consumer<SettingsProvider>(
              builder: (context, provider, _) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    children: [
                      _buildSettingsCard(context, tc, provider),
                      SizedBox(height: 24.h),
                      _buildDeleteAccountButton(context, tc),
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

  Widget _buildSettingsCard(
    BuildContext context,
    AppThemeColors tc,
    SettingsProvider provider,
  ) {
    final themeProvider = context.watch<ThemeProvider>();

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
            trailing: CupertinoSwitch(
              value: provider.notificationsEnabled,
              activeTrackColor: const Color(0xFF2563EB),
              onChanged: provider.toggleNotifications,
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
            icon: Icons.wb_sunny_outlined,
            title: "Mode",
            onTap: () {
              final nextMode = themeProvider.themeMode == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
              themeProvider.setThemeMode(nextMode);
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

  Widget _buildDeleteAccountButton(BuildContext context, AppThemeColors tc) {
    return GestureDetector(
      onTap: () async {
        final confirmed = await DeleteAccountDialog.show(context);
        if (confirmed == true && context.mounted) {
          final auth = context.read<AuthProvider>();
          await auth.logout();
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
