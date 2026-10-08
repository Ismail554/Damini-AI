import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../models/investor_chat_model.dart';
import '../repositories/investor_chat_repository.dart';

final investorChatRepositoryProvider = Provider<InvestorChatRepository>((ref) {
  return InvestorChatRepositoryImpl(ref.watch(apiServiceProvider));
});

class InvestorChatState {
  final bool isLoading;
  final String searchQuery;
  final List<InvestorChatItemModel> allChats;

  const InvestorChatState({
    this.isLoading = false,
    this.searchQuery = '',
    this.allChats = const [],
  });

  List<InvestorChatItemModel> get chats {
    if (searchQuery.trim().isEmpty) return allChats;
    final q = searchQuery.trim().toLowerCase();
    return allChats
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.lastMessage.toLowerCase().contains(q),
        )
        .toList();
  }

  InvestorChatState copyWith({
    bool? isLoading,
    String? searchQuery,
    List<InvestorChatItemModel>? allChats,
  }) {
    return InvestorChatState(
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      allChats: allChats ?? this.allChats,
    );
  }
}

final investorChatProvider =
    NotifierProvider<InvestorChatNotifier, InvestorChatState>(
  InvestorChatNotifier.new,
);

class InvestorChatNotifier extends Notifier<InvestorChatState> {
  @override
  InvestorChatState build() {
    loadChats();
    return const InvestorChatState(isLoading: true);
  }

  Future<void> loadChats() async {
    final repo = ref.read(investorChatRepositoryProvider);
    final chats = await repo.getChats();
    state = state.copyWith(isLoading: false, allChats: chats);
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearUnread(String chatId) {
    final updated = state.allChats.map((c) {
      if (c.id == chatId) {
        return InvestorChatItemModel(
          id: c.id,
          name: c.name,
          lastMessage: c.lastMessage,
          time: c.time,
          unreadCount: 0,
          avatarUrl: c.avatarUrl,
          isGroupChat: c.isGroupChat,
        );
      }
      return c;
    }).toList();
    state = state.copyWith(allChats: updated);
  }
}
