class NdaAgreementModel {
  final String title;
  final String disclosingParty;
  final String receivingParty;
  final String effectiveDate;
  final String confidentialityTerms;
  final String documentTitle;
  final String fileSize;
  final String? documentUrl;
  final List<String> customClauses;
  final bool isSigned;

  const NdaAgreementModel({
    required this.title,
    required this.disclosingParty,
    this.receivingParty = "Investor",
    required this.effectiveDate,
    required this.confidentialityTerms,
    required this.documentTitle,
    required this.fileSize,
    this.documentUrl,
    this.customClauses = const [],
    this.isSigned = false,
  });

  /// Backward compatibility getter
  String get summaryText => confidentialityTerms;

  factory NdaAgreementModel.fromJson(Map<String, dynamic> json) {
    String docName = "Pitch_Deck_Financials.pdf";
    String docSize = "2.4 MB";
    String? docUrl;

    if (json['pitch_deck_file'] is Map) {
      final fileMap = json['pitch_deck_file'] as Map;
      docName = fileMap['file_name']?.toString() ?? docName;
      docSize = fileMap['file_size']?.toString() ?? docSize;
      docUrl = fileMap['file_url']?.toString();
    } else if (json['pitch_deck'] != null) {
      docUrl = json['pitch_deck']?.toString();
      if (docUrl != null && docUrl.isNotEmpty) {
        docName = docUrl.split(RegExp(r'[\\/]')).last;
      }
    }

    final rawClauses = json['custom_clauses'];
    final clauses = <String>[];
    if (rawClauses is List) {
      for (final item in rawClauses) {
        if (item != null && item.toString().trim().isNotEmpty) {
          clauses.add(item.toString().trim());
        }
      }
    }

    return NdaAgreementModel(
      title: json['title']?.toString() ?? "Non-Disclosure Agreement",
      disclosingParty: json['disclosing_party']?.toString() ?? "Acme Holdings LLC",
      receivingParty: json['receiving_party']?.toString() ?? "Investor",
      effectiveDate: json['effective_date']?.toString() ?? "",
      confidentialityTerms: json['confidentiality_terms']?.toString() ??
          json['summary_text']?.toString() ??
          "This Non-Disclosure Agreement governs the disclosure of confidential and proprietary information between the parties.",
      documentTitle: docName,
      fileSize: docSize,
      documentUrl: docUrl,
      customClauses: clauses,
      isSigned: json['is_signed'] == true,
    );
  }

  NdaAgreementModel copyWith({
    String? title,
    String? disclosingParty,
    String? receivingParty,
    String? effectiveDate,
    String? confidentialityTerms,
    String? documentTitle,
    String? fileSize,
    String? documentUrl,
    List<String>? customClauses,
    bool? isSigned,
  }) {
    return NdaAgreementModel(
      title: title ?? this.title,
      disclosingParty: disclosingParty ?? this.disclosingParty,
      receivingParty: receivingParty ?? this.receivingParty,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      confidentialityTerms: confidentialityTerms ?? this.confidentialityTerms,
      documentTitle: documentTitle ?? this.documentTitle,
      fileSize: fileSize ?? this.fileSize,
      documentUrl: documentUrl ?? this.documentUrl,
      customClauses: customClauses ?? this.customClauses,
      isSigned: isSigned ?? this.isSigned,
    );
  }

  static NdaAgreementModel mockData([String disclosingParty = "Acme Corp"]) {
    return NdaAgreementModel(
      title: "Non-Disclosure Agreement",
      disclosingParty: disclosingParty,
      receivingParty: "Investor",
      effectiveDate: "October 24, 2024",
      confidentialityTerms:
          "This Non-Disclosure Agreement governs the disclosure of confidential and proprietary information between the parties. By signing below, you agree to keep all disclosed materials strictly confidential and use them solely for evaluation purposes.",
      documentTitle: "NDA_Standard_Terms.pdf",
      fileSize: "2.4 MB",
      documentUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
      isSigned: false,
    );
  }
}
