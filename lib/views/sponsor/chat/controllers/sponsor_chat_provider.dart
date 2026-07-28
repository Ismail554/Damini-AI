import 'package:flutter/material.dart';
import '../models/chat_item_model.dart';
import '../repositories/chat_repository.dart';

class SponsorChatProvider extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();

  List<ChatItemModel> _allChats = [];
  String _searchQuery = '';
  bool _isLoading = false;

  List<ChatItemModel> get chats {
    if (_searchQuery.isEmpty) return _allChats;
    final query = _searchQuery.toLowerCase();
    return _allChats.where((chat) {
      return chat.name.toLowerCase().contains(query) ||
          chat.lastMessage.toLowerCase().contains(query);
    }).toList();
  }

  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  void init() {
    _isLoading = true;
    notifyListeners();
    _allChats = _repository.fetchChats();
    _isLoading = false;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearUnread(String chatId) {
    final index = _allChats.indexWhere((c) => c.id == chatId);
    if (index != -1 && _allChats[index].unreadCount > 0) {
      _allChats[index] = _allChats[index].copyWith(unreadCount: 0);
      notifyListeners();
    }
  }

  void updateLastMessage(String chatId, String message, String time) {
    final index = _allChats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      _allChats[index] = _allChats[index].copyWith(
        lastMessage: message,
        time: time,
      );
      notifyListeners();
    }
  }
}
