class IndustryModel {
  final int id;
  final String name;

  const IndustryModel({
    required this.id,
    required this.name,
  });

  factory IndustryModel.fromJson(Map<String, dynamic> json) {
    return IndustryModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class VerificationStatusModel {
  final String status;
  final String? message;

  const VerificationStatusModel({
    required this.status,
    this.message,
  });

  bool get isApproved => status.toUpperCase() == 'APPROVED';
  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isRejected => status.toUpperCase() == 'REJECTED';
  bool get isUnverified => status.toUpperCase() == 'UNVERIFIED';

  factory VerificationStatusModel.fromJson(Map<String, dynamic> json) {
    String parsedStatus = 'PENDING';
    if (json['data'] is Map && json['data']['verification_status'] != null) {
      parsedStatus = json['data']['verification_status'].toString();
    } else if (json['verification_status'] != null) {
      parsedStatus = json['verification_status'].toString();
    } else if (json['status'] != null) {
      parsedStatus = json['status'].toString();
    }
    return VerificationStatusModel(
      status: parsedStatus,
      message: json['message']?.toString(),
    );
  }
}

class OnboardingState {
  final String role; // 'investor' or 'sponsor'
  final String accountType; // 'INDIVIDUAL' or 'COMPANY'
  final String phone;
  final String country;
  final String location;
  final String? profilePhotoPath;
  final String? positionTitle;
  final String? legalCompanyName;
  final String? registrationNumber;
  final String? businessAddress;
  final String? companyWebsite;
  final List<int> selectedIndustryIds;
  final Map<String, String> uploadedDocuments; // type -> filePath
  final VerificationStatusModel? verificationStatus;
  final bool isLoading;
  final String? errorMessage;

  const OnboardingState({
    this.role = 'investor',
    this.accountType = 'INDIVIDUAL',
    this.phone = '',
    this.country = '',
    this.location = '',
    this.profilePhotoPath,
    this.positionTitle,
    this.legalCompanyName,
    this.registrationNumber,
    this.businessAddress,
    this.companyWebsite,
    this.selectedIndustryIds = const [],
    this.uploadedDocuments = const {},
    this.verificationStatus,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isCompany => accountType.toUpperCase() == 'COMPANY';

  OnboardingState copyWith({
    String? role,
    String? accountType,
    String? phone,
    String? country,
    String? location,
    String? profilePhotoPath,
    String? positionTitle,
    String? legalCompanyName,
    String? registrationNumber,
    String? businessAddress,
    String? companyWebsite,
    List<int>? selectedIndustryIds,
    Map<String, String>? uploadedDocuments,
    VerificationStatusModel? verificationStatus,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OnboardingState(
      role: role ?? this.role,
      accountType: accountType ?? this.accountType,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      location: location ?? this.location,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      positionTitle: positionTitle ?? this.positionTitle,
      legalCompanyName: legalCompanyName ?? this.legalCompanyName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      businessAddress: businessAddress ?? this.businessAddress,
      companyWebsite: companyWebsite ?? this.companyWebsite,
      selectedIndustryIds: selectedIndustryIds ?? this.selectedIndustryIds,
      uploadedDocuments: uploadedDocuments ?? this.uploadedDocuments,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
