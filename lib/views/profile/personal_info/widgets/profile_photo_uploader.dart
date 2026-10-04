import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/widgets/profile_photo_adjust_dialog.dart';

class ProfilePhotoUploader extends StatelessWidget {
  final File? imageFile;
  final String? networkImageUrl;
  final ValueChanged<File?> onImageChanged;

  const ProfilePhotoUploader({
    super.key,
    required this.imageFile,
    this.networkImageUrl,
    required this.onImageChanged,
  });

  Future<void> _pickAndAdjust(BuildContext context, ImageSource source) async {
    Navigator.pop(context);
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 92,
      );
      if (picked != null && context.mounted) {
        final adjusted = await ProfilePhotoAdjustDialog.show(
          context,
          File(picked.path),
        );
        if (adjusted != null) {
          onImageChanged(adjusted);
        }
      }
    } catch (_) {}
  }

  Future<void> _reAdjust(BuildContext context) async {
    Navigator.pop(context);
    if (imageFile == null) return;
    final adjusted = await ProfilePhotoAdjustDialog.show(context, imageFile!);
    if (adjusted != null) {
      onImageChanged(adjusted);
    }
  }

  void _showPickerModal(BuildContext context) {
    final tc = AppThemeColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: tc.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: tc.borderColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Profile Photo',
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: tc.textPrimary,
                ),
              ),
              SizedBox(height: 14.h),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt_rounded,
                      color: AppColors.primaryColor, size: 20.r),
                ),
                title: Text(
                  'Take Photo',
                  style: GoogleFonts.outfit(
                    color: tc.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => _pickAndAdjust(context, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.photo_library_rounded,
                      color: AppColors.primaryColor, size: 20.r),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: GoogleFonts.outfit(
                    color: tc.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => _pickAndAdjust(context, ImageSource.gallery),
              ),
              if (imageFile != null) ...[
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: tc.borderColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.crop_rotate_rounded,
                        color: tc.textPrimary, size: 20.r),
                  ),
                  title: Text(
                    'Re-adjust / Crop Photo',
                    style: GoogleFonts.outfit(
                      color: tc.textPrimary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () => _reAdjust(context),
                ),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.delete_outline_rounded,
                        color: AppColors.error, size: 20.r),
                  ),
                  title: Text(
                    'Remove Photo',
                    style: GoogleFonts.outfit(
                      color: AppColors.error,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    onImageChanged(null);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final hasLocalImage = imageFile != null;
    final hasNetworkImage =
        networkImageUrl != null && networkImageUrl!.trim().isNotEmpty;
    final hasImage = hasLocalImage || hasNetworkImage;

    return GestureDetector(
      onTap: () => _showPickerModal(context),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 92.r,
                height: 92.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tc.cardBg,
                  border: Border.all(
                    color: hasImage
                        ? AppColors.primaryColor
                        : tc.borderColor.withValues(alpha: 0.35),
                    width: 2.w,
                  ),
                  boxShadow: hasImage
                      ? [
                          BoxShadow(
                            color: AppColors.primaryColor.withValues(alpha: 0.2),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                child: ClipOval(
                  child: hasLocalImage
                      ? Image.file(
                          imageFile!,
                          width: 92.r,
                          height: 92.r,
                          fit: BoxFit.cover,
                        )
                      : hasNetworkImage
                          ? Image.network(
                              networkImageUrl!,
                              width: 92.r,
                              height: 92.r,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  color: tc.textSecondary,
                                  size: 32.r,
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.camera_alt_outlined,
                                color: tc.textSecondary,
                                size: 32.r,
                              ),
                            ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(7.r),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: tc.cardBg,
                      width: 2.w,
                    ),
                  ),
                  child: Icon(
                    hasImage ? Icons.edit_rounded : Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 13.r,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            hasImage ? "Change Profile Photo" : "Upload Profile Photo",
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: hasImage ? AppColors.primaryColor : tc.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
