import '../../../../core/constants/api_endpoints.dart';

class GroupChatHeaderModel {
  final int conversationId;
  final int projectId;
  final String projectTitle;
  final bool isOwner;
  final bool isActive;
  final int activeMemberCount;
  final List<GroupChatParticipant> participants;

  const GroupChatHeaderModel({
    required this.conversationId,
    required this.projectId,
    required this.projectTitle,
    required this.isOwner,
    this.isActive = true,
    required this.activeMemberCount,
    required this.participants,
  });

  factory GroupChatHeaderModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;

    final convId = int.tryParse(data['conversation_id']?.toString() ?? '') ?? 0;
    final projId = int.tryParse(data['project_id']?.toString() ?? '') ?? 0;
    final title = data['project_title']?.toString() ?? '';
    final owner = data['is_owner'] == true;
    final active = data['is_active'] != false;
    final count = int.tryParse(data['active_member_count']?.toString() ?? '') ?? 0;

    final rawParticipants = data['participants'] as List? ?? [];
    final participantsList = rawParticipants
        .whereType<Map>()
        .map((p) => GroupChatParticipant.fromJson(Map<String, dynamic>.from(p)))
        .toList();

    return GroupChatHeaderModel(
      conversationId: convId,
      projectId: projId,
      projectTitle: title,
      isOwner: owner,
      isActive: active,
      activeMemberCount: count > 0 ? count : participantsList.length,
      participants: participantsList,
    );
  }
}

class GroupChatParticipant {
  final int userId;
  final String name;
  final String role;
  final bool isOwner;
  final String? avatarUrl;
  final String initials;

  const GroupChatParticipant({
    required this.userId,
    required this.name,
    required this.role,
    required this.isOwner,
    this.avatarUrl,
    required this.initials,
  });

  factory GroupChatParticipant.fromJson(Map<String, dynamic> json) {
    final uId = int.tryParse(json['user_id']?.toString() ?? '') ?? 0;
    final pName = json['name']?.toString() ?? '';
    final pRole = json['role']?.toString() ?? '';
    final owner = json['is_owner'] == true;

    String? avatar = json['avatar_url']?.toString();
    if (avatar != null && avatar.isNotEmpty && !avatar.startsWith('http')) {
      final base = ApiEndpoints.baseUrl.replaceAll(RegExp(r'/+$'), '');
      final path = avatar.startsWith('/') ? avatar : '/$avatar';
      avatar = '$base$path';
    }

    String initials = json['initials']?.toString() ?? '';
    if (initials.isEmpty && pName.isNotEmpty) {
      final parts = pName.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initials = pName.substring(0, pName.length >= 2 ? 2 : 1).toUpperCase();
      }
    }

    return GroupChatParticipant(
      userId: uId,
      name: pName,
      role: pRole,
      isOwner: owner,
      avatarUrl: avatar,
      initials: initials,
    );
  }
}
