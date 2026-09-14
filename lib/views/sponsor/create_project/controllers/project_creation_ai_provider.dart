import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ai_chat/models/ai_chat_message_model.dart';
import '../models/project_draft_model.dart';

enum ProjectCreationChatStep {
  intro,
  industry,
  description,
  fundingGoal,
  done,
}

class ProjectCreationAiState {
  final List<AiChatMessageModel> messages;
  final bool isTyping;
  final ProjectCreationChatStep currentStep;
  final String industry;
  final String description;
  final String fundingGoal;
  final ProjectDraftModel? generatedDraft;

  const ProjectCreationAiState({
    required this.messages,
    this.isTyping = false,
    this.currentStep = ProjectCreationChatStep.intro,
    this.industry = '',
    this.description = '',
    this.fundingGoal = '',
    this.generatedDraft,
  });

  int get currentStepIndex {
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

  int get totalSteps => 4;

  String get stepTitle {
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
    switch (currentStep) {
      case ProjectCreationChatStep.intro:
      case ProjectCreationChatStep.industry:
        return [
          "Technology",
          "Clean Energy",
          "Real Estate",
          "Healthcare",
          "Fintech",
        ];
      case ProjectCreationChatStep.description:
        return [
          "A renewable energy solar farm project",
          "A downtown tech hub",
          "An innovative healthcare app",
        ];
      case ProjectCreationChatStep.fundingGoal:
        return ["\$5,000,000", "\$1,000,000", "\$10,000,000"];
      case ProjectCreationChatStep.done:
        return ["Apply to Project"];
    }
  }

  ProjectCreationAiState copyWith({
    List<AiChatMessageModel>? messages,
    bool? isTyping,
    ProjectCreationChatStep? currentStep,
    String? industry,
    String? description,
    String? fundingGoal,
    ProjectDraftModel? generatedDraft,
    bool clearDraft = false,
  }) {
    return ProjectCreationAiState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      currentStep: currentStep ?? this.currentStep,
      industry: industry ?? this.industry,
      description: description ?? this.description,
      fundingGoal: fundingGoal ?? this.fundingGoal,
      generatedDraft:
          clearDraft ? null : (generatedDraft ?? this.generatedDraft),
    );
  }
}

class ProjectCreationAiNotifier
    extends Notifier<ProjectCreationAiState> {
  @override
  ProjectCreationAiState build() {
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
    );
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    if (state.currentStep == ProjectCreationChatStep.done &&
        trimmed == "Apply to Project") {
      return;
    }

    final userMsg = AiChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
    );

    await Future.delayed(const Duration(milliseconds: 1000));

    _processUserResponse(trimmed);
  }

  void _processUserResponse(String response) {
    String aiReplyText = "";
    ProjectCreationChatStep nextStep = state.currentStep;
    String newIndustry = state.industry;
    String newDescription = state.description;
    String newFundingGoal = state.fundingGoal;
    ProjectDraftModel? draft = state.generatedDraft;

    switch (state.currentStep) {
      case ProjectCreationChatStep.intro:
      case ProjectCreationChatStep.industry:
        newIndustry = response;
        aiReplyText =
            "Great! You chose $newIndustry. Now, could you provide a brief description of your business idea?";
        nextStep = ProjectCreationChatStep.description;
        break;
      case ProjectCreationChatStep.description:
        newDescription = response;
        aiReplyText =
            "Awesome! Finally, what is your target funding goal (in \$)?";
        nextStep = ProjectCreationChatStep.fundingGoal;
        break;
      case ProjectCreationChatStep.fundingGoal:
        newFundingGoal = response;
        draft = _createDraft(newIndustry, newDescription, newFundingGoal);
        aiReplyText =
            "Thanks for the details! Based on our conversation, I have generated a project draft. Would you like to review and apply it to your new project configuration?";
        nextStep = ProjectCreationChatStep.done;
        break;
      case ProjectCreationChatStep.done:
        aiReplyText =
            "You can tap 'Apply to Project' below to use the generated configuration.";
        break;
    }

    final intermediateState = state.copyWith(
      currentStep: nextStep,
      industry: newIndustry,
      description: newDescription,
      fundingGoal: newFundingGoal,
      generatedDraft: draft,
    );

    final aiMsg = AiChatMessageModel(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      text: aiReplyText,
      isUser: false,
      timestamp: DateTime.now(),
      suggestions: intermediateState.currentSuggestions,
    );

    state = intermediateState.copyWith(
      messages: [...intermediateState.messages, aiMsg],
      isTyping: false,
    );
  }

  ProjectDraftModel _createDraft(
    String industry,
    String description,
    String fundingGoal,
  ) {
    return ProjectDraftModel(
      id: 'ai_draft_${DateTime.now().millisecondsSinceEpoch}',
      title: "AI Project: $industry Innovation",
      shortDesc: "AI-assisted business opportunity focusing on $description.",
      fullDesc:
          "Comprehensive operational blueprint for $description with projected revenue streams, key milestones, and verified financial forecasting.",
      fundingGoal: fundingGoal.replaceAll(RegExp(r'[^0-9]'), ''),
      minInvestment: "1000",
      targetRoi: "15",
      industry: industry,
      country: 'United States',
      fundingStage: 'Seed',
      timeline: '36 months',
      status: 'Ready for investment pipeline',
      milestones:
          'Q1: Prototype & MVP\nQ2: Pilot Customers\nQ3: Scale Operations',
      useOfFunds: '40% R&D, 30% Sales & Marketing, 20% Ops, 10% Reserve',
      sponsorInvestment: '250000',
      minContribution: '1000',
      expectedRoi: '15% annually',
      monthlyRevenue: '45000',
      holdPeriod: '3-5 years',
      timelineOps: 'Immediate deployment',
      teamMembers: 'Alex Vance (CEO), Maria Santos (CTO), David Chen (CFO)',
      ndaAgreement:
          'Standard confidential disclosure agreement required for detailed cap table and audit documents.',
      lastEdited: 'Generated by Damini Advisor',
    );
  }

  void clearChat() {
    state = ProjectCreationAiState(
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
      isTyping: false,
      currentStep: ProjectCreationChatStep.intro,
      industry: '',
      description: '',
      fundingGoal: '',
      generatedDraft: null,
    );
  }
}

final projectCreationAiProvider = NotifierProvider.autoDispose<
    ProjectCreationAiNotifier, ProjectCreationAiState>(
  ProjectCreationAiNotifier.new,
);
