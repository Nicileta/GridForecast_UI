import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';

class WarningsScreen extends StatefulWidget {
  const WarningsScreen({super.key});
  @override
  State<WarningsScreen> createState() => _WarningsScreenState();
}

enum WarningSeverity { high, medium, low }

class WarningItem {
  final DateTime date;
  final String title;
  final String description;
  final WarningSeverity severity;
  final double deviationPercent;

  WarningItem({
    required this.date,
    required this.title,
    required this.description,
    required this.severity,
    required this.deviationPercent,
  });
}

class _WarningsScreenState extends State<WarningsScreen> {
  final _rng = Random();

  List<WarningItem> _generateWarnings(String lang) {
    final warnings = <WarningItem>[];
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i + 1));
      final deviation = (_rng.nextDouble() * 25 + 5).toStringAsFixed(1);
      final severity = i % 3 == 0
          ? WarningSeverity.high
          : (i % 3 == 1 ? WarningSeverity.medium : WarningSeverity.low);

      warnings.add(WarningItem(
        date: date,
        title: Tr.t('potentialDeviation', lang),
        description: Tr.t('weatherAffected', lang),
        severity: severity,
        deviationPercent: double.parse(deviation),
      ));
    }

    return warnings;
  }

  Color _severityColor(WarningSeverity s) {
    switch (s) {
      case WarningSeverity.high:
        return const Color(0xFFE24B4A);
      case WarningSeverity.medium:
        return const Color(0xFFFFA726);
      case WarningSeverity.low:
        return const Color(0xFF378ADD);
    }
  }

  IconData _severityIcon(WarningSeverity s) {
    switch (s) {
      case WarningSeverity.high:
        return Icons.warning;
      case WarningSeverity.medium:
        return Icons.info;
      case WarningSeverity.low:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final dark = state.darkMode;
    final lang = state.language;
    final warnings = _generateWarnings(lang);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: AppTheme.card(dark),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(Tr.t('warnings', lang),
                style: AppTheme.label(dark)
                    .copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(Tr.t('warningsDesc', lang),
                style: AppTheme.small(dark)
                    .copyWith(color: AppTheme.txmOf(dark))),
          ]),
        ),
        const SizedBox(height: 16),
        ...warnings.asMap().map((i, w) {
          return MapEntry(
              i,
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _severityColor(w.severity).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppTheme.r),
                  border: Border.all(
                      color: _severityColor(w.severity).withOpacity(0.3)),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _severityColor(w.severity).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_severityIcon(w.severity),
                        size: 18, color: _severityColor(w.severity)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    '${w.date.year}-${w.date.month.toString().padLeft(2, '0')}-${w.date.day.toString().padLeft(2, '0')}',
                                    style: AppTheme.small(dark)
                                        .copyWith(fontWeight: FontWeight.w600)),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _severityColor(w.severity),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                      w.severity.name.toUpperCase(),
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                                ),
                              ]),
                          const SizedBox(height: 6),
                          Text(w.title,
                              style: AppTheme.label(dark)
                                  .copyWith(fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(w.description,
                              style: AppTheme.small(dark)),
                        ]),
                  ),
                ]),
              ));
        }).values,
        const SizedBox(height: 16),
        Container(
          height: 180,
          padding: const EdgeInsets.all(14),
          decoration: AppTheme.card(dark),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(Tr.t('deviationForecast', lang),
                style: AppTheme.label(dark)
                    .copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Expanded(
              child: BarChart(BarChartData(
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      final d = DateTime.now().add(Duration(days: v.toInt() + 1));
                      return Text('${d.month}/${d.day}',
                          style: AppTheme.small(dark)
                              .copyWith(fontSize: 10, color: AppTheme.txmOf(dark)));
                    },
                  )),
                  leftTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,
                    getTitlesWidget: (v, _) => Text('${v.toInt()}%',
                        style: AppTheme.small(dark)
                            .copyWith(fontSize: 10, color: AppTheme.txmOf(dark))),
                  )),
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: List.generate(7, (i) {
                  final v = _rng.nextDouble() * 20 + 5;
                  return BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                      toY: v,
                      color: const Color(0xFFE24B4A).withOpacity(0.7),
                      width: 12,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ]);
                }),
              )),
            ),
          ]),
        ),
      ]),
    );
  }
}

extension on WarningSeverity {
  String get name {
    switch (this) {
      case WarningSeverity.high:
        return 'high';
      case WarningSeverity.medium:
        return 'medium';
      case WarningSeverity.low:
        return 'low';
    }
  }
}