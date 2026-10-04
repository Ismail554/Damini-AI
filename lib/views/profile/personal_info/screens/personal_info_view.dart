import 'package:Braintech/core/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/common_background.dart';
import '../controllers/personal_info_provider.dart';
import '../models/personal_info_model.dart';
import '../widgets/info_section_card.dart';

class PersonalInformationView extends ConsumerWidget {
  const PersonalInformationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);
    final info = ref.watch(personalInfoProvider).info;

    return CommonBackground(
      showGrid: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: tc.textPrimary,
              size: 22.sp,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            "Personal Information",
            style: GoogleFonts.outfit(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
            ),
          ),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => ref.read(personalInfoProvider.notifier).refresh(),
            color: const Color(0xFF006EDB),
            backgroundColor: tc.cardBg,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                children: [
                  _buildProfilePhotoHeader(info, tc),
                  AppSpacing.h20,
                  InfoSectionCard(
                    title: "Personal Information",
                    rows: [
                      InfoRowData("Full Name", info.fullName),
                      InfoRowData("Email Address", info.email),
                      InfoRowData("Phone Number", info.phone),
                      InfoRowData("Country", info.country),
                      InfoRowData("Location", info.location),
                    ],
                  ),
                  AppSpacing.h16,
                  InfoSectionCard(
                    title: "Professional Information",
                    rows: [
                      InfoRowData("Position / Title", info.position),
                      InfoRowData("Bio", info.bio),
                      if (!info.isCompany && info.website.isNotEmpty)
                        InfoRowData("Website", info.website),
                    ],
                  ),
                  if (info.isCompany ||
                      info.companyName.isNotEmpty ||
                      (info.registrationNumber != null &&
                          info.registrationNumber!.isNotEmpty)) ...[
                    AppSpacing.h16,
                    InfoSectionCard(
                      title: "Company Details",
                      rows: [
                        InfoRowData("Company Name", info.companyName),
                        InfoRowData(
                            "Registration No.", info.registrationNumber ?? ''),
                        InfoRowData(
                            "Business Address", info.businessAddress ?? ''),
                        InfoRowData("Company Website", info.website),
                      ],
                    ),
                  ],
                  AppSpacing.h24,
                  _buildEditButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePhotoHeader(PersonalInfoModel info, AppThemeColors tc) {
    final subtitleParts = [
      if (info.position.trim().isNotEmpty) info.position.trim(),
      if (info.companyName.trim().isNotEmpty) info.companyName.trim(),
    ];
    final subtitle = subtitleParts.isNotEmpty
        ? subtitleParts.join(' • ')
        : (info.role.isNotEmpty
            ? info.role
            : (info.email.isNotEmpty ? info.email : 'Member'));

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: tc.isDark ? const Color(0xFF092444) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: tc.isDark
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF006EDB), width: 2.w),
            ),
            child: AppAvatar(
              imageUrl: info.profilePhotoUrl,
              name: info.fullName,
              radius: 44.r,
            ),
          ),
          AppSpacing.h12,
          Text(
            info.fullName,
            style: GoogleFonts.outfit(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
            ),
          ),
          AppSpacing.h4,
          Text(
            subtitle,
            style: GoogleFonts.outfit(fontSize: 13.sp, color: tc.textSecondary),
          ),
          if (info.sponsorType != null &&
              (info.sponsorType as String).isNotEmpty) ...[
            AppSpacing.h10,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: (info.isCompany
                        ? const Color(0xFF006EDB)
                        : const Color(0xFF10B981))
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                info.isCompany ? "COMPANY SPONSOR" : "INDIVIDUAL SPONSOR",
                style: GoogleFonts.outfit(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: info.isCompany
                      ? const Color(0xFF006EDB)
                      : const Color(0xFF10B981),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/edit-profile'),
      child: Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          color: const Color(0xFF006EDB),
          borderRadius: BorderRadius.circular(26.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF006EDB).withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_outlined, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              "Edit",
              style: GoogleFonts.outfit(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
