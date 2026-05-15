import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme.dart';

class HistoricalScreen extends StatefulWidget {
  const HistoricalScreen({super.key});

  @override
  State<HistoricalScreen> createState() => _HistoricalScreenState();
}

class _HistoricalScreenState extends State<HistoricalScreen> {
  int _days = 7;
  final _rng = Random();
  final _base = 1640.0;

  List<FlSpot> _actual(int days) {
    double v = _base;
    return List.generate(days, (i) {
      v += (_rng.nextDouble() - 0.48) * _base * 0.15;
      v = v.clamp(_base * 0.6, _base * 1.35);
      return FlSpot(i.toDouble(), v);
    });
  }

  List<FlSpot> _expected(int days) => List.generate(days, (i) =>
      FlSpot(i.toDouble(), _base * (0.97 + _rng.nextDouble() * 0.06)));

  String _dateLabel(int days, double x) {
    final d = DateTime.now().subtract(Duration(days: days - x.round() - 1));
    return '${d.month}/${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    final actual   = _actual(_days);
    final expected = _expected(_days);
    final devs     = List.generate(_days, (i) =>
        ((actual[i].y - expected[i].y) / expected[i].y * 100));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          // Comparison chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Historical output comparison',
                        style: AppTheme.label.copyWith(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    _ChipRow(
                      options:  const ['1w', '2w', '3w', '1mo'],
                      days:     const [7, 14, 21, 30],
                      selected: _days,
                      onSelected: (d) => setState(() => _days = d),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: LineChart(LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) =>
                          const FlLine(color: AppTheme.border, strokeWidth: 1),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 52,
                          getTitlesWidget: (v, _) => Text(
                            '${(v / 1000).toStringAsFixed(1)}GW',
                            style: AppTheme.small.copyWith(fontSize: 10, color: AppTheme.txm),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: (_days / 5).ceilToDouble(),
                          getTitlesWidget: (v, _) => Text(
                            _dateLabel(_days, v),
                            style: AppTheme.small.copyWith(fontSize: 10, color: AppTheme.txm),
                          ),
                        ),
                      ),
                      topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      // Actual
                      LineChartBarData(
                        spots: actual,
                        color: AppTheme.green,
                        barWidth: 2,
                        isCurved: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                            radius: 3,
                            color: AppTheme.green,
                            strokeWidth: 0,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFF1D9E75).withOpacity(0.08),
                        ),
                      ),
                      // Expected
                      LineChartBarData(
                        spots: expected,
                        color: const Color(0xFF378ADD),
                        barWidth: 1.5,
                        isCurved: true,
                        dashArray: [5, 4],
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  )),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    _LegendItem(color: AppTheme.green, label: 'Actual output'),
                    SizedBox(width: 18),
                    _LegendItem(color: Color(0xFF378ADD), label: 'Expected baseline'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Deviation chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily deviation (%)',
                    style: AppTheme.label.copyWith(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: BarChart(BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) =>
                          const FlLine(color: AppTheme.border, strokeWidth: 1),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) => Text(
                            _dateLabel(_days, v),
                            style: AppTheme.small.copyWith(fontSize: 10, color: AppTheme.txm),
                          ),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          getTitlesWidget: (v, _) => Text(
                            '${v.toStringAsFixed(0)}%',
                            style: AppTheme.small.copyWith(fontSize: 10, color: AppTheme.txm),
                          ),
                        ),
                      ),
                      topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    barGroups: List.generate(_days, (i) {
                      final v = devs[i];
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: v,
                            color: v >= 0
                                ? const Color(0xFF1D9E75).withOpacity(0.8)
                                : const Color(0xFFE24B4A).withOpacity(0.8),
                            width: 10,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ],
                      );
                    }),
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  final List<String> options;
  final List<int> days;
  final int selected;
  final ValueChanged<int> onSelected;

  const _ChipRow({
    required this.options, required this.days,
    required this.selected, required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(options.length, (i) {
        final active = selected == days[i];
        return Padding(
          padding: const EdgeInsets.only(left: 5),
          child: InkWell(
            borderRadius: BorderRadius.circular(99),
            onTap: () => onSelected(days[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: active ? AppTheme.tx : AppTheme.bg,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: active ? AppTheme.tx : AppTheme.border2),
              ),
              child: Text(
                options[i],
                style: AppTheme.label.copyWith(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w500 : FontWeight.w400,
                  color: active ? Colors.white : AppTheme.tx2,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 9, height: 9,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 5),
        Text(label, style: AppTheme.small.copyWith(fontSize: 12)),
      ],
    );
  }
}