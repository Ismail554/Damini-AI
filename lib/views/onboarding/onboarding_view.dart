import 'package:Braintech/core/utils/app_spacing.dart';
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

class _OnboardingViewState extends State<OnboardingView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final PageController _pageCtrl = PageController();
  int _currentIndex = 0;
  VideoPlayerController? _videoCtrl;
  bool _isVideoInitialized = false;
  bool _wasPlayingBeforePause = false;
  bool _isMuted = false;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  final List<Map<String, String>> _slides = [
    {
      "title": "Find real opportunities",
      "desc":
          "Browse vetted business projects from sponsors around the world curated by industry, region, and stage.",
      "image": ImageAssets.onboarding1,
    },
    {
      "title": "Talk securely",
      "desc":
          "Verified profiles, NDA-protected confidential details, and in-app encrypted messaging keep every deal private.",
      "image": ImageAssets.onboarding2,
    },
    {
      "title": "Publish & collaborate",
      "desc":
          "Sponsors publish projects, investors send proposals no payments handled in-app, just qualified introductions.",
      "image": ImageAssets.onboarding3,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initVideo();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
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
      await _videoCtrl!.setVolume(_isMuted ? 0.0 : 1.0);
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_videoCtrl == null || !_videoCtrl!.value.isInitialized) return;

    switch (state) {
      case AppLifecycleState.resumed:
        // App back in foreground and screen is ON -> resume if it was playing
        if (_wasPlayingBeforePause && mounted) {
          _videoCtrl!.play();
          _wasPlayingBeforePause = false;
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        // Screen turned off, locked, or app minimized -> pause video & stop sound
        if (_videoCtrl!.value.isPlaying) {
          _wasPlayingBeforePause = true;
          _videoCtrl!.pause();
        }
        break;
    }
  }

  @override
  void deactivate() {
    // Stop sound and video immediately when navigating away
    _videoCtrl?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoCtrl?.pause();
    _videoCtrl?.removeListener(_videoListener);
    _videoCtrl?.dispose();
    _pageCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggleMute() {
    if (_videoCtrl == null || !_videoCtrl!.value.isInitialized) return;
    setState(() {
      _isMuted = !_isMuted;
      _videoCtrl!.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _onPageChanged(int idx) {
    setState(() => _currentIndex = idx);
    _animCtrl.reset();
    _animCtrl.forward();
  }

  Future<void> _onFinishOnboarding() async {
    if (_videoCtrl != null && _videoCtrl!.value.isPlaying) {
      await _videoCtrl!.pause();
    }
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
      topSafeArea: true,
      bottomSafeArea: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Column(
          children: [
            // Top Action Header (Back & Skip)
            _buildHeader(colors),

            SizedBox(height: 12.h),

            // Persistent Video Card — sized flexibly with Expanded
            Expanded(
              flex: 11,
              child: Hero(
                tag: 'onboarding_media',
                child: _buildVideoCard(colors),
              ),
            ),

            Spacer(),
            AppSpacing.h10,

            // Swipeable text content (title + desc per page)
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _slides.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, idx) {
                  final slide = _slides[idx];
                  if (idx == _currentIndex) {
                    return FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: _buildSlideText(slide, colors),
                      ),
                    );
                  }
                  return _buildSlideText(slide, colors);
                },
              ),
            ),

            SizedBox(height: 8.h),

            // Indicator dots
            _buildDots(colors),

            SizedBox(height: 18.h),

            // Continue / Get Started action CTA
            _buildActionButton(colors),

            SizedBox(height: 6.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppThemeColors colors) {
    return SizedBox(
      height: 40.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedOpacity(
            opacity: _currentIndex > 0 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _currentIndex > 0
                    ? () {
                        _pageCtrl.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: colors.cardBg.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: colors.borderColor.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 13.sp,
                        color: colors.textPrimary,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        "Back",
                        style: GoogleFonts.outfit(
                          color: colors.textPrimary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: _currentIndex < _slides.length - 1 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _currentIndex < _slides.length - 1
                    ? _onFinishOnboarding
                    : null,
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: colors.cardBg.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: colors.borderColor.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    "Skip",
                    style: GoogleFonts.outfit(
                      color: colors.textSecondary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(AppThemeColors colors) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: colors.borderColor.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor.withValues(alpha: 0.2),
            blurRadius: 18.r,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! < -100 &&
                  _currentIndex < _slides.length - 1) {
                _pageCtrl.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else if (details.primaryVelocity! > 100 && _currentIndex > 0) {
                _pageCtrl.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Fallback poster image
              Image.asset(
                _slides[_currentIndex]["image"] ?? ImageAssets.onboarding1,
                fit: BoxFit.cover,
              ),

              // Video layer
              if (_isVideoInitialized &&
                  _videoCtrl != null &&
                  _videoCtrl!.value.isInitialized)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
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

                      // Subtle gradient overlay at bottom of video
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 50.h,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.3),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Mute / Unmute quick toggle button
                      Positioned(
                        top: 12.h,
                        right: 12.w,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _toggleMute,
                          child: Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              _isMuted
                                  ? Icons.volume_off_rounded
                                  : Icons.volume_up_rounded,
                              color: Colors.white,
                              size: 18.r,
                            ),
                          ),
                        ),
                      ),

                      // Animated play overlay button when paused
                      if (!_videoCtrl!.value.isPlaying)
                        Center(
                          child: Container(
                            width: 56.r,
                            height: 56.r,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 36.r,
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              else if (!_isVideoInitialized)
                Center(
                  child: Container(
                    width: 50.r,
                    height: 50.r,
                    decoration: BoxDecoration(
                      color: colors.cardBg.withValues(alpha: 0.85),
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
        ),
      ),
    );
  }

  Widget _buildSlideText(Map<String, String> slide, AppThemeColors colors) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            slide["title"]!,
            style: GoogleFonts.outfit(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            slide["desc"]!,
            style: GoogleFonts.outfit(
              fontSize: 14.sp,
              color: colors.isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF475569),
              fontWeight: FontWeight.w400,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDots(AppThemeColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _slides.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: _currentIndex == index ? 24.w : 7.w,
          height: 6.h,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: _currentIndex == index
                ? AppColors.primaryColor
                : colors.textSecondary.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(3.r),
            boxShadow: _currentIndex == index
                ? [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(AppThemeColors colors) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
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
          elevation: 4,
          shadowColor: AppColors.primaryColor.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                _currentIndex == _slides.length - 1
                    ? "Get Started"
                    : "Continue",
                key: ValueKey(_currentIndex == _slides.length - 1),
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.arrow_forward_rounded, size: 18.sp, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
