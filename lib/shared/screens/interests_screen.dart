import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/widgets/custom_snackbar.dart';
import '../../views/role_selection/models/onboarding_models.dart';
import '../../views/role_selection/provider/onboarding_provider.dart';

class InterestsScreen extends ConsumerStatefulWidget {
  final String role;
  final ValueChanged<List<int>> onNext;
  final VoidCallback onBack;
  final bool isLoading;
  final int step;
  final int totalSteps;

  const InterestsScreen({
    super.key,
    required this.role,
    required this.onNext,
    required this.onBack,
    this.isLoading = false,
    this.step = 4,
    this.totalSteps = 4,
  });

  @override
  ConsumerState<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends ConsumerState<InterestsScreen> {
  final Set<int> _selectedIds = {};

  static const List<Map<String, dynamic>> _staticIndustries = [
    {'id': 1, 'name': 'Real Estate'},
    {'id': 2, 'name': 'Agriculture & Agri-processing'},
    {'id': 3, 'name': 'Technology & AI'},
    {'id': 4, 'name': 'Fintech & Financial Services'},
    {'id': 5, 'name': 'Renewable Energy & Climate Tech'},
    {'id': 6, 'name': 'Mining & Minerals'},
    {'id': 7, 'name': 'Healthcare & Healthtech'},
    {'id': 8, 'name': 'Tourism & Hospitality'},
    {'id': 9, 'name': 'Manufacturing & Industrial'},
    {'id': 10, 'name': 'TV & Film'},
    {'id': 11, 'name': 'Infrastructure & Logistics'},
    {'id': 12, 'name': 'Food & Beverage'},
    {'id': 13, 'name': 'Cannabis & Hemp'},
    {'id': 14, 'name': 'Retail & E-commerce'},
    {'id': 15, 'name': 'Water & Sanitation'},
    {'id': 16, 'name': 'Transportation'},
    {'id': 17, 'name': 'General/Other'},
  ];

  List<IndustryModel> _mergeIndustries(List<IndustryModel> apiIndustries) {
    final result = <IndustryModel>[];
    final matchedApiIds = <int>{};

    for (final staticItem in _staticIndustries) {
      final sId = staticItem['id'] as int;
      final sName = staticItem['name'] as String;

      final match = apiIndustries.firstWhere(
        (api) {
          final apiLower = api.name.trim().toLowerCase();
          final staticLower = sName.trim().toLowerCase();
          return apiLower == staticLower ||
              (apiLower.isNotEmpty && staticLower.contains(apiLower)) ||
              (staticLower.isNotEmpty && apiLower.contains(staticLower));
        },
        orElse: () => const IndustryModel(id: -1, name: ''),
      );

      if (match.id != -1) {
        result.add(IndustryModel(id: match.id, name: sName));
        matchedApiIds.add(match.id);
      } else {
        result.add(IndustryModel(id: sId, name: sName));
      }
    }

    for (final api in apiIndustries) {
      if (!matchedApiIds.contains(api.id) &&
          !result.any((r) => r.id == api.id || r.name.toLowerCase() == api.name.toLowerCase())) {
        result.add(api);
      }
    }

    return result;
  }

  void _handleContinue() {
    if (_selectedIds.isEmpty) {
      CustomSnackBar.show(
        context,
        "Please select at least one interest to continue.",
        isError: true,
      );
      return;
    }
    widget.onNext(_selectedIds.toList());
  }

  @override
  Widget build(BuildContext context) {
    final industriesAsync = ref.watch(industriesProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step & Navigation header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: widget.onBack,
                behavior: HitTestBehavior.opaque,
                child: Text(
                  "Back",
                  style: GoogleFonts.outfit(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                "Step ${widget.step} of ${widget.totalSteps}",
                style: GoogleFonts.outfit(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Segmented progress bars
          Row(
            children: List.generate(widget.totalSteps, (index) {
              final isFilled = index < widget.step;
              return Expanded(
                child: Container(
                  height: 4.h,
                  margin: EdgeInsets.only(
                    right: index < widget.totalSteps - 1 ? 6.w : 0,
                  ),
                  decoration: BoxDecoration(
                    color: isFilled
                        ? const Color(0xFF006EDB)
                        : Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 24.h),

          // Scrollable content area: Headings and Wrap pills
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "What industries interest you?",
                    style: GoogleFonts.outfit(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Pick as many as you like we'll tailor your feed.",
                    style: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      color: Colors.white.withValues(alpha: 0.65),
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 22.h),

                  industriesAsync.when(
                    data: (apiIndustries) {
                      final items = _mergeIndustries(apiIndustries);
                      return _buildPillWrap(items);
                    },
                    loading: () {
                      final items = _staticIndustries
                          .map((m) => IndustryModel(id: m['id'] as int, name: m['name'] as String))
                          .toList();
                      return _buildPillWrap(items);
                    },
                    error: (_, _) {
                      final items = _staticIndustries
                          .map((m) => IndustryModel(id: m['id'] as int, name: m['name'] as String))
                          .toList();
                      return _buildPillWrap(items);
                    },
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),

          // Bottom counter and Finish & continue button
          Text(
            "${_selectedIds.length} selected",
            style: GoogleFonts.outfit(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 16.h),

          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _handleContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006EDB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26.r),
                ),
                elevation: 0,
              ),
              child: widget.isLoading
                  ? SizedBox(
                      width: 22.r,
                      height: 22.r,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      "Finish & continue",
                      style: GoogleFonts.outfit(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildPillWrap(List<IndustryModel> items) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 12.h,
      children: items.map((item) {
        final isSelected = _selectedIds.contains(item.id);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedIds.remove(item.id);
              } else {
                _selectedIds.add(item.id);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 11.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF006EDB)
                  : const Color(0xFF0C1B2C).withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF006EDB)
                    : Colors.white.withValues(alpha: 0.25),
                width: 1.w,
              ),
            ),
            child: Text(
              item.name,
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
