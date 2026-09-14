import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_item_model.dart';
import '../repositories/chat_repository.dart';

class SponsorChatState {
  final List<ChatItemModel> allChats;
  final String searchQuery;
  final bool isLoading;

  const SponsorChatState({
    this.allChats = const [],
    this.searchQuery = '',
    this.isLoading = false,
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
  }) {
    return SponsorChatState(
      allChats: allChats ?? this.allChats,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SponsorChatNotifier extends Notifier<SponsorChatState> {
  late final ChatRepository _repository = ChatRepository();

  @override
  SponsorChatState build() {
    final chats = _repository.fetchChats();
    return SponsorChatState(
      allChats: chats,
      isLoading: false,
    );
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
    NotifierProvider.autoDispose<SponsorChatNotifier, SponsorChatState>(
  SponsorChatNotifier.new,
);
