import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/app_colors.dart';
import '../../core/widgets/common_background.dart';
import '../auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageCtrl = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      "title": "Premium Networking",
      "desc": "Seamlessly connect sponsors and global diaspora investors under a unified platform.",
      "icon": Icons.connect_without_contact_rounded,
    },
    {
      "title": "Project Discovery",
      "desc": "Discover high-yielding verified opportunities tailored to your financial guidelines.",
      "icon": Icons.explore_rounded,
    },
    {
      "title": "Secure Investments",
      "desc": "Benefit from robust identity checks and secure pipeline compliance verification.",
      "icon": Icons.gpp_good_rounded,
    },
    {
      "title": "Global Scaling",
      "desc": "Harness diaspora capital to scale businesses and yield global financial impact.",
      "icon": Icons.public_rounded,
    }
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _onFinishOnboarding() async {
    await StorageService.saveUuid("completed_onboarding");
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonBackground(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          children: [
            // Skip Button at Top Right
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _onFinishOnboarding,
                child: Text(
                  "Skip",
                  style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            
            // Swipeable Pages
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _slides.length,
                onPageChanged: (idx) => setState(() => _currentIndex = idx),
                itemBuilder: (context, idx) {
                  final slide = _slides[idx];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(32.r),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(slide["icon"] as IconData, color: AppColors.primaryColor, size: 72.r),
                      ),
                      SizedBox(height: 48.h),
                      Text(
                        slide["title"] as String,
                        style: GoogleFonts.outfit(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        slide["desc"] as String,
                        style: GoogleFonts.outfit(fontSize: 15.sp, color: AppColors.grey, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),

            // Indicator Dots & Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Indicator dots
                Row(
                  children: List.generate(
                    _slides.length,
                    (index) => Container(
                      width: _currentIndex == index ? 24.w : 8.w,
                      height: 8.h,
                      margin: EdgeInsets.only(right: 6.w),
                      decoration: BoxDecoration(
                        color: _currentIndex == index ? AppColors.primaryColor : AppColors.grey.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                ),
                
                // Next/Get Started Button
                SizedBox(
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentIndex < _slides.length - 1) {
                        _pageCtrl.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
                      } else {
                        _onFinishOnboarding();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26.r)),
                    ),
                    child: Text(
                      _currentIndex == _slides.length - 1 ? "Get Started" : "Next",
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
