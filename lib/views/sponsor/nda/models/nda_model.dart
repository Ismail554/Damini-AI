class NdaAgreementModel {
  final String title;
  final String disclosingParty;
  final String receivingParty;
  final String effectiveDate;
  final String documentTitle;
  final String fileSize;
  final String summaryText;
  final bool isSigned;

  const NdaAgreementModel({
    required this.title,
    required this.disclosingParty,
    required this.receivingParty,
    required this.effectiveDate,
    required this.documentTitle,
    required this.fileSize,
    required this.summaryText,
    this.isSigned = false,
  });

  static NdaAgreementModel mockData([String disclosingParty = "Acme Corp"]) {
    return NdaAgreementModel(
      title: "Non-Disclosure Agreement",
      disclosingParty: disclosingParty,
      receivingParty: "Investor",
      effectiveDate: "October 24, 2024",
      documentTitle: "NDA_Standard_Terms.pdf",
      fileSize: "2.4 MB",
      summaryText:
          "This Non-Disclosure Agreement governs the disclosure of confidential and proprietary information between the parties. By signing below, you agree to keep all disclosed materials strictly confidential and use them solely for evaluation purposes.",
      isSigned: false,
    );
  }
}
