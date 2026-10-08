import 'dart:convert';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../models/investor_chat_model.dart';

abstract class InvestorChatRepository {
  Future<List<InvestorChatItemModel>> getChats();
}

class InvestorChatRepositoryImpl implements InvestorChatRepository {
  final ApiService? _apiService;

  InvestorChatRepositoryImpl([this._apiService]);

  @override
  Future<List<InvestorChatItemModel>> getChats() async {
    if (_apiService != null) {
      try {
        final response = await _apiService.get(
          ApiEndpoints.conversations,
          requireAuth: true,
        );

        dynamic data = response.data;
        if (data is String) {
          try {
            data = jsonDecode(data);
          } catch (_) {}
        }

        List list = [];
        if (data is List) {
          list = data;
        } else if (data is Map) {
          final payload = data['data'] is Map ? data['data'] as Map : data;
          if (payload['results'] is List) {
            list = payload['results'] as List;
          } else if (payload['data'] is List) {
            list = payload['data'] as List;
          } else if (payload['conversations'] is List) {
            list = payload['conversations'] as List;
          }
        }

        if (list.isNotEmpty) {
          final chats = <InvestorChatItemModel>[];
          for (final item in list.whereType<Map>()) {
            try {
              chats.add(
                InvestorChatItemModel.fromJson(Map<String, dynamic>.from(item)),
              );
            } catch (_) {}
          }
          if (chats.isNotEmpty) {
            return chats;
          }
        }
      } catch (_) {}
    }

    return const [
      InvestorChatItemModel(
        id: "chat_1",
        name: "Acme Investments (Lead Sponsor)",
        lastMessage: "The term sheet has been uploaded to the deal room.",
        time: "10:42 AM",
        unreadCount: 2,
        avatarUrl:
            "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150&auto=format&fit=crop",
      ),
      InvestorChatItemModel(
        id: "chat_2",
        name: "Downtown Tech Hub Syndicate",
        lastMessage: "Q1 investor call scheduled for this Thursday.",
        time: "Yesterday",
        unreadCount: 0,
        avatarUrl:
            "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=150&auto=format&fit=crop",
        isGroupChat: true,
      ),
      InvestorChatItemModel(
        id: "chat_3",
        name: "Marcus Vance (Deal Manager)",
        lastMessage: "Please review the updated risk assessment annex.",
        time: "Sep 12",
        unreadCount: 0,
        avatarUrl:
            "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=150&auto=format&fit=crop",
      ),
    ];
  }
}
