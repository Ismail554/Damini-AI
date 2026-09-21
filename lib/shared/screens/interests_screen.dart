import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../views/role_selection/models/onboarding_models.dart';
import '../../views/role_selection/provider/onboarding_provider.dart';

class InterestsScreen extends ConsumerStatefulWidget {
  final String role;
  final ValueChanged<List<int>> onNext;
  final VoidCallback onBack;
  final bool isLoading;

  const InterestsScreen({
    super.key,
    required this.role,
    required this.onNext,
    required this.onBack,
    this.isLoading = false,
  });

  @override
  ConsumerState<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends ConsumerState<InterestsScreen> {
  final Set<int> _selectedIds = {};

  static const List<Map<String, dynamic>> _fallbackIndustries = [
    {'id': 1, 'name': 'Technology', 'icon': Icons.memory_rounded},
    {'id': 2, 'name': 'Real Estate', 'icon': Icons.home_work_outlined},
    {'id': 3, 'name': 'Healthcare', 'icon': Icons.favorite_outline_rounded},
    {'id': 4, 'name': 'Clean Energy', 'icon': Icons.bolt_rounded},
    {'id': 5, 'name': 'Agriculture', 'icon': Icons.eco_outlined},
    {'id': 6, 'name': 'Infrastructure', 'icon': Icons.location_city_outlined},
  ];

  IconData _getIconForIndustry(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tech')) return Icons.memory_rounded;
    if (lower.contains('estate') || lower.contains('property')) return Icons.home_work_outlined;
    if (lower.contains('health') || lower.contains('bio')) return Icons.favorite_outline_rounded;
    if (lower.contains('energy') || lower.contains('power')) return Icons.bolt_rounded;
    if (lower.contains('agri') || lower.contains('food')) return Icons.eco_outlined;
    if (lower.contains('infra') || lower.contains('construct')) return Icons.location_city_outlined;
    if (lower.contains('fin')) return Icons.account_balance_rounded;
    return Icons.domain_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final industriesAsync = ref.watch(industriesProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          ),
          SizedBox(height: 16.h),
          Text(
            "Select Interests",
            style: GoogleFonts.outfit(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "Choose sectors you want to explore or fund.",
            style: GoogleFonts.outfit(
              fontSize: 14.sp,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 24.h),
          Expanded(
            child: industriesAsync.when(
              data: (industries) {
                final list = industries.isNotEmpty
                    ? industries
                    : _fallbackIndustries
                        .map((m) => IndustryModel(id: m['id'] as int, name: m['name'] as String))
                        .toList();
                return _buildGrid(list);
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF006EDB)),
              ),
              error: (error, stack) {
                final fallbackList = _fallbackIndustries
                    .map((m) => IndustryModel(id: m['id'] as int, name: m['name'] as String))
                    .toList();
                return _buildGrid(fallbackList);
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: (_selectedIds.isNotEmpty && !widget.isLoading)
                  ? () => widget.onNext(_selectedIds.toList())
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006EDB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26.r)),
              ),
              child: widget.isLoading
                  ? SizedBox(
                      width: 22.r,
                      height: 22.r,
                      child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      _selectedIds.isNotEmpty
                          ? "Continue (${_selectedIds.length})"
                          : "Select Interests to Continue",
                      style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildGrid(List<IndustryModel> items) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14.w,
        mainAxisSpacing: 14.h,
        childAspectRatio: 1.3,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = _selectedIds.contains(item.id);
        final icon = _getIconForIndustry(item.name);

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
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF006EDB) : const Color(0xFF0C1B2C).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected ? Colors.white.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.08),
                width: 1.w,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.white, size: 28.r),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded, color: Colors.white, size: 18.r),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
