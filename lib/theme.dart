import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color green       = Color(0xFF1D9E75);
  static const Color greenBg     = Color(0xFFE1F5EE);
  static const Color greenDark   = Color(0xFF0F6E56);
  static const Color greenDarker = Color(0xFF085041);
  static const Color greenBgDark = Color(0xFF0D3028);

  // Light
  static const Color bg          = Color(0xFFFFFFFF);
  static const Color bg2         = Color(0xFFF5F5F2);
  static const Color border      = Color(0x17000000);
  static const Color border2     = Color(0x26000000);
  static const Color tx          = Color(0xFF1A1A18);
  static const Color tx2         = Color(0xFF5F5E5A);
  static const Color txm         = Color(0xFF9A948F);

  // Dark
  static const Color bgDark      = Color(0xFF1C1C1A);
  static const Color bg2Dark     = Color(0xFF252522);
  static const Color borderDark  = Color(0x1AFFFFFF);
  static const Color border2Dark = Color(0x2AFFFFFF);
  static const Color txDark      = Color(0xFFE8E8E4);
  static const Color tx2Dark     = Color(0xFFB4B2A9);
  static const Color txmDark     = Color(0xFF888780);

  static const Color ok  = Color(0xFF0F6E56);
  static const Color err = Color(0xFFa83218);
  static const Color okDark  = Color(0xFF5DCAA5);
  static const Color errDark = Color(0xFFF0997B);

  static const double r  = 8;
  static const double rl = 12;

  // Dynamic getters
  static Color bgOf(bool dark)      => dark ? bgDark      : bg;
  static Color bg2Of(bool dark)     => dark ? bg2Dark     : bg2;
  static Color borderOf(bool dark)  => dark ? borderDark  : border;
  static Color border2Of(bool dark) => dark ? border2Dark : border2;
  static Color txOf(bool dark)      => dark ? txDark      : tx;
  static Color tx2Of(bool dark)     => dark ? tx2Dark     : tx2;
  static Color txmOf(bool dark)     => dark ? txmDark     : txm;
  static Color okOf(bool dark)      => dark ? okDark      : ok;
  static Color errOf(bool dark)     => dark ? errDark      : err;
  static Color greenBgOf(bool dark) => dark ? greenBgDark : greenBg;

  static TextStyle label(bool dark) => GoogleFonts.inter(
    color: txOf(dark), fontSize: 14, fontWeight: FontWeight.w400);

  static TextStyle small(bool dark) => GoogleFonts.inter(
    color: tx2Of(dark), fontSize: 12, fontWeight: FontWeight.w400);

  static TextStyle sectionLabel(bool dark) => GoogleFonts.inter(
    color: txmOf(dark), fontSize: 10, fontWeight: FontWeight.w600,
    letterSpacing: 1.0);

  static BoxDecoration card(bool dark) => BoxDecoration(
    color: bgOf(dark),
    borderRadius: const BorderRadius.all(Radius.circular(rl)),
    border: Border.fromBorderSide(BorderSide(color: borderOf(dark))));

  static BoxDecoration pill(bool dark) => BoxDecoration(
    color: greenBgOf(dark),
    borderRadius: const BorderRadius.all(Radius.circular(r)));

  static ThemeData materialTheme(bool dark) => ThemeData(
    brightness: dark ? Brightness.dark : Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: green,
      brightness: dark ? Brightness.dark : Brightness.light,
    ),
    textTheme: GoogleFonts.interTextTheme(
      dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: dark ? bgDark : bg2,
  );
}