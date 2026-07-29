import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/app_theme_colors.dart';

class AdditionalImagesSection extends StatefulWidget {
  final List<String> initialImages;
  final ValueChanged<List<String>>? onImagesChanged;

  const AdditionalImagesSection({
    super.key,
    this.initialImages = const [],
    this.onImagesChanged,
  });

  @override
  State<AdditionalImagesSection> createState() => _AdditionalImagesSectionState();
}

class _AdditionalImagesSectionState extends State<AdditionalImagesSection> {
  final List<String> _images = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _images.addAll(widget.initialImages);
  }

  Future<void> _pickAdditionalImages() async {
    if (_images.length >= 10) return;

    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(imageQuality: 85);
      if (pickedFiles.isNotEmpty) {
        setState(() {
          for (final file in pickedFiles) {
            if (_images.length < 10) {
              _images.add(file.path);
            }
          }
        });
        if (widget.onImagesChanged != null) {
          widget.onImagesChanged!(_images);
        }
      }
    } catch (_) {
      // Mock fallback image if picking unavailable or cancelled on platform
      setState(() {
        if (_images.length < 10) {
          _images.add('assets/images/onboarding${(_images.length % 3) + 1}.png');
        }
      });
      if (widget.onImagesChanged != null) {
        widget.onImagesChanged!(_images);
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
    if (widget.onImagesChanged != null) {
      widget.onImagesChanged!(_images);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final isMaxReached = _images.length >= 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Additional Project Images",
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: tc.textPrimary,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: isMaxReached
                    ? Colors.redAccent.withValues(alpha: 0.2)
                    : const Color(0xFF006EDB).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                "${_images.length}/10 max",
                style: GoogleFonts.outfit(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.bold,
                  color: isMaxReached ? Colors.redAccent : const Color(0xFF006EDB),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 90.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _images.length + (isMaxReached ? 0 : 1),
            itemBuilder: (context, index) {
              if (index == _images.length) {
                return _buildAddButton(tc);
              }
              return _buildThumbnail(_images[index], index, tc);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(AppThemeColors tc) {
    return GestureDetector(
      onTap: _pickAdditionalImages,
      child: Container(
        width: 90.w,
        height: 90.h,
        margin: EdgeInsets.only(right: 10.w),
        decoration: BoxDecoration(
          color: tc.isDark ? const Color(0xFF07192F) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFF006EDB).withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_rounded, color: const Color(0xFF006EDB), size: 24.r),
            SizedBox(height: 4.h),
            Text(
              "Add Image",
              style: GoogleFonts.outfit(
                color: const Color(0xFF006EDB),
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(String path, int index, AppThemeColors tc) {
    final isAsset = path.startsWith('assets/');
    final file = File(path);

    return Container(
      width: 90.w,
      height: 90.h,
      margin: EdgeInsets.only(right: 10.w),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: isAsset
                ? Image.asset(path, width: 90.w, height: 90.h, fit: BoxFit.cover)
                : (file.existsSync()
                    ? Image.file(file, width: 90.w, height: 90.h, fit: BoxFit.cover)
                    : Image.asset('assets/images/onboarding1.png', width: 90.w, height: 90.h, fit: BoxFit.cover)),
          ),
          Positioned(
            top: 4.r,
            right: 4.r,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: const BoxDecoration(
                  color: Color(0x99000000),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close_rounded, color: Colors.white, size: 14.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
