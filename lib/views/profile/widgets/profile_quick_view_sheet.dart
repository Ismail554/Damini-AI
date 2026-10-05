import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_theme_colors.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../auth/session/controllers/session_provider.dart';
import '../personal_info/controllers/personal_info_provider.dart';

class ProfileQuickViewSheet extends ConsumerWidget {
  final String? name;
  final String? title;
  final String? company;
  final String? avatarUrl;
  final String? role;
  final String? verificationStatus;

  const ProfileQuickViewSheet({
    super.key,
    this.name,
    this.title,
    this.company,
    this.avatarUrl,
    this.role,
    this.verificationStatus,
  });

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const ProfileQuickViewSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);
    final personalInfo = ref.watch(personalInfoProvider).info;
    final authRole = ref.watch(authProvider).userRole;

    final effectiveName = name ??
        (personalInfo.fullName.isNotEmpty && personalInfo.fullName != 'Member'
            ? personalInfo.fullName
            : (authRole == 'investor' ? 'Investor' : 'Sponsor'));

    final effectiveTitle = title ??
        (personalInfo.position.isNotEmpty
            ? personalInfo.position
            : (personalInfo.companyName.isNotEmpty
                ? personalInfo.companyName
                : (authRole == 'investor'
                    ? 'Angel Investor'
                    : 'Sponsor Partner')));

    final effectiveCompany = company ?? personalInfo.companyName;
    final effectiveAvatarUrl = avatarUrl ?? personalInfo.profilePhotoUrl;

    final roleStr =
        role ?? (personalInfo.role.isNotEmpty ? personalInfo.role : authRole);
    final isInvestor = (roleStr ?? '').toLowerCase() == 'investor';
    final roleLabel = isInvestor ? 'Investor' : 'Sponsor';

    final status = (verificationStatus ??
            personalInfo.verificationStatus ??
            'PENDING')
        .toUpperCase();
    final isApproved = status == 'APPROVED';
    final statusLabel = isApproved
        ? 'Verified'
        : (status == 'REJECTED' ? 'Rejected' : 'Pending');
    final statusBg = isApproved
        ? const Color(0xFF064E3B)
        : (status == 'REJECTED'
            ? const Color(0xFF450A0A)
            : const Color(0xFF451A03));
    final statusTextColor = isApproved
        ? const Color(0xFF10B981)
        : (status == 'REJECTED'
            ? const Color(0xFFEF4444)
            : const Color(0xFFF59E0B));

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: tc.isDark ? const Color(0xFF091E36) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(
          color: tc.isDark
              ? Colors.white.withValues(alpha: 0.15)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: tc.textTertiary.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),

          // Profile Header
          Row(
            children: [
              Stack(
                children: [
                  AppAvatar(
                    imageUrl: effectiveAvatarUrl,
                    name: effectiveName,
                    radius: 30.r,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.all(3.r),
                      decoration: BoxDecoration(
                        color: statusTextColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isApproved
                            ? Icons.verified_rounded
                            : Icons.shield_outlined,
                        color: Colors.white,
                        size: 11.r,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      effectiveName,
                      style: GoogleFonts.outfit(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: tc.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      effectiveTitle,
                      style: GoogleFonts.outfit(
                        fontSize: 13.sp,
                        color: tc.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        _buildBadge(
                          roleLabel,
                          isInvestor
                              ? const Color(0xFF059669)
                              : const Color(0xFF1D4ED8),
                        ),
                        SizedBox(width: 6.w),
                        _buildBadge(
                          statusLabel,
                          statusBg,
                          textColor: statusTextColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Divider(
            height: 1,
            color: tc.isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFF1F5F9),
          ),
          SizedBox(height: 12.h),

          // Quick Action Tiles
          _buildActionTile(
            context,
            tc,
            icon: Icons.person_outline_rounded,
            title: "View Public Profile",
            onTap: () {
              context.pop();
              context.push(
                '/public-profile',
                extra: {
                  'name': effectiveName,
                  'title': effectiveTitle,
                  'company': effectiveCompany,
                  'avatarUrl': effectiveAvatarUrl ?? '',
                  'isOwnProfile': true,
                },
              );
            },
          ),
          _buildActionTile(
            context,
            tc,
            icon: Icons.assignment_ind_outlined,
            title: "Personal Information",
            onTap: () {
              context.pop();
              context.push('/personal-info');
            },
          ),
          if (personalInfo.isCompany)
            _buildActionTile(
              context,
              tc,
              icon: Icons.verified_user_outlined,
              title: "Company Verification",
              onTap: () {
                context.pop();
                context.push('/company-verification');
              },
            ),
          _buildActionTile(
            context,
            tc,
            icon: Icons.settings_outlined,
            title: "Settings",
            onTap: () {
              context.pop();
              context.push('/settings');
            },
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bg, {Color textColor = Colors.white}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    AppThemeColors tc, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: tc.isDark ? const Color(0xFF07172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: tc.textPrimary, size: 20.r),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: tc.textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: tc.textTertiary,
        size: 20.r,
      ),
    );
  }
}
