import 'package:flutter_test/flutter_test.dart';
import 'package:Braintech/views/investor/dashboard/models/investor_dashboard_models.dart';
import 'package:Braintech/views/investor/discover/models/discover_deal_model.dart';
import 'package:Braintech/views/investor/investment_history/models/investment_record_model.dart';
import 'package:Braintech/views/investor/saved/models/investor_saved_item_model.dart';
import 'package:Braintech/views/investor/chat/models/investor_chat_model.dart';

void main() {
  group('Investor Module Models & Serialization Tests', () {
    test('InvestorBannerModel deserializes from API JSON correctly', () {
      final json = {
        "id": "banner_101",
        "title": "Prime Commercial Real Estate",
        "location": "Spain",
        "target_raise": "\$12.5M",
        "subtitle": "Institutional grade assets.",
        "tag": "Featured",
        "bg_gradient": ["#1E162D", "#2A1C3D"],
        "image_url": "https://example.com/banner.png",
        "action_text": "View Assets",
        "target_project_id": "proj_9988"
      };

      final banner = InvestorBannerModel.fromJson(json);

      expect(banner.id, "banner_101");
      expect(banner.title, "Prime Commercial Real Estate");
      expect(banner.location, "Spain");
      expect(banner.targetRaise, "\$12.5M");
      expect(banner.targetProjectId, "proj_9988");
      expect(banner.actionText, "View Assets");
    });

    test('DiscoverDealItem deserializes from discover API JSON correctly', () {
      final json = {
        "id": "proj_9876",
        "title": "Downtown Tech Hub",
        "location": "United States",
        "category": "Real Estate",
        "funding_goal": 5000000,
        "raised_amount": 3750000,
        "min_investment": 1000,
        "target_roi": "~ 18%",
        "days_left": 14,
        "image_url": "https://example.com/proj.png"
      };

      final deal = DiscoverDealItem.fromJson(json);

      expect(deal.id, "proj_9876");
      expect(deal.title, "Downtown Tech Hub");
      expect(deal.category, "Real Estate");
      expect(deal.targetRaise, "\$5.0M");
      expect(deal.minInvestment, "\$1K");
      expect(deal.fundedPercent, 0.75);
      expect(deal.daysLeft, 14);
    });

    test('InvestmentPortfolioSummary and InvestmentRecordModel deserialize correctly', () {
      final summaryJson = {
        "total_invested": "\$560,000",
        "total_current_value": "\$644,200",
        "total_profit_loss": "+\$84,200 (+15.0%)",
        "active_deals_count": 4
      };

      final summary = InvestmentPortfolioSummary.fromJson(summaryJson);
      expect(summary.totalInvested, "\$560,000");
      expect(summary.totalCurrentValue, "\$644,200");
      expect(summary.activeDealsCount, 4);

      final recordJson = {
        "id": "inv_101",
        "project_id": "proj_9876",
        "title": "Downtown Tech Hub",
        "category": "Real Estate",
        "sponsor_name": "Acme Corp",
        "formatted_date": "Mar 14, 2026",
        "status": "Active",
        "formatted_invested": "\$250,000",
        "formatted_current_value": "\$288,000",
        "roi": "+15.2%"
      };

      final record = InvestmentRecordModel.fromJson(recordJson);
      expect(record.id, "inv_101");
      expect(record.sponsor, "Acme Corp");
      expect(record.status, "Active");
      expect(record.invested, "\$250,000");
      expect(record.currentValue, "\$288,000");
    });

    test('InvestorSavedItemModel and InvestorChatItemModel deserialize correctly', () {
      final savedJson = {
        "id": "proj_9876",
        "title": "Downtown Tech Hub",
        "category": "Real Estate",
        "saved_date": "Feb 22, 2026",
        "status": "Active",
        "invested": "\$250k",
        "value": "\$288k",
        "target_roi": "+15.0%",
        "funding_progress": 0.24
      };

      final saved = InvestorSavedItemModel.fromJson(savedJson);
      expect(saved.id, "proj_9876");
      expect(saved.title, "Downtown Tech Hub");
      expect(saved.fundingProgress, 0.24);
      expect(saved.isActive, isTrue);

      final chatJson = {
        "id": "conv_123",
        "name": "Acme Investments",
        "last_message": "Term sheet updated",
        "time": "10:42 AM",
        "unread_count": 2,
        "is_group_chat": false
      };

      final chat = InvestorChatItemModel.fromJson(chatJson);
      expect(chat.id, "conv_123");
      expect(chat.name, "Acme Investments");
      expect(chat.unreadCount, 2);
      expect(chat.isGroupChat, isFalse);
    });
  });
}
