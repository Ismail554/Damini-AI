import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/app_dimens.dart';
import '../../core/widgets/common_background.dart';
import 'saved/models/saved_item_model.dart';
import 'saved/widgets/saved_filter_modal.dart';
import 'saved/widgets/saved_header_row.dart';
import 'saved/widgets/saved_project_card.dart';
import 'saved/widgets/saved_stats_row.dart';

class SponsorSavedView extends StatefulWidget {
  const SponsorSavedView({super.key});

  @override
  State<SponsorSavedView> createState() => _SponsorSavedViewState();
}

class _SponsorSavedViewState extends State<SponsorSavedView> {
  String _selectedFilter = 'Active';

  void _onOpenFilterModal() async {
    final result = await SavedFilterModal.show(
      context,
      currentFilter: _selectedFilter,
    );
    if (result != null && mounted) {
      setState(() => _selectedFilter = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allItems = SavedItemModel.mockList();
    final filteredItems = allItems.where((item) {
      if (_selectedFilter.toLowerCase() == 'active') {
        return item.statusText.toLowerCase() == 'active' ||
            item.isPendingStatus;
      }
      return item.statusText.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();

    final sectionTitle = "$_selectedFilter projects";

    return CommonBackground(
      showGrid: false,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.screenHorizontal,
            vertical: AppDimens.screenVertical,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My Saved Items",
                style: GoogleFonts.outfit(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: AppDimens.spaceLg),
              const SavedStatsRow(),
              SizedBox(height: AppDimens.spaceXxl),
              SavedHeaderRow(
                title: sectionTitle,
                currentFilter: _selectedFilter,
                onFilterTap: _onOpenFilterModal,
              ),
              SizedBox(height: AppDimens.spaceMd),
              if (filteredItems.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Center(
                    child: Text(
                      "No $_selectedFilter projects found",
                      style: GoogleFonts.outfit(
                        fontSize: 14.sp,
                        color: const Color(0xFF6B8A9D),
                      ),
                    ),
                  ),
                )
              else
                ...filteredItems.map((item) => SavedProjectCard(item: item)),
              SizedBox(height: 80.h),
            ],
          ),
        ),
      ),
    );
  }
}
