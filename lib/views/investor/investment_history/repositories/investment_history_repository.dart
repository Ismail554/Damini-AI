import '../models/investment_record_model.dart';

abstract class InvestmentHistoryRepository {
  Future<List<InvestmentRecordModel>> getInvestmentRecords();
}

class InvestmentHistoryRepositoryImpl implements InvestmentHistoryRepository {
  @override
  Future<List<InvestmentRecordModel>> getInvestmentRecords() async {
    return const [
      InvestmentRecordModel(
        id: "inv_hist_1",
        title: "Downtown Tech Hub",
        category: "Real Estate",
        sponsor: "Acme Corp",
        date: "Mar 14, 2026",
        status: "Active",
        invested: "\$250,000",
        currentValue: "\$288,000",
        roi: "+15.2%",
        imageUrl:
            "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=300&auto=format&fit=crop",
      ),
      InvestmentRecordModel(
        id: "inv_hist_2",
        title: "AI Logistics Platform",
        category: "Tech",
        sponsor: "Nexus AI",
        date: "Feb 22, 2026",
        status: "Active",
        invested: "\$150,000",
        currentValue: "\$173,000",
        roi: "+15.3%",
        imageUrl:
            "https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=300&auto=format&fit=crop",
      ),
      InvestmentRecordModel(
        id: "inv_hist_3",
        title: "EcoTech Solar Farm",
        category: "Energy",
        sponsor: "Green Grid Ltd",
        date: "Jan 10, 2026",
        status: "Completed",
        invested: "\$100,000",
        currentValue: "\$118,500",
        roi: "+18.5%",
        imageUrl:
            "https://images.unsplash.com/photo-1509391365360-2e959784a276?q=80&w=300&auto=format&fit=crop",
      ),
      InvestmentRecordModel(
        id: "inv_hist_4",
        title: "AeroDynamics Drone Fleet",
        category: "Aviation",
        sponsor: "Sky Tech Ventures",
        date: "Nov 05, 2025",
        status: "Pending",
        invested: "\$60,000",
        currentValue: "\$64,700",
        roi: "+7.8%",
        imageUrl:
            "https://images.unsplash.com/photo-1508614589041-895b88991e3e?q=80&w=300&auto=format&fit=crop",
      ),
    ];
  }
}
