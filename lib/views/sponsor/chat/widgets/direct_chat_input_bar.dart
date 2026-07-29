import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/app_theme_colors.dart';

class DirectChatInputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final ValueChanged<String>? onSendImage;
  final ValueChanged<String>? onSendVoice;

  const DirectChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.onSendImage,
    this.onSendVoice,
  });

  @override
  State<DirectChatInputBar> createState() => _DirectChatInputBarState();
}

class _DirectChatInputBarState extends State<DirectChatInputBar> {
  final ImagePicker _picker = ImagePicker();
  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _recordTimer?.cancel();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (file != null && widget.onSendImage != null) {
        widget.onSendImage!(file.path);
      }
    } catch (_) {
      if (widget.onSendImage != null) {
        widget.onSendImage!('assets/images/onboarding1.png');
      }
    }
  }

  void _showImagePickerModal() {
    final tc = AppThemeColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: tc.sheetBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 28.r,
                        backgroundColor: const Color(0xFF006EDB),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Camera",
                        style: GoogleFonts.outfit(
                          color: tc.textPrimary,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 28.r,
                        backgroundColor: const Color(0xFF10B981),
                        child: const Icon(
                          Icons.photo_library_rounded,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Gallery",
                        style: GoogleFonts.outfit(
                          color: tc.textPrimary,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordSeconds = 0;
    });
    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _recordSeconds++);
    });
  }

  void _cancelRecording() {
    _recordTimer?.cancel();
    setState(() {
      _isRecording = false;
      _recordSeconds = 0;
    });
  }

  void _stopAndSendRecording() {
    _recordTimer?.cancel();
    final mins = _recordSeconds ~/ 60;
    final secs = _recordSeconds % 60;
    final durationStr = "$mins:${secs.toString().padLeft(2, '0')}";
    setState(() {
      _isRecording = false;
      _recordSeconds = 0;
    });
    if (widget.onSendVoice != null) {
      widget.onSendVoice!(durationStr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Separated Image Upload Button (outside chat input container)
            GestureDetector(
              onTap: _showImagePickerModal,
              child: Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: tc.isDark
                      ? const Color(0xFF0C1D2F).withValues(alpha: 0.9)
                      : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: tc.borderColor,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.add_photo_alternate_rounded,
                  color: const Color(0xFF006EDB),
                  size: 22.r,
                ),
              ),
            ),
            SizedBox(width: 8.w),

            // Chat Input Container
            Expanded(
              child: Container(
                height: 48.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: tc.isDark
                      ? const Color(0xFF0C1D2F).withValues(alpha: 0.9)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: tc.borderColor,
                    width: 1,
                  ),
                ),
                child: _isRecording
                    ? _buildRecordingBar(tc)
                    : _buildInputContent(tc),
              ),
            ),
            SizedBox(width: 8.w),

            // Action Button (Send / Mic / Checkmark)
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputContent(AppThemeColors tc) {
    return Center(
      child: TextField(
        controller: widget.controller,
        onSubmitted: (_) => widget.onSend(),
        style: GoogleFonts.outfit(fontSize: 14.sp, color: tc.textPrimary),
        decoration: InputDecoration(
          hintText: "Type a message...",
          hintStyle: GoogleFonts.outfit(
            fontSize: 14.sp,
            color: tc.textTertiary,
          ),
          border: InputBorder.none,
          isCollapsed: true,
        ),
      ),
    );
  }

  Widget _buildRecordingBar(AppThemeColors tc) {
    final mins = _recordSeconds ~/ 60;
    final secs = _recordSeconds % 60;
    final durationStr = "$mins:${secs.toString().padLeft(2, '0')}";

    return Row(
      children: [
        Container(
          width: 10.r,
          height: 10.r,
          decoration: const BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          "Recording $durationStr",
          style: GoogleFonts.outfit(
            color: Colors.redAccent,
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _cancelRecording,
          child: Icon(
            Icons.delete_outline_rounded,
            color: tc.textTertiary,
            size: 22.r,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    if (_isRecording) {
      return GestureDetector(
        onTap: _stopAndSendRecording,
        child: Container(
          width: 48.r,
          height: 48.r,
          decoration: const BoxDecoration(
            color: Color(0xFF10B981),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded, color: Colors.white, size: 22.r),
        ),
      );
    }

    if (_hasText) {
      return GestureDetector(
        onTap: widget.onSend,
        child: Container(
          width: 48.r,
          height: 48.r,
          decoration: const BoxDecoration(
            color: Color(0xFF006EDB),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.send_rounded, color: Colors.white, size: 20.r),
        ),
      );
    }

    return GestureDetector(
      onTap: _startRecording,
      child: Container(
        width: 48.r,
        height: 48.r,
        decoration: const BoxDecoration(
          color: Color(0xFF006EDB),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.mic_rounded, color: Colors.white, size: 22.r),
      ),
    );
  }
}
