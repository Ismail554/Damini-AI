import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/controllers/sponsor_dashboard_provider.dart';
import '../models/create_project_models.dart';
import '../repositories/create_project_repository.dart';

class CreateProjectState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final String? createdProjectId;

  const CreateProjectState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.createdProjectId,
  });

  CreateProjectState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    String? createdProjectId,
    bool clearError = false,
  }) {
    return CreateProjectState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      createdProjectId: createdProjectId ?? this.createdProjectId,
    );
  }
}

class CreateProjectNotifier extends Notifier<CreateProjectState> {
  late final CreateProjectRepository _repository;

  @override
  CreateProjectState build() {
    _repository = ref.watch(createProjectRepositoryProvider);
    return const CreateProjectState();
  }

  Future<CreateProjectResponseModel> submitProject(
    CreateProjectRequestModel request,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);

    final result = await _repository.createProject(request);

    if (result.success) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        createdProjectId: result.projectId,
      );
      // Invalidate/refresh sponsor dashboard projects immediately (Workflow 7.3)
      try {
        await ref.read(sponsorDashboardProvider.notifier).refresh();
      } catch (_) {}
    } else {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: result.message,
      );
    }

    return result;
  }
}

final createProjectProvider =
    NotifierProvider<CreateProjectNotifier, CreateProjectState>(
  CreateProjectNotifier.new,
);
