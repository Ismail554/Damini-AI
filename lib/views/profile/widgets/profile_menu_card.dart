import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../controllers/theme_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_dimens.dart';
import '../../../core/utils/app_theme_colors.dart';

class ProfileMenuCard extends StatelessWidget {
  const ProfileMenuCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: tc.cardHero,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: tc.borderColor, width: AppDimens.borderThin),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            tc: tc,
            title: "Theme Settings",
            subtitle: _getThemeLabel(themeProvider.themeMode),
            icon: Icons.palette_outlined,
            onTap: () => _showThemeSelectionSheet(context, themeProvider),
          ),
          Divider(color: tc.borderSubtle, height: 1),
          _buildMenuItem(
            tc: tc,
            title: "Personal Information",
            icon: Icons.person_outline_rounded,
            onTap: () {},
          ),
          Divider(color: tc.borderSubtle, height: 1),
          _buildMenuItem(
            tc: tc,
            title: "Saved Projects",
            icon: Icons.bookmark_border_rounded,
            onTap: () {},
          ),
          Divider(color: tc.borderSubtle, height: 1),
          _buildMenuItem(
            tc: tc,
            title: "Investment History",
            icon: Icons.trending_up_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return "Dark Mode";
      case ThemeMode.light:
        return "Light Mode";
      case ThemeMode.system:
        return "System Default";
    }
  }

  void _showThemeSelectionSheet(BuildContext context, ThemeProvider provider) {
    final tc = AppThemeColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: tc.sheetBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXl)),
      ),
      builder: (context) {
        final sheetTc = AppThemeColors.of(context);
        return Padding(
          padding: EdgeInsets.all(AppDimens.paddingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Choose Theme",
                style: GoogleFonts.outfit(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: sheetTc.textPrimary,
                ),
              ),
              SizedBox(height: AppDimens.spaceLg),
              _buildThemeOption(context, sheetTc,
                  title: "System Default",
                  mode: ThemeMode.system,
                  currentMode: provider.themeMode,
                  onSelect: () {
                    provider.setThemeMode(ThemeMode.system);
                    Navigator.pop(context);
                  }),
              _buildThemeOption(context, sheetTc,
                  title: "Dark Theme",
                  mode: ThemeMode.dark,
                  currentMode: provider.themeMode,
                  onSelect: () {
                    provider.setThemeMode(ThemeMode.dark);
                    Navigator.pop(context);
                  }),
              _buildThemeOption(context, sheetTc,
                  title: "Light Theme",
                  mode: ThemeMode.light,
                  currentMode: provider.themeMode,
                  onSelect: () {
                    provider.setThemeMode(ThemeMode.light);
                    Navigator.pop(context);
                  }),
              SizedBox(height: AppDimens.spaceLg),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    AppThemeColors tc, {
    required String title,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required VoidCallback onSelect,
  }) {
    final isSelected = mode == currentMode;
    return ListTile(
      onTap: onSelect,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 15.sp,
          color: tc.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: AppColors.primaryColor, size: AppDimens.iconMd)
          : null,
    );
  }

  Widget _buildMenuItem({
    required AppThemeColors tc,
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppDimens.paddingLg,
        vertical: AppDimens.spaceXs,
      ),
      leading: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: tc.cardHeader,
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        ),
        child: Icon(icon, color: tc.textPrimary, size: AppDimens.iconMd),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: tc.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.outfit(fontSize: 12.sp, color: tc.textSecondary),
            )
          : null,
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: tc.textTertiary,
        size: 14.r,
      ),
    );
  }
}
