import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme.dart';
import '../widgets/metric_card.dart';

class ForecastScreen extends StatefulWidget {
  final double capacity;
  final double units;
  final double efficiency;

  const ForecastScreen({
    super.key,
    required this.capacity,
    required this.units,
    required this.efficiency,
  });

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  int _selectedDays = 1;
  final _rng = Random();

  int get _output =>
      (widget.capacity * widget.units * widget.efficiency / 100).round();

  List<FlSpot> _buildSpots(int days) {
    final pts = days <= 1 ? 24 : days * 2;
    double v = _output.toDouble();
    return List.generate(pts, (i) {
      v += (_rng.nextDouble() - 0.48) * _output * 0.12;
      v = v.clamp(_output * 0.6, _output * 1.35);
      return FlSpot(i.toDouble(), v);
    });
  }

  List<FlSpot> _buildBand(List<FlSpot> base, double factor) =>
      base.map((s) => FlSpot(s.x, s.y * factor)).toList();

  String _xLabel(int days, double x) {
    final i = x.round();
    if (days <= 1) return '${i % 24}:00';
    final d = DateTime.now().add(Duration(days: i ~/ 2));
    return '${d.month}/${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    final spots  = _buildSpots(_selectedDays);
    final upper  = _buildBand(spots, 1.08);
    final lower  = _buildBand(spots, 0.92);
    final avgOut = _output * 24;
    final peak   = (_output * 1.12).round();
    final minOut = (_output * 0.72).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          // Metric cards
          Row(
            children: [
              Expanded(child: MetricCard(
                label: 'Avg daily output',
                value: _fmtNum(avgOut),
                unit: 'MWh',
                delta: '↑ 4.2% vs last week',
                deltaUp: true,
              )),
              const SizedBox(width: 12),
              Expanded(child: MetricCard(
                label: 'Peak forecast',
                value: _fmtNum(peak),
                unit: 'MW',
                delta: '↑ 1.8%',
                deltaUp: true,
              )),
              const SizedBox(width: 12),
              Expanded(child: MetricCard(
                label: 'Min forecast',
                value: _fmtNum(minOut),
                unit: 'MW',
                delta: '↓ 2.1%',
                deltaUp: false,
              )),
              const SizedBox(width: 12),
              const Expanded(child: MetricCard(
                label: 'Confidence',
                value: '91',
                unit: '%',
                delta: '7-day model',
                deltaNeutral: true,
              )),
            ],
          ),

          const SizedBox(height: 16),

          // Chart card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Production forecast',
                        style: AppTheme.label.copyWith(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    _ChipRow(
                      options: const ['1d', '3d', '7d', '14d'],
                      days:    const [1, 3, 7, 14],
                      selected: _selectedDays,
                      onSelected: (d) => setState(() => _selectedDays = d),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => const FlLine(
                          color: AppTheme.border,
                          strokeWidth: 1,
                        ),
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
                            interval: spots.length / 6,
                            getTitlesWidget: (v, _) => Text(
                              _xLabel(_selectedDays, v),
                              style: AppTheme.small.copyWith(fontSize: 10, color: AppTheme.txm),
                            ),
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        // Confidence band (upper)
                        LineChartBarData(
                          spots: upper,
                          color: Colors.transparent,
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFF1D9E75).withOpacity(0.12),
                            spotsLine: const BarAreaSpotsLine(show: false),
                          ),
                          dotData: const FlDotData(show: false),
                          barWidth: 0,
                        ),
                        // Main forecast line
                        LineChartBarData(
                          spots: spots,
                          color: AppTheme.green,
                          barWidth: 2,
                          isCurved: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFF1D9E75).withOpacity(0.08),
                          ),
                        ),
                        // Lower band
                        LineChartBarData(
                          spots: lower,
                          color: Colors.transparent,
                          dotData: const FlDotData(show: false),
                          barWidth: 0,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                const Row(
                  children: [
                    _LegendItem(color: AppTheme.green, label: 'Forecast output'),
                    SizedBox(width: 18),
                    _LegendItem(
                        color: Color(0xFF9FE1CB), label: 'Confidence band'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmtNum(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000)    return '${(v / 1000).toStringAsFixed(0)},${(v % 1000).toString().padLeft(3, '0')}';
    return v.toString();
  }
}

class _ChipRow extends StatelessWidget {
  final List<String> options;
  final List<int> days;
  final int selected;
  final ValueChanged<int> onSelected;

  const _ChipRow({
    required this.options,
    required this.days,
    required this.selected,
    required this.onSelected,
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
        Container(
          width: 9, height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: AppTheme.small.copyWith(fontSize: 12)),
      ],
    );
  }
}