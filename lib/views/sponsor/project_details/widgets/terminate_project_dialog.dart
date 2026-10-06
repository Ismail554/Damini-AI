import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_theme_colors.dart';

class TerminateProjectDialog extends StatefulWidget {
  final String projectTitle;

  const TerminateProjectDialog({super.key, required this.projectTitle});

  static Future<String?> show(BuildContext context, {required String projectTitle}) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => TerminateProjectDialog(projectTitle: projectTitle),
    );
  }

  @override
  State<TerminateProjectDialog> createState() => _TerminateProjectDialogState();
}

class _TerminateProjectDialogState extends State<TerminateProjectDialog> {
  int _secondsRemaining = 5;
  Timer? _timer;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startTimer();
    _nameController.addListener(() => setState(() {}));
    _reasonController.addListener(() => setState(() {}));
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() => _secondsRemaining = 0);
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nameController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  bool get _isTitleMatched =>
      _nameController.text.trim().toLowerCase() == widget.projectTitle.trim().toLowerCase();
  bool get _isReasonValid => _reasonController.text.trim().length >= 10;
  bool get _canTerminate => _secondsRemaining == 0 && _isTitleMatched && _isReasonValid;

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      backgroundColor: tc.isDark ? tc.cardHero : Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(22.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.warning_amber_rounded, color: const Color(0xFFDC2626), size: 24.r),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text("Terminate Project?",
                      style: GoogleFonts.outfit(
                          fontSize: 19.sp, fontWeight: FontWeight.bold, color: tc.textPrimary)),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              "Terminating will close all collaboration requests and notify all participating investors. This action is permanent and cannot be undone.",
              style: GoogleFonts.outfit(fontSize: 13.sp, color: tc.textSecondary, height: 1.4),
            ),
            SizedBox(height: 14.h),
            _buildField(tc, _reasonController, "Reason for termination (min 10 chars)*",
                "Explain why the project is being terminated...", 3),
            SizedBox(height: 12.h),
            _buildField(tc, _nameController, "Type \"${widget.projectTitle}\" to confirm*",
                widget.projectTitle, 1),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 44.h),
                      side: BorderSide(color: tc.borderColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r)),
                    ),
                    child: Text("Cancel",
                        style: GoogleFonts.outfit(
                            fontSize: 14.sp, fontWeight: FontWeight.w600, color: tc.textPrimary)),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canTerminate
                        ? () => Navigator.of(context).pop(_reasonController.text.trim())
                        : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 44.h),
                      backgroundColor: const Color(0xFFDC2626),
                      disabledBackgroundColor: const Color(0xFFDC2626).withValues(alpha: 0.35),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r)),
                    ),
                    child: Text(
                      _secondsRemaining > 0 ? "Terminate (${_secondsRemaining}s)" : "Terminate",
                      style: GoogleFonts.outfit(
                          fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(AppThemeColors tc, TextEditingController ctrl, String label, String hint, int lines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 12.sp, fontWeight: FontWeight.w500, color: tc.textSecondary)),
        SizedBox(height: 6.h),
        TextField(
          controller: ctrl,
          maxLines: lines,
          style: GoogleFonts.outfit(fontSize: 13.sp, color: tc.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(fontSize: 13.sp, color: tc.textTertiary),
            filled: true,
            fillColor: tc.isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: tc.borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: tc.borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppColors.accentOrange)),
          ),
        ),
      ],
    );
  }
}
