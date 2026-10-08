import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:Braintech/core/utils/app_spacing.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/chat_audio_service.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../models/chat_message_model.dart';

class DirectChatBubble extends StatefulWidget {
  final ChatMessageModel message;

  const DirectChatBubble({super.key, required this.message});

  @override
  State<DirectChatBubble> createState() => _DirectChatBubbleState();
}

class _DirectChatBubbleState extends State<DirectChatBubble>
    with SingleTickerProviderStateMixin {
  bool _isPlayingVoice = false;
  AudioPlayer? _audioPlayer;
  StreamSubscription? _posSubscription;
  StreamSubscription? _completeSubscription;
  StreamSubscription? _stateSubscription;
  StreamSubscription? _durationSubscription;

  Timer? _simulatedTimer;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = const Duration(seconds: 15);
  AnimationController? _waveAnimController;

  bool _isLoadingAudio = false;

  @override
  void initState() {
    super.initState();
    _totalDuration = _parseDuration(widget.message.voiceDuration);
    _waveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
  }

  @override
  void didUpdateWidget(covariant DirectChatBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.voiceDuration != widget.message.voiceDuration) {
      _totalDuration = _parseDuration(widget.message.voiceDuration);
    }
  }

  Duration _parseDuration(String? dur) {
    if (dur == null || dur.trim().isEmpty) return const Duration(seconds: 15);
    final parts = dur.trim().split(':');
    if (parts.length == 2) {
      final m = int.tryParse(parts[0]) ?? 0;
      final s = int.tryParse(parts[1]) ?? 0;
      final total = m * 60 + s;
      return Duration(seconds: total > 0 ? total : 2);
    }
    final secs = int.tryParse(dur.trim()) ?? 15;
    return Duration(seconds: secs > 0 ? secs : 2);
  }

  @override
  void dispose() {
    _simulatedTimer?.cancel();
    _posSubscription?.cancel();
    _completeSubscription?.cancel();
    _stateSubscription?.cancel();
    _durationSubscription?.cancel();
    if (_audioPlayer != null) {
      ChatAudioService.unregisterActivePlayer(_audioPlayer!);
      _audioPlayer?.dispose();
    }
    _waveAnimController?.dispose();
    super.dispose();
  }

  void _initAudioPlayer() {
    if (_audioPlayer != null) return;
    final player = AudioPlayer();
    _audioPlayer = player;

    _posSubscription = player.onPositionChanged.listen((pos) {
      if (mounted) {
        setState(() {
          _currentPosition = pos;
        });
      }
    });

    _durationSubscription = player.onDurationChanged.listen((dur) {
      if (mounted && dur > Duration.zero) {
        setState(() {
          _totalDuration = dur;
        });
      }
    });

    _stateSubscription = player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        final isPlaying = state == PlayerState.playing;
        setState(() {
          _isPlayingVoice = isPlaying;
          if (isPlaying) _isLoadingAudio = false;
        });
        if (isPlaying) {
          if (!(_waveAnimController?.isAnimating ?? false)) {
            _waveAnimController?.repeat(reverse: true);
          }
        } else {
          _waveAnimController?.stop();
        }
      }
    });

    _completeSubscription = player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlayingVoice = false;
          _currentPosition = Duration.zero;
        });
        _waveAnimController?.stop();
      }
    });
  }

  void _toggleVoicePlayback() {
    if (_isPlayingVoice) {
      _pauseVoicePlayback();
    } else {
      _startVoicePlayback();
    }
  }

  Future<void> _startVoicePlayback() async {
    _initAudioPlayer();
    await ChatAudioService.ensureAudioContext();

    if (mounted) setState(() => _isLoadingAudio = true);

    try {
      await _audioPlayer!.setAudioContext(ChatAudioService.audioContext);
      await _audioPlayer!.setVolume(1.0);

      ChatAudioService.registerActivePlayer(_audioPlayer!, () {
        if (mounted) _pauseVoicePlayback();
      });

      if (_audioPlayer?.state == PlayerState.paused) {
        await _audioPlayer!.resume();
        if (mounted) {
          setState(() {
            _isLoadingAudio = false;
            _isPlayingVoice = true;
          });
        }
        return;
      }

      final file =
          await ChatAudioService.resolvePlayableFile(widget.message.mediaUrl);

      if (file != null && file.existsSync()) {
        try {
          await _audioPlayer!.play(DeviceFileSource(file.path));
        } catch (playErr) {
          debugPrint("DeviceFileSource failed ($playErr), trying BytesSource...");
          final bytes = await file.readAsBytes();
          await _audioPlayer!.play(BytesSource(bytes));
        }
        _waveAnimController?.repeat(reverse: true);
        if (mounted) {
          setState(() {
            _isLoadingAudio = false;
            _isPlayingVoice = true;
          });
        }
        return;
      }
    } catch (e) {
      debugPrint("DirectChat AudioPlayer playback error: $e");
    }

    if (mounted) {
      setState(() {
        _isLoadingAudio = false;
        _isPlayingVoice = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio message is currently unavailable to play'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _pauseVoicePlayback() async {
    _simulatedTimer?.cancel();
    _waveAnimController?.stop();
    try {
      await _audioPlayer?.pause();
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isPlayingVoice = false;
        _isLoadingAudio = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final isMe = widget.message.isMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 12.h,
          left: isMe ? 48.w : 0,
          right: isMe ? 0 : 48.w,
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isMe
              ? tc.buttonPrimary
              : (tc.isDark
                  ? const Color(0xFF1E2D3D)
                  : const Color.fromARGB(255, 162, 196, 240)),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(isMe ? 16.r : 4.r),
            bottomRight: Radius.circular(isMe ? 4.r : 16.r),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildContent(tc),
            AppSpacing.h6,
            Text(
              widget.message.timestamp,
              style: GoogleFonts.outfit(
                fontSize: 10.sp,
                color: isMe
                    ? Colors.white.withValues(alpha: 0.7)
                    : tc.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AppThemeColors tc) {
    final isMe = widget.message.isMe;
    final mediaLower = (widget.message.mediaUrl ?? '').toLowerCase();

    final isImage = widget.message.type == ChatMessageType.image ||
        mediaLower.contains('.jpg') ||
        mediaLower.contains('.png') ||
        mediaLower.contains('.jpeg') ||
        mediaLower.contains('.webp');

    if (isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: _buildImageWidget(),
      );
    }

    final isVoice = widget.message.type == ChatMessageType.voice ||
        (widget.message.voiceDuration != null &&
            widget.message.voiceDuration!.trim().isNotEmpty) ||
        mediaLower.contains('.m4a') ||
        mediaLower.contains('.mp3') ||
        mediaLower.contains('.wav') ||
        mediaLower.contains('.aac') ||
        mediaLower.contains('.ogg');

    if (isVoice) {
      final totalSec =
          _totalDuration.inSeconds > 0 ? _totalDuration.inSeconds : 15;
      final curSec = _currentPosition.inSeconds;
      final displaySec = _isPlayingVoice || _currentPosition > Duration.zero
          ? curSec
          : totalSec;
      final displayTime =
          '${displaySec ~/ 60}:${(displaySec % 60).toString().padLeft(2, '0')}';

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _toggleVoicePlayback,
            behavior: HitTestBehavior.opaque,
            child: CircleAvatar(
              radius: 18.r,
              backgroundColor: isMe
                  ? Colors.white.withValues(alpha: 0.25)
                  : (tc.isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : tc.buttonPrimary),
              child: _isLoadingAudio
                  ? SizedBox(
                      width: 15.r,
                      height: 15.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      _isPlayingVoice
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
            ),
          ),
          AppSpacing.w10,
          _buildWaveformUI(isMe),
          AppSpacing.w8,
          Text(
            displayTime,
            style: GoogleFonts.outfit(
              fontSize: 12.sp,
              color: isMe ? Colors.white : tc.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    final rawText = widget.message.text.trim();
    if (rawText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      widget.message.text,
      style: GoogleFonts.outfit(
        fontSize: 14.sp,
        color: isMe ? Colors.white : tc.textPrimary,
        height: 1.35,
      ),
    );
  }

  Widget _buildImageWidget() {
    final path = widget.message.mediaUrl ?? '';
    if (path.startsWith('assets/')) {
      return Image.asset(path, width: 200.w, height: 140.h, fit: BoxFit.cover);
    }
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(file, width: 200.w, height: 140.h, fit: BoxFit.cover);
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, width: 200.w, height: 140.h, fit: BoxFit.cover);
    }
    if (path.startsWith('/media/') || path.startsWith('media/')) {
      final clean = path.startsWith('/') ? path : '/$path';
      return Image.network('${ApiEndpoints.baseUrl}$clean',
          width: 200.w, height: 140.h, fit: BoxFit.cover);
    }
    return Image.asset(
      'assets/images/onboarding1.png',
      width: 200.w,
      height: 140.h,
      fit: BoxFit.cover,
    );
  }

  Widget _buildWaveformUI(bool isMe) {
    final baseHeights = [
      12.h,
      20.h,
      8.h,
      24.h,
      16.h,
      28.h,
      14.h,
      22.h,
      10.h,
      18.h,
    ];
    final totalMs = _totalDuration.inMilliseconds > 0
        ? _totalDuration.inMilliseconds
        : 15000;
    final progress =
        (_currentPosition.inMilliseconds / totalMs).clamp(0.0, 1.0);
    final activeBarCount = (progress * baseHeights.length).round();

    return AnimatedBuilder(
      animation: _waveAnimController ?? const AlwaysStoppedAnimation(0.0),
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(baseHeights.length, (index) {
            final isBarActive = index <= activeBarCount;
            double h = baseHeights[index];

            if (_isPlayingVoice && _waveAnimController != null) {
              final phase = (_waveAnimController!.value * 2 * math.pi) +
                  (index * 0.6);
              final dynamicFactor = (math.sin(phase) * 3.5.h);
              h = (h + dynamicFactor).clamp(6.h, 28.h);
            }

            final double opacity;
            if (isBarActive) {
              opacity = 1.0;
            } else {
              opacity = isMe ? 0.35 : 0.3;
            }

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 1.5.w),
              width: 3.w,
              height: h,
              decoration: BoxDecoration(
                color: isMe
                    ? Colors.white.withValues(alpha: opacity)
                    : const Color(0xFF006EDB).withValues(alpha: opacity),
                borderRadius: BorderRadius.circular(2.r),
              ),
            );
          }),
        );
      },
    );
  }
}
