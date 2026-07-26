import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';

class NdaDocumentAttachmentCard extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final VoidCallback onDownload;

  const NdaDocumentAttachmentCard({
    super.key,
    this.fileName = "NDA Overview.pdf",
    this.fileSize = "2.1MB · Public",
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Container(
      padding: EdgeInsets.all(AppDimens.paddingMd),
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.25),
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: Icon(
              Icons.description_outlined,
              color: AppColors.primaryColor,
              size: 22.r,
            ),
          ),
          SizedBox(width: AppDimens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: tc.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  fileSize,
                  style: GoogleFonts.outfit(
                    fontSize: 11.sp,
                    color: tc.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: AppColors.primaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            child: InkWell(
              onTap: onDownload,
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              child: Padding(
                padding: EdgeInsets.all(8.r),
                child: Icon(
                  Icons.file_download_outlined,
                  color: AppColors.primaryColor,
                  size: 18.r,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
