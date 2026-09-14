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
              size: 22.r,
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
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 16.h,
            ),
            child: Column(
              children: [
                _buildProfilePhotoHeader(info, tc),
                SizedBox(height: 20.h),
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
                SizedBox(height: 16.h),
                InfoSectionCard(
                  title: "Professional Information",
                  rows: [
                    InfoRowData("Company Name", info.companyName),
                    InfoRowData("Position", info.position),
                    InfoRowData("Website", info.website),
                    InfoRowData("Bio", info.bio),
                  ],
                ),
                SizedBox(height: 24.h),
                _buildEditButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePhotoHeader(dynamic info, AppThemeColors tc) {
    final photoUrl = info.profilePhotoUrl ??
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=250&auto=format&fit=crop";

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
              border: Border.all(
                color: const Color(0xFF006EDB),
                width: 2.w,
              ),
            ),
            child: CircleAvatar(
              radius: 44.r,
              backgroundImage: NetworkImage(photoUrl),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            info.fullName,
            style: GoogleFonts.outfit(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            "${info.position} • ${info.companyName}",
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              color: tc.textSecondary,
            ),
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
            Icon(
              Icons.edit_outlined,
              color: Colors.white,
              size: 20.r,
            ),
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
