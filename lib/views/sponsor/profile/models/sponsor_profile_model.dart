import '../../../../core/constants/api_endpoints.dart';

class SponsorProfileData {
  final String name;
  final String title;
  final String avatarUrl;
  final String investedAmount;
  final String projectsCount;

  const SponsorProfileData({
    required this.name,
    required this.title,
    required this.avatarUrl,
    required this.investedAmount,
    required this.projectsCount,
  });

  factory SponsorProfileData.fromJson(Map<String, dynamic> json) {
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
      fullName = 'Shawn Blake';
    }

    final rawPhoto = profile['profile_photo']?.toString() ??
        data['profile_photo']?.toString() ??
        data['profile_image']?.toString() ??
        data['avatar']?.toString();

    String photoUrl =
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=250&auto=format&fit=crop";
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
                : 'Sponsor Partner'));

    final stats = data['stats'] is Map ? data['stats'] as Map : const {};
    final rawFunded = stats['funded'] ?? 0;
    final investedAmount = rawFunded != 0 ? '\$$rawFunded' : '\$0.00';
    final projectsCount = (stats['projects'] ?? 0).toString();

    return SponsorProfileData(
      name: fullName,
      title: title,
      avatarUrl: photoUrl,
      investedAmount: investedAmount,
      projectsCount: projectsCount,
    );
  }
}
