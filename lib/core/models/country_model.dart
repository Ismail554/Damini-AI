class CountryModel {
  final String name;
  final String code;
  final String flag;
  final String dialCode;

  const CountryModel({
    required this.name,
    required this.code,
    required this.flag,
    required this.dialCode,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      flag: json['flag']?.toString() ?? '',
      dialCode: json['dial_code']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'code': code,
        'flag': flag,
        'dial_code': dialCode,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryModel &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
