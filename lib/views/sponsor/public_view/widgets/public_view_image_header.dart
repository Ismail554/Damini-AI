import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';

class PublicViewImageHeader extends StatefulWidget {
  final List<String>? imageUrls;

  const PublicViewImageHeader({
    super.key,
    this.imageUrls,
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

    return Stack(
      children: [
        // Image Carousel Header Banner
        SizedBox(
          height: 240.h,
          width: double.infinity,
          child: PageView.builder(
            itemCount: totalCount,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final url = list[index];
              return Image.network(
                url,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: tc.cardInner,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: tc.textTertiary,
                        size: 32.r,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Floating Back Button (Top Left)
        Positioned(
          top: 12.h,
          left: AppDimens.screenHorizontal,
          child: _buildGlassIconButton(
            tc: tc,
            icon: Icons.arrow_back_rounded,
            onTap: () => context.pop(),
          ),
        ),

        // Floating Save / Bookmark Button (Top Right)
        Positioned(
          top: 12.h,
          right: AppDimens.screenHorizontal,
          child: _buildGlassIconButton(
            tc: tc,
            icon: Icons.bookmark_border_rounded,
            onTap: () {},
          ),
        ),

        // Image Index Badge (Bottom Right)
        Positioned(
          bottom: 16.h,
          right: AppDimens.screenHorizontal,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
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
    );
  }

  Widget _buildGlassIconButton({
    required AppThemeColors tc,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: AppDimens.borderThin,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: AppDimens.iconSm + 2,
            ),
          ),
        ),
      ),
    );
  }
}
