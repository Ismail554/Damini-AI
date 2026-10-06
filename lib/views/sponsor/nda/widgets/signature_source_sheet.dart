import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';

class SignatureSourceSheet {
  static Future<ImageSource?> show(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final isDark = tc.isDark;

    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(AppDimens.screenHorizontal),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F2238) : Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimens.radiusXl),
            ),
            border: Border(
              top: BorderSide(
                color: tc.borderColor,
                width: AppDimens.borderThin,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: AppDimens.spaceMd),
                  decoration: BoxDecoration(
                    color: tc.textTertiary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                Text(
                  "Upload Signature",
                  style: GoogleFonts.outfit(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: tc.textPrimary,
                  ),
                ),
                SizedBox(height: AppDimens.spaceLg),
                ListTile(
                  leading: Icon(
                    Icons.photo_library_outlined,
                    color: tc.textPrimary,
                  ),
                  title: Text(
                    "Choose Image from Gallery",
                    style: GoogleFonts.outfit(
                      color: tc.textPrimary,
                      fontSize: 14.sp,
                    ),
                  ),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
                ListTile(
                  leading: Icon(
                    Icons.camera_alt_outlined,
                    color: tc.textPrimary,
                  ),
                  title: Text(
                    "Take Photo with Camera",
                    style: GoogleFonts.outfit(
                      color: tc.textPrimary,
                      fontSize: 14.sp,
                    ),
                  ),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
