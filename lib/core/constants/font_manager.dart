import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FontManager {
  static TextStyle heading1({Color? color}) => GoogleFonts.inter(
    fontSize: 28.sp,
    fontWeight: FontWeight.bold,
    color: color,
    
  );
  static TextStyle heading2({Color? color}) => GoogleFonts.inter(
    fontSize: 22.sp,
    fontWeight: FontWeight.w700,
    color: color,
    
  );
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: color,
    
  );
  static TextStyle bodyMedium({Color? color}) => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: color,
    
  );
  static TextStyle buttonText({Color? color}) => GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: color,
    
  );
}
