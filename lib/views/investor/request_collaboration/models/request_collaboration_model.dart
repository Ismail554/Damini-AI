class CollaborationSubmissionModel {
  final String projectId;
  final String amount;
  final String note;
  final String investorType;

  const CollaborationSubmissionModel({
    required this.projectId,
    required this.amount,
    required this.note,
    this.investorType = "Angel Investor",
  });

  Map<String, dynamic> toJson() => {
        'project_id': projectId,
        'amount': amount,
        'note': note,
        'investor_type': investorType,
      };
}
