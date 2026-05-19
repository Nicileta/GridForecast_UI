import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/metric_card.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});
  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  int    _days       = 1;
  int?   _touchedIdx;         // index punctului atins pe grafic
  double _zoomFactor = 1.0;   // zoom interactiv
  final  _rng        = Random();

  double _displayUnitValue(double value, String unit) =>
      unit == 'kW' ? value * 1000 : value;

  List<FlSpot> _buildSpots(int output, int days) {
    final pts = days <= 1 ? 24 : days * 2;
    double v = output.toDouble();
    return List.generate(pts, (i) {
      v += (_rng.nextDouble() - 0.48) * output * 0.12;
      v = v.clamp(output * 0.6, output * 1.35);
      return FlSpot(i.toDouble(), v);
    });
  }

  List<FlSpot> _band(List<FlSpot> base, double f) =>
      base.map((s) => FlSpot(s.x, s.y * f)).toList();

  String _xLabel(int days, double x) {
    if (days <= 1) return '${x.round() % 24}:00';
    final d = DateTime.now().add(Duration(days: x.round() ~/ 2));
    return '${d.month}/${d.day}';
  }

  String _fmtNum(int v) {
    if (v >= 1000000) return '${(v/1000000).toStringAsFixed(1)}M';
    if (v >= 1000)    return '${(v/1000).toStringAsFixed(0)},${(v%1000).toString().padLeft(3,'0')}';
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    final state  = context.watch<AppState>();
    final dark   = state.darkMode;
    final lang   = state.language;
    final unit   = state.unit;
    final output = state.expectedOutput;
    final displayOutput = _displayUnitValue(output.toDouble(), unit).round();
    final spots  = _buildSpots(displayOutput, _days);
    final upper  = _band(spots, 1.08);
    final lower  = _band(spots, 0.92);

    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [

        // ── MOBILE SIDEBAR SUMMARY (shown only on mobile) ──────
        if (isMobile) ...[
          _MobilePlantSummary(dark: dark, lang: lang, state: state),
          const SizedBox(height: 12),
        ],

        // ── METRIC CARDS ──────────────────────────────────────
        isMobile
            ? GridView.count(
                crossAxisCount: 2, shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10, crossAxisSpacing: 10,
                childAspectRatio: 1.6,
                children: _buildMetricCards(displayOutput, unit, lang, dark),
              )
            : Row(
                children: _buildMetricCards(displayOutput, unit, lang, dark)
                    .map((c) => Expanded(child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: c)))
                    .toList(),
              ),

        const SizedBox(height: 16),

        // ── CHART CARD ────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(18),
          decoration: AppTheme.card(dark),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8, runSpacing: 8,
                children: [
                  Text(Tr.t('productionForecast', lang),
                      style: AppTheme.label(dark).copyWith(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  // Period chips
                  _ChipRow(
                    options: const ['1d','3d','7d','14d'],
                    days: const [1,3,7,14],
                    selected: _days, dark: dark,
                    onSelected: (d) => setState(() {
                      _days = d; _touchedIdx = null;
                    }),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── INTERACTIVE TOOLBAR ──────────────────────────
              _ChartToolbar(dark: dark, lang: lang),

              const SizedBox(height: 12),

              // ── ZOOM SLIDER ──────────────────────────────────
              Row(children: [
                Icon(Icons.zoom_out, size: 16,
                    color: AppTheme.tx2Of(dark)),
                Expanded(
                  child: Slider(
                    value: _zoomFactor,
                    min: 0.5, max: 2.0,
                    divisions: 15,
                    activeColor: AppTheme.green,
                    inactiveColor: AppTheme.border2Of(dark),
                    onChanged: (v) => setState(() => _zoomFactor = v),
                  ),
                ),
                Icon(Icons.zoom_in, size: 16,
                    color: AppTheme.tx2Of(dark)),
                const SizedBox(width: 6),
                Text('${(_zoomFactor * 100).round()}%',
                    style: AppTheme.small(dark).copyWith(fontSize: 11)),
              ]),

              const SizedBox(height: 8),

              // ── TOOLTIP DISPLAY ──────────────────────────────
              if (_touchedIdx != null && _touchedIdx! < spots.length)
                _DataTooltip(
                  spot: spots[_touchedIdx!],
                  upper: upper[_touchedIdx!].y,
                  lower: lower[_touchedIdx!].y,
                  label: _xLabel(_days, spots[_touchedIdx!].x),
                  unit: unit, dark: dark,
                ),

              const SizedBox(height: 8),

              // ── MAIN CHART ───────────────────────────────────
              SizedBox(
                height: (220 * _zoomFactor).clamp(160, 400),
                child: LineChart(LineChartData(
                  clipData: const FlClipData.all(),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => AppTheme.bgOf(dark),
                      getTooltipItems: (spots) => spots.map((s) =>
                        LineTooltipItem(
                          '${s.y.round()} $unit',
                          AppTheme.label(dark).copyWith(
                              fontSize: 12, color: AppTheme.green),
                        )).toList(),
                    ),
                    touchCallback: (evt, resp) {
                      if (resp?.lineBarSpots?.isNotEmpty == true) {
                        setState(() => _touchedIdx =
                            resp!.lineBarSpots!.first.spotIndex);
                      }
                    },
                    handleBuiltInTouches: false,
                  ),
                  gridData: FlGridData(
                    show: state.showGrid,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: AppTheme.borderOf(dark), strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true, reservedSize: 52,
                      getTitlesWidget: (v, _) => Text(
                        '${v.round()} $unit',
                        style: AppTheme.small(dark)
                            .copyWith(fontSize: 10, color: AppTheme.txmOf(dark)),
                      ),
                    )),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true,
                      interval: spots.length / 6,
                      getTitlesWidget: (v, _) => Text(
                        _xLabel(_days, v),
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
                    // Confidence band upper
                    if (state.showConfidenceBand)
                      LineChartBarData(
                        spots: upper, color: Colors.transparent, barWidth: 0,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppTheme.green.withOpacity(0.12),
                          spotsLine: const BarAreaSpotsLine(show: false),
                        ),
                      ),
                    // Main forecast line
                    LineChartBarData(
                      spots: spots,
                      color: AppTheme.green,
                      barWidth: 2,
                      isCurved: state.chartType == 'line',
                      dotData: FlDotData(
                        show: state.showDataPoints,
                        getDotPainter: (s, _, __, i) {
                          final touched = i == _touchedIdx;
                          return FlDotCirclePainter(
                            radius: touched ? 6 : 3,
                            color: AppTheme.green,
                            strokeWidth: touched ? 2 : 0,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: state.chartType == 'area',
                        color: AppTheme.green.withOpacity(0.15),
                      ),
                    ),
                    // Confidence band lower
                    if (state.showConfidenceBand)
                      LineChartBarData(
                        spots: lower, color: Colors.transparent, barWidth: 0,
                        dotData: const FlDotData(show: false),
                      ),
                  ],
                )),
              ),

              const SizedBox(height: 12),
              // Legend
              Wrap(spacing: 16, children: [
                _LegendItem(AppTheme.green, Tr.t('forecastOutput', lang)),
                if (state.showConfidenceBand)
                  _LegendItem(const Color(0xFF9FE1CB), Tr.t('confBand', lang)),
              ]),
            ],
          ),
        ),
      ]),
    );
  }

  List<Widget> _buildMetricCards(int output, String unit, String lang, bool dark) {
    return [
      MetricCard(label: Tr.t('avgDaily', lang),
          value: _fmtNum(output * 24), unit: 'MWh',
          delta: '↑ 4.2% vs last week', dark: dark),
      MetricCard(label: Tr.t('peakForecast', lang),
          value: _fmtNum((output * 1.12).round()), unit: unit,
          delta: '↑ 1.8%', dark: dark),
      MetricCard(label: Tr.t('minForecast', lang),
          value: _fmtNum((output * 0.72).round()), unit: unit,
          delta: '↓ 2.1%', deltaUp: false, dark: dark),
      MetricCard(label: Tr.t('confidence', lang),
          value: '91', unit: '%',
          delta: '7-day model', deltaNeutral: true, dark: dark),
    ];
  }
}

// ── CHART TOOLBAR ─────────────────────────────────────────────────
class _ChartToolbar extends StatelessWidget {
  final bool dark; final String lang;
  const _ChartToolbar({required this.dark, required this.lang});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Wrap(spacing: 8, runSpacing: 6, children: [
      // Chart type toggle
      _ToolChip(
        label: Tr.t('line', lang),
        icon: Icons.show_chart,
        active: s.chartType == 'line', dark: dark,
        onTap: () => context.read<AppState>().setChartType('line'),
      ),
      _ToolChip(
        label: Tr.t('area', lang),
        icon: Icons.area_chart,
        active: s.chartType == 'area', dark: dark,
        onTap: () => context.read<AppState>().setChartType('area'),
      ),
      // Toggle confidence band
      _ToolChip(
        label: Tr.t('confBand', lang),
        icon: Icons.blur_on,
        active: s.showConfidenceBand, dark: dark,
        onTap: () => context.read<AppState>()
            .setShowConfidenceBand(!s.showConfidenceBand),
      ),
      // Toggle data points
      _ToolChip(
        label: Tr.t('showDataPts', lang),
        icon: Icons.scatter_plot,
        active: s.showDataPoints, dark: dark,
        onTap: () => context.read<AppState>()
            .setShowDataPoints(!s.showDataPoints),
      ),
      // Toggle grid
      _ToolChip(
        label: Tr.t('showGrid', lang),
        icon: Icons.grid_on,
        active: s.showGrid, dark: dark,
        onTap: () => context.read<AppState>().setShowGrid(!s.showGrid),
      ),
    ]);
  }
}

class _ToolChip extends StatelessWidget {
  final String label; final IconData icon;
  final bool active, dark; final VoidCallback onTap;
  const _ToolChip({required this.label, required this.icon,
    required this.active, required this.dark, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: active ? AppTheme.green : AppTheme.bgOf(dark),
        border: Border.all(
            color: active ? AppTheme.green : AppTheme.border2Of(dark)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13,
            color: active ? Colors.white : AppTheme.tx2Of(dark)),
        const SizedBox(width: 5),
        Text(label, style: AppTheme.small(dark).copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: active ? Colors.white : AppTheme.tx2Of(dark))),
      ]),
    ),
  );
}

// ── DATA TOOLTIP PANEL ────────────────────────────────────────────
class _DataTooltip extends StatelessWidget {
  final FlSpot spot; final double upper, lower;
  final String label, unit; final bool dark;
  const _DataTooltip({required this.spot, required this.upper,
    required this.lower, required this.label,
    required this.unit, required this.dark});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppTheme.greenBgOf(dark),
      borderRadius: BorderRadius.circular(AppTheme.r),
      border: Border.all(color: AppTheme.green.withOpacity(0.3)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.info_outline, size: 14, color: AppTheme.greenDark),
      const SizedBox(width: 8),
      Text('$label  ', style: AppTheme.small(dark).copyWith(
          fontSize: 11, color: AppTheme.greenDark, fontWeight: FontWeight.w600)),
      Text('${spot.y.round()} $unit', style: AppTheme.label(dark).copyWith(
          fontSize: 12, color: AppTheme.greenDark, fontWeight: FontWeight.w700)),
      Text('  ↑${upper.round()}  ↓${lower.round()}',
          style: AppTheme.small(dark).copyWith(
              fontSize: 11, color: AppTheme.greenDark)),
    ]),
  );
}

// ── MOBILE PLANT SUMMARY ─────────────────────────────────────────
class _MobilePlantSummary extends StatelessWidget {
  final bool dark; final String lang; final AppState state;
  const _MobilePlantSummary(
      {required this.dark, required this.lang, required this.state});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: AppTheme.card(dark),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      _MiniStat(state.plantType, Tr.t('plantType', lang), dark),
      _MiniStat('${state.capacity.round()} MW',
          Tr.t('capacity', lang), dark),
      _MiniStat('${state.efficiency.round()}%',
          Tr.t('efficiency', lang), dark),
    ]),
  );
}

class _MiniStat extends StatelessWidget {
  final String value, label; final bool dark;
  const _MiniStat(this.value, this.label, this.dark);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: AppTheme.label(dark)
        .copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
    Text(label, style: AppTheme.small(dark).copyWith(fontSize: 10)),
  ]);
}

// ── CHIPS ────────────────────────────────────────────────────────
class _ChipRow extends StatelessWidget {
  final List<String> options; final List<int> days;
  final int selected; final bool dark; final ValueChanged<int> onSelected;
  const _ChipRow({required this.options, required this.days,
    required this.selected, required this.dark, required this.onSelected});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(options.length, (i) {
      final active = selected == days[i];
      return Padding(
        padding: const EdgeInsets.only(left: 4),
        child: GestureDetector(
          onTap: () => onSelected(days[i]),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: active ? AppTheme.txOf(dark) : AppTheme.bgOf(dark),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                  color: active ? AppTheme.txOf(dark) : AppTheme.border2Of(dark)),
            ),
            child: Text(options[i], style: AppTheme.label(dark).copyWith(
              fontSize: 12,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? AppTheme.bgOf(dark) : AppTheme.tx2Of(dark),
            )),
          ),
        ),
      );
    }),
  );
}

// ── LEGEND ───────────────────────────────────────────────────────
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