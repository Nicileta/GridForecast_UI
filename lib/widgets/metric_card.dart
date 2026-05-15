import 'package:flutter/material.dart';
import '../theme.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final String delta;
  final bool deltaUp;
  final bool deltaNeutral;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.delta,
    this.deltaUp = true,
    this.deltaNeutral = false,
  });

  @override
  Widget build(BuildContext context) {
    final deltaColor = deltaNeutral
        ? AppTheme.txm
        : deltaUp ? AppTheme.ok : AppTheme.err;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.small.copyWith(fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTheme.label.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppTheme.tx,
              letterSpacing: -0.5,
            ),
          ),
          Text(unit, style: AppTheme.small.copyWith(color: AppTheme.txm)),
          const SizedBox(height: 5),
          Text(
            delta,
            style: AppTheme.small.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: deltaColor,
            ),
          ),
        ],
      ),
    );
  }
}