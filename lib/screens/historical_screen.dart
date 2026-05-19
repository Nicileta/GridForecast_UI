import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
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
  DateTime _startDate = DateTime.now().subtract(Duration(days: 6));
  late final TextEditingController _dayController;
  late final TextEditingController _monthController;
  late final TextEditingController _yearController;

  @override
  void initState() {
    super.initState();
    _dayController = TextEditingController(text: _startDate.day.toString().padLeft(2, '0'));
    _monthController = TextEditingController(text: _startDate.month.toString().padLeft(2, '0'));
    _yearController = TextEditingController(text: _startDate.year.toString());
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _applyManualDate() {
    final day = int.tryParse(_dayController.text);
    final month = int.tryParse(_monthController.text);
    final year = int.tryParse(_yearController.text);
    if (day == null || month == null || year == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Enter valid day, month, and year.'),
      ));
      return;
    }
    try {
      final selected = DateTime(year, month, day);
      final today = DateTime.now();
      if (selected.isAfter(today)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Date cannot be in the future.'),
        ));
        return;
      }
      setState(() => _startDate = selected);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Enter a valid date.'),
      ));
    }
  }

  List<FlSpot> _actual(int days, String unit) {
    double v = _base;
    return List.generate(days, (i) {
      v += (_rng.nextDouble() - 0.48) * _base * 0.15;
      v = v.clamp(_base * 0.6, _base * 1.35);
      return FlSpot(i.toDouble(), _displayUnitValue(v, unit));
    });
  }

  List<FlSpot> _expected(int days, String unit) => List.generate(days, (i) =>
      FlSpot(i.toDouble(), _displayUnitValue(_base *
          (0.97 + _rng.nextDouble() * 0.06), unit)));

  double _displayUnitValue(double value, String unit) =>
      unit == 'kW' ? value * 1000 : value;

  String _unitLabel(String unit) => unit == 'kW' ? 'kW' : 'MW';

  String _dateLabel(int days, double x) {
    final d = _startDate.add(Duration(days: x.round()));
    return '${d.month}/${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    final state  = context.watch<AppState>();
    final dark   = state.darkMode;
    final lang   = state.language;
    final unit = state.unit;
    final actual   = _actual(_days, unit);
    final expected = _expected(_days, unit);
    final devs = List.generate(_days, (i) =>
        ((actual[i].y - expected[i].y) / expected[i].y * 100));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [

        // Comparison chart
        Container(
          padding: const EdgeInsets.all(18),
          decoration: AppTheme.card(dark),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(Tr.t('histComparison', lang),
                      style: AppTheme.label(dark).copyWith(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  Row(children: [
                    SizedBox(
                      width: 40,
                      child: TextField(
                        controller: _dayController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'DD',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 4),
                        ),
                        onSubmitted: (_) => _applyManualDate(),
                      ),
                    ),
                    Text('/'),
                    SizedBox(
                      width: 40,
                      child: TextField(
                        controller: _monthController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'MM',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 4),
                        ),
                        onSubmitted: (_) => _applyManualDate(),
                      ),
                    ),
                    Text('/'),
                    SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'YYYY',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 4),
                        ),
                        onSubmitted: (_) => _applyManualDate(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.txOf(dark),
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime.now().subtract(Duration(days: 365 * 2)),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _startDate = picked;
                            _dayController.text = _startDate.day.toString().padLeft(2, '0');
                            _monthController.text = _startDate.month.toString().padLeft(2, '0');
                            _yearController.text = _startDate.year.toString();
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_month, size: 16),
                      label: Text('Select',
                          style: AppTheme.small(dark).copyWith(fontSize: 12)),
                    ),
                  ]),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: LineChart(LineChartData(
                  gridData: FlGridData(
                    show: state.showGrid, drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: AppTheme.borderOf(dark), strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    enabled: false,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true, reservedSize: 52,
                      getTitlesWidget: (v, _) => Text(
                        '${v.round()} ${_unitLabel(unit)}',
                        style: AppTheme.small(dark)
                            .copyWith(fontSize: 10, color: AppTheme.txmOf(dark)),
                      ),
                    )),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true,
                      interval: (_days / 5).ceilToDouble(),
                      getTitlesWidget: (v, _) => Text(
                        _dateLabel(_days, v),
                        style: AppTheme.small(dark)
                            .copyWith(fontSize: 10, color: AppTheme.txmOf(dark)),
                      ),
                    )),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: actual, color: AppTheme.green,
                      barWidth: 2, isCurved: true,
                      dotData: FlDotData(show: state.showDataPoints,
                        getDotPainter: (_, __, ___, ____) =>
                            FlDotCirclePainter(radius: 3,
                                color: AppTheme.green, strokeWidth: 0),
                      ),
                      belowBarData: BarAreaData(show: true,
                          color: AppTheme.green.withOpacity(0.08)),
                    ),
                    LineChartBarData(
                      spots: expected,
                      color: const Color(0xFF378ADD),
                      barWidth: 1.5, isCurved: true,
                      dashArray: [5, 4],
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                )),
              ),
              const SizedBox(height: 12),
              Wrap(spacing: 16, children: [
                _LegendItem(AppTheme.green, Tr.t('actualOutput', lang)),
                _LegendItem(const Color(0xFF378ADD),
                    Tr.t('expectedBaseline', lang)),
              ]),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Deviation chart
        Container(
          padding: const EdgeInsets.all(18),
          decoration: AppTheme.card(dark),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Tr.t('dailyDeviation', lang),
                  style: AppTheme.label(dark).copyWith(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              SizedBox(
                height: 160,
                child: BarChart(BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  gridData: FlGridData(
                    show: state.showGrid, drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: AppTheme.borderOf(dark), strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Text(
                        _dateLabel(_days, v),
                        style: AppTheme.small(dark)
                            .copyWith(fontSize: 10, color: AppTheme.txmOf(dark)),
                      ),
                    )),
                    leftTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true, reservedSize: 36,
                      getTitlesWidget: (v, _) => Text('${v.toStringAsFixed(0)}%',
                        style: AppTheme.small(dark)
                            .copyWith(fontSize: 10, color: AppTheme.txmOf(dark)),
                      ),
                    )),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  barGroups: List.generate(_days, (i) {
                    final v = devs[i];
                    return BarChartGroupData(x: i, barRods: [
                      BarChartRodData(
                        toY: v,
                        color: v >= 0
                            ? AppTheme.green.withOpacity(0.8)
                            : const Color(0xFFE24B4A).withOpacity(0.8),
                        width: 10,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ]);
                  }),
                )),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color; final String label;
  const _LegendItem(this.color, this.label);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 9, height: 9, decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ]);
}