import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/country_model.dart';
import '../services/country_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme_colors.dart';
import 'country_picker_bottom_sheet.dart';

class CountryPickerField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<CountryModel>? onChanged;
  final String? Function(String?)? validator;

  const CountryPickerField({
    super.key,
    this.label = "Country",
    this.hint = "Select country",
    this.controller,
    this.initialValue,
    this.onChanged,
    this.validator,
  });

  @override
  State<CountryPickerField> createState() => _CountryPickerFieldState();
}

class _CountryPickerFieldState extends State<CountryPickerField> {
  CountryModel? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _initCountry();
    widget.controller?.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChange);
    super.dispose();
  }

  void _onControllerChange() {
    final text = widget.controller?.text;
    if (text != null && text != _selectedCountry?.name) {
      _resolveCountry(text);
    }
  }

  Future<void> _initCountry() async {
    final text = widget.controller?.text ?? widget.initialValue;
    if (text != null && text.isNotEmpty) {
      await _resolveCountry(text);
    }
  }

  Future<void> _resolveCountry(String nameOrCode) async {
    final country = await CountryService.findByName(nameOrCode) ??
        await CountryService.findByCode(nameOrCode);
    if (!mounted) return;
    setState(() => _selectedCountry = country);
  }

  Future<void> _handleTap() async {
    final current = widget.controller?.text ?? _selectedCountry?.name;
    final picked = await CountryPickerBottomSheet.show(
      context,
      selectedCountry: current,
    );
    if (picked != null && mounted) {
      setState(() => _selectedCountry = picked);
      if (widget.controller != null) {
        widget.controller!.text = picked.name;
      }
      widget.onChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final displayText = widget.controller?.text.isNotEmpty == true
        ? widget.controller!.text
        : (_selectedCountry?.name ?? '');

    return FormField<String>(
      validator: widget.validator != null
          ? (_) => widget.validator!(displayText)
          : null,
      builder: (fieldState) {
        final hasError = fieldState.hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.label,
              style: GoogleFonts.outfit(
                color: tc.textPrimary,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 6.h),
            InkWell(
              onTap: () async {
                await _handleTap();
                fieldState.didChange(widget.controller?.text ?? _selectedCountry?.name);
              },
              borderRadius: BorderRadius.circular(12.r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 50.h,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: tc.cardInner,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: hasError
                        ? AppColors.error
                        : tc.borderColor,
                    width: 1.w,
                  ),
                ),
                child: Row(
                  children: [
                    if (_selectedCountry != null)
                      Text(
                        _selectedCountry!.flag,
                        style: TextStyle(fontSize: 18.sp),
                      )
                    else
                      Icon(
                        Icons.public_rounded,
                        color: AppColors.grey,
                        size: 20.r,
                      ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        displayText.isNotEmpty ? displayText : widget.hint,
                        style: GoogleFonts.outfit(
                          fontSize: 14.sp,
                          color: displayText.isNotEmpty
                              ? tc.textPrimary
                              : tc.textTertiary,
                          fontWeight: displayText.isNotEmpty
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: tc.textSecondary,
                      size: 20.r,
                    ),
                  ],
                ),
              ),
            ),
            if (hasError) ...[
              SizedBox(height: 4.h),
              Padding(
                padding: EdgeInsets.only(left: 4.w),
                child: Text(
                  fieldState.errorText ?? '',
                  style: GoogleFonts.outfit(
                    color: AppColors.error,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
