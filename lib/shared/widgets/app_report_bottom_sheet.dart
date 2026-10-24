import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/app_theme_colors.dart';
import '../../core/widgets/custom_snackbar.dart';
import '../../data/repositories/report_repository.dart';

class AppReportBottomSheet extends ConsumerStatefulWidget {
  final String title;
  final int? reportedProjectId;
  final int? reportedUserId;
  final int? reportedMessageId;

  const AppReportBottomSheet({
    super.key,
    this.title = 'Report Content',
    this.reportedProjectId,
    this.reportedUserId,
    this.reportedMessageId,
  });

  static Future<bool?> show(
    BuildContext context, {
    String title = 'Report Content',
    int? reportedProjectId,
    int? reportedUserId,
    int? reportedMessageId,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AppReportBottomSheet(
        title: title,
        reportedProjectId: reportedProjectId,
        reportedUserId: reportedUserId,
        reportedMessageId: reportedMessageId,
      ),
    );
  }

  @override
  ConsumerState<AppReportBottomSheet> createState() =>
      _AppReportBottomSheetState();
}

class _AppReportBottomSheetState extends ConsumerState<AppReportBottomSheet> {
  static const List<Map<String, String>> _reasons = [
    {'key': 'SPAM', 'label': 'Spam or Commercial Solicitation'},
    {'key': 'INAPPROPRIATE', 'label': 'Inappropriate or Offensive Content'},
    {'key': 'HARASSMENT', 'label': 'Harassment or Bullying'},
    {'key': 'FRAUD', 'label': 'Suspected Fraud or Misrepresentation'},
    {'key': 'COPYRIGHT', 'label': 'Intellectual Property Violation'},
    {'key': 'OTHER', 'label': 'Other Policy Violation'},
  ];

  String _selectedReason = 'SPAM';
  final _detailsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(reportRepositoryProvider);
      final ok = await repo.submitReport(
        reportedProjectId: widget.reportedProjectId,
        reportedUserId: widget.reportedUserId,
        reportedMessageId: widget.reportedMessageId,
        reason: _selectedReason,
        details: _detailsController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(ok);
        if (ok) {
          CustomSnackBar.success(
            context,
            'Thank you for your report. Our moderation team reviews all reports within 24 hours.',
          );
        } else {
          CustomSnackBar.error(
            context,
            'Failed to submit report. Please try again.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        CustomSnackBar.error(
          context,
          'Unable to submit report right now. Please try again later.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 16.h,
        bottom: bottomInset > 0 ? bottomInset + 16.h : 24.h,
      ),
      decoration: BoxDecoration(
        color: tc.isDark ? const Color(0xFF0F1E2E) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        border: Border.all(
          color: tc.isDark ? Colors.white12 : Colors.black12,
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: tc.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(
                  Icons.flag_outlined,
                  color: const Color(0xFFEF4444),
                  size: 22.r,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    widget.title,
                    style: GoogleFonts.outfit(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: tc.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: Icon(
                    Icons.close,
                    color: tc.textSecondary,
                    size: 20.r,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              'Select a reason for reporting:',
              style: GoogleFonts.outfit(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: tc.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: tc.isDark ? const Color(0xFF16253C) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: tc.isDark ? Colors.white12 : Colors.black12,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedReason,
                  isExpanded: true,
                  dropdownColor:
                      tc.isDark ? const Color(0xFF16253C) : Colors.white,
                  style: GoogleFonts.outfit(
                    color: tc.textPrimary,
                    fontSize: 14.sp,
                  ),
                  items: _reasons.map((r) {
                    return DropdownMenuItem<String>(
                      value: r['key'],
                      child: Text(
                        r['label'] ?? '',
                        style: GoogleFonts.outfit(
                          color: tc.textPrimary,
                          fontSize: 13.sp,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedReason = val);
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Additional Details (optional):',
              style: GoogleFonts.outfit(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: tc.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _detailsController,
              maxLines: 3,
              style: GoogleFonts.outfit(
                color: tc.textPrimary,
                fontSize: 13.sp,
              ),
              decoration: InputDecoration(
                hintText: 'Please provide details about the violation...',
                hintStyle: GoogleFonts.outfit(
                  color: tc.textTertiary,
                  fontSize: 12.sp,
                ),
                filled: true,
                fillColor:
                    tc.isDark ? const Color(0xFF16253C) : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: tc.isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: tc.isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.primaryColor),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Submit Report',
                        style: GoogleFonts.outfit(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
