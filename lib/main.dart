import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototip_ui/app.dart';

void main() {
  runApp(const GridForecastApp());
}

class GridForecastApp extends StatelessWidget {
  const GridForecastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GridForecast',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1D9E75),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}