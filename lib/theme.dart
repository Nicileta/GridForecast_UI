import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color green       = Color(0xFF1D9E75);
  static const Color greenBg     = Color(0xFFE1F5EE);
  static const Color greenDark   = Color(0xFF0F6E56);
  static const Color greenDarker = Color(0xFF085041);

  static const Color bg          = Color(0xFFFFFFFF);
  static const Color bg2         = Color(0xFFF5F5F2);
  static const Color border      = Color(0x17000000);
  static const Color border2     = Color(0x26000000);

  static const Color tx          = Color(0xFF1A1A18);
  static const Color tx2         = Color(0xFF5F5E5A);
  static const Color txm         = Color(0xFF9A948F);

  static const Color ok          = Color(0xFF0F6E56);
  static const Color err         = Color(0xFFa83218);

  // Radius
  static const double r  = 8;
  static const double rl = 12;

  // Text styles (Inter via google_fonts)
  static TextStyle get label => GoogleFonts.inter(
    color: tx,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get small => GoogleFonts.inter(
    color: tx2,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get sectionLabel => GoogleFonts.inter(
    color: txm,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.10 * 10,
  );

  // Decorations
  static BoxDecoration get card => const BoxDecoration(
    color: bg,
    borderRadius: BorderRadius.all(Radius.circular(rl)),
    border: Border.fromBorderSide(BorderSide(color: border)),
  );

  static BoxDecoration get pill => const BoxDecoration(
    color: greenBg,
    borderRadius: BorderRadius.all(Radius.circular(r)),
  );
}