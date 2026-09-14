import '../models/investor_saved_item_model.dart';

abstract class InvestorSavedRepository {
  Future<List<InvestorSavedItemModel>> getSavedItems();
}

class InvestorSavedRepositoryImpl implements InvestorSavedRepository {
  @override
  Future<List<InvestorSavedItemModel>> getSavedItems() async {
    return const [
      InvestorSavedItemModel(
        id: "inv_saved_1",
        title: "Downtown Tech Hub",
        category: "Real Estate",
        date: "Feb 22, 2026",
        status: "Active",
        invested: "\$250k",
        value: "\$288k",
        targetRoi: "+15.0%",
        fundingProgress: 0.24,
        imageUrl:
            "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=300&auto=format&fit=crop",
      ),
      InvestorSavedItemModel(
        id: "inv_saved_2",
        title: "AI Logistics Platform",
        category: "Tech",
        date: "Feb 22, 2026",
        status: "Active",
        invested: "\$150k",
        value: "\$173k",
        targetRoi: "+15.0%",
        fundingProgress: 0.67,
        imageUrl:
            "https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=300&auto=format&fit=crop",
      ),
      InvestorSavedItemModel(
        id: "inv_saved_3",
        title: "EcoTech Solar Farm",
        category: "Energy",
        date: "Feb 22, 2026",
        status: "Pending",
        invested: "\$100k",
        value: "\$100k",
        targetRoi: "+15.0%",
        fundingProgress: 0.44,
        imageUrl:
            "https://images.unsplash.com/photo-1509391365360-2e959784a276?q=80&w=300&auto=format&fit=crop",
      ),
      InvestorSavedItemModel(
        id: "inv_saved_4",
        title: "BioMed Research Lab",
        category: "Healthcare",
        date: "Jan 10, 2026",
        status: "Active",
        invested: "\$400k",
        value: "\$520k",
        targetRoi: "+18.5%",
        fundingProgress: 0.85,
        imageUrl:
            "https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?q=80&w=300&auto=format&fit=crop",
      ),
    ];
  }
}
