import 'package:flutter/material.dart';
import '../theme.dart';

class MetricCard extends StatelessWidget {
  final String label, value, unit, delta;
  final bool deltaUp, deltaNeutral, dark;

  const MetricCard({
    super.key,
    required this.label, required this.value,
    required this.unit,  required this.delta,
    required this.dark,
    this.deltaUp = true, this.deltaNeutral = false,
  });

  @override
  Widget build(BuildContext context) {
    final deltaColor = deltaNeutral ? AppTheme.txmOf(dark)
        : deltaUp ? AppTheme.okOf(dark) : AppTheme.errOf(dark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.card(dark),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTheme.small(dark).copyWith(fontSize: 12)),
        const SizedBox(height: 6),
        Text(value, style: AppTheme.label(dark).copyWith(
            fontSize: 26, fontWeight: FontWeight.w700,
            color: AppTheme.txOf(dark), letterSpacing: -0.5)),
        Text(unit, style: AppTheme.small(dark).copyWith(
            color: AppTheme.txmOf(dark))),
        const SizedBox(height: 5),
        Text(delta, style: AppTheme.small(dark).copyWith(
            fontSize: 12, fontWeight: FontWeight.w500, color: deltaColor)),
      ]),
    );
  }
}