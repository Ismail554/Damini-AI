import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/app_colors.dart';
import '../../core/widgets/common_background.dart';
import '../../shared/screens/company_verification_screen.dart';
import '../../shared/screens/complete_profile_screen.dart';
import '../../shared/screens/role_feature_slides_screen.dart';

class RoleOnboardingView extends StatefulWidget {
  final String role;
  const RoleOnboardingView({super.key, required this.role});

  @override
  State<RoleOnboardingView> createState() => _RoleOnboardingViewState();
}

class _RoleOnboardingViewState extends State<RoleOnboardingView> {
  final PageController _pageCtrl = PageController();
  int _currentStep = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < 3) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    } else {
      if (Navigator.of(context).canPop()) {
        context.pop();
      } else {
        context.go('/role-selection');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonBackground(
      showGrid: false,
      child: SafeArea(
        child: PageView(
          controller: _pageCtrl,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            RoleFeatureSlidesScreen(
              role: widget.role,
              onCompleted: _nextPage,
              onBack: _prevPage,
            ),
            CompleteProfileScreen(
              role: widget.role,
              onSaved: _nextPage,
              onBack: _prevPage,
            ),
            CompanyVerificationScreen(
              role: widget.role,
              onSubmit: _nextPage,
              onBack: _prevPage,
            ),
            _buildPendingStep(),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingStep() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty_rounded,
            color: Colors.orangeAccent,
            size: 80.r,
          ),
          SizedBox(height: 24.h),
          Text(
            "Verification Pending",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "Our compliance team is currently reviewing your documents. You can browse the platform in the meantime.",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: AppColors.grey,
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
          SizedBox(height: 40.h),
          SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27.r),
                ),
              ),
              child: Text(
                "Explore App",
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
