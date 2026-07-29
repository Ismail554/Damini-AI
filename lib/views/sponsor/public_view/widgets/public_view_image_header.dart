import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';

class PublicViewImageHeader extends StatefulWidget {
  final List<String>? imageUrls;
  final bool isBookmarked;
  final VoidCallback? onBookmarkTap;

  const PublicViewImageHeader({
    super.key,
    this.imageUrls,
    this.isBookmarked = false,
    this.onBookmarkTap,
  });

  @override
  State<PublicViewImageHeader> createState() => _PublicViewImageHeaderState();
}

class _PublicViewImageHeaderState extends State<PublicViewImageHeader> {
  int _currentIndex = 0;

  static const String _defaultImage =
      "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=600&auto=format&fit=crop";

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final list = (widget.imageUrls != null && widget.imageUrls!.isNotEmpty)
        ? widget.imageUrls!
        : [_defaultImage];

    final totalCount = list.length;
    final displayIndex = (_currentIndex < totalCount) ? _currentIndex + 1 : 1;

    final topPadding = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image PageView Carousel
          PageView.builder(
            itemCount: totalCount,
            onPageChanged: (idx) => setState(() => _currentIndex = idx),
            itemBuilder: (context, index) {
              return Image.network(
                list[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: tc.cardInner,
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: tc.textTertiary,
                      size: AppDimens.iconLg,
                    ),
                  ),
                ),
              );
            },
          ),

          // Gradient scrim overlay for icon clarity
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.30, 0.70, 1.0],
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.40),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating Back Button (Top Left)
          Positioned(
            top: topPadding + 12.h,
            left: AppDimens.screenHorizontal,
            child: _buildGlassIconButton(
              tc: tc,
              icon: Icons.arrow_back_rounded,
              onTap: () => context.pop(),
            ),
          ),

          // Floating Save / Bookmark Button (Top Right)
          Positioned(
            top: topPadding + 12.h,
            right: AppDimens.screenHorizontal,
            child: _buildGlassIconButton(
              tc: tc,
              icon: widget.isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              iconColor: widget.isBookmarked
                  ? AppColors.accentRed
                  : Colors.white,
              onTap: widget.onBookmarkTap ?? () {},
            ),
          ),

          // Image Index Badge (Bottom Right edge above sheet)
          Positioned(
            bottom: 32.h,
            right: AppDimens.screenHorizontal,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                "$displayIndex / $totalCount",
                style: GoogleFonts.outfit(
                  fontSize: 11.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassIconButton({
    required AppThemeColors tc,
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 38.w,
            height: 38.h,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: AppDimens.borderThin,
              ),
            ),
            child: Icon(icon, color: iconColor, size: AppDimens.iconSm + 2.sp),
          ),
        ),
      ),
    );
  }
}
