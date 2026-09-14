class CompanyVerificationModel {
  final String companyName;
  final String registrationNumber;
  final String address;
  final String website;
  final String? businessLicensePath;
  final String? taxDocumentPath;
  final String status;

  const CompanyVerificationModel({
    this.companyName = '',
    this.registrationNumber = '',
    this.address = '',
    this.website = '',
    this.businessLicensePath,
    this.taxDocumentPath,
    this.status = 'unverified',
  });

  CompanyVerificationModel copyWith({
    String? companyName,
    String? registrationNumber,
    String? address,
    String? website,
    String? businessLicensePath,
    String? taxDocumentPath,
    String? status,
  }) {
    return CompanyVerificationModel(
      companyName: companyName ?? this.companyName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      address: address ?? this.address,
      website: website ?? this.website,
      businessLicensePath: businessLicensePath ?? this.businessLicensePath,
      taxDocumentPath: taxDocumentPath ?? this.taxDocumentPath,
      status: status ?? this.status,
    );
  }
}
