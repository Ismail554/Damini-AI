import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../project_details/models/sponsor_project_details_model.dart';

class ConfirmInvestorModal extends StatefulWidget {
  final Function(InvestorContributionModel contribution) onConfirm;

  const ConfirmInvestorModal({
    super.key,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(InvestorContributionModel contribution) onConfirm,
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
  final TextEditingController _nameController =
      TextEditingController(text: 'David Chen');
  final TextEditingController _amountController =
      TextEditingController(text: '\$150,000');

  String _selectedType = 'Angel Investor';
  final List<String> _types = [
    'Angel Investor',
    'Venture Capital',
    'Private Equity',
    'Strategic Investor',
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h + bottomInset),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1E32),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
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
          SizedBox(height: 16.h),
          Text(
            'Mark & Confirm Investor',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Confirm investor budget to add to project contributions.',
            style: GoogleFonts.outfit(
              color: const Color(0xFF6B8A9D),
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 16.h),
          _buildLabel('Investor Name'),
          _buildTextField(_nameController, 'e.g. David Chen'),
          SizedBox(height: 14.h),
          _buildLabel('Investor Type'),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _types.map((t) {
              final isSelected = t == _selectedType;
              return GestureDetector(
                onTap: () => setState(() => _selectedType = t),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF006EDB)
                        : const Color(0xFF071424),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF006EDB)
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    t,
                    style: GoogleFonts.outfit(
                      color: isSelected ? Colors.white : const Color(0xFF6B8A9D),
                      fontSize: 11.5.sp,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 14.h),
          _buildLabel('Confirmed Investment Budget'),
          _buildTextField(_amountController, 'e.g. \$150,000'),
          SizedBox(height: 20.h),
          CustomButton(
            text: 'Confirm & Add Contribution',
            variant: CustomButtonVariant.gradient,
            onPressed: _handleConfirm,
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          color: const Color(0xFFE2E8F0),
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF071424),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: TextField(
        controller: ctrl,
        style: GoogleFonts.outfit(color: Colors.white, fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: const Color(0xFF6B8A9D)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  void _handleConfirm() {
    final name = _nameController.text.trim();
    final amount = _amountController.text.trim();
    if (name.isEmpty || amount.isEmpty) return;

    final contribution = InvestorContributionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: _selectedType,
      avatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=150&auto=format&fit=crop',
      amount: amount,
      date: 'Today',
      isFunded: true,
    );

    widget.onConfirm(contribution);
    Navigator.pop(context);
  }
}
