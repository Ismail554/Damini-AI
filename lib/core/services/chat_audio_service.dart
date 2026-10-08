import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/api_endpoints.dart';
import 'storage_service.dart';

class ChatAudioService {
  static bool _contextInitialized = false;

  /// Global standard audio context for voice note playback through main loudspeaker
  static final AudioContext audioContext = AudioContext(
    android: const AudioContextAndroid(
      isSpeakerphoneOn: false,
      stayAwake: true,
      contentType: AndroidContentType.music,
      usageType: AndroidUsageType.media,
      audioFocus: AndroidAudioFocus.gain,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: const {},
    ),
  );

  /// Track active player so only one voice message plays at a time across the chat
  static AudioPlayer? _activePlayer;
  static VoidCallback? _stopActivePlayerCallback;

  static void registerActivePlayer(AudioPlayer player, VoidCallback onStopped) {
    if (_activePlayer != null && _activePlayer != player) {
      try {
        _activePlayer!.stop();
      } catch (_) {}
      _stopActivePlayerCallback?.call();
    }
    _activePlayer = player;
    _stopActivePlayerCallback = onStopped;
  }

  static void unregisterActivePlayer(AudioPlayer player) {
    if (_activePlayer == player) {
      _activePlayer = null;
      _stopActivePlayerCallback = null;
    }
  }

  /// Global AudioContext configuration: routes to media speaker at full volume
  static Future<void> ensureAudioContext() async {
    if (_contextInitialized) return;
    try {
      await AudioPlayer.global.setAudioContext(audioContext);
      _contextInitialized = true;
    } catch (e) {
      debugPrint("AudioContext init error: $e");
    }
  }

  /// Resolves any audio path/URL (local device file, relative server media, or ngrok URL)
  /// into a local playable file, bypassing ngrok warning screens and authenticating if necessary.
  static Future<File?> resolvePlayableFile(String? rawUrl) async {
    if (rawUrl == null || rawUrl.trim().isEmpty) return null;
    final trimmed = rawUrl.trim();

    // 1. If it's already a valid local file on the device with actual audio data (> 100 bytes)
    final local = File(trimmed);
    if (local.existsSync() && local.lengthSync() > 100) {
      return local;
    }

    // 2. Build full HTTP / HTTPS URL
    String fullUrl = trimmed;
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      final cleanPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
      final base = ApiEndpoints.baseUrl.endsWith('/')
          ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
          : ApiEndpoints.baseUrl;
      fullUrl = '$base$cleanPath';
    }

    // If backend gave localhost or 127.0.0.1 in the URL, rewrite it to use ApiEndpoints.baseUrl
    if (fullUrl.contains('localhost') || fullUrl.contains('127.0.0.1')) {
      final uri = Uri.parse(fullUrl);
      final base = ApiEndpoints.baseUrl.endsWith('/')
          ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
          : ApiEndpoints.baseUrl;
      fullUrl = '$base${uri.path}';
    }

    if (!fullUrl.startsWith('http://') && !fullUrl.startsWith('https://')) {
      return null;
    }

    // 3. Check local cache
    try {
      final tempDir = await getTemporaryDirectory();
      final urlHash = fullUrl.hashCode.abs();
      final ext = fullUrl.contains('.mp3')
          ? 'mp3'
          : (fullUrl.contains('.wav') ? 'wav' : 'm4a');
      final cachedFile = File('${tempDir.path}/cached_voice_$urlHash.$ext');

      if (cachedFile.existsSync() && cachedFile.lengthSync() > 100) {
        return cachedFile;
      }

      // 4. Download file with ngrok-skip-browser-warning and auth token headers
      final token = await StorageService.getToken();
      final headers = <String, String>{
        'ngrok-skip-browser-warning': '69420',
        'User-Agent': 'Mozilla/5.0 (Mobile; Dart)',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final dio = Dio();
      final response = await dio.get<List<int>>(
        fullUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: headers,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 400,
        ),
      );

      if (response.data != null && response.data!.length > 100) {
        final snippet =
            String.fromCharCodes(response.data!.take(30)).toLowerCase();
        if (snippet.contains('<!doctype') || snippet.contains('<html')) {
          debugPrint("Downloaded content from $fullUrl is HTML, not audio!");
          return null;
        }

        await cachedFile.writeAsBytes(response.data!);
        debugPrint(
          "Successfully cached remote audio: ${cachedFile.path} (${cachedFile.lengthSync()} bytes)",
        );
        return cachedFile;
      }
    } catch (e) {
      debugPrint("Error downloading audio from $fullUrl: $e");
    }

    return null;
  }
}
