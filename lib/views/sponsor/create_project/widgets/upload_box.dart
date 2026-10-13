import 'dart:io';
import 'package:Braintech/core/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';

class UploadBox extends StatelessWidget {
  final String label;
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final String? selectedFilePath;
  final String? selectedFileName;
  final VoidCallback? onRemove;

  const UploadBox({
    super.key,
    required this.label,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTap,
    this.selectedFilePath,
    this.selectedFileName,
    this.onRemove,
  });

  bool get _hasFile =>
      (selectedFilePath != null && selectedFilePath!.isNotEmpty) ||
      (selectedFileName != null && selectedFileName!.isNotEmpty);

  bool get _isImage {
    if (selectedFilePath == null) return false;
    final lower = selectedFilePath!.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.heic') ||
        lower.startsWith('assets/');
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: tc.textPrimary,
          ),
        ),
        SizedBox(height: AppDimens.spaceSm),
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: double.infinity,
            padding: _hasFile
                ? EdgeInsets.all(12.r)
                : EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: tc.cardInner,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(
                color: _hasFile ? const Color(0xFF006EDB) : tc.borderColor,
                width: _hasFile ? 1.5 : 1.2,
              ),
            ),
            child: _hasFile ? _buildPreview(context, tc) : _buildEmptyState(tc),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppThemeColors tc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: tc.cardBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: tc.borderColor,
              width: AppDimens.borderThin,
            ),
          ),
          child: Icon(icon, color: tc.textSecondary, size: 24.sp),
        ),
        AppSpacing.h10,
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: tc.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          AppSpacing.h4,
          Text(
            subtitle!,
            style: GoogleFonts.outfit(fontSize: 11.sp, color: tc.textTertiary),
          ),
        ],
      ],
    );
  }

  Widget _buildPreview(BuildContext context, AppThemeColors tc) {
    final path = selectedFilePath ?? '';
    final isAsset = path.startsWith('assets/');
    final file = File(path);
    final fileName =
        selectedFileName ??
        (path.isNotEmpty ? path.split('/').last : 'Uploaded File');

    if (_isImage) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: SizedBox(
              height: 140.h,
              width: double.infinity,
              child: isAsset
                  ? Image.asset(path, fit: BoxFit.cover)
                  : (file.existsSync()
                        ? Image.file(file, fit: BoxFit.cover)
                        : Container(
                            color: Colors.black26,
                            child: Icon(
                              Icons.image,
                              color: Colors.white,
                              size: 40.sp,
                            ),
                          )),
            ),
          ),
          Positioned(
            top: 8.h,
            right: 8.w,
            child: Row(
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: const BoxDecoration(
                      color: Color(0xCC000000),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                ),
                if (onRemove != null) ...[
                  AppSpacing.w8,
                  GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: const BoxDecoration(
                        color: Color(0xCCEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    // Document file preview
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: const Color(0xFF006EDB).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.insert_drive_file_rounded,
            color: const Color(0xFF006EDB),
            size: 24.sp,
          ),
        ),
        AppSpacing.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: tc.textPrimary,
                ),
              ),
              AppSpacing.h2,
              Text(
                "Tap box to replace file",
                style: GoogleFonts.outfit(
                  fontSize: 11.sp,
                  color: tc.textTertiary,
                ),
              ),
            ],
          ),
        ),
        if (onRemove != null)
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
              size: 20.sp,
            ),
            onPressed: onRemove,
          ),
      ],
    );
  }
}
