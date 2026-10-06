import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../models/project_public_view_model.dart';
import 'locked_documents_card.dart';
import 'project_document_card.dart';

class DocumentsTabContent extends StatelessWidget {
  final ProjectPublicViewModel project;
  final bool isInvestor;
  final bool isRefreshingDocs;
  final VoidCallback? onSignNda;
  final VoidCallback? onRefresh;

  const DocumentsTabContent({
    super.key,
    required this.project,
    this.isInvestor = false,
    this.isRefreshingDocs = false,
    this.onSignNda,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final isLocked = isInvestor && !project.isNdaSigned;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: AppDimens.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Documents",
                style: GoogleFonts.outfit(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: tc.textPrimary,
                ),
              ),
              Row(
                children: [
                  if (!isLocked && project.documents.isNotEmpty) ...[
                    Text(
                      "${project.documents.length} File${project.documents.length > 1 ? 's' : ''}",
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        color: tc.textSecondary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                  if (onRefresh != null)
                    InkWell(
                      onTap: onRefresh,
                      borderRadius: BorderRadius.circular(12.r),
                      child: Padding(
                        padding: EdgeInsets.all(4.r),
                        child: Icon(
                          Icons.refresh_rounded,
                          size: 18.r,
                          color: tc.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppDimens.spaceMd),

          if (isRefreshingDocs) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppDimens.paddingXl),
              decoration: BoxDecoration(
                color: tc.cardBg,
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                border: Border.all(
                  color: tc.borderColor,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(height: AppDimens.spaceMd),
                  Text(
                    "Unlocking confidential documents...",
                    style: GoogleFonts.outfit(
                      fontSize: 13.sp,
                      color: tc.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isLocked) ...[
            LockedDocumentsCard(
              isTerminated: project.stage.toLowerCase().contains('terminated'),
              onSignNda: onSignNda,
            ),
          ] else if (project.documents.isEmpty) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppDimens.paddingXl),
              decoration: BoxDecoration(
                color: tc.cardBg,
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                border: Border.all(
                  color: tc.borderColor,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.folder_open_rounded,
                    size: 40.r,
                    color: tc.textTertiary,
                  ),
                  SizedBox(height: AppDimens.spaceMd),
                  Text(
                    "No Documents Uploaded",
                    style: GoogleFonts.outfit(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: tc.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "The sponsor has not uploaded any documents for this project yet.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      color: tc.textSecondary,
                    ),
                  ),
                  if (onRefresh != null) ...[
                    SizedBox(height: AppDimens.spaceMd),
                    InkWell(
                      onTap: onRefresh,
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: tc.cardInner,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: tc.borderColor,
                            width: AppDimens.borderThin,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.refresh_rounded,
                              size: 14.r,
                              color: tc.textPrimary,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              "Refresh",
                              style: GoogleFonts.outfit(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: tc.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: project.documents.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: AppDimens.spaceMd),
              itemBuilder: (context, index) {
                return ProjectDocumentCard(
                  document: project.documents[index],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
