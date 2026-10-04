import '../../../../core/constants/api_endpoints.dart';

class InvestorProfileModel {
  final String name;
  final String title;
  final String avatarUrl;
  final String investedAmount;
  final String projectsCount;

  const InvestorProfileModel({
    this.name = "Member",
    this.title = "Angel Investor",
    this.avatarUrl = "",
    this.investedAmount = "\$0.00",
    this.projectsCount = "0",
  });

  factory InvestorProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    final profile = data['profile'] is Map
        ? Map<String, dynamic>.from(data['profile'] as Map)
        : const <String, dynamic>{};

    final first = (data['first_name']?.toString() ??
            profile['first_name']?.toString() ??
            '')
        .trim();
    final last = (data['last_name']?.toString() ??
            profile['last_name']?.toString() ??
            '')
        .trim();

    String capitalize(String s) =>
        s.isEmpty ? '' : '${s[0].toUpperCase()}${s.substring(1)}';

    String fullName = '';
    if (first.isNotEmpty && last.isNotEmpty) {
      fullName = '${capitalize(first)} ${capitalize(last)}';
    } else if (first.isNotEmpty) {
      fullName = capitalize(first);
    } else if (last.isNotEmpty) {
      fullName = capitalize(last);
    } else {
      fullName = 'Member';
    }

    final rawPhoto = profile['profile_photo']?.toString() ??
        data['profile_photo']?.toString() ??
        data['profile_image']?.toString() ??
        data['avatar']?.toString();

    String photoUrl = '';
    if (rawPhoto != null && rawPhoto != 'null' && rawPhoto.isNotEmpty) {
      if (rawPhoto.startsWith('http://') || rawPhoto.startsWith('https://')) {
        photoUrl = rawPhoto;
      } else {
        final base = ApiEndpoints.baseUrl.endsWith('/')
            ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
            : ApiEndpoints.baseUrl;
        final path = rawPhoto.startsWith('/') ? rawPhoto : '/$rawPhoto';
        photoUrl = '$base$path';
      }
    }

    final position = profile['position_title']?.toString() ?? '';
    final company = profile['legal_company_name']?.toString() ?? '';
    final title = (position.isNotEmpty && company.isNotEmpty)
        ? '$position at $company'
        : (position.isNotEmpty
            ? position
            : (company.isNotEmpty
                ? company
                : 'Angel Investor'));

    final stats = data['stats'] is Map ? data['stats'] as Map : const {};
    final rawFunded = stats['funded'] ?? 0;
    final investedAmount = rawFunded != 0 ? '\$$rawFunded' : '\$0.00';
    final projectsCount = (stats['projects'] ?? stats['requests'] ?? 0).toString();

    return InvestorProfileModel(
      name: fullName,
      title: title,
      avatarUrl: photoUrl,
      investedAmount: investedAmount,
      projectsCount: projectsCount,
    );
  }

  InvestorProfileModel copyWith({
    String? name,
    String? title,
    String? avatarUrl,
    String? investedAmount,
    String? projectsCount,
  }) {
    return InvestorProfileModel(
      name: name ?? this.name,
      title: title ?? this.title,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      investedAmount: investedAmount ?? this.investedAmount,
      projectsCount: projectsCount ?? this.projectsCount,
    );
  }
}
