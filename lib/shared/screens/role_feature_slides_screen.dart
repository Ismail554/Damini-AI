import 'package:Braintech/core/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/app_colors.dart';

class OnboardingSlideData {
  final String title;
  final String description;
  final IconData icon;

  const OnboardingSlideData({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class RoleFeatureSlidesScreen extends StatefulWidget {
  final String role;
  final VoidCallback onCompleted;
  final VoidCallback? onBack;

  const RoleFeatureSlidesScreen({
    super.key,
    required this.role,
    required this.onCompleted,
    this.onBack,
  });

  @override
  State<RoleFeatureSlidesScreen> createState() =>
      _RoleFeatureSlidesScreenState();
}

class _RoleFeatureSlidesScreenState extends State<RoleFeatureSlidesScreen> {
  final PageController _pageCtrl = PageController();
  int _currentIndex = 0;

  late final List<OnboardingSlideData> _slides;

  @override
  void initState() {
    super.initState();
    final isSponsor = widget.role == 'sponsor';
    _slides = isSponsor
        ? const [
            OnboardingSlideData(
              title: "Publish your project",
              description:
                  "Build a rich project page in minutes cover image, financials, team, documents and a confidential data room.",
              icon: Icons.rocket_launch_rounded,
            ),
            OnboardingSlideData(
              title: "Reach qualified investors",
              description:
                  "Your project is distributed only to verified investors that match your industry, ticket size and region.",
              icon: Icons.groups_rounded,
            ),
            OnboardingSlideData(
              title: "Review & approve proposals",
              description:
                  "Every collaboration request lands in one inbox. Approve, reject or open a secure chat with one tap.",
              icon: Icons.mark_email_read_rounded,
            ),
          ]
        : const [
            OnboardingSlideData(
              title: "Discover vetted projects",
              description:
                  "Explore curated, high-yield opportunities backable by institutional and private backers.",
              icon: Icons.explore_rounded,
            ),
            OnboardingSlideData(
              title: "Direct sponsor connection",
              description:
                  "Connect directly with verified project founders, schedule meetings and negotiate terms.",
              icon: Icons.handshake_rounded,
            ),
            OnboardingSlideData(
              title: "Manage investments",
              description:
                  "Track portfolio performance, access confidential data rooms and bookmark top deals.",
              icon: Icons.space_dashboard_rounded,
            ),
          ];
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < _slides.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Navigation Bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: widget.onBack,
                child: Text(
                  "Back",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              TextButton(
                onPressed: widget.onCompleted,
                child: Text(
                  "Skip",
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Slide Content
        Expanded(
          child: PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (idx) => setState(() => _currentIndex = idx),
            itemCount: _slides.length,
            itemBuilder: (context, idx) {
              final slide = _slides[idx];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 12.h),
                    // Image Banner Card with Play Button
                    Container(
                      width: double.infinity,
                      height: 280.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F2238),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            slide.icon,
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.2,
                            ),
                            size: 120.r,
                          ),
                          Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.black,
                              size: 32.r,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        slide.title,
                        style: GoogleFonts.outfit(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    AppSpacing.h12,
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        slide.description,
                        style: GoogleFonts.outfit(
                          fontSize: 14.sp,
                          color: Colors.white.withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (idx) {
            final isSelected = idx == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              width: isSelected ? 24.w : 8.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2.r),
              ),
            );
          }),
        ),
        SizedBox(height: 24.h),

        // Continue Button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentIndex == _slides.length - 1
                        ? "Get Started"
                        : "Continue",
                    style: GoogleFonts.outfit(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_currentIndex == _slides.length - 1) ...[
                    SizedBox(width: 8.w),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
