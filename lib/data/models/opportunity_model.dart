class OpportunityModel {
  final String id;
  final String title;
  final String location;
  final String logoText;
  final String badgeText;
  final double minEntry;
  final String targetReturn;
  final int durationMonths;
  final double fundedPercentage;
  final bool hasExpressedInterest;
  final String category;

  OpportunityModel({
    required this.id,
    required this.title,
    required this.location,
    required this.logoText,
    required this.badgeText,
    required this.minEntry,
    required this.targetReturn,
    required this.durationMonths,
    required this.fundedPercentage,
    required this.hasExpressedInterest,
    required this.category,
  });

  OpportunityModel copyWith({
    String? id,
    String? title,
    String? location,
    String? logoText,
    String? badgeText,
    double? minEntry,
    String? targetReturn,
    int? durationMonths,
    double? fundedPercentage,
    bool? hasExpressedInterest,
    String? category,
  }) {
    return OpportunityModel(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      logoText: logoText ?? this.logoText,
      badgeText: badgeText ?? this.badgeText,
      minEntry: minEntry ?? this.minEntry,
      targetReturn: targetReturn ?? this.targetReturn,
      durationMonths: durationMonths ?? this.durationMonths,
      fundedPercentage: fundedPercentage ?? this.fundedPercentage,
      hasExpressedInterest: hasExpressedInterest ?? this.hasExpressedInterest,
      category: category ?? this.category,
    );
  }

  factory OpportunityModel.fromJson(Map<String, dynamic> json) {
    return OpportunityModel(
      id: json['id'] as String,
      title: json['title'] as String,
      location: json['location'] as String,
      logoText: json['logoText'] as String,
      badgeText: json['badgeText'] as String,
      minEntry: (json['minEntry'] as num).toDouble(),
      targetReturn: json['targetReturn'] as String,
      durationMonths: json['durationMonths'] as int,
      fundedPercentage: (json['fundedPercentage'] as num).toDouble(),
      hasExpressedInterest: json['hasExpressedInterest'] as bool? ?? false,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'logoText': logoText,
      'badgeText': badgeText,
      'minEntry': minEntry,
      'targetReturn': targetReturn,
      'durationMonths': durationMonths,
      'fundedPercentage': fundedPercentage,
      'hasExpressedInterest': hasExpressedInterest,
      'category': category,
    };
  }
}
