import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme_colors.dart';

class ProfilePhotoAdjustDialog extends StatefulWidget {
  final File file;

  const ProfilePhotoAdjustDialog({super.key, required this.file});

  static Future<File?> show(BuildContext context, File file) {
    return showDialog<File?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ProfilePhotoAdjustDialog(file: file),
    );
  }

  @override
  State<ProfilePhotoAdjustDialog> createState() =>
      _ProfilePhotoAdjustDialogState();
}

class _ProfilePhotoAdjustDialogState extends State<ProfilePhotoAdjustDialog> {
  final GlobalKey _cropKey = GlobalKey();
  final TransformationController _transformCtrl = TransformationController();
  int _quarterTurns = 0;
  bool _isProcessing = false;

  void _rotate() {
    setState(() {
      _quarterTurns = (_quarterTurns + 1) % 4;
    });
  }

  void _reset() {
    setState(() {
      _quarterTurns = 0;
      _transformCtrl.value = Matrix4.identity();
    });
  }

  Future<void> _applyCrop() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final boundary = _cropKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        Navigator.pop(context, widget.file);
        return;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 2.5);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (!mounted) return;
      if (byteData == null) {
        Navigator.pop(context, widget.file);
        return;
      }

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final croppedFile = File(
        '${tempDir.path}/cropped_profile_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await croppedFile.writeAsBytes(pngBytes);

      if (mounted) {
        Navigator.pop(context, croppedFile);
      }
    } catch (_) {
      if (mounted) {
        Navigator.pop(context, widget.file);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final cropSize = 250.r;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      backgroundColor: tc.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: tc.borderColor.withValues(alpha: 0.15),
          width: 1.w,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Adjust Profile Photo',
                  style: GoogleFonts.outfit(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: tc.textPrimary,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: tc.textSecondary,
                    size: 20.r,
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              'Drag to position and pinch to zoom into the circular frame.',
              style: GoogleFonts.outfit(
                fontSize: 11.5.sp,
                color: tc.textSecondary,
              ),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 16.h),
            Container(
              width: cropSize,
              height: cropSize,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryColor,
                  width: 2.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.2),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: ClipOval(
                child: RepaintBoundary(
                  key: _cropKey,
                  child: InteractiveViewer(
                    transformationController: _transformCtrl,
                    minScale: 0.8,
                    maxScale: 4.0,
                    clipBehavior: Clip.none,
                    boundaryMargin: EdgeInsets.all(cropSize),
                    child: RotatedBox(
                      quarterTurns: _quarterTurns,
                      child: Image.file(
                        widget.file,
                        fit: BoxFit.cover,
                        width: cropSize,
                        height: cropSize,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: _rotate,
                  icon: Icon(
                    Icons.rotate_right_rounded,
                    size: 18.r,
                    color: AppColors.primaryColor,
                  ),
                  label: Text(
                    'Rotate',
                    style: GoogleFonts.outfit(
                      fontSize: 12.5.sp,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                TextButton.icon(
                  onPressed: _reset,
                  icon: Icon(
                    Icons.restart_alt_rounded,
                    size: 18.r,
                    color: tc.textSecondary,
                  ),
                  label: Text(
                    'Reset',
                    style: GoogleFonts.outfit(
                      fontSize: 12.5.sp,
                      color: tc.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: tc.textSecondary,
                      side: BorderSide(
                        color: tc.borderColor.withValues(alpha: 0.3),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 11.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.outfit(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _applyCrop,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 11.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: _isProcessing
                        ? SizedBox(
                            width: 16.r,
                            height: 16.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Save & Use',
                            style: GoogleFonts.outfit(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
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
}
