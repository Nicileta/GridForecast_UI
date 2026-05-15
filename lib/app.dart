import 'package:flutter/material.dart';
import 'package:prototip_ui/theme.dart';
import 'package:prototip_ui/screens/forecast_screen.dart';
import 'package:prototip_ui/screens/historical_screen.dart';
import 'package:prototip_ui/screens/contact_screen.dart';
import 'package:prototip_ui/widgets/sidebar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedTab = 0;

  String plantType = 'Solar PV';
  double capacity  = 500;
  double units     = 4;
  double efficiency = 82;
  List<Map<String, dynamic>> plantGroups = [];

  void _addPlantGroup() {
    setState(() {
      plantGroups.add({
        'type':     plantType,
        'capacity': capacity,
        'units':    units,
      });
    });
  }

  int get totalCapacity  => (capacity * units).round();
  int get expectedOutput => (capacity * units * efficiency / 100).round();

  @override
  Widget build(BuildContext context) {
    final tabs  = ['Forecast', 'Historical', 'Contact'];
    final icons = [Icons.show_chart, Icons.history, Icons.mail_outline];

    return Scaffold(
      backgroundColor: AppTheme.bg2,
      body: Column(
        children: [
          // ── Topbar ──
          Container(
            height: 52,
            decoration: const BoxDecoration(
              color: AppTheme.bg,
              border: Border(bottom: BorderSide(color: AppTheme.border)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: AppTheme.green, size: 20),
                const SizedBox(width: 7),
                Text(
                  'GridForecast',
                  style: AppTheme.label.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.tx,
                  ),
                ),
                const Spacer(),
                Row(
                  children: List.generate(tabs.length, (i) {
                    final active = _selectedTab == i;
                    return Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(99),
                        onTap: () => setState(() => _selectedTab = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: active ? AppTheme.bg2 : AppTheme.bg,
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(color: AppTheme.border2),
                          ),
                          child: Row(
                            children: [
                              Icon(icons[i],
                                  size: 14,
                                  color: active ? AppTheme.tx : AppTheme.tx2),
                              const SizedBox(width: 5),
                              Text(
                                tabs[i],
                                style: AppTheme.label.copyWith(
                                  fontSize: 13,
                                  fontWeight: active
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                  color: active ? AppTheme.tx : AppTheme.tx2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // ── Main ──
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Sidebar(
                  plantType:          plantType,
                  capacity:           capacity,
                  units:              units,
                  efficiency:         efficiency,
                  plantGroups:        plantGroups,
                  totalCapacity:      totalCapacity,
                  expectedOutput:     expectedOutput,
                  onPlantTypeChanged: (v) => setState(() => plantType = v),
                  onCapacityChanged:  (v) => setState(() => capacity  = v),
                  onUnitsChanged:     (v) => setState(() => units     = v),
                  onEfficiencyChanged:(v) => setState(() => efficiency = v),
                  onAddPlant:         _addPlantGroup,
                ),
                Expanded(
                  child: IndexedStack(
                    index: _selectedTab,
                    children: [
                      ForecastScreen(
                        capacity:   capacity,
                        units:      units,
                        efficiency: efficiency,
                      ),
                      const HistoricalScreen(),
                      const ContactScreen(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}