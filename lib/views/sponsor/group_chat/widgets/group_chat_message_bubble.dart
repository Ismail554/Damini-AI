import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/chat_audio_service.dart';
import '../../chat/models/chat_message_model.dart';
import '../../../../core/utils/file_downloader.dart';
import '../models/group_chat_model.dart';

class GroupChatMessageBubble extends StatefulWidget {
  final GroupChatMessage message;

  const GroupChatMessageBubble({
    super.key,
    required this.message,
  });

  @override
  State<GroupChatMessageBubble> createState() => _GroupChatMessageBubbleState();
}

class _GroupChatMessageBubbleState extends State<GroupChatMessageBubble>
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
  void didUpdateWidget(covariant GroupChatMessageBubble oldWidget) {
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
      debugPrint("AudioPlayer playback error: $e");
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
    if (widget.message.type == ChatMessageType.system ||
        widget.message.senderRole?.toLowerCase() == 'system') {
      return _buildSystemMessage();
    }
    if (widget.message.isMe) {
      return _buildMyMessage();
    }
    return _buildOtherMessage();
  }

  Widget _buildSystemMessage() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          constraints: BoxConstraints(maxWidth: 0.85.sw),
          decoration: BoxDecoration(
            color: const Color(0xFF132235),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Text(
            widget.message.text,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: const Color(0xFF8EB2C7),
              fontSize: 12.sp,
              fontStyle: FontStyle.italic,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyMessage() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 4.w, bottom: 4.h),
            child: Text(
              '${widget.message.senderName}${widget.message.senderRole != null ? ' · ${widget.message.senderRole}' : ''}',
              style: GoogleFonts.outfit(
                color: const Color(0xFF6B8A9D),
                fontSize: 11.sp,
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 0.78.sw),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E60FF), Color(0xFF0052CC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(4.r),
                ),
              ),
              child: _buildBubbleContent(isMe: true),
            ),
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: Text(
              widget.message.time,
              style: GoogleFonts.outfit(
                color: const Color(0xFF6B8A9D),
                fontSize: 10.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherMessage() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 4.h),
            child: Text(
              '${widget.message.senderName}${widget.message.senderRole != null ? ' · ${widget.message.senderRole}' : ''}',
              style: GoogleFonts.outfit(
                color: const Color(0xFF6B8A9D),
                fontSize: 11.sp,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildAvatar(),
              SizedBox(width: 8.w),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 0.72.sw),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16253C),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                      bottomRight: Radius.circular(16.r),
                      bottomLeft: Radius.circular(4.r),
                    ),
                  ),
                  child: _buildBubbleContent(isMe: false),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(left: 36.w),
            child: Text(
              widget.message.time,
              style: GoogleFonts.outfit(
                color: const Color(0xFF6B8A9D),
                fontSize: 10.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleContent({required bool isMe}) {
    final mediaLower = (widget.message.mediaUrl ?? '').toLowerCase();
    final isVoice = widget.message.type == ChatMessageType.voice ||
        (widget.message.voiceDuration != null &&
            widget.message.voiceDuration!.trim().isNotEmpty) ||
        mediaLower.contains('.m4a') ||
        mediaLower.contains('.mp3') ||
        mediaLower.contains('.wav') ||
        mediaLower.contains('.aac') ||
        mediaLower.contains('.ogg');

    final isImage = widget.message.type == ChatMessageType.image ||
        mediaLower.contains('.jpg') ||
        mediaLower.contains('.png') ||
        mediaLower.contains('.jpeg') ||
        mediaLower.contains('.webp');

    if (isImage) {
      final heroTag =
          'chat_img_${widget.message.id}_${widget.message.mediaUrl}';
      return GestureDetector(
        onTap: () => _openFullScreenImage(context, heroTag: heroTag),
        behavior: HitTestBehavior.opaque,
        child: Hero(
          tag: heroTag,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                _buildImageWidget(),
                Container(
                  margin: EdgeInsets.all(6.r),
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Icon(
                    Icons.fullscreen_rounded,
                    size: 16.r,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
              radius: 16.r,
              backgroundColor: isMe
                  ? Colors.white.withValues(alpha: 0.25)
                  : const Color(0xFF006EDB),
              child: _isLoadingAudio
                  ? SizedBox(
                      width: 14.r,
                      height: 14.r,
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
                      size: 19.r,
                    ),
            ),
          ),
          SizedBox(width: 10.w),
          _buildWaveformUI(isMe),
          SizedBox(width: 8.w),
          Text(
            displayTime,
            style: GoogleFonts.outfit(
              fontSize: 12.sp,
              color: Colors.white,
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
        color: isMe ? Colors.white : const Color(0xFFE2E8F0),
        fontSize: 13.5.sp,
        height: 1.4,
      ),
    );
  }

  Widget _buildImageWidget() {
    final rawPath = widget.message.mediaUrl ?? '';
    if (rawPath.isEmpty) {
      return const SizedBox.shrink();
    }

    if (rawPath.startsWith('assets/')) {
      return Image.asset(
        rawPath,
        width: 190.w,
        height: 130.h,
        fit: BoxFit.cover,
      );
    }

    if (rawPath.startsWith('http://') || rawPath.startsWith('https://')) {
      return Image.network(
        rawPath,
        width: 190.w,
        height: 130.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 190.w,
          height: 130.h,
          color: const Color(0xFF0F1E2E),
          child: const Center(
            child: Icon(Icons.broken_image_rounded, color: Colors.white54),
          ),
        ),
      );
    }

    if (rawPath.startsWith('/media/') || rawPath.startsWith('media/')) {
      final cleanPath = rawPath.startsWith('/') ? rawPath : '/$rawPath';
      final fullUrl = '${ApiEndpoints.baseUrl}$cleanPath';
      return Image.network(
        fullUrl,
        width: 190.w,
        height: 130.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 190.w,
          height: 130.h,
          color: const Color(0xFF0F1E2E),
          child: const Center(
            child: Icon(Icons.broken_image_rounded, color: Colors.white54),
          ),
        ),
      );
    }

    final file = File(rawPath);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: 190.w,
        height: 130.h,
        fit: BoxFit.cover,
      );
    }

    return Container(
      width: 190.w,
      height: 130.h,
      color: const Color(0xFF0F1E2E),
      child: const Center(
        child: Icon(Icons.image_not_supported_rounded, color: Colors.white54),
      ),
    );
  }

  void _openFullScreenImage(BuildContext context, {String? heroTag}) {
    final rawPath = widget.message.mediaUrl ?? '';
    if (rawPath.isEmpty) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        pageBuilder: (ctx, a1, a2) => _FullScreenImageViewerDialog(
          rawPath: rawPath,
          title: widget.message.senderName,
          subtitle: widget.message.time,
          heroTag: heroTag,
        ),
      ),
    );
  }

  Widget _buildWaveformUI(bool isMe) {
    final baseHeights = [
      10.h,
      18.h,
      8.h,
      22.h,
      14.h,
      26.h,
      12.h,
      20.h,
      9.h,
      24.h,
      16.h,
      12.h,
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
                  (index * 0.55);
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

  Widget _buildAvatar() {
    if (widget.message.isAi) {
      return Container(
        width: 26.w,
        height: 26.w,
        decoration: const BoxDecoration(
          color: Color(0xFF7C3AED),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.smart_toy_rounded,
          color: Colors.white,
          size: 14.sp,
        ),
      );
    }
    return Container(
      width: 26.w,
      height: 26.w,
      decoration: const BoxDecoration(
        color: Color(0xFF006EDB),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          widget.message.avatarInitials,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 9.5.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _FullScreenImageViewerDialog extends StatefulWidget {
  final String rawPath;
  final String title;
  final String subtitle;
  final String? heroTag;

  const _FullScreenImageViewerDialog({
    required this.rawPath,
    required this.title,
    required this.subtitle,
    this.heroTag,
  });

  @override
  State<_FullScreenImageViewerDialog> createState() =>
      _FullScreenImageViewerDialogState();
}

class _FullScreenImageViewerDialogState
    extends State<_FullScreenImageViewerDialog> with TickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  late final AnimationController _zoomAnimController;
  late final AnimationController _dragResetController;
  Animation<double>? _dragResetAnimation;

  double _dragOffset = 0.0;
  bool _isDragging = false;
  bool _showControls = true;
  bool _isDownloading = false;
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _zoomAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _dragResetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _zoomAnimController.dispose();
    _dragResetController.dispose();
    super.dispose();
  }

  bool get _isZoomed {
    return _transformationController.value.getMaxScaleOnAxis() > 1.05;
  }

  void _handleDoubleTap() {
    final startMatrix = _transformationController.value;
    final Matrix4 endMatrix;

    if (_isZoomed) {
      endMatrix = Matrix4.identity();
    } else {
      final pos = _doubleTapDetails?.localPosition ?? Offset.zero;
      final x = -pos.dx * 1.5;
      final y = -pos.dy * 1.5;
      endMatrix = Matrix4.identity()
        ..setTranslationRaw(x, y, 0.0)
        ..setEntry(0, 0, 2.5)
        ..setEntry(1, 1, 2.5);
    }

    final anim = Matrix4Tween(begin: startMatrix, end: endMatrix).animate(
      CurvedAnimation(parent: _zoomAnimController, curve: Curves.easeInOut),
    );

    anim.addListener(() {
      _transformationController.value = anim.value;
    });

    _zoomAnimController.forward(from: 0.0);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_isZoomed) return;
    if (details.primaryDelta != null &&
        (_dragOffset > 0 || details.primaryDelta! > 0)) {
      setState(() {
        _isDragging = true;
        _dragOffset += details.primaryDelta!;
        if (_dragOffset < 0) _dragOffset = 0;
      });
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_isZoomed || !_isDragging) return;
    if (_dragOffset > 100 ||
        (details.primaryVelocity != null && details.primaryVelocity! > 500)) {
      Navigator.of(context).pop();
    } else {
      final start = _dragOffset;
      _dragResetAnimation = Tween<double>(begin: start, end: 0.0).animate(
        CurvedAnimation(parent: _dragResetController, curve: Curves.easeOut),
      )..addListener(() {
          setState(() {
            _dragOffset = _dragResetAnimation!.value;
          });
        });
      _dragResetController.forward(from: 0.0).then((_) {
        setState(() {
          _isDragging = false;
          _dragOffset = 0;
        });
      });
    }
  }

  Future<void> _handleDownload() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);

    String downloadUrl = widget.rawPath;
    if (downloadUrl.startsWith('/media/') || downloadUrl.startsWith('media/')) {
      final clean = downloadUrl.startsWith('/') ? downloadUrl : '/$downloadUrl';
      downloadUrl = '${ApiEndpoints.baseUrl}$clean';
    }

    final ext = downloadUrl.split('.').last.split('?').first.toLowerCase();
    await FileDownloader.downloadFile(
      context,
      url: downloadUrl,
      suggestedName: 'image_${DateTime.now().millisecondsSinceEpoch}',
      extension: ext.isNotEmpty ? ext : 'jpg',
    );

    if (mounted) {
      setState(() => _isDownloading = false);
    }
  }

  Widget _buildImage() {
    final rawPath = widget.rawPath;
    if (rawPath.startsWith('assets/')) {
      return Image.asset(rawPath, fit: BoxFit.contain);
    }
    if (rawPath.startsWith('http://') || rawPath.startsWith('https://')) {
      return Image.network(
        rawPath,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(
            Icons.broken_image_rounded,
            color: Colors.white54,
            size: 48,
          ),
        ),
      );
    }
    if (rawPath.startsWith('/media/') || rawPath.startsWith('media/')) {
      final cleanPath = rawPath.startsWith('/') ? rawPath : '/$rawPath';
      final fullUrl = '${ApiEndpoints.baseUrl}$cleanPath';
      return Image.network(
        fullUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(
            Icons.broken_image_rounded,
            color: Colors.white54,
            size: 48,
          ),
        ),
      );
    }
    final file = File(rawPath);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.contain);
    }
    return const Center(
      child: Icon(
        Icons.broken_image_rounded,
        color: Colors.white54,
        size: 48,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgAlpha = ((1.0 - (_dragOffset / 300)).clamp(0.0, 1.0) * 0.95);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: bgAlpha),
      body: SafeArea(
        child: Stack(
          children: [
            // Center Image with Interactive Zoom and Drag Dismiss
            Center(
              child: GestureDetector(
                onTap: () => setState(() => _showControls = !_showControls),
                onDoubleTapDown: (d) => _doubleTapDetails = d,
                onDoubleTap: _handleDoubleTap,
                onVerticalDragUpdate: _onVerticalDragUpdate,
                onVerticalDragEnd: _onVerticalDragEnd,
                child: Transform.translate(
                  offset: Offset(0, _dragOffset),
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 0.8,
                    maxScale: 5.0,
                    child: widget.heroTag != null
                        ? Hero(
                            tag: widget.heroTag!,
                            child: _buildImage(),
                          )
                        : _buildImage(),
                  ),
                ),
              ),
            ),

            // Top Bar
            Positioned(
              top: 8.h,
              left: 16.w,
              right: 16.w,
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (widget.subtitle.isNotEmpty)
                            Text(
                              widget.subtitle,
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 12.sp,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Download Button
                    if (widget.rawPath.startsWith('http') ||
                        widget.rawPath.contains('media'))
                      Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: GestureDetector(
                          onTap: _handleDownload,
                          child: Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: _isDownloading
                                ? SizedBox(
                                    width: 20.r,
                                    height: 20.r,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    Icons.download_rounded,
                                    color: Colors.white,
                                    size: 20.r,
                                  ),
                          ),
                        ),
                      ),
                    // Close Button
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20.r,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Hint
            Positioned(
              bottom: 16.h,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Text(
                      "Pinch to zoom • Swipe down to dismiss",
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 11.5.sp,
                      ),
                    ),
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
