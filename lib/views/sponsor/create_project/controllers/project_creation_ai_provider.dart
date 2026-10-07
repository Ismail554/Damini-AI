import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ai_chat/models/ai_chat_message_model.dart';
import '../models/project_draft_model.dart';
import '../repositories/ai_project_creation_repository.dart';

enum ProjectCreationChatStep {
  intro,
  industry,
  description,
  fundingGoal,
  done,
}

class ProjectCreationAiState {
  final String? conversationId;
  final List<AiChatMessageModel> messages;
  final bool isInitializing;
  final bool isTyping;
  final ProjectCreationChatStep currentStep;
  final int? customStepIndex;
  final int? customTotalSteps;
  final String? customStepTitle;
  final List<String>? customSuggestions;
  final String industry;
  final String description;
  final String fundingGoal;
  final ProjectDraftModel? generatedDraft;
  final String? errorMessage;
  final int? retryAfterSeconds;

  const ProjectCreationAiState({
    this.conversationId,
    required this.messages,
    this.isInitializing = false,
    this.isTyping = false,
    this.currentStep = ProjectCreationChatStep.intro,
    this.customStepIndex,
    this.customTotalSteps,
    this.customStepTitle,
    this.customSuggestions,
    this.industry = '',
    this.description = '',
    this.fundingGoal = '',
    this.generatedDraft,
    this.errorMessage,
    this.retryAfterSeconds,
  });

  int get currentStepIndex {
    if (customStepIndex != null && customStepIndex! > 0) {
      return customStepIndex!;
    }
    switch (currentStep) {
      case ProjectCreationChatStep.intro:
      case ProjectCreationChatStep.industry:
        return 1;
      case ProjectCreationChatStep.description:
        return 2;
      case ProjectCreationChatStep.fundingGoal:
        return 3;
      case ProjectCreationChatStep.done:
        return 4;
    }
  }

  int get totalSteps => customTotalSteps ?? 4;

  String get stepTitle {
    if (customStepTitle != null && customStepTitle!.isNotEmpty) {
      return customStepTitle!;
    }
    switch (currentStep) {
      case ProjectCreationChatStep.intro:
      case ProjectCreationChatStep.industry:
        return "Select Industry";
      case ProjectCreationChatStep.description:
        return "Project Concept";
      case ProjectCreationChatStep.fundingGoal:
        return "Funding Target";
      case ProjectCreationChatStep.done:
        return "Blueprint Ready!";
    }
  }

  List<String> get currentSuggestions {
    if (customSuggestions != null && customSuggestions!.isNotEmpty) {
      return customSuggestions!;
    }
    switch (currentStep) {
      case ProjectCreationChatStep.intro:
      case ProjectCreationChatStep.industry:
        return const [
          "Technology",
          "Clean Energy",
          "Real Estate",
          "Healthcare",
          "Fintech",
        ];
      case ProjectCreationChatStep.description:
        return const [
          "A renewable energy solar farm project",
          "A downtown tech hub",
          "An innovative healthcare app",
        ];
      case ProjectCreationChatStep.fundingGoal:
        return const ["\$5,000,000", "\$1,000,000", "\$10,000,000"];
      case ProjectCreationChatStep.done:
        return const ["Apply to Project"];
    }
  }

  ProjectCreationAiState copyWith({
    String? conversationId,
    List<AiChatMessageModel>? messages,
    bool? isInitializing,
    bool? isTyping,
    ProjectCreationChatStep? currentStep,
    int? customStepIndex,
    int? customTotalSteps,
    String? customStepTitle,
    List<String>? customSuggestions,
    String? industry,
    String? description,
    String? fundingGoal,
    ProjectDraftModel? generatedDraft,
    bool clearDraft = false,
    String? errorMessage,
    bool clearError = false,
    int? retryAfterSeconds,
    bool clearRetry = false,
  }) {
    return ProjectCreationAiState(
      conversationId: conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
      isInitializing: isInitializing ?? this.isInitializing,
      isTyping: isTyping ?? this.isTyping,
      currentStep: currentStep ?? this.currentStep,
      customStepIndex: customStepIndex ?? this.customStepIndex,
      customTotalSteps: customTotalSteps ?? this.customTotalSteps,
      customStepTitle: customStepTitle ?? this.customStepTitle,
      customSuggestions: customSuggestions ?? this.customSuggestions,
      industry: industry ?? this.industry,
      description: description ?? this.description,
      fundingGoal: fundingGoal ?? this.fundingGoal,
      generatedDraft:
          clearDraft ? null : (generatedDraft ?? this.generatedDraft),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      retryAfterSeconds: clearRetry
          ? null
          : (retryAfterSeconds ?? this.retryAfterSeconds),
    );
  }
}

class ProjectCreationAiNotifier extends Notifier<ProjectCreationAiState> {
  AiProjectCreationRepository get _repository =>
      ref.read(aiProjectCreationRepositoryProvider);

  Timer? _countdownTimer;

  @override
  ProjectCreationAiState build() {
    ref.onDispose(() {
      _countdownTimer?.cancel();
    });

    return _defaultInitialState();
  }

  ProjectCreationAiState _defaultInitialState() {
    return ProjectCreationAiState(
      messages: [
        AiChatMessageModel(
          id: "msg_welcome",
          text:
              "Hi, I'm Damini Advisor. I can help you with creating a new project. To get started, what industry is your project in?",
          isUser: false,
          timestamp: DateTime.now(),
          suggestions: const [
            "Technology",
            "Clean Energy",
            "Real Estate",
            "Healthcare",
            "Fintech",
          ],
        ),
      ],
      currentStep: ProjectCreationChatStep.intro,
    );
  }

  ProjectCreationChatStep _mapStep(String step) {
    final lower = step.toLowerCase();
    if (lower.contains('indus')) return ProjectCreationChatStep.industry;
    if (lower.contains('desc') || lower.contains('concept')) {
      return ProjectCreationChatStep.description;
    }
    if (lower.contains('fund') || lower.contains('goal') || lower.contains('target')) {
      return ProjectCreationChatStep.fundingGoal;
    }
    if (lower.contains('done') || lower.contains('blueprint')) {
      return ProjectCreationChatStep.done;
    }
    return ProjectCreationChatStep.industry;
  }

  /// Initializes conversation with the backend.
  Future<void> initConversation({bool forceNew = false}) async {
    if (!forceNew && state.conversationId != null && state.conversationId!.isNotEmpty) {
      return;
    }

    state = state.copyWith(isInitializing: true, clearError: true);

    final result = await _repository.startConversation();
    if (result.success && result.data != null) {
      final data = result.data!;
      final welcomeMessage = data.message ??
          (data.messages.isNotEmpty ? data.messages.first : null);

      final nextStep = _mapStep(data.step);

      state = state.copyWith(
        conversationId: data.conversationId,
        isInitializing: false,
        messages: welcomeMessage != null ? [welcomeMessage] : state.messages,
        currentStep: nextStep,
        customStepIndex: data.stepIndex,
        customTotalSteps: data.totalSteps,
        customStepTitle: data.stepTitle,
        customSuggestions: welcomeMessage?.suggestions,
        generatedDraft: data.draft,
        clearError: true,
      );
    } else {
      // Keep fallback greeting so UI remains responsive even if offline
      state = state.copyWith(
        isInitializing: false,
        errorMessage: result.message,
      );
    }
  }

  /// Sends a message / user input to the backend conversation.
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    if (state.currentStep == ProjectCreationChatStep.done &&
        trimmed == "Apply to Project") {
      return;
    }

    if (state.retryAfterSeconds != null && state.retryAfterSeconds! > 0) {
      return;
    }

    // Append user message immediately
    final userMsg = AiChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
      clearError: true,
    );

    // If conversation is not yet started, initialize first
    String? currentConvId = state.conversationId;
    if (currentConvId == null || currentConvId.isEmpty) {
      final initRes = await _repository.startConversation(initialContext: trimmed);
      if (initRes.success && initRes.data != null) {
        currentConvId = initRes.data!.conversationId;
        state = state.copyWith(conversationId: currentConvId);
      } else {
        state = state.copyWith(
          isTyping: false,
          errorMessage: initRes.message ?? "Failed to initialize AI conversation.",
        );
        return;
      }
    }

    final result = await _repository.sendMessage(
      conversationId: currentConvId,
      content: trimmed,
    );

    if (result.success && result.data != null) {
      final data = result.data!;
      final newMessages = List<AiChatMessageModel>.from(state.messages);

      if (data.message != null) {
        newMessages.add(data.message!);
      }

      final nextStep = _mapStep(data.step);

      state = state.copyWith(
        messages: newMessages,
        isTyping: false,
        currentStep: nextStep,
        customStepIndex: data.stepIndex,
        customTotalSteps: data.totalSteps,
        customStepTitle: data.stepTitle,
        customSuggestions: data.message?.suggestions,
        generatedDraft: data.draft ?? state.generatedDraft,
        clearError: true,
      );
    } else {
      state = state.copyWith(isTyping: false);

      // Handle 404 (expired conversation)
      if (result.statusCode == 404) {
        await initConversation(forceNew: true);
        return;
      }

      // Handle retry-after countdown
      if (result.retryAfter != null && result.retryAfter! > 0) {
        _startRetryCountdown(result.retryAfter!);
      }

      state = state.copyWith(
        errorMessage: result.message ?? "Could not communicate with AI advisor.",
      );
    }
  }

  void _startRetryCountdown(int seconds) {
    _countdownTimer?.cancel();
    state = state.copyWith(retryAfterSeconds: seconds);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = state.retryAfterSeconds ?? 0;
      if (current <= 1) {
        timer.cancel();
        state = state.copyWith(clearRetry: true);
      } else {
        state = state.copyWith(retryAfterSeconds: current - 1);
      }
    });
  }

  /// Resets the conversation on backend and resets local state.
  Future<void> clearChat() async {
    _countdownTimer?.cancel();
    final convId = state.conversationId;
    if (convId != null && convId.isNotEmpty) {
      unawaited(_repository.resetConversation(conversationId: convId));
    }

    state = _defaultInitialState();
    await initConversation(forceNew: true);
  }
}

final projectCreationAiProvider = NotifierProvider.autoDispose<
    ProjectCreationAiNotifier, ProjectCreationAiState>(
  ProjectCreationAiNotifier.new,
);
