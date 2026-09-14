import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl();
});

class HomeState {
  final int currentIndex;
  final int unreadCount;

  const HomeState({
    this.currentIndex = 0,
    this.unreadCount = 0,
  });

  HomeState copyWith({
    int? currentIndex,
    int? unreadCount,
  }) {
    return HomeState(
      currentIndex: currentIndex ?? this.currentIndex,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    return const HomeState();
  }

  void setTabIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  Future<void> fetchUnreadCount() async {
    final repo = ref.read(homeRepositoryProvider);
    final count = await repo.getUnreadNotificationCount();
    state = state.copyWith(unreadCount: count);
  }
}
