import 'package:flutter/material.dart';
import '../theme.dart';

class Sidebar extends StatelessWidget {
  final String plantType;
  final double capacity;
  final double units;
  final double efficiency;
  final List<Map<String, dynamic>> plantGroups;
  final int totalCapacity;
  final int expectedOutput;
  final ValueChanged<String> onPlantTypeChanged;
  final ValueChanged<double> onCapacityChanged;
  final ValueChanged<double> onUnitsChanged;
  final ValueChanged<double> onEfficiencyChanged;
  final VoidCallback onAddPlant;

  const Sidebar({
    super.key,
    required this.plantType,
    required this.capacity,
    required this.units,
    required this.efficiency,
    required this.plantGroups,
    required this.totalCapacity,
    required this.expectedOutput,
    required this.onPlantTypeChanged,
    required this.onCapacityChanged,
    required this.onUnitsChanged,
    required this.onEfficiencyChanged,
    required this.onAddPlant,
  });

  static const _plantTypes = [
    'Solar PV', 'Wind Turbine', 'Hydropower', 'Gas Turbine', 'Nuclear'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 252,
      decoration: const BoxDecoration(
        color: AppTheme.bg,
        border: Border(right: BorderSide(color: AppTheme.border)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Plant configuration ──
            const _SectionLabel('Plant configuration'),
            const SizedBox(height: 2),

            const _FieldLabel('Plant type'),
            const SizedBox(height: 5),
            _Dropdown(
              value: plantType,
              items: _plantTypes,
              onChanged: onPlantTypeChanged,
            ),
            const SizedBox(height: 12),

            const _FieldLabel('Installed capacity (MW)'),
            const SizedBox(height: 5),
            _NumberInput(
              value: capacity,
              onChanged: onCapacityChanged,
            ),
            const SizedBox(height: 12),

            const _FieldLabel('Number of units'),
            const SizedBox(height: 5),
            _SliderRow(
              value: units,
              min: 1, max: 20,
              label: units.round().toString(),
              onChanged: onUnitsChanged,
            ),
            const SizedBox(height: 12),

            const _FieldLabel('Efficiency (%)'),
            const SizedBox(height: 5),
            _SliderRow(
              value: efficiency,
              min: 20, max: 99,
              label: '${efficiency.round()}%',
              onChanged: onEfficiencyChanged,
            ),
            const SizedBox(height: 14),

            // Add plant button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAddPlant,
                icon: const Icon(Icons.add, size: 16, color: AppTheme.tx),
                label: Text(
                  'Add plant group',
                  style: AppTheme.label.copyWith(fontSize: 13, color: AppTheme.tx),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  side: const BorderSide(color: AppTheme.border2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.r),
                  ),
                  backgroundColor: AppTheme.bg,
                ),
              ),
            ),

            // Plant group list
            if (plantGroups.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...plantGroups.map((p) => _PlantRow(plant: p)),
            ],

            const SizedBox(height: 24),

            // ── Computed output ──
            const _SectionLabel('Computed output'),
            const SizedBox(height: 2),
            _StatPill(label: 'Total capacity',  value: '${_fmt(totalCapacity)} MW'),
            _StatPill(label: 'Expected output', value: '${_fmt(expectedOutput)} MW'),
            _StatPill(label: 'Load factor',     value: '${efficiency.round()}%'),
          ],
        ),
      ),
    );
  }

  String _fmt(int v) {
    if (v >= 1000) {
      return '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}k';
    }
    return v.toString();
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: Text(text.toUpperCase(), style: AppTheme.sectionLabel),
  );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) =>
    Text(text, style: AppTheme.label.copyWith(fontSize: 13));
}

class _Dropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  const _Dropdown({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        border: Border.all(color: AppTheme.border2),
        borderRadius: BorderRadius.circular(AppTheme.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: AppTheme.label.copyWith(fontSize: 14),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }
}

class _NumberInput extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  const _NumberInput({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bg,
        border: Border.all(color: AppTheme.border2),
        borderRadius: BorderRadius.circular(AppTheme.r),
      ),
      child: TextField(
        controller: TextEditingController(text: value.round().toString()),
        keyboardType: TextInputType.number,
        style: AppTheme.label.copyWith(fontSize: 14),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          border: InputBorder.none,
        ),
        onSubmitted: (v) {
          final parsed = double.tryParse(v);
          if (parsed != null) onChanged(parsed);
        },
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final double value;
  final double min, max;
  final String label;
  final ValueChanged<double> onChanged;
  const _SliderRow({
    required this.value, required this.min, required this.max,
    required this.label, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.green,
              thumbColor: AppTheme.green,
              inactiveTrackColor: AppTheme.border2,
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min, max: max,
              divisions: (max - min).round(),
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 38,
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: AppTheme.label.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.green,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label, value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: AppTheme.pill,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.label.copyWith(fontSize: 13, color: AppTheme.greenDark)),
          Text(value,  style: AppTheme.label.copyWith(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.greenDark)),
        ],
      ),
    );
  }
}

class _PlantRow extends StatelessWidget {
  final Map<String, dynamic> plant;
  const _PlantRow({required this.plant});

  @override
  Widget build(BuildContext context) {
    final total = ((plant['capacity'] as double) * (plant['units'] as double)).round();
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: BorderRadius.circular(AppTheme.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plant['type'], style: AppTheme.label.copyWith(fontSize: 12, fontWeight: FontWeight.w500)),
                Text(
                  '${plant['capacity'].round()} MW × ${plant['units'].round()}',
                  style: AppTheme.small.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.greenBg,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              '$total MW',
              style: AppTheme.label.copyWith(
                fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.greenDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}