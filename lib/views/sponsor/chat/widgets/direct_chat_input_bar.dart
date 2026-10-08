import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../../../core/utils/app_theme_colors.dart';

typedef SendVoiceCallback = void Function(String duration, {String? filePath});

class DirectChatInputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final ValueChanged<String>? onSendImage;
  final SendVoiceCallback? onSendVoice;
  final ValueChanged<bool>? onTyping;

  const DirectChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.onSendImage,
    this.onSendVoice,
    this.onTyping,
  });

  @override
  State<DirectChatInputBar> createState() => _DirectChatInputBarState();
}

class _DirectChatInputBarState extends State<DirectChatInputBar>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;
  bool _hasText = false;
  AudioRecorder? _audioRecorder;
  String? _recordedFilePath;

  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;
  AnimationController? _waveController;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_onTextChanged);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.35).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
      widget.onTyping?.call(hasText);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _recordTimer?.cancel();
    _pulseController?.dispose();
    _waveController?.dispose();
    _audioRecorder?.dispose();
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

  Future<void> _startRecording() async {
    try {
      _audioRecorder ??= AudioRecorder();
      final hasPerm = await _audioRecorder!.hasPermission();

      if (!hasPerm) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission is required to record audio'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _recordedFilePath = filePath;

      await _audioRecorder!.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );

      if (mounted) {
        setState(() {
          _isRecording = true;
          _recordSeconds = 0;
        });
        _recordTimer?.cancel();
        _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) setState(() => _recordSeconds++);
        });
      }
    } catch (e) {
      debugPrint("Audio recorder exception: $e");
      if (mounted) {
        setState(() {
          _isRecording = false;
          _recordSeconds = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start recording: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _cancelRecording() async {
    _recordTimer?.cancel();
    try {
      await _audioRecorder?.stop();
      if (_recordedFilePath != null) {
        final file = File(_recordedFilePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (_) {}
    _recordedFilePath = null;
    if (mounted) {
      setState(() {
        _isRecording = false;
        _recordSeconds = 0;
      });
    }
  }

  Future<void> _stopAndSendRecording() async {
    _recordTimer?.cancel();
    final effectiveSecs = _recordSeconds == 0 ? 1 : _recordSeconds;
    final mins = effectiveSecs ~/ 60;
    final secs = effectiveSecs % 60;
    final durationStr = "$mins:${secs.toString().padLeft(2, '0')}";

    String? finalPath;
    try {
      finalPath = await _audioRecorder?.stop();
    } catch (e) {
      debugPrint("Audio recorder stop error: $e");
    }
    finalPath ??= _recordedFilePath;

    if (mounted) {
      setState(() {
        _isRecording = false;
        _recordSeconds = 0;
      });
    }

    if (finalPath == null) return;
    final file = File(finalPath);
    if (!file.existsSync() || file.lengthSync() < 200) {
      debugPrint("Audio recording file is missing or empty (${file.existsSync() ? file.lengthSync() : 0} bytes)");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio recording was too short or empty. Please hold and speak.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    if (widget.onSendVoice != null) {
      widget.onSendVoice!(durationStr, filePath: finalPath);
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
        // Pulsing glowing red recording indicator
        if (_pulseAnimation != null)
          AnimatedBuilder(
            animation: _pulseAnimation!,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation!.value,
                child: Container(
                  width: 9.r,
                  height: 9.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.55),
                        blurRadius: 7,
                        spreadRadius: 2.5,
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        else
          Container(
            width: 9.r,
            height: 9.r,
            decoration: const BoxDecoration(
              color: Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
          ),
        SizedBox(width: 8.w),

        // Live recording duration
        Text(
          durationStr,
          style: GoogleFonts.outfit(
            color: const Color(0xFFEF4444),
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w700,
          ),
        ),

        SizedBox(width: 10.w),

        // Dynamic sound wave visualizer bars
        Expanded(
          child: Center(
            child: _waveController != null
                ? AnimatedBuilder(
                    animation: _waveController!,
                    builder: (context, child) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(10, (index) {
                          final phase = (_waveController!.value * 2 * math.pi) +
                              (index * 0.65);
                          final heightFactor =
                              (math.sin(phase).abs() * 0.75) + 0.25;
                          final barHeight = 5.h + (16.h * heightFactor);

                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 1.5.w),
                            width: 2.5.w,
                            height: barHeight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2.r),
                              gradient: const LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Color(0xFF006EDB),
                                  Color(0xFF38BDF8),
                                ],
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  )
                : const SizedBox.shrink(),
          ),
        ),

        // Cancel / Delete recording button
        GestureDetector(
          onTap: _cancelRecording,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: EdgeInsets.all(5.r),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              color: const Color(0xFFEF4444),
              size: 20.r,
            ),
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
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(Icons.check_rounded, color: Colors.white, size: 24.sp),
        ),
      );
    }

    if (_hasText) {
      return GestureDetector(
        onTap: widget.onSend,
        child: Container(
          width: 48.w,
          height: 48.h,
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
        width: 48.w,
        height: 48.h,
        decoration: const BoxDecoration(
          color: Color(0xFF006EDB),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.mic_rounded, color: Colors.white, size: 22.r),
      ),
    );
  }
}
