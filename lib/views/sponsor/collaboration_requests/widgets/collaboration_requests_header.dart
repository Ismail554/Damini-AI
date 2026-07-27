import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import 'collaboration_tab_bar.dart';

class CollaborationRequestsHeader extends StatelessWidget {
  final int selectedTabIndex;
  final ValueChanged<int> onTabSelected;

  const CollaborationRequestsHeader({
    super.key,
    required this.selectedTabIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.screenHorizontal,
        vertical: AppDimens.screenVertical,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: tc.buttonSecondary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: tc.borderColor,
                          width: AppDimens.borderThin,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: tc.textPrimary,
                        size: AppDimens.iconMd,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppDimens.spaceMd),
              Text(
                "Collaboration Requests",
                style: GoogleFonts.outfit(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: tc.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimens.spaceLg),
          CollaborationTabBar(
            selectedIndex: selectedTabIndex,
            onTabSelected: onTabSelected,
          ),
        ],
      ),
    );
  }
}
