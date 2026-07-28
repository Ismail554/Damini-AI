import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../models/subscription_feature_model.dart';

class SubscriptionFeatureTable extends StatelessWidget {
  final List<SubscriptionFeatureModel> features;

  const SubscriptionFeatureTable({
    super.key,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: tc.isDark ? const Color(0xFF091E36) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: tc.isDark
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Features",
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    color: tc.textTertiary,
                  ),
                ),
              ),
              SizedBox(
                width: 50.w,
                child: Text(
                  "Free",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    color: tc.textTertiary,
                  ),
                ),
              ),
              SizedBox(
                width: 50.w,
                child: Text(
                  "Pro",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...features.map((feature) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      feature.title,
                      style: GoogleFonts.outfit(
                        fontSize: 14.sp,
                        color: tc.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 50.w,
                    child: Center(
                      child: feature.isFree
                          ? Icon(
                              Icons.check_rounded,
                              color: tc.textPrimary,
                              size: 18.r,
                            )
                          : Text(
                              "—",
                              style: GoogleFonts.outfit(
                                fontSize: 14.sp,
                                color: tc.textTertiary,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(
                    width: 50.w,
                    child: Center(
                      child: feature.isPro
                          ? const Icon(
                              Icons.check_rounded,
                              color: Color(0xFF2563EB),
                              size: 18,
                            )
                          : Text(
                              "—",
                              style: GoogleFonts.outfit(
                                fontSize: 14.sp,
                                color: tc.textTertiary,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
