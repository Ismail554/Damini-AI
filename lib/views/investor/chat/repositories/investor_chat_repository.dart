import '../models/investor_chat_model.dart';

abstract class InvestorChatRepository {
  Future<List<InvestorChatItemModel>> getChats();
}

class InvestorChatRepositoryImpl implements InvestorChatRepository {
  @override
  Future<List<InvestorChatItemModel>> getChats() async {
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
