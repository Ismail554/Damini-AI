class CompanyUploadedDoc {
  final int id;
  final String documentType;
  final String fileUrl;
  final String fileName;
  final DateTime? createdAt;

  const CompanyUploadedDoc({
    required this.id,
    required this.documentType,
    required this.fileUrl,
    required this.fileName,
    this.createdAt,
  });

  factory CompanyUploadedDoc.fromJson(Map<String, dynamic> json) {
    final url = json['file']?.toString() ?? json['file_url']?.toString() ?? '';
    String name = 'Document';
    if (url.isNotEmpty) {
      name = url.split(RegExp(r'[\\/]')).last;
    }
    return CompanyUploadedDoc(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      documentType: json['document_type']?.toString() ?? '',
      fileUrl: url,
      fileName: name,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}

class CompanyVerificationModel {
  final String companyName;
  final String registrationNumber;
  final String address;
  final String website;
  final String? businessLicensePath;
  final String? taxDocumentPath;
  final String status;
  final String? rejectionReason;
  final List<CompanyUploadedDoc> documents;

  const CompanyVerificationModel({
    this.companyName = '',
    this.registrationNumber = '',
    this.address = '',
    this.website = '',
    this.businessLicensePath,
    this.taxDocumentPath,
    this.status = 'PENDING',
    this.rejectionReason,
    this.documents = const [],
  });

  factory CompanyVerificationModel.fromJson(Map<String, dynamic> json) {
    final rawDocs = json['documents'];
    final docList = <CompanyUploadedDoc>[];
    if (rawDocs is List) {
      for (final item in rawDocs.whereType<Map>()) {
        try {
          docList.add(CompanyUploadedDoc.fromJson(Map<String, dynamic>.from(item)));
        } catch (_) {}
      }
    }

    String? bizLicPath;
    String? taxDocPath;

    for (final doc in docList) {
      final type = doc.documentType.toUpperCase();
      if (type.contains('LICENSE') || type.contains('REGISTRATION')) {
        bizLicPath ??= doc.fileName;
      } else if (type.contains('TAX')) {
        taxDocPath ??= doc.fileName;
      }
    }

    return CompanyVerificationModel(
      companyName: json['company_name']?.toString() ?? '',
      registrationNumber: json['registration_number']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
      status: json['status']?.toString().toUpperCase() ??
          json['verification_status']?.toString().toUpperCase() ??
          'PENDING',
      rejectionReason: json['rejection_reason']?.toString(),
      documents: docList,
      businessLicensePath: bizLicPath,
      taxDocumentPath: taxDocPath,
    );
  }

  CompanyVerificationModel copyWith({
    String? companyName,
    String? registrationNumber,
    String? address,
    String? website,
    String? businessLicensePath,
    String? taxDocumentPath,
    String? status,
    String? rejectionReason,
    List<CompanyUploadedDoc>? documents,
  }) {
    return CompanyVerificationModel(
      companyName: companyName ?? this.companyName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      address: address ?? this.address,
      website: website ?? this.website,
      businessLicensePath: businessLicensePath ?? this.businessLicensePath,
      taxDocumentPath: taxDocumentPath ?? this.taxDocumentPath,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      documents: documents ?? this.documents,
    );
  }
}
