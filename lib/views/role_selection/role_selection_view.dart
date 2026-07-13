import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_provider.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/asset_manager.dart';
import '../../core/widgets/common_background.dart';

class RoleSelectionView extends StatelessWidget {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonBackground(
      showGrid: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Center(
              child: Image.asset(
                IconAssets.app_logo,
                width: 48.r,
                height: 48.r,
              ),
            ),
            SizedBox(height: 36.h),
            Text(
              "Choose Your Role",
              style: GoogleFonts.outfit(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Select how you want to participate in the Damini AI ecosystem.",
              style: GoogleFonts.outfit(
                fontSize: 15.sp,
                color: AppColors.grey,
              ),
            ),
            SizedBox(height: 40.h),
            
            // Investor Card
            Expanded(
              child: _buildRoleCard(
                context: context,
                role: "investor",
                title: "Diaspora Investor",
                desc: "Discover premium projects, connect with verified sponsors, and network with global investors.",
                accentColor: AppColors.primaryColor,
                icon: Icons.trending_up_rounded,
              ),
            ),
            SizedBox(height: 20.h),
            
            // Sponsor Card
            Expanded(
              child: _buildRoleCard(
                context: context,
                role: "sponsor",
                title: "Project Sponsor",
                desc: "Pitch high-yielding opportunities, secure institutional funding, and scale your business globally.",
                accentColor: AppColors.success,
                icon: Icons.business_center_rounded,
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String role,
    required String title,
    required String desc,
    required Color accentColor,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () async {
        final auth = context.read<AuthProvider>();
        await auth.setRole(role);
        if (context.mounted) {
          context.go('/role-onboarding', extra: {'role': role});
        }
      },
      child: Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: AppColors.secondaryColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1.5.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15.r,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 28.r,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.3),
                  size: 16.r,
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              desc,
              style: GoogleFonts.outfit(
                fontSize: 13.sp,
                color: AppColors.grey,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
