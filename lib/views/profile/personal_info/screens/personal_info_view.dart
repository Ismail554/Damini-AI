import 'package:Braintech/core/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/widgets/common_background.dart';
import '../controllers/personal_info_provider.dart';
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
                      InfoRowData("Company Name", info.companyName),
                      InfoRowData("Info", info.position),
                      InfoRowData("Website", info.website),
                      InfoRowData("Bio", info.bio),
                    ],
                  ),
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

  Widget _buildProfilePhotoHeader(dynamic info, AppThemeColors tc) {
    final initials = (info.fullName as String).isNotEmpty
        ? (info.fullName as String)
              .split(' ')
              .where((w) => w.isNotEmpty)
              .map((e) => e[0])
              .take(2)
              .join()
        : 'U';

    final hasPhoto =
        info.profilePhotoUrl != null &&
        (info.profilePhotoUrl as String).isNotEmpty;

    final subtitleParts = [
      if ((info.position as String).trim().isNotEmpty)
        (info.position as String).trim(),
      if ((info.companyName as String).trim().isNotEmpty)
        (info.companyName as String).trim(),
    ];
    final subtitle = subtitleParts.isNotEmpty
        ? subtitleParts.join(' • ')
        : ((info.role as String).isNotEmpty
              ? (info.role as String)
              : ((info.email as String).isNotEmpty
                    ? (info.email as String)
                    : 'Member'));

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
            child: CircleAvatar(
              radius: 44.r,
              backgroundColor: tc.buttonSecondary,
              backgroundImage: hasPhoto
                  ? NetworkImage(info.profilePhotoUrl!)
                  : null,
              child: !hasPhoto
                  ? Text(
                      initials.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF006EDB),
                      ),
                    )
                  : null,
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
