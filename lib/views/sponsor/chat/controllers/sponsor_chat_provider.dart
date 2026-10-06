import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_item_model.dart';
import '../repositories/chat_repository.dart';

class SponsorChatState {
  final List<ChatItemModel> allChats;
  final String searchQuery;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;

  const SponsorChatState({
    this.allChats = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
  });

  List<ChatItemModel> get chats {
    if (searchQuery.isEmpty) return allChats;
    final query = searchQuery.toLowerCase();
    return allChats.where((chat) {
      return chat.name.toLowerCase().contains(query) ||
          chat.lastMessage.toLowerCase().contains(query);
    }).toList();
  }

  SponsorChatState copyWith({
    List<ChatItemModel>? allChats,
    String? searchQuery,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
  }) {
    return SponsorChatState(
      allChats: allChats ?? this.allChats,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
    );
  }
}

class SponsorChatNotifier extends Notifier<SponsorChatState> {
  late final ChatRepository _repository;

  @override
  SponsorChatState build() {
    _repository = ref.watch(chatRepositoryProvider);
    Future.microtask(() => loadConversations());
    return const SponsorChatState(isLoading: true);
  }

  Future<void> loadConversations({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(isRefreshing: true, error: null);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final conversations = await _repository.fetchConversations();
      final items = conversations
          .map((c) => ChatItemModel.fromConversation(c))
          .toList();

      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        allChats: items,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error:
            state.allChats.isEmpty ? 'Failed to load conversations: $e' : null,
      );
    }
  }

  Future<void> refresh() async {
    await loadConversations(isRefresh: true);
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearUnread(String chatId) {
    final updated = state.allChats.map((c) {
      if (c.id == chatId && c.unreadCount > 0) {
        return c.copyWith(unreadCount: 0);
      }
      return c;
    }).toList();
    state = state.copyWith(allChats: updated);
  }

  void updateLastMessage(String chatId, String message, String time) {
    final updated = state.allChats.map((c) {
      if (c.id == chatId) {
        return c.copyWith(lastMessage: message, time: time);
      }
      return c;
    }).toList();
    state = state.copyWith(allChats: updated);
  }
}

final sponsorChatProvider =
    NotifierProvider<SponsorChatNotifier, SponsorChatState>(
  SponsorChatNotifier.new,
);
