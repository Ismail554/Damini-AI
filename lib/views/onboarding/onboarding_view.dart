import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/app_theme_colors.dart';
import '../../core/utils/asset_manager.dart';
import '../../core/widgets/common_background.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageCtrl = PageController();
  int _currentIndex = 0;
  VideoPlayerController? _videoCtrl;
  bool _isVideoInitialized = false;

  final List<Map<String, String>> _slides = [
    {
      "title": "Find real opportunities",
      "desc": "Browse vetted business projects from sponsors around the world curated by industry, region, and stage.",
      "image": ImageAssets.onboarding1,
      "video": VideoAssets.onboarding1,
    },
    {
      "title": "Talk securely",
      "desc": "Verified profiles, NDA-protected confidential details, and in-app encrypted messaging keep every deal private.",
      "image": ImageAssets.onboarding2,
    },
    {
      "title": "Publish & collaborate",
      "desc": "Sponsors publish projects, investors send proposals no payments handled in-app, just qualified introductions.",
      "image": ImageAssets.onboarding3,
    }
  ];

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _videoListener() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initVideo() async {
    try {
      _videoCtrl = VideoPlayerController.asset(VideoAssets.onboarding1);
      _videoCtrl!.addListener(_videoListener);
      await _videoCtrl!.initialize();
      await _videoCtrl!.setLooping(true);
      await _videoCtrl!.setVolume(1.0);
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
        await _videoCtrl!.play();
      }
    } catch (e, st) {
      debugPrint("Video initialization failed: $e\n$st");
    }
  }

  @override
  void dispose() {
    _videoCtrl?.removeListener(_videoListener);
    _videoCtrl?.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _onFinishOnboarding() async {
    await StorageService.saveHasSeenOnboarding();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    return CommonBackground(
      showGrid: false,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            children: [
              // Top Action Header (Back & Skip)
              _buildHeader(colors),
              
              // Carousel content
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  itemCount: _slides.length,
                  onPageChanged: (idx) {
                    setState(() => _currentIndex = idx);
                    if (_isVideoInitialized && _videoCtrl != null) {
                      if (_slides[idx].containsKey("video")) {
                        _videoCtrl!.play();
                      } else {
                        _videoCtrl!.pause();
                      }
                    }
                  },
                  itemBuilder: (context, idx) {
                    final slide = _slides[idx];
                    final hasVideo = slide.containsKey("video");

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),
                        
                        // Video / Image Preview Card
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24.r),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.shadowColor,
                                  blurRadius: 15.r,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24.r),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (hasVideo &&
                                      _videoCtrl != null &&
                                      _videoCtrl!.value.isInitialized)
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (_videoCtrl!.value.isPlaying) {
                                            _videoCtrl!.pause();
                                          } else {
                                            _videoCtrl!.play();
                                          }
                                        });
                                      },
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          SizedBox.expand(
                                            child: FittedBox(
                                              fit: BoxFit.cover,
                                              clipBehavior: Clip.hardEdge,
                                              child: SizedBox(
                                                width: _videoCtrl!.value.size.width > 0
                                                    ? _videoCtrl!.value.size.width
                                                    : 16,
                                                height: _videoCtrl!.value.size.height > 0
                                                    ? _videoCtrl!.value.size.height
                                                    : 9,
                                                child: VideoPlayer(_videoCtrl!),
                                              ),
                                            ),
                                          ),
                                          // Animated play overlay button when paused
                                          if (!_videoCtrl!.value.isPlaying)
                                            Center(
                                              child: Container(
                                                width: 60.r,
                                                height: 60.r,
                                                decoration: BoxDecoration(
                                                  color: colors.cardBg.withValues(alpha: 0.85),
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: colors.shadowColor,
                                                      blurRadius: 10,
                                                      offset: const Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(
                                                  Icons.play_arrow_rounded,
                                                  color: colors.textPrimary,
                                                  size: 40.r,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    )
                                  else
                                    Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.asset(
                                          slide["image"]!,
                                          fit: BoxFit.cover,
                                        ),
                                        if (hasVideo && !_isVideoInitialized)
                                          Center(
                                            child: Container(
                                              width: 50.r,
                                              height: 50.r,
                                              decoration: BoxDecoration(
                                                color: colors.cardBg.withValues(alpha: 0.8),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Center(
                                                child: SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2.5,
                                                    color: AppColors.primaryColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),
                        
                        // Slide details
                        Text(
                          slide["title"]!,
                          style: GoogleFonts.outfit(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          slide["desc"]!,
                          style: GoogleFonts.outfit(
                            fontSize: 14.sp,
                            color: colors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 24.h),
                      ],
                    );
                  },
                ),
              ),
              
              // Indicator dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => Container(
                    width: _currentIndex == index ? 20.w : 6.w,
                    height: 6.h,
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    decoration: BoxDecoration(
                      color: _currentIndex == index ? AppColors.primaryColor : colors.textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              
              // Continue / Get Started action CTA
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentIndex < _slides.length - 1) {
                      _pageCtrl.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _onFinishOnboarding();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                  ),
                  child: Text(
                    _currentIndex == _slides.length - 1 ? "Get Started →" : "Continue",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppThemeColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentIndex > 0)
          GestureDetector(
            onTap: () {
              _pageCtrl.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Text(
              "Back",
              style: GoogleFonts.outfit(
                color: colors.textSecondary,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          const SizedBox.shrink(),
        if (_currentIndex < _slides.length - 1)
          GestureDetector(
            onTap: _onFinishOnboarding,
            child: Text(
              "Skip",
              style: GoogleFonts.outfit(
                color: colors.textSecondary,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }
}
