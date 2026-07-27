import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../project_details/models/sponsor_project_details_model.dart';
import '../models/investor_selection_helper.dart';
import 'group_member_card.dart';

class ConfirmInvestorModal extends StatefulWidget {
  final Function(List<InvestorContributionModel> contributions) onConfirm;

  const ConfirmInvestorModal({
    super.key,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(List<InvestorContributionModel> contributions) onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ConfirmInvestorModal(onConfirm: onConfirm),
    );
  }

  @override
  State<ConfirmInvestorModal> createState() => _ConfirmInvestorModalState();
}

class _ConfirmInvestorModalState extends State<ConfirmInvestorModal> {
  final Set<String> _selectedIds = {'inv_dc'};

  @override
  void initState() {
    super.initState();
    _loadCachedSelection();
  }

  Future<void> _loadCachedSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedIds = prefs.getStringList('cached_selected_investor_ids');
    if (cachedIds != null && cachedIds.isNotEmpty) {
      setState(() {
        _selectedIds.clear();
        _selectedIds.addAll(cachedIds);
      });
    }
  }

  Future<void> _saveCachedSelection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'cached_selected_investor_ids',
      _selectedIds.toList(),
    );
  }

  void _toggleInvestor(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        if (_selectedIds.length > 1) {
          _selectedIds.remove(id);
        }
      } else {
        _selectedIds.add(id);
      }
    });
    _saveCachedSelection();
  }

  @override
  Widget build(BuildContext context) {
    final investors = InvestorSelectionHelper.mockInvestors;
    final selected =
        investors.where((inv) => _selectedIds.contains(inv.id)).toList();
    final totalBudget = InvestorSelectionHelper.calculateTotalBudget(selected);

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1E32),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Confirm Group Investors',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF006EDB).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFF006EDB)),
                ),
                child: Text(
                  '${_selectedIds.length} Selected',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF00C6FF),
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Select investors to accept their offered budget for this project.',
            style: GoogleFonts.outfit(
              color: const Color(0xFF6B8A9D),
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 14.h),
          ...investors.map((inv) {
            return GroupMemberCard(
              member: inv,
              isSelected: _selectedIds.contains(inv.id),
              onTap: () => _toggleInvestor(inv.id),
            );
          }),
          SizedBox(height: 10.h),
          // Total Budget Summary Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFF071424),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Confirmed Budget:',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF6B8A9D),
                    fontSize: 13.sp,
                  ),
                ),
                Text(
                  totalBudget,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF10B981),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          CustomButton(
            text:
                'Confirm ${selected.length} Investor${selected.length > 1 ? 's' : ''} ($totalBudget)',
            variant: CustomButtonVariant.gradient,
            onPressed: () => _handleConfirm(selected),
          ),
        ],
      ),
    );
  }

  void _handleConfirm(List<GroupMemberCardItem> selected) {
    if (selected.isEmpty) return;
    _saveCachedSelection();
    final contributions = selected.map((inv) {
      return InvestorContributionModel(
        id: '${inv.id}_${DateTime.now().millisecondsSinceEpoch}',
        name: inv.name,
        type: inv.role,
        avatarUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=150&auto=format&fit=crop',
        amount: inv.offeredBudget,
        date: 'Today',
        isFunded: true,
      );
    }).toList();
    widget.onConfirm(contributions);
    Navigator.pop(context);
  }
}
