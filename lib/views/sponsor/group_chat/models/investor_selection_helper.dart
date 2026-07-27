import 'package:flutter/material.dart';
import '../widgets/group_member_card.dart';

class InvestorSelectionHelper {
  InvestorSelectionHelper._();

  static const List<GroupMemberCardItem> mockInvestors = [
    GroupMemberCardItem(
      id: 'inv_dc',
      name: 'David Chen',
      role: 'Investor',
      offeredBudget: '\$200k',
      initials: 'DC',
      avatarBg: Color(0xFF006EDB),
    ),
    GroupMemberCardItem(
      id: 'inv_vp',
      name: 'Venture Partners LLC',
      role: 'VC Investor',
      offeredBudget: '\$400k',
      initials: 'VP',
      avatarBg: Color(0xFF7C3AED),
    ),
    GroupMemberCardItem(
      id: 'inv_sj',
      name: 'Sarah Jenkins',
      role: 'Angel Investor',
      offeredBudget: '\$150k',
      initials: 'SJ',
      avatarBg: Color(0xFFEC4899),
    ),
  ];

  static String calculateTotalBudget(List<GroupMemberCardItem> selected) {
    double total = 0;
    for (final inv in selected) {
      final raw = inv.offeredBudget.replaceAll('\$', '').trim();
      if (raw.toLowerCase().endsWith('k')) {
        final numStr = raw.substring(0, raw.length - 1);
        total += (double.tryParse(numStr) ?? 0) * 1000;
      } else if (raw.toLowerCase().endsWith('m')) {
        final numStr = raw.substring(0, raw.length - 1);
        total += (double.tryParse(numStr) ?? 0) * 1000000;
      } else {
        final numStr = raw.replaceAll(',', '');
        total += double.tryParse(numStr) ?? 0;
      }
    }

    if (total >= 1000000) {
      return '\$${(total / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
    } else if (total >= 1000) {
      return '\$${(total / 1000).toStringAsFixed(0)}k';
    }
    return '\$${total.toStringAsFixed(0)}';
  }
}
