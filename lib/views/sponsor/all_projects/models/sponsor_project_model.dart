enum SponsorProjectStatus { active, completed, terminated }

class SponsorProjectModel {
  final String id;
  final String title;
  final String description;
  final String badgeText;
  final String raisedAmount;
  final String goalAmount;
  final double progress;
  final String? imageUrl;
  final SponsorProjectStatus status;

  const SponsorProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.badgeText,
    required this.raisedAmount,
    required this.goalAmount,
    required this.progress,
    this.imageUrl,
    required this.status,
  });

  static List<SponsorProjectModel> mockActiveList() {
    const defaultSolarImage =
        'https://images.unsplash.com/photo-1509391365360-2e959784a276?q=80&w=800&auto=format&fit=crop';

    return const [
      SponsorProjectModel(
        id: '1',
        title: 'Downtown Tech Hub',
        description:
            'A state-of-the-art technology hub located in the heart of downtown Austin.',
        badgeText: 'Funding Active',
        raisedAmount: '1.2M',
        goalAmount: '5.0M',
        progress: 0.24,
        imageUrl: defaultSolarImage,
        status: SponsorProjectStatus.active,
      ),
      SponsorProjectModel(
        id: '2',
        title: 'Downtown Tech Hub',
        description:
            'A state-of-the-art technology hub located in the heart of downtown Austin.',
        badgeText: 'Funding Active',
        raisedAmount: '1.2M',
        goalAmount: '5.0M',
        progress: 0.24,
        imageUrl: defaultSolarImage,
        status: SponsorProjectStatus.active,
      ),
      SponsorProjectModel(
        id: '3',
        title: 'Downtown Tech Hub',
        description:
            'A state-of-the-art technology hub located in the heart of downtown Austin.',
        badgeText: 'Funding Active',
        raisedAmount: '1.2M',
        goalAmount: '5.0M',
        progress: 0.24,
        imageUrl: defaultSolarImage,
        status: SponsorProjectStatus.active,
      ),
    ];
  }

  static List<SponsorProjectModel> mockCompletedList() {
    return const [
      SponsorProjectModel(
        id: '4',
        title: 'EcoTech Solar Farm Phase 1',
        description:
            'Successfully funded 50MW solar panel installation project in West Texas.',
        badgeText: 'Completed',
        raisedAmount: '8.5M',
        goalAmount: '8.5M',
        progress: 1.0,
        imageUrl:
            'https://images.unsplash.com/photo-1466611653911-95081537e5b7?q=80&w=800&auto=format&fit=crop',
        status: SponsorProjectStatus.completed,
      ),
      SponsorProjectModel(
        id: '5',
        title: 'Green Grid Storage Initiative',
        description:
            'High-capacity energy storage battery grid project fully capitalized.',
        badgeText: 'Completed',
        raisedAmount: '3.0M',
        goalAmount: '3.0M',
        progress: 1.0,
        imageUrl:
            'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?q=80&w=800&auto=format&fit=crop',
        status: SponsorProjectStatus.completed,
      ),
    ];
  }

  static List<SponsorProjectModel> mockTerminatedList() {
    return const [
      SponsorProjectModel(
        id: '6',
        title: 'Old Wind Turbine Retrofit',
        description:
            'Project terminated due to municipal permit regulations and land reassignment.',
        badgeText: 'Terminated',
        raisedAmount: '400K',
        goalAmount: '2.0M',
        progress: 0.20,
        imageUrl:
            'https://images.unsplash.com/photo-1548337138-e87d889cc369?q=80&w=800&auto=format&fit=crop',
        status: SponsorProjectStatus.terminated,
      ),
    ];
  }
}
