import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/widgets/common_background.dart';
import 'controllers/personal_info_provider.dart';
import 'widgets/info_section_card.dart';

class PersonalInformationView extends StatelessWidget {
  const PersonalInformationView({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return ChangeNotifierProvider(
      create: (_) => PersonalInfoProvider(),
      child: CommonBackground(
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
            child: Consumer<PersonalInfoProvider>(
              builder: (context, provider, _) {
                final info = provider.info;
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    children: [
                      InfoSectionCard(
                        title: "Personal Information",
                        rows: [
                          InfoRowData("Full Name", info.fullName),
                          InfoRowData("Email", info.email),
                          InfoRowData("Phone", info.phone),
                          InfoRowData("Country", info.country),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      InfoSectionCard(
                        title: "Company",
                        rows: [
                          InfoRowData("Company", info.companyName),
                          InfoRowData("Position", info.position),
                          InfoRowData("Website", info.website),
                        ],
                      ),
                      SizedBox(height: 32.h),
                      _buildEditButton(context),
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
