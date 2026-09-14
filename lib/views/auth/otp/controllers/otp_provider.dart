import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/api_service.dart';
import '../../session/controllers/session_provider.dart';
import '../models/otp_model.dart';
import '../repositories/otp_repository.dart';

final otpRepositoryProvider = Provider<OtpRepository>((ref) {
  return OtpRepositoryImpl(ref.watch(apiServiceProvider));
});

// Timer Provider for OTP countdown (60s)
final otpTimerProvider = NotifierProvider<OtpTimerNotifier, int>(
  OtpTimerNotifier.new,
);

class OtpTimerNotifier extends Notifier<int> {
  Timer? _timer;

  @override
  int build() {
    ref.onDispose(() => _timer?.cancel());
    return 60;
  }

  void startTimer([int duration = 60]) {
    _timer?.cancel();
    state = duration;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state <= 1) {
        timer.cancel();
        state = 0;
      } else {
        state--;
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }
}

// Resend OTP Provider (AsyncNotifier, exactly like SignupProvider)
final resendOtpProvider =
    AsyncNotifierProvider<ResendOtpProvider, OtpVerificationResponseModel?>(
      ResendOtpProvider.new,
    );

class ResendOtpProvider extends AsyncNotifier<OtpVerificationResponseModel?> {
  @override
  FutureOr<OtpVerificationResponseModel?> build() => null;

  Future<bool> resendOtp(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(otpRepositoryProvider).resendOtp(email),
    );

    final isSuccess = state.value?.success ?? false;
    if (isSuccess) {
      ref.read(otpTimerProvider.notifier).startTimer(60);
    }
    return isSuccess;
  }
}

// OTP Verification Provider (AsyncNotifier, exactly like SignupProvider)
final otpProvider =
    AsyncNotifierProvider<OtpProvider, OtpVerificationResponseModel?>(
      OtpProvider.new,
    );

class OtpProvider extends AsyncNotifier<OtpVerificationResponseModel?> {
  @override
  FutureOr<OtpVerificationResponseModel?> build() => null;

  Future<bool> verifyOtp(OtpVerificationRequestModel request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(otpRepositoryProvider).verifyOtp(request),
    );

    final isSuccess = state.value?.success ?? false;
    if (isSuccess) {
      ref.read(otpTimerProvider.notifier).stopTimer();
      if (!request.isRecovery) {
        ref.read(sessionProvider.notifier).updateSession(isAuthenticated: true);
      }
    }
    return isSuccess;
  }
}
