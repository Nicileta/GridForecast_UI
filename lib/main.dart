import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'theme.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const GridForecastApp(),
    ),
  );
}

class GridForecastApp extends StatelessWidget {
  const GridForecastApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return MaterialApp(
      title: 'GridForecast',
      debugShowCheckedModeBanner: false,
      theme:     AppTheme.materialTheme(false),
      darkTheme: AppTheme.materialTheme(true),
      themeMode: state.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AppShell(),
    );
  }
}