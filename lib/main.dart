import 'dart:ui';
import 'package:Braintech/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/app_service.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 1. Global crash & error boundary protection
  _setupErrorHandling();

  // 2. Parallel system UI setup
  await _configureSystemUI();

  // 3. Initialize core services safely
  try {
    await AppService.init();
  } catch (e, stack) {
    debugPrint('AppService.init failed: $e\n$stack');
  }

  // 4. Remove splash before mounting widget tree
  FlutterNativeSplash.remove();

  runApp(
    ProviderScope(
      observers: kDebugMode ? [const _AppProviderObserver()] : const [],
      child: const MyApp(),
    ),
  );
}

Future<void> _configureSystemUI() async {
  await Future.wait([
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]),
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge),
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      systemStatusBarContrastEnforced: false,
      statusBarColor: Colors.transparent,
    ),
  );
}

void _setupErrorHandling() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (!kDebugMode) {
      debugPrint('Flutter Error: ${details.exceptionAsString()}');
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught Async Error: $error');
    return true;
  };

  if (kReleaseMode) {
    ErrorWidget.builder = (details) => Material(
          color: const Color(0xFF0F1E2E),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFE2E8F0),
                    size: 48,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Something went wrong',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Please restart the app if this persists.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        );
  }
}

final class _AppProviderObserver extends ProviderObserver {
  const _AppProviderObserver();

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    debugPrint(
      '⚠️ [Riverpod Error] in ${context.provider.name ?? context.provider.runtimeType}: $error',
    );
  }
}

