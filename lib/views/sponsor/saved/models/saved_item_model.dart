class SavedItemModel {
  final String id;
  final String title;
  final String category;
  final String date;
  final String statusText;
  final bool isPendingStatus;
  final String imageUrl;
  final String investedAmount;
  final String valueAmount;
  final String targetRoi;
  final String fundingProgressText;
  final double fundingProgressValue;

  const SavedItemModel({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.statusText,
    this.isPendingStatus = false,
    required this.imageUrl,
    required this.investedAmount,
    required this.valueAmount,
    required this.targetRoi,
    required this.fundingProgressText,
    required this.fundingProgressValue,
  });

  static List<SavedItemModel> mockList() {
    return const [
      SavedItemModel(
        id: 'saved_1',
        title: 'Downtown Tech Hub',
        category: 'Real Estate',
        date: 'Mar 14, 2026',
        statusText: 'Active',
        isPendingStatus: false,
        imageUrl:
            'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=300&auto=format&fit=crop',
        investedAmount: '\$250k',
        valueAmount: '\$288k',
        targetRoi: '+15.0%',
        fundingProgressText: '24%',
        fundingProgressValue: 0.24,
      ),
      SavedItemModel(
        id: 'saved_2',
        title: 'AI Logistics Platform',
        category: 'Tech',
        date: 'Feb 22, 2026',
        statusText: 'Active',
        isPendingStatus: false,
        imageUrl:
            'https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=300&auto=format&fit=crop',
        investedAmount: '\$150k',
        valueAmount: '\$173k',
        targetRoi: '+15.0%',
        fundingProgressText: '67%',
        fundingProgressValue: 0.67,
      ),
      SavedItemModel(
        id: 'saved_3',
        title: 'AI Logistics Platform',
        category: 'Tech',
        date: 'Feb 22, 2026',
        statusText: 'Pending',
        isPendingStatus: true,
        imageUrl:
            'https://images.unsplash.com/photo-1509391365360-2e959784a276?q=80&w=300&auto=format&fit=crop',
        investedAmount: '\$100k',
        valueAmount: '\$100k',
        targetRoi: '+15.0%',
        fundingProgressText: '44%',
        fundingProgressValue: 0.44,
      ),
      SavedItemModel(
        id: 'saved_4',
        title: 'EcoTech Solar Farm',
        category: 'Clean Energy',
        date: 'Jan 10, 2026',
        statusText: 'Completed',
        isPendingStatus: false,
        imageUrl:
            'https://images.unsplash.com/photo-1509391365360-2e959784a276?q=80&w=300&auto=format&fit=crop',
        investedAmount: '\$300k',
        valueAmount: '\$360k',
        targetRoi: '+20.0%',
        fundingProgressText: '100%',
        fundingProgressValue: 1.0,
      ),
      SavedItemModel(
        id: 'saved_5',
        title: 'BioMed Innovation Lab',
        category: 'Healthcare',
        date: 'Nov 05, 2025',
        statusText: 'Terminated',
        isPendingStatus: false,
        imageUrl:
            'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?q=80&w=300&auto=format&fit=crop',
        investedAmount: '\$50k',
        valueAmount: '\$50k',
        targetRoi: '0.0%',
        fundingProgressText: '12%',
        fundingProgressValue: 0.12,
      ),
    ];
  }
}
