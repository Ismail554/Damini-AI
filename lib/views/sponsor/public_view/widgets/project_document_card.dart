import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/utils/external_link_launcher.dart';
import '../../../../core/utils/file_downloader.dart';
import '../models/project_document_model.dart';

class ProjectDocumentCard extends StatefulWidget {
  final ProjectDocumentModel document;

  const ProjectDocumentCard({
    super.key,
    required this.document,
  });

  @override
  State<ProjectDocumentCard> createState() => _ProjectDocumentCardState();
}

class _ProjectDocumentCardState extends State<ProjectDocumentCard> {
  bool _isDownloading = false;

  Future<void> _handleDownload() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);

    await FileDownloader.downloadFile(
      context,
      url: widget.document.fileUrl,
      suggestedName: widget.document.title,
      extension: widget.document.fileExtension,
    );

    if (mounted) {
      setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final doc = widget.document;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimens.paddingMd),
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
          color: tc.borderColor,
          width: AppDimens.borderThin,
        ),
        boxShadow: [
          BoxShadow(
            color: tc.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: tc.cardInner,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(
                color: tc.borderColor,
                width: AppDimens.borderThin,
              ),
            ),
            child: Icon(
              doc.iconData,
              color: const Color(0xFF0066FF),
              size: 22.r,
            ),
          ),
          SizedBox(width: AppDimens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: tc.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: tc.cardInner,
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(
                          color: tc.borderColor,
                          width: AppDimens.borderThin,
                        ),
                      ),
                      child: Text(
                        doc.extensionBadge,
                        style: GoogleFonts.outfit(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: tc.textSecondary,
                        ),
                      ),
                    ),
                    if (doc.isConfidential) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7)
                              .withValues(alpha: tc.isDark ? 0.15 : 0.9),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_rounded,
                              size: 10.r,
                              color: const Color(0xFFD97706),
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              "Confidential",
                              style: GoogleFonts.outfit(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: AppDimens.spaceSm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Download Button
              InkWell(
                onTap: _handleDownload,
                borderRadius: BorderRadius.circular(18.r),
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: tc.cardInner,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: tc.borderColor,
                      width: AppDimens.borderThin,
                    ),
                  ),
                  child: _isDownloading
                      ? SizedBox(
                          width: 16.r,
                          height: 16.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Color(0xFF0066FF)),
                          ),
                        )
                      : Icon(
                          Icons.file_download_outlined,
                          size: 16.r,
                          color: const Color(0xFF0066FF),
                        ),
                ),
              ),
              SizedBox(width: 6.w),
              // View Button
              InkWell(
                onTap: () => ExternalLinkLauncher.openUrl(context, doc.fileUrl),
                borderRadius: BorderRadius.circular(18.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066FF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: const Color(0xFF0066FF).withValues(alpha: 0.3),
                      width: AppDimens.borderThin,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 14.r,
                        color: const Color(0xFF0066FF),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        "View",
                        style: GoogleFonts.outfit(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0066FF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
