import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/country_model.dart';
import '../services/country_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme_colors.dart';

class CountryPickerBottomSheet extends StatefulWidget {
  final String? selectedCountry;

  const CountryPickerBottomSheet({
    super.key,
    this.selectedCountry,
  });

  static Future<CountryModel?> show(
    BuildContext context, {
    String? selectedCountry,
  }) {
    return showModalBottomSheet<CountryModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CountryPickerBottomSheet(
        selectedCountry: selectedCountry,
      ),
    );
  }

  @override
  State<CountryPickerBottomSheet> createState() =>
      _CountryPickerBottomSheetState();
}

class _CountryPickerBottomSheetState extends State<CountryPickerBottomSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<CountryModel> _allCountries = [];
  List<CountryModel> _filteredCountries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCountries();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    final list = await CountryService.getCountries();
    if (!mounted) return;
    setState(() {
      _allCountries = list;
      _filteredCountries = list;
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = _allCountries;
      } else {
        _filteredCountries = _allCountries.where((c) {
          return c.name.toLowerCase().contains(query) ||
              c.code.toLowerCase().contains(query) ||
              c.dialCode.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: 0.85.sh,
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: tc.isDark ? const Color(0xFF0C1B2C) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(
          color: tc.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: tc.isDark ? Colors.white24 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),

          // Title & Close
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select Country",
                  style: GoogleFonts.outfit(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: tc.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: tc.isDark ? Colors.white10 : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18.r,
                      color: tc.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // Search Box
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              height: 46.h,
              decoration: BoxDecoration(
                color: tc.cardInner,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: tc.borderColor),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: GoogleFonts.outfit(
                  fontSize: 14.sp,
                  color: tc.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: "Search country or code...",
                  hintStyle: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    color: tc.textTertiary,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20.r,
                    color: tc.textTertiary,
                  ),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () => _searchCtrl.clear(),
                          child: Icon(
                            Icons.cancel_rounded,
                            size: 18.r,
                            color: tc.textTertiary,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Divider(color: tc.borderColor, height: 1),

          // Countries List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryColor,
                    ),
                  )
                : _filteredCountries.isEmpty
                    ? Center(
                        child: Text(
                          "No countries found",
                          style: GoogleFonts.outfit(
                            fontSize: 14.sp,
                            color: tc.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        itemCount: _filteredCountries.length,
                        separatorBuilder: (context, index) => Divider(
                          color: tc.borderColor.withValues(alpha: 0.3),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final item = _filteredCountries[index];
                          final isSelected = widget.selectedCountry != null &&
                              (item.name.toLowerCase() ==
                                      widget.selectedCountry!.trim().toLowerCase() ||
                                  item.code.toLowerCase() ==
                                      widget.selectedCountry!.trim().toLowerCase());

                          return InkWell(
                            onTap: () => Navigator.of(context).pop(item),
                            borderRadius: BorderRadius.circular(12.r),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 12.h,
                                horizontal: 8.w,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    item.flag,
                                    style: TextStyle(fontSize: 24.sp),
                                  ),
                                  SizedBox(width: 14.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: GoogleFonts.outfit(
                                            fontSize: 15.sp,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? AppColors.primaryColor
                                                : tc.textPrimary,
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          "${item.code} • ${item.dialCode}",
                                          style: GoogleFonts.outfit(
                                            fontSize: 12.sp,
                                            color: tc.textTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.primaryColor,
                                      size: 20.r,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
