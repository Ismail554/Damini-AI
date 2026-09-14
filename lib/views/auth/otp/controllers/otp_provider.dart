import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../session/controllers/session_provider.dart';
import '../models/otp_model.dart';
import '../repositories/otp_repository.dart';

final otpRepositoryProvider = Provider<OtpRepository>((ref) {
  return OtpRepositoryImpl();
});

class OtpState {
  final bool isLoading;
  final bool isVerified;
  final String? errorMessage;
  final int secondsLeft;
  final bool isResending;

  const OtpState({
    this.isLoading = false,
    this.isVerified = false,
    this.errorMessage,
    this.secondsLeft = 59,
    this.isResending = false,
  });

  bool get canResend => secondsLeft == 0;

  OtpState copyWith({
    bool? isLoading,
    bool? isVerified,
    String? errorMessage,
    int? secondsLeft,
    bool? isResending,
    bool clearError = false,
  }) {
    return OtpState(
      isLoading: isLoading ?? this.isLoading,
      isVerified: isVerified ?? this.isVerified,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      secondsLeft: secondsLeft ?? this.secondsLeft,
      isResending: isResending ?? this.isResending,
    );
  }
}

final otpProvider = NotifierProvider<OtpNotifier, OtpState>(OtpNotifier.new);

class OtpNotifier extends Notifier<OtpState> {
  Timer? _timer;

  @override
  OtpState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const OtpState();
  }

  void startTimer() {
    _timer?.cancel();
    state = state.copyWith(secondsLeft: 59);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secondsLeft <= 1) {
        timer.cancel();
        state = state.copyWith(secondsLeft: 0);
      } else {
        state = state.copyWith(secondsLeft: state.secondsLeft - 1);
      }
    });
  }

  Future<bool> verifyOtp({
    required String email,
    required String code,
    bool isRecovery = false,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, isVerified: false);

    try {
      final repository = ref.read(otpRepositoryProvider);
      final response = await repository.verifyOtp(
        OtpVerificationRequestModel(
          email: email,
          code: code,
          isRecovery: isRecovery,
        ),
      );

      if (response.success) {
        if (!isRecovery) {
          ref.read(sessionProvider.notifier).updateSession(isAuthenticated: true);
        }
        state = state.copyWith(isLoading: false, isVerified: true);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message ?? "Verification failed",
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> resendOtp(String email) async {
    if (!state.canResend) return false;
    state = state.copyWith(isResending: true, clearError: true);

    try {
      final repository = ref.read(otpRepositoryProvider);
      final success = await repository.resendOtp(email);
      if (success) {
        startTimer();
      }
      state = state.copyWith(isResending: false);
      return success;
    } catch (e) {
      state = state.copyWith(isResending: false, errorMessage: e.toString());
      return false;
    }
  }
}
