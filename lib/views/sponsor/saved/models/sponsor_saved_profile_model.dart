import '../../../../core/constants/api_endpoints.dart';

class SponsorSavedProfileModel {
  final String id;
  final String userId;
  final String name;
  final String title;
  final String company;
  final String avatarUrl;
  final String location;
  final String role;
  final bool isSaved;
  final DateTime? createdAt;

  const SponsorSavedProfileModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.title,
    required this.company,
    required this.avatarUrl,
    required this.location,
    required this.role,
    this.isSaved = true,
    this.createdAt,
  });

  factory SponsorSavedProfileModel.fromJson(Map<String, dynamic> json) {
    // Check if target user is nested (e.g. { "id": 1, "user": { ... } } or { "saved_user": { ... } })
    final nestedUser = json['saved_user'] is Map
        ? Map<String, dynamic>.from(json['saved_user'] as Map)
        : (json['user'] is Map
            ? Map<String, dynamic>.from(json['user'] as Map)
            : const <String, dynamic>{});

    final nestedProfile = nestedUser['profile'] is Map
        ? Map<String, dynamic>.from(nestedUser['profile'] as Map)
        : (json['profile'] is Map
            ? Map<String, dynamic>.from(json['profile'] as Map)
            : const <String, dynamic>{});

    // ID of the saved bookmark record
    final id = json['id']?.toString() ??
        json['saved_id']?.toString() ??
        nestedUser['id']?.toString() ??
        '';

    // Target user ID
    final userId = json['user_id']?.toString() ??
        nestedUser['id']?.toString() ??
        id;

    // Name
    String name = json['name']?.toString() ??
        json['full_name']?.toString() ??
        '';
    if (name.trim().isEmpty && nestedUser.isNotEmpty) {
      final first = nestedUser['first_name']?.toString() ?? '';
      final last = nestedUser['last_name']?.toString() ?? '';
      name = '$first $last'.trim();
      if (name.isEmpty) {
        name = nestedUser['name']?.toString() ?? 'Member';
      }
    }
    if (name.isEmpty) name = 'Member';

    // Title / Designation
    String title = json['title']?.toString() ??
        json['designation']?.toString() ??
        nestedProfile['title']?.toString() ??
        nestedProfile['designation']?.toString() ??
        '';

    // Company
    String company = json['company']?.toString() ??
        json['company_name']?.toString() ??
        nestedProfile['company']?.toString() ??
        nestedProfile['legal_company_name']?.toString() ??
        '';

    // Location
    String location = json['location']?.toString() ?? '';
    if (location.trim().isEmpty && nestedProfile.isNotEmpty) {
      final city = nestedProfile['city']?.toString() ?? '';
      final country = nestedProfile['country']?.toString() ?? '';
      if (city.isNotEmpty && country.isNotEmpty) {
        location = '$city, $country';
      } else {
        location = city.isNotEmpty ? city : country;
      }
    }
    if (location.isEmpty) location = 'Not specified';

    // Role
    String role = json['role']?.toString() ??
        nestedUser['role']?.toString() ??
        'Investor';

    // Avatar URL
    final rawPhoto = json['avatar_url']?.toString() ??
        json['avatar']?.toString() ??
        json['photo']?.toString() ??
        nestedProfile['profile_photo']?.toString() ??
        nestedUser['avatar']?.toString();

    String avatarUrl = '';
    if (rawPhoto != null && rawPhoto.isNotEmpty && rawPhoto != 'null') {
      if (rawPhoto.startsWith('http://') || rawPhoto.startsWith('https://')) {
        avatarUrl = rawPhoto;
      } else {
        final base = ApiEndpoints.baseUrl.endsWith('/')
            ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
            : ApiEndpoints.baseUrl;
        final path = rawPhoto.startsWith('/') ? rawPhoto : '/$rawPhoto';
        avatarUrl = '$base$path';
      }
    }

    final isSavedVal = json['is_saved'];
    final isSaved = isSavedVal is bool
        ? isSavedVal
        : (isSavedVal != null ? isSavedVal.toString().toLowerCase() == 'true' : true);

    final createdAtStr = json['created_at']?.toString() ?? json['saved_at']?.toString();
    final createdAt = createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;

    return SponsorSavedProfileModel(
      id: id,
      userId: userId,
      name: name,
      title: title,
      company: company,
      avatarUrl: avatarUrl,
      location: location,
      role: role,
      isSaved: isSaved,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'title': title,
    'company': company,
    'avatar_url': avatarUrl,
    'location': location,
    'role': role,
    'is_saved': isSaved,
    'created_at': createdAt?.toIso8601String(),
  };

  SponsorSavedProfileModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? title,
    String? company,
    String? avatarUrl,
    String? location,
    String? role,
    bool? isSaved,
    DateTime? createdAt,
  }) {
    return SponsorSavedProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      title: title ?? this.title,
      company: company ?? this.company,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      location: location ?? this.location,
      role: role ?? this.role,
      isSaved: isSaved ?? this.isSaved,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static List<SponsorSavedProfileModel> mockList() {
    return const [
      SponsorSavedProfileModel(
        id: "pr1",
        userId: "pr1",
        name: "Sarah Jenkins",
        title: "Angel Investor",
        company: "Vanguard Investments",
        avatarUrl:
            "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&auto=format&fit=crop",
        location: "San Francisco, CA",
        role: "Investor",
      ),
      SponsorSavedProfileModel(
        id: "pr2",
        userId: "pr2",
        name: "Marcus Vance",
        title: "Venture Partner",
        company: "Apex Tech Ventures",
        avatarUrl:
            "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&auto=format&fit=crop",
        location: "Austin, TX",
        role: "Investor",
      ),
    ];
  }
}

class SavedProfilesResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<SponsorSavedProfileModel> results;

  const SavedProfilesResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory SavedProfilesResponse.fromJson(Map<String, dynamic> json) {
    final count = int.tryParse(json['count']?.toString() ?? '0') ?? 0;
    final next = json['next']?.toString();
    final previous = json['previous']?.toString();

    final resultsList = <SponsorSavedProfileModel>[];
    if (json['results'] is List) {
      for (final item in (json['results'] as List).whereType<Map>()) {
        try {
          resultsList.add(
            SponsorSavedProfileModel.fromJson(Map<String, dynamic>.from(item)),
          );
        } catch (_) {
          continue;
        }
      }
    }

    return SavedProfilesResponse(
      count: count > 0 ? count : resultsList.length,
      next: next,
      previous: previous,
      results: resultsList,
    );
  }
}
